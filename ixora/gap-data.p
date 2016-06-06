/* gap-data.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-9
 * CALLER
        Список процедур, вызывающих этот файл
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
        14/02/2013 Luiza - ТЗ № 1667 добавила счет 2240
        11/10/2013 Luiza - ТЗ № 1957 добавила счета 1401 1403
*/

def shared var v-dt as date no-undo.
def shared temp-table wrk
    field num as int
    field nazv as char
    field gl as char
    field mtyp as char
    field typ as char
    field crc as int
    field t7d as deci
    field t1m as deci
    field t3m as deci
    field t6m as deci
    field t1y as deci
    field t3y as deci
    field tm3y as deci
    field tnd as deci
    field ttot as deci
    field u7d as deci
    field u1m as deci
    field u3m as deci
    field u6m as deci
    field u1y as deci
    field u3y as deci
    field um3y as deci
    field und as deci
    field utot as deci
    field eu7d as deci
    field eu1m as deci
    field eu3m as deci
    field eu6m as deci
    field eu1y as deci
    field eu3y as deci
    field eum3y as deci
    field eund as deci
    field eutot as deci
    field p7d as deci
    field p1m as deci
    field p3m as deci
    field p6m as deci
    field p1y as deci
    field p3y as deci
    field pm3y as deci
    field pnd as deci
    field ptot as deci.

def var v-bal as decimal.
def var v-bal-kzt as decimal.
def var v-bal-kzt-7d as decimal.
def var v-bal-kzt-1m as decimal.
def var v-bal-kzt-3m as decimal.
def var v-bal-kzt-6m as decimal.
def var v-bal-kzt-1y as decimal.
def var v-bal-kzt-3y as decimal.
def var v-bal-kzt-m3y as decimal.
def var v-bal-kzt-nd as decimal.
def var v-bal-usd-7d as decimal.
def var v-bal-usd-1m as decimal.
def var v-bal-usd-3m as decimal.
def var v-bal-usd-6m as decimal.
def var v-bal-usd-1y as decimal.
def var v-bal-usd-3y as decimal.
def var v-bal-usd-m3y as decimal.
def var v-bal-usd-nd as decimal.
def var v-bal-eur-7d as decimal.
def var v-bal-eur-1m as decimal.
def var v-bal-eur-3m as decimal.
def var v-bal-eur-6m as decimal.
def var v-bal-eur-1y as decimal.
def var v-bal-eur-3y as decimal.
def var v-bal-eur-m3y as decimal.
def var v-bal-eur-nd as decimal.
def var v-bal-o-7d as decimal.
def var v-bal-o-1m as decimal.
def var v-bal-o-3m as decimal.
def var v-bal-o-6m as decimal.
def var v-bal-o-1y as decimal.
def var v-bal-o-3y as decimal.
def var v-bal-o-m3y as decimal.
def var v-bal-o-nd as decimal.
def var v-gl as int.
def var v-cdt as date.
def var v-days as int.
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

def buffer b-wrk for wrk.

v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1101 and int(substr(string(tgl.gl),1,4)) <= 1106) no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if tgl.cdt - v-dt <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if tgl.cdt - v-dt > 7 and tgl.cdt - v-dt <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where (int(substr(string(tgl.gl),1,4)) >= 1101 and int(substr(string(tgl.gl),1,4)) <= 1106) no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 1.
    wrk.mtyp = "Активы".
    wrk.typ = "Требования к НБРК".
    wrk.gl = "1100".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where ((int(substr(string(tgl.gl),1,4)) >= 1201 and int(substr(string(tgl.gl),1,4)) <= 1206)
or ((int(substr(string(tgl.gl),1,4)) >= 1208 and int(substr(string(tgl.gl),1,4)) <= 1209))
or ((int(substr(string(tgl.gl),1,4)) >= 1451 and int(substr(string(tgl.gl),1,4)) <= 1459))
or ((int(substr(string(tgl.gl),1,4)) >= 1481 and int(substr(string(tgl.gl),1,4)) <= 1485)))
   no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where ((int(substr(string(tgl.gl),1,4)) >= 1201 and int(substr(string(tgl.gl),1,4)) <= 1206)
or ((int(substr(string(tgl.gl),1,4)) >= 1208 and int(substr(string(tgl.gl),1,4)) <= 1209))
or ((int(substr(string(tgl.gl),1,4)) >= 1451 and int(substr(string(tgl.gl),1,4)) <= 1459))
or ((int(substr(string(tgl.gl),1,4)) >= 1481 and int(substr(string(tgl.gl),1,4)) <= 1485))) no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 2.
    wrk.mtyp = "Активы".
    wrk.typ = "Ценные бумаги".
    wrk.gl = "1200".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.






