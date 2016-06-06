 /* psroup-2.p
 * MODULE
	Платежная система
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
 * BASES
        BANK COMM
 * AUTHOR
        01/07/2004 dpuchkov
 * CHANGES
         08.01.2004 dpuchkov - добавил редактирование описания клиента
         15.09.2004 dpuchkov - огрраничение пользователей напросмотр реквизитов
         08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
         24.06.2005 saltanat - Включила возможность выбора филиалов, если таковые имеются.
         18.07.2005 saltanat - Убрала имя клиента и редактируемость РНН.
	 30.05.2006 u00121   - если департамент офицера не Центральный офис и это Алматы, то всегда работаем только через кассу в пути ТЗ ї220 от 17/02/2006
*/

{global.i}
{get-dep.i}
{comm-txb.i}
def var v-chksts as integer.
def var l-ans    as logical.
def var v-val    as integer.

/*u00121 30/05/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/


def buffer acrc for crc.
def buffer bcrc for crc.
def buffer ccrc for crc.
def buffer dcrc for crc.
def buffer zcrc for crc. 
def shared var s-remtrz like remtrz.remtrz.
def shared var v-ref as cha format "x(10)".
def shared var v-pnp as cha format "x(10)".
def var acode like crc.code.
def var bcode like crc.code.
def var ccode like crc.code.
def var s-bank like bankl.bank.
def shared frame remtrz.
def shared var v-comgl as inte.
def shared var v-regnom as char format "x(12)".

def var prilist like sysc.chval.
def var amt1 like remtrz.amt.
def var amt2 like remtrz.amt.
def var amt3 like rem.amt.
def var amtp like rem.amt.

define buffer b-cif for cif.
define buffer b-aaa for aaa.
define buffer d-aaa for aaa.
define buffer d-cif for cif.
DEF buffer xaaa for aaa.
DEF var bila like aaa.cbal label "ОСТАТОК".
def var com1 like rem.amt.
def var com2 like rem.amt.
def var com3 like rem.amt.
def var br as int format "9".
def var sr as int format "9".
def var ii as inte initial 1.
def var pakal  as char.
def var v-sumkom like remtrz.svca.
def var v-uslug as char format "x(10)".
def var ee1 like tarif2.num.
def var ee2 like tarif2.kod.
def var v-numurs as char format "x(10)".
def shared var v-reg5 as char format "x(12)".
def new shared var ee5 as char format "x".
def new shared var s-aaa like aaa.aaa.
def var i6 as int.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def shared var v-chg as integer.
def var ourbank like bankl.bank.
def var sender as cha.
def var v-cashgl like gl.gl.
def var v-priory as cha format "x(8)".
def var v-rnn as log.
def var s-cif as char.
def var s-rnn as char.

{lgps.i}

{psror-2.f}

{comchk.i}


def temp-table vgl
    field vgl as inte.
def var vgldes as char.


ee5 = "2" . 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Запись OURBNK отсутствует в файле sysc !!".
  pause .
  undo .
  return .
end.
ourbank = sysc.chval.

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
      message " Запись RMCASH отсутствует в файле sysc . " .
      return.
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

find sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display ' Запись PRI_PS отсутствует в файле sysc !! '.
  pause . undo . return .
  end.
else  prilist = sysc.chval.



do transaction :

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock.



if remtrz.svcaaa ne "" then  v-chg = 3 .
else
if remtrz.svcgl  ne 0  then  v-chg = 1 .
display v-chg with frame remtrz. pause 0 .
if remtrz.jh1 ne ? then return .
display remtrz.remtrz with frame remtrz .
pause 0 . 
find dcrc where dcrc.crc = 1 no-lock.

if remtrz.rdt = ? then  remtrz.rdt = g-today.
    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp.
    display pakal with frame remtrz .
    pause 0 . 
do on error undo,retry:
 v-ref = substr(remtrz.sqn,19).  
 update v-ref validate (v-ref ne "" ,"Введите номер платежного поручения!")
  with frame remtrz.
 remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + v-ref.

 
 disp v-priory  with frame remtrz.
 
 
 remtrz.cover = 3.
 display remtrz.cover with frame remtrz.

 disp remtrz.rdt
       with frame remtrz.
end.

MM:

do on error undo,retry:
update remtrz.fcrc validate(can-find(crc where crc.crc = remtrz.fcrc) and ((remtrz.fcrc = 1 and m_pid = "P") or (remtrz.fcrc <> 1 and m_pid <> "P")), "")
       with frame remtrz.


find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0 no-lock no-error.
        if not available acrc  then do:
            message "Статус валюты <> 0 " .
        undo, retry.
        end.

      acode = acrc.code.
   disp acode with frame remtrz.

   update  remtrz.amt validate( remtrz.amt > 0 ,"") with frame remtrz.
   remtrz.info[6] = replace(remtrz.info[6],"payment","amt").
   if not remtrz.info[6] matches  "*amt*" then remtrz.info[6] = 
   remtrz.info[6] + " amt". 
   remtrz.amt = round ( remtrz.amt , acrc.decpnt ) .
   display remtrz.amt with frame remtrz.
   remtrz.payment = remtrz.amt.
   remtrz.tcrc = remtrz.fcrc.

   displ remtrz.tcrc with frame remtrz.

find crc where crc.crc = remtrz.tcrc and crc.sts = 0 no-lock no-error.  
        disp crc.code with frame remtrz.
find ccrc where ccrc.crc = remtrz.tcrc no-lock.   /* new */
remtrz.margb = 0. remtrz.margs = 0.

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
            message "Банк не продает " ccrc.code.
        undo, retry MM.
        end.

        remtrz.margb =
        round(remtrz.amt * acrc.rate[1] / acrc.rate[9]
         - remtrz.amt * acrc.rate[br] / acrc.rate[9] ,dcrc.decpnt).

        remtrz.margs =
   round((remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[1]
 - remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[sr] ) * ccrc.rate[1]
    , dcrc.decpnt).

  if remtrz.payment eq 0 then do:
          remtrz.payment =
          round( remtrz.amt * acrc.rate[br] / acrc.rate[9] * ccrc.rate[9]
          / ccrc.rate[sr] , crc.decpnt ).
         end.
 end.
 disp remtrz.payment with frame remtrz.
 end.
