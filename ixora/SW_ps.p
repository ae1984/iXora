/* SW_ps.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        18.12.2005 tsoy     - добавил время создания платежа.
*/

def new shared var oi-name as char.
def var fou as log initial false .
def var m-typ as cha .
def var v-ret as cha .
def var tradr as cha .
def var exitcod as cha .
def var v-date as date .
def var r-bank like bankl.bank .
def var s-bank like bankl.bank .
def var sc-bank like bankl.bank.
def var sc-bank53 like bankl.bank init "".
def var s-error as cha .
def var sc-bank54 like bankl.bank init "".
def var sc-bank56 like bankl.bank init "".
def var dep-date as date .
def var v-cif like cif.cif .
def var rep as cha initial "0".
def var irep as int initial 0.
def var blok4 as log initial false .
def var blokA as log initial false .
def var v-ref as cha  .
def var v-crc like remtrz.fcrc .
def var v-amt like remtrz.amt.
def var v-ord like remtrz.ord.
def var v-info as cha .
def new shared var v-ordins as cha init "".
def var v-acc like remtrz.sacc.
def var v-bb as cha .
def var v-ba as cha .
def var v-ben as cha .
def var v-det as cha .
def var v-chg as cha init "BEN".
def var tmp as cha .

/* 18.08.98  10 santim */
def var lbnstr as cha .
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */

def var i as int .
def var num as cha extent 100 .
def var v-string as cha .
def var impok as log initial false .
def var ok as log initial false .
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
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
def var ourcode as cha.
def var v-sender like remtrz.sbank .
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var v-field  as cha extent 50 .
def var receiver as cha.
def var v-err as cha .
def new shared var s-remtrz like remtrz.remtrz .
def var v-reterr as int initial 0 .

def var qq as char.
def var qs as char format "x(12)".
def var cc as char.

{global.i }
{lgps.i }
{rmz.f}

/*ja on 04/07/01* for bank receiver (r-bank) selection*/

def temp-table mfo-s
    field ex-code as char
    field in-code as char.

for each bankl where bankl.bank begins "TXB" and bankl.bank <> "TXB00" no-lock:
   create mfo-s.
   in-code = bankl.bank.
   ex-code = substring(bankl.crbank,7,3).
end.

FUNCTION chkkey RETURNS LOGICAL( accnt AS CHAR, bcode AS CHAR).
DEF VAR templstr AS CHAR INIT '713371371371'.
DEF VAR teststr AS CHAR.
DEF VAR i AS INT.
DEF VAR res AS INT INIT 0.
teststr = STRING(INT(bcode), '999') + STRING(INT(accnt), '999999999').
DO i = 1 TO 12:
  res = res + INT(SUBSTR(teststr, i, 1)) * INT(SUBSTR(templstr, i, 1)).
END.
RETURN IF res - TRUNCATE(res / 10, 0) * 10 = 0 THEN TRUE ELSE FALSE.
END FUNCTION.


/*timur 27.02.03 функция добавляет ведущие нули к номеру счета*/

FUNCTION accleadzero RETURNS CHARACTER (acc AS CHARACTER).
  DEF BUFFER faaa for aaa.
  DEF VAR icnt as integer.
  DEF VAR alength as integer.
  DEF VAR oacc as char.

  oacc = acc.
  alength = LENGTH(TRIM(acc),"CHARACTER").
  if alength < 9
     then
       do:
         do icnt = 1 to 9 - alength:
            acc = '0' + acc.
         end.
         find first faaa where faaa.aaa = acc no-lock no-error.
         if not avail faaa
            then return oacc.
            else return acc.
       end.
     else
       return oacc.
END FUNCTION.

/*End ja on 04/07/01 */

v-text = "" .

find sysc where sysc.sysc = "clecod" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет clecod записи в sysc файле ! ".
 run lgps.
 return .
end.
ourcode = sysc.chval.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_ERR записи в sysc файле ! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.

/*  !!!!!!!!!!!!!! */

input through value("swiget 100RKB- ; echo $? ") .

num = "".
repeat:
  import num  .
  leave .
end.

if  num[1]  = ""
 then do:
  v-text = " QUEUE is EMPTY ... " .
  run lgps.
  return .
 end.

