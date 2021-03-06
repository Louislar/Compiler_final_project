%{
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <map>
#include <queue>
#include <list>
#include "variablehead.h"
using namespace std;
int yylex();
void yyerror(const char *message);
int errorFlag=0;
std::map<std::string, variable> globalVar;	/*包括變數以及函數的清單*/
std::list<e> mergeList(std::list<e> list01, std::list<e> list02);

void mergeListInt(std::list<int>& list01, std::list<int>& list02);

/*將call function傳入的參數, 依序放入function expression的參數dictionary裡面*/
void paramMerge(std::map<string, int>& a, std::list<int>& b);
/*把function的式子實際做運算，包含把參數帶進去*/
int calTheExp(std::list<e>& funList, std::map<std::string, int>& functionParams);
%}

%code requires {
	#include <stdio.h>
	#include <string.h>
	#include <iostream>
	#include <map>
	#include "variablehead.h"
	#include <list>
	
	
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
FUNEXP FUNIDs FUNBODY FUNCALL PARAM LASTEXP FUNNAME IFEXP TESTEXP THENEXP moreIDs
ELSEEXP moreEXPPlus moreEXPMUL moreEXPEqual moreEXPAnd moreEXPOr morePRAM
%left <exval> '+''-'
%left <exval> '*''/'
%right <exval> '^'
%token <ival> '('')''['']'
%%
/*1. program*/
/*一個以上的STMT*/
PROGRAM : STMT 				{
								/*將變數加入global variable清單*/
								/*if($1.Datatype==4){globalVar[$1.Name]=$1;};*/
							}
        | STMT { /*將變數加入global variable清單*/ /*if($1.Datatype==4){globalVar[$1.Name]=$1;};*/} moreSTMT
        ;
moreSTMT: STMT 				{
								/*將變數加入global variable清單*/
								/*if($1.Datatype==4){globalVar[$1.Name]=$1;};*/
							}			
		| STMT  { /*將變數加入global variable清單*/ /*if($1.Datatype==4){globalVar[$1.Name]=$1;};*/} moreSTMT
		;
STMT : EXP 
     | DEFSTMT 
     | PRINT-STMT
     ;
/*2. Print*/
PRINT-STMT : '(' printnum EXP ')'     {cout<<$3.value<<"\n";}
           | '(' printbool EXP ')'    {
										/*if($3.Datatype!=1)
											return 0;*/
										if($3.value==1)
											std::cout<<"#t\n";
										else if($3.value==0)
											std::cout<<"#f\n";
										else {
											cout<<"Invalid format\n";
										};
									  }
           ;
/*3. Exprssion*/
EXP : boolval {$$.funList.push_back(e($1.value, "", 2));} 
	| number 			{
							$$.funList.push_back(e($1.value, "", 2));
							//cout<<"yacc number\n";
						} 
	| VARIABLE 			{/*從global variable搜尋*/
							std::map<std::string, variable>::iterator it;
							it=globalVar.find($1.Name);
							if(it!=globalVar.end()) {
								$$=it->second;
							}
							else {
								//cout<<"Cant find "<<$1.Name<<"\n";
								};
							/*加入function的parameter*/
							$$.funList.clear();
							$$.funList.push_back(e(0, $1.Name, 3));
						}
	| NUM-OP | LOGICAL-OP
    | FUNEXP | FUNCALL | IFEXP
    ;
/*4. Numerical operation*/
NUM-OP : PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER
       | SMALLER | EQUAL
	   ;
moreEXP : EXP {}
		| EXP moreEXP {}
		;
moreEXPPlus : EXP {$$.value=$1.value;$$.funList.clear();$$.funList=mergeList($$.funList, $1.funList);/*cout<<"moreEXPPlus len: "<<$$.funList.size()<<"\n";*/}
        | EXP moreEXPPlus {
							$$.value=$1.value+$2.value;
							$$.funList.clear();
							$$.funList.push_back(e(0, "+", 1));
							$$.funList=mergeList($$.funList, $1.funList);
							$$.funList=mergeList($$.funList, $2.funList);
							//cout<<"PLUS has more than two parameter\n";
							}
        ;
moreEXPMUL : EXP {$$.value=$1.value;$$.funList.clear();$$.funList=mergeList($$.funList, $1.funList);/*cout<<"moreEXPMul len: "<<$$.funList.size()<<"\n";*/}
		| EXP moreEXPMUL {
							$$.value=$1.value*$2.value;
							
							$$.funList.clear();
							$$.funList.push_back(e(0, "*", 1));
							$$.funList=mergeList($$.funList, $1.funList);
							$$.funList=mergeList($$.funList, $2.funList);
							//cout<<"MUL has more than two parameter\n";
							}
		;
PLUS : '('  '+'  EXP  moreEXPPlus ')' {
										$$.value=$3.value+$4.value;
										
										$$.funList.clear();
										$$.funList.push_back(e(0, "+", 1));
										$$.funList=mergeList($$.funList, $3.funList);
										$$.funList=mergeList($$.funList, $4.funList);
										//cout<<"yacc finish PLUS len: "<<$$.funList.size()<<"\n";
										}
     ;
MINUS : '(' '-' EXP EXP ')'       {
									$$.value=$3.value-$4.value;
									
									$$.funList.clear();
									$$.funList.push_back(e(0, "-", 1));
									$$.funList=mergeList($$.funList, $3.funList);
									$$.funList=mergeList($$.funList, $4.funList);
									//cout<<"yacc finish MINUS len: "<<$$.funList.size()<<"\n";
									}
      ;
MULTIPLY : '(' '*' EXP moreEXPMUL ')' {
										$$.value=$3.value*$4.value;
										
										$$.funList.clear();
										$$.funList.push_back(e(0, "*", 1));
										$$.funList=mergeList($$.funList, $3.funList);
										$$.funList=mergeList($$.funList, $4.funList);
										//cout<<"yacc finish MULTIPLY len: "<<$$.funList.size()<<"\n";
										}
         ;
DIVIDE : '(' '/' EXP EXP ')'       {
									$$.value=$3.value/$4.value;
									
									$$.funList.clear();
									$$.funList.push_back(e(0, "/", 1));
									$$.funList=mergeList($$.funList, $3.funList);
									$$.funList=mergeList($$.funList, $4.funList);
									//cout<<"yacc finish DIVIDE\n";
									}
       ;
MODULUS : '(' mod EXP EXP ')'      {
									$$.value=$3.value%$4.value;
									
									$$.funList.clear();
									$$.funList.push_back(e(0, "mod", 1));
									$$.funList=mergeList($$.funList, $3.funList);
									$$.funList=mergeList($$.funList, $4.funList);
									//cout<<"yacc finish MODULUS\n";
									}
        ;
GREATER : '(' '>' EXP EXP ')'      {if($3.value>$4.value){$$.Datatype=1;$$.value=1;};
									if($3.value<=$4.value){$$.Datatype=1;$$.value=0;};
									
									$$.funList.clear();
									$$.funList.push_back(e(0, ">", 1));
									$$.funList=mergeList($$.funList, $3.funList);
									$$.funList=mergeList($$.funList, $4.funList);
									//cout<<"yacc finish GREATER\n";
									}
        ;
SMALLER : '(' '<' EXP EXP ')'      {if($3.value<$4.value){$$.Datatype=1;$$.value=1;};
									if($3.value>=$4.value){$$.Datatype=1;$$.value=0;};
									
									$$.funList.clear();
									$$.funList.push_back(e(0, "<", 1));
									$$.funList=mergeList($$.funList, $3.funList);
									$$.funList=mergeList($$.funList, $4.funList);
									//cout<<"yacc finish SMALLER\n";
									}
        ;
/*要很多個東西都等於才會回傳true*/
moreEXPEqual : EXP 						{
											$$.value=$1.value;$$.isEqual=1;
											$$.funList.clear();
											$$.funList=mergeList($$.funList, $1.funList);
											//cout<<"moreEXPEqual len: "<<$$.funList.size()<<"\n";
										}
			| EXP moreEXPEqual 			{
											if($1.value!=$2.value){$$.isEqual=0;};
											$$.value=$1.value;
											
											$$.funList.clear();
											//$$.funList.push_back(e(0, "=", 1));
											$$.funList=mergeList($$.funList, $1.funList);
											$$.funList=mergeList($$.funList, $2.funList);
											//cout<<"EQUAL has more than two parameter\n";
										}
			;
EQUAL : '(' '=' EXP moreEXPEqual ')'    {
											if($3.value==$4.value){$$.value=$3.value;$$.isEqual=1;}
											else {$$.isEqual=0;};
											$$.Datatype=1;
											$$.value=$$.isEqual;
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "=", 1));
											$$.funList.push_back(e($3.funList.size()+$4.funList.size(), "", 2));/*"="後面的參數個數*/
											$$.funList=mergeList($$.funList, $3.funList);
											$$.funList=mergeList($$.funList, $4.funList);
											//cout<<"yacc finish EQUAL params len: "<<$3.funList.size()+$4.funList.size()<<"\n";
										}
      ;
	  
