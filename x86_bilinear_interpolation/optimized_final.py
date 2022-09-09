#   Algoritmo de interpolacion bilineal en python 3
#   Implementado por Adrian Araya

import numpy as np

#   Imprime una matriz con formato
def printer(array2d):  

    for row in array2d:
        for col in row:
            print(col, "\t\t", sep="", end="")

        print()

def printerArray(array2d,n):

    print("Matriz de tamano: ", n,"x",n)

    counter = 1

    for c in range(len(array2d)):
        
        print(array2d[c],end="\t")

        if(counter == n):
            counter = 0
            print()

        counter = counter + 1

    print()


#   Calcula el valor de pixel de interpolacion
#   Parametros:     c1:     indice conocido1
#                   c2:     indice conocido2
#                   i:      indice numero a calcular
#                   vc1:    valor del conocido1
#                   vc2:    valor del conocido2
def calc_interpolation(c1,c2,i,vc1,vc2):   

    izq = ((c2-i)/(c2-c1))*vc1
    der = ((i-c1)/(c2-c1))*vc2
    r = izq + der

    # print("i: ",i)
    # print("c1: ",c1)
    # print("vc1: ",vc1)
    # print("c2: ",c2)
    # print("vc2: ",vc2)  
    # print()

    # print("izq = ", izq)
    # print("der = ", der)
    # print("r = ", r)
    # print()
    # print("---------------")

    result = round(r)

    #print("num(",i,") = ((",c2,"-",i,")/(",c2,"-",c1,"))*",vc1," + ((",i,"-",c1,")/(",c2,"-",c1,"))*",vc2,"=",result)

    return result



# Genera la matriz inicial con el tamano final y los valores conocidos colocados, los no conocidos se ponen -1

def fill_null_values(I):

    I2 = I

    for i in range(len(I2)):
        I2[i] = -1

    return I2

def generate_initial_Iout(I, n_src):

    
    last_index_src = n_src-1
    #print("last_index_src: ", last_index_src)

    tamano = (last_index_src*3+1)*(last_index_src*3+1)    # El final debería ser de 292x292
    #print("size of I2_out: ", tamano)

    I_out2 = np.zeros(tamano)
    I_out2 = fill_null_values(I_out2)

    col_out = 0
    row_out = 0
    last_index_out = last_index_src*3

    index_src = 0


    for c in range(len(I_out2)):

        #print("Row: ",row_out, " Col: ", col_out)

        if(col_out%3==0 and row_out%3==0):
            I_out2[c] = I[index_src]
            index_src = index_src + 1

        if (col_out == last_index_out):
            col_out = -1
            row_out = row_out +1

        col_out = col_out + 1

        
    return I_out2


def vertical_optimized_calc(I,row_size_out):

    last_index = row_size_out-1

    I_out2 = I

    col_out = 0
    row_out = 0

    index = 1

    vertical_known_counter_c1 = 0
    vertical_known_counter_c2 = 3


    for c in range(len(I_out2)-1):

        
        
        if(col_out%3==0 and row_out%3==0):

            # Variables para horizontales

            c1 = index 
            vc1 = I_out2[c1-1]
            c2 = index + 3
            vc2 = I_out2[c2-1]

            # print("---------------")

            # print("c1: ", c1)
            # print("c2: ", c2)
            # print("vc1: ", vc1)
            # print("vc2: ", vc2)
            
        
        if(col_out%3==0 and row_out%3!=0): # Valores verticales

            # print("row_size_out: ", row_size_out)
            # print("col: ", col_out)
            # print("row: ", row_out)
            # print("index: ", index)
            # print("vertical_known_counter_c1: ", vertical_known_counter_c1)
            # print("vertical_known_counter_c2: ", vertical_known_counter_c2)
            # print("row_size_out: ",row_size_out )

            c1 = (col_out + 1) + vertical_known_counter_c1*row_size_out
            vc1 = I_out2[c1-1]
            
            c2 = (col_out + 1) + vertical_known_counter_c2*row_size_out
            vc2 = I_out2[c2-1]
            
            # print()
            # print("c1: ", c1)
            # print("c2: ", c2)
            # print("vc1: ", vc1)
            # print("vc2: ", vc2)
            # print("---------------------------")

            if(I_out2[c] == -1.0):
                
                I_out2[c] = calc_interpolation(c1,c2,index,vc1,vc2)
                #print("Row: ",row_out, " Col: ", col_out)
        

        # if(col_out%3!=0 and row_out%3==0):  # Valores horizontales
            

        #     if(I_out2[c] == -1.0):
                
        #         I_out2[c] = calc_interpolation(c1,c2,index,vc1,vc2)
        #         #print("Row: ",row_out, " Col: ", col_out)


        if (col_out == last_index):
            col_out = -1
            row_out = row_out +1
            
            if (row_out % 3 == 0):
                vertical_known_counter_c1 = vertical_known_counter_c1 +3
                vertical_known_counter_c2 = vertical_known_counter_c2 +3

        index = index + 1

        col_out = col_out + 1

        
    return I_out2



