%{
#include "y.tab.h"
int column=0;
%}


%%/*yyleng是你傳入的token的長度*/
"mod" {
	printf("Lex mod\n");
	return mod;
}

"print-bool" {
	printf("Lex print-bool\n");
	return printbool;
}

"print-num" {
	printf("Lex print-num\n");
	return printnum;
}

"if" {
	printf("Lex if\n");
	return ifop;
}

"define" {
	printf("Lex define\n");
	return define;
}

"lambda" {
	printf("Lex lambda\n");
	return lambda;
}

"and" {
	printf("Lex and-op\n");
	return andop;
}

"or" {
	printf("Lex or-op\n");
	return orop;
}

"not" {
	printf("Lex not-op\n");
	return notop;
}

0|[1-9][0-9]*|-[1-9][0-9]* {
	column=column+yyleng;
	yylval.ival=atoi(yytext);
	yylval.var.value=atoi(yytext);
	yylval.var.Datatype=2;
	printf("Lex number\n");
	return number;
}

[a-z]([a-z]|[0-9]|'-')* {
	column=column+yyleng;
	printf("Lex ID\n");
	return id;
}

"#t"|"#f" {
	column=column+yyleng;
	printf("Lex boolval\n");
	yylval.var.Datatype=1;
	if(yytext[1]=='t')
		yylval.var.value=1;
	else if(yytext[1]=='f')
		yylval.var.value=0;
	printf("Lex bool is %d\n", yylval.var.value);
	return boolval;
}


"("|")"|"+"|"-"|"*"|"/"|"<"|">"|"=" {
	column=column+yyleng;
	printf("Lex %c\n", yytext[0]);
	return yytext[0];
}


\n                 {printf("Lex linefeed\n");/*Not EOF*/}
[\t]+              {/* Do nothing */}
[ ]+			   {printf("Lex blank\n");/*遇到空格, 也要加一個column, 因為空格也算一行*/column=column+yyleng;}
.                  {printf("Lex .\n");/*printf("current line: %d\n", column);printf("Got %c\n", yytext[0]);*/return(yytext[0]);}
%%