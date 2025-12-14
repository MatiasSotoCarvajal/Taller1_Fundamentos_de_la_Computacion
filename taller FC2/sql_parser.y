%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Estructura para el árbol sintáctico */
typedef struct Node {
    char *label;
    char *value;
    struct Node **children;
    int num_children;
} Node;

Node* createNode(char *label, char *value);
void addChild(Node *parent, Node *child);
void printAST(Node *node, int level, char *side);
void freeAST(Node *node);

/* Tablas y columnas predefinidas para análisis semántico */
typedef struct {
    char *table_name;
    char **columns;
    int num_columns;
} TableDef;

TableDef tables[] = {
    {"alumnos", (char*[]){"nombre", "edad", "promedio", "carrera"}, 4},
    {"profesores", (char*[]){"nombre", "departamento", "salario", "antiguedad"}, 4},
    {"cursos", (char*[]){"codigo", "nombre", "creditos", "semestre"}, 4}
};
int num_tables = 3;

int validateColumn(char *table, char *column);
void validateAllColumns(Node *columns_node, char *table);
Node *root = NULL;
char *current_table = NULL;

int yylex();
void yyerror(const char *s);
extern int line_num;
extern FILE *yyin;
%}

%union {
    int num;
    double fnum;
    char *str;
    struct Node *node;
}

%token SELECT INSERT UPDATE DELETE FROM WHERE INTO VALUES SET
%token AND OR NOT
%token EQ LT GT LE GE NE
%token SEMICOLON COMMA LPAREN RPAREN
%token <str> IDENTIFIER STRING
%token <num> INTEGER
%token <fnum> DECIMAL

%type <node> statement select_stmt insert_stmt update_stmt delete_stmt
%type <node> column_list column_item table_name where_clause condition
%type <node> value_list value expression

%%

program:
    /* vacío */
    | program statement {
        if ($2 != NULL) {
            root = $2;
            printf("\n=== VISUALIZACION AST ===\n");
            printAST(root, 0, "RAIZ");
            printf("=========================\n");
            printf(">> ");
            freeAST(root);
            root = NULL;
            current_table = NULL;
        }
    }
    | program error SEMICOLON { 
        yyerrok; 
        printf(">> "); 
        current_table = NULL;
    }
    ;

statement:
    select_stmt SEMICOLON { $$ = $1; }
    | insert_stmt SEMICOLON { $$ = $1; }
    | update_stmt SEMICOLON { $$ = $1; }
    | delete_stmt SEMICOLON { $$ = $1; }
    ;

select_stmt:
    SELECT column_list FROM table_name {
        current_table = $4->value;
        validateAllColumns($2, current_table);
        $$ = createNode("SELECT", NULL);
        addChild($$, $2);
        addChild($$, $4);
    }
    | SELECT column_list FROM table_name WHERE where_clause {
        current_table = $4->value;
        validateAllColumns($2, current_table);
        $$ = createNode("SELECT", NULL);
        addChild($$, $2);
        addChild($$, $4);
        addChild($$, $6);
    }
    ;

insert_stmt:
    INSERT INTO table_name VALUES LPAREN value_list RPAREN {
        current_table = $3->value;
        $$ = createNode("INSERT", NULL);
        addChild($$, $3);
        addChild($$, $6);
    }
    | INSERT INTO table_name LPAREN column_list RPAREN VALUES LPAREN value_list RPAREN {
        current_table = $3->value;
        validateAllColumns($5, current_table);
        $$ = createNode("INSERT", NULL);
        addChild($$, $3);
        addChild($$, $5);
        addChild($$, $9);
    }
    ;

