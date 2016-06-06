/* comm-esp-dat.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по комиссии за выпуск ЭЦП
 * RUN
        comm-esp
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.03.2012 aigul
 * BASES
        BANK TXB IB COMM
 * CHANGES
        04.05.2012 aigul - добавила Bases
*/
def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared temp-table wrk
    field fil as char
    field num as int
    field dt as date
    field client as char
    field usr as char
    field acc as char
    field ofc as char.
def var v-bank as char.
def buffer b-jl for txb.jl.

find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.

for each txb.jl where txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 and txb.jl.gl = 287082 no-lock:
    /*find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 and b-jl.dam <> 0 and b-jl.acc <> "" no-lock no-error.
    if not avail b-jl then next.*/
    if txb.jl.rem[1] = "Комиссия за выпуск электронной цифровой подписи (ЭЦП)" then do:
        create wrk.
        wrk.fil = v-bank.
        wrk.num = txb.jl.jh.
        wrk.dt = txb.jl.jdt.
        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
        if avail b-jl then do:
            find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
            if avail txb.aaa then do:
                find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif then do:
                    wrk.client = txb.cif.name.
                    find last webra where webra.cif = cif.cif and webra.jh = jl.jh no-lock no-error.
                    if avail webra then wrk.usr = webra.info[3] + " " + webra.info[1] + " " + webra.info[2].
                end.
            end.
            if b-jl.dam <> 0 then wrk.acc = b-jl.acc.
        end.

        find first txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
        if avail txb.ofc then wrk.ofc = txb.ofc.name.
        if wrk.client = "" then do:
            find first txb.joudoc where joudoc.jh = txb.jl.jh no-lock no-error.
            if avail txb.joudoc then wrk.client = txb.joudoc.info.
        end.
    end.
end.