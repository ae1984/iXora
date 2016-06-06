/* trxstsdel.p
 * MODULE
        Удаление проводок
 * DESCRIPTION
        Замена статуса при удалении проводок
 * RUN
        jou_main.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        13.05.2005 saltanat 
 * CHANGES
*/
def shared var g-ofc as char.
def input parameter vjh as inte.
def input parameter vsts as inte.
def output parameter rcode as inte initial 100.
def output parameter rdes as char.
def var errlist as char extent 32.


define variable s_payment as character.

errlist[22] = "Can't find transaction for stamp.".
errlist[23] = "Can't stamp cash transaction.".
errlist[32] = "Illegal transaction status.".

if vsts < 0 and vsts > 6 then do:
   rcode = 32.
   rdes = errlist[rcode] + ": sts=" + string(vsts).
   return.
end.
find first jh where jh.jh = vjh no-lock no-error.
if not available jh then do:
   rcode = 22.
   rdes = errlist[rcode] + " " + string(vjh,"zzzzzzz9").
   return.
end.
else do:
end.

do transaction:

find jh where jh.jh = vjh exclusive-lock no-error.
if avail jh then jh.sts = vsts.     
for each jl where jl.jh = vjh exclusive-lock:
     jl.sts = vsts.
     if jl.sts = 6 then jl.teller = g-ofc.
end.
     rcode = 0.

end.
