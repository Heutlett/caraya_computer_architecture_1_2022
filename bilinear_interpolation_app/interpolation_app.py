import tkinter as tk
from PIL import Image, ImageTk

from bilinear_interpolation import *
from img_tools import *
from drawer import *

root = tk.Tk()
root.title('Bilinear interpolation ARM')
root.geometry('1500x900+100+100')
root.resizable(False, False)

imgSrc = "imagen.jpg"
imgOut = "result.jpg"

arrayImgSrc = convert_img_array_rgb(imgSrc)
arrayImgOut = convert_img_txt(arrayImgSrc)
arrayImgOut = bilinear_interpolation(arrayImgOut)

imgSrcDimensions = len(arrayImgSrc)
imgOutDimensions = len(arrayImgOut)-1

drawImage(arrayImgOut)

arrayImgOut = convert_img_array_rgb(imgOut)

imgSrc = ImageTk.PhotoImage(image=Image.fromarray(arrayImgSrc))
imgOut = ImageTk.PhotoImage(image=Image.fromarray(arrayImgOut))


label = tk.Label(root, text='Imagen original',font=("Helvetica", 24))
label.place(x=100, y=200-40)

canvas = tk.Canvas(root,width=imgSrcDimensions,height=imgSrcDimensions)
canvas.place(x=100,y=200)
canvas.create_image(0,0, anchor="nw", image=imgSrc)


label = tk.Label(root, text='Imagen interpolada',font=("Helvetica", 24))
label.place(x=600, y=200-40)

canvas = tk.Canvas(root,width=imgOutDimensions,height=imgOutDimensions)
canvas.place(x=600,y=200)
canvas.create_image(0,0, anchor="nw", image=imgOut)




root.mainloop()

