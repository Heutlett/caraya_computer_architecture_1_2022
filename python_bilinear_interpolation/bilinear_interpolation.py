#   Algoritmo de interpolacion bilineal en python 3
#   Implementado por Adrian Araya

#   Imprime una matriz con formato
def printer(array2d):  

    for row in array2d:
        for col in row:
            print(col, "\t\t", sep="", end="")

        print()

#   Calcula el valor de pixel de interpolacion
#   Parametros:     c1:     indice conocido1
#                   c2:     indice conocido2
#                   i:      indice numero a calcular
#                   vc1:    valor del conocido1
#                   vc2:    valor del conocido2
def calc_interpolation(c1,c2,i,vc1,vc2):   

    return round(((c2-i)/(c2-c1))*vc1 + ((i-c1)/(c2-c1))*vc2)



#   Calcula los pixeles centrales
#   parametros:     n:      tamano de la fila
#                   index:  indice del valor a calcular
#                   I:      matriz
#                   r:      fila
def middle_pixels(n,index,I,r):

    mid = []

    for i in range(n):
        
        if (i%3==0):        # Pixeles verticales

            c1 = r*n+i+1                # indice conocido 1
            c2 = (r+3)*n+i+1            # indice conocido 2

            vc1 = I[r][i//3]            # valor del conocido1
            vc2 = I[r+1][i//3]          # valor del conocido2

            #print("c1: ",c1)
            #print("c2: ",c2)
            #print("index: ",index)
            #print("vc1: ",vc1)
            #print("vc2: ",vc2)

            mid.append(calc_interpolation(c1,c2,index,vc1,vc2)) #c y g
            
            index = index +3
        else:
            mid.append(0)


    return mid


#   Matrices de prueba    

#I = [[10,20],[30,40]]           #   Imagen inicial

#I = [[10,20,30],[40,50,60],[70,80,90]]           #   Imagen inicial

#I = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]           #   Imagen inicial

#I = [[10,20,10,20],[30,40,30,40],[10,20,10,20],[30,40,30,40]]           #   Imagen inicial

I = [[30,40],[10,20]]           #   Imagen inicial

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

            I_new.append(calc_interpolation(c1,c2,ai,vc1,vc2))      #a
            I_new.append(calc_interpolation(c1,c2,bi,vc1,vc2))      #b
            
    I_out.append(I_new)

    if(r < len(I[r])-1):
        
        n = 4 + (len(I[r])-2)*3

        index1 = (r+1)*n+1
        index2 = (r+2)*n+1

        
        print("index1:")
        print(index1)
        I_out.append(middle_pixels(n,index1,I,r))     #c
        print("index2:")
        print(index2)
        I_out.append(middle_pixels(n,index2,I,r))     #g

print("I:")
printer(I)
print("\nI_out:")
printer(I_out)