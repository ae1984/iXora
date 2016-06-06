/* psrconf1.p
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
def var r-new like shtbnk.remtrz.remtrz .
def var r-old like shtbnk.remtrz.sqn .
def var v-sqn as cha .
def var buf as cha extent 100 .
def var i as int . 
def shared var v-weekbeg as int.
def shared var v-weekend as int.
def new shared var srm-remtrz like bank.remtrz.remtrz .
def shared var s-remtrz like shtbnk.remtrz.remtrz . 
def stream send .
def shared var g-today as date . 
def var acode as cha . 
def var v-reterr as int . 
{lgps.i}
do transaction :
 find first shtbnk.que where shtbnk.que.remtrz = s-remtrz exclusive-lock 
  no-wait no-error.
 if not avail que then return . 
  find first shtbnk.remtrz of shtbnk.que exclusive-lock . 

  shtbnk.que.dw = today.
  shtbnk.que.tw = time.
/*  shtbnk.que.con = "P".   */
  find first bank.remtrz where bank.remtrz.sbank = shtbnk.remtrz.sbank
    and bank.remtrz.sqn begins 
    substr(shtbnk.remtrz.sqn,1,5) + "." + 
    substr(shtbnk.remtrz.remtrz,1,10) no-lock no-error.
    if not avail bank.remtrz then return .
    find first bank.que where bank.que.remtrz = bank.remtrz.remtrz
    no-lock.
    if (bank.remtrz.jh2 eq ? or bank.remtrz.jh2 = 0) and 
    (bank.que.pid <> "STW" and bank.que.pid <> "SWS") then return .
  v-text = shtbnk.remtrz.remtrz + " REMOTE " + bank.remtrz.remtrz +
  " <- подтверждение.".
  if bank.remtrz.jh2 ne ? then 
   v-text = v-text  +  
   " Найдена 2 проводка " + string(bank.remtrz.jh2).
  else if bank.que.pid = "STW" or bank.que.pid = "SWS" then
    v-text = v-text +
    " Платеж отправлен " +
    (
    if index(bank.que.npar, "Last PID = SG") > 0 then "SWIFT" else
    if index(bank.que.npar, "Last PID = LB") > 0 then "клирингом" else
    if index(bank.que.npar, "Last PID = LBG") > 0 then "гроссом" else ""
    ) + ".".
   
   run lgps-r.
   shtbnk.que.dp = today.
   shtbnk.que.tp = time.
   shtbnk.que.con = "F".
   shtbnk.que.rcod = "0".
end. 

