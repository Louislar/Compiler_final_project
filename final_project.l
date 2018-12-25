%{
#include "y.tab.h"
int column=0;
%}


%%/*yyleng是你傳入的token的長度*/
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
	printf("Lex number\n");
	return number;
}

[a-z]([a-z]|[0-9]|'-')* {
	column=column+yyleng;
	printf("Lex ID\n");
	return id;
}

"#"t|"#"f {
	column=column+yyleng;
	printf("Lex boolval\n");
	return boolval;
}


"("|")"|"+"|"-"|"*"|"/"|"<"|">" {
	column=column+yyleng;
	printf("Lex %c\n", yytext[0]);
	return yytext[0];
}


\n                 {printf("Lex linefeed\n");/*EOF*/}
[\t]+              {/* Do nothing */}
[ ]+			   {printf("Lex blank\n");/*遇到空格, 也要加一個column, 因為空格也算一行*/column=column+yyleng;}
.                  {printf("Lex .\n");/*printf("current line: %d\n", column);printf("Got %c\n", yytext[0]);*/return(yytext[0]);}
%%