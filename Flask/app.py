#! /usr/bin/python3

"""
This is an example Flask | Python | Psycopg2 | PostgreSQL
application that connects to the 7dbs database from Chapter 2 of
_Seven Databases in Seven Weeks Second Edition_
by Luc Perkins with Eric Redmond and Jim R. Wilson.
The CSC 315 Virtual Machine is assumed.

John DeGood
degoodj@tcnj.edu
The College of New Jersey
Spring 2020

----

One-Time Installation

You must perform this one-time installation in the CSC 315 VM:

# install python pip and psycopg2 packages
sudo pacman -Syu
sudo pacman -S python-pip python-psycopg2 python-flask

----

Usage

To run the Flask application, simply execute:

export FLASK_APP=app.py 
flask run
# then browse to http://127.0.0.1:5000/

----

References

Flask documentation:  
https://flask.palletsprojects.com/  

Psycopg documentation:
https://www.psycopg.org/

This example code is derived from:
https://www.postgresqltutorial.com/postgresql-python/
https://scoutapm.com/blog/python-flask-tutorial-getting-started-with-flask
https://www.geeksforgeeks.org/python-using-for-loop-in-flask/

Improvements:
- add more filters to the first graph
- make the second page an html page itself, not just the image generated
- change x axis of first graph to age in days instead of weight measured
"""

import psycopg2
from config import config
from flask import Flask, render_template, request

from matplotlib.figure import Figure
import numpy as np 
import pandas as pd
from sklearn import linear_model
from sklearn.model_selection import train_test_split
import base64
from io import BytesIO

# Connect to the PostgreSQL database server
def connect(query):
    print(query)
    conn = None
    try:
        # read connection parameters
        params = config()
 
        # connect to the PostgreSQL server
        print('Connecting to the %s database...' % (params['database']))
        conn = psycopg2.connect(**params)
        print('Connected.')
      
        # create a cursor
        cur = conn.cursor()
        
        # execute a query using fetchall()
        cur.execute(query)
        rows = cur.fetchall()

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    # return the query result from fetchall()

    # print(rows)
    return rows
 
# app.py
app = Flask(__name__)


# serve form web page
@app.route("/")
def form():
    return render_template('my-form.html')

@app.route("/")
def filter():
    return render_template('my-result.html')

# handle venue POST and serve result web page
@app.route('/breedgroup-handler', methods=['POST'])
def breedgroup_handler():
    # rows = connect('SELECT A.animal_id, W.alpha_value, W.when_measured, C.age_at_measure FROM Animal A, weights W, weight_ages C WHERE A.animal_group = \''+request.form['breed_group']+'\' AND A.animal_id = W.animal_id AND A.animal_id = C.animal_id AND W.when_measured = C.when_measured;')
    rows = connect('''SELECT A.animal_id, C.alpha_value, C.when_measured, C.age_at_measure 
                        FROM Animal A, weight_ages C 
                        WHERE A.animal_id=C.animal_id 
                            AND A.animal_group='''+request.form['breed_group']+''';''')
    col_names = ["Animal ID", "Weight", "Date Measured", "Age"]
    relation = pd.DataFrame(rows, columns=col_names) 
#remove dups to fix the line generated
    
    # remove empty strings and convert to float
    relation = relation.replace(r'^\s*$', np.nan, regex=True)
    relation = relation.dropna()
    relation = relation[relation["Age"] >= 0]
    relation["Weight"] = relation["Weight"].astype(float)
    relation = relation[relation["Weight"] > 0]
    relation.sort_values("Age", axis=0, ascending=True, inplace=True)

    X_age = relation["Age"]
    #REDO THE LINEAR REGRESSION ON X_age INSTEAD.......!!!!!!!!!
    y = relation["Weight"]

    print("X_age:")
    print(X_age)
    print("y:")
    print(y)

    degree = 3

    # new x axis
    X = np.ones(X_age.shape)
    for p in range(1, degree+1):
        X = np.column_stack((X, X_age**p))

    model = linear_model.LinearRegression(fit_intercept=False)
    model.fit(X, y)
    prediction = model.predict(X)

    fig = Figure()
    ax = fig.subplots()
    ax.scatter(X_age, y, c="r")
    ax.plot(X_age, prediction, color='b')
    ax.set_xlabel("Age in Days")
    ax.set_ylabel(col_names[1])

    buf = BytesIO()
    fig.savefig(buf, format="png")

    data = base64.b64encode(buf.getbuffer()).decode("ascii")
    # return f"<img src='data:image/png;base64,{data}'/>"

    return render_template('my-result.html', img_url=data)

# handle query POST and serve result web page
@app.route('/query-handler', methods=['POST'])
def query_handler():
    # warning()
    rows = connect('''SELECT T.vax_time, A.overall_adg 
                        FROM Animal A, time_til_vax T 
                        WHERE A.animal_id = T.animal_id 
                            AND A.dob > \'''' + request.form['start_date'] + ''' 00:00:00\' 
                            AND A.dob < \'''' + request.form['end_date'] + ''' 00:00:00\' 
                            AND T.picklistvalue_id = '''+ request.form['vaccine']+''';''')
    # rows = connect(request.form['query'])
    col_names = ["Vax Time (days)", "Overall ADG"]
    relation = pd.DataFrame(rows, columns=col_names) 

    # remove empty strings and convert to float
    relation = relation.replace(r'^\s*$', np.nan, regex=True)
    relation = relation.drop(relation[relation["Vax Time (days)"] < 0].index)
    relation["Overall ADG"] = relation["Overall ADG"].astype(float)

    X = relation["Vax Time (days)"]
    y = relation["Overall ADG"]

    fig = Figure()
    ax = fig.subplots()
    ax.scatter(X, y, c="r")
    ax.set_xlabel(col_names[0])
    ax.set_ylabel(col_names[1])

    buf = BytesIO()
    fig.savefig(buf, format="png")

    data = base64.b64encode(buf.getbuffer()).decode("ascii")

    return render_template('my-result.html', img_url=data)
    # return f"<img src='data:image/png;base64,{data}'/>"

# @app.route("/warning", methods=['GET', 'POST'])
# def warning():
#     error = None
#     if request.method == "POST":
#         if request.form['start_date'] > request.form['end_date']:
#             flash = "WARNING: End date is prior to start date"
#             print("WARNING: End date is prior to start date")
#             return render_template('my-form.html')

if __name__ == '__main__':
    app.run(debug = True)
