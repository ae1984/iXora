/* rotlxzi.p
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
        20.09.2002 ja       - added SHR value to the remtrz.bi validation criteria
        30.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование
        31.01.2003 sasco    - добавил возможность проводок с/на АРП счетов
        20.08.2003 nadejda  - дополнительное логирование при изменении транспорта
        23.09.2003 nadejda  - проверка введенной суммы комиссии с учетом минимальной и максимальной суммы
        26.09.2003 nadejda  - добавлено определение комиссии по умолчанию для внешних валютных платежей и проверка при вводе кода комиссии
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        26/11/2012 Luiza  - подключила convgl.i  ТЗ 1374
*/


def new shared var ee5 as cha initial "2" .
def var prilist as cha.
def new shared var s-aaa like aaa.aaa .
def shared var s-remtrz like remtrz.remtrz.
def var addrbank as char format "x(80)".
def var cmdk as char format "x(70)".
def new shared var f_title as char format "x(80)". /*title of frame mt100  */
def var Lswtdfb as log format "Да/Нет".
def var Lswbank as log format "Да/Нет".
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var vpoint as inte.
def var vdep as inte.
def new shared buffer f57-bank for bankl.           /* nan */
def new shared buffer sw-bank  for bankl.           /* nan */
def new shared var realbic as char format "x(12)". /* real bic code    */
def new shared var remrem202 as char format "x(16)". /* field 20 of mt202  */
def new shared var F52-L as char format "x(1)".  /* ordering institution*/
def new shared var F53-L as char format "x(1)".  /* sender's corr.      */
def new shared var F54-L as char format "x(1)".             /*rec-r's corr. */
def new shared var F56-L as char format "x(1)".    /*intermediary.  */
def new shared var F53-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F53-2val as char extent 4 format "x(35)".
/*intermediary 202 .  */
def new shared var F56-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F56-2val as char extent 4 format "x(35)".
/*intermediary 202 .  */
def new shared var F57-2L as char format "x(1)".    /*intermediary 202.*/
def new shared var F57-2val as char extent 4 format "x(35)".
/*intermediary 202 .*/
def new shared var F58-2aval as char format "x(35)". /*58A - account 202.*/
def new shared var F72-2val as char extent 6 format "x(35)".
/*intermediary 202 .*/
def new shared var F57-L as char format "x(1)".       /*account with inst.  */
def new shared var F57-str4 as char extent 2 format "x(35)".
/*addit.str.for f57d in 100*/

/* 18.08.98  10 santim */
def var lbnstr as cha .
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */

def  var ootchoice as char extent 2 format "x(35)" initial
     [" только MT100  ",
      " MT100 и MT202 "] .
def new shared var domt100 as char format "x(12)". /*dest of mt100 if mt202*/
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def var v-fcrc like remtrz.fcrc.

def shared frame remtrz.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer scrc for crc.

def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var inwgl as int.
def var intmgl as int.
def var clearing as cha.
def var t-pay like remtrz.payment.
def var t-pay1 like remtrz.payment.
def var t-pay2 like remtrz.payment.
define var v-selgl  like gl.gl.
def var v-sub as char.

def buffer tgl for gl.
def var b as int.
def var s as int.
def var sublist as cha .
def var sender   as cha.
def var receiver as cha.
def var s-bankl like remtrz.sbank .
def var v-weekbeg as int.
def var v-weekend as int.
def var fu as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

/*find sysc where sysc.sysc eq "SELGL" no-lock no-error.
if avail sysc then v-selgl = sysc.inval.*/
{convgl.i "bank"}


{global.i}
{lgps.i }
{rmzi.f}   /*
m_pid = "".
u_pid = "".
            */

{comchk.i}

ee5 = "3" .


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "psingl" no-lock no-error .
if not avail sysc or sysc.inval = 0 then do:
 display "Отсутствует запись PSINGL в таблице SYSC!".
 pause .
 undo .
 return .
end.
inwgl = sysc.inval.

find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
sublist = sysc.chval.


find sysc where sysc.sysc = "pspygl"  no-lock no-error .
if not avail sysc or sysc.inval = 0 then do:
 display "Отсутствует запись PSPYGL в таблице SYSC!".
 pause .
 undo .
 return .
end.
intmgl = sysc.inval.

find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись PRI_PS в таблице SYSC!".
 pause .
 undo .
 return .
end.
prilist = sysc.chval.

find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись CLCEN в таблице SYSC!".
 pause .
 undo .
 return .
end.
clearing = sysc.chval.

find first que where que.remtrz = s-remtrz exclusive-lock no-error .
if avail que then
  v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
    else
  v-priory = entry(1,prilist).

