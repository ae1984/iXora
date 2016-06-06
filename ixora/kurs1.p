/* kurs1.p
 * MODULE
         ГБ отчетность
 * DESCRIPTION
         Курсовая разница за период
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        14/08/10 marina
 * CHANGES
        25/10/2012 madiyar - исключил кроме счета 1858 еще счета 1859, 2858, 2859
*/


def shared temp-table wrk
  field gl       like bank.gl.gl
  field dt       as date
  field sum1     as deci  format "->>>,>>>,>>>,>>9.99"
  field sum2     as deci  format "->>>,>>>,>>>,>>9.99"
  field diff     as deci  format "->>>,>>>,>>>,>>9.99".

def shared var d1 as date.
def shared var d2 as date.

pause 0.
hide message.
find first txb.cmp.
message cmp.name.


define buffer b-crchis for txb.crchis.

def var vdt as date.

for each txb.gl where  txb.gl.gl < 300000 and txb.gl.totlev = 1 no-lock:
    if txb.gl.gl >= 185800 and txb.gl.gl <= 185999 then next.
    if txb.gl.gl >= 285800 and txb.gl.gl <= 285999 then next.
    do vdt = d1 to d2:
       for each txb.crc where txb.crc.sts ne 9 no-lock:
         find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= vdt no-lock no-error.
            if avail txb.glday and txb.glday.bal ne 0 then do:
                find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= vdt no-lock no-error.
                find last b-crchis where b-crchis.crc = glday.crc and b-crchis.rdt <= vdt - 1 no-lock no-error.
                if not avail b-crchis then message glday.crc.
                find first wrk where wrk.gl = txb.gl.gl /*and wrk.dt = vdt*/ no-lock no-error.
                if not avail wrk then do:
                   create wrk.
                   wrk.gl = txb.gl.gl.
                  /* wrk.dt = vdt .*/
                end.
                wrk.sum1 = wrk.sum1 + b-crchis.rate[1] * txb.glday.bal .
                wrk.sum2 = wrk.sum2 + crchis.rate[1] * txb.glday.bal.
         /*       displ wrk.gl wrk.dt wrk.sum1 wrk.sum2.*/
            end.
       end.
    end.
end.

