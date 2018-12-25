%{
#include <stdio.h>
#include <string.h>
#include <iostream>
using namespace std;
int yylex();
void yyerror(const char *message);
int errorFlag=0;
void checkMatrixMul(int a1, int a2, int a3, int a4, int columnNum)
{
	/*printf("CheckMatrixMul is working\n");*/
	if(a2!=a3){
		printf("Semantic error on col %d\n", columnNum);
		errorFlag=1;
	}
}
void checkMatrixAdd(int a1, int a2, int a3, int a4, int columnNum)
{
	if(a1!=a3||a2!=a4){
		printf("Semantic error on col %d\n", columnNum);
		errorFlag=1;
	}
}
%}
%union {
int ival;
struct 
{
	int a;
	int b;
}exval;
class abc
{
	public:
	int aaa;
};
}/*優先度越高的擺下面*/
%token <ival> INUMBER number id boolval andop define ifop lambda mod notop orop
printnum printbool
%type <ival> PROGRAM STMT PRINT-STMT EXP NUM-OP PLUS MINUS MULTIPLY DIVIDE
MODULUS GREATER SMALLER EQUAL LOGICAL-OP AND-OP OR-OP NOT-OP DEF-STMT VARIABLE
FUNEXP FUNIDs FUNBODY FUNCALL PARAM LASTEXP FUNNAME IFEXP TESTEXP THENEXP
ELSE-EXP
%left <exval> '+''-'
%left <exval> '*''/'
%right <exval> '^'
%token <ival> '('')''['']'
%%
/*1. program*/
/*一個以上的STMT*/
PROGRAM : STMT
        | STMT PROGRAM
        ;
STMT : EXP 
     | DEF-STMT 
     | PRINT-STMT
     ;
/*2. Print*/
PRINT-STMT : '(' printnum EXP ')'     {cout<<$2;}
           | '(' printbool EXP ')'    {cout<<$2;}
           ;
/*3. Exprssion*/
EXP : boolval | number {cout<<"yacc number\n";} | VARIABLE | NUM-OP | LOGICAL-OP
    | FUNEXP | FUNCALL | IFEXP
    ;
/*4. Numerical operation*/
NUM-OP : PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER
       | SMALLER | EQUAL
	   ;
moreEXP : EXP
        | EXP moreEXP
        ;
PLUS : '('  '+'  EXP  moreEXP ')' {cout<<"yacc finish PLUS\n";}
     ;
MINUS : '(' '-' EXP EXP ')'       {cout<<"yacc finish MINUS\n";}
      ;
MULTIPLY : '(' '*' EXP moreEXP ')' {cout<<"yacc finish MULTIPLY\n";}
         ;
DIVIDE : '(' '/' EXP EXP ')'       {cout<<"yacc finish DIVIDE\n";}
       ;
MODULUS : '(' mod EXP EXP ')'      {cout<<"yacc finish MODULUS\n";}
        ;
GREATER : '(' '>' EXP EXP ')'      {cout<<"yacc finish GREATER\n";}
        ;
SMALLER : '(' '<' EXP EXP ')'      {cout<<"yacc finish SMALLER\n";}
        ;
EQUAL : '(' '=' EXP EXP '+' ')'    {cout<<"yacc finish EQUAL\n";}
      ;
/*5. Logical operation*/
LOGICAL-OP : AND-OP | OR-OP | NOT-OP
           ;
AND-OP : '(' andop EXP moreEXP ')'    {cout<<"yacc finish AND\n";}     
       ;
OR-OP : '(' orop EXP moreEXP ')'      {cout<<"yacc finish OR\n";}
      ;
NOT-OP : '(' notop EXP ')'            {cout<<"yacc finish NOT\n";}
       ;
/*6. define Statment*/
DEF-STMT : '(' define VARIABLE EXP ')' {cout<<"yacc finish defined stmt\n";}
         ;
VARIABLE : id
         ;
/*7. Function*/
FUNEXP : '(' lambda FUNIDs FUNBODY ')'  {cout<<"yacc finish FUN-EXP\n";}
       ;
moreIDs: id
       | id moreIDs
       ;
FUNIDs : '(' moreIDs ')'                 {cout<<"yacc finish FUN-IDs\n";}
       | '(' ')'
       ;
FUNBODY : EXP                           {cout<<"yacc finish FUN-BODY\n";}
        ;
morePRAM : PARAM
         | PARAM morePRAM
		 ;
FUNCALL : '(' FUNEXP morePRAM ')'      {cout<<"yacc finish FUN-CALL\n";}
        | '(' FUNEXP ')'               {cout<<"yacc finish FUN-CALL\n";}
        | '(' FUNNAME morePRAM ')'     {cout<<"yacc finish FUN-CALL\n";}
		| '(' FUNNAME ')'              {cout<<"yacc finish FUN-CALL\n";}
        ;
PARAM : EXP                             {cout<<"yacc finish PARAM\n";}
      ;
LASTEXP : EXP                           {cout<<"yacc finish LASTEXP\n";}
         ;
FUNNAME : id                            {cout<<"yacc finish FUN-NAME\n";}
         ;
/*8. if Expression*/
IFEXP : '(' ifop TESTEXP THENEXP ELSEEXP ')' {cout<<"yacc finish IF-EXP\n";}
       ;
TESTEXP : EXP
         ;
THENEXP : EXP
         ;
ELSEEXP : EXP
         ;

%%
void yyerror (const char *message)
{
        fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[]) {
	    
        yyparse();
		if(errorFlag!=1)
		    cout<<"Accepted\n";
        return(0);
}
