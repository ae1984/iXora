/* budcodes.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * BASES
          BANK COMM TXB 
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
        04/06/09 id00363
 * CHANGES

*/

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
s-ourbank = trim(txb.sysc.chval).
if s-ourbank = "txb00" then return.



do transaction:
for each txb.budcodes:
    delete txb.budcodes.
end.
end.

/*
message v-ofc + ' ' + s-ourbank + " 1111111" view-as alert-box buttons ok.
*/

do transaction:
for each bank.budcodes no-lock:
    create txb.budcodes.
    buffer-copy bank.budcodes to txb.budcodes.
end.
end.
