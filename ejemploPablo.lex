%{
#include <stdio.h>
#include <string.h>

int line_num = 1;
int token_count = 0;
%}

/* Definiciones auxiliares */
LETTER      [a-zA-Z_]
DIGIT       [0-9]
WHITESPACE  [ \t\r]
NEWLINE     \n

/* Definiciones de tokens */
KEYWORD     (?i:SELECT|INSERT|WHERE|UPDATE|DELETE|FROM)
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
DECIMAL     {DIGIT}+\.{DIGIT}+
STRING      ('([^'])*'|\"([^\"])*\")
RELATIONAL  (=|<|>|<=|>=)
LOGICAL     (?i:AND|OR|NOT)
DELIMITER   [;,()]
COMMENT     --.*

%%

{KEYWORD}       { 
                    token_count++;
                    printf("<KEYWORD>: %s\n", yytext); 
                }

{LOGICAL}       { 
                    token_count++;
                    printf("<LOGICAL_OP>: %s\n", yytext); 
                }

{IDENTIFIER}    { 
                    token_count++;
                    printf("<IDENTIFIER>: %s\n", yytext); 
                }

{INTEGER}       { 
                    token_count++;
                    printf("<INTEGER>: %s\n", yytext); 
                }

{DECIMAL}       { 
                    token_count++;
                    printf("<DECIMAL>: %s\n", yytext); 
                }

{STRING}        { 
                    token_count++;
                    printf("<STRING>: %s\n", yytext); 
                }

{RELATIONAL}    { 
                    token_count++;
                    printf("<RELATIONAL_OP>: %s\n", yytext); 
                }

{DELIMITER}     { 
                    token_count++;
                    printf("<DELIMITER>: %s\n", yytext); 
                }

{COMMENT}       { 
                    token_count++;
                    printf("<COMMENT>: %s\n", yytext); 
                }

{WHITESPACE}+   { /* Ignorar espacios en blanco */ }

{NEWLINE}       { line_num++; }

.               { 
                    printf("ERROR léxico en línea %d: carácter inválido '%s'\n", 
                           line_num, yytext); 
                }

%%

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    printf("==============================================\n");
    printf("  Analizador Léxico SQL - Taller FC\n");
    printf("==============================================\n\n");
    
    if (argc > 1) {
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
        printf("Modo interactivo (Control + C, Ctrl+D o Ctrl+Z para terminar)\n");
        printf("Ingrese comandos SQL:\n\n");
        yylex();
    }
    
    printf("\n==============================================\n");
    printf("Análisis completado.\n");
    printf("Total de tokens reconocidos: %d\n", token_count);
    printf("==============================================\n");
    
    return 0;
}
