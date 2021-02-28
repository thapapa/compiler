%{
#define _GNU_SOURCE_
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "fort600_parser.tab.h"
#define LINE_MAX_CHARS 500
#define STRINGS_MAX_CHARS 300  
#define MAX_WRONG_CHARS 3

int lineCount = 1;
int error = 0;
int getNextLine();
int counter_string;
char string_buffer[STRINGS_MAX_CHARS];
char line[LINE_MAX_CHARS];
char wrong_chars[MAX_WRONG_CHARS];
char file[64];


double str_to_double(char* str){//if it has no plus or minus in [Ee] default is plus
	char *dot;
	double eval;
	double rval;
	double value;
	char *epsilon;
	char *realnum;
	
	dot = strchr(str,'.');
	if(dot == NULL){
		epsilon = strchr(str,'E');
		if(epsilon == NULL) {
			epsilon = strchr(str,'e');
			realnum = strtok(str,epsilon);
			rval = (double)atoi(realnum);
			eval = (double)atoi(epsilon+1);
			value = rval*pow(10,eval);
			return(value);
		}
		realnum = strtok(str,epsilon);
		rval = (double)atoi(realnum);
		eval = (double)atoi(epsilon+1);
		value = rval*pow(10,eval);
		return(value);
	}
	epsilon = strchr(str,'E');
	if(epsilon == NULL) {
		epsilon = strchr(str,'e');
		if(epsilon == NULL){
			return(strtod(str,NULL));
		}
		realnum = strtok(str,"e");
		rval = strtod(realnum,NULL);
		eval = (double)atoi(epsilon+1);
		value = rval*pow(10,eval);
		return(value);
	}
	realnum = strtok(str,"E");
	rval = strtod(realnum,NULL);
	eval = (double)atoi(epsilon+1);
	value = rval*pow(10,eval);
	return(value);
}

double hex_double_to_real_double(char* str){
	
	char *dot;
	int rval;
	int dotval;
	double value;
	char value_str[100];
	
	
	dot = strchr(str,'.');
	dotval = strtol(dot+1,NULL,16);
	rval = strtol(str,dot,16);
	sprintf(value_str,"%d.%d",rval,dotval);
	value = strtod(value_str,NULL);
	return(value);
}



void printerror(){
	printf("Error in line: %d:%s \n",lineCount,line);
	printf("Wrong chars so far:%s\n",wrong_chars);
}

%}
%option noyywrap
%option nounput
%option noinput
%x COMMENT
%x STRING

%%


\$ { error=0;  BEGIN(COMMENT);}
<COMMENT>.*$ {lineCount++; BEGIN(INITIAL);}
<COMMENT><<EOF>> {printf("Not closed Comment\n"); exit(1);}


