CC = gcc
CFLAGS = -Wall -g
LEX = flex
YACC = bison

TARGET = sql_analyzer
PARSER_SRC = sql_parser.y
LEXER_SRC = sql_lexer.l
MAIN_SRC = main.c

PARSER_OUT = sql_parser.tab.c
PARSER_HEADER = sql_parser.tab.h
LEXER_OUT = lex.yy.c

OBJ_FILES = $(PARSER_OUT:.c=.o) $(LEXER_OUT:.c=.o) $(MAIN_SRC:.c=.o)

all: $(TARGET)

$(PARSER_HEADER) $(PARSER_OUT): $(PARSER_SRC)
	$(YACC) -d -o $(PARSER_OUT) $(PARSER_SRC)

$(LEXER_OUT): $(LEXER_SRC) $(PARSER_HEADER)
	$(LEX) $(LEXER_SRC)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(PARSER_OUT) $(LEXER_OUT) $(MAIN_SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(PARSER_OUT) $(LEXER_OUT) $(MAIN_SRC)

clean:
	rm -f $(TARGET) $(TARGET).exe
	rm -f $(PARSER_OUT) $(PARSER_HEADER) $(LEXER_OUT)
	rm -f *.o

test: $(TARGET)
	@echo "============================================"
	@echo "         EJECUTANDO PRUEBAS"
	@echo "============================================"
	@echo ""
	@echo "--- Test 1: SELECT valido ---"
	@./$(TARGET) ejemplos/test1_valido.sql
	@echo ""
	@echo "--- Test 2: INSERT valido ---"
	@./$(TARGET) ejemplos/test2_valido.sql
	@echo ""
	@echo "--- Test 3: UPDATE valido ---"
	@./$(TARGET) ejemplos/test3_valido.sql
	@echo ""
	@echo "--- Test 4: Error sintactico ---"
	@./$(TARGET) ejemplos/test4_error_sintactico.sql || true
	@echo ""
	@echo "--- Test 5: Error semantico ---"
	@./$(TARGET) ejemplos/test5_error_semantico.sql || true
	@echo ""
	@echo "============================================"
	@echo "         PRUEBAS COMPLETADAS"
	@echo "============================================"

.PHONY: all clean test