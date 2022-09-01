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