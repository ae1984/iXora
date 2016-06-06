/* LONl_ps.p
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

/*LONl_ps.p
  создание исходяшего платежа из кредитного модуля
  изменения от 13.03.2001
  - psrorlon.f
  - коды ЕКНП
*/
{global.i}
{s-lonliz.i}
def input parameter  not-iss like jl.dam.  /*  сумма из кредита*/

def shared var s-lon like lon.lon.
def shared var loniss like jl.dam.
def shared var loniss1 like jl.dam.
def shared var s-crc like crc.crc.
def shared var s-jh like jh.jh. /*added jj*/
def shared var s-srv like jl.dam extent 3.
def var londam like jl.dam.

def buffer acrc for crc.
def buffer bcrc for crc.
def buffer ccrc for crc.
def buffer dcrc for crc.
def buffer zcrc for crc.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var v-ref as cha format "x(10)".
def new shared var v-pnp as cha format "x(10)".
def var acode like crc.code.
def var bcode like crc.code.
def var ccode like crc.code.
def var s-bank like bankl.bank.
def new shared frame remtrz.
def shared var v-comgl as inte.
def shared var v-regnom as char format "x(12)".
def new shared var ee5 as char init '2'.
def var v-name as char.
def var v-sname as char.

def var amt1 like remtrz.amt.
def var amt2 like remtrz.amt.
def var amt3 like remtrz.amt.
def var amtp like remtrz.amt.

DEF buffer xaaa for aaa.
DEF var bila
 like aaa.cbal label "ОСТАТОК".
def var com1 like remtrz.amt.
def var com2 like remtrz.amt.
def var com3 like remtrz.amt.
def var br as int format "9".
def var sr as int format "9".
def var ii as inte initial 1.
def var pakal  as char.
def var v-sumkom like remtrz.svca.
def var v-uslug as char format "x(10)".
def var ee1 like tarif2.num.
def var ee2 like tarif2.kod.
def var v-numurs as char format "x(10)".
def new shared var v-reg5 as char format "x(13)".
def new shared var s-aaa like aaa.aaa.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var v-chg as integer.
def var ourbank like bankl.bank.
def var sender as cha.
def var v-cashgl like gl.gl.
define shared variable s-remo like remtrz.remtrz.
def var i as int.
def var v-who as char format "x(50)".
def var v-passp as char .
def var v-perkod as char format "x(50)".
define frame f_cus
    v-who   label "ПЛАТЕЛЬЩИК " skip
    v-passp  label "ПАСПОРТ    "  format "x(320)" view-as fill-in size 50 by 1
    skip
    v-perkod label "РНН   "
    with row 15 col 16 overlay side-labels.






{lgps.i new}
u_pid  = 'LON_ps'.
m_pid = 'LON'.


{psrorlon.f}

def temp-table vgl
    field vgl as inte.
def var vgldes as char.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record OURBNK in sysc file !!".
  pause .
  undo,return .
end.
ourbank = sysc.chval.

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
      message " There isn't RMCASH record in sysc . " .
      pause.
      undo,return.
  end  .
v-cashgl = sysc.inval .

find sysc where sysc.sysc = "rmsvco" no-lock.
repeat:
  if entry(ii,sysc.chval) = "" then leave.
  create vgl.
  vgl.vgl = integer(entry(ii,sysc.chval)).
  ii = ii + 1.
end.


find sysc where sysc.sysc = "REMBUY" no-lock no-error.
br = sysc.inval.
find sysc where sysc.sysc = "REMSEL" no-lock no-error.
sr = sysc.inval.
find lon where lon.lon = s-lon no-lock.
find cif of lon no-lock.
v-reg5 = trim(substr(cif.jss,1,13)).
release sysc.

  run n-remtrz.

do transaction:

  create remtrz.
  remtrz.rtim = time.
  remtrz.remtrz  = s-remtrz.
  s-remo = s-remtrz.
  remtrz.rdt = g-today.
  display remtrz.remtrz with frame remtrz.
do on error undo,retry:

 update v-ref validate (v-ref ne ? ,"")
  with frame remtrz.
 remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + v-ref.
 remtrz.cover = 3.
 display remtrz.cover with frame remtrz.

