import tkinter as tk
from PIL import Image, ImageTk

from bilinear_interpolation import *
from img_tools import *
from matplotlib import pyplot as plt

root = tk.Tk()
root.title('Bilinear interpolation ARM')
root.geometry('1100x600+450+250')
root.resizable(False, False)


#array = np.ones((40,40))*150

arrayImgSrc = convert_img_array_rgb("pikachu.jpg")

print(arrayImgSrc)

arrayImgOut = convert_img_txt(arrayImgSrc)

print("convert to normal list")
#print(arrayImgOut)

arrayImgOut = bilinear_interpolation(arrayImgOut)

print("after bilineal")
print(arrayImgOut)

print("Src:")
#print(arrayImgSrc)
print("\nOut:")
print(arrayImgOut)

imgDimensions = 390

#plt.imshow(arrayImgOut, interpolation='nearest')
#plt.show()

#plt.imshow(arrayImgSrc, interpolation='nearest')
#plt.show()

imgSrc = ImageTk.PhotoImage(image=Image.fromarray(arrayImgSrc))
imgOut = ImageTk.PhotoImage(image=Image.fromarray(arrayImgOut))



label = tk.Label(root, text='Imagen original',font=("Helvetica", 24))
label.place(x=100, y=200-40)

canvas = tk.Canvas(root,width=imgDimensions,height=imgDimensions)
canvas.place(x=100,y=200)
canvas.create_image(0,0, anchor="nw", image=imgSrc)


label = tk.Label(root, text='Imagen interpolada',font=("Helvetica", 24))
label.place(x=600, y=200-40)

canvas = tk.Canvas(root,width=imgDimensions,height=imgDimensions)
canvas.place(x=600,y=200)
#canvas.create_image(0,0, anchor="nw", image=imgOut)



root.mainloop()

