/* tdasethold.p
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

def input parameter vaaa as char.
def input parameter vamt as deci.
def shared var g-today as date.
def shared var g-ofc as char.
def var vln as inte initial 7777777.

if vamt <= 0 then return.
do transaction:
 find aaa where aaa.aaa = vaaa exclusive-lock no-error.
 if not available aaa then return.
 find aas where aas.aaa = vaaa and aas.ln = vln exclusive-lock no-error.
 if not available aas then create aas.
 aas.chkdt = g-today.
 aas.regdt = g-today.
 aas.expdt = aaa.expdt.
 aas.whn = today.
 aas.who = g-ofc.
 aas.tim = time.
 aas.ln = vln.
 aas.aaa = aaa.aaa.
 aas.sic = "HB".
 aas.chkamt = aas.chkamt + vamt.
 aas.payee = "Срочный депозит - TDA".
 aaa.hbal = aaa.hbal + vamt.
end.
