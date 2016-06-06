/* ppen1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Отчет по полученным/возвращенным (списанным) штрафам
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
        23/07/2009 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        27/07/2009 madiyar - добавил в полученные штрафы счет 2799
        30/07/2009 madiyar - подправил неточность
*/

def shared temp-table wrk1 no-undo
    field bank as char
    field bank_city as char
    field jh as integer
    field jdt as date
    field amt as deci
    field who as char
    index idx is primary bank jh.

def shared temp-table wrk2 no-undo
    field bank as char
    field bank_city as char
    field jh as integer
    field jdt as date
    field amt as deci
    field who as char
    index idx is primary bank jh.

def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.

def buffer b-jl for txb.jl.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

def var v-city as char no-undo.
find first txb.cmp no-lock no-error.
if avail txb.cmp then v-city = entry(1,txb.cmp.addr[1]).

if s-ourbank = "txb00" then v-city = "ЦО".

for each txb.jl where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 and txb.jl.gl = 186050 and txb.jl.dc = 'C' no-lock:
    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
    if avail b-jl then do:
        if b-jl.gl = 490000 then do:
            create wrk2.
            assign wrk2.bank = s-ourbank
                   wrk2.bank_city = v-city
                   wrk2.jh = txb.jl.jh
                   wrk2.jdt = txb.jl.jdt
                   wrk2.amt = txb.jl.cam
                   wrk2.who = txb.jl.who.
        end.
        else
        if lookup(substring(string(b-jl.gl),1,4),"2203,2204,2205,2799") > 0 then do:
            create wrk1.
            assign wrk1.bank = s-ourbank
                   wrk1.bank_city = v-city
                   wrk1.jh = txb.jl.jh
                   wrk1.jdt = txb.jl.jdt
                   wrk1.amt = txb.jl.cam
                   wrk1.who = txb.jl.who.
        end.
    end.
end.
