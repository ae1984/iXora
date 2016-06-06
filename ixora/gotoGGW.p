/* gotoGGW.p
 * MODULE
    Сверка с выпиской
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
        09.09.2004 tsoy  
 * CHANGES
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

def var is_in_stmt as log .

run checkGW (s-remtrz, output is_in_stmt).

if not is_in_stmt then do:
   Message " Платеж не найден в выписках SWIFT ! Продолжить ? " update yn.
   if not yn then return.  
end.


Message "Вы уверены?" update yn .
do  transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if yn then do:
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

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
