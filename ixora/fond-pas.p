/* fond-pas.p
 * MODULE

 * DESCRIPTION
        Фондирование активных операций
 * RUN
        fond.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
            20/11/2012 Luiza  - добавила счет 3510
            07/10/2013 Luiza  - ТЗ 1956 добавила счет 2213
            08/10/2013 Luiza  - перекомпиляция
*/

{global.i}
def shared var s-tot-2act as deci.
def shared var s-tot-2act-t as deci.
def shared var s-tot-2act-u as deci.
def shared var s-tot-2act-e as deci.
def shared var s-tot-2act-r as deci.
def shared var s-tot-2act-o as deci.
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
    index tgl-id1 is primary gl7.
def shared temp-table wrk-pas
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.
def shared temp-table wrk-act
    field gr as int
    field id as int
    field sum as deci
    field typ as char
    field crc as int.

def var v-sum as deci.
def var v-sum1 as deci.
def var v-sum-all as deci.
def var v-sum-all-t as deci.
def var v-sum-all-u as deci.
def var v-sum-all-e as deci.
def var v-sum-all-r as deci.
def var v-sum-all-o as deci.

def var v-sum-t as deci.
def var v-sum-u as deci.
def var v-sum-e as deci.
def var v-sum-r as deci.
def var v-sum-o as deci.

def var v-sum1-t as deci.
def var v-sum1-u as deci.
def var v-sum1-e as deci.
def var v-sum1-r as deci.
def var v-sum1-o as deci.

def var v-temp as deci.
def var v-temp1 as deci.
def var v-temp-t as deci.
def var v-temp1-t as deci.
def var v-temp-u as deci.
def var v-temp1-u as deci.
def var v-temp-e as deci.
def var v-temp1-e as deci.
def var v-temp-r as deci.
def var v-temp1-r as deci.
def var v-temp-o as deci.
def var v-temp1-o as deci.


/*3-group*/
v-sum-all = 0.
v-sum-all-t = 0.
v-sum-all-u = 0.
v-sum-all-e = 0.
v-sum-all-r = 0.
v-sum-all-o = 0.
v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.

find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 0 no-lock no-error.
if avail wrk-act then v-temp = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 0 no-lock no-error.
if avail wrk-act then v-temp1 = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 1 no-lock no-error.
if avail wrk-act then v-temp-t = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 1 no-lock no-error.
if avail wrk-act then v-temp1-t = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 2 no-lock no-error.
if avail wrk-act then v-temp-u = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 2 no-lock no-error.
if avail wrk-act then v-temp1-u = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 3 no-lock no-error.
if avail wrk-act then v-temp-e = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 3 no-lock no-error.
if avail wrk-act then v-temp1-e = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 4 no-lock no-error.
if avail wrk-act then v-temp-r = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 4 no-lock no-error.
if avail wrk-act then v-temp1-r = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 1 and wrk-act.crc = 5 no-lock no-error.
if avail wrk-act then v-temp-o = wrk-act.sum.
find first wrk-act where wrk-act.gr = 3 and wrk-act.id = 2 and wrk-act.crc = 5 no-lock no-error.
if avail wrk-act then v-temp1-o = wrk-act.sum.

for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 3001 and int(substr(string(tgl.gl),1,4)) <= 3027)
or int(substr(string(tgl.gl),1,4)) = 3101
or int(substr(string(tgl.gl),1,4)) = 3200
or int(substr(string(tgl.gl),1,4)) = 3305
or int(substr(string(tgl.gl),1,4)) = 3315
or int(substr(string(tgl.gl),1,4)) = 3400
or int(substr(string(tgl.gl),1,4)) = 3510
or int(substr(string(tgl.gl),1,4)) = 3580
or int(substr(string(tgl.gl),1,4)) = 3599
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
if  v-temp + v-temp1 < v-sum  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 0.
    wrk-pas.sum = v-temp +  v-temp1.
    v-sum-all = v-sum-all + (v-temp +  v-temp1).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 0.
    wrk-pas.sum = v-sum .
    v-sum-all = v-sum-all + v-sum .
