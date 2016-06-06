/* chk_pid-txb.p
 * MODULE
        монитор процессов ПС
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
        15.06.2012 evseev
 * BASES
        COMM TXB
 * CHANGES
        22.11.2012 k.gitalov проверка соответствия данных в sts реальному кол-ву платежей в que
*/
define input  parameter v-paramin  as character.

define shared variable s-errpid as character no-undo.


define        variable v-bnk    as character no-undo.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if available txb.sysc then v-bnk = txb.sysc.chval. 
else v-bnk = "Банк не определён!".

for each txb.fproc where txb.fproc.tout <> 1000 no-lock:
    if v-paramin matches "*" + txb.fproc.pid + "*" then next.
    find first txb.dproc where txb.dproc.pid = txb.fproc.pid no-lock no-error.
    if not available txb.dproc then 
    do:
        if s-errpid <> "" then s-errpid = s-errpid + "~n".
        s-errpid = s-errpid + v-bnk + "   " + string(txb.fproc.pid, "x(6)") + "   " + string(txb.fproc.tout,"9999999") + "   --------    процесс не работает!   " + txb.fproc.des.
    end. 
    else 
    do:
        if dproc.l_time <> 0 and
            ((txb.fproc.tout <> 77777 and (time - txb.dproc.l_time > txb.fproc.tout + 600)) or
            (txb.fproc.tout =  77777 and txb.dproc.hst <> "wait" and time - txb.dproc.l_time > 600))  then 
        do:
            if s-errpid <> "" then s-errpid = s-errpid + "~n".
            s-errpid = s-errpid + v-bnk + "   " + string(txb.fproc.pid, "x(6)") + "   " + string(txb.fproc.tout,"9999999") + "   " + string(time - dproc.l_time,"hh:mm:ss") + "    процесс завис!         " + txb.fproc.des + "     " + txb.dproc.hst.
        end.
    end.
end.

/***************************************************************************************************/
/* k.gitalov */
function GetCount returns integer( input PID as character).
    define variable iCount as integer init 0.
    for each txb.que where txb.que.pid = PID and txb.que.con = "W" use-index fprc no-lock:
        iCount = iCount + 1.
    end.
    return iCount.    
end function.

for each txb.sts where txb.sts.pid <> "F" and txb.sts.pid <> "ARX" no-lock:
    define variable qCount as integer init 0.
    qCount = GetCount(txb.sts.pid).
    if txb.sts.nw <> qCount then 
    do:
        if s-errpid <> "" then s-errpid = s-errpid + "~n".
        s-errpid = s-errpid + v-bnk + "   " + txb.sts.pid + "    sts = " + string(txb.sts.nw) + "   que = " + string(qCount) + "   --------    несоответствие данных!   ".
    end.
end.
/***************************************************************************************************/

     