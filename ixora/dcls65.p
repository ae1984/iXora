/* dcls65.p
 * MODULE
        Закрытие дня.
 * DESCRIPTION
        Автоматизация изменения имеющейся % ставки и штрафа на 0, по истечении 30 калнд.дня с даты просрочки.
 * RUN
        dayclose.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        dayclose.p
 * AUTHOR
        06.01.2006 Natalya D.
 * BASES
        BANK
 * CHANGES
        07/04/2006 Natalya D. - обнуление ставок сохраняется в истории
        02/09/2009 madiyar - обнуление ставки по штрафам - по всем кредитам, кроме экспресс
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
        09/06/2010 galina - убрала обнуление ставки по штрафам
        13/01/2011 madiyar - убрал запись в историю обнуления ставки по штрафам (которое все равно выключено)
*/

{global.i}
def var v-date as date init today.
def var p-maxpr as integer no-undo.
def var old_prem as decimal no-undo.
def var old_sods1 as decimal no-undo.
def var v-bal   as deci init 0.
def var v-num as int init 0.
def buffer blon for lon.
def buffer bloncon for loncon.

def stream s-err.
output stream s-err to dcls65.log.

p-maxpr = 0.


for each blon where blon.prem > 0 no-lock:
    assign v-bal = 0 p-maxpr = 0 old_prem = 0 old_sods1 = 0 v-num = 0 .
    run lonbalcrc('lon',blon.lon,g-today,"7",yes,blon.crc,output v-bal).
    if v-bal > 0 then do: /*run delaylon(blon.lon, output p-maxpr)*/
       find londebt where londebt.lon = blon.lon no-lock no-error.
       if not avail londebt then next.
       p-maxpr = londebt.days_od.
    end.
    else next.

    if p-maxpr > 30 then do:
        assign old_prem  = blon.prem.
        find bloncon where bloncon.lon = blon.lon no-lock no-error.
        assign old_sods1 = bloncon.sods1.
        do transaction:
           update lon set prem1 = old_prem, prem = 0 where lon.lon = blon.lon.
           find last ln%his where ln%his.lon = blon.lon no-error.
           if avail ln%his then v-num = ln%his.f0.
           create ln%his.
                  ln%his.lon = blon.lon.
                  ln%his.stdat = g-today.
                  ln%his.intrate = 0.
                  ln%his.rem = 'авт.обнуление'.
                  ln%his.opnamt = blon.opnamt.
                  ln%his.rdt = blon.rdt.
                  ln%his.cif = blon.cif.
                  ln%his.duedt = blon.duedt.
                  ln%his.who = g-ofc.
                  ln%his.whn = today.
                  ln%his.f0 = v-num + 1.
           /* обнуление ставки по штрафам - по всем кредитам, кроме экспресс */
           /*
           if blon.grp <> 90 and blon.grp <> 92 then do:
               --update loncon set loncon.sods2 = old_sods1, loncon.sods1 = 0 where loncon.lon = blon.lon.--
               create ln%his.
                      ln%his.lon = blon.lon.
                      ln%his.stdat = g-today.
                      ln%his.pnlt1 = bloncon.sods1.
                      ln%his.rem = 'Начисление штрафов на внебаланс (просрочка ОД > 30 дней)'.
                      ln%his.opnamt = blon.opnamt.
                      ln%his.rdt = blon.rdt.
                      ln%his.cif = blon.cif.
                      ln%his.duedt = blon.duedt.
                      ln%his.who = g-ofc.
                      ln%his.whn = today.
                      ln%his.f0 = v-num + 2.
           end.
           */
        end.
        put stream s-err unformatted "LON:" blon.lon " max day:" p-maxpr " old prem:" old_prem.
        if blon.grp <> 90 and blon.grp <> 92 then put stream s-err unformatted " old sods1:" old_sods1.
        put stream s-err unformatted skip.
    end.
end.
output stream s-err close.