do on error undo,retry:
 {mesg.i 10000}.
 update remtrz.outcode with frame remtrz.
 
  if remtrz.outcode < 1 or 
   ( remtrz.outcode > 7 and m_pid = 'O' ) 
   or 
   ( remtrz.outcode > 8 and m_pid = 'P' )
   or remtrz.outcode = 2 then do:
       bell.
       undo, retry.
     end.
   
   
if remtrz.outcode = 1 then 
do: 
	run get100200arp(g-ofc, remtrz.fcrc, output v-yn, output v-arp, output v-err). /*u00121 13/04/06 получим признак разрешения работы только через кассу в пути*/
	if not v-yn then
	do: /*если разрешено работать через кассу, то работатем по старому*/
		find sysc where sysc.sysc = "RMCASH" no-lock no-error.
		if not available sysc then do:
			message "Проверьте установку  RMCASH в файле sysc !".
			undo.
		end.
		find gl where gl.gl = sysc.inval no-lock no-error.
		if not available gl then do:
			message "Проверьте установку  RMCASH в файле sysc !".
			undo.
		end.
		remtrz.drgl = gl.gl.
		remtrz.dracc = ''.
		remtrz.sacc = ''.
	end.
	else
	do:
		remtrz.drgl = 100200.
		remtrz.dracc = v-arp.
		remtrz.sacc = v-arp.
	end.
	v-pnp = ''.
	if remtrz.outcode entered then do: 
		v-sub5 = '' . v-reg5 = ''. remtrz.ord = '' .  
	end.
	if index(remtrz.ord,"/RNN/") ne 0 then do :
		v-reg5 = substr(remtrz.ord,index(remtrz.ord,"/RNN/") + 5).
		remtrz.ord = substr(remtrz.ord,1,index(remtrz.ord,"/RNN/") - 1).
	end.
	display v-pnp remtrz.ord v-reg5 v-sub5 with frame remtrz.
	{updtord-533.i}
	do on error undo,retry :
		update v-reg5 validate(length(v-reg5) eq 12 , "Введите 12 цифр РНН !") 
		with frame remtrz.
		run rnnchk( input v-reg5,output v-rnn).
		if v-rnn then do :
		message "Введите РНН верно ! ". pause .
	end.
	end.
	remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
	{vccheckp.i}.
