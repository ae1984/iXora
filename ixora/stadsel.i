/* stadsel.i
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
        21/10/2003 sasco Вставил no-error в поиск tcommLS
        22/10/2003 sasco Проверка return-value
        21/04/2005 kanat - добавил группировку по type в for each commonls ...
*/

/* Нужно заранее определить var seltxb as integer */

define temp-table tcommLS like commonLS
    field pix as integer.

def var i as integer.
def new shared var selprc  as decimal format "9.9999".
def new shared var selcom  as decimal format ">>>9.99".
def new shared var selbn   as char.
def new shared var selarp  as char format "x(9)".
def new shared var seltown as char.

def var s-sel   as char.
s-sel = ''. 
seltown = comm-txb().
seltxb = comm-cod().
i = 1.

for each commonls where commonls.txb = seltxb and commonls.visible = yes
                  and commonls.grp = selgrp no-lock use-index type break by commonls.arp by type:
    IF FIRST-OF(commonls.arp) and first-of(commonls.type) THEN do:
     create tcommls.
     buffer-copy commonls to tcommLS.
     tcommLS.pix = i.
     i = i + 1. 
     s-sel = s-sel + tcommls.bn + '|'.
   end.
end.

s-sel = substring(s-sel,1, length(s-sel) - 1). /* обрезаем последний символ "|" */

run sel('Укажите организацию',s-sel).

i = ?.
i = integer (return-value) no-error.
if i = ? then do:
   MESSAGE "Не найден АРП счет"
   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
   TITLE "Проблема: Выбор АРП-счета" .
   return.
end.

find first tcommLS where tcommLS.pix = integer(return-value) no-error.
if avail tcommLS then do:
                    selarp = string(integer(tcommLS.arp),"999999999").
                    selprc = tcommLS.comprc.
                    selcom = tcommLS.comsum.
                    selbn  = trim(tcommLS.bn). 
/*                    selgrp = tcommLS.grp.    */
                 end.
                 else do:
                   MESSAGE "Не найден АРП счет"
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                   TITLE "Проблема: Выбор АРП-счета" .
                   return.
                  end. 

selarp = string(integer(selarp),"999999999").

