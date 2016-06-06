/* rkodoh.p
 * MODULE
        Доходы по РКО за указанный период
 * DESCRIPTION
        Отчет по доходам сберкасс.
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
        07/04/04 madiar
 * CHANGES 
        15/07/04 kanat - добавил формирование данных по дубликатам распечатанных квитанций
        02/09/04 kanat - изменения по обнулению промежуточных сумм при рассмотрении операций продажи валюты
        20/09/04 kanat - добавил ТОлебИ и изменил foreach по группам
        03/05/05 kanat - увеличил разрядность массива для сбора промежуточных сумм по РКО банка до 42 и добавил grp = 15
        10/05/05 kanat - изменил запрос для социальных платежей
        01/07/05 madiar - увеличил разрядность массива для сбора промежуточных сумм по РКО банка до 50
        10/10/05 madiar - поменял перечисление больших РКО на поиск в справочнике
	03/02/06 u00121 - увеличил екстенты для хранения данных по РКО до 60
	04/09/06 suchkov - увеличил екстенты для хранения данных по РКО до 70. Пора завязывать с этими увеличениями.
*/


{mainhead.i}
/*{functions-def.i}*/
{get-dep.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def stream rep.
def var dt1 as date.
def var dt2 as date.
def var usrnm as char. 
def var dlm as char init "|".
def var ar as integer.
def var usdrate as decimal.
def var depcom_ar as decimal extent 70.
def var depcom1_ar as decimal extent 70.
def var depcom2_ar as decimal extent 70.
def var depexc_ar as decimal extent 70.
def var dept as int.

do ar = 1 to 70:
  depcom_ar[ar] = 0.
  depcom1_ar[ar] = 0.
  depcom2_ar[ar] = 0.
  depexc_ar[ar] = 0.
end.

def var d_accnt as integer.
def var v-cursum as decimal init 0.
def var v-sum as decimal init 0.
def var v-comsum-buy as decimal.
def var v-comsum-sell as decimal.

def var v-sum-buy as decimal.
def var v-sum-sell as decimal.

def var v-dep-buy as decimal.
def var v-dep-sell as decimal.

def var v-crc-buy as decimal.
def var v-crc-sell as decimal.

def var v-rate-buy as decimal.
def var v-rate-sell as decimal.

def var v-buy-rate-fin as decimal.
def var v-sell-rate-fin as decimal.

def var v-dub-tax as decimal.
def var v-dub-com as decimal.
def var v-dub-pnj as decimal.

def temp-table tcomm-buy
     field    dep     as integer format ">>>9"
     field    date    as date
     field    sum     as decimal format "zzzz,zzz,zz9.99"
     field    comsum  as decimal format "zzzz,zzz,zz9.99"
     field    type    as integer
     field    crc     as integer 
     field    rate    as decimal format "zzz9.99".

def temp-table tcomm-sell
     field    dep     as integer format ">>>9"
     field    date    as date
     field    sum     as decimal format "zzzz,zzz,zz9.99"
     field    comsum  as decimal format "zzzz,zzz,zz9.99"
     field    type    as integer
     field    crc     as integer 
     field    rate    as decimal format "zzz9.99".

def temp-table tcomm-nepl
     field    dep     as integer format ">>>9"
     field    date    as date
     field    sum     as decimal format "zzzz,zzz,zz9.99"
     field    comsum  as decimal format "zzzz,zzz,zz9.99"
     field    type    as integer
     field    crc     as integer 
     field    rate    as decimal format "zzz9.99".

define temp-table ttax like tax
    field dep like ppoint.depart.
define temp-table tcommpl like commonpl
    field dep like ppoint.depart.
define temp-table payment like p_f_payment
    field dep like ppoint.depart.

define variable ar_grp as integer extent 9 initial [1, 3, 4, 5, 6, 7, 8, 9, 15].

def var v-depart as char init ''.
find sysc where sysc.sysc = 'depart' no-lock no-error.
if avail sysc then v-depart = sysc.chval.

dt1 = g-today.
dt2 = g-today.

update dt1 format '99/99/9999' label " Начальная дата " 
       dt2 format '99/99/9999' label " Конечная дата " 
with centered frame df.

hide frame df.

message "Формируется отчет...".

/* курс на конец запрашиваемого периода */

find last crchis where crchis.rdt <= dt2 and crchis.crc = 2 no-lock no-error.
if avail crchis then usdrate = crchis.rate[1].

/* налоговые платежи */

for each tax no-lock where tax.txb = seltxb and date >= dt1 and date <= dt2 and duid = ?:
    create ttax.
      buffer-copy tax to ttax.
      ttax.dep = get-dep(tax.uid, tax.date).
  end.

find first ttax no-lock no-error.
if available ttax then
  for each ttax NO-LOCK BREAK BY ttax.dep:
    accumulate ttax.comsum (sub-total by ttax.dep).
    v-dub-tax = v-dub-tax + decimal(ttax.chval[4]).
    if last-of(ttax.dep) and lookup(string(ttax.dep),v-depart) = 0 then
      depcom_ar[ttax.dep] = depcom_ar[ttax.dep] + (accum sub-total by ttax.dep ttax.comsum).
      depcom2_ar[ttax.dep] = depcom2_ar[ttax.dep] + v-dub-tax.
      v-dub-tax = 0.
  end.

/* стандиаг */

do ar = 1 to 9:
  for each commonpl where txb = seltxb and date >= dt1 and date <= dt2 and deluid = ? and commonpl.grp = ar_grp[ar] no-lock use-index datenum:
    create tcommpl.
    buffer-copy commonpl to tcommpl.
    tcommpl.dep = get-dep(commonpl.uid, commonpl.date).
  end.
end.

find first tcommpl no-lock no-error.
if available tcommpl then
  for each tcommpl no-lock break by tcommpl.dep by tcommpl.arp:
    accumulate tcommpl.sum (sub-total by tcommpl.dep by tcommpl.arp).
    accumulate tcommpl.comsum (sub-total by tcommpl.dep by tcommpl.arp).

    if tcommpl.grp <> 15 then 
    v-dub-com = v-dub-com + decimal(tcommpl.chval[4]).

    if last-of(tcommpl.arp) and lookup(string(tcommpl.dep),v-depart) = 0 then do:
      find first commonls where commonls.txb = seltxb and commonls.arp = tcommpl.arp and commonls.grp = tcommpl.grp and commonls.type = tcommpl.type 
                 no-lock no-error.
      if avail commonls then do:
      depcom_ar[tcommpl.dep] = depcom_ar[tcommpl.dep] + (accum sub-total by tcommpl.arp tcommpl.comsum).
      depcom1_ar[tcommpl.dep] = depcom1_ar[tcommpl.dep] + (accum sub-total by tcommpl.arp tcommpl.sum) * commonls.comprc.
      depcom2_ar[tcommpl.dep] = depcom2_ar[tcommpl.dep] + v-dub-com.
      v-dub-com = 0.
      end.
    end.
  end.

/* пенсионные */

for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date >= dt1 
     and p_f_payment.date <= dt2 and p_f_payment.deluid = ? no-lock:
  create payment.
  buffer-copy p_f_payment to payment.
  payment.dep = get-dep(p_f_payment.uid, p_f_payment.date).
end.

find first payment no-lock no-error.
if available payment then
  for each payment NO-LOCK BREAK BY payment.dep:
    if last-of(payment.dep) and lookup(string(payment.dep),v-depart) = 0 then do:
      define buffer paycod for payment.
        find first paycod where paycod.dep = payment.dep /* and (paycod.cod = 100 or paycod.cod = 200)*/ no-lock no-error.
        if available paycod then do:
          for each paycod where paycod.dep = payment.dep /* and (paycod.cod = 100 or paycod.cod = 200)*/ no-lock:
            accumulate paycod.comiss (total).
            v-dub-pnj = v-dub-pnj + decimal(paycod.chval[4]).
          end.
          depcom_ar[payment.dep] = depcom_ar[payment.dep] + (accum total paycod.comiss).
          depcom2_ar[payment.dep] = depcom2_ar[payment.dep] + v-dub-pnj.
          v-dub-pnj = 0.
        end.
    end.
  end.

/* ------- доходы по обменным операциям ------ */

/* ------- online exchange ------------- */

for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.gl = 453020 no-lock use-index jdt:
  dept = get-dep(jl.who, jl.whn).
  if lookup(string(dept),v-depart) = 0 then depexc_ar[dept] = depexc_ar[dept] + jl.cam.
end.

/* ------- offline exchange ------------ */

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= dt1 and 
                        commonpl.date <= dt2 and 
                        commonpl.grp = 0 and 
                        commonpl.deluid = ? and 
                        commonpl.joudoc <> ? and
                        commonpl.type = 1 no-lock.

d_accnt = int (get-dep (commonpl.uid, commonpl.date)).
find first depaccnt where depaccnt.depart = d_accnt no-lock no-error.
if avail depaccnt then do:
create tcomm-buy.
update tcomm-buy.dep = depaccnt.depart
       tcomm-buy.date = commonpl.date
       tcomm-buy.sum = commonpl.sum
       tcomm-buy.comsum = commonpl.comsum
       tcomm-buy.type = commonpl.type
       tcomm-buy.crc = commonpl.typegrp
       tcomm-buy.rate = decimal(commonpl.chval[2]).
end.
end.

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= dt1 and 
                        commonpl.date <= dt2 and 
                        commonpl.grp = 0 and 
                        commonpl.deluid = ? and 
                        commonpl.joudoc <> ? and
                        commonpl.type = 2 no-lock.

d_accnt = int (get-dep (commonpl.uid, commonpl.date)).
find first depaccnt where depaccnt.depart = d_accnt no-lock no-error.
if avail depaccnt then do:
create tcomm-sell.
update tcomm-sell.dep = depaccnt.depart
       tcomm-sell.date = commonpl.date
       tcomm-sell.sum = commonpl.sum
       tcomm-sell.comsum = commonpl.comsum
       tcomm-sell.type = commonpl.type
       tcomm-sell.crc = commonpl.typegrp
       tcomm-sell.rate = decimal(commonpl.chval[2]).
end.
end.

for each depaccnt no-lock break by depaccnt.depart.
for each crc no-lock break by crc.crc.

for each tcomm-buy where tcomm-buy.dep = depaccnt.depart and tcomm-buy.crc = crc.crc no-lock break by tcomm-buy.type by tcomm-buy.dep by tcomm-buy.crc by tcomm-buy.date.

v-cursum = v-cursum + tcomm-buy.comsum.
v-sum = v-sum + tcomm-buy.sum.


if last-of (tcomm-buy.crc) and tcomm-buy.crc = crc.crc then do:
v-dep-buy = tcomm-buy.dep.
v-crc-buy = tcomm-buy.crc.
v-rate-buy = tcomm-buy.rate.
v-comsum-buy = v-cursum.
v-sum-buy = v-sum.
end. 
end. /* for each tcomm-buy */

v-cursum = 0.
v-sum = 0.

for each tcomm-sell where tcomm-sell.dep = depaccnt.depart and tcomm-sell.crc = crc.crc  no-lock break by tcomm-sell.type by tcomm-sell.dep by tcomm-sell.crc by tcomm-sell.date.
v-cursum = v-cursum + tcomm-sell.comsum.
v-sum = v-sum + tcomm-sell.sum.

if last-of (tcomm-sell.crc) and tcomm-sell.crc = crc.crc  then do:
v-dep-sell = tcomm-sell.dep.
v-crc-sell = tcomm-sell.crc.
v-rate-sell = tcomm-sell.rate.
v-comsum-sell = v-cursum.
v-sum-sell = v-sum.
end.
end. /* for each tcomm-sell */

v-cursum = 0.
v-sum = 0.

if (v-comsum-buy <> 0 or v-comsum-sell <> 0) then do:

/* Уточнить у Алии */
depexc_ar[depaccnt.depart] = depexc_ar[depaccnt.depart] + v-comsum-buy - (v-sum-buy * crc.rate[1]) + v-comsum-sell - (v-sum-sell * crc.rate[1]).

v-dep-buy = 0.
v-crc-buy = 0.
v-comsum-buy = 0.
v-rate-buy = 0.
v-sum-buy = 0.

v-dep-sell = 0.
v-crc-sell = 0.
v-comsum-sell = 0.
v-rate-sell = 0.
v-sum-sell = 0.

end.
end. /* for each crc */
end. /* for each depaccnt*/

hide message no-pause.

/* вывод в файл  */

output stream rep to reprkorev.htm.

put stream rep unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE></TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 6" skip
   "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
  "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
  "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
  "<center><font size=+1><b>Отчет по доходам сберкасс</b></font><BR>" skip
  "за период с " dt1 FORMAT "99/99/9999" " по " dt2 FORMAT "99/99/9999" "<BR><BR>" skip
  "Курс USD на конец периода " usdrate "</center><BR><BR>" skip
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<col span=5>" skip
  "<tr>" skip
  "<td width=250 rowspan=2><center><b>Сберкасса</b></center></td>" skip
  "<td colspan=4><center><b>Доходы сберкасс</b></center></td>" skip
  "<td width=120 rowspan=2><center><b>Всего доходов</b><center></td>" skip
  "</tr>" skip
  "<tr>" skip
  "<td width=120><center><b>Доходы от комиссий по принятым платежам</b></center></td>" skip
  "<td width=120><center><b>Доходы от комиссии от поставщиков услуг</b></center></td>" skip
  "<td width=120><center><b>Доходы по обменным операциям</b><center></td>" skip
  "<td width=120><center><b>Доходы по выдачам дубликатов квитанций</b><center></td>" skip
  "</tr>" skip.

def var allcom as deci init 0.
def var allcom1 as deci init 0.
def var allcom2 as deci init 0.
def var allexc as deci init 0.
def var allall as deci init 0.

do ar = 1 to 70:
  if lookup(string(ar),v-depart) = 0 then do:
   if depcom_ar[ar] <> 0 or depcom1_ar[ar] <> 0 or depcom2_ar[ar] <> 0 or depexc_ar[ar] <> 0 then do:
 
     find first ppoint where ppoint.dep = ar.
     if available ppoint then do:
        allcom = allcom + depcom_ar[ar].
        allcom1 = allcom1 + depcom1_ar[ar].
        allcom2 = allcom2 + depcom2_ar[ar].
        allexc = allexc + depexc_ar[ar].
        allall = allall + depcom_ar[ar] + depcom1_ar[ar] + depcom2_ar[ar] + depexc_ar[ar].
        put stream rep unformatted
          "<tr>" skip
          "<td>" ppoint.name "</td>" skip
          "<td>" replace(trim(string(round(depcom_ar[ar] / usdrate, 2))),".",",") "</td>" skip
          "<td>" replace(trim(string(round(depcom1_ar[ar] / usdrate, 2))),".",",") "</td>" skip
          "<td>" replace(trim(string(round(depexc_ar[ar] / usdrate, 2))),".",",") "</td>" skip
          "<td>" replace(trim(string(round(depcom2_ar[ar] / usdrate, 2))),".",",") "</td>" skip
          "<td>" replace(trim(string(round((depcom_ar[ar] + depcom1_ar[ar] + depcom2_ar[ar] + depexc_ar[ar]) / usdrate, 2))),".",",") "</td>" skip
          "</tr>" skip.
     end. /* if available */    
   end. /* if ar */
 end. /* do ar */
end.

put stream rep unformatted
    "<tr>" skip
    "<td><b>ВСЕГО</b></td>" skip
    "<td><b>" replace( trim( string( round(allcom / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allcom1 / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allexc / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allcom2 / usdrate, 2) ) ),".",",") "</b></td>" skip
    "<td><b>" replace( trim( string( round(allall / usdrate, 2) ) ),".",",") "</b></td>" skip
    "</tr>" skip
    "</table>" skip.
    
{html-end.i}
output stream rep close.
unix silent cptwin reprkorev.htm excel.
