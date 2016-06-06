/* clrprn2.p
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

def input parameter vbank as char.
def new shared var s-vbank as char.
def shared var s-datt as date.
def shared var g-today as date.
def shared var s-num like clrdoc.pr.
def shared temp-table ree
    field npk as inte format "zz9"
    field bank as char format "x(3)"
    field bbic like bankl.bic
    field quo as inte format "zzz9"
    field kopa as deci format "zzz,zzz,zzz,zzz.99".
def new shared stream m-doc.

output stream m-doc to maks.doc.
   s-vbank = vbank.
   run mufjsc.
output stream m-doc close.

unix silent prit value("maks.doc").
unix silent /bin/rm -f value("maks.doc").


