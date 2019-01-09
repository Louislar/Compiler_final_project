%{
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <map>
#include "variablehead.h"
using namespace std;
int yylex();
void yyerror(const char *message);
int errorFlag=0;
std::map<std::string, variable> globalVar;	/*包括變數以及函數的清單*/

%}

%code requires {
	#include <stdio.h>
	#include <string.h>
	#include <iostream>
	#include <map>
	#include "variablehead.h"
	
	
	struct Type {
        int ival;
		struct 
		{
			int a;
			int b;
		}exval;
        variable var;
    };
    
    #define YYSTYPE Type  // for cpp and c (bison itself) compatibility
}

/* This section defines the additional function using the data type in
 * `%code requires` section.
*/
%code provides {
	void checkMatrixMul(int a1, int a2, int a3, int a4, int columnNum);
}

/*優先度越高的擺下面*/
%token <var> INUMBER number id boolval andop define ifop lambda mod notop orop
printnum printbool
%type <var> PROGRAM STMT PRINT-STMT EXP NUM-OP PLUS MINUS MULTIPLY DIVIDE
MODULUS GREATER SMALLER EQUAL LOGICAL-OP AND-OP OR-OP NOT-OP DEFSTMT VARIABLE
FUNEXP FUNIDs FUNBODY FUNCALL PARAM LASTEXP FUNNAME IFEXP TESTEXP THENEXP
ELSEEXP moreEXPPlus moreEXPMUL moreEXPEqual moreEXPAnd moreEXPOr
%left <exval> '+''-'
%left <exval> '*''/'
%right <exval> '^'
%token <ival> '('')''['']'
%%
/*1. program*/
/*一個以上的STMT*/
PROGRAM : STMT 				{
								/*將變數加入global variable清單*/
								if($1.Datatype==4){globalVar[$1.Name]=$1;};
							}
        | STMT moreSTMT 	{
								/*將變數加入global variable清單*/
								if($1.Datatype==4){globalVar[$1.Name]=$1;};
							}
        ;
moreSTMT: STMT 				{
								/*將變數加入global variable清單*/
								if($1.Datatype==4){globalVar[$1.Name]=$1;};
							}			
		| STMT moreSTMT  	{
								/*將變數加入global variable清單*/
								if($1.Datatype==4){globalVar[$1.Name]=$1;};
							}
		;
STMT : EXP 
     | DEFSTMT 
     | PRINT-STMT
     ;
/*2. Print*/
PRINT-STMT : '(' printnum EXP ')'     {cout<<$3.value<<"\n";}
           | '(' printbool EXP ')'    {
										if($3.Datatype!=1)
											return 0;
										if($3.value==1)
											std::cout<<"#t\n";
										else if($3.value==0)
											std::cout<<"#f\n";
										else {
											cout<<"Invalid format\n";
										}
									  }
           ;
/*3. Exprssion*/
EXP : boolval | number {cout<<"yacc number\n";} | VARIABLE {/*從global variable搜尋*/
															std::map<std::string, variable>::iterator it;
															it=globalVar.find($1.Name);
															if(it!=globalVar.end()) {
																$$=it->second;
															}
															else {cout<<globalVar.size()<<" \n";cout<<"Cant find "<<$1.Name<<"\n";return 0;};
															}
	| NUM-OP | LOGICAL-OP
    | FUNEXP | FUNCALL | IFEXP
    ;
/*4. Numerical operation*/
NUM-OP : PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER
       | SMALLER | EQUAL
	   ;
moreEXP : EXP
		| EXP moreEXP
		;
moreEXPPlus : EXP {$$.value=$1.value;}
        | EXP moreEXPPlus {$$.value=$1.value+$2.value;}
        ;
moreEXPMUL : EXP {$$.value=$1.value;}
		| EXP moreEXPMUL {$$.value=$1.value*$2.value;}
		;
PLUS : '('  '+'  EXP  moreEXPPlus ')' {$$.value=$3.value+$4.value;cout<<"yacc finish PLUS\n";}
     ;
MINUS : '(' '-' EXP EXP ')'       {$$.value=$3.value-$4.value;cout<<"yacc finish MINUS\n";}
      ;
MULTIPLY : '(' '*' EXP moreEXPMUL ')' {$$.value=$3.value*$4.value;cout<<"yacc finish MULTIPLY\n";}
         ;
