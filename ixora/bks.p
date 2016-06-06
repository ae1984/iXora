/* bks.p
 * MODULE
        Касса
 * DESCRIPTION
        Формирование контрольного банковского чека
 * RUN
     Формат s_payment на отдельный платеж:
     s_rowid = "первичный ключ таблицы" + "#" + "операция" + "#" + "сумма" + "#" + "комиссия" + "#" + "1 - c НДС, 0 - без НДС" + "#" + "код валюты ISO" + "|".
     s_trx - если кассовая проводка + "#" + получатель РНН + "#" + получатель имя + "#" + Отправитель РНН + "#" + отрпавитель имя
 * CALLER
        Список процедур, вызывающих этот файл
         oterkvit.p
         taxkvit.p
         taxlist.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        20/06/03 kanat
 * CHANGES
        16/09/03 sasco убрал создание таблицы bksnmb
        16/09/03 sasco проверка на офицера из sysc."BKEXCL"
        12/10/03 kanat убрал skip(7) в конце
        13/10/03 sasco добавил "return s_payment" чтобы refresh в коммунальных сработал
        27/02/04 kanat подправил подсчет НДС
        09/03/04 kanat вместо логина печатается ФИО офицера
        01/12/05 kanat переделал АО и ссылки на depaccnt
        21/01/05 sasco поиск свидетельства НДС через sysc."NDSSVI"
        16/01/06 u00568 Evgeniy Теперь в s_trx может передаваться "Получатель и Отправитель" в формате
                 "NO" + "#" + commonpl.rnnbn + "#" + commonls.bn + "#" + commonpl.rnn + "#" + commonpl.fioadr
                 или по русски
                 что было раньше + "#" + получатель РНН + "#" + получатель имя + "#" + Отправитель РНН + "#" + отрпавитель имя
        06/04/06 u00568 Evgeniy - ТЗ 251 от 21/02/2006 - сделать в БКС более заметной сумму комиссии банка
                                + проставил no-undo
        26/04/06 u00568 Evgeniy - сжатый чек бкс и адекватное завершение печати.
        24.04.07 id00004 - Изменил реквизиты в БКС.
        04.07.07 id00004 - отключил печать БКС.
        04.01.08 id00004 - внес изменения в БКС для приема погашений РКЦ
        03.03.10 id00205 - из передаваемых значений берется только номер проводки из s_payment и обрабатывается s_trx если есть
        02/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{get-dep.i}
{comm-txb.i}
{ndssvi.i}
{convgl.i "bank"}

def input parameter s_payment as char no-undo.
def input parameter s_trx as char no-undo.

def var s_rowid  as char no-undo.
def var s_npl as char no-undo.
def var s_nds as char no-undo.
def var d_sum as decimal no-undo.

def var s_temp_first as char no-undo.
def var s_temp_second as char no-undo.
def var i_entr_nmb as integer no-undo.
def var total_sum as decimal no-undo.
def var i as integer no-undo.
def var d_nds_tmp as decimal no-undo.
def var s_currency as char no-undo.
def var d_bksnmb as char no-undo.
def var s_stadr as char no-undo.
def var s_depname as char no-undo.
def var d_new_bks as decimal no-undo.

def var commonpl_rnnbn as char no-undo. /*u00568*/
def var commonls_bn as char no-undo.
def var commonpl_rnn as char no-undo.
def var commonpl_fioadr as char no-undo. /**/

def var p_comsum as decimal init 0 no-undo.
define variable p_whole_comsum as decimal init 0 no-undo.
def var p_whole_sum as decimal init 0 no-undo.
def var s_nknmb as char no-undo.
def var s_rnn as char no-undo.

def var i_temp_dep as integer no-undo.

def var v-nds as decimal no-undo.
def var v-ofcname as char no-undo.

define buffer d_crc for crc.
define buffer c_crc for crc.


find first sysc where sysc = "nds" no-lock no-error.
if avail sysc then
v-nds = sysc.deval.

find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
if available sysc then if lookup (g-ofc, sysc.chval) > 0 then return s_payment.

commonpl_rnnbn = entry(2,s_trx,'#') no-error.
commonls_bn = entry(3,s_trx,'#') no-error.
commonpl_rnn = entry(4,s_trx,'#') no-error.
commonpl_fioadr = entry(5,s_trx,'#') no-error.
s_trx = entry(1,s_trx,'#') no-error.

