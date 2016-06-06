/* almtvprn.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Печать ордера Alma TV
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09.10.2003 sasco счетчик квитанций
*/

/* KOVAL настройка для филиалов */
{comm-txb.i}
def var ourbank as char.
def var ourlist as char init ''.
ourbank = comm-txb().
def input parameter rid as rowid.

def var i as integer.
def var sum as char.

define variable ckv as int.

output to almatv.prn.

   /* счетчик квитанций */
find first almatv where rowid(almatv) = rid no-lock no-error.
if almatv.uid = userid("bank") then do:
   find first almatv where rowid(almatv) = rid no-error.

   if available almatv then do:
      ckv = ?.
      ckv = integer (almatv.chval[5]) no-error.
      if ckv = ? then ckv = 0.
      ckv = ckv + 1.
      almatv.chval[5] = string (ckv, "zzz9").
   end.
end.

find first almatv where rowid(almatv) = rid no-lock no-error.
if avail almatv then do i = 1 to 2:
    run Sm-vrd(almatv.summfk, output sum).
    put unformatted 

    fill ("=", 72) skip
    "АО TEXAKABANK (" + ourbank + ")" skip
    fill("-", 72) skip
    "Cчет АлмаТВ   : " almatv.accnt format "99999999" " от " string(dt) skip
    "Вноситель     : " trim(almatv.f) " " trim(io) skip
    "Дата оплаты   : " string(dtfk) " " string(time,"HH:MM:SS") skip
    "Контракт No   : " ndoc format "ALMATV99999999" skip
    "Адрес         : " trim(address) " д." trim(string(house)) "  кв." trim(string(flat)) skip
    "Сумма, KZT    : " almatv.summfk format "->>>>>>>>9.99" skip
/*    "Сумма, USD    : " summfk format "->>>>>>>>9.99" skip
    "Комиссия банка: " round(summfk * 0.1 * cursfk, 0) format "->>>>>>>>9.99" */
    skip(3)
    "Итого прописью: " sum " тенге " + substr(trim(string(summfk,"->>>>>>>>>9.99")),
                                              length(trim(string(summfk,"->>>>>>>>>9.99"))) - 1, 2) + 
                     " тиын" skip(2)
    "Назначение    : Оплата услуг АЛМА-ТВ." skip(1)
    fill("-", 72) skip(2) fill("=", 72) skip(2).
end.

output close.

unix silent 'prit almatv.prn'.
