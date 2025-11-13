#  Taller 1 - Fundamentos de la Computación
13-11-2025

Matias Soto Carvajal -  Meylin Leonario Marambio – Pablo Bravo Bascuñán

## Instalacion y pruebas
### Dependencias
Para compilar el analizador lexico es necesario tener la libreria flex instalada

#### Para Ubuntu:
```bash
  sudo apt-get install flex
```
#### Para MacOS:
Es necesario tener Homebrew instalado.
```bash
  brew install flex
```
#### Para Windows:
```bash
  winget install GnuWin32.Flex
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
Generar archivo C.
```bash
  flex CodigoEjecutable.lex
```
Compilar el archivo C a un ejecutable.
```bash
  gcc lex.yy.c -o analizador_sql
```
### Pruebas
Para ejecutar el modo interactivo.
```bash
  ./analizador_sql
```    
Para probar archivos de texto.
```bash
  ./analizador_sql < nombre_archivo.txt
```
