/* rkoexc.p
 * MODULE
        Обменные операции в Offline PragmaTX 
 * DESCRIPTION
        Отчет по обменным операциям в СПФ по г. Алматы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        xcm2arp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01/22/04 kanat
 * CHANGES
        02/04/04 kanat Добавил вычисление доходов по операциям
        13/04/04 kanat Переделал вычисление доходов (разделил доходы по покупке и продаже).
        02/09/04 kanat - изменения по обнулению промежуточных сумм при рассмотрении операций продажи валюты
*/


{global.i}
{get-dep.i}
{comm-txb.i}

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

def var d_accnt as integer.
def var v-date-begin as date.
def var v-date-end as date.
def var seltxb as integer.

def var v-cursum as decimal init 0.
def var v-sum as decimal init 0.
def var v-wholesum as decimal init 0.

def var v-comsum-buy as decimal.
def var v-comsum-sell as decimal.

def var v-sum-buy as decimal.
def var v-sum-sell as decimal.

def var v-dep-buy as integer.
def var v-dep-sell as integer.

def var v-crc-buy as integer.
def var v-crc-sell as integer.

def var v-rate-buy as decimal.
def var v-rate-sell as decimal.

def var v-buy-whole as decimal.
def var v-sell-whole as decimal.

def var v-buy-rate-fin as decimal.
def var v-sell-rate-fin as decimal.

seltxb = comm-cod().

v-date-begin = g-today.
v-date-end = g-today.


update v-date-begin label "Введите период с " format '99/99/99' skip
with side-label row 2 centered frame dataa.

update v-date-end label "по " format '99/99/99' skip
with side-label row 2 centered frame dataa.

hide frame dataa.

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-end and 
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
                        commonpl.date >= v-date-begin and 
                        commonpl.date <= v-date-end and 
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

output to rkobm.txt.
put unformatted "АО TEXAKABANK " skip.
put unformatted "Дата: " string(g-today) skip.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
put unformatted "Исполнитель: " ofc.ofc " (" ofc.name ")" skip(2).
put unformatted "    ОТЧЕТ ПО ОБМЕННЫМ ОПЕРАЦИЯМ (OFFLINE PRAGMATX) ПО СПФ АО TEXAKABANK г. АЛМАТЫ с " string(v-date-begin) " по " string(v-date-end) skip.
put unformatted fill("-", 120) format "x(120)" skip.
put unformatted "Наименование СПФ   Валюта   Куплено валюты   Доход (покупка)   Продано валюты   Доход (продажа)" skip.
put unformatted fill("-", 120) format "x(120)" skip.
for each depaccnt no-lock break by depaccnt.depart.
for each crc no-lock break by crc.crc.

for each tcomm-buy where tcomm-buy.dep = depaccnt.depart and tcomm-buy.crc = crc.crc no-lock break by tcomm-buy.type by tcomm-buy.dep by tcomm-buy.crc by tcomm-buy.date.

v-cursum = v-cursum + tcomm-buy.comsum.
v-sum = v-sum + tcomm-buy.sum.

/*
put unformatted fill("",18) format "x(18)" " " 
                crc.code format "x(10)" " " 
                string(tcomm-buy.sum) format "x(15)" " " 
                string(tcomm-buy.rate) format "x(15)" " " 
                fill(" ",15) format "x(15)" " " 
                fill(" ",15) format "x(15)" skip. 
if last-of (tcomm-buy.date) then do:
find last crchis where crchis.rdt <= tcomm-buy.date and crchis.crc = tcomm-buy.crc no-lock no-error.
if avail crchis then 
put unformatted "Итого доход от покупки за " tcomm-buy.date " " string((v-sum * crchis.rate[1]) - v-cursum) format "x(15)" skip.
end.
*/


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


/*
put unformatted fill("",18) format "x(18)" " " 
                crc.code format "x(10)" " " 
                fill(" ",15) format "x(15)" " " 
                fill(" ",15) format "x(15)" " " 
                string(tcomm-sell.sum) format "x(15)" " " 
                string(tcomm-sell.rate) format "x(15)" skip. 
if last-of (tcomm-sell.date) then do:
find last crchis where crchis.rdt <= tcomm-sell.date and crchis.crc = tcomm-sell.crc no-lock no-error.
if avail crchis then 
put unformatted "Итого доход от продажи за " tcomm-sell.date  " " string((v-sum * crchis.rate[1]) - v-cursum) format "x(15)" skip.
end.
*/


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

if /*first-of (depaccnt.depart) and*/ (v-comsum-buy <> 0 or v-comsum-sell <> 0) then do:
find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
put unformatted ppoint.name format "x(18)" " " 
                crc.code format "x(10)" " " 
                string(v-sum-buy) format "x(15)" " " 
                string(v-comsum-buy - (v-sum-buy * crc.rate[1])) format "x(18)"
                string(v-sum-sell) format "x(15)" " " 
                string(v-comsum-sell - (v-sum-sell * crc.rate[1])) format "x(18)" skip. 

v-buy-whole = v-buy-whole + v-comsum-buy.
v-sell-whole = v-sell-whole + v-comsum-sell.

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


put unformatted fill("-", 120) format "x(120)" skip.   
put unformatted "ИТОГО:                        " string(v-buy-whole) format "x(15)" fill(" ", 18) format "x(17)" 
                                                 string(v-sell-whole) format "x(15)" fill(" ", 18) format "x(17)" skip.
put unformatted fill("-", 120) format "x(120)" skip.

output close.
run menu-prt ("rkobm.txt").

