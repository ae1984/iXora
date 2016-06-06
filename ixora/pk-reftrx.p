/* pk-reftrx.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Перевод суммы для погашения рефинансируемого кредита и непосредственно погашение
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
        12/05/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        16/05/2006 madiyar - в сумму, забираемую на погашение рефинансируемого кредита, добавили комиссию за ведение счета за один месяц
        10/10/2008 madiyar - подправил расчет комиссии за обслуживание кредита
        21/10/2008 madiyar - если валюты разные - комисии вручную; три комиссии вперед (включая текущий месяц)
        29/07/2009 galina - рефинансирование просрочников без списания процентов и шрафов
        01/08/2009 madiyar - рефинансируем в валюте
        24/08/2009 galina - изменения для полного погашения рефинансируемого кредита
        27/08/2009 galina - безналичный курс берем из sysc
        20/10/2009 galina - проставляем признак рефинансирование
        12/01/2010 galina - берем анкеты со статусом 60
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115
*/

{global.i}
{pk.i}
{getdep.i}
{getcomgl.i}
def output parameter v-errcode as char.
def shared var v-resref as integer no-undo.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

if pkanketa.sts <> "60" then do: v-errcode = "Неверный статус анкеты!". return. end. /* ????? */

def var v-lon as char no-undo.
def var v-srok as int no-undo.
def var v-npl as char no-undo.
def var v-bal as deci no-undo.
def var v-bal1 as deci no-undo.
def var v-bal10 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal5 as deci no-undo.
def var v-balpen  as deci no-undo.
def var v-bal12 as deci no-undo.
def var v-bal16 as deci no-undo.
def var v-bal11_12 as deci no-undo.
def var v-londog as char no-undo.
def buffer bjl for jl.
def var v-code as char no-undo.
def var v-dep as char no-undo.
def var v-tarif as char no-undo.
def var v-gl like jl.gl no-undo.
def var v-balcom as deci no-undo.
def var v-transsum_lon  as deci no-undo.
def var v-transsum as deci no-undo.
def var v-nxt as integer no-undo.
def var s-glremx as char extent 5.
def var pay12 like jl.dam no-undo.
def var pay10_2 like jl.dam no-undo. /* учет предоплаты - погашение %% */
def var pay10_9 like jl.dam no-undo. /* учет предоплаты - погашение просроченных %% */
def var dlong as date no-undo.
def var v-bal2_ln as deci no-undo.
def var bilance like jl.dam no-undo.
def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var dat_wrk as date no-undo.
def buffer b-anketa for pkanketa.
def buffer b-lon for lon.
find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
if avail pkanketh then v-lon = entry(1,pkanketh.rescha[1]).

find first lon where lon.lon = v-lon no-lock no-error.
if not avail lon then do: v-errcode = "Не найден кредит для рефинансирования " + lon.lon + "!". return. end.

find first b-lon where b-lon.lon = pkanketa.lon no-lock no-error.
if avail b-lon then do:
   find first sub-cod where sub-cod.acc = b-lon.lon and sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkpur' use-index dcod no-lock no-error.
   if not avail sub-cod then do:
      create sub-cod.
      assign sub-cod.acc = b-lon.lon
             sub-cod.sub = 'LON'
             sub-cod.d-cod = 'pkpur'
             sub-cod.ccode = '10'.
   end.
   else do:
     find current sub-cod exclusive-lock no-error.
     sub-cod.ccode = '10'.
     find current sub-cod no-lock no-error.
   end.
   create hissc.
   assign hissc.sub = 'LON'
          hissc.acc =  b-lon.lon
          hissc.d-cod = 'pkpur'
          hissc.ccode = '10'
          hissc.rdt = g-today
          hissc.who = g-ofc
          hissc.tim = time.

end.
find first b-anketa where  b-anketa.bank = s-ourbank and b-anketa.lon = lon.lon no-lock no-error.
if not avail b-anketa then do: v-errcode = "Не найдена анкета для кредита " + lon.lon + "!". return. end.

find first aaa where aaa.aaa = lon.aaa and aaa.sta <> 'C' and aaa.sta <> 'E' no-lock no-error.
if not avail aaa then do: v-errcode = "Не найден текущий счет " + lon.aaa + "!". return. end.

v-srok = (round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30.
if v-srok > 360 then v-npl = "423". else v-npl = "421".


run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).