exitcod = "".
repeat:
 import exitcod  .
end.

if  ( exitcod ne "0" )
 then do:
  if num[1] ne "2" then do :
   v-text = " Ошибка  LGET SWIFT : " + num[1] + " " +
     string(exitcod).
   run lgps.
  end.
   return .
 end.

if not substr(num[2],4) begins "rkb"  then do :
  v-text = " Ошибка очереди : " + num[2] .
  run lgps.
  return.
end.

input close .

input through value("swiarc  " + string(num[1] ) + " ;echo $?"  ) .

v-field = "".
repeat:
 import unformatted v-field[1] .
 if v-field[1] ne "" then leave.
end .
if not v-field[1] begins "\{" then
do:
  s-error = "".
  do i = 1 to 50 :
   if v-field[i] ne "" then s-error = s-error + v-field[i] + " ".
  end.
  v-text = " SWIARC ошибка sqn = " + string(num[1]) + " код завершения = "
   + s-error .
  run lgps.
  return .
end.
i = index(v-field[1],"\{2:O100").
tmp = substr(v-field[1],i + 17,12) .
find first bankl where tmp begins substr(bankl.bic,3)
 and substr(bankl.bic,3) ne "" no-lock no-error .
qs = tmp.
if avail bankl then s-bank = bankl.bank .  else s-bank = "" .
r-bank =  "TXB00" .

if substr(v-field[1],i + 39,2) eq  substr(string(year(today)),3,2)
   then cc = substr(string(year(today)),1,2).
   else
   if substr(v-field[1],i + 39,2) lt  substr(string(year(today)),3,2)
      then cc = "20".
   if substr(v-field[1],i + 39,2) gt  substr(string(year(today)),3,2)
      then cc = "19".

dep-date = date(int(substr(v-field[1],i + 41,2)),
         int(substr(v-field[1],i + 43,2)),
         int(trim(cc) + substr(v-field[1],i + 39,2))) .

