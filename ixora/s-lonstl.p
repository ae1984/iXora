/* s-lonstl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оплата кредита
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-1-1  Оплата
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
   20.10.2003 marinav - Добавился шаблон lon0064 для оплаты штрафов
   03/12/2004 madiar - добавил в примечания сумму погашаемых штрафов
   13/12/2005 madiar - добавил для информации сумму долга по комиссиям sds-com (без возможности оплаты)
        04/05/06 marinav Увеличить размерность поля суммы
*/

{lonlev.i}
def var v-bal like glbal.bal.

def shared var s-lon like lon.lon.
def new shared var s-gl like gl.gl.     /* payment gl # */
define new shared variable s-gljl like gl.gl.
def new shared var s-acc like jl.acc.   /* payment acct # */
define variable vacc like jl.acc.
def new shared var ppay like lon.opnamt.
def new shared var ipay like lon.opnamt.
define new shared variable s-rmz like remtrz.remtrz.
define new shared variable spay as decimal.
define new shared variable spay1 as decimal.
define new shared variable apay  as decimal.
define new shared variable apay1 as decimal.
define new shared variable algpay as decimal.
define new shared variable algpay1 as decimal.
define new shared variable sds-pay as decimal.
define new shared variable sds-pay1 as decimal.
define new shared variable sds-gl like gl.gl.
define new shared variable a-gl like gl.gl init 0.
def new shared var s-ptype as int format "z" init 1.
define new shared variable s-crc like crc.crc.
define new shared variable penlpay as decimal.
define new shared variable penlpay1 as decimal.
def var penipay like lon.opnamt.
def new shared var s-jh like jh.jh.
def var v-f0 like lnsch.f0.
def var v-flp like lnsch.flp.
def var v-del like lnsch.stval.
def new shared var s-vint like lnsci.iv.
def new shared var marked like lnsci.paid-iv.
define new shared variable s-acr as decimal.
def new shared var s-aaa like aaa.aaa.
define variable v-name as character.
define new shared variable ppay1 as decimal.
define new shared variable ipay1 as decimal.

define variable v-code as character.
define variable v-code1 as character.
define variable v-cd as character.
define variable v-cd1 as character.
define variable vcd as character.
define variable vcd1 as character.
define variable acd as character.
define variable acd1 as character.
define variable sds-cd as character.
define variable sds-cd1 as character.
define variable algcd as character.
define variable algcd1 as character.
define variable sds as decimal.
define variable sds-com as decimal.
define variable dam-cam1 as decimal.
define variable v-glcash like gl.gl.
define variable kurss as decimal.
define variable dn1 as integer.
define variable dn2 as decimal.
define variable k-p as character.
define variable rcd as logical.
define new shared variable s-falon like falon.falon.
define variable sds-ind as logical.

define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define new shared variable rc as integer.
define variable ja as logical init no format "да/нет".

/*---- variables for leasing ------*/
{s-lonliz.i "NEW"}
define variable lon-avn as  decimal.      /* avanss */
define variable avn-apm as  decimal.      /* apmaks–ts avanss */
define variable lon-avncrc  as character. /* avansa val­ta */
define variable pvn-sum as  decimal.      /*summa  PVN */
define variable avn-atl as  decimal.      /* apmaks–t PVN % */
define variable avn-atlcrc  as character. /* valuta apmaks. PVN% */
define variable noform-sum  as decimal.   /* summa par noformёЅanu */
define variable noform-crc  as character. /* noformёЅanas val­ta */
/*define variable noform-pay1 as decimal.   /* apmaks–t noformёЅanu */*/
define variable noform-crc1 as character. /* noformёЅanas val­ta */
define variable atalg-sum   as decimal.   /* summa par noformёЅanu */
define variable atalg-crc   as character. /* atalgojuma val­ta */
/*define variable atalg-pay1  as decimal.   /* apmaks–t lizinga atalgojums */*/
define variable atalg-crc1  as character. /* atalgojuma val­ta */
define variable total-sum   as decimal.   /* kopёja summa */
define variable total-crc   as character. /* val­ta */
define variable total-crc1  as character. /* val­ta */
/*define variable total-pay1  as decimal.   /* kopёja summa uz maksaЅ–nu*/
define variable avnpay1     as decimal.
define variable pvnpay1     as decimal.*/
define variable v-avncrc    as character.
define variable v-avncrc1   as character.
define variable v-pvncrc    as character.
define variable v-pvncrc1   as character.
define variable ppay-save   as decimal.
define variable ppay1-save   as decimal.

           def var vbal like jl.dam.
           def var vavl like jl.dam.
           def var vhbal like jl.dam.
           def var vfbal like jl.dam.
           def var vcrline like jl.dam.
           def var vcrlused like jl.dam.
           def var vooo like aaa.aaa.
           def buffer bcrc for crc.