/* для кассовых транзакций данные в bksnmb не вставляются - так как по номерам можно найти RMZ, JOUDOC ит.д.*/
/*
if s_trx <> "TRX" then do:
create bksnmb.
update
        bksnmb.bks = time
        bksnmb.date = g-today
        bksnmb.info[1] = g-ofc
        bksnmb.info[2] = s_payment.

        d_bksnmb = bksnmb.bks.
end.
else
*/

d_bksnmb = entry(1,entry(1, s_payment, '|'),'#').
i_temp_dep = int (get-dep (g-ofc, g-today)).

find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt and depaccnt.rem <> '' then do:

  find first cmp no-lock no-error.
  find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
  if avail ppoint then
    s_depname = cmp.name + " " + ppoint.name.
  else
    s_depname = '***'.

  s_nknmb = entry(1,depaccnt.rem,'$').
  s_stadr = entry(2,depaccnt.rem,'$') + ' ' + entry(3,depaccnt.rem,'$').


  if entry(4,depaccnt.rem,'$') = "" then do:
    find first cmp no-lock no-error.
    s_rnn = cmp.addr[2].
  end.
  else
    s_rnn = entry(4,depaccnt.rem,'$').

end.
else do:
  s_nknmb = '***'.
  s_stadr = '***'.
end.

output to bks.img.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then
  v-ofcname = ofc.name.
else
  v-ofcname = "manager".

put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' chr(10). /*чтобы печатался сжатый файл. типа междустрочный интервал - минимальный.*/
put unformatted  "                 КОНТРОЛЬНЫЙ ЧЕК БКС N " d_bksnmb skip.
put unformatted s_depname skip.
put unformatted  "РНН: " s_rnn skip.
put unformatted  "Рег. номер БКС в НК: " s_nknmb  skip.
put unformatted  "Кассир: " v-ofcname skip.
put unformatted  string(g-today) " " string(time,"HH:MM:SS") skip.

/*k.gitalov*/
if s_trx = "COM" then do:
  put unformatted "Dok.Nr." commonpl_rnnbn skip.
  commonpl_rnnbn = "".
end.

IF commonpl_rnnbn <> "" or commonls_bn <> "" or commonpl_rnn <> "" or commonpl_fioadr <> "" THEN  do:
  put unformatted "Получатель: " commonpl_rnnbn format "x(12)" " " commonls_bn format "x(58)" skip.
  put unformatted "Отправитель: " commonpl_rnn format "x(12)" " " commonpl_fioadr format "x(58)" skip.
end.

put fill("=",78) format "x(78)" skip.

/*******************************************************************************************/
/* Новая версия */
function GetCodeCrc returns char (input currency as int):
  def var code as char format "x(3)".
  def buffer b-crc for crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
  return code.
end function.

/**/
i_entr_nmb = num-entries(s_payment,'|').
i = 1.
repeat while i <= i_entr_nmb:
  s_temp_first = entry(i, s_payment, '|').
  s_rowid = entry(1,s_temp_first,'#').
  s_nds = entry(5,s_temp_first,'#').

  if trim(s_nds) = "1" then do:
    for each jl where jl.jh = int(s_rowid) and string(jl.gl) begins '4' no-lock:
      find first sub-cod where sub-cod.d-cod = "ndcgl" and
        sub-cod.ccode = "01" and sub-cod.sub = "gld" and
        sub-cod.acc = string(jl.gl) no-lock no-error.
      if avail sub-cod then do:
        d_nds_tmp = d_nds_tmp + (jl.dam + jl.cam).
      end.
    end.
  end.
  i = i + 1.
end. /*repeat*/
/**/

  def var sumin as deci EXTENT 6.
  def var sumout as deci EXTENT 6.

  for each jl where jl.jh = int(d_bksnmb) and (jl.gl = 100100 or jl.gl = 100200 ) no-lock :
     if jl.cam = 0 then d_sum = jl.dam.
     else d_sum = jl.cam.

     if jl.dc = "D" then sumin[jl.crc] = sumin[jl.crc] + jl.dam.
     if jl.dc = "C" then sumout[jl.crc] = sumout[jl.crc] + jl.cam.

     put  d_bksnmb format "x(10)" " | " jl.rem[1] format "x(40)" " | " d_sum format ">>>>>>>>9.99" " | " GetCodeCrc(jl.crc) skip.
  end.

  put fill("=",78) format "x(78)" skip.

  put "x1E Общий итог по проведенным операциям:x0F"skip.
  def var cc as int init 1.
  repeat while cc <= 6:
    if sumin[cc] > 0 then put "x1E Приход -" sumin[cc] format ">>>>>>>>9.99" "  " GetCodeCrc(cc) "x0F"skip.
    cc = cc + 1.
  end. /*repeat*/
  cc = 1.
  repeat while cc <= 6:
    if sumout[cc] > 0 then put "x1E Расход -" sumout[cc] format ">>>>>>>>9.99" "  " GetCodeCrc(cc) "x0F"skip.
    cc = cc + 1.
  end. /*repeat*/

  put " " skip skip.
