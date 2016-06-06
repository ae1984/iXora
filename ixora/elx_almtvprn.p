/* elx_almtvprn.p
 * MODULE
        Elecsnet
 * DESCRIPTION
        Печать ордера Alma TV
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        elx_aall.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        22/05/2006 dpuchkov
 * CHANGES
        12.02.2007 id00004 добавил alias
*/


{comm-txb.i}
def var ourbank as char.
def var ourlist as char init ''.
ourbank = comm-txb().
def input parameter rid as rowid.
def input parameter indoc as integer.

def var i as integer.
def var sum as char.

define variable ckv as int.

output to almatv.prn.

   /* счетчик квитанций */
/* find first almatv where rowid(almatv) = rid no-lock no-error. */
/* find last almatv where almatv.ndoc = indoc no-lock no-error. */
 find last comm.almatv where comm.almatv.ndoc = indoc use-index ndoc_dt_idx no-lock no-error.

if comm.almatv.uid = userid("bank") then do:
   find first comm.almatv where rowid(comm.almatv) = rid no-error.

   if available comm.almatv then do:
      ckv = ?.
      ckv = integer (comm.almatv.chval[5]) no-error.
      if ckv = ? then ckv = 0.
      ckv = ckv + 1.
      comm.almatv.chval[5] = string (ckv, "zzz9").
   end.
end.

/*find first almatv where rowid(almatv) = rid no-lock no-error. */
 find first mobi-almatv where rowid(mobi-almatv) = rid no-lock.
 /*find last almatv where almatv.ndoc = indoc no-lock no-error.*/
 find last comm.almatv where comm.almatv.ndoc = indoc use-index ndoc_dt_idx no-lock no-error.
if avail comm.almatv then do i = 1 to 2:
    run Sm-vrd(mobi-almatv.summ, output sum).
    put unformatted 

    fill ("=", 72) skip
    "АО TEXAKABANK (" + ourbank + ")" skip
    fill("-", 72) skip
    "Cчет АлмаТВ   : " comm.almatv.accnt format "99999999" " от " string(comm.almatv.dt) skip
    "Вноситель     : " trim(comm.almatv.f) " " trim(io) skip
    "Дата оплаты   : " string(mobi-almatv.dt) " " string(time,"HH:MM:SS") skip
    "Контракт No   : " comm.almatv.ndoc format "ALMATV99999999" skip
    "Адрес         : " trim(comm.almatv.address) " д." trim(string(house)) "  кв." trim(string(flat)) skip
    "Сумма, KZT    : " mobi-almatv.summ format "->>>>>>>>9.99" skip
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