display v-priory with frame remtrz. pause 0 .


find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
    message "Отсутствует запись RMCASH в таблице SYSC!" .
    return.
    end  .
v-cashgl = sysc.inval .


find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .
if remtrz.jh1 ne ? and remtrz.jh2 ne  ? then return .

display remtrz.remtrz with frame remtrz . pause 0 .
v-ref = substr(remtrz.sqn,19).

    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp.
 /*
   remtrz.rbank = ourbank .
   remtrz.rbank = caps(remtrz.rbank).
   remtrz.rcbank = remtrz.rbank.
   */
    display remtrz.rbank remtrz.rcbank pakal with frame remtrz .

if remtrz.rdt = ? then remtrz.rdt = g-today .


if remtrz.jh1 eq ? and m_pid <> "S" then
display  remtrz.rdt with frame remtrz.

if not ( remtrz.source eq "SW" or remtrz.source eq "UI" ) then do :

  update  v-ref validate(v-ref ne "" and v-ref ne ?
       , "Ссылка должна быть не пустой!")
     with frame remtrz .

  remtrz.sqn = trim(ourbank) + "."  + remtrz.remtrz + ".." + v-ref.
end.

/* SENDER   */
do on error undo , retry   :
      display remtrz.fcrc with frame remtrz.

      /*
      if remtrz.sbank = "" then remtrz.sbank = ourbank.
        */

if remtrz.jh1 eq ? and m_pid <> "S" then
     do on error undo,retry :
      v-psbank = caps(remtrz.sbank) .
       update v-psbank with frame remtrz.
       find first bankl where bankl.bank = v-psbank no-lock no-error .
       if not avail bankl then
        find first bankl where substr(bankl.bank,7,3)  = v-psbank
          no-lock no-error .
       if not avail bankl then undo,retry .
       remtrz.sbank = caps(bankl.bank).
      end .

     v-psbank = caps(remtrz.sbank) .
     display v-psbank with frame remtrz . pause 0 .
     if remtrz.source ne "sw" then do :
       find first bankl where bankl.bank = remtrz.sbank no-lock .
       remtrz.scbank = bankl.cbank .
       display remtrz.scbank with frame remtrz .
        remtrz.ordins[1] = bankl.name.
        remtrz.ordins[2] = bankl.addr[1].
        remtrz.ordins[3] = bankl.addr[2].
        remtrz.ordins[4] = bankl.addr[3].
     end.
     display remtrz.ordins[1] with frame remtrz .



if remtrz.jh1 eq ? and m_pid <> "S" and remtrz.sbank ne ourbank then
     do on error undo,retry :
       update remtrz.scbank  with frame remtrz.
       if remtrz.scbank = "" then undo,retry .
       find first bankl where bankl.bank = remtrz.scbank no-lock no-error .
       if not avail bankl then
        find first bankl where substr(bankl.bank,7,3)  =
         remtrz.scbank  no-lock no-error .
       if not avail bankl then undo,retry .
       remtrz.scbank = caps(bankl.bank).
       display remtrz.scbank with frame remtrz . pause 0 .
       if remtrz.sbank = "" then do:
         remtrz.ordins[1] = bankl.name.
         remtrz.ordins[2] = bankl.addr[1].
         remtrz.ordins[3] = bankl.addr[2].
         remtrz.ordins[4] = bankl.addr[3].
         display remtrz.ordins[1] with frame remtrz .
       end.
      end.
      /*
      update remtrz.scbank validate(can-find(first bankt where bankt.cbank
       = remtrz.scbank)," NOT FOUND IN BANKT ") with frame remtrz.
     remtrz.scbank = caps(remtrz.scbank).
        */


  /* SENDER - NOT OUR BANK */

     if bankl.bank ne ourbank then do on error undo ,retry :

     if remtrz.jh1 eq ? and m_pid <> "S" then
     update remtrz.fcrc validate( can-find(crc where crc.crc =
                                      remtrz.fcrc),"") with frame remtrz.
     find first crc where crc.crc = remtrz.fcrc.  acode = crc.code .
     disp acode with frame remtrz.

      if remtrz.fcrc entered then  do:
      remtrz.tcrc = remtrz.fcrc.
      bcode = acode.
      end.



     find first bankt where bankt.cbank = remtrz.scbank
      and bankt.crc = remtrz.fcrc
      and bankt.racc = "1" no-lock no-error .
     if not avail bankt then do:
      message "Ошибка! Отсутствует запись в таблице BANKT!".
      pause .
      undo,retry .
     end.
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     if t-bankl.nu = "u" then sender = "u". else sender = "n" .
     remtrz.saddr = t-bankl.crbank.
     remtrz.dracc = bankt.acc.

     if remtrz.jh1 eq ? then
       do on error undo,retry :
         update remtrz.dracc with frame remtrz .
         find first bankt where bankt.acc = remtrz.dracc and
         bankt.crc = remtrz.fcrc
         and bankt.cbank = remtrz.scbank no-lock no-error .
         if not avail bankt then
           do: bell . undo , retry . end .
       end .

     if bankt.subl = "dfb"
         then do:
         find first dfb where dfb.dfb = bankt.acc no-lock.
          remtrz.drgl = dfb.gl.
         find gl where gl.gl = remtrz.drgl no-lock.
