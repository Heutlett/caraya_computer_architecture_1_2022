
# Proyecto 1: Desarrollo de una aplicación para la generación de gráficos y texto


## Autor

Carlos Adrian Araya Ramírez    
adrian.araya@estudiantec.cr

## Requerimientos del sistema

- 2 GB RAM (4 GB preferible)
- x86 64-bit CPU (Intel / AMD architecture)
- 5 GB free disk space
- Sistema operativo: Ubuntu 18.04.06

## Dependencias

- Se requiere el paquete NASM, para instalarlo abra una nueva terminal y ejecute el siguiente comando:

    ``` 
    sudo apt install nasm gdb 
    ```

- Se requiere python3, para instalarlo ejecute el siguiente comando en la terminal:

    ```
    sudo apt install python3
    ```
    Nota: normalmente las distribuciones de linux ya tienen instalado python3 por defecto.

## Instalación

- Dirijase la sección de TAG's en este repositorio y haga clic en el botón *zip* para iniciar la descarga.

![image](https://user-images.githubusercontent.com/44324449/189574602-8e9f7c23-6846-4bf1-b7aa-4120e1294944.png)

- Una vez descargado el proyecto, extraigalo en el directorio que desee y abra una terminal en el subdirectorio: 

  ```
  /caraya_computer_architecture_1_2022/proyecto_1/bilinear_interpolation_app
  ```

- Una vez abierta la terminal ejecute el siguiente comando:

  ```
  python3 interpolation_app.py
  ```
  
- Se abrirá una ventana como la que se muestra a continuación:

  ![image](https://user-images.githubusercontent.com/44324449/189575074-2b58429f-644f-4968-8430-e680f92cad35.png)
  
- Por defecto, en el nombre de la imagen se tiene *imagen.jpg* la cual corresponde a una imagen que puede ser procesada por el programa, pero si desea utilizar una imagen propia solo debe colocarla en el mismo directorio donde ejecutó el comando anterior y asegurarse de que la imagen es de extesión .jpg y dimensiones 390x390.
  
  Nota: no es requerido que la imagen esté en escala de grises pues el algoritmo la procesará igualmente y la convertirá a escala de grises.
  
- Una vez haya ingresado el nombre de la imagen que desea procesar, haga clic en el botón *Load image*. Si ingresó un nombre de imagen correcto se mostrará lo siguiente:

  ![image](https://user-images.githubusercontent.com/44324449/189575604-31f7b791-de41-4504-bf4e-f0f5098ea25f.png)

- Ahora seleccione haga clic en uno de los cuadrantes de la imagen que se muestra en el centro de la ventana y presione el botón de *Execute* y si el proceso fue exitosó se mostrará un resultado como el siguiente:

  ![image](https://user-images.githubusercontent.com/44324449/189575970-18f3eba1-0de9-412c-9e5b-cba70d99078e.png)

- Una vez finalizado el paso anterior, en el mismo directorio donde se encuentra se ha generado una imagen con el nombre *result.jpg* la cual corresponde a la imagen interpolada.  
