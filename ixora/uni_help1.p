/* uni_help1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

def  shared var g-lang as char.
def buffer b_codfr for codfr.
def input parameter s-codfr as char.
def input parameter codemask as char. 
def var codific-name as char.
def var v-name as char.

find first codific where codific.codfr = s-codfr no-lock no-error.
if available codific then codific-name = codific.name. 
 
{jabro.i

&start     =  " "
&head      =  "codfr"
&headkey   =  "codfr"
&index     =  "codfr_idx"
&formname  =  "uni_help1"
&framename =  "uni_help1"
&where     =  " codfr.codfr = s-codfr and codfr.child = false 
            and codfr.code <> 'msc' and codfr.code matches codemask"
&addcon    =  "false"
&deletecon =  "false"
&predelete =  " " 
&precreate =  " "
&postadd   =  " "
&prechoose =  " "
&predisplay = " v-name = codfr.name[1] + codfr.name[2] + codfr.name[3]. "
&display   =  " codfr.code v-name "
&highlight =  "codfr.code"
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    if codfr.child = true then do:
                       message 'Illegal code !'.
                       bell. bell. bell.
                       pause 3.
                       next inner.
                    end.   
                    frame-value = codfr.code.
                    leave upper.
                end."
&end =        " hide frame uni_help1."
}
 

