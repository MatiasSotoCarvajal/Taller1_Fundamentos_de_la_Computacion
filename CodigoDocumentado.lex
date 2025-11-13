/*
 * Analizador Léxico para SQL Básico
 * Autores: Matías Soto, Meylin Leonario, Pablo Bravo
 * Curso: Fundamentos de la Computación
 * Profesor: Claudio Meneses | Ayudante: Byron Letelier
 */

%{
#include <stdio.h>
#include <string.h>

int line_num = 1;      // Contador de líneas procesadas
int token_count = 0;   // Contador total de tokens reconocidos
%}

// ================= DEFINICIONES AUXILIARES =================
LETTER      [a-zA-Z_]                    // Letras y guion bajo
DIGIT       [0-9]                        // Dígitos 0-9
WHITESPACE  [ \t\r]                      // Espacios, tabs, retorno de carro
NEWLINE     \n                           // Salto de línea

// ================= DEFINICIONES DE TOKENS =================
KEYWORD     (?i:SELECT|INSERT|WHERE|UPDATE|DELETE|FROM)  // Palabras clave (case-insensitive)
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*                // Nombres de tablas/columnas
INTEGER     {DIGIT}+                                      // Números enteros
DECIMAL     {DIGIT}+\.{DIGIT}+                           // Números decimales
STRING      ('([^'])*'|\"([^\"])*\")                     // Cadenas con comillas simples o dobles
RELATIONAL  (=|<|>|<=|>=)                                // Operadores relacionales
LOGICAL     (?i:AND|OR|NOT)                              // Operadores lógicos (case-insensitive)
DELIMITER   [;,()]                                       // Delimitadores
COMMENT     --.*                                         // Comentarios de línea

%%
// ================= REGLAS DE RECONOCIMIENTO =================

// Palabras clave SQL (debe ir antes que IDENTIFIER)
{KEYWORD}       { 
                    token_count++;
                    printf("<KEYWORD>: %s\n", yytext); 
                }

// Operadores lógicos (debe ir antes que IDENTIFIER)
{LOGICAL}       { 
                    token_count++;
                    printf("<LOGICAL_OP>: %s\n", yytext); 
                }

// Identificadores: nombres de tablas, columnas, etc.
{IDENTIFIER}    { 
                    token_count++;
                    printf("<IDENTIFIER>: %s\n", yytext); 
                }

// Números enteros
{INTEGER}       { 
                    token_count++;
                    printf("<INTEGER>: %s\n", yytext); 
                }

// Números decimales
{DECIMAL}       { 
                    token_count++;
                    printf("<DECIMAL>: %s\n", yytext); 
                }

// Cadenas de texto literales
{STRING}        { 
                    token_count++;
                    printf("<STRING>: %s\n", yytext); 
                }

// Operadores relacionales
{RELATIONAL}    { 
                    token_count++;
                    printf("<RELATIONAL_OP>: %s\n", yytext); 
                }

// Delimitadores
{DELIMITER}     { 
                    token_count++;
                    printf("<DELIMITER>: %s\n", yytext); 
                }

// Comentarios SQL
{COMMENT}       { 
                    token_count++;
                    printf("<COMMENT>: %s\n", yytext); 
                }

// Ignorar espacios en blanco
{WHITESPACE}+   { /* Espacios descartados */ }

// Contar saltos de línea
{NEWLINE}       { line_num++; }

// Manejo de errores: cualquier carácter no reconocido
.               { 
                    printf("ERROR léxico en línea %d: carácter inválido '%s'\n", 
                           line_num, yytext); 
                }

%%
// ================= CÓDIGO DE USUARIO =================

// Función requerida por Flex al finalizar el análisis
int yywrap() {
    return 1;
}

// Función principal: maneja modo archivo e interactivo
int main(int argc, char **argv) {
    printf("==============================================\n");
    printf("  Analizador Léxico SQL - Taller FC\n");
    printf("==============================================\n\n");
    
    if (argc > 1) {
        // Modo archivo: leer desde archivo especificado
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Error: No se puede abrir el archivo '%s'\n", argv[1]);
            return 1;
        }
        printf("Analizando archivo: %s\n\n", argv[1]);
        yyin = file;
        yylex();
        fclose(file);
    } else {
        // Modo interactivo: leer desde teclado
        printf("Modo interactivo (Ctrl+D o Ctrl+Z para terminar)\n");
        printf("Ingrese comandos SQL:\n\n");
        yylex();
    }
    
    printf("\n==============================================\n");
    printf("Análisis completado.\n");
    printf("Total de tokens reconocidos: %d\n", token_count);
    printf("==============================================\n");
    
    return 0;
}