end.
/*kzt*/
if  v-temp-t + v-temp1-t < v-sum-t  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 1.
    wrk-pas.sum = v-temp-t +  v-temp1-t.
    v-sum-all-t = v-sum-all-t + (v-temp-t +  v-temp1-t).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 1.
    wrk-pas.sum = v-sum-t .
    v-sum-all-t = v-sum-all-t + v-sum-t .
end.
/*usd*/
if  v-temp-u + v-temp1-u < v-sum-u  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 2.
    wrk-pas.sum = v-temp-u +  v-temp1-u.
    v-sum-all-u = v-sum-all-u + (v-temp-u +  v-temp1-u).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 2.
    wrk-pas.sum = v-sum-u.
    v-sum-all-u = v-sum-all-u + v-sum-u.
end.
/*eur*/
if  v-temp-e + v-temp1-e < v-sum-e  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 3.
    wrk-pas.sum = v-temp-e +  v-temp1-e.
    v-sum-all-e = v-sum-all-e + (v-temp-e +  v-temp1-e).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 3.
    wrk-pas.sum = v-sum-e.
    v-sum-all-e = v-sum-all-e + v-sum-e.
end.
/*rub*/
if  v-temp-r + v-temp1-r < v-sum-r  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 4.
    wrk-pas.sum = v-temp-r +  v-temp1-r.
    v-sum-all-r = v-sum-all-r + (v-temp-r +  v-temp1-r).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 4.
    wrk-pas.sum = v-sum-r .
    v-sum-all-r = v-sum-all-r + v-sum-r.
end.
/*o*/
if  v-temp-o + v-temp1-o < v-sum-o  then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 5.
    wrk-pas.sum = v-temp-o +  v-temp1-o.
    v-sum-all-o = v-sum-all-o + (v-temp-o +  v-temp1-o).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 1.
    wrk-pas.crc = 5.
    wrk-pas.sum = v-sum-o.
    v-sum-all-o = v-sum-all-o + v-sum-o.
end.

v-sum = 0.
v-sum1 = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2701 and int(substr(string(tgl.gl),1,4)) <= 2714)
or (int(substr(string(tgl.gl),1,4)) >= 2717 and int(substr(string(tgl.gl),1,4)) <= 2757)
or (int(substr(string(tgl.gl),1,4)) >= 2792 and int(substr(string(tgl.gl),1,4)) <= 2799)
or (int(substr(string(tgl.gl),1,4)) >= 2811 and int(substr(string(tgl.gl),1,4)) <= 2839)
or (int(substr(string(tgl.gl),1,4)) >= 2851 and int(substr(string(tgl.gl),1,4)) <= 2854)
or (int(substr(string(tgl.gl),1,4)) >= 2856 and int(substr(string(tgl.gl),1,4)) <= 2857)
or (int(substr(string(tgl.gl),1,4)) >= 2860 and int(substr(string(tgl.gl),1,4)) <= 2869)
or int(substr(string(tgl.gl),1,4)) = 2871
or (int(substr(string(tgl.gl),1,4)) >= 2891 and int(substr(string(tgl.gl),1,4)) <= 2899)
or (int(substr(string(tgl.gl),1,4)) >= 2551 and int(substr(string(tgl.gl),1,4)) <= 2752)
) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 2.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.

v-sum = 0.
v-sum1 = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 0 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum = v-sum + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 1 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum-t = v-sum-t + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 2 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum-u = v-sum-u + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 3 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum-e = v-sum-e + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 4 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum-r = v-sum-r + wrk-act.sum.
end.
for each wrk-act where wrk-act.typ = "total" and wrk-act.crc = 5 and wrk-act.gr = 3 and wrk-act.id = 4 no-lock:
    v-sum-o = v-sum-o + wrk-act.sum.
end.

find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp1 = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp1-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp1-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp1-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp1-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp-o = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp1-o = wrk-pas.sum.

