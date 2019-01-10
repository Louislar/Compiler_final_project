# Compiler_final_project


compler的期末project, 實作minilisp的interpreter(smli)

## 完成進度
只做完 basic features 1~8

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
