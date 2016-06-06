/* report2_txb.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Отчет по депозитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        TXB COMM
 * AUTHOR
        07/09/09 id00004
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{nbankBik-txb.i}
def input parameter pAccount as char no-undo.
def input parameter fromDate as date no-undo.
def input parameter toDate as date no-undo.
def input  parameter g_date as date no-undo.

def output parameter totalCount as integer no-undo.
def output parameter bankName as char no-undo.
def output parameter bankRNN as char no-undo.



def buffer b-aaa for txb.aaa.

totalCount = 0.
bankName = v-nbankru.
bankRNN = "600400585309" .

def shared temp-table t-report2 no-undo /* Отчет по движению денежных средств */
  field dtplat as date
  field startBalance as char
  field transactionType as char
  field amount as char
  field transactionOrder as char
  field bankComission as char.
    def var v-str as char.
    def var v-txb as char.
    def var sm as decimal.
    sm = 0.
    run lonbal3('cif', pAccount, fromDate - 1, "1", yes, output sm).


    find first comm.txb where comm.txb.bank = "TXB" + substr(pAccount,19,2) and comm.txb.consolid no-lock no-error.

    v-txb = replace(comm.txb.path,'/data/','/data/b').
    v-txb = substr(v-txb, 1, 6) + "log/" + substr(v-txb, 7, 5).






for each txb.jl where txb.jl.jdt >= fromDate and txb.jl.jdt <= toDate and txb.jl.acc = pAccount and txb.jl.lev = 1 no-lock:
    find first txb.jh where txb.jh.jh = jl.jh no-lock no-error.
    if not avail txb.jh then next.





    find first txb.remtrz where txb.remtrz.remtrz = txb.jh.ref no-lock no-error.
    if avail txb.remtrz then do:

     create t-report2.
            t-report2.amount = string(abs(txb.jl.dam - txb.jl.cam)).
             t-report2.dtplat = txb.jl.jdt.
             t-report2.startBalance = string(sm).
       totalCount = totalCount + 1.

            find first txb.remtrz where txb.remtrz.remtrz = txb.jh.ref no-lock no-error.
            if txb.remtrz.ptype = '5' or txb.remtrz.ptype = '7'  or txb.remtrz.ptype = '3' then do: /*входящие*/
                t-report2.transactionType = 'Приход'.
            end. else do:
                t-report2.transactionType = 'Расход'.
            end.
            t-report2.transactionOrder = trim( substring( txb.remtrz.sqn,19,8 )).
            t-report2.bankComission = '0.00' .
            if SEARCH(v-txb + "dclstarif" + string(year(remtrz.valdt1), "9999") + string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1), "99") + ".log") <> ? then do:
               input from value(v-txb + "dclstarif" + string(year(remtrz.valdt1), "9999") + string(month(remtrz.valdt1), "99") + string(day(remtrz.valdt1), "99") + ".log") .
               repeat :
                   import unformatted v-str.
                   if entry(10, v-str, "") = remtrz.remtrz then do:
                      t-report2.bankComission = entry(9, v-str, "").
                   end.

               end.
            end.
    end.
end.








procedure lonbal3.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:

            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
	    else res = res + txb.trxbal.cam - txb.trxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
/*	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end. */

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub
                              and txb.histrxbal.acc = p-acc
                              and txb.histrxbal.level = integer(entry(i, p-lvls))
                              and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                                 and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.



end.


