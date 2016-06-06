/* dcls66.p
 * MODULE
        Закрытие дня.
 * DESCRIPTION
        Возобновление начисления вознаграждения и неустойки в атоматическом режиме, при погашенных задолженностях на 2,9,16,4, и 5 уровнях.
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
        07.02.2006 Natalya D.
 * BASES
        BANK
 * CHANGES
        28/03/2006 Natalya D. - добавида обнуление v-prem1 & v-sods2 (на всякий случай)
        29/03/2006 Natalya D. - изменила: проверяеет остатки на 7 уровне( было на 2)
        31/03/2006 Natalya D. - добавила восстановление ставок из истории, в случае, если были обнулены в ручную
        07/04/2006 Natalya D. - при восстановлении из истории беруться последнии данные, т.к. может быть изменение %-ной ставки.
                                восстановление сохраняется в истории
        16/05/2006 Natalya D. - перед восстановлением %-ставки или штрафов, проверяется на признак "Начислять %" и "Начислять штрафы".
        29/08/2009 madiyar - не смотрим на наличие штрафов (16)
        02/09/2009 madiyar - проходим по кредитам с нулевой процентной ставкой; восстанавливаем штрафы только если они действительно обнулены
*/

{global.i}

def buffer b-lon for lon.
def buffer b-loncon for loncon.
def var v-bal7  as decimal format ">>>,>>>,>>9.99-" no-undo.
def var v-bal9  as decimal format ">>>,>>>,>>9.99-" no-undo.
def var v-bal4  as decimal format ">>>,>>>,>>9.99-" no-undo.
/*
def var v-bal16 as decimal format ">>>,>>>,>>9.99-" no-undo.
def var v-bal5  as decimal format ">>>,>>>,>>9.99-" no-undo.
*/
def var v-lon   like lon.lon no-undo.
def var old-prem like lon.prem no-undo.
def var old-sods like loncon.sods2 no-undo.
def var v-num as int init 0.
def stream s-err.
output stream s-err to dcls66.log.

for each b-lon where b-lon.prem = 0 no-lock:
    if abs(b-lon.dam[1] - b-lon.cam[1]) = 0 then next.
    assign v-bal7 = 0  v-bal9 = 0 v-bal4 = 0 /*v-bal16 = 0 v-bal5 = 0*/ old-prem = 0 old-sods = 0 v-num = 0 .
    v-lon = b-lon.lon.
    if b-lon.prem1 > 0 then old-prem = b-lon.prem1.
    else do:
       find last ln%his where ln%his.lon = b-lon.lon and ln%his.intrate <> 0 no-lock no-error.
       if avail ln%his then old-prem = ln%his.intrate.
       else old-prem = 0.
    end.

    find first b-loncon where b-loncon.lon = b-lon.lon no-lock no-error.
    if avail b-loncon then do:
        if b-loncon.sods2 > 0 then old-sods = b-loncon.sods2.
        else do:
           find last ln%his where ln%his.lon = b-lon.lon and ln%his.pnlt1 <> 0 no-lock no-error.
           if avail ln%his then old-sods = ln%his.pnlt1.
           else old-sods = 0.
        end.
    end.

    find trxbal where trxbal.acc = b-lon.lon and trxbal.subled = 'LON' and trxbal.level = 7 no-lock no-error.
    if avail trxbal then  v-bal7 = v-bal7 + (trxbal.dam - trxbal.cam).
    else v-bal7 = 0.

    find trxbal where trxbal.acc = b-lon.lon and trxbal.subled = 'LON' and trxbal.level = 9 no-lock no-error.
    if avail trxbal then  v-bal9 = v-bal9 + (trxbal.dam - trxbal.cam).
    else v-bal9 = 0.

    find trxbal where trxbal.acc = b-lon.lon and trxbal.subled = 'LON' and trxbal.level = 4 no-lock no-error.
    if avail trxbal then  v-bal4 = v-bal4 + (trxbal.dam - trxbal.cam).
    else v-bal4 = 0.
    /*
    find trxbal where trxbal.acc = b-lon.lon and trxbal.subled = 'LON' and trxbal.level = 16 no-lock no-error.
    if avail trxbal then v-bal16 = v-bal16 + (trxbal.dam - trxbal.cam).
    else v-bal16 = 0.

    find trxbal where trxbal.acc = b-lon.lon and trxbal.subled = 'LON' and trxbal.level = 5 no-lock no-error.
    if avail trxbal then  v-bal5 = v-bal5 + (trxbal.dam - trxbal.cam).
    else v-bal5 = 0.
    */
    if v-bal7 = 0 and v-bal9 = 0 and v-bal4 = 0 /* and v-bal16 = 0 and v-bal5 = 0*/ then do:

       find sub-cod where sub-cod.acc eq b-lon.lon and sub-cod.sub eq "LON" and sub-cod.d-cod eq "flagl" and sub-cod.ccode = '01' use-index dcod  no-lock no-error .
       if not avail sub-cod then do:
         do transaction:
            update lon set lon.prem = old-prem, lon.prem1 = 0 where lon.lon = b-lon.lon.
            find last ln%his where ln%his.lon = b-lon.lon no-lock no-error.
            if avail ln%his then v-num = ln%his.f0.
            create ln%his.
              ln%his.lon = b-lon.lon.
              ln%his.stdat = g-today.
              ln%his.intrate = old-prem.
              ln%his.rem = 'авт.восстановление'.
              ln%his.opnamt = b-lon.opnamt.
              ln%his.rdt = b-lon.rdt.
              ln%his.cif = b-lon.cif.
              ln%his.duedt = b-lon.duedt.
              ln%his.who = g-ofc.
              ln%his.whn = today.
              ln%his.f0 = v-num + 1.
            put stream s-err unformatted "LON:" b-lon.lon " old-prem: " old-prem skip.
         end.
       end.

       if avail b-loncon and b-loncon.sods1 = 0 then do:
           find sub-cod where sub-cod.acc eq b-lon.lon and sub-cod.sub eq "LON" and sub-cod.d-cod eq "lnpen" and sub-cod.ccode = "01" no-lock no-error.
           if not avail sub-cod then do:
               do transaction:
                  update loncon set loncon.sods1 = old-sods, loncon.sods2 = 0 where loncon.lon = b-lon.lon.
                  find last ln%his where ln%his.lon = b-lon.lon no-lock no-error.
                  if avail ln%his then v-num = ln%his.f0.
                  create ln%his.
                      ln%his.lon = b-lon.lon.
                      ln%his.stdat = g-today.
                      ln%his.intrate = old-prem.
                      ln%his.pnlt1 = old-sods.
                      ln%his.rem = 'авт.восстановление'.
                      ln%his.opnamt = b-lon.opnamt.
                      ln%his.rdt = b-lon.rdt.
                      ln%his.cif = b-lon.cif.
                      ln%his.duedt = b-lon.duedt.
                      ln%his.who = g-ofc.
                      ln%his.whn = today.
                      ln%his.f0 = v-num + 1.
                  put stream s-err unformatted "LON:" b-lon.lon " old-sods: " old-sods skip.
               end. /* transaction */
           end.
       end. /* if avail b-loncon and b-loncon.sods1 = 0 */
    end. /* if no debt */
end.
output stream s-err close.










