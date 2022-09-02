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

# Convierte una imagen RGB de pixeles [R,G,B] a pixeles B&W [B] 
def convert_img_txt(array):

    array = array.tolist()

    result = []

    for r in range(len(array)):
        row = []
        for c in range(len(array)):
            row.append(array[r][c][0])

        result.append(row)

    return result

# Convierte una imagen a un np.array con pixeles pixeles [R,G,B] o B&W [B] dependiendo del formato de la imagen
def convert_img_array_rgb(img_name):

    image  = imread("imgs/"+img_name)  

    return image
    

