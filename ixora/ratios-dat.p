/* ratios-dat.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-1
 * CALLER
        ratios.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        16.05.2012 aigul - счета 2707 и 2240  исключить из вкладов до востребования в срочные вклады
        05/12/2012 Luiza ТЗ 1374 от 13.05.2012  счета конвертации 285800 285900 185900
        27.02.2013 damir - Внедрено Т.З. № 1607.
        30/09/2013 Luiza - ТЗ 1946 добавление счетов 1403, 2013, 2213
*/

def shared var v-dt as date no-undo.
define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define shared temp-table tgl1
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

def shared temp-table arat
    field id as int
    field typ as char
    field nazv as char
    field odt as decimal
    field dolya as decimal
    field pdt as decimal
    field pdolya as decimal
    field izm as decimal
    field limit as char.

def shared temp-table orat
    field id as int
    field typ as char
    field nazv as char
    field odt as decimal
    field dolya as decimal
    field pdt as decimal
    field pdolya as decimal
    field izm as decimal
    field limit as char.

def var i as int.
i = 0.
def var v-active as decimal.
def var v-active1 as deci.
def var v-act as decimal.
def var v-act1 as deci.
/*ctrating active*/
v-active = 0.
v-active1 = 0.
v-act = 0.
v-act1 = 0.

for each tgl where
(
( int(substr(string(tgl.gl),1,4)) >= 1000 and int(substr(string(tgl.gl),1,3)) < 135 )
or ( int(substr(string(tgl.gl),1,3)) > 135 and int(substr(string(tgl.gl),1,4)) <= 1999 and tgl.gl <> 185800 and tgl.gl <> 185900 )
)
no-lock:
    v-active = v-active + tgl.sum.
end.

for each tgl1 where
(
( int(substr(string(tgl1.gl),1,4)) >= 1000 and int(substr(string(tgl1.gl),1,3)) < 135 )
or ( int(substr(string(tgl1.gl),1,3)) > 135 and int(substr(string(tgl1.gl),1,4)) <= 1999 and tgl1.gl <> 185800 and tgl1.gl <> 185900 )
)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.

v-act = v-active.
v-act1 = v-active1.
create arat.
arat.id = 1.
arat.typ = "Активы".
arat.nazv = "Всего активов".
arat.odt = v-active.
arat.dolya = 100.
arat.pdt = v-active1.
arat.pdolya = 100.
arat.izm = 0.


v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4)) = 1001
or int(substr(string(tgl.gl),1,4)) = 1002
or int(substr(string(tgl.gl),1,4)) = 1727
or int(substr(string(tgl.gl),1,4)) = 1010)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4)) = 1001
or int(substr(string(tgl1.gl),1,4)) = 1002
or int(substr(string(tgl1.gl),1,4)) = 1727
or int(substr(string(tgl1.gl),1,4)) = 1010)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 2.
arat.typ = "Активы".
arat.nazv = "Наличность".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=15%".

v-active = 0.
v-active1 = 0.
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1051
or int(substr(string(tgl.gl),1,4)) = 1103
or int(substr(string(tgl.gl),1,4)) = 1710)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(
int(substr(string(tgl1.gl),1,4)) = 1051
or int(substr(string(tgl1.gl),1,4)) = 1103
or int(substr(string(tgl1.gl),1,4)) = 1710)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 3.
arat.typ = "Активы".
arat.nazv = "Средства в Национальном Банке Республики Казахстан".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=50%".


v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4))  = 1251
or int(substr(string(tgl.gl),1,4))  = 1253
or int(substr(string(tgl.gl),1,4))  = 1254
or int(substr(string(tgl.gl),1,4))  = 1264

or int(substr(string(tgl.gl),1,4)) = 1300
or int(substr(string(tgl.gl),1,4)) = 1302

