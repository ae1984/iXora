/* isrmgnt.p
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
        11.07.2005 dpuchkov- добавил формирование корешка
        02.08.2005 dpuchkov- добавил формирование корешка для РКО-шек
        11.08.2005 saltanat - Для платежей с кодом комиссии 226,227,228 добавлять снятие по комиссии 229. (после 16-15)
                              А также при комиссиях "240", "241", добавляется "242". (после 16-15)
        26/05/2006 nataly добавила обработку счета TSF
        30/05/2006 u00121 - формирование проводок по кассе в пути для тех департаментов, которые работают только через кассу в пути
        02.06.2006 u00121 - временно блокировал работу get100200arp
        17.03.2010 k.gitalov - если есть код тарифа то берется примечание из тарификатора
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        28.11.2012 evseev - ТЗ-1374
*/

{global.i}
{lgps.i}
{comm-txb.i}
{convgl.i "bank"}

/*u00121 30/05/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/

def shared var s-remtrz like remtrz.remtrz .

def new shared var s-jh like jh.jh .
def var v-ref as cha format "x(10)" no-undo.
def var v-pnp as cha format "x(10)" no-undo.
def var v-chg as int  no-undo.
def var v-reg5  as cha format "x(13)" no-undo.
def var v-bin5 as char format "x(12)".
def var acode like crc.code  no-undo.
def var bcode like crc.code  no-undo.
def var pakal as cha no-undo.
def var v-priory as char no-undo.

def var vdel    as char initial "^" no-undo.
def var rdes    as char no-undo.
def var rcode   as int no-undo.
def var rdes1   as char no-undo.
def var rcode1  as int no-undo.
def var vparam  as char no-undo.
def var vparam1 as char no-undo.
def var vparam2 as char no-undo.
def var vsum    as char no-undo.
def var shcode  as char no-undo.
def var ro-gl   as char no-undo.
def var ro-gl1  as char no-undo.
def var v-chk   as char no-undo.
def var v-commdop as char init '226,227,228' no-undo.
def var v-newcode as char init '229' no-undo.
def var v-dopkomiss as deci no-undo.
def var v-dopkomgl as char no-undo.
def var i as inte no-undo.
def var CommStr as char init '' no-undo.

find sysc where sysc.sysc eq "PSPYGL" no-lock no-error.
ro-gl = string(sysc.inval) .
ro-gl1 = trim(sysc.chval).

{psror.f}


find first remtrz where remtrz.remtrz  = s-remtrz  no-lock no-error.
if remtrz.jh1 ne ?  then do:
   v-text = remtrz.remtrz +  " 1 TRX = " + string(remtrz.jh1)  +  " have been already done . " .
   message v-text . pause .
   return .
end .


do transaction :
   find first remtrz where remtrz.remtrz = s-remtrz  exclusive-lock no-error.
   /* ----------- 1 - line  -------------------------- */
   find first gl where gl.gl = remtrz.drgl no-lock no-error.
   if remtrz.fcrc = remtrz.tcrc then do:
      vparam = remtrz.remtrz + "  (" + trim(substr(remtrz.sqn,19)) + ")" + ' ' + trim(substring(remtrz.ref,1,6))
            + vdel + string(remtrz.amt)
            + vdel + (if remtrz.outcode = 1 or remtrz.outcode = 8 then string(remtrz.tcrc) else remtrz.dracc )
            + vdel + (if remtrz.tcrc = 1 then ro-gl1 else ro-gl)
            + vdel + remtrz.remtrz + " " + replace(
                      trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2]) +  ' ' +
                      trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]) +
                      substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) +
                      substr(remtrz.ord,71),"^"," ")  .
   end.

   if remtrz.outcode  = 1 then do:
      if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0019" .
   end.
   if remtrz.outcode  = 2 then  /*TSF*/ do:
     if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0043" .
     else do:
         message ' Из-за того, что валюты разные данный режим не работает !'.
     end.
   end.
   if remtrz.outcode  = 8 then do:
     if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0022" .
   end.
   if remtrz.outcode  = 3 then do:
     if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0004" .
   end.
   if remtrz.outcode  = 4 then do:
      if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0007" .
   end.
   if remtrz.outcode  = 5 then do:
      if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0010" .
   end.
   if remtrz.outcode  = 7 then do:
      if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0016" .
   end.
   if remtrz.outcode  = 6 then do:
      if remtrz.fcrc = remtrz.tcrc then shcode = "PSY0013" .
   end.

   run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode, output rdes,input-output s-jh).
   if rcode > 0  then do:
      Message " Error: " + string(rcode) + ":" +  rdes .
      pause .
      undo.
      return .
   end.
   if remtrz.svca > 0 then do:
       find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
       if avail tarif2 then do: CommStr = tarif2.pakalp. end.
       else do:
         CommStr = remtrz.remtrz + " " + replace(trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2]) +  ' ' +  trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]) +  substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70) + substr(remtrz.ord,71),"^"," ")  .
       end.


       vparam =  string(remtrz.svca)
             + vdel + (if remtrz.svcaaa eq "" then string(remtrz.svcrc) else remtrz.svcaaa)
             + vdel + string(remtrz.svccgl)
             + vdel + CommStr  .

       if remtrz.svcaaa ne "" and remtrz.svcgl <> 100200 then  shcode = "PSY0025" .
       else if remtrz.svcgl = 100200  then  shcode = "PSY0046" .
       else if remtrz.svcgl  ne 0  then  shcode = "PSY0026" .



       run trxgen(shcode,vdel,vparam,"rmz",remtrz.remtrz, output rcode, output rdes,input-output s-jh).
       if rcode > 0  then  do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo.
         return .
       end.
       /* 11.08.05 saltanat - Если код коммиссии из зад-го списка, то берем комиссию по v-newcode коду. */
       do i = 1 to 2 :
           if i = 2 then do:
              v-commdop = '240,241'.
              v-newcode = '242'.
           end.
           if lookup(string(remtrz.svccgr),v-commdop) > 0 then do:
              find first tarif2 where tarif2.str5 = v-newcode and tarif2.stat = 'r' no-lock no-error.
              if not avail tarif2 then do:
                 Message " Error: " + 'Не найден код комиссии: ' + v-newcode .
                 pause .
                 undo.
                 return .
              end.
              v-dopkomiss = 0.
              run commdop (input remtrz.remtrz, input v-newcode, output v-dopkomiss, output v-dopkomgl).

              vparam2 = string(v-dopkomiss)
                    + vdel + (if remtrz.svcaaa eq "" then string(remtrz.svcrc) else remtrz.svcaaa)
                    + vdel + v-dopkomgl
                    + vdel + remtrz.remtrz + " " + replace(trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2])
                              +  ' ' + trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]) + substr(remtrz.ord,1,35) + substr(remtrz.ord,36,70)
                              + substr(remtrz.ord,71),"^"," ")  .
              if remtrz.svcaaa ne "" then  shcode = "PSY0025" .
              else if remtrz.svcgl  ne 0  then  shcode = "PSY0026" .
              run trxgen(shcode,vdel,vparam2,"rmz",remtrz.remtrz, output rcode, output rdes,input-output s-jh).
              if rcode > 0  then do:
                 Message " Error: " + string(rcode) + ":" +  rdes .
                 pause .
                 undo.
                 return .
              end.
           end.
       end. /* do */
   end.

   find first jl where jl.jh = s-jh and jl.ln = 2 no-lock no-error.
   if avail jl then remtrz.info[10] = string(jl.gl) .
   if remtrz.info[6] matches "*payment*" then remtrz.info[6] = "TRXGEN " + shcode + " payment". else remtrz.info[6] = "TRXGEN " + shcode + " amt".

   v-text = string(s-jh) + " 1-TRX " + remtrz.remtrz +
       " " + remtrz.dracc + " " + string(remtrz.amt) + " CRC = " +
       string(remtrz.fcrc) + " was made by " + g-ofc .
   run lgps.
   remtrz.jh1 = s-jh.
   remtrz.info[9] =  string(g-today) + " " +   remtrz.scbank .
   display remtrz.jh1 with frame remtrz .

   /*ФОРМИРОВАНИЕ КОРЕШКА ДЛЯ ОПЕРАЦИОНКИ*/
   def buffer b-ofc for ofc.
   find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
   if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/
       find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
       if (remtrz.dracc = string(sysc.inval) or remtrz.cracc = string(sysc.inval)) or remtrz.outcode = 1 then do:
           find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
           if not avail acheck then do:
              v-chk = "".
              v-chk = string(NEXT-VALUE(krnum)).
              create acheck.
                     acheck.jh = string(s-jh).
                     acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                     acheck.dt = g-today.
                     acheck.n1 = v-chk.
              release acheck.
           end.
       end.
   end.
   /*ФОРМИРОВАНИЕ КОРЕШКА ДЛЯ ОПЕРАЦИОНКИ*/
