/* ANS_ps.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{global.i }
{lgps.i }
                                   /*

 m_pid = "ANS".
 u_pid = "".                         */

def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .

def new shared var r-hst as cha .
def new shared var v-log as cha .
def var s-remtrz like remtrz.remtrz . 
def var df as date . 
def var dt as date .
def var dfi  as date .
def var v-weekbeg as int.
def var v-weekend as int.
def var v-str as cha .
def var v-amt as cha . 
def var v-code as cha . 
def var v-sbank like remtrz.sbank . 
def var v-rmz like remtrz.remtrz . 
def var i as int .
def var ir as int . 
def temp-table ww field remtrz like remtrz.remtrz . 
def var m-dir as cha . 
def var patt1 as cha format "x(20)"  .
def var patt2 as cha format "x(20)"  .
def var patt3 as cha format "x(20)"  .
def var patt4 as cha format "x(20)"  .
def var patt5 as cha format "x(20)"  .

def var xpatt1 as cha format "x(20)"  .
def var xpatt2 as cha format "x(20)"  .


 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .
   if not avail sysc then do:
      v-text =  " Нет M-DIR записи в sysc файле ! ".  
      run lgps.
      return .
   end.
   m-dir = sysc.chval . 
/*
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
v-hst = trim(sysc.chval).
 */

find sysc where sysc.sysc = "PS_LOG" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_LOG записи в sysc файле ! ".
  run lgps. 
 return .
end.

v-log = trim(sysc.chval).

def var num as cha extent 100 . 
def var headr as cha extent 10 .

def var impok as log initial false .
def var ok as log initial false .
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var fou as log . 
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
def var v-reterr as int initial 0 .
          

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
 v-text = " Нет CLCEN записи в sysc файле ! ".
 run lgps.
 return .
end.
v-cl = sysc.chval.

                                               
if ourbank = v-cl then 
 input through value("lget e96  -q BRNCH ; echo $? ") .
else
 input through value("lget e96  -q RECVD ; echo $? ") .


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
 /*                                                
input through value("larc -F s -s " + string(num[1]))  .  !!!!!!!!!!!!!! */

/*         num[1] = "333686".   */ 

 input through value("larc -F s -s " + string(num[1]))  .
 import v-field .
 import v-field .
 import headr .                                      
 if headr[1] = "ANSWER" then  
  do: 
   input close .
     unix value("larc -F s -s " + string(num[1]) + " > " + v-log + "/" + 
     headr[2]) .    
          v-text = " ANSWER PS STATEMENT " + headr[2]
              +  " получен SQN = " + string(num[1]) .
   run lgps. 
   ok = true .  
  end .      
  else 
  do:
 repeat:
  import v-field .
  if v-field = ":5C:" then leave .
 end .
 if v-field ne ":5C:"
  then do:
   v-text = " Ошибка формата в QUEST PS STATEMENT - SQN = " + string(num[1]) .
   run lgps.
   return .
  end.

do on error undo  :
  
  import unformatted v-str .
  r-hst = entry(1,substr(v-str,24)," ") .
  output to value ( v-log + "/" + headr[2] + "ans" ) .
  put unformatted
  "\{1:xxxXXXXXXXXXXXXxxxxXXXXXX\}\{2:EE96XXXXXXXXXXXXxXxxx\}\{4:" 
  chr(13) chr(10)
  ":5A:" chr(13) chr(10) 
  " Ответ  "  headr[2] "ans PS_STATEMENT " + headr[4] + " <- " +  
      string(time,"hh:mm:ss")   chr(13) chr(10)
  ":5b:" chr(13) chr(10)
       " ПС Манаджер " 
       chr(13) chr(10)
  ":5c:" chr(13) chr(10) .