end. /* if remtrz.outcode = 1 */


  if remtrz.outcode = 8 then do:
   if m_pid = "P" then do:
    find sysc where sysc.sysc = "CELRMZ" no-lock no-error.
    if not available sysc then do:
       message "Запись CELRMZ отсутствует в файле sysc !".
       undo.
     end.
     find gl where gl.gl = sysc.inval no-lock no-error.
     if not available gl then do:
       message "Проверьте CELRMZ в файле sysc !".
       undo.
     end.
     remtrz.drgl = gl.gl.
     remtrz.ord = gl.des. 
     v-pnp = ''.
     remtrz.dracc = ''.
     remtrz.sacc = ''.
     if v-chg <> 3 then do: 
        v-sub5 = '' . v-reg5 = ''. 
      end.
     display v-pnp remtrz.ord v-reg5 v-sub5 with frame remtrz.
     end.
  end.
   if remtrz.outcode = 4 then  do on error undo , retry :
      update v-pnp with frame remtrz.
      find dfb where dfb.dfb = v-pnp no-lock no-error. /* new */
      if not available dfb then do:
         bell.
         {mesg.i 8916}.
          undo, retry.
      end.
      else if dfb.crc ne remtrz.fcrc then do:
               bell.
               {mesg.i 9813}.
               undo,retry.
      end.
      else do:
           remtrz.dracc = v-pnp.
           if v-sub5 <> '' then
            remtrz.sacc = v-pnp + "/" + v-sub5 .
           else
            remtrz.sacc = v-pnp .
           remtrz.drgl = dfb.gl.
           v-reg5 = "" . 
           remtrz.ord = "" . 
      end.
      disp dfb.name remtrz.ord v-reg5 v-sub5 with frame remtrz.
      pause 0 . 
   end.
   else if remtrz.outcode = 3 then do:
      v-pnp = remtrz.dracc.
      if index(remtrz.sacc,"/") <> 0 then do :
       v-pnp = substr(remtrz.sacc,1,index(remtrz.sacc,"/") - 1) .
       v-sub5 = substr(remtrz.sacc,index(remtrz.sacc,"/") + 1) .
      end .
      else do :
       v-pnp = remtrz.sacc.
       v-sub5 = "" .
      end .
      update v-pnp with frame remtrz.

/**/

find aaa where aaa.aaa = v-pnp no-lock no-error.
if avail aaa then 
do:
   find cif where cif.cif = aaa.cif  no-lock no-error.

   find last cifsec where cifsec.cif = cif.cif no-lock no-error.
   if avail cifsec then
   do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "5.3.14 Оплата налогов юр.лицом за филиалы".
          message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
          return.
     end.
     else
     do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = cif.cif
            ciflogu.menu = "5.3.14 Оплата налогов юр.лицом за филиалы".
     end.

   end.

end.
/**/



 find aaa where aaa.aaa = v-pnp no-lock no-error. /* new */
 if avail aaa then find first lgr where lgr.lgr = aaa.lgr no-lock no-error .
      if not available aaa then do:
        bell.
         {mesg.i 2203}.
         undo,retry.
      end.
    else if avail lgr and lgr.led = "ODA" then do:
        Message " Счет типа ODA   " .
        pause .
         undo,retry.
     end.
    else do:
        remtrz.dracc = v-pnp.
        if v-sub5 <> '' then
         remtrz.sacc = v-pnp + "/" + v-sub5 .
        else
         remtrz.sacc = v-pnp .
        remtrz.drgl = aaa.gl.
      end.
           s-aaa = v-pnp.
           run aaa-aas.
           find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
           no-lock no-error.
           if available aas then do: pause. undo,retry. end.
      if aaa.crc ne remtrz.fcrc then do:
         bell.
         {mesg.i 9813}.
         undo,retry.
      end.
      if aaa.sta eq "C" then do:
         bell.
         {mesg.i 6207}.
         undo,retry.
      end.
        find cif of aaa no-lock no-error.
        tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
        tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