/*5. Logical operation*/
LOGICAL-OP : AND-OP | OR-OP | NOT-OP
           ;
moreEXPAnd : EXP 						{$$.value=$1.value;$$.funList.clear();$$.funList=mergeList($$.funList, $1.funList);/*cout<<"moreEXPAnd len: "<<$$.funList.size()<<"\n";*/}
			| EXP moreEXPAnd 			{
											if($1.value==1&&$2.value==1){$$.value=1;}
											else{$$.value=0;};
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "and", 1));
											$$.funList=mergeList($$.funList, $1.funList);
											$$.funList=mergeList($$.funList, $2.funList);
										}
			;
AND-OP : '(' andop EXP moreEXPAnd ')'   {
											if($3.value==1&&$4.value==1){$$.value=1;}
											else{$$.value=0;};
											$$.Datatype=1;
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "and", 1));
											$$.funList=mergeList($$.funList, $3.funList);
											$$.funList=mergeList($$.funList, $4.funList);
											//cout<<"yacc finish AND\n";
										}     
       ;
moreEXPOr : EXP 						{$$.value=$1.value;$$.funList.clear();$$.funList=mergeList($$.funList, $1.funList);/*cout<<"moreEXPOr len: "<<$$.funList.size()<<"\n";*/}
			| EXP moreEXPOr 			{
											if($1.value==1||$2.value==1){$$.value=1;}
											else{$$.value=0;};
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "or", 1));
											$$.funList=mergeList($$.funList, $1.funList);
											$$.funList=mergeList($$.funList, $2.funList);
										}
			;
