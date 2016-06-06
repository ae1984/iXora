/* perev_txb.p
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        11/10/2012 Luiza  - файл создан по подобию perev.p только для межфил
        06/08/2013 Luiza    - ТЗ 1997 Расширение поля «Код тарифа»

 * CHANGES
*/
/*{global.i}*/

def input parameter p-aaa as char.
def input parameter komis as char format "x(4)".
def input parameter paym  like txb.rem.payment.
def input parameter kod12 like txb.rem.crc2.
def input parameter kod11 like txb.rem.crc1.
def input parameter tcif  like txb.cif.cif .
def shared var g-today as date.


def output parameter v-sum as dec.
def output parameter konts like txb.tarif2.kont.
def output parameter pakal as char.
def var a2 like txb.tarif2.kod.
def var a1 like txb.tarif2.num.
def var rr as dec.
def var sum1 like txb.rem.payment.
def var sum2 like txb.rem.payment.
def var sum3 like txb.rem.payment.
def var v-sumkom as dec.
def var tproc   as dec decimals 10 .
def var tmin1   as dec decimals 10 .
def var tmax1   as dec decimals 10 .
def var tost    as dec decimals 10 .
def var comis as logi.
def var avl_sum as deci.

def buffer bcif for txb.cif.

  find first txb.tarif2 where txb.tarif2.str5 = trim(komis) and txb.tarif2.stat = 'r' no-lock no-error.

  if available txb.tarif2 then  do :
   if tcif <> "" then
    /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
    {curs_conv_txb.i}
    find first txb.tarifex2 where txb.tarifex2.aaa = p-aaa
                          and txb.tarifex2.cif = tcif
                          and txb.tarifex2.str5 = txb.tarif2.str5
                          and txb.tarifex2.stat = 'r' no-lock no-error.
    if available txb.tarifex2 then do:
       comis = yes. /* commission > 0 */
       avl_sum = avail_bal(p-aaa).
       find bcif where bcif.cif = tcif no-lock no-error.
       if (avail bcif and bcif.type = 'p') and (txb.tarifex2.str5 = '105' or txb.tarifex2.str5 = '419') and txb.tarifex2.nsost ne 0 then do:
          if konv2usd(avl_sum,txb.tarifex2.crc,g-today) > txb.tarifex2.nsost then comis = no.
       end.

       find first txb.crc where txb.crc.crc = txb.tarifex2.crc no-lock .
	   pakal = txb.tarifex2.pakal.
	   konts = txb.tarifex2.kont .
	   tproc =  if comis then txb.tarifex2.proc else 0.
	   tmin1 =  if comis then txb.tarifex2.min1 * txb.crc.rate[1] else 0.
	   tmax1 =  if comis then txb.tarifex2.max1 * txb.crc.rate[1] else 0.
	   tost  =  if comis then txb.tarifex2.ost  * txb.crc.rate[1] else 0.
    end.
    else do:
	    find first txb.tarifex where txb.tarifex.str5 = txb.tarif2.str5 and txb.tarifex.cif = tcif
    	                     and txb.tarifex.stat = 'r' no-lock no-error .
	   if avail txb.tarifex then do :
	    find first txb.crc where txb.crc.crc = txb.tarifex.crc no-lock .
	    pakal = txb.tarifex.pakal.
	    konts = txb.tarifex.kont .
	    tproc = txb.tarifex.proc .
	    tmin1 = txb.tarifex.min1 * txb.crc.rate[1] .
	    tmax1 = txb.tarifex.max1 * txb.crc.rate[1] .
	    tost  = txb.tarifex.ost  * txb.crc.rate[1] .
	   end .
	   else do :
    	find first txb.crc where txb.crc.crc = txb.tarif2.crc no-lock .
	    pakal = txb.tarif2.pakal.
	    konts = txb.tarif2.kont .
	    tproc = txb.tarif2.proc .
	    tmin1 = txb.tarif2.min1 * txb.crc.rate[1] .
	    tmax1 = txb.tarif2.max1 * txb.crc.rate[1] .
	    tost  = txb.tarif2.ost  * txb.crc.rate[1] .
	   end .
	 end.

     if kod12 <> kod11 then do:
     find first txb.crc where txb.crc.crc = kod12 no-lock no-error.
     if available txb.crc then do:
       sum1 = round( paym * txb.crc.rate[1] / txb.crc.rate[9], txb.crc.decpnt ).
       if tproc<> 0 then do :
            rr = round(tproc * sum1 / 100, 2).
            if rr < tmin1 then rr = tmin1.
            if rr > tmax1  and tmax1 <> 0 then rr = tmax1.
            v-sumkom = tost + rr.
       end.
       else v-sumkom = tost.
     end.

     find first txb.crc where txb.crc.crc = kod11 no-lock no-error.
     if available txb.crc then do:
       v-sumkom = round( v-sumkom * txb.crc.rate [9] / txb.crc.rate[1], txb.crc.decpnt).
       v-sum = v-sumkom.
     end.
    end. /*kod11<>kod12*/
    else do:
     find first txb.crc where txb.crc.crc = kod12 no-lock no-error.
     if available txb.crc then do:
            sum3 = round(tost  * txb.crc.rate[9]  / txb.crc.rate[1], txb.crc.decpnt).

       if tproc<> 0 then do :
            rr = round(tproc * paym / 100, 2).
            sum1 = round(tmin1 * txb.crc.rate [9] / txb.crc.rate[1], txb.crc.decpnt).
            sum2 = round(tmax1 * txb.crc.rate [9] / txb.crc.rate[1], txb.crc.decpnt).
            if rr < sum1 then rr = sum1.
            if rr > sum2  and sum2 <> 0 then rr = sum2.
            v-sumkom = sum3 + rr.
       end.
       else v-sumkom = sum3.
     end.
       v-sum = v-sumkom.
    end. /*kod11 = kod12*/
  end. /*tarif2*/