for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1251 and int(substr(string(tgl.gl),1,4)) <= 1257)
or ((int(substr(string(tgl.gl),1,4)) >= 1260 and int(substr(string(tgl.gl),1,4)) <= 1267))
or ((int(substr(string(tgl.gl),1,4)) >= 1301 and int(substr(string(tgl.gl),1,4)) <= 1306))
or ((int(substr(string(tgl.gl),1,4)) >= 1309 and int(substr(string(tgl.gl),1,4)) <= 1313))
or ((int(substr(string(tgl.gl),1,4)) >= 1321 and int(substr(string(tgl.gl),1,4)) <= 1331))
) no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1251 and int(substr(string(tgl.gl),1,4)) <= 1257)
or ((int(substr(string(tgl.gl),1,4)) >= 1260 and int(substr(string(tgl.gl),1,4)) <= 1267))
or ((int(substr(string(tgl.gl),1,4)) >= 1301 and int(substr(string(tgl.gl),1,4)) <= 1306))
or ((int(substr(string(tgl.gl),1,4)) >= 1309 and int(substr(string(tgl.gl),1,4)) <= 1313))
or ((int(substr(string(tgl.gl),1,4)) >= 1321 and int(substr(string(tgl.gl),1,4)) <= 1331))
) no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 3.
    wrk.mtyp = "Активы".
    wrk.typ = "Вклады, размещенные в других банках".
    wrk.gl = "1250, 1300, 1320".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1401 and int(substr(string(tgl.gl),1,4)) <= 1445)
    or tgl.gl  = 140150 or tgl.gl = 140160 or substr(string(tgl.gl),1,4) = "1403" no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if tgl.gl = 140150 or  tgl.gl = 140160 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        else do:
            if substr(string(tgl.gl),1,4) = "1403" then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
            else do:
                if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
                if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
                if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
                if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
                if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
                if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
                if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
                if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
            end.
        end.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if tgl.gl = 140150 or  tgl.gl = 140160 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        else do:
            if substr(string(tgl.gl),1,4) = "1403" then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
            else do:
                if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
                if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
                if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
                if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
                if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
                if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
                if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
                if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
            end.
        end.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if tgl.gl = 140150 or  tgl.gl = 140160 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        else do:
            if substr(string(tgl.gl),1,4) = "1403" then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
            else do:
                if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
                if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
                if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
                if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
                if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
                if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
                if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
                if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
            end.
        end.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if tgl.gl = 140150 or  tgl.gl = 140160 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        else do:
            if substr(string(tgl.gl),1,4) = "1403" then v-bal-o-3y = v-bal-o-3y + tgl.sum.
            else do:
                if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
                if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
                if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
                if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
                if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
                if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
                if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
                if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
            end.
        end.
    end.
end.
find first tgl where
(int(substr(string(tgl.gl),1,4)) >= 1401 and int(substr(string(tgl.gl),1,4)) <= 1445)
or tgl.gl  = 140150 or tgl.gl = 140160 or substr(string(tgl.gl),1,4) = "1403"  no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 4.
    wrk.mtyp = "Активы".
    wrk.typ = "Займы, предоставлен-ные клиентам".
    wrk.gl = "1400".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.

for each tgl where
(int(substr(string(tgl.gl),1,4)) >= 1461 and int(substr(string(tgl.gl),1,4)) <= 1463) no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where (int(substr(string(tgl.gl),1,4)) >= 1461 and int(substr(string(tgl.gl),1,4)) <= 1463)  no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 5.
    wrk.mtyp = "Активы".
    wrk.typ = "РЕПО".
    wrk.gl = "1460".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.

