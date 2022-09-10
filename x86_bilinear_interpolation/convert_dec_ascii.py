

def convert_dec_to_ascii(num):

    result = ""

    if(num < 10):


        result = str(num)

    elif(num < 100):

        result = result + str(num//10)

        result = result + str(num%10)

    elif(num > 199):

        result = "2"
        num = num - 200

        result = result + str(num//10)

        result = result + str(num%10)

    elif(num > 99):

        result = "1"
        num = num - 100

        result = result + str(num//10)

        result = result + str(num%10)
    

    print(result)

        

for i in range(256):


    convert_dec_to_ascii(i)