end.

Procedure perev0.
    def input parameter komis as char format "x(4)".
    def input parameter tcif like cif.cif .

    def output parameter kod11 like rem.crc1.
    def output parameter tproc   like tarif2.proc .
    def output parameter tmin1   as dec decimals 10 .
    def output parameter tmax1   as dec decimals 10 .
    def output parameter tost    as dec decimals 10 .
    def output parameter pakal as char.
    def output parameter v-err as log.

    def var a2 like tarif2.kod.
    def var a1 like tarif2.num.
    def var rr as dec.
    def var sum1 like rem.payment.
    def var sum2 like rem.payment.
    def var sum3 like rem.payment.
    def var v-sumkom as dec.
    def var konts like gl.gl.

    v-err = no.
    tproc = 0.
    tost = 0.

      find first tarif2 where tarif2.str5 = komis
                          and tarif2.stat = 'r' no-lock no-error.

      if available tarif2 then
      do :
           if tcif <> "" then
                find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif
                                     and tarifex.stat = 'r' no-lock no-error .
           if avail tarifex then
           do :
            find first crc where crc.crc = tarifex.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex.pakal.
            konts = tarifex.kont .
            tproc = tarifex.proc .
            tmin1 = tarifex.min1 .
            tmax1 = tarifex.max1 .
                tost  = tarifex.ost .
           end .
           else
           do :
                find first crc where crc.crc = tarif2.crc no-lock .
                kod11 = crc.crc.
                pakal = tarif2.pakal.
                konts = tarif2.kont .
                tproc = tarif2.proc .
                tmin1 = tarif2.min1 .
                tmax1 = tarif2.max1 .
                tost  = tarif2.ost  .
               end.
     end. /*tarif2*/
     else v-err = yes.
end procedure.
