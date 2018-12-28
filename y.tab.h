/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 15 "final_project.y" /* yacc.c:1909  */

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

#line 65 "y.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INUMBER = 258,
    number = 259,
    id = 260,
    boolval = 261,
    andop = 262,
    define = 263,
    ifop = 264,
    lambda = 265,
    mod = 266,
    notop = 267,
    orop = 268,
    printnum = 269,
    printbool = 270
  };
#endif

/* Value type.  */


extern YYSTYPE yylval;

int yyparse (void);
/* "%code provides" blocks.  */
#line 39 "final_project.y" /* yacc.c:1909  */

	void checkMatrixMul(int a1, int a2, int a3, int a4, int columnNum);

#line 99 "y.tab.h" /* yacc.c:1909  */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
