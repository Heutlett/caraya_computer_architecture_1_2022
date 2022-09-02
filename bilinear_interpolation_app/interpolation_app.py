
from cgitb import enable
import tkinter as tk
from tkinter import ttk
from calendar import month_name
from tkinter.messagebox import showinfo
from tkinter import filedialog
from PIL import Image, ImageTk
import os
from bilinear_interpolation import *
from img_tools import *
from drawer import *


class Interfaz(ttk.Frame):
    
    # Ventana principal
    root_frame = tk.Tk()

    # StringVar: nombre imagen
    entry_var = tk.StringVar()
    entry_var.set("imagen.jpg")

    entry_Quad = tk.StringVar()
    entry_Quad.set("0")

    # Canvas
    canvasSrc = 0
    canvasQuad = 0
    canvasOut = 0

    # Variables

    imgSrc = ""
    imgQuad = "imageSrcQuadrants.jpg"
    imgOut = "result.jpg"
    arrayImgSrc = []
    

    imgSrcDimensions = 390
    imgOutDimensions = 390

    # Flags

    loaded = False


    def __init__(self):
        super().__init__()

        self.iniciar_interfaz()

    def iniciar_interfaz(self):

        self.root_frame.title('Bilinear interpolation ARM')
        self.root_frame.geometry('1700x810')
        self.root_frame.resizable(0, 0)

        # This will create style object
        style = ttk.Style()
        
        style.configure('my.TButton', font =
                    ('Helvetica', 24, 'bold'),
                        foreground = 'black',borderwidth = '4')


        labelTitulo = tk.Label(self.root_frame, text='Bilinear Interpolation in ARM',font=("Helvetica", 35)).place(x=477, y=34)
        
        label_entry_img = tk.Label(self.root_frame, text='Type image name:',font=("Helvetica", 20)).place(x=80, y=158)
        entry_img = ttk.Entry(self.root_frame, textvariable=self.entry_var, font=("Helvetica", 20)).place(x=320, y=154)

        button_cargarImg = ttk.Button(self.root_frame, text='Load image', style='my.TButton',
                                    command=self.fun_cargar_img).place(x=720,y=150)

        button_iniciar = ttk.Button(self.root_frame, text='Ejecutar interpolación bilinear', style='my.TButton',
                                          command=self.fun_ejecutar_interpolacion).place(x=1120,y=150)

        label1 = tk.Label(self.root_frame, text='Source Image',font=("Helvetica", 24)).place(x=250-100, y=260)
        label2 = tk.Label(self.root_frame, text='Select one quadrant',font=("Helvetica", 24)).place(x=850-180, y=260)
        label3 = tk.Label(self.root_frame, text='Interpolated Image',font=("Helvetica", 24)).place(x=850+450, y=260)

        labelQuad = tk.Label(self.root_frame, text='Quadrant:',font=("Helvetica", 20),foreground="red").place(x=710, y=740)
        label_quad = ttk.Label(self.root_frame, width=5, justify="center", textvariable=self.entry_Quad, font=("Consolas", 30)).place(x=850, y=730)

        
        
        # Evento que captura la posicion de un click 

        def motion(event):
            x, y = event.x, event.y
            print('{}, {}'.format(x, y))

        self.root_frame.bind('<Button-1>', motion)

        self.root_frame.mainloop()

    #######################################################################################################################

    def fun_cargar_img(self):

        if (self.entry_var.get() == ""):

            tk.messagebox.showinfo(title="Error", message="You must enter the name of the image!")
            return 

        files = os.listdir('./imgs')

        if (self.entry_var.get() not in files):
            tk.messagebox.showinfo(title="Error", message="The image you entered does not exist")
            return 

        self.imgSrc = self.entry_var.get()
        imgSrcQuadrants = "imageSrcQuadrants.jpg"

        self.arrayImgSrc = convert_img_array_rgb(self.imgSrc)
        arraySrcQuadrants = convert_img_txt(self.arrayImgSrc)

        self.imgSrcDimensions = len(self.arrayImgSrc)

        drawQuadrants(arraySrcQuadrants)

        arrayImgQuadrants = convert_img_array_rgb(imgSrcQuadrants)

        self.imgSrc = ImageTk.PhotoImage(image=Image.fromarray(self.arrayImgSrc))
        self.imgQuad = ImageTk.PhotoImage(image=Image.fromarray(arrayImgQuadrants))

        self.canvasSrc = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasSrc.place(x=180-100,y=308)
        self.canvasSrc.create_image(0,0, anchor="nw", image=self.imgSrc)

        self.canvasQuad = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasQuad.place(x=770-140,y=308)
        self.canvasQuad.create_image(0,0, anchor="nw", image=self.imgQuad)

        self.loaded = True


    def fun_ejecutar_interpolacion(self):
        
        if(self.entry_var.get() != "" and self.loaded):

            imgOut = "result.jpg"

            arrayImgOut = convert_img_txt(self.arrayImgSrc)
            arrayImgOut = bilinear_interpolation(arrayImgOut)

            drawImage(arrayImgOut)

            arrayImgOut = convert_img_array_rgb(imgOut)

            self.imgOut = ImageTk.PhotoImage(image=Image.fromarray(arrayImgOut))

            self.canvasOut = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
            self.canvasOut.place(x=770+450,y=308)
            self.canvasOut.create_image(0,0, anchor="nw", image=self.imgOut)

            tk.messagebox.showinfo(title="Success", message="The interpolated image has been generated successfully!")

        elif(self.entry_var.get() == ""):
            tk.messagebox.showinfo(title="Error", message="You must enter the name of the image!")
        else:

            tk.messagebox.showinfo(title="Error", message="You must first upload an image!")


if __name__ == "__main__":
    interfaz = Interfaz()

    # create_main_window()