/*         remtrz.fcrc = dfb.crc.     */
         end.
     if bankt.subl = "arp"
         then do:
         find first arp where arp.arp = bankt.acc no-lock.
         remtrz.drgl = arp.gl.
         find gl where gl.gl = remtrz.drgl no-lock.
/*         remtrz.fcrc = dfb.crc.     */
         end.
     if bankt.subl = "cif"
         then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.drgl = aaa.gl.
          find gl where gl.gl = remtrz.drgl no-lock.
 /*         remtrz.fcrc = aaa.crc.        */
         end.
      display remtrz.dracc remtrz.drgl gl.sub
       remtrz.fcrc acode
       /*
       remtrz.saddr   */
       with frame remtrz.



    if remtrz.valdt1 = ? then
      remtrz.valdt1 = g-today .
    if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.valdt1 with frame remtrz .


     if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.sacc
       /* validate(remtrz.sacc ne "","") */ with frame remtrz.
   end.

 end .


/* RECEIVER */
do on error undo , retry :
 display remtrz.tcrc bcode with frame remtrz.
 if remtrz.rbank = "" and m_pid = "I" then
  do:
   remtrz.rbank = ourbank .
   remtrz.rcbank = ourbank .
  end.
 display remtrz.rbank remtrz.rcbank  with frame remtrz .
 if remtrz.jh2 eq ? and m_pid <> "S" then
 do:
   update remtrz.rbank with frame remtrz.
   if ( m_pid eq "3" or m_pid eq "3g" )
   and remtrz.rbank = ourbank then undo,retry .
 end.

if remtrz.rbank ne ourbank  then
 do on error undo , retry :
    do on error undo , retry :
    if remtrz.rbank ne "" then do:
        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
        if not avail bankl then
        find first bankl where substr(bankl.bank,7,3)  =
          remtrz.rbank no-lock no-error .
         if not avail bankl then do: bell . undo,retry .   end .
         if remtrz.rbank ENTERED  or bankl.nu = "u"
           then remtrz.rcbank = caps(bankl.cbank) .
           remtrz.rbank = caps(bankl.bank) .
           display remtrz.rbank remtrz.rcbank with frame remtrz .
        end.
        else
         if not ourbank = clearing then remtrz.rcbank = clearing .
       end .

   find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
   if ( ( avail bankl and bankl.nu ne "u" ) or remtrz.rbank = "" )
       and remtrz.jh2 eq ? and m_pid <> "S"
       then do on error undo,retry :
        update remtrz.rcbank
        /*
        validate(
          can-find(first bankt where remtrz.rcbank eq bankt.cbank),"")
            */
            with frame remtrz.
    find first bankl where bankl.bank  =
      remtrz.rcbank no-lock no-error .
    if not avail bankl then
     find first bankl where substr(bankl.bank,7,3)  =
       remtrz.rcbank no-lock no-error .
      if not avail bankl then undo,retry .
     remtrz.rcbank = caps(bankl.bank).
  display remtrz.rcbank with frame remtrz .
 end .

  find first bankl where bankl.bank = remtrz.rcbank no-lock .
  disp remtrz.tcrc bcode with frame remtrz.
  update remtrz.tcrc validate( can-find(crc where crc.crc =
         remtrz.tcrc),"") with frame remtrz.
     find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
     display bcode with frame remtrz .
     find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc =
      remtrz.tcrc  and bankt.racc = "1" no-lock no-error .
     if not avail bankt
     then do:
      message "Ошибка! Отсутствует запись в таблице BANKT!".
      pause .
      undo,retry .
    end.

     if remtrz.valdt1 >= g-today then
     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
     else
     remtrz.valdt2 = g-today + bankt.vdate .
     if remtrz.valdt2 = g-today and bankt.vtime < time
      then remtrz.valdt2 = remtrz.valdt2 + 1 .
     repeat:
       find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
       if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and
          weekday(remtrz.valdt2) le v-weekend then leave.
       else remtrz.valdt2  = remtrz.valdt2 + 1.
     end.


 if remtrz.jh2 eq ? and m_pid <> "S" then
     update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1,
     "  2Дата < 1Дата " )
     with frame remtrz. pause 0 .
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     if t-bankl.nu = "u" then receiver = "u". else
      do: receiver = "n" . remtrz.rsub = "" .
      display remtrz.rsub with frame remtrz . end .

     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.

     if remtrz.jh2 eq ? then
       do on error undo,retry :
        update remtrz.cracc validate(true,"") with frame remtrz .
        find first bankt where bankt.acc = remtrz.cracc and bankt.crc =
        remtrz.tcrc and bankt.cbank = remtrz.rcbank no-lock no-error .
        if not avail bankt then
         do: display remtrz.cracc remtrz.tcrc remtrz.rcbank . pause .
          bell . undo ,retry . end .
       end .

     if bankt.subl = "dfb"
         then do:
         find first dfb where dfb.dfb = bankt.acc no-lock.
         remtrz.crgl = dfb.gl.
         find tgl where tgl.gl = remtrz.crgl no-lock.
