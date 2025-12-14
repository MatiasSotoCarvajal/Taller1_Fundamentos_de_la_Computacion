%{
#include <stdio.h>
#include <string.h>
#include "sql_parser.tab.h"

int line_num = 1;
%}

%option noyywrap
%option case-insensitive

LETTER      [a-zA-Z_]
DIGIT       [0-9]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
DECIMAL     {DIGIT}+\.{DIGIT}+
WHITESPACE  [ \t\r]+
COMMENT     "--".*

%%

{WHITESPACE}    { /* Ignorar espacios en blanco */ }
\n              { line_num++; }
{COMMENT}       { /* Ignorar comentarios */ }

"SELECT"        { return SELECT; }
"INSERT"        { return INSERT; }
"UPDATE"        { return UPDATE; }
"DELETE"        { return DELETE; }
"FROM"          { return FROM; }
"WHERE"         { return WHERE; }
"INTO"          { return INTO; }
"VALUES"        { return VALUES; }
"SET"           { return SET; }
"AND"           { return AND; }
"OR"            { return OR; }
"NOT"           { return NOT; }

"="             { return EQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LE; }
">="            { return GE; }
"!="            { return NE; }

";"             { return SEMICOLON; }
","             { return COMMA; }
"("             { return LPAREN; }
")"             { return RPAREN; }

{IDENTIFIER}    { 
                    yylval.str = strdup(yytext); 
                    return IDENTIFIER; 
                }

{INTEGER}       { 
                    yylval.num = atoi(yytext); 
                    return INTEGER; 
                }

{DECIMAL}       { 
                    yylval.fnum = atof(yytext); 
                    return DECIMAL; 
                }

'[^']*'         { 
                    yylval.str = strndup(yytext+1, strlen(yytext)-2); 
                    return STRING; 
                }

\"[^\"]*\"      { 
                    yylval.str = strndup(yytext+1, strlen(yytext)-2); 
                    return STRING; 
                }

.               { 
                    printf("Error lexico: caracter no reconocido '%s' en linea %d\n", 
                           yytext, line_num); 
                }

%%