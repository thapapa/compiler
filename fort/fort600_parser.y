/*hash Table was taken MR FLOROS
 * hash function is djb2 and taken from here: http://www.cse.yorku.ca/~oz/hash.html
 * also the getNextLine function is from christo giamouzi
 * The erros is put only in the rules that is most likely to get error (expressions in between parenthesis,IF ELSE,etc.)*/


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashtbl.h"
#define YYDEBUG 1
#define LINE_MAX_CHARS 500
#define MAX_ERRORS 3
#define HASH_TBL_SIZE 16

int yylex();
int scope = 1;
extern char line[LINE_MAX_CHARS],file[64];
HASHTBL *hash_tbl;
extern int lineCount;
extern FILE *yyin;
int errors = 0;


void yyerror (char const *s){
	fprintf (stderr, "%s\n", s);
}

void print_error_and_terminate(){
	
	if(errors > MAX_ERRORS){
		printf("Too many errors in parser TERMINATE NOW!");
		exit(1);
	}
	printf("Error discoverd in parser.\nLINE:%s\nTotal errors so far:%d\n",line,errors);
}

unsigned long hash(unsigned char *str){
	unsigned long hash = 5381;
	int c;
	
	while (c = *str++)
		hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
		
	return hash;
}

extern int getNextLine(char filename[], char line[], int maxlinesize) {
    static int firstrun = 1;
    static FILE *fp;
    memset(line, 0, maxlinesize);
    if (firstrun) {
        fp = fopen(filename, "r");
        if (fp == NULL) {
            fprintf(stderr, "Error opening file \"%s\" for reading.\n", filename);
            exit(1);
        }
        firstrun = 0;
    }
    char *lineptr = NULL;
    size_t linecap = 0;
    ssize_t linelen;
    linelen = getline(&lineptr, &linecap, fp);
    if (linelen == -1) {
        fclose(fp);
        firstrun = 1;
        return 0;
    }
    char *newline = strchr(lineptr, '\n');
    if (newline) {
        *newline='\0';
        linecap--;
    }

    if (linecap > maxlinesize) {
        fprintf(stderr, "Warning: Missing/Incomplete words due to insufficient space.\n");
        strncpy(line, lineptr, maxlinesize-1);
        printf("%zu, %s\n", linecap, line);
        exit(1);
    }
    else {
        strcpy(line, lineptr);
    }
    return 1;
}

%}

%union{
    int intval;
    double doubleval;
    char *strval;
}

%token <intval> I_ICONST

%token <doubleval> I_RCONST

%token <strval> I_FUNCTION I_SUBROUTINE I_END I_COMMON I_INTEGER I_REAL I_LOGICAL I_CHARACTER I_STRING I_DATA I_CONTINUE I_GOTO I_CALL I_LENGTH I_READ I_WRITE I_IF I_THEN I_ELSE I_ENDIF I_DO I_ENDDO I_STOP I_RETURN I_ID I_LCONST I_CCONST I_SCONST I_OROP I_ANDOP I_NOTOP I_RELOP I_ADDOP I_MULOP I_DIVOP I_POWEROP I_LPAREN I_RPAREN I_COMMA I_ASSIGN 

%left I_ADDOP I_MULOP I_DIVOP
%left I_ANDOP I_OROP I_RELOP
%right I_ASSIGN I_POWEROP
%start program

%%

program: body I_END subprograms {hashtbl_get(hash_tbl,0);}
       ;

body: declarations statements
    ;

declarations: declarations type vars
			| declarations I_COMMON cblock_list
			| declarations I_DATA vals
			| 
			;

type: I_INTEGER
	| I_REAL
	| I_LOGICAL
	| I_CHARACTER
	| I_STRING
	;

vars: vars I_COMMA undef_variable 
	| undef_variable
	;


undef_variable: I_ID I_LPAREN dims I_RPAREN  {hashtbl_insert(hash_tbl,$1,NULL,scope);}
			  | I_ID {hashtbl_insert(hash_tbl,$1,NULL,scope);}
			  | I_ID I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
			  ;

dims: dims I_COMMA dim
	| dim
	;

dim: I_ICONST 
	|I_ID // etc x(g) like is on fotr600 test in first line we dont have to put anything in hash tbl
	;

cblock_list: cblock_list cblock 
		   | cblock
		   ;

cblock: I_DIVOP I_ID I_DIVOP id_list {hashtbl_insert(hash_tbl, $2, NULL, 0);}//etc s_str_/.../ like on line 5 on fotr600 test
	  ;