/*******************************************************************************************/
/* Старая версия */
/*
i_entr_nmb = num-entries(s_payment,'|').

i = 1.

repeat while i <= i_entr_nmb:

  s_temp_first = entry(i, s_payment, '|').

  s_rowid = entry(1,s_temp_first,'#').
  s_npl = entry(2,s_temp_first,'#').
  d_sum = decimal(entry(3,s_temp_first,'#')).
  p_comsum = decimal(entry(4,s_temp_first,'#')).
  s_nds = entry(5,s_temp_first,'#').
  s_currency = entry(6,s_temp_first,'#').

  if s_trx <> "TRX" then
    total_sum = total_sum + d_sum.


  put  s_rowid format "x(10)" " | " substr(s_npl,1,40) format "x(40)" " | " d_sum format ">>>>>>>>9.99" " | " s_currency skip.

  p_whole_comsum = p_whole_comsum + p_comsum.


  /*  - begin nds calculations - marina */

  if trim(s_nds) = "1" then do:

    for each jl where jl.jh = int(s_rowid) and string(jl.gl) begins '4' no-lock:

      find first sub-cod where sub-cod.d-cod = "ndcgl" and
        sub-cod.ccode = "01" and sub-cod.sub = "gld" and
        sub-cod.acc = string(jl.gl) no-lock no-error.

      if avail sub-cod then do:
        d_nds_tmp = d_nds_tmp + (jl.dam + jl.cam).
      end.

    end.

  end.

  /*  - end nds calculations - */
  i = i + 1.
end. /*repeat*/


if s_trx = "TRX" then  total_sum = d_sum.

p_whole_sum = total_sum + p_whole_comsum.

put fill("=",78) format "x(78)" skip.

if p_whole_comsum <> 0 then  put "КОМИССИЯ БАНКА: x1E" p_whole_comsum format ">>>>>>>>9.99" " " s_currency "x0F"skip.




put "ИТОГО: " p_whole_sum format ">>>>>>>>9.99" " " s_currency skip skip.
put " " skip.
*/
/*******************************************************************************************/



define variable conve as logical.
find first jh where jh.jh =  int(d_bksnmb) no-lock no-error.

conve = false.
for each jl of jh no-lock:
    if isConvGL(jl.gl) then do:
       conve = true.
       leave.
    end.
end.

if conve and jh.sub eq "jou" then do:
    find joudoc where joudoc.jh eq jh.jh no-lock.
    find d_crc where d_crc.crc eq joudoc.drcur no-lock.
    find c_crc where c_crc.crc eq joudoc.crcur no-lock.

    if d_crc.crc ne 1 then put "  " +
        d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
        " KZT/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
        d_crc.code format "x(80)" skip.

    if c_crc.crc ne 1 then put "  " +
        c_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
        " KZT/ " + trim (string (joudoc.sn, "zzzzzzz")) + " " +
        c_crc.code format "x(80)" skip.
end.
/***************************************************************/




/*  nds output information */

if d_nds_tmp <> 0 then do:

  put "Свидетельство о постановке на учет по НДС серия " ndssvi "г. "        skip.
  put " " skip.

  find first crc where crc.code = trim(s_currency) no-lock no-error.
  if avail crc then do:
    if crc.crc ne 1 then do:
      find last crchis where crchis.crc eq crc.crc and crchis.rdt le g-today no-lock no-error.
      d_nds_tmp = d_nds_tmp * crchis.rate[1] / crchis.rate[9].
    end.
  end.

  total_sum  = d_nds_tmp  / (1 + v-nds) * v-nds.

  put "                                              НДС 12% = " total_sum format ">>>>>>>>9.99" " KZT" skip.
end.

put " " skip(2).
put unformatted chr(27) chr(64). /*чтобы после окончания печати по кнопке SET на принтере FX-890 адекватно выезжадл и заезжал отступ для отрыва*/

output close.
unix silent prit bks.img.
