#!/bin/bash
if (("$#" < 2)) || (("$#" > 3)); then
    echo "Illegal number of arguments"
    exit 1
fi
bison -v -d -o "y.tab.c" $2
g++ -c -g -I.. "y.tab.c"
flex -o lex.yy.c $1
g++ -c -g -I.. lex.yy.c
if [ "$#" -eq 2 ]; then
    g++ -o a.out "y.tab.o" lex.yy.o -ll
elif [ "$#" -eq 3 ]; then
    g++ -o $3 "y.tab.o" lex.yy.o -ll -lm
fi
