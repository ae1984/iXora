/* fond-act.p
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
            18/01/2013 Luiza - счет 1254 перебросила в 2 группу как и треб-ся по ТЗ
            25/01/2013 Luiza - ТЗ 1374 из прочих активов минус счета 1858, 1859
*/
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
for each tgl where int(substr(string(tgl.gl),1,4)) >= 1001 and int(substr(string(tgl.gl),1,4)) <= 1013 no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 0.
wrk-act.sum = v-sum.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 1.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where int(substr(string(tgl.gl),1,4)) >= 1051 and int(substr(string(tgl.gl),1,4)) < 1054 no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 2.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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

for each tgl where int(substr(string(tgl.gl),1,4)) >= 1101 and int(substr(string(tgl.gl),1,4)) <= 1106 no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 3.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1251 and int(substr(string(tgl.gl),1,4)) <= 1253)
or (int(substr(string(tgl.gl),1,4)) >= 1257 and int(substr(string(tgl.gl),1,4)) <= 1258)
or (int(substr(string(tgl.gl),1,4)) >= 1260 and int(substr(string(tgl.gl),1,4)) <=1263)
or (int(substr(string(tgl.gl),1,4)) >= 1265 and int(substr(string(tgl.gl),1,4)) <= 1267)
or (int(substr(string(tgl.gl),1,4)) >= 1301 and int(substr(string(tgl.gl),1,4)) <= 1303)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
/*for each tgl where int(substr(string(tgl.gl),1,4)) = 1259 no-lock:
    v-sum1 = v-sum1 + tgl.sum.
    if tgl.crc = 1 then v-sum1-t = v-sum1-t + tgl.sum.
    if tgl.crc = 2 then v-sum1-u = v-sum1-u + tgl.sum.
    if tgl.crc = 3 then v-sum1-e = v-sum1-e + tgl.sum.
    if tgl.crc = 4 then v-sum1-r = v-sum1-r + tgl.sum.
    if tgl.crc > 4 then v-sum1-o = v-sum1-o + tgl.sum.
end.*/
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 4.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1201 and int(substr(string(tgl.gl),1,4)) <= 1209)
or (int(substr(string(tgl.gl),1,4)) >= 1452 and int(substr(string(tgl.gl),1,4)) <= 1459)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 5.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where (int(substr(string(tgl.gl),1,4)) >= 1461 and int(substr(string(tgl.gl),1,4)) <= 1462) no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 6.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where int(substr(string(tgl.gl),1,4)) = 1054 no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 8.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where int(substr(string(tgl.gl),1,4)) = 1259 no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 9.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where int(substr(string(tgl.gl),1,4)) = 1451 no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 10.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where int(substr(string(tgl.gl),1,4)) = 1463 no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 11.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.


create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-t.
wrk-act.crc = 1.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-u.
wrk-act.crc = 2.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-e.
wrk-act.crc = 3.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-r.
wrk-act.crc = 4.
create wrk-act.
wrk-act.gr = 1.
wrk-act.id = 7.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-o.
wrk-act.crc = 5.


/*2-group*/
v-sum-all = 0.
v-sum-all-t = 0.
v-sum-all-u = 0.
v-sum-all-e = 0.
v-sum-all-r = 0.
v-sum-all-o = 0.
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
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1321 and int(substr(string(tgl.gl),1,4)) <= 1328)
or int(substr(string(tgl.gl),1,4)) = 1330
or int(substr(string(tgl.gl),1,4)) = 1331
or (int(substr(string(tgl.gl),1,4)) >= 1401 and int(substr(string(tgl.gl),1,4)) <= 1427)
or (int(substr(string(tgl.gl),1,4)) >= 1429 and int(substr(string(tgl.gl),1,4)) <= 1445)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 1.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1254 and int(substr(string(tgl.gl),1,4)) <= 1256)
or (int(substr(string(tgl.gl),1,4)) >= 1304 and int(substr(string(tgl.gl),1,4)) <= 1313)
or  int(substr(string(tgl.gl),1,4)) = 1264
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 2.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
int(substr(string(tgl.gl),1,4)) = 1855
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 3.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(int(substr(string(tgl.gl),1,4)) >= 1481 and int(substr(string(tgl.gl),1,4)) < 1486)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 4.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1401
or int(substr(string(tgl.gl),1,4)) = 1403
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 6.
wrk-act.sum = v-sum.

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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1329
or int(substr(string(tgl.gl),1,4)) = 1428
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 7.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1319
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 8.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1486
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 9.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all.

create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-t.
wrk-act.crc = 1.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-u.
wrk-act.crc = 2.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-e.
wrk-act.crc = 3.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-r.
wrk-act.crc = 4.
create wrk-act.
wrk-act.gr = 2.
wrk-act.id = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-o.
wrk-act.crc = 5.

s-tot-2act = v-sum-all.
s-tot-2act-t = v-sum-all-t.
s-tot-2act-u = v-sum-all-u.
s-tot-2act-e = v-sum-all-e.
s-tot-2act-r = v-sum-all-r.
s-tot-2act-o = v-sum-all-o.

/*3-group*/
v-sum-all = 0.
v-sum-all-t = 0.
v-sum-all-u = 0.
v-sum-all-e = 0.
v-sum-all-r = 0.
v-sum-all-o = 0.
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
for each tgl where
(int(substr(string(tgl.gl),1,4)) >= 1471 and int(substr(string(tgl.gl),1,4)) < 1477)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 1.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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

