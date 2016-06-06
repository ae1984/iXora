/* dubltrx.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Проводка - комиссия за дубликат квитанции
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        11.12.2003 sasco
 * CHANGES
        13.12.2003 sasco добавил формирование jou_doc
        21.11.2005 dpuchkov добавил формирование корешка для дубликатов
        01.02.2012 lyubov - изменила символ кассплана (200 на 100)
*/

{global.i}
{comm-txb.i}

define input parameter sum as decimal.
define input parameter cgl as integer.
define input parameter npl as character.

define new shared variable s-jh like jh.jh.

run trx(
        5,
        sum,
        1,
        100100,
        '',
        cgl,
        '',
        npl,
        '19','14','890').

if return-value = '' then undo, return.

s-jh = int(return-value).


 define var v-chk as char.
 define buffer b-ofc for ofc.
 find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
 if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/
       find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
       if not avail acheck then do:
          v-chk = "".
          v-chk = string(NEXT-VALUE(krnum)).
          create acheck.
                 acheck.jh  = string(s-jh).
                 acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                 acheck.dt = g-today.
                 acheck.n1 = v-chk.
         release acheck.
       end.
 end.




/* СИМВОЛ КАСПЛАНА */
run setcsymb (s-jh, 100).

run jou.

 find last b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
 if comm-txb() = "txb00" then do:
    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
    if avail acheck then do:
       run vou_bank2(2,1, "").
    end.
    else do:
      run vou_bank(2).
    end.
 end.
 else do:
      run vou_bank(2).
 end.










