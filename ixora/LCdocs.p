/*LCdocs .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        формирование документов
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
        09/09/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        23/09/2010 galina - поменяла формат ввода поля 39:A (Percent Credit Amount Tolerance)
        11/10/2010 galina - поменяла формат вывода полей 71 и 72
        25/11/2010 galina - добавила новый критерий AdvThOpt
        30/11/2010 galina - для аккредитивов без критерия AdvThOpt ставим по умолчанию A
                            добавила признак MT700
        09/12/2010 galina - выводим номер аккредитива заглавными буквами
        28/12/2010 Vera   - не выводился номер поля 45А
        30/12/2010 Vera   - изменения в Cover Sheet
        15/08/2011 id00810 - изменения в связи с MT720
        07/12/2011 id00810 - добавлены поля в Cover Sheet
        17/01/2012 id00810 - изменлось значение реквизита fmt
        06.04.2012 Lyubov  - добавила печать ордера для лимитов
        21.06.2012 Lyubov  - поправила формат суммы
        09/09/2013 galina - ТЗ 1881 добавила вывод полей PLAD и PDAD
*/

{global.i}
def shared var s-lc like LC.LC.
def shared var v-cif      as char.
define new shared var s-jh like jh.jh .
def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-amt    as char no-undo.
def var i        as int  no-undo.
def var k        as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-fmt    as char no-undo init 'MT700'.
def var v-name   as char no-undo.
def var v-bank   as char no-undo.
def buffer b-lch for lch.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else return.

find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
if avail lch then if lch.value1 = '720' then v-fmt = 'MT720'.
run sel2('Docs',' '  + v-fmt + ' | Cover Sheet | Payment Order ', output v-sel).