if v-sum > v-temp + v-temp1 then do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 0.
    wrk-pas.sum = v-sum - (v-temp + v-temp1).
    v-sum-all = v-sum-all + (v-sum - (v-temp + v-temp1)).
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 1.
    wrk-pas.sum = v-sum-t - (v-temp-t + v-temp1-t).
    v-sum-all-t = v-sum-all-t + (v-sum-t - (v-temp-t + v-temp1-t)).
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 2.
    wrk-pas.sum = v-sum-u - (v-temp-u + v-temp1-u).
    v-sum-all-u = v-sum-all-u + (v-sum-u - (v-temp-u + v-temp1-u)).
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 3.
    wrk-pas.sum = v-sum-e - (v-temp-e + v-temp1-e).
    v-sum-all-e = v-sum-all-e + (v-sum-e - (v-temp-e + v-temp1-e)).
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 4.
    wrk-pas.sum = v-sum-r - (v-temp-r + v-temp1-r).
    v-sum-all-r = v-sum-all-r + (v-sum-r - (v-temp-r + v-temp1-r)).
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 5.
    wrk-pas.sum = v-sum-o - (v-temp-o + v-temp1-o).
    v-sum-all-o = v-sum-all-o + (v-sum-o - (v-temp-o + v-temp1-o)).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 0.
    wrk-pas.sum = 0.
    v-sum-all = v-sum-all.
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 1.
    wrk-pas.sum = 0.
    v-sum-all-t = v-sum-all-t.
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 2.
    wrk-pas.sum = 0.
    v-sum-all-u = v-sum-all-u.
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 1.
    wrk-pas.sum = 3.
    v-sum-all-e = v-sum-all-e.
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 4.
    wrk-pas.sum = 0.
    v-sum-all-r = v-sum-all-r.
    create wrk-pas.
    wrk-pas.gr = 3.
    wrk-pas.id = 3.
    wrk-pas.crc = 5.
    wrk-pas.sum = 0.
    v-sum-all-o = v-sum-all-o.
end.



create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all.
wrk-pas.crc = 0.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-t.
wrk-pas.crc = 1.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-u.
wrk-pas.crc = 2.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-e.
wrk-pas.crc = 3.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-r.
wrk-pas.crc = 4.
create wrk-pas.
wrk-pas.gr = 3.
wrk-pas.id = 4.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-o.
wrk-pas.crc = 5.

/*2-group*/

v-sum-all = 0.
v-sum-all-t = 0.
v-sum-all-u = 0.
v-sum-all-e = 0.
v-sum-all-r = 0.
v-sum-all-o = 0.
v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2054 and int(substr(string(tgl.gl),1,4)) <= 2059)
or int(substr(string(tgl.gl),1,4)) = 2124
or (int(substr(string(tgl.gl),1,4)) >=  2127 and int(substr(string(tgl.gl),1,4)) <= 2138)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 3.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.


v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2034 and int(substr(string(tgl.gl),1,4)) <= 2038)
or (int(substr(string(tgl.gl),1,4)) >=  2041 and int(substr(string(tgl.gl),1,4)) <= 2042)
or (int(substr(string(tgl.gl),1,4)) >=  2044 and int(substr(string(tgl.gl),1,4)) <= 2048)
or (int(substr(string(tgl.gl),1,4)) >=  2064 and int(substr(string(tgl.gl),1,4)) <= 2068)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 4.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.

v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) = 2301)
or (int(substr(string(tgl.gl),1,4)) >=  2303 and int(substr(string(tgl.gl),1,4)) <= 2306)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 5.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.




v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) = 2451)
or (int(substr(string(tgl.gl),1,4)) >=  2401 and int(substr(string(tgl.gl),1,4)) <= 2406)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 6.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.



v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 3001 and int(substr(string(tgl.gl),1,4)) <= 3027)
or int(substr(string(tgl.gl),1,4)) = 3101
or int(substr(string(tgl.gl),1,4)) = 3200
or int(substr(string(tgl.gl),1,4)) = 3305
or int(substr(string(tgl.gl),1,4)) = 3315
or int(substr(string(tgl.gl),1,4)) = 3400
or int(substr(string(tgl.gl),1,4)) = 3510
or int(substr(string(tgl.gl),1,4)) = 3580
or int(substr(string(tgl.gl),1,4)) = 3599
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp-o = wrk-pas.sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum - v-temp.
v-sum-all = v-sum-all + (v-sum - v-temp).
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t - v-temp-t.
v-sum-all-t = v-sum-all-t + v-sum-t - v-temp-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u - v-temp-u.
v-sum-all-u = v-sum-all-u + v-sum-u - v-temp-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e - v-temp-e.
v-sum-all-e = v-sum-all-e + v-sum-e - v-temp-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r - v-temp-r.
v-sum-all-r = v-sum-all-r + v-sum-r - v-temp-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 7.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o - v-temp-o.
v-sum-all-o = v-sum-all-o + v-sum-o - v-temp-o.