or int(substr(string(tgl.gl),1,4)) = 1052
or int(substr(string(tgl.gl),1,4)) = 1733
or int(substr(string(tgl.gl),1,4)) = 1734
or int(substr(string(tgl.gl),1,4)) = 1792
or int(substr(string(tgl.gl),1,4)) = 1705
or int(substr(string(tgl.gl),1,4)) = 1725
or int(substr(string(tgl.gl),1,4)) = 1726
or int(substr(string(tgl.gl),1,4)) = 1728
or (int(substr(string(tgl.gl),1,4)) >= 1730 and int(substr(string(tgl.gl),1,4)) <= 1734))
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4))  = 1251
or int(substr(string(tgl1.gl),1,4))  = 1253
or int(substr(string(tgl1.gl),1,4))  = 1254
or int(substr(string(tgl1.gl),1,4))  = 1264

or int(substr(string(tgl1.gl),1,4)) = 1300
or int(substr(string(tgl1.gl),1,4)) = 1302

or int(substr(string(tgl1.gl),1,4)) = 1052
or int(substr(string(tgl1.gl),1,4)) = 1733
or int(substr(string(tgl1.gl),1,4)) = 1734
or int(substr(string(tgl1.gl),1,4)) = 1792
or int(substr(string(tgl1.gl),1,4)) = 1705
or int(substr(string(tgl1.gl),1,4)) = 1725
or int(substr(string(tgl1.gl),1,4)) = 1726
or int(substr(string(tgl1.gl),1,4)) = 1728
or (int(substr(string(tgl1.gl),1,4)) >= 1730 and int(substr(string(tgl1.gl),1,4)) <= 1734))
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 4.
arat.typ = "Активы".
arat.nazv = "Займы, предоставленные банкам и организациям, осуществляющим отдельные виды банковских операций".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=30%".

v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4))  = 1201
or int(substr(string(tgl.gl),1,4))  = 1205
or int(substr(string(tgl.gl),1,4))  = 1206
or int(substr(string(tgl.gl),1,4))  = 1208
or int(substr(string(tgl.gl),1,4))  = 1209

or int(substr(string(tgl.gl),1,4)) = 1452

or int(substr(string(tgl.gl),1,4)) = 1481
or int(substr(string(tgl.gl),1,4)) = 1483
or int(substr(string(tgl.gl),1,4)) = 1484

or int(substr(string(tgl.gl),1,4)) = 1750
or (int(substr(string(tgl.gl),1,4)) >= 1744 and int(substr(string(tgl.gl),1,4)) <= 1746))
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4))  = 1201
or int(substr(string(tgl1.gl),1,4))  = 1205
or int(substr(string(tgl1.gl),1,4))  = 1206
or int(substr(string(tgl1.gl),1,4))  = 1208
or int(substr(string(tgl1.gl),1,4))  = 1209

or int(substr(string(tgl1.gl),1,4)) = 1452

or int(substr(string(tgl1.gl),1,4)) = 1481
or int(substr(string(tgl1.gl),1,4)) = 1483
or int(substr(string(tgl1.gl),1,4)) = 1484

or int(substr(string(tgl1.gl),1,4)) = 1750
or (int(substr(string(tgl1.gl),1,4)) >= 1744 and int(substr(string(tgl1.gl),1,4)) <= 1746))
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 5.
arat.typ = "Активы".
arat.nazv = "Инвестиции в ценные бумаги".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=20%".




v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4)) = 1460 or int(substr(string(tgl.gl),1,4)) = 1748) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,4)) = 1460 or int(substr(string(tgl1.gl),1,4)) = 1748) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 6.
arat.typ = "Активы".
arat.nazv = "Операции «РЕПО»".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=15%".



v-active = 0.
v-active1 = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) = 1470 or int(substr(string(tgl.gl),1,4)) = 1747) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,4)) = 1470 or int(substr(string(tgl1.gl),1,4)) = 1747) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 7.
arat.typ = "Активы".
arat.nazv = "Инвестиции в связанные юридические лица".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=10%".




