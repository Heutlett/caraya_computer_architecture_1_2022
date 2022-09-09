import numpy as np

def init_matrix(I):

    matrix_out = np.zeros(100)

    last_index = 9
    row_size_out = 10
    col_out = 0

    r14 = 0     # index


    for r11 in I:
        
        matrix_out[r14] = r11

        if (col_out == last_index):

            r14 = r14 + 1 + row_size_out*2
            col_out = 0
        else:
            

            r14 = r14 + 3
            col_out = col_out + 3



    return matrix_out



    



matrix = [10,20,30,40,50,60,70,80,90,100,10,11,1,20,30,40]

Iout = init_matrix(matrix)

print(Iout)