"FUNCTION" {error = 0; yylval.strval=strdup(yytext); return(I_FUNCTION);}
"function" {error = 0; yylval.strval=strdup(yytext); return(I_FUNCTION);}
"SUBROUTINE" {error = 0; yylval.strval=strdup(yytext); return(I_SUBROUTINE);}
"subroutine" {error = 0; yylval.strval=strdup(yytext); return(I_SUBROUTINE);}
"END" {error = 0; yylval.strval=strdup(yytext); return(I_END);}
"end" {error = 0; yylval.strval=strdup(yytext); return(I_END);}
"COMMON" {error = 0; yylval.strval=strdup(yytext); return(I_COMMON);}
"common" {error = 0; yylval.strval=strdup(yytext); return(I_COMMON);}
"INTEGER" {error = 0; yylval.strval=strdup(yytext); return(I_INTEGER);}
"integer" {error = 0; yylval.strval=strdup(yytext); return(I_INTEGER);}
"REAL" {error = 0; yylval.strval=strdup(yytext); return(I_REAL);}
"real" {error = 0; yylval.strval=strdup(yytext); return(I_REAL);}
"LOGICAL" {error = 0; yylval.strval=strdup(yytext); return(I_LOGICAL);}
"logical" {error = 0; yylval.strval=strdup(yytext); return(I_LOGICAL);}
"CHARACTER" {error = 0; yylval.strval=strdup(yytext); return(I_CHARACTER);}
"character" {error = 0; yylval.strval=strdup(yytext); return(I_CHARACTER);}
"STRING" {error = 0; yylval.strval=strdup(yytext); return(I_STRING);}
"string" {error = 0; yylval.strval=strdup(yytext); return(I_STRING);}
"DATA" {error = 0; yylval.strval=strdup(yytext); return(I_DATA);}
"data" {error = 0; yylval.strval=strdup(yytext); return(I_DATA);}
"CONTINUE" {error = 0; yylval.strval=strdup(yytext); return(I_CONTINUE);}
"continue" {error = 0; yylval.strval=strdup(yytext); return(I_CONTINUE);}
"GOTO" {error = 0; yylval.strval=strdup(yytext); return(I_GOTO);}
"goto" {error = 0; yylval.strval=strdup(yytext); return(I_GOTO);}
"CALL" {error = 0; yylval.strval=strdup(yytext); return(I_CALL);}
"call" {error = 0; yylval.strval=strdup(yytext); return(I_CALL);}
"LENGTH" {error = 0; yylval.strval=strdup(yytext); return(I_LENGTH);}
"length" {error = 0; yylval.strval=strdup(yytext); return(I_LENGTH);}
"READ" {error = 0; yylval.strval=strdup(yytext); return(I_READ);}
"read" {error = 0; yylval.strval=strdup(yytext); return(I_READ);}
"WRITE" {error = 0; yylval.strval=strdup(yytext); return(I_WRITE);}
"write" {error = 0; yylval.strval=strdup(yytext); return(I_WRITE);}
"IF" {error = 0; yylval.strval=strdup(yytext); return(I_IF);}
"if" {error = 0; yylval.strval=strdup(yytext); return(I_IF);}
"THEN" {error = 0; yylval.strval=strdup(yytext); return(I_THEN);}
"then" {error = 0; yylval.strval=strdup(yytext); return(I_THEN);}
"ELSE" {error = 0; yylval.strval=strdup(yytext); return(I_ELSE);}
"else" {error = 0; yylval.strval=strdup(yytext); return(I_ELSE);}
"ENDIF" {error = 0; yylval.strval=strdup(yytext); return(I_ENDIF);}
"endif" {error = 0; yylval.strval=strdup(yytext); return(I_ENDIF);}
"DO" {error = 0; yylval.strval=strdup(yytext); return(I_DO);}
"do" {error = 0; yylval.strval=strdup(yytext); return(I_DO);}
"ENDDO" {error = 0; yylval.strval=strdup(yytext); return(I_ENDDO);}
"enddo" {error = 0; yylval.strval=strdup(yytext); return(I_ENDDO);}
"STOP" {error = 0; yylval.strval=strdup(yytext); return(I_STOP);}
"stop" {error = 0; yylval.strval=strdup(yytext); return(I_STOP);}
"RETURN" {error = 0; yylval.strval=strdup(yytext); return(I_RETURN);}
"return" {error = 0; yylval.strval=strdup(yytext); return(I_RETURN);}



[a-zA-Z]\_?([a-zA-Z0-9]\_?)* {error = 0; yylval.strval=strdup(yytext); return(I_ID);}


0[xX][1-9A-Fa-f][0-9A-Fa-f]* {error = 0; yylval.intval = strtol(&yytext[2],NULL,16); return(I_ICONST);}

0|[1-9][0-9]* {error = 0; yylval.intval = atoi(yytext); return(I_ICONST);}


(0|[1-9][0-9]*)\.([0-9]*[1-9])?([Ee][+-]?[1-9][0-9]*)? {error = 0; yylval.doubleval = str_to_double(yytext); return(I_RCONST);}

[1-9][0-9]*[Ee][+-]?[1-9][0-9]* {error = 0; yylval.doubleval = str_to_double(yytext); return(I_RCONST);}

0[xX](0|[1-9A-Fa-f][0-9A-Fa-f]*)\.([0-9A-Fa-f]*[1-9A-Fa-f])? {error = 0; yylval.doubleval = hex_double_to_real_double(yytext); return(I_RCONST);}