define variable damu_v-cd1 as character.
def new shared var damu_ipay1 as dec.
def new shared var damu_v-intod as dec.
def var damu_v-iodcrc1 like crc.code.
def new shared var damu_v-payiod1 as dec.
def new shared var damu_v-4ur as dec.
def var damu_v-odcrc4 like crc.code.

define variable astana_v-cd1 as character.
def new shared var astana_ipay1 as dec.
def new shared var astana_v-intod as dec.
def var astana_v-iodcrc1 like crc.code.
def new shared var astana_v-payiod1 as dec.
def new shared var astana_v-4ur as dec.
def var astana_v-odcrc4 like crc.code.


def new shared var v-amtod as dec.
def new shared var v-intod as dec.
def new shared var v-amtbl as dec.
def new shared var v-payod as dec.
def new shared var v-payiod as dec.
def new shared var v-payiod1 as dec.
def new shared var v-paybl as dec.
def new shared var v-payod1 as dec.
def new shared var v-paybl1 as dec.



def var v-odcrc like crc.code.
def var v-odcrc1 like crc.code.
def var v-iodcrc like crc.code.
def var v-iodcrc1 like crc.code.

def var v-blcrc like crc.code.
def var v-blcrc1 like crc.code.
def var v-who as char format "x(50)".
def var v-passp as char .
def var v-perkod as char format "x(50)".
def var i as int.
define frame f_cus
    v-who   label "ПОЛУЧАТЕЛЬ " skip
    v-passp  label "ПАСПОРТ    "  format "x(320)" view-as fill-in size 50 by 1
    skip
    v-perkod label "ПЕРС.КОД   "
    with row 15 col 16 overlay side-labels.






find lon where lon.lon = s-lon no-error.
find loncon where loncon.lon = lon.lon no-lock.

/*
dam-cam1 = lon.dam[1] - lon.cam[1].
*/

find falon where falon.falon = lon.lon no-lock no-error.
if loncon.sods2 > 0 or lon.gua = "LK"
then sds-ind = yes.
else sds-ind = no.
if sds-ind and available falon
then sds = falon.dam[2] - falon.cam[2].
else sds = 0.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon
and trxbal.lev eq 16 no-lock no-error.
if available trxbal then  sds = trxbal.dam - trxbal.cam.

sds-com = 0.
for each bxcif where bxcif.cif = lon.cif no-lock:
  sds-com = sds-com + bxcif.amount.
end.

run clear-fg("C").
/*
run f-longl(lon.gl,"sa%gl,lon%gl,glsoda%",output ok).
if not ok
then do:
     bell.
     message lon.lon " - s-lonstj:"
             "longl не определен счет".
     pause.
     return.
end.

*/

{global.i}
{x-eomint.f}
{x-eomintl.i}

dam-cam1 = v-bal.
s-acr = vinttday.
s-crc = lon.crc.
apay = 0.
apay1 = 0.
sds-pay = 0.
sds-pay1 = 0.
algpay =  0.
algpay1 =  0.
find sysc where sysc.sysc = "cashgl" no-lock.
v-glcash = sysc.inval.

lon-avn    = 0.
pvn-sum    = 0.
noform-sum = 0.
atalg-sum  = 0.
total-sum  = 0.