repeat :

 v-field = "".
 import unformatted v-field[1] .

 if not ( v-field[1] begins ":") and not  blok4  then next .
  blok4 = true .

 if v-field[1] begins ":"  or  v-field[1] begins "-}"
   then do: rep = "0" . irep = 0 . end .
 i = 0 .
 v-string = "".
 repeat:
  i = i + 1 . if i > 50 then leave .
  if v-field[i] = "" then next .
  v-string = v-string + v-field[i] + " " .
 end.
 /*
  display v-string  format "x(70)" with frame qq .
   pause .
 */
 if v-string begins ":20:" then v-ref = substr(v-string,5) .
  else
 if v-string begins ":32A:" then
  do:
   v-date = date(int(substr(v-string,8,2)), int(substr(v-string,10,2)),
   int( substr(string(year(today)),1,2) +
   substr(v-string,6,2))) .
   tmp = (substr(v-string,12,3)) .
   if tmp = "lvl" then tmp = "ls" .
   find first crc where crc.code = tmp no-lock no-error .
   if not avail crc then  v-crc = 0 .
   else v-crc = crc.crc .
   tmp = (substr(v-string,15)) .
   overlay (tmp,index(tmp,",")) = "." .
   v-amt = decimal(tmp).
 end.
 else
 if v-string begins ":50:" or rep = "50" then do:
   if rep = "0" then do: rep = "50" .
          v-ord  = (substr(v-string,5)) .
    end .
    else
    v-ord  = substr(v-ord,1,length(v-ord) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":52" or rep = "52" then do:
  if v-string begins ":52B" then v-ordins = "".
  else do :
   if rep = "0" then do:
          i = index(substr(v-string,2),":").
          rep = "52" .
          v-ordins  = (substr(v-string,i + 2)) .
    end .
    else
    v-ordins  = substr(v-ordins,1,length(v-ordins) - 1) + " " + v-string .
  end.
 end.
 else
 if v-string begins ":53" or rep = "53" then do: /* find scbank by BIC */
    if rep = "0" then do:
      rep = "53" .
      sc-bank53  = (substr(v-string,6)) .
    end .
    else
    sc-bank53  = substr(sc-bank53,1,length(sc-bank53) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":54" or rep = "54" then do: /* find scbank by BIC */
    if rep = "0" then do:
      rep = "54" .
      sc-bank54  = (substr(v-string,6)) .
    end .
    else
    sc-bank54  = substr(sc-bank54,1,length(sc-bank54) - 1) + " " + v-string .
 end.
 else
  if v-string begins ":56" or rep = "56" then do: /* find scbank by BIC */
    if rep = "0" then do:
       rep = "56" .
       sc-bank56  = (substr(v-string,6)) .
    end .
    else
    sc-bank56  = substr(sc-bank56,1,length(sc-bank56) - 1) + " " + v-string .
  end.
 else
 if v-string begins ":59:" or rep = "59" then do:
   if rep = "0" then do: rep = "59" .
    /*
    if substr(v-string,5,1) = "/" then v-ba = substr(v-string,6,10).
    */
    if substr(v-string,5,1) = "/" then v-ba = substr(v-string,6).
   end .
   else
   v-ben = substr(v-ben,1,length(v-ben) - 1) + " " + v-string .
  end .
 else
 if v-string begins ":57" or rep = "57" then do:
   if rep = "0" then do:
       i = index(substr(v-string,2),":").
       rep = "57" .
       v-bb  = (substr(v-string,i + 2)) .
    end .
    else
    v-bb  = substr(v-bb,1,length(v-bb) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":70:" or rep = "70" then do:
   if rep = "0" then do: rep = "70" .
          v-det = (substr(v-string,5)) .
    end .
    else
    v-det = substr(v-det,1,length(v-det) - 1) + " " + v-string .
 end.
 else
 if v-string begins ":71A:" then v-chg = substr(v-string,6) .
 else
 if v-string begins ":72:" or rep = "72" then do:
   if rep = "0" then do: rep = "72" .
          v-info  = (substr(v-string,5)) .
    end .
    else
    v-info  = substr(v-info,1,length(v-info) - 1) + " " + v-string .
 end.

end.
input close .

 if v-ordins ne "" then do :
   find first bankl where v-ordins begins substr(bankl.bic,3)
     and substr(bankl.bic,3) ne "" no-lock no-error .
   if avail bankl then s-bank = bankl.bank.
   else s-bank = "".  /* sbank is situated in :52: */
 end.

 sc-bank = qs.
 if sc-bank53 ne "" then sc-bank = sc-bank53.
 if sc-bank54 ne "" then sc-bank = sc-bank54.
 /*
 if sc-bank56 ne "" and (sc-bank54 ne "" or sc-bank53 ne "" )
    then sc-bank = sc-bank56.
 */
 qq = sc-bank.

 find first bankl where sc-bank begins substr(bankl.bic,3)
      and substr(bankl.bic,3) ne "" no-lock no-error .
 if avail bankl then sc-bank = bankl.bank .
 else do:
     v-text = "Корр.банк " + sc-bank + " не найден ".
     run lgps.
     sc-bank = "" .
 end.


v-ben = substr(v-ben,2).

 if s-bank ne "" then
 find remtrz where remtrz.sbank = s-bank  and
     remtrz.sqn = string(qs,"x(12)") + "......" +
     trim(v-ref) no-lock no-error .
 else
 find remtrz where remtrz.sbank = sc-bank  and
      remtrz.sqn = string(qs,"x(12)") + "......" +
      trim(v-ref) no-lock no-error .

 if avail remtrz then do:
   v-reterr = 1 .
   v-text = "Дубликат ! SWIFT SQN = " + string(num[1]) + " от " +
   string(qs,"x(12)") + string(dep-date,"999999") + v-ref +
   " уже зарегистрирован . " .
   run lgps.
 end .

/*ja on 04/07/01 trying to define r-bank, if fault - then TXB00*/
 r-bank = "TXB00".
 for each mfo-s:
    if chkkey(v-ba, mfo-s.ex-code) then do:
       r-bank=mfo-s.in-code.
       leave.
    end.
 end.
/*End ja on 04/07/01*/

if v-reterr eq 0 and r-bank = ourbank then do:

v-ba = accleadzero(v-ba).

find first aaa where aaa.aaa = v-ba no-lock no-error .
if avail aaa then find cif of aaa no-lock no-error .

if not avail cif or not avail aaa then do:
   v-text = "SWIFT SQN = " + string(num[1]) + " из " +  s-bank +
      "." + string(dep-date,"99/99/9999")  + "." + v-ref + " -> " + v-ba +
        "  код клиента  или счет не найден ! " .
   run lgps.
end .
           else
  if aaa.crc ne v-crc  then do:
  v-text = "SWIFT SQN = " + string(num[1]) + " из " +
     s-bank  + "." + string(dep-date,"99/99/9999")  + "." + v-ref +
     " валюта счета " + string(v-crc) + " " + string(aaa.crc)   +
     " не равна валюте платежа !" .
     run lgps.
  end.
end .


if v-reterr gt 0 then

 do :
  run lgps.
 input through value
 ( "swires " + string(num[2]) + " " + string(num[1]) + " reject ; echo $? " ) .

   exitcod = "".
   repeat:
    import exitcod .
   end.
   input close .

    if  exitcod ne "0"  then do:
      v-text = " Ошибка  SWIRES REJECT  " +
      s-bank +  "." + string(dep-date,"99/99/9999")  + "." + v-ref +
       " SWIFT SQN = " + string(num[1])  .
      run lgps.
     end.
 /*
 display v-reterr  . pause .
   */
 return .
end.


do on error undo  :
 /*    input from value(v-file) .    */          /*  !!!!!!!!!!!!!! */
     create remtrz .
     remtrz.rtim = time.

     run n-remtrz.                     /* !!!!!!!!!!!!!!!! */
     remtrz.source = "SW".
     remtrz.t_sqn = num[1] .
     remtrz.rdt = today .
     remtrz.remtrz = s-remtrz .
     remtrz.scbank = sc-bank.
     remtrz.valdt1 = v-date .
                             /*
     remtrz.saddr = tradr .     */
     remtrz.sacc = v-acc  .
     remtrz.tcrc = v-crc .
     remtrz.payment = v-amt .

    /*
     remtrz.cracc = v-ba  .
     find first aaa where aaa.aaa = v-ba no-lock no-error .
     remtrz.crgl = aaa.gl .
     */
     remtrz.fcrc = v-crc .
     remtrz.amt = v-amt .
     remtrz.jh1   = ?  . remtrz.jh2 = ? .
     remtrz.ord = v-ord .
     if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "SW_ps.p 521", "1", "", "").
     end.
     remtrz.sndcoract = qq.
     /*
     remtrz.ordcst[1] = substr(v-ord,1,35) .
     remtrz.ordcst[2] = substr(v-ord,36,35) .
     remtrz.ordcst[3] = substr(v-ord,71,35) .
     remtrz.ordcst[4] = substr(v-ord,104,35) .
     */
     if v-bb = "" then do :
       find bankl where bankl.bank = r-bank no-lock no-error.
       if avail bankl then v-bb = trim(bankl.name) + " " + trim(bankl.addr[1])
        + trim(bankl.addr[2]) + " " + trim (bankl.addr[3]).
     end.
     if v-bb ne "" then do:
     remtrz.bb[1]  = "/" + substr(v-bb,1,35) .
     remtrz.bb[2]  = substr(v-bb,36,35) .
     remtrz.bb[3]  = substr(v-bb,71,70) .

     remtrz.actins[1]  = "/" + substr(v-bb,1,35) .
     remtrz.actins[2]  = substr(v-bb,36,35) .
     remtrz.actins[3]  = substr(v-bb,71,35) .
     remtrz.actins[4]  = substr(v-bb,106,35) .
                          end .
     remtrz.bn[1] = substr(v-ben,1,60) .
     remtrz.bn[2] = substr(v-ben,61,60) .
     remtrz.bn[3] = substr(v-ben,121,60) .

     remtrz.det[1] = substr(v-det,1,35) .
     remtrz.det[2] = substr(v-det,36,35) .
     remtrz.det[3] = substr(v-det,71,35) .
     remtrz.det[4] = substr(v-det,106,35) .

     remtrz.rcvinfo[1] = substr(v-info,1,35) .
     remtrz.rcvinfo[2] = substr(v-info,36,35) .
     remtrz.rcvinfo[3] = substr(v-info,71,35) .
     remtrz.rcvinfo[4] = substr(v-info,106,35) .
     remtrz.rcvinfo[5] = substr(v-info,141,35) .
     remtrz.rcvinfo[6] = substr(v-info,176,35) .

     remtrz.ba =  v-ba .
     remtrz.bi = v-chg .

     remtrz.margb = 0.
     remtrz.margs = 0.

     remtrz.svca   = 0.
     remtrz.svcaaa = "".
     remtrz.svcmarg = 0.
     remtrz.svcp = 0.
     remtrz.svcrc = 0.
     remtrz.svccgl = 0.
     remtrz.svcgl = 0.
     remtrz.dracc = "".
     remtrz.drgl = 0.

    if v-ordins = "" then do :
     if s-bank ne "" then do :
      find first bankl where bankl.bank = s-bank no-lock no-error.
      if avail bankl then
        v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " "
        + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
      else v-ordins = "".
     end.
     /*
     else do :
      find first bankl where qs begins substr(bankl.bic,3)
          and substr(bankl.bic,3) ne "" no-lock no-error .
       if avail bankl then
        v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " "
        + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
       else  v-ordins = "".
     end.
     */
    end.
    else do :    /*  v-ordins ne ""   */
     find first bankl where v-ordins begins substr(bankl.bic,3)
         and substr(bankl.bic,3) ne "" no-lock no-error .
     if avail bankl then
       v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " "
         + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
     else do :
       run stests1.
       if oi-name ne "" then v-ordins = oi-name.
     end.
    end.
    if v-ordins = "" then  do :  /* search in bint   */
      v-ordins = trim(qs).
      run stests1.
      if oi-name ne "" then v-ordins = oi-name.
    end.

    remtrz.ordins[1] = substr(v-ordins,1,35).
    remtrz.ordins[2] = substr(v-ordins,36,35).
    remtrz.ordins[3] = substr(v-ordins,71,35).
    remtrz.ordins[4] = substr(v-ordins,106,35).


     remtrz.sqn   = string(qs,"x(12)") + "......" +
      trim(v-ref) .
     remtrz.rcbank = "".
     if r-bank = "TXB" then r-bank = "TXB00".
     remtrz.rbank = r-bank.
     acode = "".
     remtrz.racc = v-ba .
     remtrz.outcode = 3 .
     if remtrz.valdt1 >= g-today then
     remtrz.valdt2 = remtrz.valdt1  .
     else
     remtrz.valdt2 = g-today .


   if s-bank eq "" and sc-bank = "" then  do:
      v-text = remtrz.remtrz +
      " Внимание ! Не найден код банка отправителя " .
      run lgps.
   end.

   else
   do:    /*  known sender */
    if s-bank ne "" then do :
     find first bankl where bankl.bank = s-bank no-lock no-error.
     if not avail bankl then do:
       v-text = remtrz.remtrz + " Внимание ! Не найден код банка "
         + s-bank  .
       run lgps .
       v-reterr = v-reterr + 8.  /*  */  .
     end.
     else remtrz.sbank = s-bank .
    end.  /* s-bank ne ""   */
    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
    if avail crc then
    bcode = crc.code .
    if sc-bank ne "" then
       find first bankt where bankt.cbank = sc-bank and
       bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
    else
       find first bankt where bankt.cbank = bankl.cbank and
       bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

    if not avail bankt then do:
      v-text = remtrz.remtrz + " SWIFT " +
      " Внимание ! Не найден корр.счет " + sc-bank +
       " для валюты = " + bcode   .
      run lgps .
      v-reterr = v-reterr + 16 .
    end.

    else do :        /* not error */
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.scbank = t-bankl.bank .
     remtrz.dracc = bankt.acc.
     sender = "n" .
     if bankt.subl = "dfb"
     then do:
          find first dfb where dfb.dfb = bankt.acc no-lock no-error .
      if not avail dfb  then do:
       v-text = remtrz.remtrz + " Внимание ! Не найден корр.счет " +
       bankt.acc  + " в dfb файле для " +
       s-bank + " ! " .
       run lgps .
       v-reterr = v-reterr + 125.  /*  */  .
      end.
      else
      do:
       remtrz.drgl = dfb.gl.
       find tgl where tgl.gl = remtrz.drgl no-lock.
      end.
     end.
     if bankt.subl = "cif"
     then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
        if not avail aaa  then do:
          v-text = remtrz.remtrz + " Не найден LORO счет " +
              bankt.acc  + " для " + s-bank + " !" .
          run lgps .
          v-reterr = v-reterr + 126.  /*  */  .
        end.
        else do:
           remtrz.drgl = aaa.gl.
           find tgl where tgl.gl = remtrz.drgl no-lock.
        end.
     end.
    end .  /* not error */
    find first bankl where bankl.bank = s-bank no-lock no-error.
/*   end.   sbank isn't our bank  */
   end .

 if r-bank eq "" or r-bank = "txb" then  do:
      v-text = remtrz.remtrz +
  "  Нет кода банка получателя  ! " .
      run lgps.              end.
 else
 do:

/*  known RECEIVER  */

   find first bankl where bankl.bank = r-bank no-lock no-error.

   if not avail bankl then do:
      v-text = remtrz.remtrz + " Не найден код банка " +
      r-bank  .
      run lgps .
      v-reterr = v-reterr + 8.  /*  */  .
   end.
   else
   if bankl.bank ne ourbank  then
    do  :
     find first crc where crc.crc = remtrz.tcrc no-lock no-error .
     if avail crc then
     bcode = crc.code .
     find first bankt where bankt.cbank = bankl.cbank and
     bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

    if not avail bankt then do:
      v-text = remtrz.remtrz + " SWIFT " +
  " Внимание ! не найден корр.счет для " + bankl.cbank +
       "  Валюта = " + bcode  .
      run lgps .
   /*   v-reterr = v-reterr + 16 .  */  .
    end.

    else do :        /* not error */
     if remtrz.valdt1 >= g-today then
     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
     else
     remtrz.valdt2 = g-today + bankt.vdate .
     if remtrz.valdt2 = g-today and bankt.vtime < time
      then remtrz.valdt2 = remtrz.valdt2 + 1 .
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.rcbank = t-bankl.bank .
     if t-bankl.nu = "u" then
     do:
      receiver = "u".
      remtrz.rsub = "cif".
     end.
     else do:
      receiver = "n" .
      remtrz.ba = "/" +  v-ba .
     end .
     remtrz.rcbank = t-bankl.bank .
     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.
     if bankt.subl = "dfb"
        then do:
          find first dfb where dfb.dfb = bankt.acc no-lock no-error .
     if not avail dfb  then do:
      v-text = remtrz.remtrz + " Внимание ! Не найден корр.счет " +
                   bankt.acc  + " для " + r-bank + " !" .

      run lgps .
      v-reterr = v-reterr + 125.  /*  */  .
     end.
        else
        do:
          remtrz.crgl = dfb.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.
      if bankt.subl = "cif"
        then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
   if not avail aaa  then do:
      v-text = remtrz.remtrz + " Внимание ! Не найден LORO счет " +
                bankt.acc  + " для " + r-bank + " ! " .
      run lgps .
      v-reterr = v-reterr + 126.  /*  */  .
   end.
          else do:
           remtrz.crgl = aaa.gl.
           find tgl where tgl.gl = remtrz.crgl no-lock.
          end.
        end.
     end .  /* not error */
  end.     /* rbank isn't our bank */

   else
     do:
        remtrz.rcbank = r-bank.
        remtrz.rsub = "cif".
        remtrz.raddr = "".
        remtrz.valdt2 = remtrz.valdt1.
        receiver = "o".
        if remtrz.rsub ne "" then do:
         c-acc = remtrz.racc.
         if rsub = "cif"
            then do:
              find first aaa where aaa.aaa = c-acc and aaa.crc eq remtrz.tcrc no-lock no-error .
              if avail aaa then do:
                if aaa.sta eq "C" then do:
                    v-text = remtrz.remtrz + " Закрытый счет : " + c-acc.
                    for each aas where aas.aaa = c-acc and aas.sic = "KM" no-lock .
                    v-text = remtrz.remtrz + " Счет  " + c-acc + " переведен в " + aas.payee .
                end .
                run lgps .
                v-reterr = v-reterr + 8.
                /* aaa for rbank.racc  wasn't found */  .
              end.
              else do:
                find tgl where tgl.gl = aaa.gl no-lock.
                remtrz.cracc = remtrz.racc .
                remtrz.crgl = tgl.gl.
              end.
            end.
            else
              do:
                 v-text = remtrz.remtrz + " Не найден счет " +
                 c-acc  + " или валюта счета не = валюте платежа " .
                 run lgps .
                 /* v-reterr = v-reterr + 32. * aaa for rbank.racc  wasn't found. */
              end.
         end.         /* cif */
          else
            do:
              v-text = remtrz.remtrz + " RSUB ne CIF:   " + rsub + " " +
              c-acc  + " , 6 bit retcode = 1 " .
              run lgps .
              /* v-reterr = v-reterr + 64 .   */ .
            end.

     end.        /*  rsub ne "" */
   else
     do:
        v-text = remtrz.remtrz + " RSUB пуст  " + c-acc.
        run lgps .
        /*  v-reterr = v-reterr + 128 .   */ .
     end.

  end.        /* end rbank = ourbank */
end .  /* known receiver   */

/* 18.08.98  10 santim */
     if remtrz.dracc = lbnstr then do:
       find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(307)
                           and tarif2.stat = 'r' no-lock no-error .
       if avail tarif2 then do:
           remtrz.svccgr = 307.
           remtrz.svcrc = remtrz.tcrc .
           run comiss .
          end.
       end.
/* 18.08.98  10 santim */

                remtrz.ref =
                (substring(trim(v-cif),1,6) +
                fill(" " , 6 - length(substring(trim(v-cif),1,6))))
                +  (substring(trim(v-ref),1,12) +
                fill(" " , 12 - length(substring(trim(v-ref),1,12))))
                +
                (substring(trim(ourcode),1,12) +
                fill(" " , 12 - length(substring(trim(ourcode),1,12))))
                +
                (substring(trim(v-acc),1,10) +
                fill(" " , 10 - length(substring(trim(v-acc),1,10))))

                + string(day(dep-date),"99")
                + string(month(dep-date),"99")
                + substr(string(year(dep-date),"9999"),3,2) .
                                                  /*
                + substring(v-rcvinfo[1],11,5) .
                                                    */
/*
 if receiver ne "o" and r-bank ne "" then do:
   {nbal+r.i}       /*          nbal           */
 end.
*/

  if remtrz.sbank = "" then remtrz.sbank = remtrz.scbank.

  sender = "n".
  find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
  if avail bankl then
  if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .
  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
  find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
     no-lock no-error .
  if avail ptyp then remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".

 v-text = "Автоматическая регистрация платежа " + remtrz.remtrz +
  " <- SWIFT SQN = " + string(num[1]) +
 " <- " + s-bank + " " + " " + qq + " " + remtrz.sqn +
  " код завершения = " + string(v-reterr) .
 run lgps.
 create que.
 que.remtrz = remtrz.remtrz.
 que.pid = m_pid.
 remtrz.remtrz = que.remtrz .
 que.ptype = remtrz.ptype.
 if v-reterr = 0 then que.rcod = string(v-reterr).
                 else
                   do:
                      que.rcod = "1".
                      que.pvar = string(v-reterr).
                   end.
 if remtrz.scbank = "" then
    do:
      que.rcod = "2".
      v-text = remtrz.remtrz +
      "Не найден код банка отправителя. Платеж переводится на очередь I код завершения = " + que.rcod.
      run lgps.
    end.
 que.con = "F".
 que.dp = today.
 que.tp = time.
 que.pri = 29999.
 ok = true.
end.



if ok then
 do:

input through value
( "swires " + string(num[2]) + " " + string(num[1]) + " done  ; echo $? " ).
  exitcod = "".
  repeat:
   import exitcod.
  end.
input close.
   if  exitcod ne "0"  then do:
    v-text = " Ошибка  SWIRES DONE " +  que.remtrz +
       " SWIFT SQN = " + string(num[1]).
     run lgps.
   end.
pause 0.
end.