for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1651 and int(substr(string(tgl.gl),1,4)) <= 1660)
or (int(substr(string(tgl.gl),1,4)) >= 1692 and int(substr(string(tgl.gl),1,4)) <= 1699)
or (int(substr(string(tgl.gl),1,4)) >= 1601 and int(substr(string(tgl.gl),1,4)) <= 1603)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.sum = v-sum.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 2.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o.

v-sum-all = v-sum-all + v-sum.
v-sum-all-t = v-sum-all-t + v-sum-t.
v-sum-all-u = v-sum-all-u + v-sum-u.
v-sum-all-e = v-sum-all-e + v-sum-e.
v-sum-all-r = v-sum-all-r + v-sum-r.
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
for each tgl where
(
(int(substr(string(tgl.gl),1,4)) >= 1491 and int(substr(string(tgl.gl),1,4)) <= 1495)
or int(substr(string(tgl.gl),1,4)) = 1610
or (int(substr(string(tgl.gl),1,4)) >= 1705 and int(substr(string(tgl.gl),1,4)) <= 1772)
or int(substr(string(tgl.gl),1,4)) = 1792
or int(substr(string(tgl.gl),1,4)) = 1793
or (int(substr(string(tgl.gl),1,4)) >= 1811 and int(substr(string(tgl.gl),1,4)) <= 1844)
or (int(substr(string(tgl.gl),1,4)) >= 1851 and int(substr(string(tgl.gl),1,4)) <= 1854)
or (int(substr(string(tgl.gl),1,4)) >= 1856 and int(substr(string(tgl.gl),1,4)) <= 1878)
or int(substr(string(tgl.gl),1,4)) = 1879
or (int(substr(string(tgl.gl),1,4)) >= 1891 and int(substr(string(tgl.gl),1,4)) <= 1899)
)
no-lock:
    v-sum = v-sum + tgl.sum.
    if tgl.crc = 1 then v-sum-t = v-sum-t + tgl.sum.
    if tgl.crc = 2 then v-sum-u = v-sum-u + tgl.sum.
    if tgl.crc = 3 then v-sum-e = v-sum-e + tgl.sum.
    if tgl.crc = 4 then v-sum-r = v-sum-r + tgl.sum.
    if tgl.crc > 4 then v-sum-o = v-sum-o + tgl.sum.
end.
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1495
or  (int(substr(string(tgl.gl),1,4)) >= 1876 and int(substr(string(tgl.gl),1,4)) <= 1878)
or int(substr(string(tgl.gl),1,4)) = 1858 or int(substr(string(tgl.gl),1,4)) = 1859
)
no-lock:
    v-sum1 = v-sum1 + tgl.sum.
    if tgl.crc = 1 then v-sum1-t = v-sum1-t + tgl.sum.
    if tgl.crc = 2 then v-sum1-u = v-sum1-u + tgl.sum.
    if tgl.crc = 3 then v-sum1-e = v-sum1-e + tgl.sum.
    if tgl.crc = 4 then v-sum1-r = v-sum1-r + tgl.sum.
    if tgl.crc > 4 then v-sum1-o = v-sum1-o + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.sum = v-sum - v-sum1.
wrk-act.crc = 0.

create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.crc = 1.
wrk-act.sum = v-sum-t - v-sum1-t.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.crc = 2.
wrk-act.sum = v-sum-u - v-sum1-u.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.crc = 3.
wrk-act.sum = v-sum-e - v-sum1-e.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.crc = 4.
wrk-act.sum = v-sum-r - v-sum1-r.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 3.
wrk-act.crc = 5.
wrk-act.sum = v-sum-o - v-sum1-o.

v-sum-all = v-sum-all + (v-sum - v-sum1).
v-sum-all-t = v-sum-all-t + (v-sum-t  - v-sum1-t).
v-sum-all-u = v-sum-all-u + (v-sum-u - v-sum1-u).
v-sum-all-e = v-sum-all-e + (v-sum-e - v-sum1-e).
v-sum-all-r = v-sum-all-r + (v-sum-r  - v-sum1-r).
v-sum-all-o = v-sum-all-o + (v-sum-o  - v-sum1-o).

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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1477
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 5.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.

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
for each tgl where
(
int(substr(string(tgl.gl),1,4)) = 1495
or int(substr(string(tgl.gl),1,4)) =  1876
or int(substr(string(tgl.gl),1,4)) = 1877
or int(substr(string(tgl.gl),1,4)) = 1878
/*or int(substr(string(tgl.gl),1,4)) = 1858
or int(substr(string(tgl.gl),1,4)) = 1859*/
or int(substr(string(tgl.gl),1,4)) = 1873
or int(substr(string(tgl.gl),1,4)) = 1874
)
no-lock:
    v-sum = v-sum + tgl.sum.
end.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 6.
wrk-act.sum = v-sum.
v-sum-all = v-sum-all + v-sum.


create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 0.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 1.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-t.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 2.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-u.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 3.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-e.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 4.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-r.
create wrk-act.
wrk-act.gr = 3.
wrk-act.id = 4.
wrk-act.crc = 5.
wrk-act.typ = "total".
wrk-act.sum = v-sum-all-o.

