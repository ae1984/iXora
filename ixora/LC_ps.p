/* LC_ps.p
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
	24.06.2006 tsoy     - перекомпиляция
*/


/* 19/09/02 by sasco - sending report to KMobile */

 {global.i}
 {lgps.i }
 {comm-txb.i}

def var seltown as char.
def var i as int .
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha extent 100 .
def buffer que2 for que .
def var ibhost as cha .
def var unpr as cha .

 seltown = comm-txb().

 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Нет M_DIR записи в sysc файле ! ".
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

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   if remtrz.info[3] begins "11B" and not remtrz.ref begins "single" then do :
    find first que2 where que2.pid = m_pid and que2.con = "W"
     and que2.remtrz = substr(remtrz.ref,1,10)  exclusive-lock no-error.
    if not avail que2 or substr(remtrz.ref,12) begins "SNIP t" then do :
     que.pid = m_pid .
     que.df = today.
     que.tf = time.
     que.con = "W".
     return .
    end .
    que2.dw = today.
    que2.tw = time.
    que2.con = "P".
   end .

   /*  Beginning of main program body */
  if remtrz.source = "IBH" then do :
   find sysc where sysc.sysc = "IBHOST" no-lock no-error .
   if not avail sysc or sysc.chval = "" then do :
    v-text = " Нет IBHOST записи в sysc файле ! ".
    run lgps .
    return .
   end .
   ibhost = sysc.chval .
   if not connected("ib") then 
    connect value(ibhost) no-error .
   if not connected("ib") then do:
    v-text = " INTERNET HOST не отвечает ."  + remtrz.remtrz .
     run lgps .           
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.rcod = "1".
    if avail que2 then do : 
     que2.dp = today.
     que2.tp = time.
     que2.con = "F".
     que2.rcod = "1".
    end .
    return .
   end.
   unpr = "" .
   run IBrej_ps(8,remtrz.jh1,unpr,remtrz.remtrz) .

   /* sasco - check for KMobile account      */
   /* if matches then send report to KMobile */
   /* through mobtemp table (KMOB process)   */
   
   {mob333rmz.i}


   /* the same for kcell - Kanat */
   {ibcomrmz.i}


   if connected("ib") then
    disconnect ib .
   v-text = "Отправка подтверждения клиенту HOME-BANK " 
   + remtrz.remtrz + " -> " +
     remtrz.saddr + "1-проводка= " + string(remtrz.jh1).
   run lgps .
  end .
  else do :

  output to value( sysc.chval + "/" + remtrz.remtrz + ".cnfl") .

  find crc where crc.crc = remtrz.fcrc no-lock no-error.

  put unformatted
  "\{1:xxxXXXXXXXXXXXXxxxxXXXXXX\}\{2:E900XXXXXXXXXXXXxXxxx\}\{4:" chr(13)
  chr(10)
  ":20:" string(remtrz.jh1)
       chr(13) chr(10)
  ":21:" substr(remtrz.sqn,19)
       chr(13) chr(10)
  ":25:" remtrz.dracc
       chr(13) chr(10)
  ":32A:"
      substring(string(year(g-today)),3,2) month(g-today)
      format "99" day(g-today) format "99" crc.code format "x(3)"
       remtrz.amt
       chr(13) chr(10)
  "-}" .

   v-text = "Отправка подтверждения клиенту HOME-BANK "+ remtrz.remtrz 
   + " -> " +  remtrz.saddr + "1-проводка= " + string(remtrz.jh1).
  output close .

input through
   value( "lsend -v - " + remtrz.saddr
   + " < " + sysc.chval + "/" + remtrz.remtrz + ".cnfl " +
   " ; echo $? " ) .

  v-sqn = "".
  repeat:
   import buf .
   exitcod = buf[1].
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf[3] .
  end.

 if  exitcod ne "0"  or v-sqn = "" then do:
  do i = 1 to 100 .
   if buf[i] ne "" then
   v-text = v-text + " " + buf[i]  .
  end.
  v-text = " Ошибка транспортной системы (LSEND) " +  que.remtrz +
       " " + remtrz.saddr + " " + v-text .
     que.dp = today.
     que.tp = time.
     que.con = "F".
     que.rcod = "1".
     run lgps.
     if avail que2 then do : 
      que2.dp = today.
      que2.tp = time.
      que2.con = "F".
      que2.rcod = "1".
     end .
     return .
   end.

   v-text = v-text + " SQN = " + v-sqn .
   run lgps.

   end .

   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
   if avail que2 then do : 
    que2.dp = today.
    que2.tp = time.
    que2.con = "F".
    que2.rcod = "0".
   end .

  end.
 end.