/*         remtrz.tcrc = dfb.crc.        */
         end.
     if bankt.subl = "arp"
         then do:
         find first arp where arp.arp = bankt.acc no-lock.
         remtrz.crgl = arp.gl.
         find gl where gl.gl = remtrz.crgl no-lock.
/*         remtrz.fcrc = dfb.crc.     */
         end.
     if bankt.subl = "cif"
         then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.crgl = aaa.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
/*          remtrz.tcrc = aaa.crc.           */
         end.

      display remtrz.cracc remtrz.crgl tgl.sub
       remtrz.tcrc bcode
       /*
       remtrz.raddr
       */
       with frame remtrz.
      find first bankl where bankl.bank = rbank no-lock no-error .
      if avail bankl and (bankl.nu = "u" or receiver = 'u' ) then do:
      do on error undo,retry :

       if remtrz.rbank begins 'rkb' then remtrz.rsub = 'cif'.

       update remtrz.rsub validate(remtrz.rsub ne "","")  with  frame remtrz .
       if lookup(remtrz.rsub,sublist) = 0 then undo , retry .
      end .
        if remtrz.rsub ne ""
         then do:
          update remtrz.racc validate(remtrz.racc ne "","") with frame remtrz.
          remtrz.ba = "/" + remtrz.racc .
          remtrz.bb[1] = "/" + bankl.name.
          remtrz.bb[2] = bankl.addr[1].
          remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
         end .
         else
         do:
          remtrz.rsub = "" . remtrz.ba = "" . remtrz.racc = "".
         end .
    end .
       else
       do:
          remtrz.rsub = "" .
         remtrz.racc = ""  . /* remtrz.ba = "" .    */
       end .
      display remtrz.bb[1]
        remtrz.rsub  remtrz.racc with frame remtrz . pause 0 .

if receiver = "u" then do:
  v-text = " rotlxzi Автоматически изменен транспорт платежа " + remtrz.remtrz + " : receiver = 'u', трансп " + string(remtrz.cover) + " -> 5".
  run lgps.
  remtrz.cover = 5 .
end.
else do:
  v-text = " rotlxzi Автоматически изменен транспорт платежа " + remtrz.remtrz + " : receiver <> 'u', трансп " + string(remtrz.cover) + " -> 1".
  run lgps.
  remtrz.cover = 1 .
end.

end.

/*   end of receiver not our bank  */

else

/* RECEIVER -  OUR BANK  */

 do on error undo ,retry :
      remtrz.cover = 9.
      display remtrz.cover with frame remtrz. pause 0 .
      remtrz.raddr = "".
      receiver = "o".
      if remtrz.rsub = "" then remtrz.rsub = "cif" .

    if remtrz.jh1 eq ? then
      do on error undo,retry :
       update remtrz.rsub validate(remtrz.rsub ne "","")  with  frame remtrz .
       if lookup(remtrz.rsub,sublist) = 0 then undo , retry .
      end .
        if remtrz.rsub ne "" and remtrz.rsub ne "cif"
         then do:
          remtrz.crgl = 0  .
          remtrz.cracc = "" .
          display remtrz.crgl remtrz.cracc with frame remtrz .
          update remtrz.racc validate(remtrz.racc ne "","") with frame remtrz.
          remtrz.ba = "/" + remtrz.racc .
