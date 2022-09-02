import tkinter as tk
from PIL import Image

from bilinear_interpolation import *
from img_tools import *
from matplotlib import pyplot as plt

# Dibuja una matriz de pixeles en un fondo blanco y lo guarda como una imagen
def drawImage(imgMatrix):

    image = Image.open("imgs/white1500.jpg") 

    for r in range(len(imgMatrix)):
        for c in range(len(imgMatrix)):
            
            color = imgMatrix[r][c]
            #print("pintando el color: ", color, " en las cordenadas: ", c,",",r)
            image.putpixel( (c, r), (color, color, color) )

    image.save("imgs/result.jpg")

    print("Imagen guardada correctamente")

def drawQuadrants(imgMatrix):

    image = Image.open("imgs/white1500.jpg") 

    for r in range(len(imgMatrix)):
        for c in range(len(imgMatrix)):
            
            color = imgMatrix[r][c]
            #print("pintando el color: ", color, " en las cordenadas: ", c,",",r)

            image.putpixel( (c, r), (color, color, color) )

            if (r == 98 or r == 195 or r == 293 or c == 98 or c == 195 or c == 293):
                image.putpixel( (c, r), (255, 0, 0) )

    image.save("imgs/imageSrcQuadrants.jpg")

    print("Imagen guardada correctamente")

    pass