v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) = 2855)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 8.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.


v-sum = 0.
v-sum1 = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.


find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.

for each tgl where
    (
    (int(substr(string(tgl.gl),1,4)) >= 2206 and int(substr(string(tgl.gl),1,4)) <= 2208)
    or int(substr(string(tgl.gl),1,4)) = 2210 or int(substr(string(tgl.gl),1,4)) = 2213
    or (int(substr(string(tgl.gl),1,4)) >= 2215 and int(substr(string(tgl.gl),1,4)) <= 2219)
    or (int(substr(string(tgl.gl),1,4)) >= 2222 and int(substr(string(tgl.gl),1,4)) <= 2227)
    or (int(substr(string(tgl.gl),1,4)) >= 2230 and int(substr(string(tgl.gl),1,4)) <= 2236)
    or int(substr(string(tgl.gl),1,4)) = 2240
    )
    no-lock:
        v-sum = v-sum + tgl.sum.
        if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
        if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
        if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
        if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
        if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
    end.

if s-tot-2act < v-sum1 + v-sum then do:
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 2.
    wrk-pas.crc = 0.
    wrk-pas.sum = s-tot-2act - v-sum1.
    v-sum-all = v-sum-all + (s-tot-2act - v-sum1).
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 2.
    wrk-pas.crc = 0.
    wrk-pas.sum = v-sum.
    v-sum-all = v-sum-all + v-sum.
end.
find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 1 no-lock no-error.
if avail wrk-act then do:
    if wrk-act.sum < v-sum1-t + v-sum-t then do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 1.
        wrk-pas.sum = wrk-act.sum - v-sum1-t.
        v-sum-all-t = v-sum-all-t + (wrk-act.sum - v-sum1-t).
    end.
    else do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 1.
        wrk-pas.sum = v-sum-t.
        v-sum-all-t = v-sum-all-t + v-sum-t.
    end.
end.
find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 2 no-lock no-error.
if avail wrk-act then do:
    if wrk-act.sum < v-sum1-u + v-sum-u then do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 2.
        wrk-pas.sum = wrk-act.sum - v-sum1-u.
        v-sum-all-u = v-sum-all-u + (wrk-act.sum - v-sum1-u ).
    end.
    else do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 2.
        wrk-pas.sum = v-sum-u.
        v-sum-all-u = v-sum-all-u + v-sum-u.
    end.
end.
find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 3 no-lock no-error.
if avail wrk-act then do:
    if wrk-act.sum < v-sum1-e + v-sum-e then do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 3.
        wrk-pas.sum = wrk-act.sum - v-sum1-e.
        v-sum-all-e = v-sum-all-e + (wrk-act.sum - v-sum1-e ).
    end.
    else do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 3.
        wrk-pas.sum = v-sum-e.
        v-sum-all-e = v-sum-all-e + v-sum-e.
    end.
end.
find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 4 no-lock no-error.
if avail wrk-act then do:
    if wrk-act.sum < v-sum1-r + v-sum-r then do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 4.
        wrk-pas.sum = wrk-act.sum - v-sum1-r.
        v-sum-all-r = v-sum-all-r + (wrk-act.sum - v-sum1-r).
    end.
    else do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 4.
        wrk-pas.sum = v-sum-r.
        v-sum-all-r = v-sum-all-r + v-sum-r.
    end.
end.
find first wrk-act where wrk-act.gr = 2 and wrk-act.id = 4 and wrk-act.crc = 5 no-lock no-error.
if avail wrk-act then do:
    if wrk-act.sum < v-sum1-o + v-sum-o then do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 5.
        wrk-pas.sum = wrk-act.sum - v-sum1-o .
        v-sum-all-o = v-sum-all-o + (wrk-act.sum - v-sum1-o).
    end.
    else do:
        create wrk-pas.
        wrk-pas.gr = 2.
        wrk-pas.id = 2.
        wrk-pas.crc = 5.
        wrk-pas.sum = v-sum-o.
        v-sum-all-o = v-sum-all-o + v-sum-o.
    end.
