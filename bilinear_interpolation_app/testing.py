import re
from matplotlib.image import imread
import numpy as np
from bilinear_interpolation import *

#   Imprime una matriz con formato
def printer(array2d):  

    for row in array2d:
        for col in row:
            print(col, "\t\t", sep="", end="")

        print()

def convert_img_txt(array):

    array = array.tolist()

    result = []

    for r in range(len(array)):
        row = []
        for c in range(len(array)):
            row.append(array[r][c][0])

        result.append(row)

    return result

def convert_txt_img(array):

    result = []

    for r in range(len(array)):
        row = []
        for c in range(len(array)):
            row.append([array[r][c],array[r][c],array[r][c]])

        result.append(row)

    #SOLUCIONAR ESTO
    for r in range(len(result)):
        
        result[r].append([0,0,0])
        result[r].append([0,0,0])

    result.append(result[0])
    result.append(result[0])

    return np.array(result)

def convert_img_array_rgb(img_name):

    image  = imread("imgs/"+img_name)  

    return image



I = convert_img_array_rgb("pikachu10.jpg")

I2 = convert_img_txt(I)

I2 = bilinear_interpolation(I2)

I2 = convert_txt_img(I2)

print("Src:")
#print(I)

contador = 0
print(len(I),"x",len(I[0]))
for i in I:
    #print("row: ",contador)
    #print(i)
    #print()
    contador = contador +1

print()
print("Out")
#print(I2)

contador = 0
print(len(I2),"x",len(I2[0]))
for i in I2:
    #print("row: ",contador)
    #print(i)
    #print()
    contador = contador +1
from matplotlib import pyplot as plt

plt.imshow(I2, interpolation='nearest')
plt.show()
