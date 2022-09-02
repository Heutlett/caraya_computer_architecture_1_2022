
import tkinter as tk
from tkinter import ttk
from calendar import month_name
from tkinter.messagebox import showinfo
from tkinter import filedialog
from PIL import Image, ImageTk

from bilinear_interpolation import *
from img_tools import *
from drawer import *


class Interfaz(ttk.Frame):
    
    # Ventana principal
    root_frame = tk.Tk()

    # StringVar: nombre imagen
    entry_var = tk.StringVar()
    entry_var.set("imagen.jpg")

    # Canvas
    canvasSrc = 0
    canvasQuad = 0
    canvasOut = 0

    # Variables

    imgSrc = ""
    imgOut = "result.jpg"

    imgSrcDimensions = 0
    imgOutDimensions = 0

    # Flags

    plot = False

    def __init__(self):
        super().__init__()

        self.iniciar_interfaz()

    def iniciar_interfaz(self):

        self.root_frame.title('Bilinear interpolation ARM')
        self.root_frame.geometry('1700x810')
        self.root_frame.resizable(0, 0)

        # This will create style object
        style = ttk.Style()
        
        # This will be adding style, and
        # naming that style variable as
        # W.Tbutton (TButton is used for ttk.Button).
        style.configure('my.TButton', font =
                    ('Helvetica', 24, 'bold'),
                        foreground = 'black',borderwidth = '4')


        labelTitulo = tk.Label(self.root_frame, text='Bilinear Interpolation in ARM',font=("Helvetica", 35)).place(x=477, y=34)
        
        label_entry_img = tk.Label(self.root_frame, text='Type image name:',font=("Helvetica", 20)).place(x=100, y=158)
        entry_img = ttk.Entry(self.root_frame, textvariable=self.entry_var, font=("Helvetica", 20)).place(x=360, y=154)
        button_iniciar = ttk.Button(self.root_frame, text='Ejecutar interpolación bilinear', style='my.TButton',
                                          command=self.fun_ejecutar_interpolacion).place(x=1000,y=150)

        label1 = tk.Label(self.root_frame, text='Source Image',font=("Helvetica", 24)).place(x=250-100, y=260)
        label2 = tk.Label(self.root_frame, text='Select one quadrant',font=("Helvetica", 24)).place(x=850-180, y=260)
        label3 = tk.Label(self.root_frame, text='Interpolated Image',font=("Helvetica", 24)).place(x=850+450, y=260)


        
        
        # Evento que captura la posicion de un click 

        def motion(event):
            x, y = event.x, event.y
            print('{}, {}'.format(x, y))

        self.root_frame.bind('<Button-1>', motion)

        self.root_frame.mainloop()

    #######################################################################################################################

    
    def fun_ejecutar_interpolacion(self):

        imgSrc = self.entry_var.get()
        imgOut = "result.jpg"

        arrayImgSrc = convert_img_array_rgb(imgSrc)
        arrayImgOut = convert_img_txt(arrayImgSrc)
        arrayImgOut = bilinear_interpolation(arrayImgOut)

        self.imgSrcDimensions = len(arrayImgSrc)
        self.imgOutDimensions = len(arrayImgOut)-1

        drawImage(arrayImgOut)

        arrayImgOut = convert_img_array_rgb(imgOut)

        self.imgSrc = ImageTk.PhotoImage(image=Image.fromarray(arrayImgSrc))
        self.imgOut = ImageTk.PhotoImage(image=Image.fromarray(arrayImgOut))

        self.canvasSrc = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasSrc.place(x=180-100,y=308)
        self.canvasSrc.create_image(0,0, anchor="nw", image=self.imgSrc)

        self.canvasQuad = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasQuad.place(x=770-140,y=308)
        self.canvasQuad.create_image(0,0, anchor="nw", image=self.imgSrc)

        self.canvasOut = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasOut.place(x=770+450,y=308)
        self.canvasOut.create_image(0,0, anchor="nw", image=self.imgOut)

        self.plot = True


if __name__ == "__main__":
    interfaz = Interfaz()

    # create_main_window()