end.


v-sum = 0.
v-sum1 = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
/*
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 0 no-lock:
     v-sum1 = v-sum1 +  wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 1 no-lock:
     v-sum1-t = v-sum1-t +  wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 2 no-lock:
     v-sum1-u = v-sum1-u +  wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 3 no-lock:
     v-sum1-e = v-sum1-e +  wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 4 no-lock:
     v-sum1-r = v-sum1-r +  wrk-pas.sum.
end.
for each wrk-pas where wrk-pas.gr = 2 and (wrk-pas.id > 1 and wrk-pas.id < 9) and wrk-pas.crc = 5 no-lock:
     v-sum1-o = v-sum1-o +  wrk-pas.sum.
end.
*/
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-sum1 = v-sum1 + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-sum1-t = v-sum1-t + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-sum1-u = v-sum1-u + wrk-pas.sum.


find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-sum1-e = v-sum1-e + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-sum1-r = v-sum1-r + wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 4 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 5 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 6 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 7 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 8 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-sum1-o = v-sum1-o + wrk-pas.sum.

if s-tot-2act > v-sum1 then do:
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 0.
    wrk-pas.sum = s-tot-2act - v-sum1.
    v-sum-all = v-sum-all + (s-tot-2act - v-sum1).
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 1.
    wrk-pas.sum = s-tot-2act-t - v-sum1-t.
    v-sum-all-t = v-sum-all-t + (s-tot-2act-t - v-sum1-t).
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 2.
    wrk-pas.sum = s-tot-2act-u - v-sum1-u.
    v-sum-all-u = v-sum-all-u + (s-tot-2act-u - v-sum1-u).
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 3.
    wrk-pas.sum = s-tot-2act-e - v-sum1-e.
    v-sum-all-e = v-sum-all-e + (s-tot-2act-e - v-sum1-e).
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 4.
    wrk-pas.sum = s-tot-2act-r - v-sum1-r.
    v-sum-all-r = v-sum-all-r + (s-tot-2act-r - v-sum1-r).
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 5.
    wrk-pas.sum = s-tot-2act-o - v-sum1-o.
    v-sum-all-o = v-sum-all-o + (s-tot-2act-o - v-sum1-o).
end.
else do:
    v-sum = 0.
    v-sum-t = 0.
    v-sum-u = 0.
    v-sum-e = 0.
    v-sum-r = 0.
    v-sum-o = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 0.
    wrk-pas.sum = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 1.
    wrk-pas.sum = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 2.
    wrk-pas.sum = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 3.
    wrk-pas.sum = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 4.
    wrk-pas.sum = 0.
    create wrk-pas.
    wrk-pas.gr = 2.
    wrk-pas.id = 1.
    wrk-pas.crc = 5.
    wrk-pas.sum = 0.
end.

create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all.
wrk-pas.crc = 0.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-t.
wrk-pas.crc = 1.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-u.
wrk-pas.crc = 2.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-e.
wrk-pas.crc = 3.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-r.
wrk-pas.crc = 4.
create wrk-pas.
wrk-pas.gr = 2.
wrk-pas.id = 9.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-o.
wrk-pas.crc = 5.



/*1-group*/
v-sum-all = 0.
v-sum-all-t = 0.
v-sum-all-u = 0.
v-sum-all-e = 0.
v-sum-all-r = 0.
v-sum-all-o = 0.
v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2201 and int(substr(string(tgl.gl),1,4)) <= 2205)
or int(substr(string(tgl.gl),1,4)) = 2209
or int(substr(string(tgl.gl),1,4)) = 2211
or int(substr(string(tgl.gl),1,4)) = 2221
or int(substr(string(tgl.gl),1,4)) = 2228
or int(substr(string(tgl.gl),1,4)) = 2237
or int(substr(string(tgl.gl),1,4)) = 2870
) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
v-temp = 0.
v-temp1 = 0.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp1 = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp1-t = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp1-u = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp1-e = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp1-r = wrk-pas.sum.

