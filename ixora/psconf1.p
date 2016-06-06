/* psconf1.p
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

def var oldvaldt as date .
def var exitcod as cha .
def var r-new like bank.remtrz.remtrz .
def var r-old like bank.remtrz.sqn .
def var v-sqn as cha .
def var buf as cha extent 100 .
def var i as int . 
def shared var v-weekbeg as int.
def shared var v-weekend as int.
def new shared var srm-remtrz like shtbnk.remtrz.remtrz .
def shared var s-remtrz like bank.remtrz.remtrz . 
def stream send .
def shared var g-today as date . 
def var acode as cha . 
def var v-reterr as int . 
{lgps.i}
do transaction :
    find first bank.que where bank.que.remtrz = s-remtrz exclusive-lock no-wait no-error.
    if not avail que then return.
    find first bank.remtrz of bank.que exclusive-lock.

    bank.que.dw = today.
    bank.que.tw = time.
/*  bank.que.con = "P".   */
    find first shtbnk.remtrz where shtbnk.remtrz.sbank = bank.remtrz.sbank
                             and shtbnk.remtrz.sqn begins substr(bank.remtrz.sqn,1,5) + "." + substr(bank.remtrz.remtrz,1,10)
                             no-lock no-error.
    if not avail shtbnk.remtrz then return.
    find first shtbnk.que where shtbnk.que.remtrz = shtbnk.remtrz.remtrz no-lock.
    if (shtbnk.remtrz.jh2 eq ? or shtbnk.remtrz.jh2 = 0) and (shtbnk.que.pid <> "STW" and shtbnk.que.pid <> "SWS") then return.
    v-text = bank.remtrz.remtrz + " REMOTE " + shtbnk.remtrz.remtrz + " <- подтверждение.".
    
    if shtbnk.remtrz.jh2 ne ? then
        v-text = v-text + " Найдена 2 проводка " + string(shtbnk.remtrz.jh2).
    else if shtbnk.que.pid = "STW" or shtbnk.que.pid = "SWS" then
        v-text = v-text + " Платеж отправлен " + (
                 if index(shtbnk.que.npar, "Last PID = SG") > 0 then "SWIFT" else
                 if index(shtbnk.que.npar, "Last PID = LB") > 0 then "клирингом" else
                 if index(shtbnk.que.npar, "Last PID = LBG") > 0 then "гроссом" else ""
                 ) + ".".
        run lgps.
        bank.que.dp = today.
        bank.que.tp = time.
        bank.que.con = "F".
        bank.que.rcod = "0".
end. 

