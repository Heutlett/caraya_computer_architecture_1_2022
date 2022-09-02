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