find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 1 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp-o = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 3 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp1-o = wrk-pas.sum.

create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum - v-temp - v-temp1.
v-sum-all = v-sum-all + (v-sum - v-temp - v-temp1).

create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t - v-temp-t - v-temp1-t.
v-sum-all-t = v-sum-all-t + (v-sum-t - v-temp-t - v-temp1-t).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u - v-temp-u - v-temp1-u.
v-sum-all-u = v-sum-all-u + (v-sum-u - v-temp-u - v-temp1-u).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e - v-temp-e - v-temp1-e.
v-sum-all-e = v-sum-all-e + (v-sum-e - v-temp-e - v-temp1-e).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r - v-temp-r - v-temp1-r.
v-sum-all-r = v-sum-all-r + (v-sum-r - v-temp-r - v-temp1-r).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 1.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o - v-temp-o - v-temp1-o.
v-sum-all-o = v-sum-all-o + (v-sum-o - v-temp-o - v-temp1-o).

v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2021 and int(substr(string(tgl.gl),1,4)) <= 2024)
or (int(substr(string(tgl.gl),1,4)) >= 2011 and int(substr(string(tgl.gl),1,4)) <= 2014)
or int(substr(string(tgl.gl),1,4)) = 2016
or (int(substr(string(tgl.gl),1,4)) >= 2051 and int(substr(string(tgl.gl),1,4)) <= 2052)
or (int(substr(string(tgl.gl),1,4)) >= 2111 and int(substr(string(tgl.gl),1,4)) <= 2113)
or int(substr(string(tgl.gl),1,4)) = 2121
or int(substr(string(tgl.gl),1,4)) =  2123
) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 2.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.

v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 2 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp-o = wrk-pas.sum.
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2206 and int(substr(string(tgl.gl),1,4)) <= 2208)
or (int(substr(string(tgl.gl),1,4)) >= 2222 and int(substr(string(tgl.gl),1,4)) <= 2227)
or int(substr(string(tgl.gl),1,4)) = 2210 or int(substr(string(tgl.gl),1,4)) = 2213
or (int(substr(string(tgl.gl),1,4)) >= 2215 and int(substr(string(tgl.gl),1,4)) <= 2219)
or (int(substr(string(tgl.gl),1,4)) >= 2230 and int(substr(string(tgl.gl),1,4)) <= 2236)
or int(substr(string(tgl.gl),1,4)) = 2240
) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
if v-sum = v-temp then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 0.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 0.
    wrk-pas.sum = v-sum - v-temp.
    v-sum-all = v-sum-all + (v-sum - v-temp).
end.
if v-sum-t = v-temp-t then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 1.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 1.
    wrk-pas.sum = v-sum-t - v-temp-t.
    v-sum-all-t = v-sum-all-t + (v-sum-t - v-temp-t).
end.
if v-sum-u = v-temp-u then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 2.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 2.
    wrk-pas.sum = v-sum-u - v-temp-u.
    v-sum-all-u = v-sum-all-u + (v-sum-u - v-temp-u).
end.
if v-sum-e = v-temp-e then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 3.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 3.
    wrk-pas.sum = v-sum-e - v-temp-e.
    v-sum-all-e = v-sum-all-e + (v-sum-e - v-temp-e).
end.
if v-sum-r = v-temp-r then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 4.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 4.
    wrk-pas.sum = v-sum-r - v-temp-r.
    v-sum-all-r = v-sum-all-r + (v-sum-r - v-temp-r).
end.
if v-sum-o = v-temp-o then do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 5.
    wrk-pas.sum = 0.
end.
else do:
    create wrk-pas.
    wrk-pas.gr = 1.
    wrk-pas.id = 3.
    wrk-pas.crc = 5.
    wrk-pas.sum = v-sum-o - v-temp-o.
    v-sum-all-o = v-sum-all-o + (v-sum-o - v-temp-o).
end.

