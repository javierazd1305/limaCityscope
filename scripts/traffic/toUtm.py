import pandas as pd
import ast
import utm
import csv
import os

data = pd.read_csv('positions.txt', sep="\t", header=None)
filename = "latlng.csv"
with open(filename, 'wb') as file:
    w = csv.writer(file)
    if  os.stat(filename).st_size == 0:
        w.writerow(["codigo","lat","lng"])

    for index, i in enumerate(data.iterrows()):
        lat = ast.literal_eval(data.iloc[index].values[0])[0]
        lng = ast.literal_eval(data.iloc[index].values[0])[1]
        utm1 = utm.to_latlon(lat,lng,18,'L')
        newLat = utm1[0]
        newLng = utm1[1]
        row = index, newLat, newLng
        w.writerow(row)

#print ast.literal_eval(data.head(1)[0].values[0])[0],ast.literal_eval(data.head(1)[0].values[0])[1]
#print utm.to_latlon(279534.5,8658038.0,18,'L')