"\.TRUE\."  {error = 0; yylval.strval=strdup(yytext); return(I_LCONST);}
"\.true\."  {error = 0; yylval.strval=strdup(yytext); return(I_LCONST);}
"\.FALSE\." {error = 0; yylval.strval=strdup(yytext); return(I_LCONST);}
"\.false\." {error = 0; yylval.strval=strdup(yytext); return(I_LCONST);}

\'([ -~]|\n|\f|\t|\r|\b|\v)\' {error = 0; yylval.strval=strdup(yytext); return(I_CCONST);} 

\" {error = 0; counter_string = 0; BEGIN(STRING);}

<STRING>"\\n" {string_buffer[counter_string] = '\n'; counter_string++; yyless(1);/* yyless(1) is used for purposes of something like "st\nvb" after \n in the last rule (<STRING>".") i use  (string_buffer[counter_string]= *yytext) if i dont have the yyless then the yytext will also have \n but i want to have only vb*/}
<STRING>"\\f" {string_buffer[counter_string] = '\f'; counter_string++; yyless(1);}
<STRING>"\\t" {string_buffer[counter_string] = '\t'; counter_string++; yyless(1);} 
<STRING>"\\r" {string_buffer[counter_string] = '\r'; counter_string++; yyless(1);} 
<STRING>"\\b" {string_buffer[counter_string] = '\b'; counter_string++; yyless(1);} 
<STRING>"\\v" {string_buffer[counter_string] = '\v'; counter_string++; yyless(1);} 
<STRING>"\\\"" {string_buffer[counter_string] = '\\'; counter_string++; string_buffer[counter_string] = '\"'; counter_string++; yyless(2);}
<STRING>"\\" {string_buffer[counter_string] = '\\'; counter_string++; yyless(1);}
<STRING>"\\$" {string_buffer[counter_string] = '\n'; counter_string++; yyless(1);}
<STRING><<EOF>> {printf("String is not closed\n"); exit(1);}
<STRING>"\"" {BEGIN(INITIAL); string_buffer[counter_string]='\0'; yylval.strval = strdup(string_buffer); return(I_SCONST);}
<STRING>. {string_buffer[counter_string] = *yytext; counter_string++;} 

"\.OR\." {error = 0; yylval.strval=strdup(yytext); return(I_OROP);}
"\.or\." {error = 0; yylval.strval=strdup(yytext); return(I_OROP);}
"\.AND\." {error = 0; yylval.strval=strdup(yytext); return(I_ANDOP);}
"\.and\." {error = 0; yylval.strval=strdup(yytext); return(I_ANDOP);}
"\.NOT\." {error = 0; yylval.strval=strdup(yytext); return(I_NOTOP);}
"\.not\." {error = 0; yylval.strval=strdup(yytext); return(I_NOTOP);}

"\.GT\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.gt\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.GE\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.ge\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.LT\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.lt\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.LE\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.le\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.EQ\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.eq\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.NE\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}
"\.ne\." {error = 0; yylval.strval=strdup(yytext); return(I_RELOP);}

"\*\*" {error = 0; yylval.strval=strdup(yytext); return(I_POWEROP);}
"\+" {error = 0; yylval.strval=strdup(yytext); return(I_ADDOP);}
"\-" {error = 0; yylval.strval=strdup(yytext); return(I_ADDOP);}
"\*" {error = 0; yylval.strval=strdup(yytext); return(I_MULOP);}
"\/" {error = 0; yylval.strval=strdup(yytext); return(I_DIVOP);}


"\(" {error = 0; yylval.strval=strdup(yytext); return(I_LPAREN);}
"\)" {error = 0; yylval.strval=strdup(yytext); return(I_RPAREN);}
"\," {error = 0; yylval.strval=strdup(yytext); return(I_COMMA);}
"\=" {error = 0; yylval.strval=strdup(yytext); return(I_ASSIGN);}

"\n" {lineCount++; getNextLine(file,line,LINE_MAX_CHARS);}

<<EOF>> {return(0);}

[ /t] {;/*noop*/}
. {/*Error chars doesnt match with nothing after MAX_WRONG_CHARS wrong chars abord */ wrong_chars[error]= *yytext; printerror();  error++; if(error >= MAX_WRONG_CHARS) exit(1); yyless(1);}

%%
