import tkinter as tk
from PIL import Image

from bilinear_interpolation import *
from img_tools import *
from matplotlib import pyplot as plt

img = "imagen.jpg"

arrayImgSrc = convert_img_array_rgb(img)

#printer(arrayImgSrc)

arrayImgOut = convert_img_txt(arrayImgSrc)
arrayImgOut = bilinear_interpolation(arrayImgOut)

# creating a image object
image = Image.open("imgs/white1500.jpg") 

  
for r in range(len(arrayImgOut)):
    for c in range(len(arrayImgOut)):
        
        color = arrayImgOut[r][c]
        #print("pintando el color: ", color, " en las cordenadas: ", c,",",r)
        image.putpixel( (c, r), (color, color, color) )
  
image.show()