v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4)) = 1401
or int(substr(string(tgl.gl),1,4)) = 1403
or int(substr(string(tgl.gl),1,4)) = 1407
or int(substr(string(tgl.gl),1,4)) = 1409
or int(substr(string(tgl.gl),1,4)) = 1411
or int(substr(string(tgl.gl),1,4)) = 1417
or int(substr(string(tgl.gl),1,4)) = 1424
or int(substr(string(tgl.gl),1,4)) = 1428
or int(substr(string(tgl.gl),1,4)) = 1434

or int(substr(string(tgl.gl),1,4)) = 1320
or int(substr(string(tgl.gl),1,4)) = 1740
or int(substr(string(tgl.gl),1,4)) = 1741)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4)) = 1401
or int(substr(string(tgl1.gl),1,4)) = 1403
or int(substr(string(tgl1.gl),1,4)) = 1407
or int(substr(string(tgl1.gl),1,4)) = 1409
or int(substr(string(tgl1.gl),1,4)) = 1411
or int(substr(string(tgl1.gl),1,4)) = 1417
or int(substr(string(tgl1.gl),1,4)) = 1424
or int(substr(string(tgl1.gl),1,4)) = 1428
or int(substr(string(tgl1.gl),1,4)) = 1434

or int(substr(string(tgl1.gl),1,4)) = 1320
or int(substr(string(tgl1.gl),1,4)) = 1740
or int(substr(string(tgl1.gl),1,4)) = 1741)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 8.
arat.typ = "Активы".
arat.nazv = "Займы клиентам".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = ">=30%".



v-active = 0.
v-active1 = 0.
for each tgl where (
int(substr(string(tgl.gl),1,4)) = 1650
or int(substr(string(tgl.gl),1,4)) = 1651
or int(substr(string(tgl.gl),1,4)) = 1652
or int(substr(string(tgl.gl),1,4)) = 1653
or int(substr(string(tgl.gl),1,4)) = 1654
or int(substr(string(tgl.gl),1,4)) = 1657
or int(substr(string(tgl.gl),1,4)) = 1658
or int(substr(string(tgl.gl),1,4)) = 1659
or int(substr(string(tgl.gl),1,4)) = 1692
or int(substr(string(tgl.gl),1,4)) = 1693
or int(substr(string(tgl.gl),1,4)) = 1694
or int(substr(string(tgl.gl),1,4)) = 1697
or int(substr(string(tgl.gl),1,4)) = 1698
or int(substr(string(tgl.gl),1,4)) = 1699
or int(substr(string(tgl.gl),1,4)) = 1690) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(
int(substr(string(tgl1.gl),1,4)) = 1650
or int(substr(string(tgl1.gl),1,4)) = 1651
or int(substr(string(tgl1.gl),1,4)) = 1652
or int(substr(string(tgl1.gl),1,4)) = 1653
or int(substr(string(tgl1.gl),1,4)) = 1654
or int(substr(string(tgl1.gl),1,4)) = 1657
or int(substr(string(tgl1.gl),1,4)) = 1658
or int(substr(string(tgl1.gl),1,4)) = 1659
or int(substr(string(tgl1.gl),1,4)) = 1692
or int(substr(string(tgl1.gl),1,4)) = 1693
or int(substr(string(tgl1.gl),1,4)) = 1694
or int(substr(string(tgl1.gl),1,4)) = 1697
or int(substr(string(tgl1.gl),1,4)) = 1698
or int(substr(string(tgl1.gl),1,4)) = 1699
or int(substr(string(tgl1.gl),1,4)) = 1690)
 no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 9.
arat.typ = "Активы".
arat.nazv = "Инвестиции в недвижимость (здания банка)".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
arat.limit = "<=10%".