case v-sel:
    when 1 then do:
        if v-fmt = 'MT720' then run lcmtlch.p ('720', no).
        else do:
        find first lch where lch.lc = s-lc  and lch.kritcode = 'MT700' no-lock no-error.
        if avail lch and lookup(lch.value1,v-logsno) > 0 then do:
            message 'You  choice had not been to create this type of document!' view-as alert-box.
            return.
        end.
        else do:
            output stream out to MT700.txt.
            put stream out unformatted 'MT700: Issue of a Documentary Credit' skip
                                        'To Institution '.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted '27:Sequence of Total' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'SeqTot' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.


            put stream out unformatted '40A:Form of Documentary Credit' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'FormCred' no-lock no-error.
            if avail lch then do:
                find first lckrit where lckrit.datacode = 'FormCred' no-lock no-error.
                if avail lckrit then do:
                    find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
                    if avail codfr then put stream out unformatted codfr.name[1] skip.
                end.
            end.

            put stream out unformatted '20:Documentary Credit Number' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'CreditN' no-lock no-error.
            if avail lch then put stream out unformatted caps(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '31C:Date of Issue' skip
                                                          datestr(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'AppRule' no-lock no-error.
            if avail lch then put stream out unformatted '40E:Applicable Rules' skip
                                                          lch.value1 skip.

            put stream out unformatted '31D:Date and Place of Expiry' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
            if avail lch then put stream out unformatted datestr(lch.value1) skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'PlcExp' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.


            put stream out unformatted '50:Applicant' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            if avail lch then do:
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            put stream out unformatted '59:Beneficiary' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            if avail lch then do:
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.

            end.

            put stream out unformatted '32B:Currency Code, Amount' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then do:
                find first crc where crc.crc = int(lch.value1) no-lock no-error.
                if avail crc then put stream out unformatted crc.code.
            end.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
            if avail lch then put stream out unformatted trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PerAmt' no-lock no-error.
    /*        if avail lch and trim(lch.value1) <> '' then put stream out unformatted '39A:Percent Credit Amount Tolerance' skip trim(replace(string(deci(lch.value1),'>>9.99'),'.',',')) skip.*/
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '39A:Percent Credit Amount Tolerance' skip lch.value1 skip.

            put stream out unformatted '41A:Available With ... By ...' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AvlWith' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
            if avail lch then do:
                find first lckrit where lckrit.datacode = 'By' no-lock no-error.
                if avail lckrit then do:
                    find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
                    if avail codfr then put stream out unformatted 'BY ' + caps(codfr.name[1]) skip.
                end.

            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DrfAt' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted 'Drafts at' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Drawee' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '42A:Drawee' skip lch.value1 skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DefPayD' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '42P:Deferred Payments Details' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'ParShip' no-lock no-error.
            if avail lch then do:
                find first lckrit where lckrit.datacode = 'ParShip' no-lock no-error.
                if avail lckrit then do:
                    find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
                    if avail codfr then put stream out unformatted '43P:Partial Shipments' skip codfr.name[1] skip.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'TrnShip' no-lock no-error.
            if avail lch then do:
                find first lckrit where lckrit.datacode = 'TrnShip' no-lock no-error.
                if avail lckrit then do:
                    find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
                    if avail codfr then put stream out unformatted '43T:Transshipment' skip codfr.name[1] skip.
                end.
             end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PlcCharg' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '44A:Place of Taking in Charge/Dispatch from.../Place of Receipt' skip caps(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PLAD' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '44E:Port of Loading/Airport of Departure' skip caps(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PDAD' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '44F:Port of Discharge/Airport of Destination' skip caps(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PclFD' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '44B:Place of Final Destination/For Transportation to.../Place of Delivery' skip caps(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'LDtShip' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '44C:Latest Date of Shipment' skip datestr(lch.value1) skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DesGood' no-lock no-error.

            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '45A:Description of Goods &/or Services' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DocReq' no-lock no-error.

            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '46A:Documents Required' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.
            end.



            find first lch where lch.lc = s-lc and lch.kritcode = 'AddCond' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '47A:Additional Conditions' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Charges' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '71B:Charges' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'PerPres' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '48:Period for Presentation' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            put stream out unformatted '49:Confirmation Instructions' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Confir' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                find first lckrit where lckrit.datacode = lch.kritcode no-lock no-error.
                if avail lckrit then do:
                    find first codfr where codfr.codfr = lckrit.dataSpr and codfr.code = lch.value1 no-lock no-error.
                    if avail codfr then put stream out unformatted codfr.name[1] skip.
                end.

            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'ReimBnk' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then put stream out unformatted '53A:Reimbursing Bank' skip lch.value1 skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'InstoBnk' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted '78:Instructions to the Paying/Accepting/Negotiating Bank' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.

            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'AdvThrou' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted "57".
                find first b-LCh where b-LCh.LC = s-lc and b-LCh.kritcode = 'AdvThOpt' no-lock no-error.
                if avail b-lch and trim(b-lch.value1) <> '' then put stream out unformatted caps(trim(b-lch.value1)).
                else  put stream out unformatted 'A'.
                put stream out unformatted ":Advise Through'Bank"  skip.
                if avail b-lch then do:
                    if trim(b-lch.value1) = 'D' then do:
                        k = length(lch.value1).
                        i = 1.
                        repeat:
                            put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                            k = k - 35.
                            if k <= 0 then leave.
                            i = i + 35.
                        end.
                    end.
                    else put stream out unformatted lch.value1 skip.
                end.
                else put stream out unformatted lch.value1 skip.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'StoRInf' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted "72:'Sender to Receiver Information "  skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            output stream out close.
            unix silent cptwin MT700.txt winword.
            unix silent rm -f MT700.txt.
        end.
        end.
    end.
    when 2 then do:

          /*******************/
        v-infile  = "/data/docs/" + "Appl.htm".
        v-ofile = "CoverSheet.htm".
        output stream out to value(v-ofile).
        /********/

        input from value(v-infile).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*v-lcnum*" then do:
                    v-str = replace (v-str, "v-lcnum", s-lc).
                    next.
                end.

                if v-str matches "*v-clname*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-clname", trim(substr(lch.value1,1,35))).
                    else  v-str = replace (v-str, "v-clname", "___________________").
                    next.
                end.

                if v-str matches "*v-ben*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-ben", trim(substr(lch.value1,1,35))).
                    else  v-str = replace (v-str, "v-ben", "___________________").
                    next.
                end.

                if v-str matches "*v-amt*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
                    if avail lch then do:
                        v-amt = trim(replace(string(deci(lch.value1),'>>>,>>>,>>9.99'),',',' ')).
                        find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
                        if avail lch then do:
                            find first crc where crc.crc = integer(lch.value1) no-lock no-error.
                            if avail crc then v-amt = crc.code + ' ' + v-amt.
                        end.
                        v-str = replace (v-str, "v-amt", v-amt).
                    end.
                    else  v-str = replace (v-str, "v-amt", "0.00").
                    next.
                end.

                if v-str matches "*v-avlwith*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'AvlWith' no-lock no-error.
                    if avail lch then do:
                        find first swibic where swibic.bic = lch.value1 no-lock no-error.
                        if avail swibic then v-str = replace (v-str, "v-avlwith", swibic.name).
                        else  v-str = replace (v-str, "v-avlwith", " ").
                    end.
                    else  v-str = replace (v-str, "v-avlwith", " ").
                    next.
                end.

               if v-str matches "*v-advbank*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
                    if avail lch then do:
                        find first swibic where swibic.bic = lch.value1 no-lock no-error.
                        if avail swibic then v-str = replace (v-str, "v-advbank", swibic.name).
                        else  v-str = replace (v-str, "v-advbank", " ").
                    end.
                    else  v-str = replace (v-str, "v-advbank", " ").
                    next.
                end.

                if v-str matches "*v-dtis*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtis", lch.value1).
                    else  v-str = replace (v-str, "v-dtis", " ").
                    next.
                end.

                if v-str matches "*v-dtexp*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtexp", lch.value1).
                    else  v-str = replace (v-str, "v-dtexp", " ").
                    next.
                end.

                if v-str matches "*v-ldtship*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'LDtShip' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-ldtship", lch.value1).
                    else  v-str = replace (v-str, "v-ldtship", " ").
                    next.
                end.

                if v-str matches "*v-ofc*" then do:
                    find first lcsts where lcsts.lcnum = s-lc and lcsts.type = 'cre' and lcsts.sts = 'MD1' no-lock no-error.
                    if avail lcsts then do:
                        find first ofc where ofc.ofc = lcsts.who no-lock no-error.
                        if avail ofc then do:
                            run rus-eng.p (ofc.name, output v-name).
                            v-str = replace (v-str, "v-ofc", v-name).
                        end.
                        v-str = replace (v-str, "v-ofc", " ").
                    end.
                    v-str = replace (v-str, "v-ofc", " ").
                    next.
                end.

                if v-str matches "*v-confir*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Confir' no-lock no-error.
                    if avail lch then do:
                        find first LCkrit where LCkrit.dataCode = lch.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
                        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
                            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = lch.value1 no-lock no-error.
                            if avail codfr then v-str = replace (v-str, "v-confir", codfr.name[1]).
                            else  v-str = replace (v-str, "v-confir", " ").
                        end.
                        else  v-str = replace (v-str, "v-confir", " ").
                    end.
                    else  v-str = replace (v-str, "v-confir", " ").
                    next.
                end.

                if v-str matches "*v-by*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'by' no-lock no-error.
                    if avail lch then do:
                        find first LCkrit where LCkrit.dataCode = lch.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
                        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
                            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = lch.value1 no-lock no-error.
                            if avail codfr then v-str = replace (v-str, "v-by", codfr.name[1]).
                            else v-str = replace (v-str, "v-by", " ").
                        end.
                        else  v-str = replace (v-str, "v-by", " ").
                    end.
                    else  v-str = replace (v-str, "v-by", " ").
                end.
                leave.
            end. /* repeat */

            put stream out unformatted v-str skip.
        end. /* repeat */
        input close.
        /********/


        output stream out close.

        unix silent value("cptwin " + v-ofile + " winword").
        unix silent value("rm -r " + v-ofile).


      /*******************/
    end.
    when 3 then do:
        find first lcres where lcres.lc = s-lc and lcres.jh > 0 no-lock no-error.
        if avail lcres then do:
            for each lcres where lcres.lc = s-lc and lcres.jh > 0 no-lock:
                find first jh where jh.jh = lcres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.

        find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
        if avail lch then do:
            find first lclimitres where lclimitres.bank = v-bank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.jh > 0 and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' no-lock no-error.
            if avail lclimitres then do:
                s-jh  = 0.
                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.

    end.
end case.