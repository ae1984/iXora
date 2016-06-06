/* finkoef.p
 * MODULE
        Финансовые коэффициенты
 * DESCRIPTION
        Дополнительные данные по клиентам
 * BASES
        BANK TXB
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        01/04/2013 Luiza ТЗ № 1504
 * CHANGES
        23/05/2013 Luiza ТЗ № 1775 отчет.
        24/05/2013 Luiza - перекомпиляция

*/


def  var v-bank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc and txb.sysc.chval <> '' then v-bank = txb.sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.
find first txb.cmp no-lock no-error.
if available txb.cmp then display 'Ждите идет сбор данных по ' + txb.cmp.name format "x(40)" with row 8 width 80 frame ww centered .
pause 0.
def shared temp-table wrk no-undo
    field idotr as int
    field otr   as char
    field code1 as char
    field code2 as char.

def shared temp-table lst no-undo
    field txb     as char
    field fil     as char
    field code    as decim
    field idotr   as int
    field cif     as char
    field name    as char
    field otr     as char
    field period  as char
    field speed   as decim
    field profit  as decim
    field margin  as decim
    field aspeed  as decim
    field aprofit as decim
    field price   as decim
    field rem     as char.


for each txb.cif no-lock.
    find first txb.finkoef where txb.finkoef.cif = txb.cif.cif no-lock no-error.
    if available txb.finkoef then do:
        create lst.
        lst.txb     = v-bank.
        lst.cif     = txb.cif.cif.
        lst.name    = txb.cif.prefix + " " + txb.cif.name.
        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivisg' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod and trim(txb.sub-cod.ccode) <> "msc" then do:
            lst.code = decim(trim(txb.sub-cod.ccode)).
            for each wrk no-lock.
                if num-entries(trim(wrk.code1)) > 0 then do:
                    if (decim(trim(txb.sub-cod.ccode)) >= decim(entry(1,trim(wrk.code1))) and decim(trim(txb.sub-cod.ccode)) <= decim(entry(2,trim(wrk.code1)))) then do:
                        /* для 68.2 и 77 код отрасли проставляем 5 */
                        if (decim(trim(txb.sub-cod.ccode)) >= 68.20 and decim(trim(txb.sub-cod.ccode)) <= 68.29) or (decim(trim(txb.sub-cod.ccode)) >= 77.00 and decim(trim(txb.sub-cod.ccode)) <= 77.99) then lst.idotr = 5.
                        else lst.idotr = wrk.idotr.
                        find first txb.codfr where txb.codfr.codfr = "ecdivisg" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                        if available txb.codfr then lst.otr   = txb.codfr.name[1].
                    end.
                end.
            end.
        end.
        else do :
        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' use-index sub-cod-idx3 no-lock no-error.
        if available txb.sub-cod and trim(txb.sub-cod.ccode) <> "msc" then do:
            lst.code = decim(trim(txb.sub-cod.ccode)).
            for each wrk no-lock.
                if num-entries(trim(wrk.code1)) > 0 then do:
                    if (decim(trim(txb.sub-cod.ccode)) >= decim(entry(1,trim(wrk.code1))) and decim(trim(txb.sub-cod.ccode)) <= decim(entry(2,trim(wrk.code1)))) then do:
                        /* для 68 и 77 код отрасли проставляем 5 */
                        if decim(trim(txb.sub-cod.ccode)) >= 68 or decim(trim(txb.sub-cod.ccode)) >= 77 then lst.idotr = 5.
                        else lst.idotr = wrk.idotr.
                        find first txb.codfr where txb.codfr.codfr = "ecdivis" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                        if available txb.codfr then lst.otr   = txb.codfr.name[1].
                    end.
                end.
            end.
        end.
        end.
        lst.period  = txb.finkoef.period.
        lst.speed   = txb.finkoef.speed.
        lst.profit  = txb.finkoef.profit.
        lst.margin  = txb.finkoef.margin.
        lst.aspeed  = txb.finkoef.aspeed.
        lst.aprofit = txb.finkoef.aprofit.
        lst.price   = txb.finkoef.price.
        lst.rem     = trim(txb.finkoef.rem[1]) + " " + trim(txb.finkoef.rem[2]) + " " + trim(txb.finkoef.rem[3]) + " " + trim(txb.finkoef.rem[4]) + " " + trim(txb.finkoef.rem[5]) + " " + trim(txb.finkoef.rem[6]) + " " + trim(txb.finkoef.rem[7]).
    end.
end.