v-active = 0.
v-active1 = 0.
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1602
or int(substr(string(tgl.gl),1,4)) = 1793
or int(substr(string(tgl.gl),1,4)) = 1799
or (int(substr(string(tgl.gl),1,4)) >= 1851 and int(substr(string(tgl.gl),1,4)) <= 1879 and tgl.gl <> 185800 and tgl.gl <> 185900)
/*or int(substr(string(tgl.gl),1,4)) = 1894*/
or int(substr(string(tgl.gl),1,4)) = 1816
or (int(substr(string(tgl.gl),1,4)) >= 1891 and int(substr(string(tgl.gl),1,4)) <= 1899)
)
no-lock:
    v-active = v-active + tgl.sum.
end.

for each tgl1 where
(
int(substr(string(tgl1.gl),1,4)) = 1602
or int(substr(string(tgl1.gl),1,4)) = 1793
or int(substr(string(tgl1.gl),1,4)) = 1799
or (int(substr(string(tgl1.gl),1,4)) >= 1851 and int(substr(string(tgl1.gl),1,4)) <= 1879 and tgl1.gl <> 185800 and tgl1.gl <> 185900)
/*or int(substr(string(tgl1.gl),1,4)) = 1894*/
or int(substr(string(tgl1.gl),1,4)) = 1816
or (int(substr(string(tgl1.gl),1,4)) >= 1891 and int(substr(string(tgl1.gl),1,4)) <= 1899)
)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create arat.
arat.id = 10.
arat.typ = "Активы".
arat.nazv = "Прочие активы".
arat.odt = v-active.
arat.dolya = v-active * 100 / v-act.
arat.pdt = v-active1.
arat.pdolya = v-active1 * 100 / v-act1.
arat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).

/*ctrating passive*/
v-act = 0.
v-act1 = 0.
v-active = 0.
v-active1 = 0.
for each tgl where
(
( int(substr(string(tgl.gl),1,4)) >= 2000 and int(substr(string(tgl.gl),1,3)) < 215 )
or ( int(substr(string(tgl.gl),1,3)) > 215 and int(substr(string(tgl.gl),1,4)) <= 2999 and tgl.gl <> 285800 and tgl.gl <> 285900 )
)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(
( int(substr(string(tgl1.gl),1,4)) >= 2000 and int(substr(string(tgl1.gl),1,3)) < 215 )
or ( int(substr(string(tgl1.gl),1,3)) > 215 and int(substr(string(tgl1.gl),1,4)) <= 2999 and tgl1.gl <> 285800 and tgl1.gl <> 285900)
)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
v-act = v-active.
v-act1 = v-active1.
create orat.
orat.id = 10.
orat.typ = "Структуры обязательств".
orat.nazv = "Итого обязательства".
orat.odt = v-active.
orat.dolya = 100.
orat.pdt = v-active1.
orat.pdolya = 100.
orat.izm = 0.






v-active = 0.
v-active1 = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) = 2203 or int(substr(string(tgl.gl),1,4)) = 2204 or int(substr(string(tgl.gl),1,4)) = 2718) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,4)) = 2203 or int(substr(string(tgl1.gl),1,4)) = 2204 or int(substr(string(tgl1.gl),1,4)) = 2718) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 2.
orat.typ = "Структуры обязательств".
orat.nazv = "Текущие счета".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = ">=10%".

v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4))  = 2206
or int(substr(string(tgl.gl),1,4)) = 2207
or int(substr(string(tgl.gl),1,4)) = 2213
or int(substr(string(tgl.gl),1,4)) = 2215
or int(substr(string(tgl.gl),1,4)) = 2217
or int(substr(string(tgl.gl),1,4)) = 2219
or int(substr(string(tgl.gl),1,4)) = 2223
or int(substr(string(tgl.gl),1,4)) = 2719
or int(substr(string(tgl.gl),1,4)) = 2721
or int(substr(string(tgl.gl),1,4)) = 2723
or int(substr(string(tgl.gl),1,4)) = 2240
or int(substr(string(tgl.gl),1,4)) = 2707) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4))  = 2206
or int(substr(string(tgl1.gl),1,4)) = 2207
or int(substr(string(tgl1.gl),1,4)) = 2213
or int(substr(string(tgl1.gl),1,4)) = 2215
or int(substr(string(tgl1.gl),1,4)) = 2217
or int(substr(string(tgl1.gl),1,4)) = 2219
or int(substr(string(tgl1.gl),1,4)) = 2223
or int(substr(string(tgl1.gl),1,4)) = 2719
or int(substr(string(tgl1.gl),1,4)) = 2721
or int(substr(string(tgl1.gl),1,4)) = 2723
or int(substr(string(tgl1.gl),1,4)) = 2240
or int(substr(string(tgl1.gl),1,4)) = 2707)  no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 3.
orat.typ = "Структуры обязательств".
orat.nazv = "Срочные вклады".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = ">=15%".


