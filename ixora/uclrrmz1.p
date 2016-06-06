/* uclrrmz1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def input parameter vwho as char .
def shared var s-datt as date.
def shared var s-num like clrdoc.pr.
def new shared var s-remtrz like remtrz.remtrz.
def shared var vsum as deci.
def shared var nsum as deci format "zzz,zzz,zzz,zzz.99".

def shared temp-table oree
    field npk as inte format "zz9"
    field cwho as char format "x(8)"
    field quo as inte format "zzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".

def shared temp-table roree
    field remtrz as char format "x(10)"
    field cwho as char format "x(8)"
    field racc as char format "x(10)"
    field amt as deci index iroree amt.


{global.i}
{uclrdoc.f}
{jabra.i
&start = " "
&head = "roree"
&headkey = "amt" 
&index = "iroree"
&where = "roree.cwho = vwho"
&formname = "uclrdoc1"
&framename = "uclrdoc1"
&addcon = "false"
&deletecon = "false"
&prechoose = "
message 
'1-история; F4 - выход'.
"
&predelete = " "
&predisplay = " "
&display = "roree.remtrz roree.racc roree.amt"
&highlight = "roree.remtrz roree.racc roree.amt"
&postcreate = " "
&postdisplay = " "
&postadd = " "
&postkey = "else if keyfunction(lastkey) = '1' then do:
                 s-remtrz = roree.remtrz .
                 run rmzhis.
                 view frame uclrdoc .
                 pause 0 . 
                 view frame uclrdoc1.
            end."
&end = "hide frame uclrdoc1." 
}