for each tgl where /*(
    substr(string(tgl.gl),1,3) = "203" or substr(string(tgl.gl),1,3) = "204" or
    substr(string(tgl.gl),1,4) = "2052" or (substr(string(tgl.gl),1,4) = "2064" or
    substr(string(tgl.gl),1,3) = "207" or substr(string(tgl.gl),1,4) = "2065" or
    substr(string(tgl.gl),1,4) = "2066" or substr(string(tgl.gl),1,4) = "2067" or
    substr(string(tgl.gl),1,4) = "2068" or substr(string(tgl.gl),1,4) = "2069")
    or (substr(string(tgl.gl),1,3) = "211" or substr(string(tgl.gl),1,3) = "214" or
    substr(string(tgl.gl),1,4) = "2111" or substr(string(tgl.gl),1,4) = "2112"
    or substr(string(tgl.gl),1,4) = "2113"))*/
    (
    (int(substr(string(tgl.gl),1,4)) >= 2034 and int(substr(string(tgl.gl),1,4)) <= 2038)
    or ((int(substr(string(tgl.gl),1,4)) >= 2041 and int(substr(string(tgl.gl),1,4)) <= 2042))
    or int(substr(string(tgl.gl),1,4)) = 2052
    or ((int(substr(string(tgl.gl),1,4)) >= 2054 and int(substr(string(tgl.gl),1,4)) <= 2059))
    or ((int(substr(string(tgl.gl),1,4)) >= 2064 and int(substr(string(tgl.gl),1,4)) <= 2070))
    or int(substr(string(tgl.gl),1,4)) = 2113
    or ((int(substr(string(tgl.gl),1,4)) >= 2121 and int(substr(string(tgl.gl),1,4)) <= 2131))
    or int(substr(string(tgl.gl),1,4)) = 2133
    or ((int(substr(string(tgl.gl),1,4)) >= 2135 and int(substr(string(tgl.gl),1,4)) <= 2140))
    )no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where (
    (int(substr(string(tgl.gl),1,4)) >= 2034 and int(substr(string(tgl.gl),1,4)) <= 2038)
    or ((int(substr(string(tgl.gl),1,4)) >= 2041 and int(substr(string(tgl.gl),1,4)) <= 2042))
    or int(substr(string(tgl.gl),1,4)) = 2052
    or ((int(substr(string(tgl.gl),1,4)) >= 2054 and int(substr(string(tgl.gl),1,4)) <= 2059))
    or ((int(substr(string(tgl.gl),1,4)) >= 2064 and int(substr(string(tgl.gl),1,4)) <= 2070))
    or int(substr(string(tgl.gl),1,4)) = 2113
    or ((int(substr(string(tgl.gl),1,4)) >= 2121 and int(substr(string(tgl.gl),1,4)) <= 2131))
    or int(substr(string(tgl.gl),1,4)) = 2133
    or ((int(substr(string(tgl.gl),1,4)) >= 2135 and int(substr(string(tgl.gl),1,4)) <= 2140))
    ) no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 7.
    wrk.mtyp = "Обязательства".
    wrk.typ = "Межбанковское привлечение".
    wrk.gl = "2030, 2040, 2052, 2064-2070, 2110-2140".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where (
    substr(string(tgl.gl),1,4) = "2206"
    or substr(string(tgl.gl),1,4) = "2207"
    or substr(string(tgl.gl),1,4) = "2208" or substr(string(tgl.gl),1,4) = "2213"
    or substr(string(tgl.gl),1,4) = "2215" or substr(string(tgl.gl),1,4) = "2217"
    or substr(string(tgl.gl),1,4) = "2219" or substr(string(tgl.gl),1,4) = "2223" or substr(string(tgl.gl),1,4) = "2240") no-lock:
    if tgl.acc = "KZ18470172223A130202" or tgl.acc = "KZ30470172223A316808" or tgl.acc = "KZ43470172223A302315" then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
    else do:
        if tgl.crc = 1 then do:
            v-days = tgl.cdt - v-dt.
            if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
            if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
            if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
            if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
            if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
            if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
            if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
            if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
        end.
        if tgl.crc = 3 then do:
            v-days = tgl.cdt - v-dt.
            if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
            if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
            if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
            if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
            if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
            if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
            if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
            if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
        end.
        if tgl.crc = 2 then do:
            v-days = tgl.cdt - v-dt.
            if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
            if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
            if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
            if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
            if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
            if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
            if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
            if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
        end.
        if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
            v-days = tgl.cdt - v-dt.
            if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
            if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
            if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
            if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
            if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
            if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
            if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
            if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
        end.
    end.