avnpay = 0.
pvnpay = 0.
noform-pay = 0.
atalg-pay = 0.
total-pay = 0.
avnpay1 = 0.
pvnpay1 = 0.
noform-pay1 = 0.
atalg-pay1 = 0.
total-pay1 = 0.

if lon.gua <> "LK" then lon-pvn = 0.
else do:
   find first lonhar where lonhar.lon = lon.lon and lonhar.ln = 1
   no-lock no-error.
   if lonhar.rez-char[3]  <> ""  then lon-pvn = decimal(lonhar.rez-char[3]).
   else lon-pvn = 0.
   /*if lonhar.rez-char[4]  <> ""  then pvn-sum = decimal(lonhar.rez-char[4]).
       else pvn-sum = 0.*/
   pvn-sum = 0.

   /*find first lonliz where lonliz.lon = lon.lon no-lock no-error.
   if available lonliz then do:
      pvn-sum    = pvn-sum - (lonliz.cam[2] - lonliz.dam[2]).
   end.*/
end.

{s-lonstll.f}

upper:
do on error undo, retry  on endkey undo,return:
   readkey pause 0.
   repeat /* on endkey undo, return */ :
      find crc where crc.crc = lon.crc no-lock.
      kurss = crc.rate[9] / crc.rate[5].
      v-code = crc.code.
      v-code1 = v-code.
      v-odcrc = crc.code.
      v-odcrc1 = crc.code.
      v-blcrc = crc.code.
      v-blcrc1 = crc.code.
      v-iodcrc = crc.code.
      v-iodcrc1 = crc.code.


      v-cd = v-code.
      v-cd1 = v-cd.
      algcd = v-code.
      algcd1 = v-code.
      vcd = v-code.
      vcd1 = v-cd.
      acd = v-code.
      acd1 = v-code.
      sds-cd = 'KZT'.
      sds-cd1 = 'KZT'.
      v-pvncrc = v-code.
      v-pvncrc1 = v-pvncrc.
      total-crc = v-code.
      total-crc1 = total-crc.
      display v-code1 v-code
      v-odcrc
      v-odcrc1
      v-blcrc
      v-blcrc1
      v-iodcrc
      v-iodcrc1

      /*
      v-pvncrc1 v-pvncrc
      */
      v-cd1 v-cd

      sds-cd1 sds-cd sds-com
      /*
      vcd1 vcd
      algcd1 algcd
      */
      total-crc total-crc1 /* acd1 acd */
      vacc s-glrem with frame lon.

      update s-ptype validate(s-ptype eq 1 or s-ptype eq 3
      or s-ptype eq 4 or s-ptype eq 9, "")
      go-on("PF4") with frame lon.

      if lastkey = keycode("PF4")
      then return.
      if s-ptype = 1 or s-ptype = 9
      then do:
        s-gl = 0.
        v-name = "СПИСАНИЕ".
        if s-ptype eq 1 then do:
           s-gl = v-glcash.
           v-name = "Оплата наличными".
        end.
        display s-gl v-name with frame lon.
      end.

      if s-ptype = 2
      then do:
           find sysc where sysc.sysc eq "OCGL" no-lock.
           s-gl = sysc.inval.
           v-name = "°eks".
           display s-gl v-name with frame lon.
      end.

      if s-ptype = 3
      then do:
           k-p = " Счет".
           display k-p with frame lon.
           update vacc with frame lon.
           s-acc = vacc.
           find aaa where aaa.aaa = s-acc no-error.
           if not available aaa
           then do:
                bell.
                {mesg.i 2208}.
                undo,retry.
           end.
           if aaa.sta eq "C"
           then do:
                bell.
                {mesg.i 6207}.
                undo,retry.
           end.
           find cif where cif.cif = aaa.cif no-lock.
           v-name = s-acc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
           if cif.jss ne "" then v-name = v-name + " РНН " + cif.jss.
           s-aaa = s-acc.


           find bcrc where bcrc.crc = aaa.crc no-lock no-error.
           run aaa-bal777(input s-aaa, output vbal,output vavl, output vhbal,
           output vfbal, output vcrline, output vcrlused, output vooo).

           message "Входящий остаток: " string(vavl, "->>>,>>>,>>9.99")
           " " bcrc.code.
           pause no-message.

           run aaa-aas.
           find first aas where aas.aaa = s-aaa and
                aas.sic = 'SP' no-lock no-error.
           if available aas
           then do:
                pause.
                undo,retry.
           end.
           s-gl = aaa.gl.
           s-crc = aaa.crc.
           display s-crc s-gl v-name with frame lon.
      end.
      if s-ptype = 4
      then do:
           find sysc where sysc.sysc eq "RMPY1G" no-lock.
           s-gl = sysc.inval.
           v-name = "Входящий перевод".
           find sysc where sysc.sysc = "BILEXT" no-lock.
           do:
                k-p = "#перев.".
                display s-gl k-p v-name with frame lon.
                update vacc with frame lon.
                s-acc = vacc.

                run chklonps(s-acc,"LON",output rcd).
                if not rcd
                then do:
                     message "Нет такого перевода !".
                     pause.
                     undo,retry.
                end.
                find remtrz where remtrz.remtrz = s-acc no-lock.
                s-crc = remtrz.tcrc.
                s-rmz = remtrz.remtrz.
                s-acc = "".
                if trim(remtrz.INFO[10]) <> ""
                then do:
                     s-gl = integer(trim(remtrz.INFO[10])).
                     display s-gl with frame lon.
                end.
                find crc where crc.crc eq remtrz.fcrc no-lock no-error.
                v-name = v-name + " - summa " + string(remtrz.payment) + " "
                + crc.code .



