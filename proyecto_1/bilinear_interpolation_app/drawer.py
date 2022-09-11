import tkinter as tk
from PIL import Image
from img_tools import *
from matplotlib import pyplot as plt

# Dibuja una matriz de pixeles en un fondo blanco y lo guarda como una imagen
def drawImage(imgMatrix):

    image = Image.open("imgs/white289x289.jpg") 

    for r in range(len(imgMatrix)):
        for c in range(len(imgMatrix)):
            
            color = imgMatrix[r][c]
            #print("pintando el color: ", color, " en las cordenadas: ", c,",",r)
            image.putpixel( (c, r), (color, color, color) )

    image.save("imgs/result.jpg")
    image.save("result.jpg")

    print("Se ha dibujado exitosamente el resultado\n")
    print("Se ha generado el archivo de la imagen en la ruta: /imgs/result.jpg ")


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



def paintQuadrant(imgMatrix,x,y,q):

    image = Image.open("imgs/white1500.jpg") 
    counter = 0

    for r in range(len(imgMatrix)):
        for c in range(len(imgMatrix)):
            
            color = imgMatrix[r][c]
            #print("pintando el color: ", color, " en las cordenadas: ", c,",",r)

            image.putpixel( (c, r), (color, color, color) )

            if (r == 98 or r == 195 or r == 293 or c == 98 or c == 195 or c == 293):
                image.putpixel( (c, r), (255, 0, 0) )

            x = c
            y = r

            if (x < 97 and x > 0):
                if (y < 97 and counter%5==0 and q == 0):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 98 and y < 194 and counter%5==0 and q == 5):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 195 and y < 292 and counter%5==0 and q == 9):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 293 and y < 389 and counter%5==0 and q == 13):
                    image.putpixel( (c, r), (255, 0, 0) )

            if (x < 194 and x > 98):
                if (y < 97 and counter%5==0 and q == 2):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 98 and y < 194 and counter%5==0 and q == 6):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 195 and y < 292 and counter%5==0 and q == 10):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 293 and y < 389 and counter%5==0 and q == 14):
                    image.putpixel( (c, r), (255, 0, 0) )

            if (x < 292 and x > 195):
                if (y < 97 and counter%5==0 and q == 3):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 98 and y < 194 and counter%5==0 and q == 7):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 195 and y < 292 and counter%5==0 and q == 11):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 293 and y < 389 and counter%5==0 and q == 15):
                    image.putpixel( (c, r), (255, 0, 0) )

            if (x < 389 and x > 293):
                if (y < 97 and counter%5==0 and q == 4):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 98 and y < 194 and counter%5==0 and q == 8):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 195 and y < 292 and counter%5==0 and q == 12):
                    image.putpixel( (c, r), (255, 0, 0) )
                elif (y> 293 and y < 389 and counter%5==0 and q == 16):
                    image.putpixel( (c, r), (255, 0, 0) )
                        

            counter = counter +1 


    image.save("imgs/imageSrcQuadrants.jpg")

    
