/* pack_sync1.p
 * MODULE
        Администрирование АБПК
 * DESCRIPTION
        Разрешение / Запрещение использования пунктов меню
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/08/2007 madiyar
 * BASES
        bank,txb
 * CHANGES
        19/09/2007 madiyar - забыл убрать отладочные сообщения
        07/02/2008 madiyar - изменилась переменная propath для триггеров
*/

def input parameter v-ofc like txb.ofc.ofc.

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
if s-ourbank = "txb00" then return.

def var v-propath as char no-undo.
v-propath = propath.
propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.

do transaction:
for each txb.sec where txb.sec.ofc = v-ofc:
    delete txb.sec.
end.
end.

/*
message v-ofc + ' ' + s-ourbank + " 1111111" view-as alert-box buttons ok.
*/

do transaction:
for each bank.sec where bank.sec.ofc = v-ofc no-lock:
    create txb.sec.
    buffer-copy bank.sec to txb.sec.
end.
end.

/*
message v-ofc + ' ' + s-ourbank + " 2222222" view-as alert-box buttons ok.
*/

propath = v-propath no-error.