end.
find first tgl where (
    substr(string(tgl.gl),1,4) = "2206" or substr(string(tgl.gl),1,4) = "2207" or
    substr(string(tgl.gl),1,4) = "2208" or substr(string(tgl.gl),1,4) = "2213"
    or substr(string(tgl.gl),1,4) = "2215" or substr(string(tgl.gl),1,4) = "2217"
    or substr(string(tgl.gl),1,4) = "2219" or substr(string(tgl.gl),1,4) = "2223"
    or substr(string(tgl.gl),1,4) = "2240") no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 8.
    wrk.mtyp = "Обязательства".
    wrk.typ = "Срочные обязательства перед клиентами".
    wrk.gl = "2206,2207,2208,2213,2215,2217,2219,2223,2240".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 2400 and int(substr(string(tgl.gl),1,4)) <= 2451) no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where (int(substr(string(tgl.gl),1,4)) >= 2400 and int(substr(string(tgl.gl),1,4)) <= 2451) no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 9.
    wrk.mtyp = "Обязательства".
    wrk.typ = "Суб долг".
    wrk.gl = "2400".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each tgl where substr(string(tgl.gl),1,4) = "2255" no-lock:
    if tgl.crc = 1 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-kzt-7d = v-bal-kzt-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-kzt-1m = v-bal-kzt-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-kzt-3m = v-bal-kzt-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-kzt-6m = v-bal-kzt-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-kzt-1y = v-bal-kzt-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-kzt-3y = v-bal-kzt-3y + tgl.sum.
        if v-days > 1095 then v-bal-kzt-m3y = v-bal-kzt-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-kzt-nd = v-bal-kzt-nd + tgl.sum.
    end.
    if tgl.crc = 3 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-eur-7d = v-bal-eur-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-eur-1m = v-bal-eur-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-eur-3m = v-bal-eur-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-eur-6m = v-bal-eur-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-eur-1y = v-bal-eur-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-eur-3y = v-bal-eur-3y + tgl.sum.
        if v-days > 1095 then v-bal-eur-m3y = v-bal-eur-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-eur-nd = v-bal-eur-nd + tgl.sum.
    end.
    if tgl.crc = 2 then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-usd-7d = v-bal-usd-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-usd-1m = v-bal-usd-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-usd-3m = v-bal-usd-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-usd-6m = v-bal-usd-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-usd-1y = v-bal-usd-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-usd-3y = v-bal-usd-3y + tgl.sum.
        if v-days > 1095 then v-bal-usd-m3y = v-bal-usd-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-usd-nd = v-bal-usd-nd + tgl.sum.
    end.
    if not (tgl.crc = 1 or tgl.crc = 2 or tgl.crc = 3) then do:
        v-days = tgl.cdt - v-dt.
        if v-days <= 7 then v-bal-o-7d = v-bal-o-7d + tgl.sum.
        if v-days > 7 and v-days <=30 then v-bal-o-1m = v-bal-o-1m + tgl.sum.
        if v-days > 30 and v-days <=90 then v-bal-o-3m = v-bal-o-3m + tgl.sum.
        if v-days > 90 and v-days <=180 then v-bal-o-6m = v-bal-o-6m + tgl.sum.
        if v-days > 180 and v-days <=365 then v-bal-o-1y = v-bal-o-1y + tgl.sum.
        if v-days > 365 and v-days <=1095 then v-bal-o-3y = v-bal-o-3y + tgl.sum.
        if v-days > 1095 then v-bal-o-m3y = v-bal-o-m3y + tgl.sum.
        if tgl.cdt = ? then v-bal-o-nd = v-bal-o-nd + tgl.sum.
    end.
