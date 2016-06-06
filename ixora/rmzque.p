/* rmzque.p
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

def new shared var ee5 as cha initial "2" .
{lgps.i}
def shared var s-remtrz like remtrz.remtrz .
find first remtrz where remtrz.remtrz = s-remtrz no-lock .
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
if not avail que then do :

  v-text = "Создан платеж = " + remtrz.remtrz + " Тип=" + 
  remtrz.ptype + " " +  remtrz.scbank + " " +  remtrz.dracc + " " + 
  remtrz.rcbank + " " +  remtrz.cracc + " " +
  string(remtrz.amt) .
  run lgps.
  create que.
  que.remtrz = remtrz.remtrz.
  que.pid = m_pid.
  remtrz.remtrz = que.remtrz .
  que.ptype = remtrz.ptype.
  que.rcod = "99".
  que.con = "W".
  que.dp = today.
  que.tp = time.
  que.df = today.
  que.tf = time.
  que.dw = today.
  que.tw = time.
  que.pvar = " , , , , ,".
  que.pri = 29999 .

end.
else
do :
  que.ptype = remtrz.ptype .
  que.rcod = "99" .
  que.dp = today.
  que.tp = time.
  que.dw = today.
  que.tw = time.
   v-text = "Изменен платеж = " + remtrz.remtrz + " Тип=" +
   remtrz.ptype + " " +  remtrz.scbank + " " +  remtrz.dracc + " " +
   remtrz.rcbank + " " +  remtrz.cracc + " " +
   string(remtrz.amt) .
   run lgps.
  
  /*
   que.pri = ( 4 - lookup(v-priory , prilist )) * 10000 - 1 .
  */
end .
