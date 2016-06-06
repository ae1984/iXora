/* comincas.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        28.03.2005 suchkov - Переделал принцип выборки arp счетов .
        05.07.2005 saltanat - Выборка льгот по счетам.
        20/09/2013 Luiza    - ТЗ 1916 изменение поиска записи в таблице tarif2

*/
{curs_conv.i}
{global.i}

define variable s-cif like cif.cif.
find last cls no-lock.
define variable df as date label "C ".
define variable dt as date label "По ".
def var s-arp like arp.arp.

def var kod11 like rem.crc1.
def var tproc   like tarif2.proc .
def var tmin1   as dec decimals 10 .
def var tmax1   as dec decimals 10 .
def var tost    as dec decimals 10 .
def var v-sum as dec.
def var konts like tarif2.kont.
def var pakal as char.
def var v-err as log.

def var s-summin like jl.cam.
def var s-sumall like jl.cam.

form    cif.cif  label "Код клиента"
        cif.name label "Имя"
        df       label "С"
        dt       label "По"
with side-label 1 column  frame cif.

   prompt-for cif.cif with frame cif.
   find cif using cif.cif no-lock.
   display trim(trim(cif.prefix) + " " + trim(cif.name)) @ cif.name with frame cif. pause 0.
   s-cif =  cif.cif.
   update df  with side-label frame cif.
   update dt  with side-label frame cif.

if df = ? or dt = ? then do:
    return.
end.

/* suchkov - Переделал принцип выборки arp счетов

find last arp where arp.cif = s-cif and substr(arp.arp,4,3) = '729' no-lock no-error.

 if not avail arp then do:
   message 'No account arp'.
   pause.
   return.
 end.*/

for each arp where arp.cif = s-cif and substr(arp.arp,4,3) = '729' no-lock .
        find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock .
        if sub-cod.ccode <> "msc" then next .
                                  else s-arp = arp.arp .
end.

if s-arp = ? then do:
   message 'No account arp'.
   pause.
   return.
end.

run perev0('','126', s-cif, output kod11,
           output tproc, output tmin1, output tmax1,
           output tost, output pakal, output v-err).

output to rpt.img.
put cif.cif skip.
put trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" skip.
put "C  " df skip.
put "По " dt skip.


put skip(2) "Валюта      Проц      Мин       Макс" skip.
put '-----------------------------------' skip.
put kod11  '        ' tproc  tmin1 tmax1  skip(2).

find crc where crc.crc = kod11 no-lock no-error.
  s-summin = tmin1 * crc.rate[1] / tproc * 100.
  put "Курс            "  crc.rate[1] skip.
  put skip "Минимум   "  s-summin skip(2).

  put "Счет        Дата                Сумма" skip.
  put '---------------------------------------' skip.
for each jl where jl.acc = s-arp and dc = 'C' and jdt >= df and jdt <= dt:
   put jl.acc  jdt  cam skip.
   if cam > s-summin then s-sumall = s-sumall + cam * tproc / 100.
                     else s-sumall = s-sumall + tmin1 * crc.rate[1].
end.

put skip(2) 'К проводке   ' s-sumall.

output close.
run menu-prt("rpt.img").


Procedure perev0.
def input parameter v-aaa as char.
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
def var comis as logi.
def var avl_sum as deci.

  v-err = no.
  /*a1 = trim(substring(komis,1,1)).
  a2 = trim(substring(komis,2,2)).
  find first tarif2 where  tarif2.num = a1
                      and tarif2.kod  = a2
                      and tarif2.stat = 'r' no-lock no-error.*/
  find first tarif2 where  tarif2.str5 = trim(komis) and tarif2.stat = 'r' no-lock no-error.

  if available tarif2 then  do :
   if tcif ne "" and v-aaa ne "" then

   find first tarifex2 where  tarifex2.aaa = v-aaa
                          and tarifex2.cif = tcif
                          and tarifex2.str5 = tarif2.str5
                          and tarifex2.stat = 'r' no-lock no-error.
   if avail tarifex2 then do:
       comis = yes. /* commission > 0 */
       avl_sum = avail_bal(v-aaa).
       if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
          if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
       end.

      find first crc where crc.crc = tarifex2.crc no-lock .
    	kod11 = crc.crc.
	    pakal = tarifex2.pakal.
    	konts = tarifex2.kont .
	    tproc = if comis then tarifex2.proc else 0.
    	tmin1 = if comis then tarifex2.min1 else 0.
	    tmax1 = if comis then tarifex2.max1 else 0.
    	tost  = if comis then tarifex2.ost else 0.
   end.
   else do:
	   if tcif <> "" then
    	find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif
	                         and tarifex.stat = 'r' no-lock no-error .
	   if avail tarifex then do :
	    find first crc where crc.crc = tarifex.crc no-lock .
    	kod11 = crc.crc.
	    pakal = tarifex.pakal.
    	konts = tarifex.kont .
	    tproc = tarifex.proc .
    	tmin1 = tarifex.min1 .
	    tmax1 = tarifex.max1 .
    	tost  = tarifex.ost .
	   end .
	   else do :
	    find first crc where crc.crc = tarif2.crc no-lock .
	    kod11 = crc.crc.
	    pakal = tarif2.pakal.
	    konts = tarif2.kont .
	    tproc = tarif2.proc .
	    tmin1 = tarif2.min1 .
	    tmax1 = tarif2.max1 .
	    tost  = tarif2.ost  .
	   end .
   end. /* tarifex2 */

  end. /*tarif2*/

  else v-err = yes.
end procedure.




