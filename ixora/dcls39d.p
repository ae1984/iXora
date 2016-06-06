/* dcls39d.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.10.2012 evseev ТЗ-1556
 * BASES
        BANK
 * CHANGES
*/




/*
Для проводок:
Дт 1858 (валюта);
Кт 2858  (валюта);
Дт 1859 (тенге);
Кт 2859 (тенге).

Для переноса на 185800:

вал
Дт 2858
Кт 1858

кзт
Дт 1858
Кт 1859

кзт
Дт 2859
Кт 1858

*/

{global.i}


def var s-jh like jh.jh.
def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.

def var v-bal as decimal.

find first cmp no-lock no-error.
if avail cmp and cmp.name matches "*МКО*" then return.

v-bal = 0.
find first glbal where glbal.gl = 185900 and glbal.crc = 1 no-lock no-error.
if avail glbal then v-bal = glbal.bal.
for each jl where jl.jdt = g-today and jl.gl = 185900 and jl.crc = 1 no-lock:
  v-bal = v-bal + jl.dam - jl.cam.
end.
if v-bal > 0 then do:
    v-templ = "dcl0018".
    v-param = string(v-bal) + vdel + "1" + vdel + "185800"  + vdel + "185900" + vdel + "Перенос остатков со счета ГК 185900 «Контрстоимость ин.вал.в тг(длин.вал.поз)»".

    s-jh = 0.
    run trxgen (v-templ, vdel, v-param, "dcl" , "" , output rcode, output rdes, input-output s-jh).
    if rcode <> 0 then do:
       message rdes.
       run savelog("dcls39d", "185900; " + rdes).
    end.
    run savelog("dcls39d", "185900; s-jh = " + string(s-jh) + " v-bal = " + string(v-bal)).
end. else run savelog("dcls39d", "185900; v-bal = " + string(v-bal)).


v-bal = 0.
find first glbal where glbal.gl = 285900 and glbal.crc = 1 no-lock no-error.
if avail glbal then v-bal = glbal.bal.
for each jl where jl.jdt = g-today and jl.gl = 285900 and jl.crc = 1 no-lock:
  v-bal = v-bal + jl.cam - jl.dam.
end.
if v-bal > 0 then do:
    v-templ = "dcl0018".
    v-param = string(v-bal) + vdel + "1" + vdel + "285900"  + vdel + "185800" + vdel + "Перенос остатков со счета ГК 285900 «Контрстоимость ин.вал.в тг(кор.вал.поз.)»" .

    s-jh = 0.
    run trxgen (v-templ, vdel, v-param, "dcl" , "" , output rcode, output rdes, input-output s-jh).
    if rcode <> 0 then do:
       message rdes.
       run savelog("dcls39d", "285900; " + rdes).
    end.
    run savelog("dcls39d", "285900; s-jh = " + string(s-jh) + " v-bal = " + string(v-bal)).
end. else run savelog("dcls39d", "285900; v-bal = " + string(v-bal)).



for each crc no-lock:
    v-bal = 0.
    find first glbal where glbal.gl = 285800 and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = 285800 and jl.crc = crc.crc no-lock:
      v-bal = v-bal + jl.cam - jl.dam.
    end.
    if v-bal > 0 then do:
        v-templ = "dcl0018".
        v-param = string(v-bal) + vdel + string(crc.crc) + vdel + "285800"  + vdel + "185800"  + vdel + "Перенос остатков со счета ГК 285800 «Длинная валютная позиция по иностр.валют»" .

        s-jh = 0.
        run trxgen (v-templ, vdel, v-param, "dcl" , "" , output rcode, output rdes, input-output s-jh).
        if rcode <> 0 then do:
           message rdes.
           run savelog("dcls39d", "285800; " + rdes + " crc = "  + string(crc.crc)).
        end.
        run savelog("dcls39d", "285800; s-jh = " + string(s-jh) + " v-bal = " + string(v-bal) + " crc = "  + string(crc.crc)).
    end. else run savelog("dcls39d", "285800; v-bal = " + string(v-bal) + " crc = "  + string(crc.crc)).
end.



/*проверка*/
v-bal = 0.
find first glbal where glbal.gl = 185900 and glbal.crc = 1 no-lock no-error.
if avail glbal then v-bal = glbal.bal.
for each jl where jl.jdt = g-today and jl.gl = 185900 and jl.crc = 1 no-lock:
  v-bal = v-bal + jl.dam - jl.cam.
end.
if v-bal > 0 then do:
   message "На счете 185900 имеются остатки! Возникнет проблема с переоценкой" view-as alert-box.
end.
v-bal = 0.
find first glbal where glbal.gl = 285900 and glbal.crc = 1 no-lock no-error.
if avail glbal then v-bal = glbal.bal.
for each jl where jl.jdt = g-today and jl.gl = 285900 and jl.crc = 1 no-lock:
  v-bal = v-bal + jl.cam - jl.dam.
end.
if v-bal > 0 then do:
   message "На счете 285900 имеются остатки! Возникнет проблема с переоценкой" view-as alert-box.
end.
for each crc no-lock:
    v-bal = 0.
    find first glbal where glbal.gl = 285800 and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then v-bal = glbal.bal.
    for each jl where jl.jdt = g-today and jl.gl = 285800 and jl.crc = crc.crc no-lock:
      v-bal = v-bal + jl.cam - jl.dam.
    end.
    if v-bal > 0 then do:
       message "На счете 285800 валюта " + string(crc.crc) + " имеются остатки! Возникнет проблема с переоценкой" view-as alert-box.
    end.
end.
