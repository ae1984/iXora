/* cordoc.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Формирование документов
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var s-jh like jh.jh .
def shared var s-lccor  like lcswt.lccor.
def shared var s-lc     like LC.LC.
def shared var s-lctype as char.

def var v-sel       as integer.
def var v-infile    as char.
def var v-ofile     as char.
def var v-str       as char.
def var v-amt       as char.
def var i           as integer.
def var k           as integer.
def var str         as char.
def var v-sp        as char no-undo.
def var v-logsno    as char init "no,n,нет,н,1".
def buffer b-lch for lch.

def var v-name   as char no-undo.
def var v-bank   as char no-undo.

def stream out.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.
if s-lctype = "I" then v-sp = ' MT 799 | Payment Order '.
else v-sp = ' MT 799 | MT 768 | Cover Sheet '.
run sel2('Docs',v-sp, output v-sel).
case v-sel:

    when 1 then do:
        output stream out to MT799.txt.
        put stream out unformatted 'MT799: Free Format Message' skip
                                   'To Institution '.

        find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
        if avail lch then put stream out unformatted lch.value1 skip.

        put stream out unformatted 'Priority N' skip(2).

        put stream out unformatted '20:Transaction Reference Number' skip.
        if s-lctype = 'I' then
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
        else
            find first lch where lch.lc = s-lc and lch.kritcode = 'BankRef' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
        if avail lch then put stream out unformatted lch.value1 skip.

        put stream out unformatted '21:Related Reference' skip.
        if s-lctype = 'I' then
            find first lch where lch.lc = s-lc and lch.kritcode = 'RREF' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
        else
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
        if avail lch then put stream out unformatted lch.value1 skip.


        put stream out unformatted '79:Narrative' skip.
        find first lch where lch.lc = s-lc and lch.kritcode = 'Narrat' /*and LCh.value4 begins 'I799' + string(s-lccor,'9999')*/ no-lock no-error.
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

    when 2 then do:
        if s-lctype = 'I' then do:
            find first lcres where lcres.lc = s-lc /*+ '_' + string(s-lccor)*/ and lcres.jh > 0 no-lock no-error.
            if avail lcres then do:
                for each lcres where lcres.lc = s-lc /*+ '_' + string(s-lccor)*/ and lcres.jh > 0 no-lock:
                    find first jh where jh.jh = lcres.jh no-lock no-error.
                    if avail jh then do:
                        s-jh = jh.jh.
                        run vou_bank(1).
                    end.
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.
        else do:
            output stream out to MT768.txt.
            put stream out unformatted 'MT768: Acknowledgement of Guarantee Message' skip.
                                       'To Institution '.

            find first lch where lch.lc = s-lc and lch.kritcode = 'InsTo730' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip(2).

            put stream out unformatted "20:Transaction Reference Number" skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'BankRef' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted "21:Related Reference" skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted '30:Date of Message Being Acknowledged' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
            if avail lch then put stream out unformatted datestr(lch.value1) skip.

            put stream out unformatted '32a:Amount of Charges' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AmtChaC' no-lock no-error.
            if avail lch then
            find first crc where crc.crc = int(lch.value1) no-lock no-error.
            if avail crc then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'AmtChaA' no-lock no-error.
                if avail lch then put stream out unformatted crc.code + lch.value1 skip.
            end.

            put stream out unformatted '57a:Account With Bank' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'AccBnk' no-lock no-error.
            if avail lch then
            find first swibic where swibic.bic = lch.value1 no-lock no-error.
            if avail swibic then put stream out unformatted swibic.bic skip swibic.name skip.
            else put stream out unformatted lch.value1 skip.

            find first lch where lch.lc = s-lc and lch.kritcode = 'DetCharg' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted "71B:Details of Charges "  skip.
                k = length(lch.value1).
                i = 1.
                repeat:
                    put stream out unformatted caps(substr(lch.value1,i,35)) SKIP.
                    k = k - 35.
                    if k <= 0 then leave.
                    i = i + 35.
                end.
            end.

            find first lch where lch.lc = s-lc and lch.kritcode = 'StoRI730' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then do:
                put stream out unformatted "72:Sender to Receiver Information "  skip.
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
            unix silent cptwin MT768.txt winword.
            unix silent rm -f MT768.txt.
        end.
    end.

    when 3 then do:
        /*******************/
        v-infile  = "/data/docs/" + "ApplGT.htm".
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

                if v-str matches "*v-avlwith*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Sender' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-avlwith", lch.value1).
                    next.
                end.

                if v-str matches "*v-amt*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'amount' no-lock no-error.
                    if avail lch then do:
                        v-amt = trim(replace(string(deci(lch.value1),'>>>>>>>>9,99'),',','.')).
                        v-amt = trim(replace(string(deci(v-amt),'>>>,>>>,>>9.99'),',',' ')).
                        find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
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

                if v-str matches "*v-dtis*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
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
                leave.
            end. /* repeat */
            put stream out unformatted v-str skip.
        end. /* repeat */
        input close.
        /********/

        output stream out close.

        unix silent value("cptwin " + v-ofile + " winword").
        unix silent value("rm -r " + v-ofile).
    end.
end case.
