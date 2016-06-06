/* 1_ps.p
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
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def var r-sqn like remtrz.remtrz . 
 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Нет записи M-DIR в sysc файле " .  run lgps.
  return .
 end.


 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".
   /*
    v-text = "I start process ... " +  que.remtrz .  run lgps.
   */
   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   /*  Beginning of main program body */
  r-sqn = substr(remtrz.sqn,7,10) . 
  output to value( sysc.chval + "/" + r-sqn + ".cnf") .

  find crc where crc.crc = remtrz.fcrc no-lock no-error.

  put unformatted
  "\{1:xxxXXXXXXXXXXXXxxxxXXXXXX\}\{2:E10CXXXXXXXXXXXXxXxxx\}\{4:" chr(13)
  chr(10)
  ":20:" r-sqn
       chr(13) chr(10)
  ":32A:"
      substring(string(year(remtrz.valdt1)),3,2) month(remtrz.valdt1)
      format "99" day(remtrz.valdt1) format "99" crc.code format "x(3)"
       remtrz.amt
       chr(13) chr(10)
  ":c5:" skip .
  export r-sqn remtrz.amt remtrz.fcrc.
  put unformatted chr(13) chr(10)
  "-}" .

   v-text = "Отправка подтверждения для " + remtrz.remtrz + " -> " + r-sqn + " "
   + remtrz.sbank + " сумма=" + string(remtrz.amt) + " валюта=" +
   string(remtrz.fcrc) + 
   " тип= " + remtrz.ptype + " " + remtrz.saddr .   
   
   output close .

input through
   value( "lsend -v - "
   + remtrz.saddr + " < "
   + sysc.chval + "/" + r-sqn + ".cnf " +
   " ; echo $? " ) .

  v-sqn = "".
  repeat:
   import exitcod buf buf .
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf .
  end.

   if  exitcod ne "0"  or v-sqn = ""  then do:
    v-text = " Ошибка транспортной системы " +  que.remtrz +
       " " + remtrz.saddr . 
     run lgps.
     que.dp = today.
     que.tp = time.
     que.con = "F".
     que.rcod = "1".
     return .
   end.


   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".

   v-text = v-text + " SQN Транс.системы = " + v-sqn .
   run lgps.
  end.
 end.