s-cif = cif.cif.
s-rnn = ''.
if cif.type = "b" then do:
  update remtrz.ord with frame remtrz.
end.
        if s-rnn ne '' then v-reg5 = s-rnn.
        else
        v-reg5 = trim(substr(cif.jss,1,13)).
              
        disp v-reg5 v-sub5 remtrz.ord  with frame remtrz.
        pause 0.
        form bila
           tt1 label "ПОЛНОЕ-----"
           tt2 label "--НАЗВАНИЕ "
           cif.lname  label "СОКРАЩЕННОЕ" format "x(60)"
           cif.pss   label "ИДЕНТ.КАРТА"
           cif.jss   label "РЕГ.НОМЕР "  format "x(13)"
           with overlay  1 column row 13 column 1 frame ggg.
      if aaa.craccnt ne "" then
        find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error .
      if available xaaa then do:

       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
       disp  bila tt1 tt2  cif.lname cif.pss cif.jss with frame ggg.
       pause .
      end.
      else do:
       bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal  .
       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
       pause .

      end.

      {updtord-533.i}
      update v-sub5 with frame remtrz.
      remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
      if v-sub5 <> '' then
        remtrz.sacc = v-pnp + "/" + v-sub5 .
       else
        remtrz.sacc = v-pnp .
        {vccheckp.i}. 
    end.
   else if remtrz.outcode = 5 then do:
      update v-pnp with frame remtrz.
      find eps where eps.eps = v-pnp no-lock no-error.
      if not available eps then do:
         bell.
         {mesg.i 2203}.
         undo,retry.
      end.
      else do:
       remtrz.dracc = v-pnp.
       if v-sub5 <> '' then
        remtrz.sacc = v-pnp + "/" + v-sub5 .
       else
        remtrz.sacc = v-pnp .
       remtrz.drgl = eps.gl.
      end.
      if eps.crc ne remtrz.fcrc then do:
         bell.
         {mesg.i 9813}.
         undo,retry.
      end.
        remtrz.ord = eps.ref .
        v-reg5 = "" .
        display v-sub5 v-reg5 with frame remtrz . pause 0 . 
        /*update remtrz.ord with frame remtrz.*/
        {updtord-533.i}
    end.
   else if remtrz.outcode = 7 then do:
      update v-pnp with frame remtrz.
      find ock where ock.ock = v-pnp no-lock no-error.
      if not available ock then do:
         bell.
         {mesg.i 2203}.
         undo,retry.
      end.
      else do:
       remtrz.dracc = v-pnp.
       if v-sub5 <> '' then
        remtrz.sacc = v-pnp + "/" + v-sub5 .
       else
        remtrz.sacc = v-pnp .
       remtrz.drgl = ock.gl.
      end.
      if ock.crc ne remtrz.fcrc then do:
         bell.
         {mesg.i 9813}.
         undo,retry.
      end.
      find gl where gl.gl = ock.gl no-lock no-error.
      if gl.type eq "A" then do :
         if ock.dam[gl.level] - ock.cam[gl.level] ne remtrz.amt then
         do :
           bell.
           Message "Сумма чека   " + 
           string(ock.dam[gl.level] - ock.cam[gl.level]) + "!". pause.
           undo,retry.
         end.
      end.
      if gl.type eq "L" then do :
         if ock.cam[gl.level] - ock.dam[gl.level] ne remtrz.amt then
         do:
           bell.
           Message "Сумма чека   " +
           string(ock.cam[gl.level] - ock.dam[gl.level]) + "!". pause.
           undo,retry.
         end.
      end.
        remtrz.ord = ock.ref .
        v-reg5 = "" .
        display v-sub5 v-reg5 with frame remtrz . pause 0 . 
        {updtord-533.i}
    end.

   else if remtrz.outcode = 6 then do:
      update v-pnp with frame remtrz.
      find arp where arp.arp = v-pnp no-lock no-error.
      if not available arp then do:
         bell.
         {mesg.i 2203}.
         undo,retry.
      end.
      else do:
       remtrz.dracc = v-pnp.
       if v-sub5 <> '' then
        remtrz.sacc = v-pnp + "/" + v-sub5 .
       else
        remtrz.sacc = v-pnp .
       remtrz.drgl = arp.gl.
      end.
      if arp.crc ne remtrz.fcrc then do:
         bell.
         {mesg.i 9813}.
         undo,retry.
      end.
        remtrz.ord = arp.des .
        v-reg5 = "" .
        display v-sub5 v-reg5 with frame remtrz . pause 0 .
        {updtord-533.i}
    end.
 find first sysc where sysc.sysc = "GLARPB" no-lock no-error . 
  if avail sysc then do: 
   if ( string(remtrz.drgl) >= entry(1,sysc.chval) and 
        string(remtrz.drgl) <= entry(2,sysc.chval) ) or 
      ( string(remtrz.drgl) >= entry(3,sysc.chval) and
      string(remtrz.drgl) <= entry(4,sysc.chval) ) 
    then do:
    Message " Внебалансовый счет Главной Книги . " . pause . 
    undo,retry . 
    end.
  end . 
 end.


