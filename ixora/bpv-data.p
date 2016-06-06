/* bpv-data.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        bpv.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
            12/09/2013 Luiza - ТЗ 1958 добавить кар счета 1401 1403
*/

def shared var v-dt as date no-undo.
def shared temp-table a-bpv
    field id as int
    field tid as int
    field typ as char
    field dur as char
    field crc as int
    field t1m as deci
    field t3m as deci
    field t6m as deci
    field t1y as deci
    field t3y as deci
    field tm3y as deci
    field ttot as deci
    field u1m as deci
    field u3m as deci
    field u6m as deci
    field u1y as deci
    field u3y as deci
    field um3y as deci
    field utot as deci
    field eu1m as deci
    field eu3m as deci
    field eu6m as deci
    field eu1y as deci
    field eu3y as deci
    field eum3y as deci
    field eund as deci
    field eutot as deci
    field p1m as deci
    field p3m as deci
    field p6m as deci
    field p1y as deci
    field p3y as deci
    field pm3y as deci
    field ptot as deci.

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

def var v-bal-1m as deci.
def var v-bal-3m as deci.
def var v-bal-6m as deci.
def var v-bal-1y as deci.
def var v-bal-3y as deci.
def var v-bal-m3y as deci.
def var v-bal-tot as deci.
def var v-days as int.

def buffer b-tgl for tgl.
v-bal-1m = 0.
v-bal-3m = 0.
v-bal-6m = 0.
v-bal-1y = 0.
v-bal-3y = 0.
v-bal-m3y = 0.
v-bal-tot = 0.


def temp-table act
    field id as int
    field gl as int
    field dt as date
    field tday as int
    field sum as deci
    field perc as deci
    field crc as int
    field chk as logi.
def buffer b-act for act.
def buffer b-a-bpv for a-bpv.
def var i as int.
i = 0.

/*ctrating bpv active*/
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1101 and int(substr(string(tgl.gl),1,4)) <= 1106) and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where
    (int(substr(string(tgl.gl),1,4)) >= 1201 and int(substr(string(tgl.gl),1,4)) <= 1206
    or ((int(substr(string(tgl.gl),1,4)) >= 1208 and int(substr(string(tgl.gl),1,4)) <= 1209))
    or ((int(substr(string(tgl.gl),1,4)) >= 1451 and int(substr(string(tgl.gl),1,4)) <= 1459))
    or ((int(substr(string(tgl.gl),1,4)) >= 1481 and int(substr(string(tgl.gl),1,4)) <= 1485))) and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where
    ((int(substr(string(tgl.gl),1,4)) >= 1251 and int(substr(string(tgl.gl),1,4)) <= 1257)
    or ((int(substr(string(tgl.gl),1,4)) >= 1260 and int(substr(string(tgl.gl),1,4)) <= 1267))
    or ((int(substr(string(tgl.gl),1,4)) >= 1301 and int(substr(string(tgl.gl),1,4)) <= 1306))
    or ((int(substr(string(tgl.gl),1,4)) >= 1309 and int(substr(string(tgl.gl),1,4)) <= 1313))
    or ((int(substr(string(tgl.gl),1,4)) >= 1321 and int(substr(string(tgl.gl),1,4)) <= 1331)))
    and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1401 and int(substr(string(tgl.gl),1,4)) <= 1445) and tgl.cdt <> ?
    and tgl.gl <> 140150 and  tgl.gl <> 140160 and substr(string(tgl.gl),1,4) <> "1403" no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1461 and int(substr(string(tgl.gl),1,4)) <= 1463) and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where tgl.gl = 140150 or tgl.gl = 140160 or substr(string(tgl.gl),1,4) = "1403" no-lock:
    create act.
    if substr(string(tgl.gl),1,4) = "1403" then act.tday = 730. /* "1Y-3Y" */
    else act.tday = 30. /* "0-1M" */
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.


v-bal-1m = 0.
v-bal-3m = 0.
v-bal-6m = 0.
v-bal-1y = 0.
v-bal-3y = 0.
v-bal-m3y = 0.