/* update remtrz.cover with frame remtrz.
 if remtrz.cover < 1 or remtrz.cover > 3 then do:
    bell.
    undo, retry.
 end.*/

 update remtrz.rdt
       with frame remtrz.
end.

MM:

do on error undo,retry:
remtrz.fcrc  = lon.crc.
display remtrz.fcrc
with frame remtrz.
find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0 no-lock no-error.
        if not available acrc  then do:
            message "Статус валюты <> 0 " .
        undo, retry.
        end.

      acode = acrc.code.
   disp acode with frame remtrz.

   remtrz.amt = loniss.

/*   update  remtrz.amt validate( remtrz.amt >= 0 ,"") with frame remtrz. */
   if remtrz.amt > not-iss  then do:
       bell. bell.
       message " Loan open amount exceeded.".
       undo, retry.
   end.

   remtrz.amt = round ( remtrz.amt , acrc.decpnt ) .
/*   display remtrz.amt with frame remtrz.
   remtrz.payment = 0.
   remtrz.tcrc = remtrz.fcrc.
   update remtrz.tcrc validate(can-find(crc where crc.crc = remtrz.tcrc) , "")
   with frame remtrz. */

   remtrz.tcrc = s-crc.
   remtrz.payment = 0.
   display remtrz.amt remtrz.tcrc remtrz.payment with frame remtrz.

find crc where crc.crc = remtrz.tcrc and crc.sts = 0 no-lock no-error.  /* new
*/     if not available crc then do:
            message "Статус валюты <> 0 " .
        undo, retry.
        end.
        disp crc.code with frame remtrz.
find ccrc where ccrc.crc = remtrz.tcrc no-lock.   /* new */

remtrz.margb = 0. remtrz.margs = 0.

if remtrz.amt = 0 then do:

/* update  remtrz.payment validate( remtrz.payment >= 0,"" ) with frame remtrz.
   remtrz.payment = round ( remtrz.payment , ccrc.decpnt ) . */
   display remtrz.payment with frame remtrz.



 /* remtrz.amt = 0. */
 if remtrz.amt = 0 and remtrz.payment = 0 then do:
    bell.
    bell.
    undo,retry.
   end.
if remtrz.fcrc eq remtrz.tcrc then
    remtrz.amt = remtrz.payment.
    if remtrz.amt > not-iss then do:
        bell. bell.
        message 'Loan open amount exceeded.'.
        undo,retry.
    end.
    else do:
        if acrc.rate[br] = 0 then do:
            message "Банк не покупает " acrc.code.
        undo, retry MM.
        end.

        if ccrc.rate[sr] = 0 then do:
            message "Банк не продает" ccrc.code.
        undo, retry MM.
        end.
        /* amtp =
          remtrz.payment * ccrc.rate[sr] *
           acrc.rate[9] / acrc.rate[br] / ccrc.rate[9]. */
        remtrz.amt =
         round(remtrz.amt,acrc.decpnt) .
       end.
    disp remtrz.amt with frame remtrz.
end.

 find acrc where acrc.crc = remtrz.fcrc no-lock . /* new */
 find ccrc where ccrc.crc = remtrz.tcrc no-lock . /* new */
 find crc where crc.crc = remtrz.tcrc no-lock . /* new */

