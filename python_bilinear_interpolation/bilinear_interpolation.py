#   Algoritmo de interpolacion bilineal en python 3
#   Implementado por Adrian Araya

#   Imprime una matriz con formato
def printer(array2d):  

    for row in array2d:
        for col in row:
            print(col, "\t\t", sep="", end="")

        print()


def zeros_array(n):

    a = []

    for i in range(n):
        a.append(0)

    return a


#I = [[10,20],[30,40]]           #   Imagen inicial

#I = [[10,20,50],[30,40,60],[30,40,60]]           #   Imagen inicial

I = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]           #   Imagen inicial

I_out = []                      #   Imagen interpolada
for r in range(len(I)):
    I_new = []               #   Espacios superiores e inferiores
    for c in range(len(I[r])):   

        I_new.append(I[r][c])

        if(c < len(I[r])-1):

            I_new.append(0)
            I_new.append(0)
            
    I_out.append(I_new)

    if(r < len(I[r])-1):
        
        n = 4 + (len(I[r])-2)*3

        I_out.append(zeros_array(n))
        I_out.append(zeros_array(n))

print("I:")
printer(I)
print("\nI_out:")
printer(I_out)