/* pointrp.p
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
        15/03/12 id00810 - добавила v-bankname для печати
        04/05/2012 evseev - наименование банка из banknameDgv
*/


{global.i}

def var return_choice as logical.
def var v-bankname    as char no-undo.

    MESSAGE "Сформировать отчет?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Отчет по СПФ" UPDATE return_choice.

      if return_choice then do:
        find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
        if avail sysc then v-bankname = sysc.chval.
output to rkolist.img.

put unformatted "СПФ и кассы АО " v-bankname  skip.
put fill("=",78) format "x(78)" skip.
put unformatted "Код       ARP              Наименование" skip.
put fill("=",78) format "x(78)" skip.

for each ppoint no-lock.

find first depaccnt where depaccnt.depart = ppoint.depart no-lock no-error.
if avail depaccnt then do:
put unformatted depaccnt.depart "   -   " depaccnt.accnt "    -   " ppoint.name skip.
put fill("-",78) format "x(78)" skip.
end.

end.
output close.

run menu-prt ('rkolist.img').

      end.