if remtrz.fcrc eq remtrz.tcrc then
    remtrz.payment = remtrz.amt.
    else do:

        if acrc.rate[br] = 0 then do:
            message "Банк не покупает " acrc.code.
        undo, retry MM.
        end.

        if ccrc.rate[sr] = 0 then do:
            message "Банк не продает" ccrc.code.
        undo, retry MM.
        end.

        remtrz.margb =
        round(remtrz.amt * acrc.rate[1] / acrc.rate[9]
         - remtrz.amt * acrc.rate[br] / acrc.rate[9] ,acrc.decpnt).

        remtrz.margs =
   round((remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[1]
 - remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[sr] ) * ccrc.rate[1]
    ,acrc.decpnt).

  if remtrz.payment eq 0 then do:
          remtrz.payment = loniss1.
          /* remtrz.payment =
          round( remtrz.amt * acrc.rate[br] / acrc.rate[9] * ccrc.rate[9]
          / ccrc.rate[sr] , crc.decpnt ). */
         end.
 end.
 disp remtrz.payment with frame remtrz.
 end.
 remtrz.outcode =  18.
 disp remtrz.outcode with frame remtrz.
      remtrz.drgl = lon.gl.

      remtrz.dracc = lon.lon.
      remtrz.ord = trim(trim(cif.prefix) + " " + trim(cif.sname)).
      if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "LONl_ps.p 306", "1", "", "").
      end.
      v-pnp =  lon.lon.
 displ v-pnp with frame remtrz.

        find cif where cif.cif eq lon.cif no-lock no-error.
        v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
        tt1 = substring(trim(v-name),1,60).
        tt2 = substring(trim(v-name),61,60).
        remtrz.ord = trim(tt1) + ' ' + trim(tt2).
        if remtrz.ord = ? then do:
         run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "LONl_ps.p 317", "1", "", "").
        end.
        v-reg5 = trim(substr(cif.jss,1,13)).
        v-sname = trim(trim(cif.prefix) + " " + trim(cif.sname)).

        disp v-reg5 remtrz.ord  with frame remtrz.
        pause 0.
        form bila
           tt1 label "ПОЛНОЕ     "
           tt2 label "НАЗВАНИЕ   "
           v-sname label "СОКРАЩЕННОЕ" format "x(60)"
           cif.jss   label "РНН        "  format "x(13)"
           with overlay  1 column row 13 column 1 frame ggg.

    /*  update remtrz.ord
      validate(remtrz.ord ne "","Введите наименование")
      with frame remtrz.
     do on error undo,retry :
        update v-reg5 validate(length(v-reg5) eq 12 , "Введите 12 цифр РНН !")
               with frame remtrz.
        def var v-rnn as log.
        run rnnchk( input v-reg5,output v-rnn).
        if v-rnn then do :
           message "Введите РНН верно ! ". pause.
           /*
           undo, retry.
           */
        end.
      end.    */

      remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
      if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "LONl_ps.p 349", "1", "", "").
      end.
      remtrz.sacc = v-pnp .

