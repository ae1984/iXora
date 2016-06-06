/* 8C_ps.p
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

def var num as cha extent 100 . 
def var v-sqn like remtrz.sqn  .
def var impok as log initial false .
def var ok as log initial false .
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var i as int . 
def var fou as log . 
def var exitcod as cha . 
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var v-cl as cha.
def var v-sender like remtrz.sbank .
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var v-field as cha .
def var receiver as cha.
def var v-err as cha .
def new shared var s-remtrz like remtrz.remtrz .
def var v-reterr as int initial 0 .
{global.i }
{lgps.i }
{rmz.f}

        /*
 m_pid = "A".
 u_pid = "AUTORG".
          */

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.
find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "CLCEN" no-lock no-error.  /* Clearing cent.code */
if not available sysc or sysc.chval = "" then do :
 v-text = " Нет CLGEN записи в sysc файле ! ".
 run lgps.
 return .
end.
v-cl = sysc.chval.


find sysc where sysc.sysc = "PS_ERR" exclusive-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_ERR записи в sysc файле ! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.

if ourbank = v-cl then 
 input through value("lget 10C  -q BRNCH ; echo $? ") .
else
 input through value("lget 10C  -q RECVD ; echo $? ") .


num = "".
repeat:
  import num  .
  leave .
end.

if  num[1]  = "0"
 then do:
  return .
 end.

exitcod = "".
repeat:
  import exitcod  .
end.

   fou = false .
   do i = 1 to length(num[1]) .
      if substr(num[1],i,1) > "9" or substr(num[1],i,1) <  "0"
       then do: fou = true . leave . end .
   end.

  if not fou then
  do i = 2 to 100 .
   if num[i] ne ""  then
   do: fou = true . leave . end .
  end.


if  ( exitcod ne "0" ) or fou
 then do:
  do i = 1 to 100 .
   if num[i] ne "" then
   v-text = v-text + " " + num[i]  .
  end.
  v-text = " Ошибка транспортной системы ! (LGET) " + v-text .
  run lgps.
  return .
 end.

input close .

input through value("larc -F s -s " + string(num[1]))  .  /*  !!!!!!!!!!!!!! */

 import v-field .
 if substr(v-field,34,3) ne "10C" then 
  do: 
   input close . 
   return . 
  end .
repeat:
 import v-field .
 if v-field = ":C5:" then leave .
end .
if v-field ne ":C5:"
 then do:
  v-text = "Ошибка формата сообщения SQN = " + string(num[1]) .
  run lgps.
  return .
 end.

do on error undo  :
     create conf .
     import conf .
     conf.who = g-ofc .
     conf.whn = today .
     conf.tim = time .
     conf.sqn = num[1] .
     ok = true  .
     v-text = " Зарегистрировано подтверждение для " + conf.remtrz +
     " SQN = " + string(num[1]) .
     run lgps.
end.
                                           /*
 if ok then 
 do:
 if ourbank = v-cl then
        unix silent value("lget -q BRNCH --done " + string(num[1])) .
        else
        unix silent value("lget -q RECVD --done " + string(num[1])) .
 end.                                        */

 if ok then
 do:
 if ourbank = v-cl then
  input through
     value( "lget -q BRNCH --done " + string(num[1]) + " ; echo $? " ) .
 else 
 input through
   value( "lget -q RECVD --done " + string(num[1]) + " ; echo $? " ) .
  exitcod = "".
  repeat:
   import exitcod .
  end.
 input close .
   if  exitcod ne "0"  then do:
    v-text = " Ошибка транспортной системы ( LGET DONE ) для  " +  conf.remtrz 
    + " Laska SQN = " + string(num[1])  .
     run lgps.
   end.
 pause 0 .
end .

pause 0 .
