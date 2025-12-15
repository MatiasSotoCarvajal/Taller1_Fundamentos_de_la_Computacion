#  Taller 2 - Fundamentos de la Computación
13-11-2025

Matias Soto Carvajal -  Meylin Leonario Marambio – Pablo Bravo Bascuñán

## Instalacion y pruebas
### Dependencias
Para compilar el analizador lexico es necesario tener la libreria flex y bison instalada

#### Para Ubuntu:
```bash
  sudo apt-get update
  sudo apt-get install flex bison gcc make
```
#### Para MacOS:
Es necesario tener Homebrew instalado.
```bash
    brew install flex bison gcc make
```
#### Para Windows:
```bash
  pacman -S flex bison gcc make
```
### Instalación y compilación
Clona el repositorio.
```bash
  git clone https://github.com/MatiasSotoCarvajal/Taller1_Fundamentos_de_la_Computacion
```
Abre la carpeta contenedora.
```bash
  cd Taller1_Fundamentos_de_la_Computacion
```
Compila el proyecto.
```bash
   make
```
Compilación Manual (Alternativa)
```bash
    bison -d -o sql_parser.tab.c sql_parser.y
     flex sql_lexer.l
      gcc -Wall -g -o sql_analyzer sql_parser.tab.c lex.yy.c main.c
```
### Pruebas
Para ejecutar el modo interactivo.
```bash
    ./sql_analyzer
```    
Para probar archivos de texto.
```bash
    ./sql_analyzer < nombre_archivo.txt
```