DIVIDE : '(' '/' EXP EXP ')'       {$$.value=$3.value/$4.value;cout<<"yacc finish DIVIDE\n";}
       ;
MODULUS : '(' mod EXP EXP ')'      {$$.value=$3.value%$4.value;cout<<"yacc finish MODULUS\n";}
        ;
GREATER : '(' '>' EXP EXP ')'      {if($3.value>$4.value){$$.Datatype=1;$$.value=1;};
									if($3.value<=$4.value){$$.Datatype=1;$$.value=0;};
									cout<<"yacc finish GREATER\n";}
        ;
SMALLER : '(' '<' EXP EXP ')'      {if($3.value<$4.value){$$.Datatype=1;$$.value=1;};
									if($3.value>=$4.value){$$.Datatype=1;$$.value=0;};
									cout<<"yacc finish SMALLER\n";}
        ;
/*要很多個東西都等於才會回傳true*/
moreEXPEqual : EXP {$$.value=$1.value;$$.isEqual=1;}
			| EXP moreEXPEqual {if($1.value!=$2.value){$$.isEqual=0;};$$.value=$1.value;}
			;
EQUAL : '(' '=' EXP moreEXPEqual ')'    {if($3.value==$4.value){$$.value=$3.value;$$.isEqual=1;}
										else {$$.isEqual=0;};
										$$.Datatype=1;
										$$.value=$$.isEqual;
										cout<<"yacc finish EQUAL\n";}
      ;
	  
/*5. Logical operation*/
LOGICAL-OP : AND-OP | OR-OP | NOT-OP
           ;
moreEXPAnd : EXP {$$.value=$1.value;}
			| EXP moreEXPAnd {if($1.value==1&&$2.value==1){$$.value=1;}
								else{$$.value=0;};}
			;
AND-OP : '(' andop EXP moreEXPAnd ')'    {if($3.value==1&&$4.value==1){$$.value=1;}
											else{$$.value=0;};
											$$.Datatype=1;
											cout<<"yacc finish AND\n";}     
       ;
moreEXPOr : EXP {$$.value=$1.value;}
			| EXP moreEXPOr {if($1.value==1||$2.value==1){$$.value=1;}
								else{$$.value=0;};}
			;
OR-OP : '(' orop EXP moreEXPOr ')'      {if($3.value==1||$4.value==1){$$.value=1;}
											else{$$.value=0;};
											$$.Datatype=1;cout<<"yacc finish OR\n";}
      ;
NOT-OP : '(' notop EXP ')'            {if($3.value==1){$$.value=0;}
										else if($3.value==0){$$.value=1;};
										$$.Datatype=1;
										cout<<"yacc finish NOT\n";}
       ;
/*6. define Statment*/
DEFSTMT : '(' define VARIABLE EXP ')' { /*還沒考慮function的define要怎麼做*/
										$$.Datatype=4;
										$$.Name=$3.Name;
										$$.value=$4.value;
										/*globalVar[$$.Name]=$$;*//*可以正常運作, 是一道上面就不行了*/
										cout<<"yacc finish defined stmt\n";
										}
         ;/*用map<string, int>存所有變數的值*/
VARIABLE : id {$$.Name=$1.Name;}
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
IFEXP : '(' ifop TESTEXP THENEXP ELSEEXP ')' {if($3.value==1){$$.value=$4.value;} /*條件是true*/
												else if($3.value==0){$$.value=$5.value;};
												cout<<"yacc finish IF-EXP\n";}
       ;
TESTEXP : EXP                                {$$.value=$1.value;$$.Datatype=$1.Datatype;cout<<"yacc finish TEST-EXP\n";}
        ;
THENEXP : EXP                                {$$.value=$1.value;$$.Datatype=$1.Datatype;cout<<"yacc finish THEN-EXP\n";} 
        ;
ELSEEXP : EXP                                {$$.value=$1.value;$$.Datatype=$1.Datatype;cout<<"yacc finish ELSE-EXP\n";}
        ;

%%
void yyerror (const char *message)
{
        fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[]) {
	    
        yyparse();
        return(0);
}

void checkMatrixMul(int a1, int a2, int a3, int a4, int columnNum)
{
	/*printf("CheckMatrixMul is working\n");*/
	if(a2!=a3){
		printf("Semantic error on col %d\n", columnNum);
		errorFlag=1;
	}
}
