
from cgitb import enable
import tkinter as tk
from tkinter import ttk
from calendar import month_name
from tkinter.messagebox import showinfo
from tkinter import filedialog
from turtle import bgcolor
from PIL import Image, ImageTk
import os
from bilinear_interpolation import *
from img_tools import *
from drawer import *
import os
from optimized_final import *


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
    imgSelected = ""

    arrayImgSrc = []
    arraySrcQuadrants = []
    arrayImgSelect = []
    arrayAssembly = []
    

    imgSrcDimensions = 390
    imgOutDimensions = 390

    # Flags

    loaded = False
    quad_selected = False


    def __init__(self):
        super().__init__()

        self.iniciar_interfaz()

    def iniciar_interfaz(self):

        self.root_frame.title('Bilinear interpolation ARM')
        self.root_frame.geometry('1700x810')
        self.root_frame.resizable(0, 0)

        # This will create style object
        style = ttk.Style()
        
        style.configure('my.TButton',  background = 'yellow',font =
                    ('Helvetica', 24, 'bold'),
                        foreground = 'black',borderwidth = '4')
        
        style.configure('my2.TButton',  background = 'green',font =
            ('Helvetica', 24, 'bold'),
                foreground = 'black',borderwidth = '4')

       


        labelTitulo = tk.Label(self.root_frame, text='Bilinear Interpolation in ARM',font=("Helvetica", 35)).place(x=477, y=34)
        
        label_entry_img = tk.Label(self.root_frame, text='Type image name:',font=("Helvetica", 20)).place(x=80, y=158)
        entry_img = ttk.Entry(self.root_frame, textvariable=self.entry_var, font=("Helvetica", 20)).place(x=320, y=154)

        button_cargarImg = ttk.Button(self.root_frame, text='Load image', style='my.TButton',
                                    command=self.fun_cargar_img).place(x=720,y=150)

        button_iniciar = ttk.Button(self.root_frame, text='Execute', style='my2.TButton',
                                          command=self.fun_ejecutar_interpolacion).place(x=1320,y=150)

        label1 = tk.Label(self.root_frame, text='Source Image',font=("Helvetica", 24)).place(x=250-100, y=260)
        label2 = tk.Label(self.root_frame, text='Select one quadrant',font=("Helvetica", 24)).place(x=850-180, y=260)
        label3 = tk.Label(self.root_frame, text='Interpolated Image',font=("Helvetica", 24)).place(x=850+450, y=260)

        labelQuad = tk.Label(self.root_frame, text='Quadrant:',font=("Helvetica", 20),foreground="red").place(x=710, y=740)
        label_quad = ttk.Label(self.root_frame, width=5, justify="center", textvariable=self.entry_Quad, font=("Consolas", 30)).place(x=850, y=730)

        
        
        # Evento que captura la posicion de un click 

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
        self.arraySrcQuadrants = convert_img_txt(self.arrayImgSrc)

        drawQuadrants(self.arraySrcQuadrants)

        self.arrayImgQuadrants = convert_img_array_rgb(imgSrcQuadrants)

        self.imgSrc = ImageTk.PhotoImage(image=Image.fromarray(self.arrayImgSrc))
        self.imgQuad = ImageTk.PhotoImage(image=Image.fromarray(self.arrayImgQuadrants))

        self.canvasSrc = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasSrc.place(x=180-100,y=308)
        self.canvasSrc.create_image(0,0, anchor="nw", image=self.imgSrc)



        self.loaded = True

        self.canvasQuad = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
        self.canvasQuad.place(x=770-140,y=308)
        self.canvasQuad.create_image(0,0, anchor="nw", image=self.imgQuad)
        self.canvasQuad.bind("<Button-1>", self.motion)

    def motion(self,event):
            x, y = event.x, event.y
            
            quad = 0

            if (x < 97 and x > 0):
                if (y < 97):
                    quad = 0
                elif (y> 98 and y < 194):
                    quad = 5
                elif (y> 195 and y < 292):
                    quad = 9
                elif (y> 293 and y < 389):
                    quad = 13

            if (x < 194 and x > 98):
                if (y < 97):
                    quad = 2
                elif (y> 98 and y < 194):
                    quad = 6
                elif (y> 195 and y < 292):
                    quad = 10
                elif (y> 293 and y < 389):
                    quad = 14

            if (x < 292 and x > 195):
                if (y < 97):
                    quad = 3
                elif (y> 98 and y < 194):
                    quad = 7
                elif (y> 195 and y < 292):
                    quad = 11
                elif (y> 293 and y < 389):
                    quad = 15

            if (x < 389 and x > 293):
                if (y < 97):
                    quad = 4
                elif (y> 98 and y < 194):
                    quad = 8
                elif (y> 195 and y < 292):
                    quad = 12
                elif (y> 293 and y < 389):
                    quad = 16

            self.entry_Quad.set(quad)
            self.quad_selected = True

            imgSrcQuadrants = "imageSrcQuadrants.jpg"

            paintQuadrant(self.arraySrcQuadrants,x,y,quad)

            self.arrayImgQuadrants = convert_img_array_rgb(imgSrcQuadrants)

            self.imgQuad = ImageTk.PhotoImage(image=Image.fromarray(self.arrayImgQuadrants))

            self.canvasQuad = tk.Canvas(self.root_frame,width=self.imgSrcDimensions,height=self.imgSrcDimensions)
            self.canvasQuad.place(x=770-140,y=308)
            self.canvasQuad.create_image(0,0, anchor="nw", image=self.imgQuad)
            self.canvasQuad.bind("<Button-1>", self.motion)

            self.createQuadrantMatrix()


    def createQuadrantMatrix(self):

        quad = self.entry_Quad.get()

        array = convert_img_txt(self.arrayImgSrc)

        #print(array)

        result = []

        for r in range(len(array)):
            row = []
            for c in range(len(array)):
                
                #print(array[r][c])

                if(quad == "0"):
                    if (r <= 96 and c <= 96 and r <= 96):
                        row.append(array[r][c])
                elif(quad == "2"):
                    if (c <= 193 and c >= 97 and r <= 96):
                        row.append(array[r][c])
                elif(quad == "3"):
                    if (c <= 290 and c >= 194 and r <= 96):
                        row.append(array[r][c])
                elif(quad == "4"):
                    if (c <= 387 and c >= 291 and r <= 96):
                        row.append(array[r][c])
                elif(quad == "5"):
                    if (c <= 96 and r>= 97 and r <= 193):
                        row.append(array[r][c])
                elif(quad == "6"):
                    if (c <= 193 and c >= 97 and r>= 97 and r <= 193):
                        row.append(array[r][c])
                elif(quad == "7"):
                    if (c <= 290 and c >= 194 and r>= 97 and r <= 193):
                        row.append(array[r][c])
                elif(quad == "8"):
                    if (c <= 387 and c >= 291 and r>= 97 and r <= 193):
                        row.append(array[r][c])    
                elif(quad == "9"):
                    if (c <= 96 and r>= 194 and r <= 290):
                        row.append(array[r][c])
                elif(quad == "10"):
                    if (c <= 193 and c >= 97 and r>= 194 and r <= 290):
                        row.append(array[r][c])
                elif(quad == "11"):
                    if (c <= 290 and c >= 194 and r>= 194 and r <= 290):
                        row.append(array[r][c])
                elif(quad == "12"):
                    if (c <= 387 and c >= 291 and r>= 194 and r <= 290):
                        row.append(array[r][c]) 

                elif(quad == "13"):
                    if (c <= 96 and r>= 291 and r <= 387):
                        row.append(array[r][c])
                elif(quad == "14"):
                    if (c <= 193 and c >= 97 and r>= 291 and r <= 387):
                        row.append(array[r][c])
                elif(quad == "15"):
                    if (c <= 290 and c >= 194 and r>= 291 and r <= 387):
                        row.append(array[r][c])
                elif(quad == "16"):
                    if (c <= 387 and c >= 291 and r>= 291 and r <= 387):
                        row.append(array[r][c]) 
            
            if(len(row)>0):
                result.append(row)
        
        self.arrayImgSelect = result

        print("Se ha generado la matriz que va para assembly")


    def generate_img_file(self):

        file = open("assembly_bilinear_interpolation/img_src.img","w") 
 
        for r in range(len(self.arrayImgSelect)):

            for c in range(len(self.arrayImgSelect[r])):

                num = self.arrayImgSelect[r][c]
                self.arrayAssembly.append (num)

                if (num < 10):
                    num = "00" + str(num)
                elif(num < 100):
                    num = "0" + str(num)
                else:
                    num = str(num)
            
                file.write(num)
                file.write(" ")
        
        file.close() 

        self.arrayAssembly = np.array(self.arrayAssembly)

        print("Se ha generado el archivo img que se utilizara en assembly")

        #self.execute_assembly_bilinear_interpolation()

    def convert_img_array_to_matrix(self, I,row_size):

        array = []
        c = 1

        row = []

        for i in range(len(I)):

            row.append(int(I[i]))
            
            if (c == row_size):
                array.append(row)
                row = []
                c = -1

            c = c + 1

        return array

    def execute_assembly_bilinear_interpolation(self):

        os.system('assembly_bilinear_interpolation/./inter')



    def fun_ejecutar_interpolacion(self):

        self.generate_img_file()

        n = len(self.arrayImgSelect[0])

        print("El tamano de la matriz es: ", str(n))
        
        
        if(self.entry_var.get() != "" and self.loaded and self.quad_selected):

            imgOut = "result.jpg"

            #arrayImgOut = convert_img_txt(self.arrayImgSrc)


            #   Este es el que sirve con algoritmo de python
            arrayImgOut = bilinear_interpolation(self.arrayImgSelect)

            
            #arrayImgOut = execute(self.arrayAssembly,n)

            #arrayImgOut = execute(np.array([10,20,30,40]),30)

            #arrayImgOut = self.convert_img_array_to_matrix(arrayImgOut,30)

            self.imgOutDimensions = len(arrayImgOut)

            print("Size out img: ", self.imgOutDimensions, "x", self.imgOutDimensions)

            drawImage(arrayImgOut)

            arrayImgOut = convert_img_array_rgb(imgOut)

            self.imgOut = ImageTk.PhotoImage(image=Image.fromarray(arrayImgOut))

            

            self.canvasOut = tk.Canvas(self.root_frame,width=self.imgOutDimensions,height=self.imgOutDimensions)
            self.canvasOut.place(x=780+500,y=358)
            self.canvasOut.create_image(0,0, anchor="nw", image=self.imgOut)

            tk.messagebox.showinfo(title="Success", message="The interpolated image has been generated successfully!")

        elif(self.entry_var.get() == ""):
            tk.messagebox.showinfo(title="Error", message="You must enter the name of the image!")
        elif(self.quad_selected == False):
            tk.messagebox.showinfo(title="Error", message="You must select one quadrant in the image!")
        else:

            tk.messagebox.showinfo(title="Error", message="You must first upload an image!")


if __name__ == "__main__":
    interfaz = Interfaz()

    # create_main_window()
