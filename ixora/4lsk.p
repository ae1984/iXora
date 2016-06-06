/* 4lsk.p
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
def shared var v-weekbeg as int.
def shared var v-weekend as int.
def shared var s-remtrz like remtrz.remtrz .
 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .
  if not avail sysc then do:
   v-text = " Нет  M-DIR записи в sysc файле  " .  run lgps.
   return .
  end.

 do transaction :
 find first que where que.remtrz = s-remtrz 
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
     v-text = " Невозможно отправить " + remtrz.remtrz + 
      ". Нет 1 проводки .".
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
    v-text = " Банк-получатель " + remtrz.rcbank + " не найден ! " 
     + remtrz.remtrz.
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
  if remtrz.valdt2 ne today then do:
  remtrz.valdt2 = today.
  v-text = "Дата 2 валютирования изменена : " + string(oldvaldt) + " -> " + 
    string(remtrz.valdt2) + " " + r-new . 
  run lgps . 
  end.
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

   v-text = "Отправка " + remtrz.sqn + " -> " + remtrz.remtrz + " "
   + remtrz.rcbank + " сумма= " + string(remtrz.payment) + " валюта=" + 
   string(remtrz.fcrc)
   +    " тип платежа= " + remtrz.ptype + remtrz.raddr .   
   
   remtrz.sqn = r-old.
   remtrz.remtrz = r-new.

 output close .

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
   v-text = v-text + " SQN Тран.системы = " + v-sqn .
   run lgps.
  end.
 end.

