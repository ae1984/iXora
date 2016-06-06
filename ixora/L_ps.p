/* L_ps.p
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

{lgps.i}

def buffer b-log for logfile.
find first sysc where sysc.sysc = "PS_LOG" no-lock no-error .

if not avail sysc then  return .

for each b-log no-lock use-index dttm break by dattim  .
/* if b-log.dattim = "" then next .  */
 if first(b-log.dattim) then
   output to value(trim(sysc.chval) + "/" + m_hst + "_logfile.lg." +
   string(date(substr(b-log.dattim,1,8)),"99.99.9999") ) append.
 if b-log.dattim = "" then next .
 do transaction :
 find first logfile where recid(logfile) = recid(b-log) 
  exclusive-lock no-wait no-error .
  if not avail logfile then next . 
   put unformatted logfile.dattim + " " + logfile.mess skip .
   delete logfile .
/*   if last-of(b-log.dattim) then  output close .  */
  release logfile . 
 end.
end.
output close.