v-active = 0.
v-active1 = 0.
for each tgl where
(int(substr(string(tgl.gl),1,4)) = 2205
or int(substr(string(tgl.gl),1,4)) = 2237)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl1.gl),1,4)) = 2205
or int(substr(string(tgl1.gl),1,4)) = 2237)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 4.
orat.typ = "Структуры обязательств".
orat.nazv = "Вклады до  востребования".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=5%".


v-active = 0.
v-active1 = 0.
/*for each tgl where
(int(substr(string(tgl.gl),1,4)) = 2223
or int(substr(string(tgl.gl),1,4)) = 2237
or int(substr(string(tgl.gl),1,4)) = 2240
or int(substr(string(tgl.gl),1,4)) = 2203
or int(substr(string(tgl.gl),1,4)) = 2204
or int(substr(string(tgl.gl),1,4)) = 2205
or int(substr(string(tgl.gl),1,4)) = 2206
or int(substr(string(tgl.gl),1,4)) = 2207
or int(substr(string(tgl.gl),1,4)) = 2208
or int(substr(string(tgl.gl),1,4)) = 2213
or int(substr(string(tgl.gl),1,4)) = 2215
or int(substr(string(tgl.gl),1,4)) = 2217
or int(substr(string(tgl.gl),1,4)) = 2219)
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(int(substr(string(tgl.gl),1,4)) = 2223
or int(substr(string(tgl.gl),1,4)) = 2237
or int(substr(string(tgl.gl),1,4)) = 2240
or int(substr(string(tgl.gl),1,4)) = 2203
or int(substr(string(tgl.gl),1,4)) = 2204
or int(substr(string(tgl.gl),1,4)) = 2205
or int(substr(string(tgl.gl),1,4)) = 2206
or int(substr(string(tgl.gl),1,4)) = 2207
or int(substr(string(tgl.gl),1,4)) = 2208
or int(substr(string(tgl.gl),1,4)) = 2213
or int(substr(string(tgl.gl),1,4)) = 2215
or int(substr(string(tgl.gl),1,4)) = 2217
or int(substr(string(tgl.gl),1,4)) = 2219)
no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.*/

for each orat where (orat.id = 4 or orat.id = 3 or orat.id = 2) no-lock:
    v-active = v-active + orat.odt.
    v-active1 = v-active1 + orat.pdt.
end.

create orat.
orat.id = 1.
orat.typ = "Структуры обязательств".
orat.nazv = "Всего депозитов".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = ">=50%".


