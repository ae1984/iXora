/* TRAN_ps.p
 * MODULE
        Название модуля - Автоматический перевод остатков (Кар-Тел)
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def new shared var v-aaa1    as char init "KZ11470172203A378716". /*Счет для списания*/
def new shared var v-aaa2    as char init "KZ73470172203A360916". /*Счет для зачисления*/

def var v-time as char.

v-time = string(time, "HH:MM:SS").

if v-time >= "15:50:00" and v-time <= "16:00:00" then do:
    if connected ("txb") then disconnect "txb".
    for each txb where txb.is_branch and txb.consolid and txb.bank = "TXB16" no-lock:
        if connected ("txb") then  disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).
        run TRANS_ps2.
        disconnect "txb".
    end.
end.