/*          remtrz.bb[1] = "/" + bankl.name.
          remtrz.bb[2] = bankl.addr[1].
          remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3]. */
         end .
         else remtrz.ba = "" .
         display  remtrz.bb[1] remtrz.crgl
           remtrz.cracc with frame remtrz  . pause 0 .

   if remtrz.rsub eq "" then
   do on error undo,retry  :
    remtrz.cracc = "" .
    remtrz.racc = "" .
    remtrz.ba = "" .
    display remtrz.cracc  remtrz.racc with frame remtrz . pause 0 .
    if remtrz.jh1 eq ? then
      update remtrz.crgl validate(can-find(gl where gl.gl = remtrz.crgl ),"")
      with frame remtrz .
      find tgl where tgl.gl = remtrz.crgl no-lock.
      if tgl.sub ne "" then
      do: message "Неверный счет Г/К!" . bell .
        pause . undo,retry . end .
      if tgl.totact then
      do: message "Неверный счет Г/К!" . bell .
        pause . undo,retry . end .
     remtrz.racc = string(remtrz.crgl) .
     remtrz.ba = string(remtrz.crgl) .
     display remtrz.cracc remtrz.racc with frame remtrz . pause 0 .
    end.
    else if remtrz.rsub = "cif" then
     do on error undo,retry :
      if remtrz.jh1 eq ? then
      update remtrz.cracc
        validate(can-find(aaa where aaa.aaa = remtrz.cracc ),"")
         with frame remtrz .
       find first aaa where aaa.aaa = remtrz.cracc no-lock no-error .
       if not avail aaa then  do: bell. undo ,retry . end.
       if aaa.crc ne remtrz.fcrc then
       do:
        bell . bell .
        Message "Валюта счета не совпадает с валютой платежа!"  .
        pause .
       end .
       find first bankt where bankt.acc = remtrz.cracc no-lock no-error .
       if avail bankt then  do:
        bell. bell.
        Message "LORO счет! Необходимо предварительно ввести код банка!" .
        pause .
        undo ,retry  .
       end.
       find gl where gl.gl = aaa.gl.
       c-acc = remtrz.cracc . {pschk.i} .
       if c-acc = "" then do: bell. undo ,retry . end.

        s-aaa = remtrz.cracc.
        run aaa-aas.
        find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
        no-lock no-error.
        if available aas then do: pause. undo,retry. end.

        if aaa.sta = "C" then do :
         message "Счет " + aaa.aaa + " закрыт!".
         undo,retry .
        end .

        find cif of aaa no-lock.

        tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
        tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
        vpname = ''.
        vpoint = integer(cif.jame) / 1000 - 0.5.
        vdep = integer(cif.jame) - vpoint * 1000.

        find ppoint where ppoint.point = vpoint and ppoint.dep = vdep
                                                  no-lock no-error.
        if available ppoint then vpname = ppoint.name + ', '.
        find point where point.point = vpoint no-lock no-error.
        if available point then vpname = vpname + point.addr[1].

        disp vpname with frame remtrz .
        pause 0.

        form
           vpname format "x(60)" label "Пункт"
           tt1 label "Полное----"
           tt2 label "--название"
           cif.lname  label "Сокращенное" format "x(60)"
           cif.pss   label "Идент.карта"
           cif.jss   label "Рег.номер"  format "x(13)"
           with overlay  centered  row 13 1 column  frame ggg.
         disp   vpname tt1 tt2  cif.lname cif.pss cif.jss with frame ggg.
           pause .

        do:
          remtrz.ba = "/" + remtrz.cracc .
          remtrz.bn[1] = trim(trim(cif.prefix) + " " + trim(cif.name)).
          remtrz.bn[2] = cif.addr[1].
          remtrz.bn[3] = cif.addr[2] + " " + cif.addr[3].
        end.
        display  remtrz.bb[1]  with frame remtrz .

             do : remtrz.tcrc = vv-crc .
                  remtrz.racc = remtrz.cracc .
                  remtrz.crgl = gl.gl.
                  display remtrz.racc remtrz.crgl
                   with frame remtrz.
                   find bank.crc where crc.crc = vv-crc.  bcode = crc.code .
                   find cif of aaa no-lock .
             end.
      end.
     if remtrz.jh1 eq ? and remtrz.cracc = "" then
        do:
           disp remtrz.tcrc bcode with frame remtrz.
           update remtrz.tcrc validate( can-find(crc where crc.crc =
           remtrz.tcrc),"") with frame remtrz.
        end.
   find bank.crc where crc.crc = remtrz.tcrc.  bcode = crc.code .


   display remtrz.tcrc bcode with frame remtrz .
   if remtrz.valdt2 = ? then
       remtrz.valdt2 = remtrz.valdt1  .
       if remtrz.jh1 eq ? then
       update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1,
       "  2Дата < 1Дата ")
       with frame remtrz. pause 0 .

end.       /* receiver - our bank     */

