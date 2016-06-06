/* compils1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчёт по суммам свыше 5 млн тенгедля комплаенс контроля
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        TXB COMM

 * AUTHOR
     04.09.2009 id0004

 * CHANGES
     17.01.11 evseev - добавил группы для учета счетов Недропользователь 518,519,520
     23.05.2011 evseev - исправил ,520") <> no-lock: на ,520") <> 0 no-lock:
     01/06/2011 evseev - добавил группы A22 A23 A24
     24.05.2013 evseev - tz-1844
     10.06.2013 evseev - tz-1845

*/


define var t-amt as decimal.
define var sm as decimal.
define var v-operation as char.
define shared var d_date as date.
define shared var d_date_fin as date.
define shared var g_date as date.
def buffer b-aaa for txb.aaa.
def buffer b-jl for txb.jl.






function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for txb.crchis.
define buffer bcrc2 for txb.crchis.



if d1 = 10.01.08 or d1 = 12.01.08 then do:
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.

end.
do:
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end.


end.


find last txb.sysc where txb.sysc.sysc = "citi" no-lock no-error.


                        put unformatted "<P><b>" txb.sysc.chval "</b><br>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:E3E3FA "">" skip
        "<TD>Дата</TD>" skip
        "<TD>Сумма операции</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Наименование клиента</TD>" skip
        "<TD>Назначение платежа</TD>" skip
        "<TD>Наименование операции</TD>" skip
        "</TR>" skip.



    for each txb.lgr where lookup(txb.lgr.lgr, "A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A01,A02,A03,A04,A05,A06,A28,A29,A30,A34,A35,A36,A31,A32,A33,202,204,222,208,246,151,153,171,157,152,154,172,158,173,174,478,479,480,481,482,483,484,485,486,487,488,489,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 no-lock:
        for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr no-lock:
            find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            find last txb.crc where  txb.crc.crc = txb.aaa.crc no-lock no-error.
            for each b-jl where b-jl.acc = txb.aaa.aaa and b-jl.lev = 1 and b-jl.jdt >= d_date and b-jl.jdt <= d_date_fin no-lock use-index acc :
                t-amt = 0.
                t-amt = if b-jl.dc = "D" then b-jl.dam else b-jl.cam.

                sm = 0.
                sm = round(crc-crc-date(decimal(t-amt), txb.aaa.crc, 1, b-jl.jdt - 1),2).


                if sm >= 5000000 then do:
                if b-jl.dc = "D" then v-operation = 'Расход' .
                  else v-operation = 'Приход'.


                put unformatted "<tr valign=top style=""background:"  "FCFCFC " """>" skip.
                put unformatted
                    "<td>" b-jl.jdt  "</td>" skip
                    "<td>" string((t-amt) ,"-zzz,zzz,zz9.99")   "</td>" skip
                    "<td>" txb.crc.code   "</td>" skip
                    "<td>" txb.cif.name   "</td>" skip
                    "<td>" b-jl.rem[1] + b-jl.rem[2] + b-jl.rem[3] + b-jl.rem[4] "</td>" skip
                    "<td>" v-operation "</td>" skip
                    "</TR>" skip.
end.
            end.
        end.
    end.

    put unformatted        "</table>" skip.


















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

            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
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
	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end.

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
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
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
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
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

