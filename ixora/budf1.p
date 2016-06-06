/* budf1.p.p
 * MODULE
        расчет фактических расходов
 * DESCRIPTION
        расчет фактических расходов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        14/07/2012 Luiza
 * BASES
	COMM TXB
 * CHANGES
                11/06/2012 Luiza
*/



define input parameter v-date as date.
define input parameter v-date2 as date.
define input parameter v-txt1 as char.
/*define input parameter v-gl2 as int.*/
def shared var v-year   as int.

/*define shared temp-table r-gl no-undo
field gl as int.*/

def var v-des as char no-undo.
def var v-dxd as decimal no-undo.
def var dt as date  no-undo.

def var v-dep as char no-undo.
def var v-code as char no-undo.
def var v-rate as decimal no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
find first txb.cmp no-lock no-error.
displ  ("Ждите идет расчет за " + v-txt1 + " " + txb.cmp.name) format "x(60)" WITH FRAME a overlay COLUMN 10 ROW 10 width 90.
pause 0.
do dt = v-date to v-date2:
    /*for each r-gl.*/
        for each txb.gl where (lookup(substring(string(txb.gl.gl),1,4),"5781,5782,5783,5787,5788,5761,5763,5764,5765,5766,5768,5767,5799") > 0
            or lookup(string(txb.gl.gl),"572151,572161,572171,572153,572940,572910,572930,572210") > 0) no-lock.

            for each txb.jl  no-lock where txb.jl.jdt = dt and txb.jl.gl = txb.gl.gl use-index jdt.

                if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
                if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

                find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx  no-lock no-error.
                if not avail txb.trxcods then next.
                for each txb.trxcods no-lock where txb.trxcods.trxh = txb.jl.jh  and txb.trxcods.trxln = txb.jl.ln and  txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx .

                    find last txb.crchis where txb.crchis.crc = txb.jl.crc
                    and txb.crchis.rdt <= dt   use-index crcrdt no-lock no-error.
                    if not available txb.crchis then do:
                    v-rate =  1.
                    end.
                    else do:
                    v-rate =  txb.crchis.rate[1].
                    end.

                    v-dxd = (txb.jl.dam * v-rate) - (txb.jl.cam * v-rate).

                    find first budget where budget.year = v-year and budget.gl = txb.jl.gl and budget.coder = substr(txb.trxcods.code,1,7) + trim(txb.sysc.chval) exclusive-lock no-error.
                    if avail budget then do:
                        if budget.fact[month(v-date)] + v-dxd <= budget.plan[month(v-date)] then
                                        budget.fact[month(v-date)] = budget.fact[month(v-date)] + v-dxd.
                        else budget.budget[month(v-date)] = budget.budget[month(v-date)] + v-dxd.
                    end.

                    /*find first budget where budget.year = v-year and budget.gl = txb.jl.gl and substring(budget.coder,1,7) begins substr(txb.trxcods.code,1,7) and budget.txb begins "TXB00" and not substr(txb.trxcods.code,8,5) begins "TXB"  exclusive-lock no-error.
                    if avail budget then do:
                        if budget.fact[month(v-date)] + v-dxd <= budget.plan[month(v-date)] then
                                        budget.fact[month(v-date)] = budget.fact[month(v-date)] + v-dxd.
                        else budget.budget[month(v-date)] = budget.budget[month(v-date)] + v-dxd.

                    end.*/
                    find first budget where budget.year = v-year and budget.gl = txb.jl.gl and substring(budget.coder,1,7) begins substr(txb.trxcods.code,1,7) and budget.txb begins "___" exclusive-lock no-error.
                    if avail budget then do:
                        if budget.fact[month(v-date)] + v-dxd <= budget.plan[month(v-date)] then
                                        budget.fact[month(v-date)] = budget.fact[month(v-date)] + v-dxd.
                        else budget.budget[month(v-date)] = budget.budget[month(v-date)] + v-dxd.
                    end.
                end. /*txb.trxcods*/

            end. /* jl */
        end. /*gl*/
    /* end.  r-gl*/
end. /*dt*/
hide frame a.