end.
find first tgl where substr(string(tgl.gl),1,4) = "2255" no-lock no-error.
if avail tgl then do:
    create wrk.
    wrk.num = 10.
    wrk.mtyp = "Обязательства".
    wrk.typ = "Прямое РЕПО".
    wrk.gl = "2255".
    wrk.t7d = v-bal-kzt-7d.
    wrk.t1m = v-bal-kzt-1m.
    wrk.t3m = v-bal-kzt-3m.
    wrk.t6m = v-bal-kzt-6m.
    wrk.t1y = v-bal-kzt-1y.
    wrk.t3y = v-bal-kzt-3y.
    wrk.tm3y = v-bal-kzt-m3y.
    wrk.tnd = v-bal-kzt-nd.
    wrk.u7d = v-bal-usd-7d.
    wrk.u1m = v-bal-usd-1m.
    wrk.u3m = v-bal-usd-3m.
    wrk.u6m = v-bal-usd-6m.
    wrk.u1y = v-bal-usd-1y.
    wrk.u3y = v-bal-usd-3y.
    wrk.um3y = v-bal-usd-m3y.
    wrk.und = v-bal-usd-nd.
    wrk.eu7d = v-bal-eur-7d.
    wrk.eu1m = v-bal-eur-1m.
    wrk.eu3m = v-bal-eur-3m.
    wrk.eu6m = v-bal-eur-6m.
    wrk.eu1y = v-bal-eur-1y.
    wrk.eu3y = v-bal-eur-3y.
    wrk.eum3y = v-bal-eur-m3y.
    wrk.eund = v-bal-eur-nd.
    wrk.p7d = v-bal-o-7d.
    wrk.p1m = v-bal-o-1m.
    wrk.p3m = v-bal-o-3m.
    wrk.p6m = v-bal-o-6m.
    wrk.p1y = v-bal-o-1y.
    wrk.p3y = v-bal-o-3y.
    wrk.pm3y = v-bal-o-m3y.
    wrk.pnd = v-bal-o-nd.
    wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
    wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
    wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
    wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.
end.
v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.

for each wrk where wrk.mtyp = "Активы" no-lock:
    v-bal-kzt-7d = v-bal-kzt-7d + wrk.t7d.
    v-bal-kzt-1m = v-bal-kzt-1m + wrk.t1m.
    v-bal-kzt-3m = v-bal-kzt-3m + wrk.t3m.
    v-bal-kzt-6m = v-bal-kzt-6m + wrk.t6m.
    v-bal-kzt-1y = v-bal-kzt-1y + wrk.t1y.
    v-bal-kzt-3y = v-bal-kzt-3y + wrk.t3y.
    v-bal-kzt-m3y = v-bal-kzt-m3y + wrk.tm3y.
    v-bal-kzt-nd = v-bal-kzt-nd + wrk.tnd.
    v-bal-usd-7d = v-bal-usd-7d + wrk.u7d.
    v-bal-usd-1m = v-bal-usd-1m + wrk.u1m.
    v-bal-usd-3m = v-bal-usd-3m + wrk.u3m.
    v-bal-usd-6m = v-bal-usd-6m + wrk.u6m.
    v-bal-usd-1y = v-bal-usd-1y + wrk.u1y.
    v-bal-usd-3y = v-bal-usd-3y + wrk.u3y.
    v-bal-usd-m3y = v-bal-usd-m3y + wrk.um3y.
    v-bal-usd-nd = v-bal-usd-nd + wrk.und.
    v-bal-eur-7d = v-bal-eur-7d + wrk.eu7d.
    v-bal-eur-1m = v-bal-eur-1m + wrk.eu1m.
    v-bal-eur-3m = v-bal-eur-3m + wrk.eu3m.
    v-bal-eur-6m = v-bal-eur-6m + wrk.eu6m.
    v-bal-eur-1y = v-bal-eur-1y + wrk.eu1y.
    v-bal-eur-3y = v-bal-eur-3y + wrk.eu3y.
    v-bal-eur-m3y = v-bal-eur-m3y + wrk.eum3y.
    v-bal-eur-nd = v-bal-eur-nd + wrk.eund.
    v-bal-o-7d = v-bal-o-7d + wrk.p7d.
    v-bal-o-1m = v-bal-o-1m + wrk.p1m.
    v-bal-o-3m = v-bal-o-3m + wrk.p3m.
    v-bal-o-6m = v-bal-o-6m + wrk.p6m.
    v-bal-o-1y = v-bal-o-1y + wrk.p1y.
    v-bal-o-3y = v-bal-o-3y + wrk.p3y.
    v-bal-o-m3y = v-bal-o-m3y + wrk.pm3y.
    v-bal-o-nd = v-bal-o-nd + wrk.pnd.
