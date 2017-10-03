import pandas as pd
import csv
import os

data = pd.read_csv("comercios.csv")
homo = pd.read_csv("homologacion.csv")
typePOI = data["GIRO"]

EDUCACION = pd.read_csv("educacion.csv")
COMIDA = pd.read_csv("comida.csv")
HOSPEDAJE = pd.read_csv("hospedaje.csv")
SALUD = pd.read_csv("salud.csv")
DIVERSION = pd.read_csv("diversion.csv")

educacionLista = EDUCACION['DESCRIP'].values.tolist()
comidaLista = COMIDA['DESCRIP'].values.tolist()
hospedajeLista = HOSPEDAJE['DESCRIP'].values.tolist()
saludLista = SALUD['DESCRIP'].values.tolist()
diversionLista = DIVERSION['DESCRIP'].values.tolist()

filename = "new_comercios.csv"

with open(filename, 'wb') as file:
    w = csv.writer(file)
    if  os.stat(filename).st_size == 0:
        print 'write headers'
        w.writerow(["CODIGO","NOMBRE-COMERCIAL","NOMBRE","NOMBRE-DE-VIA","GIRO","GEO_X","GEO_Y","HOMOLOGACION"])

    for index, i in enumerate(data.iterrows()):
        codigo = i[1]["CODIGO"]
        print codigo
        nombre_comercial = i[1]["NOMBRE-COMERCIAL"]
        nombre = i[1]["NOMBRE"]
        nombre_de_via = i[1]["NOMBRE-DE-VIA"]
        geo_x = i[1]["GEO_X"]
        geo_y = i[1]["GEO_Y"]
        tipoPOI = i[1]["GIRO"]
        if tipoPOI in educacionLista:
            homo = "EDUCACION"
        elif tipoPOI in comidaLista:
            homo = "COMIDA"
        elif tipoPOI in hospedajeLista:
            homo = "HOSPEDAJE"
        elif tipoPOI in saludLista:
            homo = "SALUD"
        elif tipoPOI in diversionLista:
            homo = "DIVERSION"
        else:
            homo = "OTRO"

        row = codigo, nombre_comercial, nombre, nombre_de_via, tipoPOI, geo_x, geo_y, homo
        w.writerow(row)

'''
uniqueValues = typePOI.unique()
for i in uniqueValues:
    print i
'''
