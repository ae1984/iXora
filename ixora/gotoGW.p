/* gotoGW.p
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

{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".
def var ourbank as cha . 
def var sender like ptyp.sender .
def var receiver like ptyp.receiver .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBANK в таблице SYSC!".
  pause .
   undo .
    return .
    end.
    ourbank = sysc.chval.


{ps-prmt.i}

Message "Вы уверены?" update yn .
do  transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if yn then do  :
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if avail que then do :

  que.ptype = remtrz.ptype . 
  que.pid = m_pid.
  que.rcod = "3" .
  v-text = " Отсылка ->GW " + remtrz.remtrz + " тип=" + remtrz.ptype +
     " по маршруту , код возврата = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
 release que .
 release remtrz.
end.
end .
 end. /*transaction*/
