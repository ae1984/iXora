/* functions-def.i
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

/*
    13.01.2000
    functions-def.i
    Заголовки функций...
    Пропер С.В.
*/

def var hFirstLine as handle.
def var hPadl      as handle.
def var hPadr      as handle.
def var hPadc      as handle.

function FirstLine returns char (
         input n1 as integer, 
         input n2 as integer ) in hFirstLine.
function padl returns char (
         input c1 as char, 
         input n2 as integer, 
         input c3 as char ) in hPadl.
function padr returns char (
         input c1 as char, 
         input n2 as integer, 
         input c3 as char ) in hPadr.
function padc returns char (
         input c1 as char, 
         input n2 as integer, 
         input c3 as char ) in hPadc.

run firstline persistent set hFirstLine.
run padl      persistent set hPadl.
run padr      persistent set hPadr.
run padc      persistent set hPadc.

/***/