/*    ANSWER START   */
        put unformatted v-str  
        "                                                "    
          chr(13) chr(10) .
        import unformatted v-str .
        put unformatted v-str  
         "            -----------------------------------"  chr(13) chr(10) .
        import unformatted v-str .
        put unformatted v-str 
          "          Ссылка    1-проводка  R_SQN     КОД "   chr(13) chr(10)  .
        import unformatted v-str .
        put unformatted v-str
          "            -----------------------------------"  chr(13) chr(10) .
       repeat:
        import unformatted v-str .
  /*         display v-str .       */ 
        if v-str matches "*Всего*"  then do:
         put unformatted v-str   chr(13) chr(10) . 
         leave .  
        end.
        if v-str matches "*---------*"  then do:
        put unformatted v-str  
        "            --------------------------------"   chr(13) chr(10) .
          next .
        end.

        put unformatted  v-str "   --->   " . 
        v-rmz = substr(v-str,12,16)  .
        v-sbank = entry(1,v-str," ") . 
        v-amt = substr(v-str,46,21) .
        v-code = substr(v-str,68,3) .   
/*        display v-amt format "x(21)" v-code  .  */
        find first remtrz where remtrz.sbank = trim(v-sbank) and remtrz.sqn
         begins v-rmz  use-index sbnksqn   no-lock  no-error . 
        if avail remtrz then
          find crc where crc = remtrz.fcrc no-lock .
        if avail remtrz and trim(v-amt) =
           trim(string(remtrz.amt,"z,zzz,zzz,zzz,zz9.99")) and
           trim(v-code) = crc.code then do :   
             find que of remtrz no-lock .
         put unformatted 
         " " remtrz.remtrz format "x(10)" 
         " " remtrz.jh1 format "zzzzzzzz" " " remtrz.t_sqn format "x(8)"
         "    "  que.pid format "x(3)"  chr(13) chr(10) .       
         ir = ir + 1  .
        end .
        else 
         if not avail remtrz  then 
         do:
         put unformatted "       **** Не получен   ! **** "  chr(13) chr(10) . 
         end.
        else 
        if ( trim(v-amt) ne 
        trim(string(remtrz.amt,"z,zzz,zzz,zzz,zz9.99"))) 
         or ( trim(v-code) ne crc.code ) 
        then do :
           put unformatted "       ** Не соответствует ! * "  chr(13) chr(10) .
        end .
       end.

   put unformatted " Всего получено: " ir  chr(13) chr(10) .

   /*     ANSWER END    */                    
   put unformatted  "-}" .
   input close .
   output close . 
/*   unix joe value ( v-log + "/" + headr[2] +  "ans" ) .  */
   v-text = " Запрос на квитовку " + headr[2] +
     " получен SQN = " + string(num[1]) .

   run lgps.
   /*  SEND   ANSWER    */

    v-text = "Отправлен ответ на запрос" + headr[2] + "ans " . 
    find first bankl where bankl.bank = r-hst no-lock . 
/*  display bankl.crbank . pause .  */ 
 input through
   value( "lsend -v - "
   + bankl.crbank  + " < "
    + v-log + "/" + headr[2] +  "ans "  + " ; echo $? " ) .
  v-sqn = "".
  repeat:
   import exitcod buf buf .
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf .
  end.

   if  exitcod ne "0"  or v-sqn = ""  then do:
    v-text = " There is any LASKA ERROR  " 
    + v-log + "/" + headr[2] +  "ans " + 
      " " + bankl.crbank .  run lgps.
    v-text = " Ошибка транспортной системы ! (LSEND) " + v-text .
    run lgps  .
    return .
   end.

   v-text = v-text + " Laska SQN = " + v-sqn .
    run lgps.
   
   /*  SEND  FINISH     */
   ok = true . 
 end.
end. 
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
   v-text = " Ошибка транспортной системы ! (LGET DONE) " + v-text  +
    headr[2] +    " Laska SQN = " + string(num[1])  .
    run lgps.
  end.
 pause 0 .
end .

pause 0 .
