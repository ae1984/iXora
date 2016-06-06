/* trx-help1.p
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
def shared var s-codfr as char. 
 
{jabro.i

&start     =  " "
&head      =  "codfr"
&headkey   =  "codfr"
&index     =  "codfr_idx"
&formname  =  "trx-help1"
&framename =  "trx-help1"
&where     =  " codfr.codfr = s-codfr and codfr.child = false"
&addcon    =  "false"
&deletecon =  "false"
&predelete =  " " 
&precreate =  " "
&postadd   =  " "
&prechoose =  " "
&predisplay = " "
&display   =  " (fill(' ', codfr.level - 1) + codfr.code) @ codfr.code codfr.name[1]"
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
&end =        " hide frame trx-help1."
}
 