end . /* receiver */

     /*     AMT and SERVICE CHARGE */


if remtrz.ptype ne "H" and remtrz.ptype ne "M"  then do :
  find first ptyp where ptyp.sender = sender and
  ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then
  remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".
 end .
if sender = "o" and receiver = "o" then remtrz.ptype = "M".
/*
if m_pid = "I" then remtrz.ptype = "7" .
  */

find first ptyp where ptyp.ptype = remtrz.ptype no-lock .
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
if avail que then que.ptype = remtrz.ptype.
display  remtrz.ptype ptyp.des remtrz.cover with frame remtrz.

    if receiver = 'u'  then do:
     remtrz.svccgl = 0. remtrz.svcp = 0. remtrz.svccgr = 0.
     remtrz.svca = 0.   pakal = ''.
     display remtrz.svcrc remtrz.svccgr remtrz.svca  pakal
     remtrz.svcaaa remtrz.svccgl with frame remtrz.
     end.

if remtrz.jh1 eq ?  then do on error undo ,retry :

do on error undo.
 update remtrz.amt validate ( remtrz.amt >= 0 ," " )
   with frame remtrz .

  if remtrz.amt = 0 then do:
   update remtrz.payment validate ( remtrz.payment > 0, "")
   with frame remtrz .
  end. else remtrz.payment = 0 .
end.
if remtrz.fcrc ne remtrz.tcrc then do on error undo :
                    /*  FOREIGN EXCANGE */

if remtrz.drgl eq v-cashgl then
 b = 2.
 else b = 4.

if remtrz.crgl eq v-cashgl then
 s = 3.
 else s = 5.


find crc where crc.crc = 1 no-lock.
find fcrc where fcrc.crc = remtrz.fcrc no-lock.
vfb-rate = fcrc.rate[b].
vf1-rate = fcrc.rate[1].
find tcrc where tcrc.crc = remtrz.tcrc no-lock.
vts-rate = tcrc.rate[s].
vt1-rate = tcrc.rate[1].


if remtrz.amt eq 0 then do:
 remtrz.amt = round( remtrz.payment * vts-rate / tcrc.rate[9] , crc.decpnt).
 remtrz.amt = round( remtrz.amt / vfb-rate * fcrc.rate[9] , fcrc.decpnt).
end.
else do:
  t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
  remtrz.payment = round(t-pay / vts-rate * tcrc.rate[9] , tcrc.decpnt).
end.
 t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
 remtrz.margb  = round( remtrz.amt * vf1-rate / fcrc.rate[9] , crc.decpnt) -
  t-pay.
 remtrz.margs = round(
  t-pay * ( 1 - vt1-rate / vts-rate ) , crc.decpnt).
  t-pay = margb + margs .

/* end of FOREIGN EXCHANGE */
 end.
 else
 do:
  if remtrz.amt ne 0 then remtrz.payment = remtrz.amt .
     else remtrz.amt = remtrz.payment .
  remtrz.margb = 0.
  remtrz.margs = 0.
 end.
 display remtrz.amt remtrz.payment /* remtrz.margb remtrz.margs t-pay */
   with frame remtrz .

 if ( remtrz.ptype <> '5' and remtrz.ptype <> '1') or remtrz.svca > 0
 then do on error undo , retry :

/* 18.08.98  10 santim */
 if remtrz.svcrc eq ? or remtrz.svcrc = 0 or remtrz.svccgr = 0  then
  do:
   find first aaa where aaa.aaa = remtrz.cracc no-lock no-error .
   if avail aaa and dracc = lbnstr then
    do:
     remtrz.svcrc =  remtrz.tcrc .
     remtrz.svccgr = 307 .
     display remtrz.svcrc remtrz.svccgr with frame remtrz . pause 0 .
    end.
    else remtrz.svcrc = remtrz.fcrc .
  end.
