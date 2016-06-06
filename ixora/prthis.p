/* prthis.p
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
 	29/08/06 u00121 заменил nawk на awk
*/



 def var df as date . 
 def var dt as date .
 def shared var s-remtrz like remtrz.remtrz .
 def var v-hst as cha.
 def var v-log as cha.
 find sysc where sysc.sysc = "ourbnk" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
  display "Отсутствует запись OURBNK в таблице SYSC!".
  pause .
  undo .
  return .
 end.
s-remtrz = caps(s-remtrz) . 
v-hst = trim(sysc.chval).
 find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
  display "Отсутствует запись PS_LOG в таблице SYSC!".
  pause .
  undo .
  return .
 end.

  v-log = trim(sysc.chval).

  display "Ж Д И Т Е !" with centered frame www . pause 0 .
  output to tmp_ps.img .
  run rmz-view.
  output close .

  find first remtrz where remtrz.remtrz = s-remtrz no-lock . 
  find first que where que.remtrz = s-remtrz no-lock .
  df = remtrz.rdt . 
  dt = que.df .
  if que.dp > dt then dt = que.dp.
  if que.dw > dt then dt = que.dw.


  repeat :
   if df > dt then leave . 
   if    search(v-log + trim(v-hst) + "_logfile.lg." +
      string(df,"99.99.9999")) =
    v-log + trim(v-hst) + "_logfile.lg." + string(df,"99.99.9999") then 
   unix silent value("awk 'index($0,""" + s-remtrz + """) != 0 \{print $0\}' "
   + v-log + trim(v-hst) + "_logfile.lg." + string(df,"99.99.9999") +
   " >>  tmp_ps.img " ). /*29/08/06 u00121 заменил nawk на awk*/
   hide frame www.
   df = df + 1 . 
  end . 
  pause 0 .
  unix prit tmp_ps.img.
  pause 0 . 

