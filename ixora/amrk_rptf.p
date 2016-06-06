/* amrk_rptf.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет для проверки амортизации комиссии
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        amrk_rpt.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        kapar
 * BASES
	    COMM TXB
 * CHANGES
        07/03/2012 madiyar - исправил расчет
        01/11/2013 galina - ТЗ1897 42 уровень берем в валюте кредита
*/

def shared temp-table lnpr no-undo
  field fname    as   char
  field cname    as   char
  field ndog     as   char
  field lon      as   char
  field nsum     as   decimal
  field ksum     as   decimal
  field gsum     as   decimal
  field rsum     as   decimal.

def shared var dt as date.

def var s-rdt as date no-undo.
def var v-takeall as logi no-undo.
def var v-bal as deci no-undo.
def var v-duedt as date no-undo.
def var v-lev1 as integer no-undo.
v-lev1 = 42. /* 1434 */
def var v-lev2 as integer no-undo.
v-lev2 = 31. /* 4434 */
def var v-comopl as deci no-undo.
def var v-comopl_grf as deci no-undo.
def var v-com_trx as deci no-undo.
def var v-com_rnd as deci no-undo.
def var v-com42 as deci no-undo.
def var v-sumcom_full as deci no-undo.
def var v-fname as char no-undo.
def var v-cname as char no-undo.
def var v-ndog as char no-undo.

def temp-table t-grfcom no-undo
    field dt as date
    field com as deci
    index idx is primary dt.

/* функция get-com возвращает сумму комиссии, которая должна быть самортизирована на сегодня */
function get-com returns deci (input p-date as date, input p-rdt as date).
    def var v-sumres as deci no-undo.
    def var v-dtlast as date no-undo.
    def var v-days as integer no-undo.
    v-sumres = 0. v-dtlast = p-rdt.
    for each t-grfcom where t-grfcom.dt <= p-date:
        v-sumres = v-sumres + t-grfcom.com.
        v-dtlast = t-grfcom.dt.
    end.
    v-days = p-date - v-dtlast.
    find first t-grfcom where t-grfcom.dt > p-date no-error.
    if avail t-grfcom then v-sumres = v-sumres + v-days * t-grfcom.com / (t-grfcom.dt - v-dtlast).
    return (v-sumres).
end function.


v-fname = ''.
find first txb.cmp no-lock no-error.
if avail txb.cmp then v-fname = txb.cmp.name.

for each txb.lon no-lock:

    if txb.lon.opnamt <= 0 then next.
    if txb.lon.rdt >= dt then next.
    if year(txb.lon.rdt) < 2011 then next.

    v-takeall = no.
    v-duedt = txb.lon.duedt.
    if txb.lon.ddt[5] <> ? then v-duedt = txb.lon.ddt[5].
    if txb.lon.cdt[5] <> ? then v-duedt = txb.lon.cdt[5].
    if v-duedt < dt then v-takeall = yes.
    else do:
        if txb.lon.gua = "CL" then do: /* !!!!!!!!!!!!!!!!!!!!!!!!! */
            find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = lon.lon and txb.sub-cod.d-cod = 'clsarep' no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-takeall = yes.
        end.
        else do:
            run lonbal_txb('lon',txb.lon.lon,dt,"1,7,2,9,16,4,5",no,output v-bal).
            if v-bal <= 0 then v-takeall = yes.
        end.
    end.

    if v-takeall then next.

    find first txb.lnscc where txb.lnscc.lon = txb.lon.lon and txb.lnscc.stdat > dt no-lock no-error.
    if not avail txb.lnscc then next.

    v-cname = ''.
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then v-cname = txb.cif.name.

    v-ndog = ''.
    find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if avail txb.loncon then v-ndog = txb.loncon.lcnt.

    s-rdt = txb.lon.rdt.
    find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
    if avail txb.lnscg and txb.lnscg.stdat <> s-rdt then s-rdt = txb.lnscg.stdat.


    v-sumcom_full = 0.
    empty temp-table t-grfcom.
    for each txb.lnscc where txb.lnscc.lon = txb.lon.lon no-lock:
        v-sumcom_full = v-sumcom_full + txb.lnscc.stval.
        create t-grfcom.
        assign t-grfcom.dt = txb.lnscc.stdat
               t-grfcom.com = txb.lnscc.stval.
    end.

    /* рассчитаем сумму, которая должна быть самортизирована на dt по графику */
    v-comopl_grf = get-com(dt, s-rdt).
    /* и реально самортизированную */
    run lonbalcrc_txb('lon',txb.lon.lon,dt,string(v-lev1),no,txb.lon.crc,output v-com42).
    v-com42 = - v-com42.
    v-comopl = v-sumcom_full - v-com42. /* фактический несамортизированный остаток комиссии */
    v-com_trx = v-comopl_grf - v-comopl.

    create lnpr.
     lnpr.fname = v-fname.
     lnpr.cname = v-cname.
     lnpr.ndog = v-ndog.
     lnpr.lon = txb.lon.lon.
     lnpr.nsum = v-sumcom_full.
     lnpr.ksum = v-com42.
     lnpr.gsum = v-comopl_grf.
     lnpr.rsum = v-com_trx.

end. /* for each txb.lon */

