/* v-que.p
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

def buffer tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.
def var oldpid like que.pid .
def var prilist as cha.
def var oldpri like que.pri .
def var nparpri as cha .
def var nparpid as cha .
/*
def shared frame remtrz.
  */
{global.i}
{ps-prmt.i}
{lgps.i}

/*
{rmz.f}
*/

def shared var s-remtrz like que.remtrz.

find first que where que.remtrz = s-remtrz no-lock .
/*
display que.remtrz que.ptype pid rcod pvar npar format "x(35)" con pri 
rcid format "zzzzzzz9" 
string(df)  + " " + string(tf,"hh:mm:ss") format "x(20)" label "LastF"
string(dp)  + " " + string(tp,"hh:mm:ss") format "x(20)" label "LastP"
string(dw)  + " " + string(tw,"hh:mm:ss") format "x(20)" label "LastW"
with 1 col no-hide overlay row 3 column 10  frame qqq .
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



if  (m_pid = "ps_" or m_pid = "I" or m_pid = "3" ) and que.con = "W" then
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
 display que.npar with frame qqq .
/*
 update
    que.pid    
   que.pri validate (que.pri > 0 and que.pri < 30000,
   "  0 < PRIORITY < 30000 "  ) with frame qqq .
     */
 if frame qqq que.pri entered then do :
     v-text = s-remtrz + " Priority was changed : " + string(oldpri) + " -> " +
     string(que.pri) .
     run lgps.
     nparpri = " Last PRI = " + string(oldpri,"zzzz9") .
 /*    que.df = today .
     que.tf = time .
   */
find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  display " Нет записи PRI_PS в sysc файле !".
  pause .
  release que.
  undo , return .
end.
prilist = sysc.chval.
/*
v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
display v-priory with frame remtrz .
pause 0 .
*/
end.

 if frame qqq que.pid entered then do:
     que.pid = CAPS(que.pid) .
     v-text = s-remtrz + " Маршрут изменен  : " + string(oldpid) + " -> " +
     string(que.pid) .
     run lgps.
     que.df = today .
     que.tf = time .
     nparpid = " Last PID = " + string(oldpid) .
   end.
  que.npar = nparpri + nparpid .
release que .
end.