/*usd*/
for each act where act.crc = 2 and (act.tday >= 0 and act.tday <= 30):
    v-bal-1m = v-bal-1m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 2 and act.tday > 30 and act.tday <= 90:
    v-bal-3m = v-bal-3m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 2 and act.tday > 90 and act.tday <= 180:
    v-bal-6m = v-bal-6m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 2 and act.tday > 180 and act.tday <= 365:
    v-bal-1y = v-bal-1y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 2 and act.tday > 365 and act.tday <= 1095:
    v-bal-3y = v-bal-3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 2 and act.tday > 1095:
    v-bal-m3y = v-bal-m3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.

create a-bpv.
a-bpv.id = 1.
a-bpv.tid = 1.
a-bpv.crc = 2.
a-bpv.dur = "0-1M".
a-bpv.u1m = v-bal-1m.
create a-bpv.
a-bpv.id = 2.
a-bpv.tid = 2.
a-bpv.crc = 2.
a-bpv.dur = "1M-3M".
a-bpv.u3m = v-bal-3m.
create a-bpv.
a-bpv.id = 3.
a-bpv.tid = 3.
a-bpv.crc = 2.
a-bpv.dur = "3M-6M".
a-bpv.u6m = v-bal-6m.
create a-bpv.
a-bpv.id = 4.
a-bpv.tid = 4.
a-bpv.crc = 2.
a-bpv.dur = "6M-1Y".
a-bpv.u1y = v-bal-1y.
create a-bpv.
a-bpv.id = 5.
a-bpv.tid = 5.
a-bpv.crc = 2.
a-bpv.dur = "1Y-3Y".
a-bpv.u3y = v-bal-3y.
create a-bpv.
a-bpv.id = 6.
a-bpv.tid = 6.
a-bpv.crc = 2.
a-bpv.dur = "3Y-…".
a-bpv.um3y = v-bal-m3y.

/*eur*/
v-bal-1m = 0.
v-bal-3m = 0.
v-bal-6m = 0.
v-bal-1y = 0.
v-bal-3y = 0.
v-bal-m3y = 0.


for each act where act.crc = 3 and (act.tday >= 0 and act.tday <= 30):
    v-bal-1m = v-bal-1m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 3 and act.tday > 30 and act.tday <= 90:
    v-bal-3m = v-bal-3m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 3 and act.tday > 90 and act.tday <= 180:
    v-bal-6m = v-bal-6m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 3 and act.tday > 180 and act.tday <= 365:
    v-bal-1y = v-bal-1y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 3 and act.tday > 365 and act.tday <= 1095:
    v-bal-3y = v-bal-3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 3 and act.tday > 1095:
    v-bal-m3y = v-bal-m3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.

create a-bpv.
a-bpv.id = 7.
a-bpv.tid = 1.
a-bpv.crc = 3.
a-bpv.dur = "0-1M".
a-bpv.eu1m = v-bal-1m.
create a-bpv.
a-bpv.id = 8.
a-bpv.tid = 2.
a-bpv.crc = 3.
a-bpv.dur = "1M-3M".
a-bpv.eu3m = v-bal-3m.
create a-bpv.
a-bpv.tid = 3.
a-bpv.id = 9.
a-bpv.crc = 3.
a-bpv.dur = "3M-6M".
a-bpv.eu6m = v-bal-6m.
create a-bpv.
a-bpv.tid = 4.
a-bpv.id = 10.
a-bpv.crc = 3.
a-bpv.dur = "6M-1Y".
a-bpv.eu1y = v-bal-1y.
create a-bpv.
a-bpv.tid = 5.
a-bpv.id = 11.
a-bpv.crc = 3.
a-bpv.dur = "1Y-3Y".
a-bpv.eu3y = v-bal-3y.
create a-bpv.
a-bpv.tid = 6.
a-bpv.id = 12.
a-bpv.crc = 3.
a-bpv.dur = "3Y-…".
a-bpv.eum3y = v-bal-m3y.

/*kzt*/