OR-OP : '(' orop EXP moreEXPOr ')'      {
											if($3.value==1||$4.value==1){$$.value=1;}
											else{$$.value=0;};
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "or", 1));
											$$.funList=mergeList($$.funList, $3.funList);
											$$.funList=mergeList($$.funList, $4.funList);
											//$$.Datatype=1;cout<<"yacc finish OR\n";
										}
      ;
NOT-OP : '(' notop EXP ')'            	{
											if($3.value==1){$$.value=0;}
											else if($3.value==0){$$.value=1;};
											$$.Datatype=1;
											
											$$.funList.clear();
											$$.funList.push_back(e(0, "not", 1));
											$$.funList=mergeList($$.funList, $3.funList);
											//cout<<"yacc finish NOT\n";
										}
       ;
/*6. define Statment*/
DEFSTMT : '(' define VARIABLE EXP ')' 	{ 
											$$.Datatype=4;
											$$.Name=$3.Name;
											$$.value=$4.value;
										
											/*傳入的是function變數*/
											$$.funList=$4.funList;
											$$.functionParams=$4.functionParams;
											if($4.Datatype==3){$$.Datatype=3;};
											/*加到全域變數清單*/
											globalVar[$$.Name]=$$;
											//cout<<"yacc finish defined stmt\n";
										}
         ;/*用map<string, int>存所有變數的值*/
VARIABLE : id {$$.Name=$1.Name;}
         ;
