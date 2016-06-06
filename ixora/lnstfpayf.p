/*lnstfpayf.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет "График платежей по сотрудникам"
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
        08/11/2013 galina ТЗ1457
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter p-dt as date.
/*def shared var g-todate as date.*/
def shared temp-table wrk
field lon like txb.lon.lon
field bank as char
field clname as char
field dtpay as date
field sumod as deci
field sumproc as deci
field aaa as char
field pros as logi
index idx is primary bank dtpay lon.

def var v-bank as char.
def var v-availpros as logi.
def var v-sumpros as deci.
find first txb.cmp no-lock no-error.
if avail txb.cmp and txb.cmp.name <> '' then v-bank = txb.cmp.name.
else v-bank = ''.
for each txb.lon where (txb.lon.grp = 81 or txb.lon.grp = 82) and txb.lon.sts <> 'C' use-index grp no-lock:
    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    v-sumpros = 0.
    run lonbal_txb('lon',txb.lon.lon,p-dt,"7,9,4,16,5",yes,output v-sumpros).
    if v-sumpros > 0 then v-availpros = yes.

    find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > p-dt use-index lnsch-idx2 no-lock no-error.
    if avail txb.lnsch then do:
        create wrk.
        assign wrk.lon = txb.lon.lon
               wrk.bank = v-bank
               wrk.dtpay = txb.lnsch.stdat
               wrk.clname = txb.cif.name
               wrk.sumod = txb.lnsch.stval
               wrk.aaa = txb.lon.aaa
               wrk.pros = v-availpros.
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat = txb.lnsch.stdat no-lock no-error.
        if avail txb.lnsci then wrk.sumproc = txb.lnsci.iv-sc.
    end.
    else do:
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat > p-dt no-lock no-error.
        if avail txb.lnsci then do:
            create wrk.
            assign wrk.lon = txb.lon.lon
                   wrk.bank = v-bank
                   wrk.dtpay = txb.lnsci.idat
                   wrk.clname = txb.cif.name
                   wrk.sumproc = txb.lnsci.iv-sc
                   wrk.aaa = txb.lon.aaa
                   wrk.pros = v-availpros.
        end.
    end.
end.