/* 18.08.98  10 santim */

 if m_pid <> "S" and remtrz.ptype ne "8" then do :
   update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
   do on error undo,retry :

   /* определение кода комиссии */
   if remtrz.svccgr = 0 and remtrz.fcrc <> 1 and sender = "o" and receiver = "n" then do:
     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
     if avail aaa then do:
       /* если это внешний валютный клиентский платеж, то проставить по умолчанию комиссию за счет отправителя */
       {comdef.i &cif = " aaa.cif "}
     end.
   end.

   update remtrz.svccgr validate (chkkomcod (remtrz.svccgr), v-msgerr) with frame remtrz .
   if remtrz.svccgr ne 0  then do:
    run comiss2 (output v-komissmin, output v-komissmax).

    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if not avail tarif2 then undo ,retry .
    if avail tarif2 then pakal = tarif2.pakalp .
    display remtrz.svccgl pakal with frame remtrz .
   end.

   update remtrz.svca validate (remtrz.svca >= 0 and chkkomiss(remtrz.svca), v-msgerr)
      with frame remtrz.
  end .
 end.

 if remtrz.svca > 0  then do:

   find first bankt where bankt.cbank = remtrz.scbank and
        bankt.crc = remtrz.fcrc and bankt.racc = "1" no-lock no-error .
   if avail bankt then v-sub =  bankt.subl.

   if v-sub = "cif" then
     update remtrz.bi validate( remtrz.bi = "BEN" or remtrz.bi = "OUR"
                             or remtrz.bi = "NON" or remtrz.bi = "SHA"
                             ," OUR, BEN, SHA, NON ")
     with frame remtrz.

   if remtrz.bi = "our" and v-sub = "cif"
   then do :
    if remtrz.svcrc = remtrz.fcrc then do:
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
    end.
    else do :
     message "Валюта комиссии не совпадает с валютой дебета!". pause.
     undo,retry.
    end.
   end.
   else do :
     remtrz.svcaaa = "".
     remtrz.svcgl = intmgl.
   end.
  /* tranzit. remittances */
  if remtrz.ptype = '8' and not (remtrz.bi = "our" and v-sub = "cif")
  then do :
     /*remtrz.svcgl = v-selgl.*/
     remtrz.svcgl = getConvGL(remtrz.fcrc,"D").
     if remtrz.fcrc = remtrz.svcrc then do:
      find fcrc where fcrc.crc = remtrz.fcrc no-lock.
      find tcrc where tcrc.crc = remtrz.tcrc no-lock.
      t-pay2 = remtrz.amt - remtrz.svca.
      remtrz.svcp  = remtrz.svca.
        if remtrz.tcrc <> remtrz.fcrc then do:
        t-pay1 = round( t-pay2 * vfb-rate / fcrc.rate[9] , fcrc.decpnt).
        remtrz.payment = round(t-pay1 / vts-rate * tcrc.rate[9] , tcrc.decpnt).
        end.
        else remtrz.payment = t-pay2.
     end.
     else do:
      find fcrc where fcrc.crc = remtrz.fcrc no-lock.
      find fcrc where fcrc.crc = remtrz.fcrc no-lock.
      find scrc where scrc.crc = remtrz.svcrc no-lock.
      t-pay = round(remtrz.svca * scrc.rate[1] / scrc.rate[9] ,scrc.decpnt).
      t-pay = round( t-pay * fcrc.rate[9] / fcrc.rate[1] , fcrc.decpnt).
      remtrz.svcp = t-pay.
      t-pay2 = remtrz.amt  - t-pay.

        if remtrz.tcrc <> remtrz.fcrc then do:
        t-pay1 = round( t-pay2 * vfb-rate / fcrc.rate[9] , fcrc.decpnt).
        remtrz.payment = round(t-pay1 / vts-rate * tcrc.rate[9] , tcrc.decpnt).
        end.
        else remtrz.payment = remtrz.payment - t-pay.
     end.
     t-pay = round( t-pay2 * vfb-rate / fcrc.rate[9] , crc.decpnt).
     remtrz.margb  = round( t-pay2 * vf1-rate /
     fcrc.rate[9] , crc.decpnt) -  t-pay.
     remtrz.margs = round(t-pay * ( 1 - vt1-rate / vts-rate ) , crc.decpnt).
     t-pay = margb + margs .

    disp remtrz.payment with frame remtrz.
  end.

  do on error undo,retry :
   update svccgl  with frame remtrz .
   find first gl where  gl.gl = remtrz.svccgl and gl.sub eq "" no-lock
    no-error .
   if not avail gl then undo,retry .
  end.
  if remtrz.bi = "" then  remtrz.bi = "BEN" .

 end.  /* if svca > 0   */
 else
 do:
     remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
     remtrz.svccgl = 0. remtrz.svcp = 0.

     if remtrz.fcrc = remtrz.tcrc then
     remtrz.payment = remtrz.amt.
     else  do:
     t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
     remtrz.payment = round(t-pay / vts-rate * tcrc.rate[9] , tcrc.decpnt).
     end.
     if remtrz.bi = "" then remtrz.bi = "NON" .
   end.

 display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca
  remtrz.bi with frame remtrz.
 pause 0 .