do on error undo,retry:

   remtrz.sbank = ourbank. sender = "o". 
   if remtrz.svcrc eq ? or remtrz.svcrc = 0  then remtrz.svcrc = 1 .
   update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
   find first zcrc where zcrc.crc = remtrz.svcrc no-lock no-error . 
   if not avail zcrc then undo,retry . 
   bcode = zcrc.code . 
   display bcode with frame remtrz . pause 0 . 

   /* определение кода комиссии */
   if remtrz.svccgr = 0 and remtrz.fcrc <> 1 then do:
     find bankl where bankl.bank = remtrz.rbank no-lock no-error.
     if not avail bankl or bankl.nu = "n" then do:
       /* если это внешний валютный платеж, то проставить по умолчанию комиссию за счет отправителя */
       {comdef.i &cif = " cif.cif "}
     end.
   end.
   
   update remtrz.svccgr validate (chkkomcod (remtrz.svccgr), v-msgerr) with frame remtrz .
   if remtrz.svccgr > 0 then do:
     run comiss2 (output v-komissmin, output v-komissmax).

     find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
     if avail tarif2 then pakal = tarif2.pakalp .
     display remtrz.svccgl pakal remtrz.svca with frame remtrz .
   end.
   if (remtrz.svccgr > 0 and remtrz.svca = 0 ) or remtrz.svccgr = 0 then  
      update remtrz.svca validate (chkkomiss(remtrz.svca), v-msgerr) 
        with frame remtrz.
   
 if remtrz.svca > 0 then do:
   if sender = "o" and remtrz.dracc ne "" and remtrz.svcrc = remtrz.fcrc
   and remtrz.svcaaa eq "" and remtrz.outcode = 3 and 
     ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl )
   then  remtrz.svcaaa = remtrz.dracc.

   if remtrz.outcode  eq 3  then  v-chg = 3 .
   else
   v-chg = 1 .
   update v-chg validate(v-chg = 1 or v-chg = 3 ," 1)Cash  3)Customer-Acct " )
    with frame remtrz .  
   if v-chg = 1 then 
   do: 
			run get100200arp(g-ofc, remtrz.svcrc, output v-yn, output v-arp, output v-err). /*u00121 13/04/06 получим признак разрешения работы только через кассу в пути*/
			if not v-yn then
			do:
			    remtrz.svcaaa = ""  . 
			    remtrz.svcgl = v-cashgl.
			end.
			else
			do:
				remtrz.svcaaa = v-arp  . 
				remtrz.svcgl = 100200.
			end.

    display remtrz.svcaaa with frame remtrz . pause 0 . 
   end . 
    else 
    do on error undo,retry :
     if remtrz.outcode = 3 
        then remtrz.svcaaa = v-pnp.

      update remtrz.svcaaa with frame remtrz.
      find first aaa where aaa.aaa = remtrz.svcaaa and aaa.crc = remtrz.svcrc
      no-lock no-error .

      /* sasco - проверка кода счета клиента комиссии */
      if remtrz.outcode = 3 then do:
         find b-aaa where b-aaa.aaa = v-pnp no-lock no-error.
         if not available b-aaa then undo,retry.
         find b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
         find b-aaa where b-aaa.aaa = remtrz.svcaaa no-lock no-error.
         if not available b-aaa then undo,retry.
         if b-aaa.cif <> b-cif.cif then do:
            message "Не тот клиент!" view-as alert-box title ''.
            undo, retry.
         end.
      end.

      if not avail aaa or remtrz.svcaaa = "" then undo,retry .
      remtrz.svcgl = aaa.gl .
  
      if aaa.sta eq "C" then do:
         bell.
         {mesg.i 6207}.
         undo,retry.
      end.
        s-aaa = remtrz.svcaaa.
        run aaa-aas.
        find first aas where aas.aaa = s-aaa no-lock no-error . 
        if avail aas then pause .
        find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
        no-lock no-error.

        if available aas then do: pause. undo,retry. end.
        find cif of aaa no-lock .
        tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
        tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
        pause 0.
      form bila
           tt1 label "PILNAIS----"
           tt2 label "--NOSAUKUMS"
           cif.lname  label "SA§SINATAIS" format "x(60)"
           cif.pss   label "IDENT.KARTE"
           cif.jss   label "REІ.NUMURS"  format "x(13)"
           with overlay  1 columns column 1 row 13 frame eee.
         if available xaaa then do:
           bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
           - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
           - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
           disp  bila tt1 tt2  cif.lname cif.pss cif.jss with frame eee.
           pause .
          end.
         else do:
           bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal
           - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
           - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
           disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame eee.
           pause .
         end.
         if remtrz.outcode <> 3 
         then do:
           v-reg5 = trim(substr(cif.jss,1,13)).
           remtrz.ord = trim(trim(cif.prefix) + " " + trim(cif.name)).
           disp v-sub5 v-reg5 remtrz.ord with frame remtrz .
           update  remtrz.ord  
           validate(remtrz.ord ne "","Введите наименование")
           v-sub5 with frame remtrz . 

           do on error undo,retry :
             update v-reg5 validate(length(v-reg5) eq 12 , 
                "Введите 12 цифр РНН !")
                with frame remtrz.
             run rnnchk( input v-reg5,output v-rnn).
             if v-rnn then do :
               message "Введите РНН верно ! ". pause.
             end.
           end.
           
           remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
         end.
    end.
 end.
 else do:
     remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
     remtrz.svccgl = 0.
 end.


 display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.

end.



update remtrz.detpay[1] go-on("return") with frame detpay .


find first ptyp where  remtrz.ptype = ptyp.ptype no-lock no-error . 
if not avail ptyp then remtrz.ptype = "N" . 

remtrz.valdt1 = g-today . 

remtrz.chg = 7.     /*   to  outgoing process     */
run subcod(s-remtrz,'rmz').
    if keyfunction(lastkey) eq "end-error" then
        repeat while lastkey ne -1 :
         readkey pause 0.
        end.
                     

run rmzque . 


  run chgsts(input "rmz", remtrz.remtrz, "new").
 if m_pid = "P" then do:
  find ofc where ofc.ofc eq g-ofc no-lock. 
   remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
  + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
   fill(' ' , 12 - length(trim(remtrz.sbank))) +
   (trim(remtrz.dracc) +
   fill(' ' , 10 - length(trim(remtrz.dracc))))
   + substring(string(g-today),1,2) + substring(string(g-today),4,2)
   + substring(string(g-today),7,2).
  end . 
end.