end.
create wrk.
wrk.num = 6.
wrk.mtyp = "Активы".
wrk.typ = "Итого активы".
wrk.gl = "".
wrk.t7d = v-bal-kzt-7d.
wrk.t1m = v-bal-kzt-1m.
wrk.t3m = v-bal-kzt-3m.
wrk.t6m = v-bal-kzt-6m.
wrk.t1y = v-bal-kzt-1y.
wrk.t3y = v-bal-kzt-3y.
wrk.tm3y = v-bal-kzt-m3y.
wrk.tnd = v-bal-kzt-nd.
wrk.u7d = v-bal-usd-7d.
wrk.u1m = v-bal-usd-1m.
wrk.u3m = v-bal-usd-3m.
wrk.u6m = v-bal-usd-6m.
wrk.u1y = v-bal-usd-1y.
wrk.u3y = v-bal-usd-3y.
wrk.um3y = v-bal-usd-m3y.
wrk.und = v-bal-usd-nd.
wrk.eu7d = v-bal-eur-7d.
wrk.eu1m = v-bal-eur-1m.
wrk.eu3m = v-bal-eur-3m.
wrk.eu6m = v-bal-eur-6m.
wrk.eu1y = v-bal-eur-1y.
wrk.eu3y = v-bal-eur-3y.
wrk.eum3y = v-bal-eur-m3y.
wrk.eund = v-bal-eur-nd.
wrk.p7d = v-bal-o-7d.
wrk.p1m = v-bal-o-1m.
wrk.p3m = v-bal-o-3m.
wrk.p6m = v-bal-o-6m.
wrk.p1y = v-bal-o-1y.
wrk.p3y = v-bal-o-3y.
wrk.pm3y = v-bal-o-m3y.
wrk.pnd = v-bal-o-nd.
wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.

v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each wrk where wrk.mtyp = "Обязательства" no-lock:
    v-bal-kzt-7d = v-bal-kzt-7d + wrk.t7d.
    v-bal-kzt-1m = v-bal-kzt-1m + wrk.t1m.
    v-bal-kzt-3m = v-bal-kzt-3m + wrk.t3m.
    v-bal-kzt-6m = v-bal-kzt-6m + wrk.t6m.
    v-bal-kzt-1y = v-bal-kzt-1y + wrk.t1y.
    v-bal-kzt-3y = v-bal-kzt-3y + wrk.t3y.
    v-bal-kzt-m3y = v-bal-kzt-m3y + wrk.tm3y.
    v-bal-kzt-nd = v-bal-kzt-nd + wrk.tnd.
    v-bal-usd-7d = v-bal-usd-7d + wrk.u7d.
    v-bal-usd-1m = v-bal-usd-1m + wrk.u1m.
    v-bal-usd-3m = v-bal-usd-3m + wrk.u3m.
    v-bal-usd-6m = v-bal-usd-6m + wrk.u6m.
    v-bal-usd-1y = v-bal-usd-1y + wrk.u1y.
    v-bal-usd-3y = v-bal-usd-3y + wrk.u3y.
    v-bal-usd-m3y = v-bal-usd-m3y + wrk.um3y.
    v-bal-usd-nd = v-bal-usd-nd + wrk.und.
    v-bal-eur-7d = v-bal-eur-7d + wrk.eu7d.
    v-bal-eur-1m = v-bal-eur-1m + wrk.eu1m.
    v-bal-eur-3m = v-bal-eur-3m + wrk.eu3m.
    v-bal-eur-6m = v-bal-eur-6m + wrk.eu6m.
    v-bal-eur-1y = v-bal-eur-1y + wrk.eu1y.
    v-bal-eur-3y = v-bal-eur-3y + wrk.eu3y.
    v-bal-eur-m3y = v-bal-eur-m3y + wrk.eum3y.
    v-bal-eur-nd = v-bal-eur-nd + wrk.eund.
    v-bal-o-7d = v-bal-o-7d + wrk.p7d.
    v-bal-o-1m = v-bal-o-1m + wrk.p1m.
    v-bal-o-3m = v-bal-o-3m + wrk.p3m.
    v-bal-o-6m = v-bal-o-6m + wrk.p6m.
    v-bal-o-1y = v-bal-o-1y + wrk.p1y.
    v-bal-o-3y = v-bal-o-3y + wrk.p3y.
    v-bal-o-m3y = v-bal-o-m3y + wrk.pm3y.
    v-bal-o-nd = v-bal-o-nd + wrk.pnd.