/*7. Function*/
FUNEXP : '(' lambda FUNIDs FUNBODY ')'  {
											$$.functionParams.clear();
											for(std::map<string, int>::iterator it=$3.functionParams.begin()
												;it!=$3.functionParams.end();it++){
													$$.functionParams[it->first]=it->second;
												};
												
											$$.funList.clear();
											$$.funList=mergeList($$.funList, $4.funList);	
											
											$$.Datatype=3;
											//for(std::list<e>::iterator it=$$.funList.begin();it!=$$.funList.end();it++){cout<<(*it).value<<" ";};
											//cout<<endl;
											//for(std::list<e>::iterator it=$$.funList.begin();it!=$$.funList.end();it++){cout<<(*it).name<<" ";};
											//cout<<endl;
											//cout<<"yacc finish FUN-EXP, len: "<<$$.funList.size()<<"\n";
										}
       ;
moreIDs: id								{$$.functionParams.clear();$$.functionParams[$1.Name]=0;}
       | id  moreIDs 					{
											$$.functionParams.clear();
											$$.functionParams[$1.Name]=0;
											for(std::map<string, int>::iterator it=$2.functionParams.begin()
												;it!=$2.functionParams.end();it++){
													$$.functionParams[it->first]=it->second;
												};
										}
       ;
FUNIDs : '(' moreIDs ')'                 {$$.functionParams=$2.functionParams;/*cout<<"yacc finish FUN-IDs\n";*/}
       | '(' ')'
       ;
FUNBODY : EXP                           {$$.funList.clear();$$.funList=mergeList($$.funList, $1.funList);/*cout<<"yacc finish FUN-BODY\n";*/}
        ;
morePRAM : PARAM						{$$.funParamPassIn.clear();mergeListInt($$.funParamPassIn, $1.funParamPassIn);}
         | PARAM morePRAM				{
											$$.funParamPassIn.clear();
											mergeListInt($$.funParamPassIn, $1.funParamPassIn);
											mergeListInt($$.funParamPassIn, $2.funParamPassIn);
										}
		 ;
		 /*這裡就要把function的值算出來了*/
FUNCALL : '(' FUNEXP morePRAM ')'      {
										/*參數傳入*/
										paramMerge($2.functionParams, $3.funParamPassIn);
										/*參數帶入，實際計算*/
										$$.value=calTheExp($2.funList, $2.functionParams);
										//cout<<"FunList len: "<<$2.funList.size()<<"\n";
										//cout<<"FunParams len: "<<$2.functionParams.size()<<"\n";
										//for(std::map<std::string, int>::iterator it=$2.functionParams.begin();it!=$2.functionParams.end();it++){cout<<it->first<<" ";};
										//cout<<endl;
										//for(std::map<std::string, int>::iterator it=$2.functionParams.begin();it!=$2.functionParams.end();it++){cout<<it->second<<" ";};
										//cout<<endl;
										
										//cout<<"yacc finish FUN-CALL\n";
										}
        | '(' FUNEXP ')'               {
										/*參數帶入，實際計算*/
										$$.value=calTheExp($2.funList, $2.functionParams);
										//cout<<"yacc finish FUN-CALL\n";
										}
        | '(' FUNNAME morePRAM ')'     {
										/*從變數清單找到function*/
										std::map<std::string, variable>::iterator it;
										it=globalVar.find($2.Name);
										if(it!=globalVar.end()) {
											/*先把參數送進來*/
											paramMerge((it->second).functionParams, $3.funParamPassIn);
											//cout<<"FunList len: "<<(it->second).funList.size()<<"\n";
											//cout<<"FunParams len: "<<(it->second).functionParams.size()<<"\n";
											//for(std::map<std::string, int>::iterator it1=(it->second).functionParams.begin();it1!=(it->second).functionParams.end();it1++){cout<<it1->first<<" ";};
											//cout<<endl;
											//for(std::map<std::string, int>::iterator it1=(it->second).functionParams.begin();it1!=(it->second).functionParams.end();it1++){cout<<it1->second<<" ";};
											//cout<<endl;
											$$.value=calTheExp((it->second).funList, (it->second).functionParams);
										}
										else{
											$$.value=0;
											//cout<<"Cant find the function"<<endl;
										}
										
										//cout<<"yacc finish FUN-CALL\n";
										}
		| '(' FUNNAME ')'              {
											/*從變數清單找到function*/
											std::map<std::string, variable>::iterator it;
											it=globalVar.find($2.Name);
											if(it!=globalVar.end()) {
												//cout<<"FunList len: "<<(it->second).funList.size()<<"\n";
												//cout<<"FunParams len: "<<(it->second).functionParams.size()<<"\n";
												//for(std::map<std::string, int>::iterator it1=(it->second).functionParams.begin();it1!=(it->second).functionParams.end();it1++){cout<<it1->first<<" ";};
												//cout<<endl;
												//for(std::map<std::string, int>::iterator it1=(it->second).functionParams.begin();it1!=(it->second).functionParams.end();it1++){cout<<it1->second<<" ";};
												//cout<<endl;
												$$.value=calTheExp((it->second).funList, (it->second).functionParams);
											}
											else{
												$$.value=0;
											//cout<<"Cant find the function"<<endl;
											}
											/*cout<<"yacc finish FUN-CALL\n";*/
										}
        ;
