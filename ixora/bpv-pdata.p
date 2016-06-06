/* bpv-pdata.p
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
        06/03/2013 Luiza - ТЗ № 1668 добавила счет 2240
*/

def shared var v-dt as date no-undo.
def shared temp-table p-bpv
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
def buffer b-p-bpv for p-bpv.
def var i as int.
i = 0.

/*ctrating bpv active*/
for each tgl where
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
    ) and tgl.cdt <> ? no-lock:
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
    (
    substr(string(tgl.gl),1,4) = "2206" or substr(string(tgl.gl),1,4) = "2207" or
    substr(string(tgl.gl),1,4) = "2208" or substr(string(tgl.gl),1,4) = "2213"
    or substr(string(tgl.gl),1,4) = "2215" or substr(string(tgl.gl),1,4) = "2217"
    or substr(string(tgl.gl),1,4) = "2219" or substr(string(tgl.gl),1,4) = "2223")  and tgl.cdt <> ? no-lock:
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
(int(substr(string(tgl.gl),1,4)) >= 2400 and int(substr(string(tgl.gl),1,4)) <= 2451) and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where substr(string(tgl.gl),1,4) = "2255" and tgl.cdt <> ? no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.gl = tgl.gl.
    act.dt = tgl.cdt.
    act.sum = tgl.sum.
    act.perc = tgl.perc.
    act.crc = tgl.crc.
    act.chk = no.
end.
for each tgl where substr(string(tgl.gl),1,4) = "2240" /*and tgl.cdt <> ?*/ no-lock:
    create act.
    act.tday = tgl.cdt - v-dt.
    act.dt = tgl.cdt.
    act.gl = tgl.gl.
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

create p-bpv.
p-bpv.tid = 1.
p-bpv.id = 1.
p-bpv.crc = 2.
p-bpv.dur = "0-1M".
p-bpv.u1m = v-bal-1m.
create p-bpv.
p-bpv.tid = 2.
p-bpv.id = 2.
p-bpv.crc = 2.
p-bpv.dur = "1M-3M".
p-bpv.u3m = v-bal-3m.
create p-bpv.
p-bpv.tid = 3.
p-bpv.id = 3.
p-bpv.crc = 2.
p-bpv.dur = "3M-6M".
p-bpv.u6m = v-bal-6m.
create p-bpv.
p-bpv.tid = 4.
p-bpv.id = 4.
p-bpv.crc = 2.
p-bpv.dur = "6M-1Y".
p-bpv.u1y = v-bal-1y.
create p-bpv.
p-bpv.tid = 5.
p-bpv.id = 5.
p-bpv.crc = 2.
p-bpv.dur = "1Y-3Y".
p-bpv.u3y = v-bal-3y.
create p-bpv.
p-bpv.tid = 6.
p-bpv.id = 6.
p-bpv.crc = 2.
p-bpv.dur = "3Y-…".
p-bpv.um3y = v-bal-m3y.

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

create p-bpv.
p-bpv.tid = 1.
p-bpv.id = 7.
p-bpv.crc = 3.
p-bpv.dur = "0-1M".
p-bpv.eu1m = v-bal-1m.
create p-bpv.
p-bpv.tid = 2.
p-bpv.id = 8.
p-bpv.crc = 3.
p-bpv.dur = "1M-3M".
p-bpv.eu3m = v-bal-3m.
create p-bpv.
p-bpv.tid = 3.
p-bpv.id = 9.
p-bpv.crc = 3.
p-bpv.dur = "3M-6M".
p-bpv.eu6m = v-bal-6m.
create p-bpv.
p-bpv.tid = 4.
p-bpv.id = 10.
p-bpv.crc = 3.
p-bpv.dur = "6M-1Y".
p-bpv.eu1y = v-bal-1y.
create p-bpv.
p-bpv.tid = 5.
p-bpv.id = 11.
p-bpv.crc = 3.
p-bpv.dur = "1Y-3Y".
p-bpv.eu3y = v-bal-3y.
create p-bpv.
p-bpv.tid = 6.
p-bpv.id = 12.
p-bpv.crc = 3.
p-bpv.dur = "3Y-…".
p-bpv.eum3y = v-bal-m3y.

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

create p-bpv.
p-bpv.tid = 1.
p-bpv.crc = 1.
p-bpv.id = 13.
p-bpv.dur = "0-1M".
p-bpv.t1m = v-bal-1m.
create p-bpv.
p-bpv.tid = 2.
p-bpv.crc = 1.
p-bpv.id = 14.
p-bpv.dur = "1M-3M".
p-bpv.t3m = v-bal-3m.
create p-bpv.
p-bpv.tid = 3.
p-bpv.crc = 1.
p-bpv.id = 15.
p-bpv.dur = "3M-6M".
p-bpv.t6m = v-bal-6m.
create p-bpv.
p-bpv.tid = 4.
p-bpv.crc = 1.
p-bpv.id = 16.
p-bpv.dur = "6M-1Y".
p-bpv.t1y = v-bal-1y.
create p-bpv.
p-bpv.tid = 5.
p-bpv.crc = 1.
p-bpv.id = 17.
p-bpv.dur = "1Y-3Y".
p-bpv.t3y = v-bal-3y.
create p-bpv.
p-bpv.tid = 6.
p-bpv.crc = 1.
p-bpv.id = 18.
p-bpv.dur = "3Y-…".
p-bpv.tm3y = v-bal-m3y.

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

create p-bpv.
p-bpv.tid = 1.
p-bpv.id = 19.
p-bpv.crc = 4.
p-bpv.dur = "0-1M".
p-bpv.p1m = v-bal-1m.
create p-bpv.
p-bpv.tid = 2.
p-bpv.id = 20.
p-bpv.crc = 4.
p-bpv.dur = "1M-3M".
p-bpv.p3m = v-bal-3m.
create p-bpv.
p-bpv.tid = 3.
p-bpv.id = 21.
p-bpv.crc = 4.
p-bpv.dur = "3M-6M".
p-bpv.p6m = v-bal-6m.
create p-bpv.
p-bpv.tid = 4.
p-bpv.id = 22.
p-bpv.crc = 4.
p-bpv.dur = "6M-1Y".
p-bpv.p1y = v-bal-1y.
create p-bpv.
p-bpv.tid = 5.
p-bpv.id = 23.
p-bpv.crc = 4.
p-bpv.dur = "1Y-3Y".
p-bpv.p3y = v-bal-3y.
create p-bpv.
p-bpv.tid = 6.
p-bpv.id = 24.
p-bpv.crc = 4.
p-bpv.dur = "3Y-…".
p-bpv.pm3y = v-bal-m3y.


