from matplotlib.image import imread
import numpy as np

#   Imprime una matriz con formato
def printer(array2d):  

    for row in array2d:
        for col in row:
            print(col, "\t\t", sep="", end="")

        print()

def convert_img_txt(array):

    result = []

    for r in range(len(array)):
        row = []
        for c in range(len(array)):
            row.append(array[r][c][0])

        result.append(row)

    return result


image  = imread("imgs/pikachu.jpg")  

I = image.tolist()

#print(type(image))
#printer(I)
printer(convert_img_txt(I))
#print(len(I[0]))