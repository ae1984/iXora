/* rpttransf.p
 * MODULE
        Название модуля
 * DESCRIPTION
        подготовка данных для отчета, сбор данных со всех филиалов для reptransf.p
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
        Luiza 26.01.11
 * BASES
        BANK COMM
 * CHANGES
*/


def shared var v-fil-cnt as int.
v-fil-cnt = v-fil-cnt + 1.
hide message no-pause.
message  "Ждите идет подготовка данных для отчета, филиал № " + string(v-fil-cnt).
def var vv-ofc as char.
def shared var v-dt1 as date.
def shared var v-dt2 as date.
define shared temp-table wrk no-undo
    field txb as char
    field ntxb as char
    field who as char
    field jdt as date
    field nofc as char
index ind1 is primary txb who.
def var v-cmp as char.
def var v-jlgl as int.

define temp-table jhjh no-undo
field jh as int.

for each txb.jl where txb.jl.jdt >= v-dt1 and txb.jl.jdt <= v-dt2 and txb.jl.dc = "C" and
    (txb.jl.gl = 287033 or txb.jl.gl = 287034 or txb.jl.gl = 287035 or txb.jl.gl = 287036 or txb.jl.gl = 287037) no-lock,
    txb.jh where txb.jh.jh = txb.jl.jh and substring( txb.jh.party,1,5) <> "storn".
    create jhjh.
    jhjh.jh = txb.jl.jh.
end.

def var v-jh as int no-undo.
def var s-ourbank as char no-undo.
find first txb.sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).
find first txb.cmp no-lock.
if available txb.cmp then v-cmp = trim(txb.cmp.name).
for each jhjh no-lock.
    v-jh = jhjh.jh.
    find first txb.jl where txb.jl.jh = v-jh and txb.jl.dc = "D" and (txb.jl.gl = 100100 or  txb.jl.gl = 100200) no-lock no-error.
    if available txb.jl then do:
        create wrk.
        wrk.txb = s-ourbank.
        wrk.ntxb = v-cmp.
        wrk.who = txb.jl.who.
        wrk.jdt = txb.jl.jdt.
        vv-ofc = txb.jl.who.
        find first txb.ofc where txb.ofc.ofc = vv-ofc no-lock.
        if available txb.ofc then do:
            wrk.nofc = trim(txb.ofc.name).
        end.
    end.
end.
empty temp-table jhjh.