end.
create wrk.
wrk.num = 11.
wrk.mtyp = "Обязательства".
wrk.typ = "Итого обязательства".
wrk.gl = "".
wrk.t7d = v-bal-kzt-7d.
wrk.t1m = v-bal-kzt-1m.
wrk.t3m = v-bal-kzt-3m.
wrk.t6m = v-bal-kzt-6m.
wrk.t1y = v-bal-kzt-1y.
wrk.t3y = v-bal-kzt-3y.
wrk.tm3y = v-bal-kzt-m3y.
wrk.tnd = v-bal-kzt-nd.
wrk.u7d = v-bal-usd-7d.
wrk.u1m = v-bal-usd-1m.
wrk.u3m = v-bal-usd-3m.
wrk.u6m = v-bal-usd-6m.
wrk.u1y = v-bal-usd-1y.
wrk.u3y = v-bal-usd-3y.
wrk.um3y = v-bal-usd-m3y.
wrk.und = v-bal-usd-nd.
wrk.eu7d = v-bal-eur-7d.
wrk.eu1m = v-bal-eur-1m.
wrk.eu3m = v-bal-eur-3m.
wrk.eu6m = v-bal-eur-6m.
wrk.eu1y = v-bal-eur-1y.
wrk.eu3y = v-bal-eur-3y.
wrk.eum3y = v-bal-eur-m3y.
wrk.eund = v-bal-eur-nd.
wrk.p7d = v-bal-o-7d.
wrk.p1m = v-bal-o-1m.
wrk.p3m = v-bal-o-3m.
wrk.p6m = v-bal-o-6m.
wrk.p1y = v-bal-o-1y.
wrk.p3y = v-bal-o-3y.
wrk.pm3y = v-bal-o-m3y.
wrk.pnd = v-bal-o-nd.
wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.

v-bal-kzt-7d = 0.
v-bal-kzt-1m = 0.
v-bal-kzt-3m = 0.
v-bal-kzt-6m = 0.
v-bal-kzt-1y = 0.
v-bal-kzt-3y = 0.
v-bal-kzt-m3y = 0.
v-bal-kzt-nd = 0.
v-bal-usd-7d = 0.
v-bal-usd-1m = 0.
v-bal-usd-3m = 0.
v-bal-usd-6m = 0.
v-bal-usd-1y = 0.
v-bal-usd-3y = 0.
v-bal-usd-m3y = 0.
v-bal-usd-nd = 0.
v-bal-eur-7d = 0.
v-bal-eur-1m = 0.
v-bal-eur-3m = 0.
v-bal-eur-6m = 0.
v-bal-eur-1y = 0.
v-bal-eur-3y = 0.
v-bal-eur-m3y = 0.
v-bal-eur-nd = 0.
v-bal-o-7d = 0.
v-bal-o-1m = 0.
v-bal-o-3m = 0.
v-bal-o-6m = 0.
v-bal-o-1y = 0.
v-bal-o-3y = 0.
v-bal-o-m3y = 0.
v-bal-o-nd = 0.
for each wrk where /*wrk.mtyp = "Обязательства" and wrk.typ = "Итого обязательства"*/ wrk.num = 6  no-lock:
    for each b-wrk where /*b-wrk.mtyp = "Активы" and b-wrk.typ = "Итого активы"*/ b-wrk.num = 11 no-lock:
        v-bal-kzt-7d = wrk.t7d - b-wrk.t7d.
        v-bal-kzt-1m = wrk.t1m - b-wrk.t1m.
        v-bal-kzt-3m = wrk.t3m - b-wrk.t3m.
        v-bal-kzt-6m = wrk.t6m - b-wrk.t6m.
        v-bal-kzt-1y = wrk.t1y - b-wrk.t1y.
        v-bal-kzt-3y = wrk.t3y - b-wrk.t3y.
        v-bal-kzt-m3y = wrk.tm3y - b-wrk.tm3y.
        v-bal-kzt-nd = wrk.tnd - b-wrk.tnd.
        v-bal-usd-7d = wrk.u7d - b-wrk.u7d.
        v-bal-usd-1m = wrk.u1m - b-wrk.u1m.
        v-bal-usd-3m = wrk.u3m - b-wrk.u3m.
        v-bal-usd-6m = wrk.u6m - b-wrk.u6m.
        v-bal-usd-1y = wrk.u1y - b-wrk.u1y.
        v-bal-usd-3y = wrk.u3y - b-wrk.u3y.
        v-bal-usd-m3y = wrk.um3y - b-wrk.um3y.
        v-bal-usd-nd = wrk.und - b-wrk.und.
        v-bal-eur-7d = wrk.eu7d - b-wrk.eu7d.
        v-bal-eur-1m = wrk.eu1m - b-wrk.eu1m.
        v-bal-eur-3m = wrk.eu3m - b-wrk.eu3m.
        v-bal-eur-6m = wrk.eu6m - b-wrk.eu6m.
        v-bal-eur-1y = wrk.eu1y - b-wrk.eu1y.
        v-bal-eur-3y = wrk.eu3y - b-wrk.eu3y.
        v-bal-eur-m3y = wrk.eum3y - b-wrk.eum3y.
        v-bal-eur-nd = wrk.eund - b-wrk.eund.
        v-bal-o-7d = wrk.p7d - b-wrk.p7d.
        v-bal-o-1m = wrk.p1m - b-wrk.p1m.
        v-bal-o-3m = wrk.p3m - b-wrk.p3m.
        v-bal-o-6m = wrk.p6m - b-wrk.p6m.
        v-bal-o-1y = wrk.p1y - b-wrk.p1y.
        v-bal-o-3y = wrk.p3y - b-wrk.p3y.
        v-bal-o-m3y = wrk.pm3y - b-wrk.pm3y.
        v-bal-o-nd = wrk.pnd - b-wrk.pnd.
    end.
