/* p905txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        p905_ps.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        31.08.2011 aigul
 * BASES
        TXB
 * CHANGES
*/

def input parameter p-remtrz as char.
def var oldpid like txb.que.pid .
def var oldpri like txb.que.pri .
def var nparpri as cha .
def var nparpid as cha .
def var v-que as char.
find first txb.que where txb.que.remtrz = p-remtrz and txb.que.pid = "F" exclusive-lock no-error.
if avail txb.que then do:
    oldpri = txb.que.pri.
    oldpid = txb.que.pid.
    nparpri = substr(txb.que.npar,1,17).
    nparpid = substr(txb.que.npar,18).
    txb.que.pid = "31".
    txb.que.df = today .
    txb.que.tf = time .
    nparpri = " Last PRI = " + string(oldpri,"zzzz9") .
    nparpid = " Last PID = " + string(oldpid) .
    txb.que.npar = nparpri + nparpid .
    v-que =  txb.que.pid.
end.
find first txb.que where txb.que.remtrz = p-remtrz no-lock no-error.