PARAM : EXP                             {$$.funParamPassIn.clear();$$.funParamPassIn.push_back($1.value);/*cout<<"yacc finish PARAM, value: "<<$1.value<<"\n";*/}
      ;
LASTEXP : EXP                           {/*cout<<"yacc finish LASTEXP\n"*/}
         ;
FUNNAME : id                            {$$.Name=$1.Name;/*cout<<"yacc finish FUN-NAME\n";*/}
         ;
/*8. if Expression*/
IFEXP : '(' ifop TESTEXP THENEXP ELSEEXP ')' {
												if($3.value==1){$$.value=$4.value;} /*條件是true*/
												else if($3.value==0){$$.value=$5.value;};
												
												$$.funList.clear();
												$$.funList.push_back(e(0, "if", 1));
												$$.funList=mergeList($$.funList, $3.funList);
												$$.funList=mergeList($$.funList, $4.funList);
												$$.funList=mergeList($$.funList, $5.funList);
												//cout<<"yacc finish IF-EXP\n";
											 }
       ;
TESTEXP : EXP                               {
												$$.value=$1.value;
												$$.Datatype=$1.Datatype;
												
												$$.funList.clear();
												$$.funList=mergeList($$.funList, $1.funList);
												//cout<<"yacc finish TEST-EXP\n";
											}
        ;
THENEXP : EXP                               {
												$$.value=$1.value;
												$$.Datatype=$1.Datatype;
												
												$$.funList.clear();
												$$.funList=mergeList($$.funList, $1.funList);
												//cout<<"yacc finish THEN-EXP\n";
											} 
        ;
ELSEEXP : EXP                               {
												$$.value=$1.value;
												$$.Datatype=$1.Datatype;
												
												$$.funList.clear();
												$$.funList=mergeList($$.funList, $1.funList);
												//cout<<"yacc finish ELSE-EXP\n";
											}
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

std::list<e> mergeList(std::list<e> list01, std::list<e> list02)
		{
			std::list<e> output;
			for(std::list<e>::iterator it=list01.begin();it!=list01.end();it++)
			{
				output.push_back(*it);
			}
			for(std::list<e>::iterator it=list02.begin();it!=list02.end();it++)
			{
				output.push_back(*it);
			}
			return output;
		}
		

void mergeListInt(std::list<int>& list01, std::list<int>& list02)
		{
			for(std::list<int>::iterator it=list02.begin();it!=list02.end();it++)
			{
				list01.push_back(*it);
			}
		}

/*將call function傳入的參數, 依序放入function expression的參數dictionary裡面*/
void paramMerge(std::map<string, int>& a, std::list<int>& b)
{
	std::list<int>::iterator it=b.begin();
	std::map<string, int>::iterator it2=a.begin();
	while(it!=b.end() && it2!=a.end())
	{
		it2->second=*it;
		
		it++;
		it2++;
	}
}

