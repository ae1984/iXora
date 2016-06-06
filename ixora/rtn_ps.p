/* rtn_ps.p
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
def buffer rmz2 for que .
def var t-i as int .
def var v-jh like jh.jh . 
 for each que where que.pid = "WSN" and que.con = "W"
   use-index fprc  exclusive-lock .
  find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
  if remtrz.info[4] ne "" then do:
   v-jh = integer(remtrz.info[4]) no-error . 
   if not error-status:error then do:
    find first jh where jh.jh = integer(remtrz.info[4]) no-lock no-error .
    if avail jh and jh.sts = 6  then do:
      que.dw = today.
      que.tw = time.
      que.pid = "F" .
      que.dp = today.
      que.tp = time.
      que.con = "w".
      v-text = "Платеж до востребования " + que.remtrz +
      " обработан програмой закрытия дня  " .
      run lgps .
      next . 
    end.
   end.
  end.
  t-i = index(remtrz.info[3],"3f:") .
  t-i = integer(substr(remtrz.info[3],t-i + 3,
    index(remtrz.info[3],"^",t-i) - t-i - 3 )) .
  if t-i <= today - remtrz.valdt1 then do :
   if substr(remtrz.ref,12) begins "SNIP p" then do :
    if remtrz.ref begins "single" then do :
     que.dw = today.
     que.tw = time.
     que.pid = "RTN" .
     que.dp = today.
     que.tp = time.
     que.con = "w".
     v-text = " Невостребованный " + string(t-i) + 
      " дней платеж до востребования " + que.remtrz + 
       " -> RTN программой закрытия дня " .
     run lgps .
    end .
    else do :
     find first rmz2 where rmz2.pid = "WSN" and rmz2.con = "W" and rmz2.remtrz
       = substr(remtrz.ref,1,10) exclusive-lock no-error .
     if avail rmz2 then do :
      rmz2.dw = today.
      rmz2.tw = time.
      rmz2.pid = "RTN" .
      rmz2.dp = today.
      rmz2.tp = time.
      rmz2.con = "w".
      que.dw = today.
      que.tw = time.
      que.pid = "RTN" .
      que.dp = today.
      que.tp = time.
      que.con = "w".
      v-text = " Невостребованный " + string(t-i) +
              " дней платеж до востребования " + que.remtrz +
              " и " + rmz2.remtrz +
              " -> RTN программой закрытия дня " .
      run lgps .
     end .
    end .
   end .
  end.
 end.