run lonbalcrc('lon',lon.lon,g-today,"16,5",yes,'1',output v-balpen).

run lonbalcrc('lon',lon.lon,g-today,"16",yes,'1',output v-bal16).

run lonbalcrc('lon',lon.lon,g-today,"5",yes,'1',output v-bal5).
run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).

find first crc where crc.crc = lon.crc no-lock no-error.

if lon.crc <> 1 then do:
  find first crc where crc.crc = lon.crc no-lock no-error.

  if not avail crc then do:
     v-errcode = "Не найдена валюта " + string(lon.crc) + " для рефинансируемого кредита!". return.
  end.

  /*find sysc where sysc.sysc = 'erc' + crc.code no-lock no-error.*/
  find sysc where sysc.sysc = 'ec' + crc.code no-lock no-error.
  if not avail sysc then do:
     v-errcode = "Не найден безналичный курс продажи валюты " + crc.code. return.
  end.
  v-balpen = v-balpen / sysc.deval. /*пересчитываем по курсу покупки  безналич. валюты*/
end.

run lonbalcrc('cif',aaa.aaa,g-today,"1",yes,lon.crc,output v-bal).
v-bal = - v-bal.

v-balcom = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' and bxcif.crc = lon.crc no-lock:
   v-balcom = v-balcom + bxcif.amount.
end.

v-transsum = v-bal1 + v-bal2 + v-bal4 + v-bal7 + v-bal9 + v-balpen + v-balcom - v-bal. /* ОД + ОД7 - текущий остаток на счете */


if v-transsum <= 0 then do: v-errcode = "Ошибка расчета суммы кредита!". return. end.
v-transsum_lon = v-transsum.

if lon.crc = 1 and pkanketa.crc <> 1 then do:
  find first crc where crc.crc = pkanketa.crc no-lock no-error.
  if not avail crc then do:
     v-errcode = "Не найдена валюта " + string(pkanketa.crc) + " для нового кредита!". return.
  end.
  /*find sysc where sysc.sysc = 'ec' + crc.code no-lock no-error.*/
  find sysc where sysc.sysc = 'ec' + crc.code no-lock no-error.
  if not avail sysc then do:
     v-errcode = "Не найден безналичный курс покупки валюты " + crc.code. return.
  end.
  v-transsum = v-transsum / sysc.deval. /*курс покупки валюты*/

end.
if lon.crc <> 1 and pkanketa.crc = 1 then do:
  find first crc where crc.crc = lon.crc no-lock no-error.

  if not avail crc then do:
     v-errcode = "Не найдена валюта " + string(lon.crc) + " для рефинансируемого кредита!". return.
  end.
  /*find sysc where sysc.sysc = 'erc' + crc.code no-lock.*/
  find sysc where sysc.sysc = 'ec' + crc.code no-lock.
  v-transsum = v-transsum * sysc.deval. /*курс продажи валюты*/
  if not avail sysc then do:
     v-errcode = "Не безналичный найден курс продажи валюты " + crc.code. return.
  end.
end.

if lon.crc <> 1 and pkanketa.crc <> 1 and lon.crc <> pkanketa.crc then do: v-errcode = "Валюта рефинансируемого и нового кредита не тенге!". return. end. /*ошибка, если рефинансируем валютный кредит в валюту (например USD->EUR)*/


if v-transsum > truncate(v-transsum,0) then v-transsum = truncate(v-transsum,0) + 1.
if v-transsum_lon > truncate(v-transsum_lon,0) then v-transsum_lon = truncate(v-transsum_lon,0) + 1.

if pkanketa.crc = 1 then run lonbalcrc('cif', pkanketa.aaa,g-today,"1",yes,pkanketa.crc, output v-bal).
if pkanketa.crc <> 1 then run lonbalcrc('cif', pkanketa.aaaval,g-today,"1",yes,pkanketa.crc, output v-bal).
v-bal = - v-bal.
if v-bal < v-transsum then do: v-errcode = "Выданная сумма меньше расчитаной! " + string(v-bal) + ' ' + string(v-transsum). return. end.



/*
проводка по переводу суммы v-transsum с pkanketa.aaa на aaa.aaa
*/


