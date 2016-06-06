/* sblcdocs.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        SBLC - формирование документов
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
        22/04/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        17/01/2012 id00810 - добавлена новая переменная s-fmt
        21.06.2012 Lyubov  - поправила формат суммы
 */

{global.i}
def shared var s-lc     like lc.lc.
def var v-list   as char.
def var v-sel    as int.
def var v-logsno as char init "no,n,нет,н,1".
def var i        as int.
def var k        as int.
def var v-infile as char.
def var v-ofile  as char.
def var v-str    as char.
def var v-amt    as char.
def stream out.

def     shared var s-fmt    as char.
def     shared var s-lccor  like lcswt.lccor.
def new shared var s-jh     like jh.jh .
def new shared var s-remtrz like remtrz.remtrz.

v-list = ' MT 700/ MT 760 | MT 799 | Cover Sheet | Payment Order '.
run sel2('Docs',v-list, output v-sel).

case v-sel:
    when 1 then do:
        /*find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.*/
        run lcmtlch (s-fmt,no).
    end.
    when 2 then do:
        find first lch where lch.lc = s-lc  and lch.kritcode = 'MT799' no-lock no-error.
        if avail lch and lookup(lch.value1,v-logsno) > 0 then do:
            message 'You  choice had not been to create this type of document!' view-as alert-box.
            return.
        end.
        else do:
            output stream out to MT799.txt.
            put stream out unformatted 'MT799: Free Format Message' skip
                                        'To Institution '.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' and LCh.value4 = 'O799-' + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted '20:Transaction Reference Number' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' and LCh.value4 = 'O799-' + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted '21:Related Reference' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'RREF' and LCh.value4 = 'O799-' + string(s-lccor,'999999') no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.


            put stream out unformatted '79:Narrative' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'Narrat' and LCh.value4 = 'O799-' + string(s-lccor,'999999') no-lock no-error.
            if avail lch then do:
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,50)) SKIP.
                    k = k - 50.
                    if k <= 0 then leave.
                    i = i + 50.
                end.
            end.

            output stream out close.
            unix silent cptwin MT799.txt winword.
            unix silent rm -f MT799.txt.
        end.
    end.
    when 3 then do:
        /*find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
        if avail lch and lch.value1 = 'mt700'*/
        if s-fmt = '700'
        then assign v-infile  = "/data/docs/" + "Appl.htm"
                    v-ofile   = "CoverSheet.htm".
        else assign v-infile  = "/data/docs/" + "ApplPG.htm"
                    v-ofile   = "CoverSheetPG.htm".
        output stream out to value(v-ofile).

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
                    if not avail lch then find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-clname", lch.value1).
                    else  v-str = replace (v-str, "v-clname", "___________________").
                    next.
                end.
                if v-str matches "*v-ben*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-ben", lch.value1).
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
                            if avail crc then v-amt = v-amt + ' ' + crc.code.
                        end.
                        v-str = replace (v-str, "v-amt", v-amt).
                    end.
                    else  v-str = replace (v-str, "v-amt", "0.00").
                    next.
                end.
                if v-str matches "*v-advthrou*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'AdvThrou' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-advthrou", lch.value1).
                    else  v-str = replace (v-str, "v-advthrou", " ").
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
                end.

                if v-str matches "*v-pgnum*" then do:
                    v-str = replace (v-str, "v-pgnum", s-lc).
                    next.
                end.

                if v-str matches "*v-type*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Type' no-lock no-error.
                    if avail lch then do:
                       find first codfr where codfr.codfr = 'expgtype' and codfr.code = lch.value1 no-lock no-error.
                       if avail codfr then v-str = replace (v-str, "v-type", codfr.name[1]).
                    end.
                    else  v-str = replace (v-str, "v-type", " ").
                    next.
                end.

               /* if v-str matches "*v-dtexp*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtexp", lch.value1).
                    else  v-str = replace (v-str, "v-dtexp", " ").
                    next.
                end.
*/
                leave.
            end. /* repeat */

            put stream out unformatted v-str skip.
        end. /* repeat */
        input close.
        output stream out close.

        unix silent value("cptwin " + v-ofile + " winword").
        unix silent value("rm -r " + v-ofile).
    end.
    when 4 then do:
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
    end.

end case.