/*把function的式子實際做運算，包含把參數帶進去*/
int calTheExp(std::list<e>& funlist, std::map<std::string, int>& functionparams)
{
	int ans=0;
	std::stack<e> expStack;
	/*先將function的exp放入stack裡面*/
	for(std::list<e>::iterator it=funlist.begin();it!=funlist.end();it++){
		expStack.push(*it);
		//std::cout<<"IT: "<<(*it).value<<" "<<(*it).name<<"\n";
	}
	
	std::stack<int> tempStack;
	while(expStack.size()>0)
	{
		e tempElement=expStack.top();
		expStack.pop();
		
		/*是加減乘除*/
		if(tempElement.type==1)
		{
			if(tempElement.name=="+")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				a=a+b;
				tempStack.push(a);
			}
			else if(tempElement.name=="-")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				a=a-b;
				tempStack.push(a);
			}
			else if(tempElement.name=="*")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				a=a*b;
				tempStack.push(a);
			}
			else if(tempElement.name=="/")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				a=a/b;
				tempStack.push(a);
			}
			else if(tempElement.name=="mod")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				a=a%b;
				tempStack.push(a);
			}
			else if(tempElement.name=="<")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				if(a<b)
					a=1;
				else
					a=0;
				tempStack.push(a);
			}
			else if(tempElement.name==">")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				if(a>b)
					a=1;
				else
					a=0;
				tempStack.push(a);
			}
			else if(tempElement.name=="=")	/*"="的部分還要修正, function內部*/
			{
				int paramsNum=tempStack.top();
				tempStack.pop();
				int paramsArray[100];
				for(int i=0;i<paramsNum;i++)
				{
					paramsArray[i]=tempStack.top();
					tempStack.pop();
				}
				int isAllEqual=1;
				int tempNum=paramsArray[0];
				for(int i=1;i<paramsNum;i++)
				{
					if(paramsArray[i]!=tempNum){
						isAllEqual=0;
						break;
					}
				}
				
				tempStack.push(isAllEqual);
				
			}
			else if(tempElement.name=="if")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				int c=tempStack.top();
				tempStack.pop();
				
				if(a==1)
				{
					tempStack.push(b);
				}
				else if(a==0)
				{
					tempStack.push(c);
				}
			}
			else if(tempElement.name=="and")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				
				if(a==1 && b==1)
				{
					tempStack.push(1);
				}
				else
				{
					tempStack.push(0);
				}
			}
			else if(tempElement.name=="or")
			{
				int a=tempStack.top();
				tempStack.pop();
				int b=tempStack.top();
				tempStack.pop();
				
				if(a==1 || b==1)
				{
					tempStack.push(1);
				}
				else
				{
					tempStack.push(0);
				}
			}
			else if(tempElement.name=="not")
			{
				int a=tempStack.top();
				tempStack.pop();
				
				if(a==0)
				{
					tempStack.push(1);
				}
				else
				{
					tempStack.push(0);
				}
			}
		}
		/*是數字*/
		else if(tempElement.type==2)
		{
			tempStack.push(tempElement.value);
		}
		/*是參數, 就要從傳進來的參數表找了*/
		else if(tempElement.type==3)
		{
			int paramVal=0;
			int isFind=0;
			for(std::map<std::string, int>::iterator it=functionparams.begin()
				;it!=functionparams.end();it++)
			{
				if((it->first)==tempElement.name){
					paramVal=it->second;
					isFind=1;
					break;
				}
			}
			
			/*沒有從傳進來的參數裡面找到*/
			if(isFind==0)
			{
				/*到global variable裡面找*/
				for(std::map<std::string, variable>::iterator it=globalVar.begin()
					;it!=globalVar.end();it++)
				{
					if((it->first)==tempElement.name){
						if((it->second).Datatype!=3){
							paramVal=(it->second).value;
							isFind=1;
							break;
						}
						else if((it->second).Datatype==3)/*如果找到的是函數*/
						{
							
						}
					}
				}
			}
			
			tempStack.push(paramVal);
		}
	}
	ans=tempStack.top();
	return ans;
}

void checkMatrixMul(int a1, int a2, int a3, int a4, int columnNum)
{
	/*printf("CheckMatrixMul is working\n");*/
	if(a2!=a3){
		printf("Semantic error on col %d\n", columnNum);
		errorFlag=1;
	}
}
