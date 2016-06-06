/* lnrptprc.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Выписка по процентам
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
        07/07/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "Не найден ссудный счет!" view-as alert-box error.
    return.
end.

def temp-table wrk no-undo
  field cif like cif.cif
  field lon like lon.lon
  field jdt as date
  field jh as integer
  field who as char
  field dtgl as integer
  field ctgl as integer
  field amt as deci
  field rem as char
  index idx is primary jdt.

def buffer b-jl for jl.

def var v-sum0 as deci no-undo.
def var v-sum as deci no-undo.
def var v-dt as date no-undo.
v-sum0 = 0.
v-dt = lon.rdt - 1.

def var gl2 as integer no-undo.
def var gl11 as integer no-undo.
find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = 2 no-lock no-error.
if avail trxlevgl then gl2 = trxlevgl.glr.
find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = 11 no-lock no-error.
if avail trxlevgl then gl11 = trxlevgl.glr.

for each histrxbal where histrxbal.sub = 'lon' and histrxbal.acc = lon.lon and histrxbal.lev = 2 no-lock:
    v-sum = histrxbal.dam - histrxbal.cam - v-sum0.
    for each jl where jl.sub = "lon" and jl.acc = lon.lon and jl.lev = 2 and jl.jdt > v-dt and jl.jdt <= histrxbal.dt no-lock:
        create wrk.
        assign wrk.cif = lon.cif
               wrk.lon = lon.lon
               wrk.jdt = jl.jdt
               wrk.jh = jl.jh
               wrk.who = jl.who
               wrk.rem = trim(trim(jl.rem[1]) + " " + trim(jl.rem[2]) + " " + trim(jl.rem[3]) + " " + trim(jl.rem[4]) + " " + trim(jl.rem[5])).
        if jl.dc = "d" then do:
            assign wrk.dtgl = jl.gl wrk.amt = jl.dam v-sum = v-sum - jl.dam.
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
            if avail b-jl then wrk.ctgl = b-jl.gl.
        end.
        else do:
            assign wrk.ctgl = jl.gl wrk.amt = jl.cam v-sum = v-sum + jl.cam.
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln - 1 no-lock no-error.
            if avail b-jl then wrk.dtgl = b-jl.gl.
        end.
    end.

    if v-sum <> 0 then do:
        create wrk.
        assign wrk.cif = lon.cif
               wrk.lon = lon.lon
               wrk.jdt = histrxbal.dt
               wrk.dtgl = gl2
               wrk.ctgl = gl11
               wrk.amt = v-sum
               wrk.rem = "Автоматическое начисление".
    end.

    v-sum0 = histrxbal.dam - histrxbal.cam.
    v-dt = histrxbal.dt.
end.

def stream rep.
output stream rep to rep.csv.

put stream rep unformatted "Код клиента;Сс.счет;Дата;jh;id;СчетДт;СчетКт;Сумма;Примечание" skip.

for each wrk no-lock:
    put stream rep unformatted
        wrk.cif ";"
        "`" wrk.lon ";"
        string(wrk.jdt,"99/99/9999") ";"
        wrk.jh ";"
        wrk.who ";"
        wrk.dtgl ";"
        wrk.ctgl ";"
        replace(trim(string(wrk.amt,"->>>>>>>>>>>9.99")),'.',',') ";"
        replace(wrk.rem,";",",") skip.
end.

output stream rep close.
unix silent cptwin rep.csv excel.