end.
create wrk.
wrk.num = 12.
wrk.mtyp = "GAP".
wrk.typ = "".
wrk.gl = "".
wrk.t7d = v-bal-kzt-7d.
wrk.t1m = v-bal-kzt-1m.
wrk.t3m = v-bal-kzt-3m.
wrk.t6m = v-bal-kzt-6m.
wrk.t1y = v-bal-kzt-1y.
wrk.t3y = v-bal-kzt-3y.
wrk.tm3y = v-bal-kzt-m3y.
wrk.tnd = v-bal-kzt-nd.
wrk.u7d = v-bal-usd-7d.
wrk.u1m = v-bal-usd-1m.
wrk.u3m = v-bal-usd-3m.
wrk.u6m = v-bal-usd-6m.
wrk.u1y = v-bal-usd-1y.
wrk.u3y = v-bal-usd-3y.
wrk.um3y = v-bal-usd-m3y.
wrk.und = v-bal-usd-nd.
wrk.eu7d = v-bal-eur-7d.
wrk.eu1m = v-bal-eur-1m.
wrk.eu3m = v-bal-eur-3m.
wrk.eu6m = v-bal-eur-6m.
wrk.eu1y = v-bal-eur-1y.
wrk.eu3y = v-bal-eur-3y.
wrk.eum3y = v-bal-eur-m3y.
wrk.eund = v-bal-eur-nd.
wrk.p7d = v-bal-o-7d.
wrk.p1m = v-bal-o-1m.
wrk.p3m = v-bal-o-3m.
wrk.p6m = v-bal-o-6m.
wrk.p1y = v-bal-o-1y.
wrk.p3y = v-bal-o-3y.
wrk.pm3y = v-bal-o-m3y.
wrk.pnd = v-bal-o-nd.
wrk.ttot = wrk.t7d + wrk.t1m + wrk.t3m + wrk.t6m + wrk.t1y + wrk.t3y + wrk.tm3y + wrk.tnd.
wrk.utot = wrk.u7d + wrk.u1m + wrk.u3m + wrk.u6m + wrk.u1y + wrk.u3y + wrk.um3y + wrk.und.
wrk.eutot = wrk.eu7d + wrk.eu1m + wrk.eu3m + wrk.eu6m + wrk.eu1y + wrk.eu3y + wrk.eum3y + wrk.eund.
wrk.ptot = wrk.p7d + wrk.p1m + wrk.p3m + wrk.p6m + wrk.p1y + wrk.p3y + wrk.pm3y + wrk.pnd.