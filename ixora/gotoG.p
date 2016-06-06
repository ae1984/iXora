/* gotoG.p
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
        19.08.2004 dpuchkov - добавил возможность автоматического зачисления платежей на полочки РКО.
        25.08.2004 dpuchkov - временно закоментировал код 
*/

{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".
def var ourbank as cha.
def var sender like ptyp.sender .
def var receiver like ptyp.receiver .

def var s-rko as char. 
def var v-plk as char. 


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
  pause .
   undo .
    return .
    end.
    ourbank = sysc.chval.


{ps-prmt.i}

Message "Вы уверены?" update yn .
do  transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

/*
  if remtrz.source ne "sw" then do:
    Message "Impossible to send . It's for SWIFT only.". pause.
    return.
  end.
*/

if yn then do:
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.


/*
if remtrz.rbank = "TXB00" then do:
   find last aaa where aaa.aaa = remtrz.racc no-lock no-error.
   if avail aaa then do:
     find last cif where cif.cif = aaa.cif no-lock no-error.
       if avail cif then do:
           s-rko = string(integer(cif.jame) mod 1000).
           if s-rko = "1"  then v-plk = "valcon". else
           if s-rko = "2"  then v-plk = "rko-1".  else
           if s-rko = "3"  then v-plk = "rko-23". else
           if s-rko = "4"  then v-plk = "rko-3".  else
           if s-rko = "35" then v-plk = "rko-34". else
           if s-rko = "36" then v-plk = "rko-35".

         message "Установить для платежа полочку: " + v-plk + " ?"   view-as alert-box question buttons yes-no update b as logical.
         if b then
         do:
           s-rko = string(integer(cif.jame) mod 1000).
           if s-rko = "1"  then remtrz.rsub = "valcon". else
           if s-rko = "2"  then remtrz.rsub = "rko-1".  else
           if s-rko = "3"  then remtrz.rsub = "rko-23". else
           if s-rko = "4"  then remtrz.rsub = "rko-3".  else
           if s-rko = "35" then remtrz.rsub = "rko-34". else
           if s-rko = "36" then remtrz.rsub = "rko-35".
         end.
          s-rko = "".
       end.
   end.
end.
*/


if avail que then do:
  que.ptype = remtrz.ptype . 
  que.pid = m_pid.
  que.rcod = "0" .
  v-text = " Отсылка  " + remtrz.remtrz + " по маршруту , тип = " 
    + remtrz.ptype + " код возврата = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
 release que .
 release remtrz.
end.
end.
 end. /*transaction*/
