/* dcls21.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09.12.05 dpuchkov выплату по новым депозитам юр лиц перенес в др пункт.
*/

/* aipay.p
   10-14-90 created by Simon Y. Kim
*/
{proghead.i "PAY ACCRUED INTEREST "}
define new shared var s-jh like jh.jh.
def var s-amt as dec.
def var v-trx85 as log.
def var v-likme like aax.pct.
def var v-geo as char.
def var v-param as char.
def var vdel as char initial "^".
def var v-templ as char.
def var rcode as int.
def var rdes as char.

define buffer bb-sysc for sysc.
find last bb-sysc where bb-sysc.sysc = "JUR" no-lock no-error.

def stream s-err.
output stream s-err to value("aipay" + 
string(day(g-today),"99") +
string(month(g-today),"99") +
string(year(g-today),"9999") + ".err").
 for each lgr where /* lgr.accgl ne 0 and */
/*<ja-tda6>*/
                   lgr.led <> "TDA" and 
/*</ja-tda6>*/
                  (lgr.intpay eq "M" or
                   lgr.intpay eq "Q" and month(g-today) mod 3 eq 0)
   , each aaa of lgr where   aaa.accrued gt 0
                   break by aaa.crc by aaa.lgr:
    if first-of(aaa.lgr) then do :
        v-trx85 = yes.
        find aax where aax.lgr eq lgr.lgr and aax.ln eq 85 no-lock no-error.
        if available aax then v-likme = aax.pct.
        else v-trx85 = no.
    end.
    s-amt = aaa.cr[2] - aaa.dr[2].
    v-templ = "DCL0005".
    v-param = string(s-amt) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999").
    s-jh = 0.
if lookup(lgr.lgr,bb-sysc.chval) = 0 then do:
    run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa , output rcode, 
    output rdes, input-output s-jh).

    if rcode ne 0 then do:
        put stream s-err unformatted 
        aaa.aaa ", " string(s-amt) " -> " rdes skip.
        undo, next.
    end.
end. 
    /* ------------------- NNR ----------------------- */
    if v-trx85 then do:
        find cif where cif.cif eq aaa.cif no-lock.
        
        if length(cif.geo) gt 0 then
        v-geo = substring(cif.geo,length(cif.geo),1). else v-geo = "".
        
        /*
        substring(string(integer(cif.geo),"999"),3,1).
        */

        if (v-geo eq "2" or v-geo eq "3")
            and substring(cif.lgr,1,1) eq "Y" then do:
            s-amt = round(s-amt * v-likme / 100.00, 2).
            if s-amt gt 0 then do:
                v-templ = "CIF0002".
                v-param = string(s-amt) + vdel + aaa.aaa.
                run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa , 
                output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    put stream s-err unformatted 
                    aaa.aaa ", " string(s-amt) " , TAX -> " rdes skip.
                    undo, next.
                end.
            end.
        end.
    end.
    /* ----------------------------------------------- */

    aaa.accrued = 0.

  end.  /* for each ,lgr aaa */
  return.