if remtrz.sacc <> ? then v-name = v-name + " " + trim(remtrz.sacc).

if remtrz.ord <> ? then v-name = v-name + " " + trim(remtrz.ord).

def var o_ordins as char.



if remtrz.sbank begins "TXB" then do:
find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
 if available bankl and bankl.name <> "" then do:
  o_ordins = trim(bankl.name).
 end.
 else do:
   if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
   if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[2]).
   if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[3]).
   if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[4]).
 end.
end.
else do:
 if remtrz.ordins[1] = "NONE" then do:
    find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
    if available bankl and bankl.name <> "" then do:
      o_ordins = trim(bankl.name).
    end.
 end.
 else do:
   if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
   if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[2]).
   if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[3]).
   if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " +
   trim (remtrz.ordins[4]).
 end.
end.
find first bankl where bankl.bank = remtrz.sbank no-lock no-error .
if avail bankl then do:
 o_ordins = trim(bankl.bank) + " " + o_ordins .
end.
if o_ordins ne "" and o_ordins ne ? then v-name = v-name + " " + o_ordins.

                display v-name with frame lon.
           end.
           /* else do:
                display v-name with frame lon.
                k-p = "".
                display s-gl k-p with frame lon.
                update s-gl with frame lon.
                s-ptype = 6.
                s-acc = "".
           end.  */
      end.
      if s-ptype = 5
      then do:
           update s-crc with frame lon.
           update s-gl with frame lon.
           find gl where gl.gl = s-gl no-lock.
           v-name = gl.des.
           if gl.subled <> ""
           then k-p = "Subkonts".
           else k-p = "".
           display s-gl k-p v-name with frame lon.
           if gl.subled <> ""
           then update vacc with frame lon.
           else vacc = "".
           s-acc = vacc.
      end.
      if s-ptype <= 1
      then update s-crc with frame lon.
      if s-crc <> lon.crc
      then do:
           find crc where crc.crc = s-crc no-lock.
           v-code1 = crc.code.
           v-pvncrc1 = crc.code.
           v-cd1 = crc.code.
           vcd1 = crc.code.
           algcd1 = crc.code.
           total-crc1 = crc.code.
           acd1 = crc.code.
           sds-cd1 = crc.code.
           v-odcrc1 = crc.code.
           v-blcrc1 = crc.code.
           v-iodcrc1 = crc.code.

           display v-code1
           /* v-pvncrc1 */
           v-cd1 /* sds-cd1 */ v-cd v-odcrc1 v-blcrc1 v-iodcrc1
           /* v-cd1 v-cd algcd1  */
           total-crc1 /* acd1 */
           with frame lon.

           if s-gl = v-glcash
           then kurss = kurss * crc.rate[2] / crc.rate[9].
           else kurss = kurss * crc.rate[4] / crc.rate[9].
      end.
      else kurss = 1.
      leave.
   end.

   readkey pause 0.
   inner2: repeat on endkey undo,return:
      if lon.gua = "LK" or lon.gua = "FK"
      then do:
           if lon.gua = "FK"
           then do:
                run s-fakst.
                algpay1 = round(algpay / kurss,2).
           end.
           if lon.gua = "LK"
           then run s-lizst.
           if rc > 0
           then return.


           pvn-sum = round(ppay * lon-pvn / 100, 2).
           ppay1 = round(ppay / kurss, 2).
           pvnpay  = pvn-sum.
           pvnpay1 = round(ppay1 * lon-pvn / 100, 2).

           ipay1 = round(ipay / kurss, 2).
           apay1 = round(apay / kurss, 2).

           total-pay = ppay + pvnpay + ipay + spay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
           display ppay1 ppay
           /*
           lon-pvn pvn-sum pvnpay pvnpay1
           */
           ipay1 ipay
           total-pay total-pay1 loncon.konts
           /*
           apay1 apay
           */
           with frame lon.

           if s-ptype = 4 then do on endkey undo,leave:
              display ppay1 ppay
              /*
              lon-pvn pvn-sum pvnpay pvnpay1
              */
              ipay1 ipay with frame lon.
              update pvnpay1 with frame lon.
              pvnpay  = round(pvnpay1 * kurss, 2).
              pvn-sum = pvnpay.
           end.

           /*
           total-pay = ppay + pvnpay + ipay + sds-pay + spay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + sds-pay1 + spay1.
           display ppay1 ppay
           /*
           lon-pvn pvn-sum pvnpay pvnpay1
           */
           ipay1 ipay
           total-pay total-pay1 loncon.konts /* apay1 apay */ with frame lon.

           if dam-cam1 = ppay then do on endkey undo,leave:
              display ppay1 ppay
              /*
              lon-pvn pvn-sum pvnpay pvnpay1
              */
              ipay1 ipay with frame lon.
              update pvnpay with frame lon.
              pvn-sum = pvnpay.
              pvnpay1 = round(pvnpay / kurss, 2).
           end.
           */

           total-pay = ppay + pvnpay + ipay + spay + algpay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1 + algpay1.

           display ppay1 ppay
           /* lon-pvn pvn-sum pvnpay pvnpay1 */
           ipay1 ipay
           /* algpay algpay1 */

           total-pay total-pay1 loncon.konts /* apay1 apay */ with frame lon.
      end.
      else do:
           /*---- all for leasing = 0.-- */
           lon-pvn = 0.
           pvn-sum = 0.
           pvnpay  = 0.
           pvnpay1 = 0.

           update ppay1 validate(kurss * ppay1 <= v-bal
           /* ( lon.dam[1] - lon.cam[1] ) */
                  and ppay1 >= 0,"" ) with frame lon.
           ppay = truncate(kurss * ppay1, 2).

           if ppay gt v-amtbl then v-paybl = v-amtbl.
           else v-paybl = ppay.
           if ppay - v-paybl gt v-amtod then v-payod = v-amtod.
           else v-payod = ppay - v-paybl.
           v-paybl1 = v-paybl / kurss.
           v-payod1 = v-payod / kurss.


           /* ???? */

           total-pay = ppay + pvnpay + ipay + spay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.

           display ppay
           v-paybl v-payod v-payod1 v-paybl1

           /* lon-pvn pvn-sum pvnpay pvnpay1   */

           total-pay
           total-pay1 with frame lon.
           if (v-amtod gt 0 or v-amtbl gt 0 ) and ppay gt 0 then
           repeat :
            update v-payod v-paybl with frame lon.
            v-paybl1 = v-paybl / kurss.
            v-payod1 = v-payod / kurss.
            displ v-paybl1 v-payod1 with frame lon.
            if v-payod + v-paybl le ppay then leave.
            else do:
                message "Превышена сумма платежа".
                pause 5.
            end.
           end.
      end.
      pause 0.

      if ppay1 = 0 then
      do:
           if lastkey = 13 or (lon.gua = "LK" or lon.gua = "FK")
           and ipay1 = 0 and apay1 = 0 and algpay1 = 0
           then do:
                run lonstl-p.
                if lon.gua = "LK" or lon.gua = "FK"
                then do:
                     run clear-fg("C").
                     leave inner2.
                end.
           end.
           /*else if (lon.gua = "LK" or lon.gua = "FK") and ipay1 = 0 and apay1 = 0
           then do:
                run clear-fg("C").
                leave inner2.
           end.*/
           else if lon.gua <> "LK" and lon.gua <> "FK"
           then do:
                update ppay validate(ppay <= (lon.dam[1] - lon.cam[1]) and
                       ppay >= 0, " ") with frame lon.
                ppay1 = round(ppay / kurss, 2).

                if ppay gt v-amtbl then v-paybl = v-amtbl.
                else v-paybl = ppay.
                if ppay - v-paybl gt v-amtod then v-payod = v-amtod.
                else v-payod = ppay - v-paybl.
                v-paybl1 = v-paybl / kurss.
                v-payod1 = v-payod / kurss.

                total-pay = ppay + pvnpay + ipay + spay.
                total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.

                display ppay1 v-payod v-payod1 v-paybl v-paybl1
                /* lon-pvn pvn-sum pvnpay pvnpay1 */
                total-pay total-pay1 with frame lon.
                if (v-amtod gt 0 or v-amtbl gt 0 ) and ppay gt 0 then
                repeat:
                update v-payod v-paybl with frame lon.
                    v-paybl1 = v-paybl / kurss.
                    v-payod1 = v-payod / kurss.
                    displ v-paybl1 v-payod1 with frame lon.
                    if v-payod + v-paybl le ppay then leave.
                    else do:
                        message "Превышена сумма платежа".
                        pause 5.
                    end.
                end.



                leave.
           end.
           else leave.
      end.
      else leave.
   end.
   readkey pause 0.
   if s-ptype = 4
   then do:
        if ppay1 + pvnpay1 + apay1 + algpay1 > remtrz.payment
        then do:
             bell.
             message "Превышена сумма перевода !".
             pause.
             undo,retry.
        end.
   end.

   repeat on endkey undo, return:
      if lon.gua <> "LK" and lon.gua <> "FK"
      then do:
           update ipay1 with frame lon.
           ipay = truncate(kurss * ipay1, 2).
           if ipay gt v-intod then v-payiod = v-intod.
           else v-payiod = ipay.
           v-payiod1 = v-payiod / kurss.



           total-pay = ppay + pvnpay + ipay + spay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.

           display ipay ipay1 v-payiod v-payiod1 total-pay total-pay1
           with frame lon.
           if v-intod gt 0 and ipay gt 0 then
           repeat:
            update v-payiod with frame lon.
            v-payiod1 = v-payiod / kurss.
            displ v-payiod1 with frame lon.
            if v-payiod le ipay then leave.
            else do:
                message "Превышена сумма платежа".
                pause 5.
            end.
           end.




      end.
      pause 0.

      if ipay1 = 0
      then do:
           if lastkey = 13 or (lon.gua = "LK" or lon.gua = "FK") and ppay1 = 0
              and apay1 = 0
           then do:
                run lonstl-i.
                ipay = marked.
                marked = 0.
                if lon.gua = "LK" or lon.gua = "FK" then leave.
                /*leave.*/
           end.
           else if lon.gua <> "LK" and lon.gua <> "FK"
                then do:
                     update ipay with frame lon.
                     ipay1 = round(ipay / kurss, 2).

                     if ipay gt v-intod then v-payiod = v-intod.
                     else v-payiod = ipay.

                     total-pay = ppay + pvnpay + ipay + spay.
                     total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.

                     display ipay1 v-payiod total-pay total-pay1 with frame lon.

                        repeat:
                            update v-payiod with frame lon.
                            v-payiod1 = v-payiod / kurss.
                            displ v-payiod1 with frame lon.
                            if v-payiod le ipay then leave.
                            else do:
                                message "Превышена сумма платежа".
                                pause 5.
                            end.
                        end.


                     leave.
                end.
                else leave.
      end.
      else leave.
   end.
   readkey pause 0.
   if s-ptype = 4
   then do:
        if ppay1 + pvnpay1 + ipay1 + apay1 > remtrz.payment
        then do:
             bell.
             message "Превышена сумма перевода  !".
             pause.
             undo,retry.
        end.
   end.

   repeat on endkey undo, return:
       if s-ptype = 4 and lon.gua = 'LK' then do on endkey undo,leave:
          display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */
          ipay1 ipay with frame lon.
          update pvnpay1 with frame lon.
          pvnpay  = round(pvnpay1 * kurss, 2).
          pvn-sum = pvnpay.
       end.
       else leave.

       total-pay = ppay + pvnpay + ipay + spay.
       total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
       display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */ ipay1 ipay
       total-pay total-pay1 loncon.konts /* apay1 apay */ with frame lon.
       leave.
   end.
   pause 0.

   repeat on endkey undo, return:
       if dam-cam1 = ppay and lon.gua = 'LK' then do on endkey undo,leave:
          display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */
          ipay1 ipay with frame lon.
          update pvnpay with frame lon.
          pvn-sum = pvnpay.
          pvnpay1 = round(pvnpay / kurss, 2).
       end.
       else leave.

       total-pay = ppay + pvnpay + ipay + spay.
       total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
       display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */ ipay1 ipay
       total-pay total-pay1 loncon.konts /* apay1 apay */ with frame lon.
       leave.
   end.
   pause 0.

   repeat on endkey undo, return:
         update sds-pay1 with frame lon.
         sds-pay = round(sds-pay1, 2).
         display sds-pay1  sds-pay with frame lon.
        leave.
   end.

   readkey pause 0.
   if s-ptype = 4
   then do:
        if ppay1 + pvnpay1 + ipay1 + apay1 > remtrz.payment
        then do:
             bell.
             message "Превышена сумма перевода !".
             pause.
             undo,retry.
        end.
   end.

   find lonsa where lonsa.lon = lon.lon no-lock no-error.
   if available lonsa
   then do:
        repeat on endkey undo, return:
           /*
           update spay1 with frame lon.
           */
           spay = truncate(kurss * spay1, 2).
           total-pay = ppay + pvnpay + ipay + spay.
           total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
           display /* spay */ total-pay total-pay1 with frame lon.
           pause 0.
           /*
           if spay1 = 0
           then do:

                if lastkey = 13
                then do:
                     s-gljl = s-longl[1].
                     run lonstl-s.
                end.
                else do:
                     update spay with frame lon.
                     spay1 = round(spay / kurss, 2).
                     total-pay = ppay + pvnpay + ipay + sds-pay + spay.
                     total-pay1 = ppay1 + pvnpay1 + ipay1 + sds-pay1 + spay1.

                     display spay1 total-pay total-pay1 with frame lon.
                     leave.
                end.
           end.
           else
           */
           leave.

        end.
   end.
   if s-ptype = 4
   then do:
        if ppay1 + pvnpay1 + ipay1 + spay1 + apay1 + algpay1 <>
           remtrz.payment
        then do:
             bell.
             message "Сумма платежа и перевода не совпадают !".
             pause.
             undo,retry.
        end.
   end.
   if s-ptype eq 9 then do:
    if (ppay gt dam-cam1) or (ipay gt vinttday) then do:
     message "Превышена сумма долга" view-as alert-box.
     undo,retry.
    end.
    if (ppay gt dam-cam1) or (ipay gt vinttday) then do:
     message "Превышена сумма долга по процентам" view-as alert-box.
     undo,retry.
    end.
   end.


   /* dobavlenije primechanija */
   do :
       find crc where crc.crc eq lon.crc no-lock no-error.
       if ppay ne 0 then
       s-glrem2 = "Сумма погашаемого основного долга " +
       trim(string(ppay,">>>,>>>,>>>,>>>,>>9.99-"))
       + " " + crc.code.
       else s-glrem2 = "".
       if ipay ne 0 then
       s-glrem3 = "Сумма погашаемых %% " +
       trim(string(ipay,">>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code.
       else s-glrem3 = "".

       if sds-pay ne 0 then do:
         if s-glrem3 <> "" then s-glrem3 = s-glrem3 + ", штрафов " + trim(string(sds-pay,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
         else s-glrem3 = "Сумма погашаемых штрафов " + trim(string(sds-pay,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
       end.

       display s-glrem2 s-glrem3 with frame lon.
       pause 0.
       update  v-name with frame lon.
       display v-name with frame lon.
       pause 0.
       update  s-glrem2 with frame lon.
       display s-glrem2 with frame lon.
       pause 0.
       update  s-glrem3 with frame lon.
       display s-glrem3 with frame lon.
       pause 0.



   end.
   if  lastkey = keycode("PF4")
   then next.
end.

s-lon = lon.lon.
if ppay = 0 and ipay = 0 and spay = 0 and apay = 0 and
sds-pay = 0 then undo,return.
ja = no.
update ja with frame lon.
if ja
then do:
  s-ordtype = 2. /* apmaksa */
  if s-ptype eq 1 then
  update v-who v-passp v-perkod with frame f_cus.

find lon where lon.lon eq s-lon no-lock no-error.
find cif where cif.cif eq lon.cif no-lock no-error.
find loncon where loncon.lon eq s-lon no-lock no-error.
find last ln%his where ln%his.lon = lon.lon and ln%his.stdat le g-today
no-lock no-error.
find crc where crc.crc eq lon.crc no-lock no-error.
s-glrem =
"Оплата кредита " + s-lon + " " + ln%his.lcnt + " " +
trim(string(ln%his.opnamt,">>>,>>>,>>>,>>>,>>>,>>9.99-"))
+ " " + crc.code + " "
+ trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss .
if s-ptype eq 4 then s-glrem = s-rmz + " " + s-glrem.

/*
Выдача кредита 1234567890 Наименование клиента
РНН 1234567890


*/
/*
run s-lonfrm(s-glrem, 60).
*/
s-glremx[1] = s-glrem.
s-glremx[2] = s-glrem2.
s-glremx[3] = s-glrem3.
s-glremx[4] = v-name.
if s-ptype eq 1 then s-glremx[5] =
    "/ПЛАТЕЛЬЩИК/" + v-who +
    "/ПАСПОРТ/" + v-passp + "/ПЕРС.КОД/" + v-perkod.

/*
do:

    do i = 5 to 10 :
        s-glremx[4] = s-glremx[4] + " " + trim(s-glremx[i]).
    end.
    s-glremx[5] =
    "/ПЛАТЕЛЬЩИК/" + v-who +
    "/ПАСПОРТ/" + v-passp + "/ПЕРС.КОД/" + v-perkod.
end.
else do:
    do i = 6 to 10 :
        s-glremx[5] = s-glremx[5] + trim(s-glremx[i]).
    end.
end.
*/

  run x-lonstrx.

  /*
  run x-lonstjl.
  */
end.
run clear-fg("C").

/*----------------------------------------------------------------------------
  #3.
     1.izmai‡a - mainЁgaj– s-acr padod t–l–k uz Ѕodienu uzskaitЁtos %

-----------------------------------------------------------------------------*/
