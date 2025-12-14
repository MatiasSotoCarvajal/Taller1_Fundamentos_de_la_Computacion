#include <stdio.h>
#include <stdlib.h>

extern int yyparse();
extern FILE *yyin;

int main(int argc, char *argv[]) {
    
    printf("============================================\n");
    printf("   ANALIZADOR SINTACTICO Y SEMANTICO SQL\n");
    printf("============================================\n");
    printf("Taller II - Fundamentos de la Computacion\n");
    printf("Tablas disponibles:\n");
    printf("  - alumnos (nombre, edad, promedio, carrera)\n");
    printf("  - profesores (nombre, departamento, salario, antiguedad)\n");
    printf("  - cursos (codigo, nombre, creditos, semestre)\n");
    printf("============================================\n\n");

    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            perror("Error al abrir el archivo");
            return 1;
        }
        yyin = archivo;
        printf("--- Analizando archivo: %s ---\n", argv[1]);
    }
    else {
        yyin = stdin;
        printf("       MODO INTERACTIVO ACTIVADO\n");
        printf("============================================\n");
        printf("1. Escribe tus sentencias SQL (ej: SELECT nombre FROM alumnos;)\n");
        printf("2. Presiona ENTER para procesar cada linea.\n");
        printf("3. Para SALIR presiona Ctrl+D (Linux/Mac) o Ctrl+Z (Windows)\n");
        printf("============================================\n\n");
        printf(">> ");
    }

    int parse_result = yyparse();
    
    if (parse_result == 0) {
        printf("\n--- Analisis completado exitosamente ---\n");
    } else {
        printf("\n--- El analisis termino con errores ---\n");
    }

    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}