end.     /*   undo service charge   */
end .    /*   if jh1 eq ? */

     /* end of AMT and SERVICE CHARGE */

 do:
   do on error undo,retry:

         update remtrz.ord validate(remtrz.ord ne "","") with frame remtrz.
         remtrz.ordcst[1] = remtrz.ord.

              s-bankl = remtrz.rbank.
              if remtrz.rsub eq  "" then
              do:
                disp s-bankl label "БанкП"
                  remtrz.bb label "Банк получ"
                  remtrz.ba label "Счет получ"
                  with centered row 14 1 col overlay top-only frame bnkx.
                update s-bankl with frame bnkx.
              end.
              if s-bankl ne "" then
              do:
               find bankl where bankl.bank = trim(s-bankl) no-lock no-error.
               if available bankl then do:
                         remtrz.bb[1] = "/" + bankl.name.
                         remtrz.bb[2] = bankl.addr[1].
                         remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
               end.
              end .
             if remtrz.rsub eq  "" then
              update remtrz.bb remtrz.ba with frame bnkx.
         end.  /* do on error */
         disp   remtrz.bb[1]   with frame remtrz.
         update remtrz.bn[1]  remtrz.bn[2] with frame remtrz.
          remtrz.ben[1] = trim(remtrz.bn[1]) + " " + trim(remtrz.bn[2])
          +  " " + trim(remtrz.bn[3]).

 do on error undo , leave  :
          dtt1 = remtrz.detpay[1] + remtrz.detpay[2].
          if dtt1  begins remtrz.racc  then
          dtt1 = substr(dtt1,length(remtrz.racc) + 2 )  .
          fu = index(remtrz.detpay[4], trim(remtrz.bi)).
          if fu <= 2 then
          dtt2 = remtrz.detpay[3].
          else
          dtt2 = remtrz.detpay[3] + substr(remtrz.detpay[4],1,(fu - 2)).

          update  dtt1 dtt2  with frame remtrz.
          if not trim(dtt1)  begins remtrz.racc  then
             dtt1 = remtrz.racc + ' ' + trim(dtt1) .
          remtrz.detpay[1] = substr(dtt1,1,35) .
          remtrz.detpay[2] = substr(dtt1,36) .
          remtrz.detpay[3] = substr(dtt2,1,35) .
          remtrz.detpay[4] = substr(dtt2,36,35) .
 end .

/*  for Lattelekom   */
 find first aaa where aaa.aaa = remtrz.cracc no-lock no-error.
 find first cif where cif.cif = aaa.cif no-lock no-error.
 find sysc where sysc.sysc = "LATTEL" no-lock no-error.
 if avail sysc and avail cif and index(sysc.chval,trim(cif.cif)) > 0 then
 do on error undo, leave :

  display      /* O72 - Sender to receivers information */
    remtrz.rcvinfo[1] format "x(35)"
    remtrz.rcvinfo[2] format "x(35)"
    remtrz.rcvinfo[3] format "x(35)"
    remtrz.rcvinfo[4] format "x(35)"
    remtrz.rcvinfo[5] format "x(35)"
    remtrz.rcvinfo[6] format "x(35)"
         with overlay top-only row 13 column 41 no-labels 1 col
         title "Межбанковская информация"
         frame ff72.
       update      /* O72 - Sender to receivers information */
         remtrz.rcvinfo[1] format "x(35)"
         remtrz.rcvinfo[2] format "x(35)"
         remtrz.rcvinfo[3] format "x(35)"
         remtrz.rcvinfo[4] format "x(35)"
         remtrz.rcvinfo[5] format "x(35)"
         remtrz.rcvinfo[6] format "x(35)"
          with overlay top-only row 13 column 41 no-labels 1 col
          title "Межбанковская информация"
         frame ff72.
 end. /* if avail sysc and for Lattelekom   */

 end. /* do on error */

   if remtrz.ptype = '5' and remtrz.bi = "" then remtrz.bi = 'NON'.

   if v-sub ne "cif" then      /* for v-sub = "cif" update was done upper */
   update remtrz.bi validate( remtrz.bi = "BEN" or
     remtrz.bi = "OUR" or remtrz.bi = "NON" ," OUR,BEN,NON ")
     with frame remtrz .
  disp remtrz.bb[1]  remtrz.bn[1] remtrz.bn[2] remtrz.ord
  remtrz.bi with frame remtrz.


  remtrz.detpay[4] = remtrz.detpay[4] +  " /" + trim(remtrz.bi) + "/." +
  " " + trim(remtrz.rcvinfo[1]) +
  " " + trim(remtrz.rcvinfo[2]) + " " + trim(remtrz.rcvinfo[3]) +
  " " + trim(remtrz.rcvinfo[4]) + " " + trim(remtrz.rcvinfo[5]) +
  " " + trim(remtrz.rcvinfo[6]) + " " .

run rmzque.
