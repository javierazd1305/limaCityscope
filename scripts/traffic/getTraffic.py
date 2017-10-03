import json
import urllib2
import pandas as pd
import csv
import os

#https://maps.googleapis.com/maps/api/distancematrix/json?origins=-12.13193318,-77.02584255&destinations=-12.046394,-77.030862&departure_time=1505914200&mode=driving&key=AIzaSyCLY2HT3qgE9_PhVUl35FaUkSYWzMVmjM4
def sendRequest(lat,lng, apiKey):
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
    traffic_model = ["best_guess", "pessimistic"]
    total = []
    for i, item in enumerate(traffic_model):
        destination = "&destinations=-12.046394,-77.030862&mode=driving&departure_time=1506990600&traffic_model=" + traffic_model[i] + "&key="
        newUrl = url + str(lat) +","+ str(lng) + destination + apiKey
        data = requestType(newUrl)
        total.append(data)
    return total
def requestType(newUrl):
    response = urllib2.urlopen(newUrl)
    traffic = json.load(response)
    if traffic['status'] == 'OK':
        return traffic
    elif traffic['status'] == 'ZERO_RESULTS' or traffic['status'] == 'NOT_FOUND':
        print 'not found'
        return None
    elif traffic['status'] == 'OVER_QUERY_LIMIT':
        print 'other key!'
        return "null"
    elif traffic['status'] == 'INVALID_REQUEST':
        print 'bad request url'
        return 'null'

def managerKeys(lat, lng):
    keys = ['AIzaSyCLY2HT3qgE9_PhVUl35FaUkSYWzMVmjM4',"AIzaSyCuKx1ltx2dhFeoHfElcuBVOZTcQ7JbzxU", "AIzaSyDNfutBGqOPCAEvrmoWGElX977DC4qUIRE", "AIzaSyDdXRmzGheKvksQAI2_cxl6oQOINhrHCG8","AIzaSyBahH6aXX-RkP_wdkTn2-W5LOHR6uPwWFQ"]
    for i in keys:
        data = sendRequest(lat, lng, i)
        if data[0] != "null":
            return data
        else:
            break

filename = "traffic_2.csv"
data = pd.read_csv("latlng.csv")
#data = data[1:]
tamano =  data.shape[0]
actual = 0

with open(filename, 'ab') as file:
    w = csv.writer(file)
    if  os.stat(filename).st_size == 0:
        w.writerow(["codigo","lat","lng","distance","best_guess_time","pessimistic_time","kmm","ratio"])

    for index, i in enumerate(data.iterrows()):
        codigo = data.iloc[index]["codigo"]
        lat = data.iloc[index]["lat"]
        lng = data.iloc[index]["lng"]
        try:
            data1 = managerKeys(lat, lng)
        except Exception:
            print 'try again'
            data1 = managerKeys(lat, lng)

        traffic = []
        for i, item in enumerate(data1):
            traffic.append([float(data1[i]['rows'][0]["elements"][0]["duration_in_traffic"]["text"].split(" ")[0]),float(data1[i]['rows'][0]["elements"][0]["distance"]["text"].split(" ")[0])])
        distance = traffic[0][1]
        best_guess_time = traffic[0][0]
        pessimistic_time = traffic[1][0]
        kmm = distance/best_guess_time
        ratio = pessimistic_time/best_guess_time
        #print distance, best_guess_time, pessimistic_time
        row = codigo, lat, lng, distance, best_guess_time, pessimistic_time, kmm, ratio
        w.writerow(row)
        print codigo
