/* r-fsvz.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Полученные и непогашенные внешние заимствования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.8.2.
 * AUTHOR
        27.12.2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES

*/

def shared var v-dt as date.
def shared var v-reptype as integer no-undo.
def shared var v-prov_type as integer no-undo.
v-reptype = 1.
v-prov_type = 1.

def shared temp-table wrk
   field cif as char
   field cifname as char
   field country as char
   field lontype as char
   field object  as char
   field gl as int
   field bal as deci
   field crc as int
   field amt as deci
   field ost as deci
   field opndt as date
   field duedt as date
   field prolong as date
   field rate as deci
   field month-cr as deci.


def var summm as decimal extent 5.
def var profit as decimal extent 4.
def var v-branch as char.
def var v-bankn   as char no-undo.
def var i as int.
def var vbegin-bal as deci.
def var v-dr as deci.
def var v-cr as deci.

def var v-gllist as char init "2054|2056|2064|2066|2401|2402|2406|2301|2303|2306|2255".

for each txb.gl where index(v-gllist, substr(string(txb.gl.gl),1,4)) > 0 and txb.gl.gl > 0 no-lock:
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc no-lock no-error.
        if avail txb.glday and txb.glday.bal <> 0  then do:
            for each txb.aaa where txb.aaa.gl = txb.gl.gl no-lock:
                find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif and substr(txb.cif.geo, 3,1) = "2" then do:
                    find last txb.histrxbal where txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.sub = txb.gl.sub no-lock no-error.
                    if avail txb.histrxbal then do:
                        run lonbalcrc_txb('cif',txb.aaa.aaa,v-dt,"1,7",yes,txb.aaa.crc,output vbegin-bal).
                        create wrk.
                        wrk.cif  = txb.cif.cif.
                        wrk.cifname = txb.cif.name.
                        wrk.country = entry(1, txb.cif.addr[1], ",").
                        wrk.gl = txb.gl.gl.
                        wrk.bal = txb.histrxbal.dam - txb.histrxbal.cam.
                        wrk.crc = txb.crc.crc.
                        wrk.opndt = txb.aaa.regdt.
                        wrk.duedt = txb.aaa.expdt.
                        wrk.amt = txb.aaa.cr[1] - txb.aaa.dr[1].
                        wrk.ost = aaa.cbal - aaa.hbal.
                        wrk.rate = txb.aaa.rate.

                        v-cr = 0. v-dr = 0.
                        for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.jdt >= date(month(v-dt), 1, year(v-dt)) and txb.jl.jdt <= v-dt no-lock:
                            if txb.jl.dc = "D" then v-dr = v-dr + txb.jl.dam.
                            if txb.jl.dc = "C" then v-cr = v-cr + txb.jl.cam.
                        end.
                        wrk.month-cr = v-cr - v-dr.
                    end.
                end.
            end.
        end.
    end.
end.