update_stmt:
    UPDATE table_name SET column_item EQ value {
        current_table = $2->value;
        if (!validateColumn(current_table, $4->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $4->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("UPDATE", NULL);
        addChild($$, $2);
        Node *set_node = createNode("SET", NULL);
        addChild(set_node, $4);
        addChild(set_node, $6);
        addChild($$, set_node);
    }
    | UPDATE table_name SET column_item EQ value WHERE where_clause {
        current_table = $2->value;
        if (!validateColumn(current_table, $4->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $4->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("UPDATE", NULL);
        addChild($$, $2);
        Node *set_node = createNode("SET", NULL);
        addChild(set_node, $4);
        addChild(set_node, $6);
        addChild($$, set_node);
        addChild($$, $8);
    }
    ;

delete_stmt:
    DELETE FROM table_name {
        current_table = $3->value;
        $$ = createNode("DELETE", NULL);
        addChild($$, $3);
    }
    | DELETE FROM table_name WHERE where_clause {
        current_table = $3->value;
        $$ = createNode("DELETE", NULL);
        addChild($$, $3);
        addChild($$, $5);
    }
    ;

table_name:
    IDENTIFIER {
        $$ = createNode("TABLE", $1);
    }
    ;

column_list:
    column_item {
        $$ = createNode("COLUMNS", NULL);
        addChild($$, $1);
    }
    | column_list COMMA column_item {
        addChild($1, $3);
        $$ = $1;
    }
    ;

column_item:
    IDENTIFIER {
        $$ = createNode("COLUMN", $1);
    }
    ;

where_clause:
    condition { 
        $$ = createNode("WHERE", NULL); 
        addChild($$, $1); 
    }
    | where_clause AND condition {
        Node *and_node = createNode("AND", NULL);
        addChild(and_node, $1->children[0]);
        addChild(and_node, $3);
        $1->children[0] = and_node;
        $$ = $1;
    }
    | where_clause OR condition {
        Node *or_node = createNode("OR", NULL);
        addChild(or_node, $1->children[0]);
        addChild(or_node, $3);
        $1->children[0] = or_node;
        $$ = $1;
    }
    ;

condition:
    column_item EQ value {
        if (current_table && !validateColumn(current_table, $1->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $1->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("CONDITION", "=");
        addChild($$, $1);
        addChild($$, $3);
    }
    | column_item LT value {
        if (current_table && !validateColumn(current_table, $1->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $1->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("CONDITION", "<");
        addChild($$, $1);
        addChild($$, $3);
    }
    | column_item GT value {
        if (current_table && !validateColumn(current_table, $1->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $1->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("CONDITION", ">");
        addChild($$, $1);
        addChild($$, $3);
    }
    | column_item LE value {
        if (current_table && !validateColumn(current_table, $1->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $1->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("CONDITION", "<=");
        addChild($$, $1);
        addChild($$, $3);
    }
    | column_item GE value {
        if (current_table && !validateColumn(current_table, $1->value)) {
            char error[256];
            snprintf(error, sizeof(error), 
                    "Error semantico: columna '%s' no existe en tabla '%s'", 
                    $1->value, current_table);
            yyerror(error);
            YYERROR;
        }
        $$ = createNode("CONDITION", ">=");
        addChild($$, $1);
        addChild($$, $3);
    }
    ;

value_list:
    value {
        $$ = createNode("VALUES", NULL);
        addChild($$, $1);
    }
    | value_list COMMA value {
        addChild($1, $3);
        $$ = $1;
    }
    ;

value:
    INTEGER {
        char buf[32];
        snprintf(buf, sizeof(buf), "%d", $1);
        $$ = createNode("VALUE", buf);
    }
    | DECIMAL {
        char buf[32];
        snprintf(buf, sizeof(buf), "%.2f", $1);
        $$ = createNode("VALUE", buf);
    }
    | STRING {
        $$ = createNode("VALUE", $1);
    }
    ;

expression:
    value { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error en linea %d: %s\n", line_num, s);
}

Node* createNode(char *label, char *value) {
    Node *node = (Node*)malloc(sizeof(Node));
    node->label = strdup(label);
    node->value = value ? strdup(value) : NULL;
    node->children = NULL;
    node->num_children = 0;
    return node;
}

void addChild(Node *parent, Node *child) {
    parent->num_children++;
    parent->children = (Node**)realloc(parent->children, 
                                       parent->num_children * sizeof(Node*));
    parent->children[parent->num_children - 1] = child;
}

void printAST(Node *node, int level, char *side) {
    if (node == NULL) return;
    
    for (int i = 0; i < level; i++) {
        printf("    ");
    }
    
    if (level == 0) {
        printf("RAIZ -> ");
    } else {
        printf("|--(%s)-- ", side);
    }
    
    printf("[%s", node->label);
    if (node->value) {
        printf(": %s", node->value);
    }
    printf("]\n");
    
    for (int i = 0; i < node->num_children; i++) {
        char child_label[20];
        sprintf(child_label, "%d", i+1);
        printAST(node->children[i], level + 1, child_label);
    }
}

void freeAST(Node *node) {
    if (node == NULL) return;
    
    for (int i = 0; i < node->num_children; i++) {
        freeAST(node->children[i]);
    }
    
    free(node->label);
    if (node->value) free(node->value);
    if (node->children) free(node->children);
    free(node);
}

int validateColumn(char *table, char *column) {
    for (int i = 0; i < num_tables; i++) {
        if (strcasecmp(tables[i].table_name, table) == 0) {
            for (int j = 0; j < tables[i].num_columns; j++) {
                if (strcasecmp(tables[i].columns[j], column) == 0) {
                    return 1;
                }
            }
            return 0;
        }
    }
    return 0;
}

void validateAllColumns(Node *columns_node, char *table) {
    if (columns_node == NULL) return;
    
    for (int i = 0; i < columns_node->num_children; i++) {
        Node *col = columns_node->children[i];
        if (col && col->value) {
            if (!validateColumn(table, col->value)) {
                char error[256];
                snprintf(error, sizeof(error), 
                        "Error semantico: columna '%s' no existe en tabla '%s'", 
                        col->value, table);
                yyerror(error);
                exit(1);
            }
        }
    }
}