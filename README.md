# Compiler_final_project


compler的期末project, 實作minilisp的interpreter

## 完成進度
只做完 basic features 1~8

1. Syntax               Validation Print “syntax error” when parsing invalid syntax       10
2. Print                Implement print-num statement                                     10
3. Numerical            Operations Implement all numerical operations                     25
4. Logical              Operations Implement all logical operations                       25
5. if Expression        Implement if expression                                           8
6. Variable Definition  Able to define a variable                                         8
7. Function             Able to declare and call an anonymous function                    8
8. Named Function       Able to declare and call a named function                         6

|   Feature   | Description |   Points   |
|:--------:|:------:|:-----------:|
|   1. Syntax   |   Validation Print “syntax error” when parsing invalid syntax  |  10  |
|   2. Print  |   Implement print-num statement  |  10  |
| 3. Numerical |   Operations Implement all numerical operations  |  25  |
|  4. Logical  |   Operations Implement all logical operations   | 25 |
|  5. if Expression |  Implement if expression | 8 |
|  6. Variable Definition |   Able to define a variable  |  8  |
|  7. Function |  Able to declare and call an anonymous function  |  8  |
|   8. Named Function  |   Able to declare and call a named function  |  6  |


## make file 用法
./compile_make xx.l xx.y yy

yy是生成的執行檔



## stack運行方式


https://www.geeksforgeeks.org/evaluation-prefix-expressions/


## Grammar Overview

<pre><code>PROGRAM ::= STMT +

STMT ::= EXP | DEF-STMT | PRINT-STMT

PRINT-STMT ::= print-num EXP | print-bool EXP

EXP ::= bool-val | number | VARIABLE | NUM-OP | LOGICAL-OP | FUN-EXP | FUN-CALL | COND-EXP

NUM-OP ::= PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER | SMALLER | EQUAL
      
         PLUS ::= (+ EXP EXP + )

         MINUS ::= (- EXP EXP)
       
         MULTIPLY ::= ( * EXP EXP + )
       
         DIVIDE ::= (/ EXP EXP)
       
         MODULUS ::= (mod EXP EXP)
       
         GREATER ::= (> EXP EXP)
       
         SMALLER ::= (< EXP EXP)
       
         EQUAL ::= (= EXP EXP + )
       
LOGICAL-OP ::= AND-OP | OR-OP | NOT-OP

         AND-OP ::= (and EXP EXP + )

         OR-OP ::= (or EXP EXP + )
       
         NOT-OP ::= (not EXP)
       
DEF-STMT ::= (define VARIABLE EXP)

         VARIABLE ::= id
         
FUN-EXP ::= (fun FUN_IDs FUN-BODY)
        
        FUN-IDs ::= (id*)

        FUN-BODY ::= EXP

        FUN-CALL ::= (FUN-EXP PARAM*) | (FUN-NAME PARAM*)

        PARAM ::= EXP
        
        LAST-EXP ::= EXP

        FUN-NAME ::= id

IF-EXP::= (if TEST-EXP THAN-EXP ELSE-EXP)

        TEST-EXP ::= EXP

        THEN-EXP ::= EXP

        ELSE-EXP ::= EXP
</code></pre>
