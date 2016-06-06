/* perev.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Расчет суммы комиссии для проставления в платеже в 5-2-8
        копия perev.p с выходом минимальной и максимальной суммы комиссии в пересчете на валюту комиссии
 * RUN
        
 * CALLER
        comiss2.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-2-8
 * AUTHOR
        23.09.2003 nadejda
 * CHANGES
        19.12.2003 nadejda - изменила формат переменной tproc, а то она округлялась до 2 знаков
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        05.07.2005 saltanat - Выборка льгот по счетам.
*/
{global.i}

def input parameter p-aaa as char.
def input parameter komis as char format "x(4)".
def input parameter paym  like rem.payment.
def input parameter kod12 like rem.crc2.
def input parameter kod11 like rem.crc1.
def input parameter tcif like cif.cif.


def output parameter v-sum as decimal.
def output parameter konts like tarif2.kont.
def output parameter pakal as char.
def output parameter tmin1 as decimal decimals 10.
def output parameter tmax1 as decimal decimals 10.


def var rr as decimal.
def var sum1 like rem.payment.
def var sum2 like rem.payment.
def var sum3 like rem.payment.
def var v-sumkom as decimal.
def var tproc as dec decimals 10 .
def var tost as decimal decimals 10.
def var comis as logi.
def var avl_sum as deci.

def buffer bcif for cif.


find first tarif2 where tarif2.str5 = komis and tarif2.stat = 'r' no-lock no-error.

if available tarif2 then do:
  if tcif <> "" then
    
    /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */                  
    {curs_conv.i}
    find first tarifex2 where tarifex2.aaa = p-aaa 
                          and tarifex2.cif = tcif 
                          and tarifex2.str5 = tarif2.str5 
                          and tarifex2.stat = 'r' no-lock no-error. 
    if available tarifex2 then do:
       comis = yes. /* commission > 0 */
       avl_sum = avail_bal(p-aaa).
       find bcif where bcif.cif = tcif no-lock no-error.
       if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
          if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
       end.
       
       find first crc where crc.crc = tarifex2.crc no-lock.
	    pakal = tarifex2.pakal.
    	konts = tarifex2.kont.
	    tproc = if comis then tarifex2.proc else 0.
    	tmin1 = if comis then tarifex2.min1 * crc.rate[1] else 0.
	    tmax1 = if comis then tarifex2.max1 * crc.rate[1] else 0.
    	tost  = if comis then tarifex2.ost  * crc.rate[1] else 0.
    end.
    else do:  
	    find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif 
    	                     and tarifex.stat = 'r' no-lock no-error.
	    if avail tarifex then do:
    	find first crc where crc.crc = tarifex.crc no-lock.
	    pakal = tarifex.pakal.
    	konts = tarifex.kont.
	    tproc = tarifex.proc.
    	tmin1 = tarifex.min1 * crc.rate[1].
	    tmax1 = tarifex.max1 * crc.rate[1].
    	tost  = tarifex.ost  * crc.rate[1].
	  end.
	  else do :
    	find first crc where crc.crc = tarif2.crc no-lock.
	    pakal = tarif2.pakal.
    	konts = tarif2.kont.
	    tproc = tarif2.proc.
    	tmin1 = tarif2.min1 * crc.rate[1].
	    tmax1 = tarif2.max1 * crc.rate[1].
    	tost  = tarif2.ost  * crc.rate[1].
	  end.
  end.	  

  if kod12 <> kod11 then do:
    find first crc where crc.crc = kod12 no-lock no-error.
    if available crc then do:
      v-sumkom = tost.  /* сумма комиссии в тенге */

      if tproc <> 0 then do :
        sum1 = round (paym * crc.rate[1] / crc.rate[9], crc.decpnt). /* сумма платежа в тенге */
        rr = round (tproc * sum1 / 100, 2).
        if rr < tmin1 then rr = tmin1.
        if rr > tmax1 and tmax1 <> 0 then rr = tmax1.
        v-sumkom = v-sumkom + rr.
      end.
    end.

    /* перевести суммы в валюту комиссии */
    find first crc where crc.crc = kod11 no-lock no-error.
    if available crc then do:
      v-sum = round (v-sumkom * crc.rate[9] / crc.rate[1], crc.decpnt).
      tmin1 = round (tmin1 * crc.rate[9] / crc.rate[1], crc.decpnt).
      tmax1 = round (tmax1 * crc.rate[9] / crc.rate[1], crc.decpnt).
    end.
  end. /*kod11<>kod12*/
  else do:
    find first crc where crc.crc = kod12 no-lock no-error.
    if available crc then do:
      /* перевести суммы в валюту комиссии = валюте платежа */
      v-sumkom = round (tost  * crc.rate[9] / crc.rate[1], crc.decpnt).
      tmin1    = round (tmin1 * crc.rate[9] / crc.rate[1], crc.decpnt).
      tmax1    = round (tmax1 * crc.rate[9] / crc.rate[1], crc.decpnt).

      if tproc <> 0 then do :
        rr = round (tproc * paym / 100, 2).
        if rr < tmin1 then rr = tmin1.
        if rr > tmax1 and tmax1 <> 0 then rr = tmax1.
        v-sumkom = v-sumkom + rr.
      end.
    end.
    v-sum = v-sumkom.
  end. /*kod11 = kod12*/

end. /*tarif2*/

