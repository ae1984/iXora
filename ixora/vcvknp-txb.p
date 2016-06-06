/* vcvknp-txb.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Синхронизация таблицы codfr с филиалами
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
        26/05/2011 dmitriy
 * CHANGES
        19/12/2012 madiyar - полная синхронизация справочника
*/

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

if s-ourbank = "txb00" then return.

do transaction:
    for each txb.codfr where txb.codfr.codfr = 'spnpl' exclusive-lock:
        delete txb.codfr.
    end.
    for each bank.codfr where bank.codfr.codfr = 'spnpl' no-lock:
        create txb.codfr.
        buffer-copy bank.codfr to txb.codfr.
    end.
end.