if lon.crc = pkanketa.crc then do:
    v-param = '' + vdel +
              string(v-transsum) + vdel +
              string(lon.crc) + vdel.
    if lon.crc = 1 then v-param = v-param + pkanketa.aaa + vdel.
    else v-param = v-param + pkanketa.aaaval + vdel.
    v-param = v-param + aaa.aaa + vdel + "Перевод средств по программе реф-ния РНН/" + pkanketa.rnn + vdel +  v-npl. /* назначение платежа */

    s-jh = 0.
    run trxgen ("jou0022", vdel, v-param, "cif", aaa.aaa, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        v-resref = 1.
        message rdes.
        pause.
        undo, return.
    end.

    for each jl where jl.jh = s-jh: jl.sts = 5. end.
    for each jh where jh.jh = s-jh: jh.sts = 5. end.
    run jl-stmp.


end.
else do:
    v-param = string (v-transsum) + vdel + "1" + vdel.
    if pkanketa.crc = 1 then v-param = v-param + pkanketa.aaa.
    if pkanketa.crc <> 1 then v-param = v-param + pkanketa.aaaval.

    s-jh = 0.
    v-param = v-param + vdel + "Перевод средств по программе реф-ния с конвертацией РНН/" + pkanketa.rnn + vdel +
                 "" + vdel + string (v-transsum_lon) + vdel + "1" + vdel + aaa.aaa.


    run trxgen ("vnb0077", vdel, v-param, "cif", aaa.aaa, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        v-resref = 1.
        message rdes.
        pause.
        undo, return.
    end.

    for each jl where jl.jh = s-jh: jl.sts = 5. end.
    for each jh where jh.jh = s-jh: jh.sts = 5. end.
    run jl-stmp.
end.

if lon.crc <> 1 then do:
  find first crc where crc.crc = lon.crc no-lock no-error.
   find sysc where sysc.sysc = 'ec' + crc.code no-lock.
  /*find sysc where sysc.sysc = 'erc' + crc.code no-lock.*/
  if not avail sysc then do:
     v-errcode = "Не безналичный найден курс продажи валюты " + crc.code. return.
  end.
end.

/*вносим в баланс забалансовые штрафы */
v-param = string(v-bal5) + vdel + lon.lon + vdel + "Сумма погашаемого забалансового штрафа" +  trim(string(v-bal5,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + string(v-bal5).
s-jh = 0.
run trxgen ("lon0119", vdel, v-param, "lon" , lon.lon , output rcode,output rdes, input-output s-jh).

if rcode ne 0 then do:
    v-resref = 1.
    message rdes.
    pause.
    undo, return.
end.
for each jl where jl.jh = s-jh: jl.sts = 5. end.
for each jh where jh.jh = s-jh: jh.sts = 5. end.
run jl-stmp.


s-jh = 0.
/*вносим в баланс забалансовые %% */
/*v-param = string(v-bal4) + vdel + lon.lon + vdel + "Сумма погашаемых забалансовых %% " +  trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + string(v-bal4).*/
if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel +
      "Сумма погашаемых забалансовых %% " +  trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + "0" + vdel + string(v-bal4) + vdel + lon.lon + vdel +
      "Сумма погашаемых забалансовых %% " +  trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + string(v-bal4).
else v-param = string(v-bal4) + vdel + lon.lon + vdel +
      "Сумма погашаемых забалансовых %% " +  trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + string(v-bal4) + vdel + "0" + vdel + lon.lon + vdel +
      "Сумма погашаемых забалансовых %% " +  trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + crc.code + vdel + "0".
run trxgen ("lon0115", vdel, v-param, "lon" , lon.lon , output rcode,output rdes, input-output s-jh).

if rcode ne 0 then do:
    v-resref = 1.
    message rdes.
    pause.
    undo, return.
end.

for each jl where jl.jh = s-jh: jl.sts = 5. end.
for each jh where jh.jh = s-jh: jh.sts = 5. end.
run jl-stmp.


v-londog = ''.
find first loncon where loncon.lon = lon.lon no-lock no-error.
if avail loncon then v-londog = loncon.lcnt.

find first cif where cif.cif = lon.cif no-lock no-error.

/*
проводка по погашению кредита
*/
/************************************************************/
if lon.crc <> 1 then do:
  find first crc where crc.crc = lon.crc no-lock no-error.
  find sysc where sysc.sysc = 'ec' + crc.code no-lock.
/*  find sysc where sysc.sysc = 'erc' + crc.code no-lock.*/
  if not avail sysc then do:
     v-errcode = "Не безналичный найден курс продажи валюты " + crc.code. return.
  end.
end.
for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon and trxbal.level = 10 no-lock :
   v-bal10 = v-bal10 + (trxbal.cam - trxbal.dam).
end.

v-bal2_ln = v-bal2.

/* Учтем пролонгации */
dlong = lon.duedt.
if lon.ddt[5] <> ? then dlong = lon.ddt[5].
if lon.cdt[5] <> ? then dlong = lon.cdt[5].
if dlong > lon.duedt and dlong > g-today then do:
   v-bal1 = 0. v-bal2_ln = 0.
end.

/* Если пролонгация закончилась, то гасить все что есть на 1 и 2 уровнях */
if dlong <= g-today then do: v-bal1 = lon.dam[1] - lon.cam[1]. v-bal2_ln = lon.dam[2] - lon.cam[2]. end.

/* проверим v-bal2 на непревышение начисленных процентов на 2-ом уровне */
if v-bal2_ln > v-bal2 then v-bal2_ln = v-bal2.

/* 22/12/2004 madiyar - корректировка погашаемых процентов с учетом предоплаты */


if v-bal10 > 0 and v-bal9 > 0 then do:
   if v-bal9 <= v-bal10 then pay10_9 = v-bal9.
   else pay10_9 = v-bal10.
   v-bal10 = v-bal10 - pay10_9.
   v-bal9 = v-bal9 - pay10_9.
end.

if v-bal10 > 0 and v-bal2_ln > 0 then do:
   if v-bal2_ln <= v-bal10 then pay10_2 = v-bal2_ln.
   else pay10_2 = v-bal10.
   v-bal10 = v-bal10 - pay10_2.
   v-bal2_ln = v-bal2_ln - pay10_2.
end.

if pay10_2 > 0 or pay10_9 > 0 then do:
   pay12 = pay12 + (pay10_2 + pay10_9) * crc.rate[1] / crc.rate[9].
end.

/* сумма для погашения просроченных процентов */ /* 04/05/2005 madiyar - убрал просроченные индекс. % */
pay12 = pay12 + v-bal9 * crc.rate[1] / crc.rate[9].

/* сумма для погашения процентов по графику */ /* 04/05/2005 madiyar - убрал индекс. % */
 pay12 = pay12 + v-bal2_ln * crc.rate[1] / crc.rate[9].
/****************************************************************/

if v-balpen > 0 or v-bal9 > 0 or v-bal4 > 0 or v-bal7 > 0 or v-bal2_ln > 0 or v-bal1 > 0  or pay10_2 > 0 or pay10_9 > 0 then do:
     v-bal16 = v-bal16 + v-bal5.
     v-bal2_ln = v-bal2_ln + v-bal4.

     v-bal12 = pay12.
     v-bal12 = v-bal12 + v-bal4 * crc.rate[1] / crc.rate[9].

     if lon.crc <> 1 then do:
        /*перевод с тенгового счета на валютный*/
        v-param = string (v-bal16 / sysc.deval) + vdel + "1" + vdel + lon.aaa + vdel + "Перевод средств для погашения штрафов РНН/" + pkanketa.rnn + vdel +
                     "" + vdel + string (v-bal16) + vdel + "1" + vdel + b-anketa.aaa.
        s-jh = 0.
        run trxgen ("vnb0077", vdel, v-param, "cif", aaa.aaa, output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            v-resref = 1.
            message rdes.
            pause.
            undo, return.
        end.
        for each jl where jl.jh = s-jh: jl.sts = 5. end.
        for each jh where jh.jh = s-jh: jh.sts = 5. end.
        run jl-stmp.


        /*погашение шрафов*/
        v-param =  string(v-bal16) + vdel + b-anketa.aaa + vdel + lon.lon.
        if v-srok > 360 then v-param = v-param + vdel + "423".
        else v-param = v-param + vdel + "421".
        v-param = v-param + vdel + "0" + vdel +  "0" + vdel + "0" + vdel + "0" +  vdel + "0" + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel + "Сумма погашаемого штрафа" + trim(string(v-bal16,">>>,>>>,>>9.99-")) + " KZT" + vdel + '0' + vdel + '0'.

        s-jh = 0.
        run trxgen ("lon0062", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
           v-resref = 1.
           message rdes.
           pause.
           undo, return.
        end.
        for each jl where jl.jh = s-jh: jl.sts = 5. end.
        for each jh where jh.jh = s-jh: jh.sts = 5. end.
        run jl-stmp.

        v-param = '0' + vdel + lon.aaa + vdel + lon.lon.

     end.

     if lon.crc = 1 then v-param = string(v-bal16) + vdel + lon.aaa + vdel + lon.lon.

     v-srok = (round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30.
     if v-srok > 360 then v-param = v-param + vdel + "423".
     else v-param = v-param + vdel + "421".

     v-param =  v-param + vdel + string(v-bal9) + vdel +  string(v-bal7) + vdel + string(v-bal2_ln) + vdel + string(v-bal1).

     for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon and trxbal.level = 11 no-lock :
       bilance = trxbal.cam - trxbal.dam.
     end.

     if v-bal12 > bilance then v-param = v-param + vdel + string(bilance).
     else v-param = v-param + vdel + string(v-bal12).
     v-bal11_12 = 0.
     if v-bal12 < bilance then v-bal11_12 = bilance - v-bal12.

     s-glremx[1] = "Оплата кредита " + lon.lon + " " + v-londog + " " +  trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-")) + " " + crc.code + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss .
     if v-bal1 ne 0 then s-glremx[2] = "Сумма погашаемого осн. долга " + trim(string(v-bal1,">>>,>>>,>>9.99-")) + " " + crc.code.
     else s-glremx[2] = "".

     if v-bal2_ln ne 0 then  s-glremx[3] = "Сумма погашаемых %% " + trim(string(v-bal2_ln + pay10_2,">>>,>>>,>>9.99-")) + " " + crc.code.
     else s-glremx[3] = "".

     if v-bal7 ne 0 then s-glremx[4] = "Сумма погашаемого просроч ОД" + trim(string(v-bal7,">>>,>>>,>>9.99-")) + " " + crc.code.
     else s-glremx[4] = "".

     if v-bal9 ne 0 then s-glremx[5] = "Сумма погашаемого просроч %%" + trim(string(v-bal9 + pay10_9,">>>,>>>,>>9.99-")) + " " + crc.code.
     else s-glremx[5] = "".

     if v-bal16 ne 0 then do:
        if lon.crc = 1 then s-glremx[5] = s-glremx[5] + "Сумма погашаемого штрафа" + trim(string(v-bal16,">>>,>>>,>>9.99-")) + " KZT" .
        else s-glremx[5] = "".
     end.

     v-param = v-param + vdel +
               s-glremx[1] + vdel +
               s-glremx[2] + vdel +
               s-glremx[3] + vdel +
               s-glremx[4] + vdel +
               s-glremx[5] .

     v-param = v-param + vdel +
               string(pay10_2) + vdel +
               string(pay10_9).


     s-jh = 0.
     run trxgen ("lon0062", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
     {upd-dep.i}
     if rcode ne 0 then do:
        v-resref = 1.
        message rdes.
        pause.
        undo, return.
     end.
     for each jl where jl.jh = s-jh: jl.sts = 5. end.
     for each jh where jh.jh = s-jh: jh.sts = 5. end.
     run jl-stmp.

     run lonresadd(s-jh).
     find jh where jh.jh eq s-jh no-lock no-error.

     if v-bal1 gt 0 then do:
        v-nxt = 0.
        for each lnsch where lnsch.lnn eq lon.lon no-lock :
           if lnsch.f0 eq 0 and lnsch.flp gt 0 then do:
              if v-nxt lt lnsch.flp then v-nxt = lnsch.flp.
           end.
        end.
     create lnsch.
            lnsch.lnn = lon.lon.
            lnsch.f0 = 0.
            lnsch.flp = v-nxt + 1.
            lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
            lnsch.paid = v-bal1.
            lnsch.stdat = jh.jdt.
            lnsch.jh = jh.jh.
            lnsch.whn = g-today.
            lnsch.who = g-ofc.
     end.

     if v-bal7 gt 0 then do:
        v-nxt = 0.
        for each lnsch where lnsch.lnn eq lon.lon no-lock :
           if lnsch.f0 eq 0 and lnsch.flp gt 0 then do:
              if v-nxt lt lnsch.flp then v-nxt = lnsch.flp.
           end.
        end.
        create lnsch.
               lnsch.lnn = lon.lon.
               lnsch.f0 = 0.
               lnsch.flp = v-nxt + 1.
               lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
               lnsch.paid = v-bal7.
               lnsch.stdat = jh.jdt.
               lnsch.jh = jh.jh.
               lnsch.whn = g-today.
               lnsch.who = g-ofc.
     end.

     if v-bal2_ln gt 0 then do:
        v-nxt = 0.
        for each lnsci where lnsci.lni eq lon.lon no-lock :
           if lnsci.f0 eq 0 and lnsci.flp gt 0 then do:
              if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
           end.
        end.
        create lnsci.
               lnsci.lni = lon.lon.
               lnsci.f0 = 0.
               lnsci.flp = v-nxt + 1.
               lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
               lnsci.paid-iv = v-bal2_ln.
               lnsci.idat = jh.jdt.
               lnsci.jh = jh.jh.
               lnsci.whn = g-today.
               lnsci.who = g-ofc.

     end.

     if v-bal9 gt 0 then do:
        v-nxt = 0.
        for each lnsci where lnsci.lni eq lon.lon no-lock :
           if lnsci.f0 eq 0 and lnsci.flp gt 0 then do:
              if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
           end.
        end.
        create lnsci.
               lnsci.lni = lon.lon.
               lnsci.f0 = 0.
               lnsci.flp = v-nxt + 1.
               lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
               lnsci.paid-iv = v-bal9.
               lnsci.idat = jh.jdt.
               lnsci.jh = jh.jh.
               lnsci.whn = g-today.
               lnsci.who = g-ofc.

     end.

     if v-bal7 ne 0 then do:
         create lonpen.
         assign lonpen.lon = lon.lon
                lonpen.cif = lon.cif
                lonpen.rdt = g-today
                lonpen.who = g-ofc
                lonpen.lev = 7
                lonpen.cam = v-bal7.
     end.
     /************************/
     if v-bal11_12 > 0 then do:
        s-jh = 0.
        v-param = string(v-bal11_12) + vdel + lon.lon + vdel + "Оплата кредита " + lon.lon + " " + v-londog + " " +  trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-")) + " " + crc.code + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss + vdel + "Урегулирование курсовой разницы".
        run trxgen("LON0090", vdel,v-param, "lon", "", output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
          v-resref = 1.
          message rdes.
          pause.
          undo, return.
        end.
        for each jl where jl.jh = s-jh: jl.sts = 5. end.
        for each jh where jh.jh = s-jh: jh.sts = 5. end.
        run jl-stmp.
     end.
     /***********************/



end.
/****************************/
/*Погашение комиссии*/

if v-balcom > 0 then do:
   run lonbalcrc('cif',lon.aaa,g-today,"1",yes,lon.crc,output v-bal).
   v-bal = - v-bal.
   if v-balcom > v-bal then return.
   s-jh = 0.

   v-param = string(v-balcom) + vdel + lon.aaa + vdel +  "460712" + vdel + "Оплата комиссионного долга при рефинансировании".
   run trxgen("CIF0006", vdel,v-param, "cif", "", output rcode, output rdes, input-output s-jh).


   v-gl = 460712.
   v-tarif = '195'.
  /*переприсваиваем значения trxcods*/
   for each bjl where  bjl.jh = s-jh and  bjl.gl = v-gl no-lock .
     find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = bjl.ln and  trxcods.codfr = 'cods' no-error.
     if not avail trxcods then next.
     find first cods where cods.gl  = v-gl and cods.arc = no and cods.acc = v-tarif no-lock no-error.
     if avail cods then do: v-code = cods.code.   v-dep = getdep(lon.cif). end.
     if v-code <> ""  then  trxcods.code = v-code + v-dep.
   end.


  if rcode ne 0 then do:
     v-resref = 1.
     message rdes.
     pause.
     undo, return.
  end.
  if rcode = 0 then do:
     for each bxcif where bxcif.cif = lon.cif and bxcif.aaa = lon.aaa and bxcif.type = '195' and bxcif.crc = lon.crc exclusive-lock:
       delete bxcif.
     end.

  end.

  for each jl where jl.jh = s-jh: jl.sts = 5. end.
  for each jh where jh.jh = s-jh: jh.sts = 5. end.
  run jl-stmp.

end.