do on error undo,retry:

   remtrz.sbank = ourbank. sender = "o".
   remtrz.scbank = ourbank.
   if remtrz.svcrc eq ? or remtrz.svcrc = 0  then remtrz.svcrc = 1 .
   update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
   find first zcrc where zcrc.crc = remtrz.svcrc no-lock no-error .
   if not avail zcrc then undo,retry .
   bcode = zcrc.code .
   display bcode with frame remtrz . pause 0 .
   update remtrz.svccgr with frame remtrz .


   if remtrz.svccgr > 0 then do:
     run comiss.
     find first tarif2 where tarif2.str5 =string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
     if avail tarif2 then pakal = tarif2.pakalp .
     display remtrz.svccgl pakal remtrz.svca with frame remtrz .
   end.
   else
     update remtrz.svca with frame remtrz.

   if remtrz.svca > 0 then do :
      v-chg = 3 .
      {mesg.i  6403}.
      update v-chg validate(v-chg = 1 or v-chg = 3
      ," 1)Касса  3)Счет клиента " ) when remtrz.svca > 0
      with frame remtrz .
      if v-chg = 1 then do:
          remtrz.svcaaa = ""  .
          remtrz.svcgl = v-cashgl.
          display remtrz.svcaaa with frame remtrz . pause 0 .

      end .

    if v-chg = 3 then do:
      update remtrz.svcaaa with frame remtrz.
      find first aaa where aaa.aaa = remtrz.svcaaa and
      aaa.crc = remtrz.svcrc
      no-lock no-error .
      if not avail aaa or remtrz.svcaaa = "" then
      do:
       message "Счет не найден".
       bell. bell.
       undo,retry.
      end.
      remtrz.svcgl = aaa.gl .

         if aaa.sta eq "C" then do:
         bell.
         {mesg.i 6207}.
         undo,retry.
         end.
        s-aaa = remtrz.svcaaa.
        run aaa-aas.
        find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
        no-lock no-error.
        if available aas then do: pause. undo,retry. end.
        find cif of aaa no-lock .
        v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
        tt1 = substring(v-name,1,60).
        tt2 = substring(v-name,61,60).
        v-sname = trim(trim(cif.prefix) + " " + trim(cif.sname)).
        pause 0.
           form bila
           tt1        label "Полное      "
           tt2        label "наименование"
           v-sname label "Сокращенное " format "x(60)"
           cif.jss    label "РНН         "  format "x(13)"
           with overlay  1 columns column 1 row 13 frame eee.
         if available xaaa then do:
           bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
           - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
           - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
           disp  bila tt1 tt2  v-sname cif.jss with frame eee.
           pause .
         end.
         else do:
           bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal
           - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
           - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
           disp  bila tt1 tt2 v-sname cif.jss with frame eee.
           pause .
         end.
     end.
      if v-chg = 4 then do :
        if lon.crc <> remtrz.svcrc then do:
           bell.
           {mesg.i 2203}.
           undo,retry.
        end.
        if remtrz.amt + remtrz.svca > not-iss then do:
           bell.
           message 'Loan open amount exceeded.'.
           undo,retry.
        end.
        remtrz.svcaaa = s-lon.
        remtrz.svcgl = lon.gl.
        disp remtrz.svcaaa with frame remtrz.

     end.
 end.
   do on error undo,retry :
  /*if remtrz.svca <> 0 then do:
     update remtrz.svccgl  with frame remtrz .
     find first gl where  gl.gl = remtrz.svccgl and gl.sub eq "" no-lock
          no-error .
     if not avail gl then undo,retry .
   end. */

 if remtrz.svca = 0 then do:
     remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
     remtrz.svccgl = 0.
 end.
 end.
 display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.

end.






remtrz.detpay[1] =  substring(s-glrem,1,35).
remtrz.detpay[2] =  substring(s-glrem,36,35).

if v-chg eq 1 then
update v-who v-passp v-perkod with frame f_cus.


s-glrem = remtrz.remtrz + " " + s-glrem.
/*
run s-lonfrm(s-glrem, 60).
*/

if v-chg ne 1 then do:
s-glremx[1] = remtrz.remtrz + " " + trim(s-glremx[1]).
s-glremx[2] = trim(s-glremx[2]).
s-glremx[3] = trim(s-glremx[3]).
s-glremx[4] = trim(s-glremx[4]).
s-glremx[5] = trim(s-glremx[5]).
end.
else do:
    s-glremx[5] =
    "/ПЛАТЕЛЬЩИК/" + v-who +
    "/ПАСПОРТ/" + v-passp + "/РНН/" + v-perkod.
end.





remtrz.detpay[3] =  substring(s-glrem,71,35).
remtrz.detpay[4] =  substring(s-glrem,106).




update remtrz.detpay[1] remtrz.detpay[2] with frame remtrz.
find first ptyp where  remtrz.ptype = ptyp.ptype no-lock no-error .
if not avail ptyp then remtrz.ptype = "N" .

remtrz.valdt1 = g-today .
remtrz.source = 'LON'.
remtrz.rwho  = g-ofc.

remtrz.chg = 7.     /*   to  outgoing process     */

/* заполнение кодов ЕКНП */
  def var v-pr as char.
  repeat while v-pr ne '0'.
    run subcod(s-remtrz,'rmz').
    if keyfunction(lastkey) eq "end-error" then
       repeat while lastkey ne -1 :
       readkey pause 0.
    end.
    /* контроль  */
    run k-eknp(output v-pr).
  end.

run rmzque .
pause 0.

end.


run islonltrz.

pause 0.
find first jl where jl.jh = s-jh no-lock no-error.
if not available jl
then do transaction :
     find que where que.remtrz = remtrz.remtrz exclusive-lock.
     que.pid = "D".
     remtrz.jh1 = ?.
     message "Транзакция не сделана !".
     pause.
end.