v-active = 0.
v-active1 = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2012 and int(substr(string(tgl.gl),1,4)) <= 2014)
or int(substr(string(tgl.gl),1,4)) = 2016
or (int(substr(string(tgl.gl),1,4)) >= 2022 and int(substr(string(tgl.gl),1,4)) <= 2024)
or int(substr(string(tgl.gl),1,4)) = 2041
or int(substr(string(tgl.gl),1,4)) = 2042
or (int(substr(string(tgl.gl),1,4)) >= 2044 and int(substr(string(tgl.gl),1,4)) <= 2048)
or int(substr(string(tgl.gl),1,4)) = 2052
or (int(substr(string(tgl.gl),1,4)) >= 2054 and int(substr(string(tgl.gl),1,4)) <= 2058)
or (int(substr(string(tgl.gl),1,4)) >= 2064 and int(substr(string(tgl.gl),1,4)) <= 2070)
or int(substr(string(tgl.gl),1,4)) = 2112
or int(substr(string(tgl.gl),1,4)) = 2113
or (int(substr(string(tgl.gl),1,4)) >= 2122 and int(substr(string(tgl.gl),1,4)) <= 2133)
or (int(substr(string(tgl.gl),1,4)) >= 2135 and int(substr(string(tgl.gl),1,4)) <= 2138)
or int(substr(string(tgl.gl),1,4)) = 2013
or int(substr(string(tgl.gl),1,4)) = 2011
or int(substr(string(tgl.gl),1,4)) =  2021
or ( int(substr(string(tgl.gl),1,4)) >= 2034 and int(substr(string(tgl.gl),1,4)) <= 2038 )
or int(substr(string(tgl.gl),1,4)) =  2051
or int(substr(string(tgl.gl),1,4)) =  2059
or int(substr(string(tgl.gl),1,4)) =  2111
or int(substr(string(tgl.gl),1,4)) =  2121
or int(substr(string(tgl.gl),1,4)) =  2139
or int(substr(string(tgl.gl),1,4)) =  2140
)
and tgl.geo = "021"
no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(
(int(substr(string(tgl1.gl),1,4)) >= 2012 and int(substr(string(tgl1.gl),1,4)) <= 2014)
or int(substr(string(tgl1.gl),1,4)) = 2016
or (int(substr(string(tgl1.gl),1,4)) >= 2022 and int(substr(string(tgl1.gl),1,4)) <= 2024)
or int(substr(string(tgl1.gl),1,4)) = 2041
or int(substr(string(tgl1.gl),1,4)) = 2042
or (int(substr(string(tgl1.gl),1,4)) >= 2044 and int(substr(string(tgl1.gl),1,4)) <= 2048)
or int(substr(string(tgl1.gl),1,4)) = 2052
or (int(substr(string(tgl1.gl),1,4)) >= 2054 and int(substr(string(tgl1.gl),1,4)) <= 2058)
or (int(substr(string(tgl1.gl),1,4)) >= 2064 and int(substr(string(tgl1.gl),1,4)) <= 2070)
or int(substr(string(tgl1.gl),1,4)) = 2112
or int(substr(string(tgl1.gl),1,4)) = 2113
or (int(substr(string(tgl1.gl),1,4)) >= 2122 and int(substr(string(tgl1.gl),1,4)) <= 2133)
or (int(substr(string(tgl1.gl),1,4)) >= 2135 and int(substr(string(tgl1.gl),1,4)) <= 2138)
or int(substr(string(tgl1.gl),1,4)) = 2013
or int(substr(string(tgl1.gl),1,4)) = 2011
or int(substr(string(tgl1.gl),1,4)) =  2021
or ( int(substr(string(tgl1.gl),1,4)) >= 2034 and int(substr(string(tgl1.gl),1,4)) <= 2038 )
or int(substr(string(tgl1.gl),1,4)) =  2051
or int(substr(string(tgl1.gl),1,4)) =  2059
or int(substr(string(tgl1.gl),1,4)) =  2111
or int(substr(string(tgl1.gl),1,4)) =  2121
or int(substr(string(tgl1.gl),1,4)) =  2139
or int(substr(string(tgl1.gl),1,4)) =  2140
)
and tgl1.geo = "021" no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 5.
orat.typ = "Структуры обязательств".
orat.nazv = "Заимствования на местном межбанковском рынке".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=20%".


