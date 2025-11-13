/*
 * Analizador Léxico para SQL Básico
 * 
 * Autores: Matías Soto, Meylin Leonario, Pablo Bravo
 * Curso: Fundamentos de la Computación
 * Profesor: Claudio Meneses
 * Ayudante: Byron Letelier
 * 
 * Descripción:
 * Este analizador léxico reconoce tokens básicos de comandos SQL,
 * incluyendo palabras clave, identificadores, literales numéricos,
 * cadenas de texto, operadores y comentarios.
 */

%{
/* 
 * SECCIÓN 1: DEFINICIONES EN C
 * 
 * Esta sección contiene código C que será incluido directamente
 * en el archivo generado lex.yy.c
 */

#include <stdio.h>   // Para printf, fprintf, FILE
#include <string.h>  // Para funciones de manipulación de strings

/* Variables globales para estadísticas */
int line_num = 1;      // Contador de líneas procesadas (comienza en 1)
int token_count = 0;   // Contador total de tokens reconocidos
%}

/* 
 * DEFINICIONES AUXILIARES
 * 
 *
 * Se usan como bloques de construcción para tokens.
 */

/* LETTER: Letras (a-z, A-Z) o guion bajo (_)
 * Usado para definir el inicio de identificadores */
LETTER      [a-zA-Z_]

/* DIGIT: Dígitos numéricos (0-9)
 * Usado para números enteros y decimales */
DIGIT       [0-9]

/* WHITESPACE: Espacios en blanco (espacio, tab, retorno de carro)
 * No incluye salto de línea para poder contarlas por separado */
WHITESPACE  [ \t\r]

/* NEWLINE: Salto de línea
 * Se maneja separadamente para incrementar el contador de líneas */
NEWLINE     \n

/* 
 * DEFINICIONES DE TOKENS
 * 
 * Estas expresiones regulares definen los patrones que el
 * analizador debe reconocer como tokens válidos.
 */

/* KEYWORD: Palabras clave de SQL
 * (?i:...) hace que sea insensible a mayúsculas/minúsculas
 */
KEYWORD     (?i:SELECT|INSERT|WHERE|UPDATE|DELETE|FROM)

/* IDENTIFIER: Identificadores (nombres de tablas, columnas)
 * - Debe comenzar con letra o guion bajo: {LETTER}
 * - Seguido de cero o más letras, dígitos o guiones bajos: ({LETTER}|{DIGIT}|_)*
 */
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*

/* INTEGER: Números enteros
 * Uno o más dígitos: {DIGIT}+
 */
INTEGER     {DIGIT}+

/* DECIMAL: Números decimales
 * Formato: dígitos + punto + dígitos
 */
DECIMAL     {DIGIT}+\.{DIGIT}+

/* STRING: Cadenas de texto literales
 * Soporta dos formatos:
 * 1. Comillas simples: '([^'])*'
 *    - ' = comienza con comilla simple
 *    - ([^'])* = cero o más caracteres que no sean comilla simple
 *    - ' = termina con comilla simple
 * 2. Comillas dobles: \"([^\"])*\"
 *    - \" = comienza con comilla doble (escapada con \)
 *    - ([^\"])* = cero o más caracteres que no sean comilla doble
 *    - \" = termina con comilla doble (escapada con \)
 */
STRING      ('([^'])*'|\"([^\"])*\")

/* RELATIONAL: Operadores relacionales
 * Usados para comparaciones en cláusulas WHERE
 * Incluye: =, <, >, <=, >=
 * NOTA: <= y >= deben ir antes que < y > para coincidir correctamente */
RELATIONAL  (=|<|>|<=|>=)

/* LOGICAL: Operadores lógicos
 * (?i:...) hace que sea insensible a mayúsculas/minúsculas
 * Incluye: AND, OR, NOT */
LOGICAL     (?i:AND|OR|NOT)

/* DELIMITER: Delimitadores
 * Caracteres especiales que separan elementos:
 * ; = fin de sentencia
 * , = separador de elementos en listas
 * ( ) = paréntesis para agrupación */
DELIMITER   [;,()]

/* COMMENT: Comentarios de línea
 * -- = inicio del comentario
 * .* = cualquier carácter hasta el final de la línea */
COMMENT     --.*

%%
/*
 * SECCIÓN 2: REGLAS DE RECONOCIMIENTO
 * 
 * Esta sección define qué hacer cuando se reconoce cada patrón.
 * La variable yytext contiene el texto reconocido.
 */

/* Regla 1: Reconocer palabras clave SQL
 * 
 */
{KEYWORD}       { 
                    token_count++;                        // Incrementar contador
                    printf("<KEYWORD>: %s\n", yytext);    // Imprimir token
                }

