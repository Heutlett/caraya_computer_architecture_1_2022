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

    result = round(((c2-i)/(c2-c1))*vc1 + ((i-c1)/(c2-c1))*vc2)

    #print("num(",i,") = ((",c2,"-",i,")/(",c2,"-",c1,"))*",vc1," + ((",i,"-",c1,")/(",c2,"-",c1,"))*",vc2,"=",result)

    return result



#   Calcula los pixeles centrales
#   parametros:     n:      tamano de la fila
#                   index:  indice del primer valor a calcular de la fila
#                   I:      matriz
#                   r:      fila
def middle_pixels(n,index,I,r,m):

    mid = []

    ind = index

    for i in range(n):      # Pixeles verticales
        
        if (i%3==0):        

            c1 = r*n+i+1                # indice conocido 1
            c2 = (r+3)*n+i+1            # indice conocido 2

            vc1 = I[r][i//3]            # valor del conocido1
            vc2 = I[r+1][i//3]          # valor del conocido2

            #print("c1: ",c1)
            #print("c2: ",c2)
            #print("index: ",index)
            #print("vc1: ",vc1)
            #print("vc2: ",vc2)

            #print("\n> Pixeles verticales (c,g,f,j)\n")

            mid.append(calc_interpolation(c1,c2,ind,vc1,vc2)) #c y g
            
            ind = ind +3
        else:
            mid.append(-1)

    for i in range(len(mid)-1):     # Pixeles del centro

        if (i%3==0 & i<len(mid)-1):
            
            c1 = (r+1+m)*n+(i+1)
            vc1 = mid[i]

            c2 = c1 + 3
            vc2 = mid[i+3]

        if(mid[i]==-1):

            ind = index+i

            #print("c1: ",c1)
            #print("c2: ",c2)
            #print("ind: ",ind)
            #print("vc1: ",vc1)
            #print("vc2: ",vc2)

            #print("\n> Pixeles intermedios (d,e,h,i)\n")
            
            mid[i] = calc_interpolation(c1,c2,ind,vc1,vc2)

    return mid

def bilinear_interpolation(I):

    I_out = []                      #   Imagen interpolada
    for r in range(len(I)):
        I_new = []               #   Espacios superiores e inferiores
        for c in range(len(I[r])):   

            I_new.append(I[r][c])

            if(c < len(I[r])-1):
                
                c1 = (c) + 1                # indice conocido 1
                c2 = (c + 3) + 1            # indice conocido 2
                ai = (c + 1) + 1            # indice de a
                bi = (c + 2) + 1            # indice de a
                vc1 = I[r][c]               # valor del conocido1
                vc2 = I[r][c+1]             # valor del conocido2

                #print("c1: ",c1)
                #print("c2: ",c2)
                #print("ai: ",ai)
                #print("vc1: ",vc1)
                #print("vc2: ",vc2)

                #print("\n> Pixeles horizontales (a,b,k,l)\n")

                I_new.append(calc_interpolation(c1,c2,ai,vc1,vc2))      #a
                I_new.append(calc_interpolation(c1,c2,bi,vc1,vc2))      #b
                
        I_out.append(I_new)

        if(r < len(I[r])-1):
            
            n = 4 + (len(I[r])-2)*3

            index1 = (r+1)*n+1
            index2 = (r+2)*n+1
            
            I_out.append(middle_pixels(n,index1,I,r,0))     #c
            I_out.append(middle_pixels(n,index2,I,r,1))     #g

    return I_out

def bilinear_optimized(I, n_src):

    index = 0
    last_index = n_src-1
    print("last_index_src: ", last_index)

    row = 0


    tamano = (last_index*3+1)*(last_index*3+1)    # El final debería ser de 292x292
    print("size of I2_out: ", tamano)
    print()

    I_out2 = np.zeros(tamano)

    for c in range(len(I)):  #   c: corresponde al indice de cada valor conocido de l matriz original

        if(index == last_index):
            pass
        else:
            pass

        if (index == last_index):   # Se encarga de analizar cuando pasar a una siguiente fila
            index = 0
            row = row + 1
        else:
            index = index + 1

    

    return I_out2

# Genera la matriz inicial con el tamano final y los valores conocidos colocados, los no conocidos se ponen -1

def generate_initial_Iout(I, n_src):

    
    last_index_src = n_src-1
    print("last_index_src: ", last_index_src)

    tamano = (last_index_src*3+1)*(last_index_src*3+1)    # El final debería ser de 292x292
    print("size of I2_out: ", tamano)
    print()

    I_out2 = np.zeros(tamano)

    col_out = 0
    row_out = 0
    last_index_out = last_index_src*3

    index_src = 0


    for c in range(len(I_out2)):

        print("Row: ",row_out, " Col: ", col_out)

        if(col_out%3==0 and row_out%3==0):
            I_out2[c] = I[index_src]
            index_src = index_src + 1

        if (col_out == last_index_out):
            col_out = -1
            row_out = row_out +1

        col_out = col_out + 1

        
    return I_out2


        

# Matrices de prueba    

#I = [[10,20],[30,40]]           #   Imagen inicial

# I = [[10,20,30],[40,50,60],[70,80,90]]           #   Imagen inicial

# I = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]           #   Imagen inicial

# I = [[10,20,10,20],[30,40,30,40],[10,20,10,20],[30,40,30,40]]           #   Imagen inicial

# I = [[30,40],[10,20]]           #   Imagen inicial


#I_out = bilinear_interpolation(I)

#I_2 = np.array([10,20,30,40])
#n_src = 2

I_2 = np.array([10,20,10,20,30,40,30,40,10,20,10,20,30,40,10,20])
n_src = 4


nm_src = n_src*n_src

I_out2 = generate_initial_Iout(I_2,n_src)

last_index_src = n_src-1
tamano = last_index_src*3+1

#I_out2 = bilinear_optimized(I_2,n_src)

print("\nI2:")
print(I_2)
print("\nI_out:")
printerArray(I_out2,tamano)