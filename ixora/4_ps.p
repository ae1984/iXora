/* 4_ps.p
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
 {lgps.i}
def var oldvaldt as date .
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha extent 100 .
def var i as int . 
def var v-weekbeg as int.
def var v-weekend as int.

/* 18.08.98  10 santim */
def var lbnstr as cha .
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */


 find sysc "WKEND" no-lock no-error.
 if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
 find sysc "WKSTRT" no-lock no-error.
 if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .
  if not avail sysc then do:
   v-text = " Нет записи  M-DIR в sysc файле  " .  run lgps.
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

   /*  Beginning of main program body */
   
   find first jl where jl.jh = remtrz.jh1 no-lock no-error.
   if not avail jl or remtrz.jh1 eq ? then do :
     v-text = "Ошибка !" + remtrz.remtrz + " нет 1 проводки.".
     run lgps.
     que.dp = today.
     que.tp = time.
     que.con = "F".
     que.rcod = "1".
     return .
   end.
   
   find first bankl where bankl.bank = remtrz.rcbank no-lock no-error . 
   if avail bankl then 
   find first bankt where bankt.cbank = bankl.cbank and
   bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
   if not avail bankt then do:
    v-text = " Банк-получатель " + remtrz.rcbank + " не найден ! " +      remtrz.remtrz.
    run lgps.
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.rcod = "1".
    return . 
   end . 

 def var r-new like remtrz.remtrz .
 def var r-old like remtrz.sqn .

  output to value ( sysc.chval + "/" + remtrz.remtrz + ".msg" )  .

  r-old = remtrz.sqn .
  r-new = remtrz.remtrz.
  remtrz.remtrz = "HOWDOYOUDO".
  remtrz.sqn = substr(r-old,1,5) + "." + substr(r-new,1,10) + ".." +  
               substr(r-old,19) .
  oldvaldt = remtrz.valdt2.
  if remtrz.valdt2 < today then remtrz.valdt2 = today . 
  if bankt.vtime   < time  and  remtrz.valdt2 = today   then 
   do:
    remtrz.valdt2 = remtrz.valdt2 + 1 .
    repeat:
       find hol where hol.hol eq remtrz.valdt2 no-lock  no-error.
         if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
         and  weekday(remtrz.valdt2) le v-weekend then leave.
         else remtrz.valdt2  = remtrz.valdt2 + 1. 
    end.
   end . 
  if remtrz.valdt2 ne oldvaldt then do:
  v-text = "2 дата валютирования изменена : " + string(oldvaldt) + " -> " + 
    string(remtrz.valdt2) + " " + r-new . 
  run lgps . 
  end.
  if remtrz.dracc = lbnstr then remtrz.info[2] = lbnstr . 
  find crc where crc.crc = remtrz.tcrc no-lock no-error.
  put unformatted
  "\{1:xxxXXXXXXXXXXXXxxxxXXXXXX\}\{2:E10AXXXXXXXXXXXXxXxxx\}\{4:" chr(13)
  chr(10) ":32A:"
      substring(string(year(remtrz.valdt2)),3,2) month(remtrz.valdt2)
      format "99" day(remtrz.valdt2) format "99" crc.code format "x(3)"
       remtrz.payment
       chr(13) chr(10)
  ":c5:" skip .
  export remtrz.sbank remtrz.sqn .
  export remtrz.
  put unformatted chr(13) chr(10)
  "-}" .

   v-text = "Отправка в транспортную систему " + remtrz.sqn + " -> " 
   + remtrz.remtrz + " "
   + remtrz.rcbank + " сумма = " + string(remtrz.payment) + " Вал=" + 
   string(remtrz.fcrc)
   +    " Тип= " + remtrz.ptype + remtrz.raddr .   
   
   remtrz.sqn = r-old.
   remtrz.remtrz = r-new.

 output close .

                        /*
input through
   value( "lsend -v " + sysc.chval + "/" +
   remtrz.remtrz + ".msg " + remtrz.raddr + " ; echo $? " ) .

  v-sqn = "".
  repeat:
   import exitcod buf buf .
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf .
  end.

   if  exitcod ne "0"  then do:
    v-text = " There is any LASKA ERROR  " +  que.remtrz +
       " " + remtrz.raddr .      */
  
input through
   value( "lsend -v - " + remtrz.raddr
   + " < " + sysc.chval + "/" + remtrz.remtrz + ".msg " +
   " ; echo $? " ) .

  v-sqn = "".
  repeat:
   import buf .
   exitcod = buf[1].
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf[3] .
  end.

 if  exitcod ne "0" or v-sqn = ""  then do:
  do i = 1 to 100 .
   if buf[i] ne "" then
   v-text = v-text + " " + buf[i]  .
  end.
  v-text = " Ошибка транспортной системы " +  que.remtrz +
       " " + remtrz.raddr + " " + v-text .
 
     que.dp = today.
     que.tp = time.
     que.con = "F".
     que.rcod = "1".
     run lgps.
     return .
   end.


   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
   v-text = v-text + " SQN трансп.системы = " + v-sqn .
   run lgps.
  end.
 end.

