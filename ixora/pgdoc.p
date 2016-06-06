/*pgdoc .p
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
        26/01/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
    07/12/2011 id00810 - добавлены поля в Cover Sheet
    06.04.2012 Lyubov  - добавила печать ордера для лимитов
    21.06.2012 Lyubov  - поправила формат суммы
*/

{global.i}
def     shared var s-lc like LC.LC.
def new shared var s-jh like jh.jh .
def     shared var v-cif as char.
def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-amt    as char no-undo.
def var i        as int  no-undo.
def var k        as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var v-name   as char no-undo.
def var v-bank   as char no-undo.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else return.

run sel2('Docs',' MT 760 | Cover Sheet | Payment Order ', output v-sel).
case v-sel:
    when 1 then do:
        find first lch where lch.lc = s-lc  and lch.kritcode = 'MT760' no-lock no-error.
        if avail lch and lookup(lch.value1,v-logsno) > 0 then do:
            message 'You  choice had not been to create this type of document!' view-as alert-box.
            return.
        end.
        else do:
            output stream out to MT760.txt.
            put stream out unformatted 'MT760: Guarantee' skip
                                        'To Institution '.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted '27:Sequence of Total' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'SeqTot' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.


            put stream out unformatted '20:Transaction Reference Number' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
            if avail lch then put stream out unformatted caps(lch.value1) skip.

            put stream out unformatted '23:Further Identification' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'FurId' no-lock no-error.
            if avail lch then do:
               find first codfr where codfr.codfr = 'pgfurid' and codfr.code = lch.value1 no-lock no-error.
               if avail codfr then put stream out unformatted caps(codfr.name[1]) skip.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
               put stream out unformatted '30:Date' skip.
               put stream out unformatted datestr(lch.value1) skip.
            end.

            put stream out unformatted '40C:Applicable Rules' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AppRule' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted '77C:Details of Guarantee' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'DetGar' no-lock no-error.
            if avail lch then do:
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,65)) SKIP.
                    k = k - 65.
                    if k <= 0 then leave.
                    i = i + 65.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'StoRInf' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
               put stream out unformatted '72:Sender to Receiver Information' skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.

            end.

            /*run pgmt.*/

            output stream out close.
            unix silent cptwin MT760.txt winword.
            unix silent rm -f MT760.txt.
        end.
    end.
    when 2 then do:

          /*******************/
        v-infile  = "/data/docs/" + "ApplPG.htm".
        v-ofile = "CoverSheetPG.htm".
        output stream out to value(v-ofile).
        /********/

        input from value(v-infile).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*v-pgnum*" then do:
                    v-str = replace (v-str, "v-pgnum", s-lc).
                    next.
                end.

                if v-str matches "*v-clname*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
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

                if v-str matches "*v-type*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Type' no-lock no-error.
                    if avail lch then do:
                        find first LCkrit where LCkrit.dataCode = lch.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
                        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
                            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = lch.value1 no-lock no-error.
                            if avail codfr then v-str = replace (v-str, "v-type", codfr.name[1]).
                            else  v-str = replace (v-str, "v-type", " ").
                        end.
                        else  v-str = replace (v-str, "v-type", " ").
                    end.
                    else  v-str = replace (v-str, "v-type", " ").
                    next.
                end.

                if v-str matches "*v-date*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-date", lch.value1).
                    else  v-str = replace (v-str, "v-date", " ").
                    next.
                end.

                if v-str matches "*v-dtexp*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtexp", lch.value1).
                    else  v-str = replace (v-str, "v-dtexp", " ").
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
                    /*next.*/
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