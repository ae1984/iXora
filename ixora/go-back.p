/* go-back.p
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
        16.06.04 - suchkov - Поправлен формат rcid
*/


{global.i}
{ps-prmt.i}
def var oldpid like que.pid .
def var oldpri like que.pri .
def var nparpri as cha .
def var nparpid as cha .
def var answ as log format "да/нет" . 
 {lgps.i}
def shared var s-remtrz like que.remtrz.
find first que where que.remtrz = s-remtrz no-lock .
display
      que.remtrz label "Платеж"
      que.ptype label "Тип"
      pid label "Код" format 'x(5)'
      rcod label "КодВзвр"
      pvar label "Пар1"
      npar label "Пар2" format "x(35)"
      con label "Сост."
      pri label "Приорит."
      rcid format "zzzzzzzz9"
 string(df)  + " " + string(tf,"hh:mm:ss") format  "x(20)" label "Оконч.Обраб."
 string(dp)  + " " + string(tp,"hh:mm:ss") format "x(20)" label  "НачалоОбраб."
 string(dw)  + " " + string(tw,"hh:mm:ss") format "x(20)" label  "НачалоОжидан."
 with 1 col no-hide overlay row 3 column 10  frame qqq .

if con = "w" and m_pid = "ps_" then
do transaction :
 find first que where que.remtrz = s-remtrz exclusive-lock .
 oldpri = que.pri.
 oldpid = que.pid.
 nparpri = substr(que.npar,1,17).
 nparpid = substr(que.npar,18).
 if nparpri = "" then
    nparpri = " Last PRI = " + string(oldpri,"zzzz9") .
 if nparpid = "" then
    nparpid = " Last PID = " + string(oldpid) .
 que.npar = nparpri + nparpid .
 nparpid = substr(que.npar,30).
 if nparpid = "" then do:
   message " Операция невозможна ! " . pause .
   return .
  end.
 display que.npar with frame qqq .
 message " Вы уверены ? " update answ .

 if answ  then do:
     que.pid = nparpid .
     que.con = "F".
     v-text = s-remtrz + " Маршрут изменен  : "
      + string(oldpid) + " -> " + string(que.pid) + " (F)" .
     run lgps.
     nparpid = " Last PID = " + string(oldpid) .
  que.npar = nparpri + nparpid .
 /*
display que.remtrz que.ptype pid rcod pvar npar format "x(35)" con pri rcid
format "zzzzzzz9"
string(df)  + " " + string(tf,"hh:mm:ss") format "x(20)" label "LastF"
string(dp)  + " " + string(tp,"hh:mm:ss") format "x(20)" label "LastP"
string(dw)  + " " + string(tw,"hh:mm:ss") format "x(20)" label "LastW" with
  frame qqq .
  */

 display
      que.remtrz label "Платеж"
      que.ptype label "Тип"
      pid label "Код"
      rcod label "КодВзвр"
      pvar label "Пар1"
      npar label "Пар2" format "x(35)"
      con label "Сост."
      pri label "Приорит."
      rcid format "zzzzzzzz9"
 string(df)  + " " + string(tf,"hh:mm:ss") format  "x(20)" label "Оконч.Обраб."
 string(dp)  + " " + string(tp,"hh:mm:ss") format "x(20)" label  "НачалоОбраб."
 string(dw)  + " " + string(tw,"hh:mm:ss") format "x(20)" label  "НачалоОжидан."
 with 1 col no-hide overlay row 3 column 10  frame qqq .
 
 end .
release que .
end.
