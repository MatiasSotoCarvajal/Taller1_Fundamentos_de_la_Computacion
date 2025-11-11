%{
    // Seccion de definiciones.
    #include <stdio.h>
%}

%%
// Seccion de reglas.
(?i:SELECT)    { printf("Palabra reservada: SELECT\n"); }
(?i:INSERT)    { printf("Palabra reservada: INSERT\n"); }
(?i:WHERE)     { printf("Palabra reservada: WHERE\n"); }
(?i:UPDATE)    { printf("Palabra reservada: UPDATE\n"); }
(?i:DELETE)    { printf("Palabra reservada: DELETE\n"); }
(?i:FROM)      { printf("Palabra reservada: FROM\n"); }

{IDENTIFIER}   { printf("<IDENTIFIER>: %s\n", yytext); }
[ \t\n]+      { /* Ignorar espacios en blanco */ }
.             { printf("Caracter no reconocido: %s\n", yytext); }
%%

// Codigo en C para la funcion main.
int main(int argc, char **argv) {
    yylex();
    return 0;
}
%%