v-bal-1m = 0.
v-bal-3m = 0.
v-bal-6m = 0.
v-bal-1y = 0.
v-bal-3y = 0.
v-bal-m3y = 0.
for each act where act.crc = 1 and (act.tday >= 0 and act.tday <= 30):
    v-bal-1m = v-bal-1m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 1 and act.tday > 30 and act.tday <= 90:
    v-bal-3m = v-bal-3m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 1 and act.tday > 90 and act.tday <= 180:
    v-bal-6m = v-bal-6m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 1 and act.tday > 180 and act.tday <= 365:
    v-bal-1y = v-bal-1y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 1 and act.tday > 365 and act.tday <= 1095:
    v-bal-3y = v-bal-3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 1 and act.tday > 1095:
    v-bal-m3y = v-bal-m3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.

create a-bpv.
a-bpv.tid = 1.
a-bpv.crc = 1.
a-bpv.id = 13.
a-bpv.dur = "0-1M".
a-bpv.t1m = v-bal-1m.
create a-bpv.
a-bpv.tid = 2.
a-bpv.crc = 1.
a-bpv.id = 14.
a-bpv.dur = "1M-3M".
a-bpv.t3m = v-bal-3m.
create a-bpv.
a-bpv.tid = 3.
a-bpv.crc = 1.
a-bpv.id = 15.
a-bpv.dur = "3M-6M".
a-bpv.t6m = v-bal-6m.
create a-bpv.
a-bpv.tid = 4.
a-bpv.crc = 1.
a-bpv.id = 16.
a-bpv.dur = "6M-1Y".
a-bpv.t1y = v-bal-1y.
create a-bpv.
a-bpv.tid = 5.
a-bpv.crc = 1.
a-bpv.id = 17.
a-bpv.dur = "1Y-3Y".
a-bpv.t3y = v-bal-3y.
create a-bpv.
a-bpv.tid = 6.
a-bpv.crc = 1.
a-bpv.id = 18.
a-bpv.dur = "3Y-…".
a-bpv.tm3y = v-bal-m3y.

/*rub*/
v-bal-1m = 0.
v-bal-3m = 0.
v-bal-6m = 0.
v-bal-1y = 0.
v-bal-3y = 0.
v-bal-m3y = 0.


for each act where act.crc = 4 and (act.tday >= 0 and act.tday <= 30):
    v-bal-1m = v-bal-1m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 4 and act.tday > 30 and act.tday <= 90:
    v-bal-3m = v-bal-3m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 4 and act.tday > 90 and act.tday <= 180:
    v-bal-6m = v-bal-6m + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 4 and act.tday > 180 and act.tday <= 365:
    v-bal-1y = v-bal-1y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 4 and act.tday > 365 and act.tday <= 1095:
    v-bal-3y = v-bal-3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.
for each act where act.crc = 4 and act.tday > 1095:
    v-bal-m3y = v-bal-m3y + (act.sum * exp(2.71828,((- act.perc / 100) * (act.tday / 360)))) / 10000 / 360 * (- act.tday).
end.

create a-bpv.
a-bpv.tid = 1.
a-bpv.id = 19.
a-bpv.crc = 4.
a-bpv.dur = "0-1M".
a-bpv.p1m = v-bal-1m.
create a-bpv.
a-bpv.tid = 2.
a-bpv.id = 20.
a-bpv.crc = 4.
a-bpv.dur = "1M-3M".
a-bpv.p3m = v-bal-3m.
create a-bpv.
a-bpv.tid = 3.
a-bpv.id = 21.
a-bpv.crc = 4.
a-bpv.dur = "3M-6M".
a-bpv.p6m = v-bal-6m.
create a-bpv.
a-bpv.tid = 4.
a-bpv.id = 22.
a-bpv.crc = 4.
a-bpv.dur = "6M-1Y".
a-bpv.p1y = v-bal-1y.
create a-bpv.
a-bpv.tid = 5.
a-bpv.id = 23.
a-bpv.crc = 4.
a-bpv.dur = "1Y-3Y".
a-bpv.p3y = v-bal-3y.
create a-bpv.
a-bpv.tid = 6.
a-bpv.id = 24.
a-bpv.crc = 4.
a-bpv.dur = "3Y-…".
a-bpv.pm3y = v-bal-m3y.