def horizontal_optimized_calc(I,row_size_out):

    print("CALCULO HORIZONTAL")
    printerArray(I,4)

    last_index = row_size_out-1

    I_out2 = I

    col_out = 0
    row_out = 0

    index = 1


    for c in range(len(I_out2)-1):

        
        if(col_out%3==0):

            # Variables para horizontales

            c1 = index 
            vc1 = I_out2[c1-1]
            c2 = index + 3
            vc2 = I_out2[c2-1]

            # print("---------------")
            # print("Row: ",row_out, " Col: ", col_out)
            # print("index: ",index)
            # print("c1: ", c1)
            # print("c2: ", c2)
            # print("vc1: ", vc1)
            # print("vc2: ", vc2)
            

        if(col_out%3!=0):  # Valores horizontales
            

            if(I_out2[c] == -1.0):
                
                I_out2[c] = calc_interpolation(c1,c2,index,vc1,vc2)
                print("Row: ",row_out, " Col: ", col_out)


        if (col_out == last_index):
            col_out = -1
            row_out = row_out +1
            

        index = index + 1

        col_out = col_out + 1

        
    return I_out2

def interpolation_optimized(I, n_src):

    # %assign FILE_SIZE               35
    # %assign MATRIX_SRC_SIZE         9
    # %assign MATRIX_OUT_SIZE         49
    # %assign ROW_SIZE_SRC            4
    # %assign ROW_SIZE_OUT            10
    # %assign LAST_INDEX_OUT          9

    row_size_out = (n_src-1)*3+1

    array_size_src = n_src*n_src
    array_size_out = row_size_out*row_size_out

    print("MATRIX_SRC_SIZE = ", array_size_src)

    print("MATRIX_OUT_SIZE = ", array_size_out)

    print("ROW_SIZE_SRC = ", n_src)

    print("ROW_SIZE_OUT = ", row_size_out)

    last_index = row_size_out-1
    
    print("LAST_INDEX_OUT: ", last_index)
    
    print()

    I_out2 = vertical_optimized_calc(I, row_size_out)
    I_out2 = horizontal_optimized_calc(I_out2, row_size_out)
        
    return I_out2


    #   Calcula el valor de pixel de interpolacion
#   Parametros:     c1:     indice conocido1
#                   c2:     indice conocido2
#                   i:      indice numero a calcular
#                   vc1:    valor del conocido1
#                   vc2:    valor del conocido2
# def calc_interpolation(c1,c2,i,vc1,vc2):   

#     result = round(((c2-i)/(c2-c1))*vc1 + ((i-c1)/(c2-c1))*vc2)

#     #print("num(",i,") = ((",c2,"-",i,")/(",c2,"-",c1,"))*",vc1," + ((",i,"-",c1,")/(",c2,"-",c1,"))*",vc2,"=",result)

#     return result


# def test_algorithm():

#     I = [[10,20,30,40],[30,40,50,60],[50,60,70,80], [70,80,90,0]]           #   Imagen inicial


#     I_out = interpolation_optimized(I)

#     I_test = [[10,13,17,20,23,27,30,33,37,40],
#             [17,20,24,27,30,34,37,40,44,47],
#             [23,26,30,33,36,40,43,46,50,53],
#             [30,33,37,40,43,47,50,53,57,60],
#             [37,40,44,47,50,54,57,60,64,67],
#             [43,46,50,53,56,60,63,66,70,73],
#             [50,53,57,60,63,67,70,73,77,80],
#             [57,60,64,67,70,74,77,69,61,53],
#             [63,66,70,73,76,80,83,64,46,27],
#             [70,73,77,80,83,87,90,60,30,0]]

#     if (I_test == I_out):

#         print("EXITO:   El algoritmo funciona correctamente")

#     else: 
        
#         print("ERROR:   El algoritmo tiene errores")

        

# Matrices de prueba    

#I = [[10,20],[30,40]]           #   Imagen inicial

# I = [[10,20,30],[40,50,60],[70,80,90]]           #   Imagen inicial

# I = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]           #   Imagen inicial

# I = [[10,20,10,20],[30,40,30,40],[10,20,10,20],[30,40,30,40]]           #   Imagen inicial

# I = [[30,40],[10,20]]           #   Imagen inicial


#I_out = bilinear_interpolation(I)



I_2 = np.array([10,20,30,40])
n_src = 2                           # Esto se lo voy a pasar al compilador yo mismo como argumento de linea de comandos

#I_2 = np.array([10,20,30,40,30,40,50,60,50])
#n_src = 3

#I_2 = np.array([10,20,30,40,30,40,50,60,50,60,70,80,70,80,90,0])
#n_src = 4

I_out2 = generate_initial_Iout(I_2,n_src)

row_size_src = n_src-1
row_size_out = row_size_src*3+1


I_out2 = interpolation_optimized(I_out2,n_src)

print("\nI2:")
printerArray(I_2,n_src)
print("\nI_out:")
printerArray(I_out2,row_size_out)

#test_algorithm()