v-active = 0.
v-active1 = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2012 and int(substr(string(tgl.gl),1,4)) <= 2014)
or int(substr(string(tgl.gl),1,4)) = 2016
or (int(substr(string(tgl.gl),1,4)) >= 2022 and int(substr(string(tgl.gl),1,4)) <= 2024)
or int(substr(string(tgl.gl),1,4)) = 2041
or int(substr(string(tgl.gl),1,4)) = 2042
or (int(substr(string(tgl.gl),1,4)) >= 2044 and int(substr(string(tgl.gl),1,4)) <= 2048)
or int(substr(string(tgl.gl),1,4)) = 2052
or (int(substr(string(tgl.gl),1,4)) >= 2054 and int(substr(string(tgl.gl),1,4)) <= 2058)
or (int(substr(string(tgl.gl),1,4)) >= 2064 and int(substr(string(tgl.gl),1,4)) <= 2070)
or int(substr(string(tgl.gl),1,4)) = 2112
or int(substr(string(tgl.gl),1,4)) = 2113
or (int(substr(string(tgl.gl),1,4)) >= 2122 and int(substr(string(tgl.gl),1,4)) <= 2133)
or (int(substr(string(tgl.gl),1,4)) >= 2135 and int(substr(string(tgl.gl),1,4)) <= 2138)
or int(substr(string(tgl.gl),1,4)) = 2013
)
and tgl.geo <> "021" no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where
(
(int(substr(string(tgl1.gl),1,4)) >= 2012 and int(substr(string(tgl1.gl),1,4)) <= 2014)
or int(substr(string(tgl1.gl),1,4)) = 2016
or (int(substr(string(tgl1.gl),1,4)) >= 2022 and int(substr(string(tgl1.gl),1,4)) <= 2024)
or int(substr(string(tgl1.gl),1,4)) = 2041
or int(substr(string(tgl1.gl),1,4)) = 2042
or (int(substr(string(tgl1.gl),1,4)) >= 2044 and int(substr(string(tgl1.gl),1,4)) <= 2048)
or int(substr(string(tgl1.gl),1,4)) = 2052
or (int(substr(string(tgl1.gl),1,4)) >= 2054 and int(substr(string(tgl1.gl),1,4)) <= 2058)
or (int(substr(string(tgl1.gl),1,4)) >= 2064 and int(substr(string(tgl1.gl),1,4)) <= 2070)
or int(substr(string(tgl1.gl),1,4)) = 2112
or int(substr(string(tgl1.gl),1,4)) = 2113
or (int(substr(string(tgl1.gl),1,4)) >= 2122 and int(substr(string(tgl1.gl),1,4)) <= 2133)
or (int(substr(string(tgl1.gl),1,4)) >= 2135 and int(substr(string(tgl1.gl),1,4)) <= 2138)
or int(substr(string(tgl1.gl),1,4)) = 2013
)
and tgl1.geo <> "021" no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 6.
orat.typ = "Структуры обязательств".
orat.nazv = "Иностранные заимствования".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=10%".



v-active = 0.
v-active1 = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) = 2300) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,4)) = 2300) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 7.
orat.typ = "Структуры обязательств".
orat.nazv = "Собственные ценные бумаги банка".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=10%".


v-active = 0.
v-active1 = 0.
for each tgl where (int(substr(string(tgl.gl),1,1)) = 0) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,1)) = 0) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 8.
orat.typ = "Структуры обязательств".
orat.nazv = "Займы, полученные от связанных лиц".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=10%".

v-active = 0.
v-active1 = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) = 2402 or int(substr(string(tgl.gl),1,4)) = 2740) no-lock:
    v-active = v-active + tgl.sum.
end.
for each tgl1 where (int(substr(string(tgl1.gl),1,4)) = 2402 or int(substr(string(tgl1.gl),1,4)) = 2740) no-lock:
    v-active1 = v-active1 + tgl1.sum.
end.
create orat.
orat.id = 9.
orat.typ = "Структуры обязательств".
orat.nazv = "Субординирован-ный долг".
orat.odt = v-active.
orat.dolya = v-active * 100 / v-act.
orat.pdt = v-active1.
orat.pdolya = v-active1 * 100 / v-act1.
orat.izm = (v-active * 100 / v-act) - (v-active1 * 100 / v-act1).
orat.limit = "<=20%".


