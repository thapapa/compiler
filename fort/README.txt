flex fort600_lexical.l paragogi tou arxeiou lex.yy.c

bison -d -v -Dparse.trace -t -Werror=yacc,conflicts-sr fort600_parser.y 
paragogi tou .output,fort600_parser.tab.c,fort600_parser.tab.h arxeiou 

gcc -Wall -g lex.yy.c fort600_parser.tab.c hashtbl.c -o name_you_want -lfl -lm
paragogi tou name_you_want

treksimo: ./name_you_want fort600test1.f