id_list: id_list I_COMMA I_ID {hashtbl_insert(hash_tbl, $3, NULL, 0);}//etc /"string1", *"string2", "string3"/ like on line 5 on fotr600 test
	   | I_ID {hashtbl_insert(hash_tbl, $1, NULL, 0);}
	   ;

vals: vals I_COMMA I_ID value_list
	| I_ID value_list
	;

value_list: I_DIVOP values I_DIVOP
		  ;

values: values I_COMMA value
	  | value
	  ;

value: I_ADDOP constant
	 | I_MULOP I_ADDOP constant
	 | constant
	 | I_MULOP constant
	 ;
	 
constant: I_ICONST | I_RCONST | I_LCONST | I_CCONST | I_SCONST
		;

statements: statements labeled_statement
		  | labeled_statement
		  ;

labeled_statement: label statement
				 | statement
				 ;

label: I_ICONST
	 ;

statement: simple_statement
		 | compound_statement
		 ;

simple_statement: assignment
				| goto_statement
				| if_statement
				| subroutine_call
				| io_statement
				| I_CONTINUE
				| I_RETURN
				| I_STOP
				;

assignment: variable I_ASSIGN expression
		  | variable I_ASSIGN error {errors++; print_error_and_terminate(); yyerrok;}
		  ;

variable: I_ID I_LPAREN expressions I_RPAREN {hashtbl_insert(hash_tbl, $1, NULL, scope);}//the left id on assignment 
		| I_ID {hashtbl_insert(hash_tbl, $1, NULL, scope);}//the left id on assignment 
		| I_ID I_LPAREN error {errors++; print_error_and_terminate(); yyerrok;}
		;

expressions: expressions I_COMMA expression
		   | expression
		   ;

//HERE THERE ARE 8 SHIFT/REDUCE CONFLICTS IN STATE 89--------->
//   BUT IN BISON IN SHIFT/REDUCE CONFLICTS SHIFT IS PREFERED BY BISON SO WE DONT HAVE TO //CHANGE ANYTHING CUSE IT WILL ALWAYS SHIFT TO NEXT EXPRESSION 
  
//State 89

 //  59 expression: expression . OROP expression -----WE WANT SHIFT-----
 //  60           | expression . ANDOP expression -----WE WANT SHIFT-----
  // 61           | expression . RELOP expression -----WE WANT SHIFT-----
  // 62           | expression . ADDOP expression -----WE WANT SHIFT-----
  // 63           | expression . MULOP expression -----WE WANT SHIFT-----
  // 64           | expression . DIVOP expression -----WE WANT SHIFT-----
   //65           | expression . POWEROP expression -----WE WANT SHIFT-----
  // 66           | NOTOP expression .

   // OROP     shift, and go to state 93
   // ANDOP    shift, and go to state 94
   // RELOP    shift, and go to state 95
    //ADDOP    shift, and go to state 96
    //MULOP    shift, and go to state 97
    //DIVOP    shift, and go to state 98
    //POWEROP  shift, and go to state 99

  //  OROP      [reduce using rule 66 (expression)]
   // ANDOP     [reduce using rule 66 (expression)]
   // RELOP     [reduce using rule 66 (expression)]
   // ADDOP     [reduce using rule 66 (expression)]
   // MULOP     [reduce using rule 66 (expression)]
   // DIVOP     [reduce using rule 66 (expression)]
   // POWEROP   [reduce using rule 66 (expression)]
   // $default  reduce using rule 66 (expression) */

expression: expression I_OROP expression
		  | expression I_ANDOP expression
		  | expression I_RELOP expression
		  | expression I_ADDOP expression
		  | expression I_MULOP expression
		  | expression I_DIVOP expression
		  | expression I_POWEROP expression
		  | I_NOTOP expression
		  | I_ADDOP expression
		  | variable
		  | constant
		  | I_LPAREN expression I_RPAREN
		  | I_LENGTH I_LPAREN expression I_RPAREN
		  | I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
		  | I_LENGTH I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
		  ;

goto_statement: I_GOTO label
			  | I_GOTO I_ID I_COMMA I_LPAREN labels I_RPAREN {hashtbl_insert(hash_tbl, $2, NULL, scope);}// the right id after goto etc goto 1000 in line 18 of fort600 test
			  | I_GOTO I_ID I_COMMA I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
			  ;

labels: labels I_COMMA label
	  | label
	  ;