/* Regla 2: Reconocer operadores lógicos
 */
{LOGICAL}       { 
                    token_count++;
                    printf("<LOGICAL_OP>: %s\n", yytext); 
                }

/* Regla 3: Reconocer identificadores
 * Nombres de tablas, columnas, alias, etc. */
{IDENTIFIER}    { 
                    token_count++;
                    printf("<IDENTIFIER>: %s\n", yytext); 
                }

/* Regla 4: Reconocer números enteros */
{INTEGER}       { 
                    token_count++;
                    printf("<INTEGER>: %s\n", yytext); 
                }

/* Regla 5: Reconocer números decimales
 * 
 */
{DECIMAL}       { 
                    token_count++;
                    printf("<DECIMAL>: %s\n", yytext); 
                }

/* Regla 6: Reconocer cadenas de texto literales */
{STRING}        { 
                    token_count++;
                    printf("<STRING>: %s\n", yytext); 
                }

/* Regla 7: Reconocer operadores relacionales */
{RELATIONAL}    { 
                    token_count++;
                    printf("<RELATIONAL_OP>: %s\n", yytext); 
                }

/* Regla 8: Reconocer delimitadores */
{DELIMITER}     { 
                    token_count++;
                    printf("<DELIMITER>: %s\n", yytext); 
                }

/* Regla 9: Reconocer comentarios */
{COMMENT}       { 
                    token_count++;
                    printf("<COMMENT>: %s\n", yytext); 
                }

/* Regla 10: Ignorar espacios en blanco
 * El + indica uno o más espacios consecutivos
 * No se imprime nada, simplemente se descartan */
{WHITESPACE}+   { /* Ignorar espacios en blanco */ }

/* Regla 11: Contar saltos de línea
 * Incrementa el contador de líneas pero no genera token */
{NEWLINE}       { line_num++; }

/* Regla 12: Manejo de errores léxicos
 * El punto (.) coincide con cualquier carácter no reconocido
 * Esta regla debe ir al final para capturar todo lo que no
 * coincidió con ninguna regla anterior */
.               { 
                    printf("ERROR léxico en línea %d: carácter inválido '%s'\n", 
                           line_num, yytext); 
                }

%%
/* 
 * SECCIÓN 3: CÓDIGO DE USUARIO
 * 
 * Esta sección contiene funciones auxiliares y la función main
 */

/**
 * yywrap()
 * 
 * Función requerida por Flex que se llama cuando se alcanza
 * el final del archivo de entrada.
 * 
 * Retorno:
 *   - 1: Indica que no hay más archivos para procesar
 *   - 0: Indicaría que hay otro archivo (no usado aquí)
 */
int yywrap() {
    return 1;
}

/**
 * main()
 * 
 * Función principal del programa. Maneja dos modos de operación:
 * 1. Modo archivo: Si se proporciona un argumento (nombre de archivo)
 * 2. Modo interactivo: Si no se proporciona argumento
 * 
 * Parámetros:
 *   argc - Número de argumentos de línea de comandos
 *   argv - Array de strings con los argumentos
 * 
 * Retorno:
 *   0 - Ejecución exitosa
 *   1 - Error al abrir archivo
 */
int main(int argc, char **argv) {
    // Imprimir encabezado
    printf("==============================================\n");
    printf("  Analizador Léxico SQL - Taller FC\n");
    printf("==============================================\n\n");
    
    // Verificar si se proporcionó un archivo como argumento
    if (argc > 1) {
        // MODO ARCHIVO: Leer desde archivo especificado
        FILE *file = fopen(argv[1], "r");  // Abrir archivo en modo lectura
        
        // Validar que el archivo se abrió correctamente
        if (!file) {
            fprintf(stderr, "Error: No se puede abrir el archivo '%s'\n", argv[1]);
            return 1;  // Salir con código de error
        }
        
        printf("Analizando archivo: %s\n\n", argv[1]);
        yyin = file;  // Redirigir entrada de Flex al archivo
        yylex();      // Iniciar análisis léxico
        fclose(file); // Cerrar archivo al terminar
        
    } else {
        // MODO INTERACTIVO: Leer desde stdin (teclado)
        printf("Modo interactivo (Ctrl+D o Ctrl+Z para terminar)\n");
        printf("Ingrese comandos SQL:\n\n");
        yylex();  // Iniciar análisis léxico desde entrada estándar
    }
    
    // Imprimir resumen de resultados
    printf("\n==============================================\n");
    printf("Análisis completado.\n");
    printf("Total de tokens reconocidos: %d\n", token_count);
    printf("==============================================\n");
    
    return 0;  // Salida exitosa
}