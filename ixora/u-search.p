/* u-search.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical format "Да/Нет".
{lgps.i }
/*
m_pid = "I" .

u_pid = "inw_Icps".
v-option = "rmzinwc".
  */
def new shared var v-crc like remtrz.tcrc.
def new shared var v-amt like remtrz.payment.
def new shared var v-acc like remtrz.cracc.
def new shared var v-ref like remtrz.sqn format "x(20)".
def shared var s-remtrz like remtrz.remtrz.
def var v-sname like cif.sname.
def var v-sbank like remtrz.sbank init "Все".
def var pr as log format "Да/Нет".
def var pri as int.
def var ans as log format "Да/Нет".
def var i as integer.
def new shared temp-table wrem
    field remtrz like remtrz.remtrz
    field sbank like remtrz.sbank
    field ref like remtrz.ref
    field ofc like remtrz.rwho
    field sname like cif.sname.

def var v-lb as char.
def frame remz v-sbank label "БанкО" with side-label centered row 14 .
def frame remz1 v-sbank label "БанкО" with side-label centered row 14 .

find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then do:
   Message  "Отсутствует запись OURBNK в таблице SYSC!". pause  . 
   return.
end.
v-lb = trim(sysc.chval).

form skip v-crc label "Валюта К."
  skip v-amt label "Сумма К."
  skip v-acc label "Счет К." skip 
  with frame rmzc  side-label row 5  centered .
 pr = no.
 ans = no.
 for each wrem :
  delete wrem.
 end.
 i = 0.


 
 update v-crc validate (can-find (crc where crc.crc = v-crc), "" )
        v-amt
        v-acc with frame rmzc .
 if v-acc ne "" then do:

    find first aaa where aaa.aaa = v-acc no-lock no-error.
    find first dfb where dfb.dfb = v-acc no-lock no-error.
    
    if not available aaa and not avail dfb then do :
      Message "Неправильный счет!". pause.
      undo, retry.
    end.

    find cif where cif.cif = aaa.cif no-lock no-error.
    if available cif then v-sname = trim(trim(cif.prefix) + " " + trim(cif.sname)).

    i = 0.
    pri = 0.
  
 for each remtrz where remtrz.amt = v-amt and remtrz.cracc = v-acc
     no-lock :
/*  
  for each que where que.con = "W" and que.pid = m_pid no-lock :
  find first remtrz where remtrz.remtrz = que.remtrz no-lock.
  */
  find first  que of remtrz no-lock .
       if not(que.con = "W" and que.pid = m_pid ) then next .
        
  if string(remtrz.dracc) = trim(sysc.chval) and remtrz.fcrc = v-crc 
   and remtrz.amt = v-amt and remtrz.cracc = v-acc then do :  
   if pri = 0 then do:
      update v-sbank with frame remz .
      find first bankl where substr(bankl.bank,7,3) = v-sbank no-lock no-error.
   if not avail bankl then
         find first bankl where bankl.bank = trim(v-sbank) no-lock no-error.
      if not avail bankl then do :
        Message "Неправильный код банка!". pause.
        undo, retry.
      end.
      if trim(v-sbank) ne "170" then
      v-sbank = bankl.bank. 
      display v-sbank with frame remz. 
      pause 0.
      pri = 1.
   end.
  end.  

  if remtrz.fcrc = v-crc and remtrz.amt = v-amt and remtrz.cracc = v-acc
   and (remtrz.sbank = v-sbank or v-sbank = "Все")
   then do :
      create wrem.
      wrem.remtrz = remtrz.remtrz.
      wrem.sbank = remtrz.sbank.
      wrem.ref = substr(remtrz.sqn,19).
      if avail cif then wrem.sname =  trim(trim(cif.prefix) + " " + trim(cif.sname)).
      else if avail dfb then 
      wrem.sname = dfb.name . 
      wrem.ofc = remtrz.rwho.
      i = i + 1.
   end.
  end.
 end.


 else do :
  update v-ref label "Nr." with frame rmzr side-label row 10 centered.
  
  v-ref = trim(v-ref).
  display v-ref with frame rmzr side-label row 10 centered.
  
  pri = 0.
  for each que where que.con = "W" and que.pid = m_pid no-lock :
  find first remtrz where remtrz.remtrz = que.remtrz no-lock.


  if string(remtrz.dracc) = v-lb and remtrz.fcrc = v-crc and remtrz.amt = v-amt
   and remtrz.cracc = "" and substr(remtrz.sqn,19) = v-ref then do :
   if pri = 0 then do :
    update v-sbank with frame remz1.
    find first bankl where substr(bankl.bank,7,3) = v-sbank no-lock no-error.
   if not avail bankl then
         find first bankl where bankl.bank = trim(v-sbank) no-lock no-error.
    if not avail bankl then do :
       Message "Неправильный код банка!". pause.
       undo, retry.
    end.
    if trim(v-sbank) ne "170" then
    v-sbank = bankl.bank.
    display v-sbank with frame remz1.
    pause 0.
    pri = 1.
   end.
  end.

   if remtrz.fcrc = v-crc and remtrz.amt = v-amt and remtrz.cracc = ""
     and substr(remtrz.sqn,19) = v-ref and (remtrz.sbank = v-sbank or 
     v-sbank = "Все") 
   then do :
      create wrem.
      wrem.remtrz = remtrz.remtrz.
      wrem.sbank = remtrz.sbank.
      wrem.ref = substr(remtrz.sqn,19).
      wrem.ofc = remtrz.rwho.
      i = i + 1.
   end.
  end.
 end.

  if i = 0 then do :
    Message "Платеж не найден!". pause.
    undo, retry.
  end.
  if i = 1 then s-remtrz = wrem.remtrz.
  if i > 1 then run rml.
/*
 find first wrem where wrem.remtrz = s-remtrz no-lock.
 */
 hide frame remz .
 hide frame remz1 .
 hide frame rmzr .
 hide frame rmzc .
 /* frame-value = s-remtrz . */  
