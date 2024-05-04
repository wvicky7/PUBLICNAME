from matplotlib.figure import Figure
import base64
from io import BytesIO
from flask import Flask

import numpy as np 
from app import connect
from sklearn import linear_model
from sklearn import mean_squared_error
from sklearn import train_test_split

#Query must only select goat age and overall_adg as attributes
@app.route("/")
def generateGrowthCurve():
    rows = connect(request.form['query'])
    relation = np.array(rows) 
    relation[:,1].astype(np.float)

    X = relation[:,0]
    y = relation[:,1]

    fig = Figure()
    ax = fig.subplots()
    ax.scatter(X, y, c="r", label='Data')

    buf = BytesIO()
    fig.savefig(buf, format=png)

    data = base64.b64encode(buf.getbuffer()).decode("ascii")
    return f"<img src='data:image/png;base64,{data}'/>"

if __name__ == '__main__':
    app.run(debug = True)