if_statement: I_IF I_LPAREN expression I_RPAREN label I_COMMA label I_COMMA label
			| I_IF I_LPAREN expression I_RPAREN simple_statement
			| I_IF I_LPAREN error I_RPAREN label I_COMMA label I_COMMA label {errors++; print_error_and_terminate(); yyerrok;}
			| I_IF I_LPAREN error I_RPAREN simple_statement {errors++; print_error_and_terminate(); yyerrok;}
			;

subroutine_call: I_CALL variable
			   ;

io_statement: I_READ read_list
			| I_WRITE write_list
			;

read_list: read_list I_COMMA read_item
		 | read_item
		 ;

read_item: variable
		 | I_LPAREN read_list I_COMMA I_ID I_ASSIGN iter_space I_RPAREN {hashtbl_insert(hash_tbl, $4, NULL, scope);} // etc the z in read (x,i=1,x(i)),z in line 17 of fort600 test
		 | I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
		 ;

iter_space: expression I_COMMA expression step
		  ;

step: I_COMMA expression
	| 
	;

write_list: write_list I_COMMA write_item
		  | write_item
		  ;

write_item: expression
		  | I_LPAREN write_list I_COMMA I_ID I_ASSIGN iter_space I_RPAREN {hashtbl_insert(hash_tbl, $4, NULL, scope);} // like read item 
		  ;

compound_statement: branch_statement
				  | loop_statement
				  ;

// we raise scope in I_THEN because after the I_THEN the body of if statement starts and after body we get the ids 
branch_statement: I_IF I_LPAREN expression I_RPAREN I_THEN {scope++;} body {hashtbl_get(hash_tbl, scope); scope--;} tail
				| I_IF I_LPAREN error I_RPAREN I_THEN body tail {errors++; print_error_and_terminate(); yyerrok;}
				;

// we raise scope in I_ELSE because after the I_ELSE the body of else statement starts and after body we get the ids 
tail: I_ELSE{scope++;} body {hashtbl_get(hash_tbl, scope); scope--;} I_ENDIF
	| I_ELSE error I_ENDIF {errors++; print_error_and_terminate(); yyerrok;}
	| I_ENDIF
	| error I_ENDIF {errors++; print_error_and_terminate(); yyerrok;}
	;
// we raise scope in iter_space because after the iter_space the body of loop statement starts and after body we get the ids.
loop_statement: I_DO I_ID I_ASSIGN iter_space{scope++;} body {hashtbl_get(hash_tbl, scope); scope--;} I_ENDDO
			  | I_DO error I_ENDDO {errors++; print_error_and_terminate(); yyerrok;}
			  ;

subprograms: subprograms subprogram
		   | 
		   ;

subprogram: header body I_END {hashtbl_get(hash_tbl, scope);}
		  ;

header: type I_FUNCTION I_ID I_LPAREN formal_parameters I_RPAREN {hashtbl_insert(hash_tbl, $3, NULL, 0);hashtbl_get(hash_tbl, scope); scope++;} // the functions id and we change scope becuse we go inside function
	  | I_SUBROUTINE I_ID I_LPAREN formal_parameters I_RPAREN {hashtbl_insert(hash_tbl, $2, NULL, 0);hashtbl_get(hash_tbl, scope); scope++;} // the subroutins id and we change scope becuse we go inside subroutine
	  | I_SUBROUTINE I_ID {hashtbl_insert(hash_tbl, $2, NULL, 0);hashtbl_get(hash_tbl, scope); scope++;} // the subroutins id and we change scope becuse we go inside subroutine
	  | type I_FUNCTION I_ID I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
	  | I_SUBROUTINE I_ID I_LPAREN error I_RPAREN {errors++; print_error_and_terminate(); yyerrok;}
	  ;

formal_parameters: type vars I_COMMA formal_parameters
				 | type vars
				 ;

%%

int main(int argc,char* argv[]) {
	
	int check;
	
	if(argc < 2) {
		printf("give input file\n");
		exit(1);
	}
	
	yyin = fopen(argv[1],"r");
	
	if(yyin == NULL){
		printf("Something went wrong with opening of file:%s\n",argv[1]);
		exit(1);
	}
	
	hash_tbl = hashtbl_create(HASH_TBL_SIZE,hash);
	strcpy(file,argv[1]);
	getNextLine(file,line,LINE_MAX_CHARS);
	check = yyparse();
	
	if(check != 0) {
		hashtbl_destroy(hash_tbl);
		printf("\nyyparse() wasnt successful parsing:%s\n",file);
		fclose(yyin);
		return(1);
	}
	hashtbl_destroy(hash_tbl);
	printf("\nyyparse() was successful parsing:%s\n",file);
	fclose(yyin);
	return(0);
}