v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
for each tgl where (int(substr(string(tgl.gl),1,4)) = 2255) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum.
v-sum-all = v-sum-all + v-sum.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t.
v-sum-all-t = v-sum-all-t + v-sum-t.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u.
v-sum-all-u = v-sum-all-u + v-sum-u.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e.
v-sum-all-e = v-sum-all-e + v-sum-e.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r.
v-sum-all-r = v-sum-all-r + v-sum-r.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 4.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o.
v-sum-all-o = v-sum-all-o + v-sum-o.


v-sum = 0.
v-sum-t = 0.
v-sum-u = 0.
v-sum-e = 0.
v-sum-r = 0.
v-sum-o = 0.
v-sum1-t = 0.
v-sum1-u = 0.
v-sum1-e = 0.
v-sum1-r = 0.
v-sum1-o = 0.
v-temp = 0.
v-temp1 = 0.
v-temp-t = 0.
v-temp1-t = 0.
v-temp-u = 0.
v-temp1-u = 0.
v-temp-e = 0.
v-temp1-e = 0.
v-temp-r = 0.
v-temp1-r = 0.
v-temp-o = 0.
v-temp1-o = 0.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 0 no-lock no-error.
if avail wrk-pas then v-temp = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 1 no-lock no-error.
if avail wrk-pas then v-temp-t = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 2 no-lock no-error.
if avail wrk-pas then v-temp-u = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 3 no-lock no-error.
if avail wrk-pas then v-temp-e = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 4 no-lock no-error.
if avail wrk-pas then v-temp-r = wrk-pas.sum.
find first wrk-pas where wrk-pas.gr = 3 and wrk-pas.id = 2 and wrk-pas.crc = 5 no-lock no-error.
if avail wrk-pas then v-temp-o = wrk-pas.sum.

for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 2701 and int(substr(string(tgl.gl),1,4)) <= 2714)
or (int(substr(string(tgl.gl),1,4)) >= 2717 and int(substr(string(tgl.gl),1,4)) <= 2757)
or (int(substr(string(tgl.gl),1,4)) >= 2792 and int(substr(string(tgl.gl),1,4)) <= 2799)
or (int(substr(string(tgl.gl),1,4)) >= 2811 and int(substr(string(tgl.gl),1,4)) <= 2839)
or (int(substr(string(tgl.gl),1,4)) >= 2851 and int(substr(string(tgl.gl),1,4)) <= 2854)
or (int(substr(string(tgl.gl),1,4)) >= 2856 and int(substr(string(tgl.gl),1,4)) <= 2857)
or (int(substr(string(tgl.gl),1,4)) >= 2860 and int(substr(string(tgl.gl),1,4)) <= 2869)
or int(substr(string(tgl.gl),1,4)) = 2871
or (int(substr(string(tgl.gl),1,4)) >= 2891 and int(substr(string(tgl.gl),1,4)) <= 2899)
or (int(substr(string(tgl.gl),1,4)) >= 2551 and int(substr(string(tgl.gl),1,4)) <= 2752)
) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 0.
wrk-pas.sum = v-sum - v-temp.
v-sum-all = v-sum-all + (v-sum - v-temp).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 1.
wrk-pas.sum = v-sum-t - v-temp-t.
v-sum-all-t = v-sum-all-t + (v-sum-t - v-temp-t).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 2.
wrk-pas.sum = v-sum-u - v-temp-u.
v-sum-all-u = v-sum-all-u + (v-sum-u - v-temp-u).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 3.
wrk-pas.sum = v-sum-e - v-temp-e.
v-sum-all-e = v-sum-all-e + (v-sum-e - v-temp-e).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 4.
wrk-pas.sum = v-sum-r - v-temp-r.
v-sum-all-r = v-sum-all-r + (v-sum-r - v-temp-r).
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 5.
wrk-pas.crc = 5.
wrk-pas.sum = v-sum-o - v-temp-o.
v-sum-all-o = v-sum-all-o + (v-sum-o - v-temp-o).


create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all.
wrk-pas.crc = 0.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-t.
wrk-pas.crc = 1.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-u.
wrk-pas.crc = 2.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-e.
wrk-pas.crc = 3.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-r.
wrk-pas.crc = 4.
create wrk-pas.
wrk-pas.gr = 1.
wrk-pas.id = 6.
wrk-pas.typ = "total".
wrk-pas.sum = v-sum-all-o.
wrk-pas.crc = 5.



