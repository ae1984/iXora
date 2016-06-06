/*exlcdoc .p
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
        11/02/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        20/05/2011 id00810 - для EXSBLC
        14/09/2011 id00810 - MT720
        07/12/2011 id00810 - добавлены поля в Cover Sheet
        13/01/2012 id00810 - MT730 - если значение соотв.реквизита = yes
        20/04/2012 id00810 - корректировка текста авизования
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        07/06/2012 Lyubov  - добавлена проверка на отправку мт 730
        21.06.2012 Lyubov  - поправила формат суммы

*/

{global.i}
def shared var s-lc     like lc.lc.
def shared var s-lcprod as char.
def shared var s-fmt    as char.
def var v-sel     as int  no-undo.
def var v-infile  as char no-undo.
def var v-infile1 as char no-undo.
def var v-ofile   as char no-undo.
def var v-str     as char no-undo.
def var v-amt     as char no-undo.
def var v-bank1   as char no-undo.
def var v-bank2   as char no-undo.
def var i         as int  no-undo.
def var k         as int  no-undo.
def var j         as int  no-undo.
def var v-kod     as char no-undo.
def var v-sum     as deci no-undo.
def var v-sum1    as deci no-undo.
def var v-sum2    as deci no-undo.
def var v-result  as char no-undo.
def var sw-text   as char no-undo extent 1000.
def var v-text    as char no-undo.
def var v-sp      as char no-undo.
def var v-name    as char no-undo.
def var v-logsno  as char no-undo init "no,n,нет,н,1".
def stream out.
def stream in1.
def stream in2.

def temp-table wrk no-undo
  field id        as integer
  field nom-f     as char
  field name-f    as char
  field datacode1 as char
  field datacode2 as char
  index idx is primary id.
def buffer b-lch for lch.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

if s-fmt <> '760' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'Advby' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        message 'The field "Advise by" must be completed!' view-as alert-box error.
        return.
    end.
    if lch.value1 = '1' then v-sp = ' Авизование | Cover Sheet '.
    else if lch.value1 = '710' then v-sp = ' MT710 | Cover Sheet '.
    else v-sp = ' MT720 | Cover Sheet '.
end.
else v-sp = ' Авизование | Cover Sheet '.

find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'MT730' no-lock no-error.
if avail b-lch and lookup(b-lch.value1,v-logsno) = 0 then v-sp = v-sp + '| MT730 '.

run sel2('Docs',v-sp, output v-sel).
case v-sel:
    when 1 then do:
         if (s-fmt <> '760' and lch.value1 = '1') or s-fmt = '760' then do:
            assign v-infile  = "/data/docs/" + "exlc.htm"
                        v-ofile   = "exlc.htm".
            v-sum = 0.
            find first lcres where lcres.lc = s-lc and lcres.com and  lcres.comcode = '972' /*and lcres.jh ne 0*/ no-lock no-error.
            if avail lcres then v-sum1 = lcres.amt.

            find first lcres where lcres.lc = s-lc and lcres.com and  lcres.comcode = '944' /*and lcres.jh ne 0*/ no-lock no-error.
            if avail lcres then v-sum2 = lcres.amt.

            output stream out to value(v-ofile).
            /********/

            input stream in1 from value(v-infile).
            repeat:
                import stream in1 unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*\{v-city\}*" then do:
                        find first sysc where sysc.sysc = 'citi' no-lock no-error.
                        if avail sysc then v-str = replace (v-str, "\{v-city\}", sysc.chval).
                        else v-str = replace (v-str, "\{v-city\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-whom\}*" then do:
                        find first sysc where sysc.sysc = 'dkkomu' no-lock no-error.
                        if avail sysc then v-str = replace (v-str, "\{v-whom\}", substr(entry(2,sysc.chval),index(entry(2,sysc.chval),' ') + 1)).
                        else v-str = replace (v-str, "\{v-whom\}"," ").
                        next.
                    end.
                    if v-str matches "*\{v-from\}*" then do:
                        find first pksysc where pksysc.sysc = 'mddir-r' no-lock no-error.
                        if avail pksysc then v-str = replace (v-str, "\{v-from\}", pksysc.chval).
                        else v-str = replace (v-str, "\{v-from\}"," ").
                        next.
                    end.
                    if v-str matches "*\{v-dt\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'DtIs' no-lock no-error.
                        if not avail lch then find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-dt\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-dt\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-dtadv\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-dtadv\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-dtadv\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-who\}*" then do:
                        find first sysc where sysc.sysc = 'dkface' no-lock no-error.
                        if avail sysc then v-str = replace (v-str, "\{v-who\}", substr(entry(1,sysc.chval),index(entry(1,sysc.chval),' ') + 1)).
                        else v-str = replace (v-str, "\{v-who\}"," ").
                        next.
                    end.
                    if v-str matches "*\{v-issbank\}*" then do:
                       find first lch where lch.lc = s-lc and lch.kritcode = 'IssBank' no-lock no-error.
                        if avail lch then do:
                            find first swibic where swibic.bic = lch.value1 no-lock no-error.
                            if avail swibic then v-str = replace (v-str, "\{v-issbank\}",  swibic.name + ',' + swibic.cnt).
                            else v-str = replace (v-str, "\{v-issbank\}", lch.value1).
                        end.
                        else  v-str = replace (v-str, "\{v-issbank\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-benef\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-benef\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-benef\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-applic\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-applic\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-applic\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-sum1\}*" then do:
                        if v-sum1 <> 0 then v-str = replace (v-str, "\{v-sum1\}", string(v-sum1,'>>>>9.99')).
                        else  v-str = replace (v-str, "\{v-sum1\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-sum2\}*" then do:
                        if v-sum2 <> 0 then v-str = replace (v-str, "\{v-sum2\}", string(v-sum2,'>>>>9.99')).
                        else  v-str = replace (v-str, "\{v-sum2\}", " ").
                        next.
                    end.
                   if v-str matches "*\{v-crc\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
                        if avail lch then do:
                           find first crc where crc.crc = integer(lch.value1) no-lock no-error.
                           if avail crc then v-str = replace (v-str, "\{v-crc\}", crc.code).
                           else  v-str = replace (v-str, "\{v-crc\}", " ").
                        end.
                        else  v-str = replace (v-str, "\{v-crc\}", " ").
                        next.
                    end.
                   if v-str matches "*\{v-amt\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
                        if avail lch then do:
                            v-amt = trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')).
                            v-str = replace (v-str, "\{v-amt\}", v-amt).
                        end.
                        else  v-str = replace (v-str, "\{v-amt\}", "0,00").
                        next.
                    end.
                    if v-str matches "*\{v-CreditN\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'CreditN' no-lock no-error.
                        if not avail lch then find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-CreditN\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-CreditN\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-bankref\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'BankRef' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-bankref\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-bankref\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-benef\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-benef\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-benef\}", " ").
                        next.
                    end.

                    if v-str matches "*\{v-applic\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-applic\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-applic\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-info\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Sender' no-lock no-error.
                        if avail lch then v-bank1 = lch.value1.
                        find first lch where lch.lc = s-lc and lch.kritcode = 'IssBank' no-lock no-error.
                        if avail lch then v-bank2 = lch.value1.
                        if v-bank1 <> v-bank2 then do:
                            find first swibic where swibic.bic = v-bank1 no-lock no-error.
                            if avail swibic then v-str = replace (v-str, "\{v-info\}", 'Аккредитив подтвержден ' + swibic.name + ',' + swibic.cnt + '.').
                            else v-str = replace (v-str, "\{v-info\}",'').
                        end.
                        else  v-str = replace (v-str, "\{v-info\}", "").
                        next.
                    end.

                    if v-str matches "*\{v-sum\}*" then
                       v-str = replace (v-str, "\{v-sum\}", string((v-sum1 + v-sum2),'>>>>9.99')).

                    if v-str matches "*\{v-rez1\}*" then do:
                        if s-lcprod = 'exsblc' then v-str = replace (v-str, "\{v-rez1\}", "резервный ").
                        else v-str = replace (v-str, "\{v-rez1\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-rez2\}*" then do:
                        if s-lcprod = 'exsblc' then v-str = replace (v-str, "\{v-rez2\}", "резервного ").
                        else v-str = replace (v-str, "\{v-rez2\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-rez3\}*" then do:
                        if s-lcprod = 'exsblc' then v-str = replace (v-str, "\{v-rez3\}", "резервному ").
                        else v-str = replace (v-str, "\{v-rez3\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-rez4\}*" then do:
                        if s-lcprod = 'exsblc' then v-str = replace (v-str, "\{v-rez4\}", "РЕЗЕРВНОГО ").
                        else v-str = replace (v-str, "\{v-rez4\}", " ").
                        next.
                    end.

                    if v-str matches "*\{v-mt\}*" then do:
                       find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' no-lock no-error.
                       if not avail lch then v-str = replace (v-str, "\{v-mt\}", "").
                       else do:
                        v-infile1  = lch.value1.
                        find first lcswt where lcswt.fname2 = v-infile1 no-lock no-error.
                        if not avail lcswt then leave.

                        find first codific where codific.codfr = 'MT' + substr(lcswt.mt,2) no-lock no-error.
                        if not avail codific then leave.

                        input through  value("cp " + "/data/import/lcmt/" + string(year(LCswt.rdt),"9999") + string(month(LCswt.rdt),"99") + string(day(LCswt.rdt),"99") + "/" + v-infile1 + " " + v-infile1 + ";echo $?").
                        repeat:
                            import unformatted v-result.
                        end.
                        if v-result <> "0" then do:
                            message v-result + "Ошибка копирования файла " + v-infile view-as alert-box error.
                            return.
                        end.
                        input stream in2 from value(v-infile1).

                        i = 0. j = 0.
                        repeat:
                            i = i + 1.
                            import stream in2 unformatted sw-text[i].

                            if sw-text[i] begins "-}"  then leave.

                            if index(sw-text[i],"\{2:O700") > 0 or index(sw-text[i],"\{2:O710") > 0 then do:
                                find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,11) no-lock no-error.
                                if not avail swibic
                                then find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,8) + 'XXX' no-lock no-error.
                                if not avail swibic then next.
                                v-text = 'ЦИТАТА'  + '<br/>'
                                         + codific.codfr + ': ' + codific.name  + '<br/>'
                                         + 'Status: Processed'  + '<br/>'
                                         + 'From Institution ' + swibic.bic  + '<br/>'
                                         + swibic.name  + '<br/>'
                                         + 'Priority N'  + '<br/>'  + '<br/>'.

                                next.
                            end.
                            if sw-text[i] begins ":" then do:
                                v-kod = entry(2,sw-text[i],':').
                                v-text = v-text  +  v-kod + ': '.
                                find first codfr
                                where      codfr.codfr   = 'MT' + substr(lcswt.mt,2)
                                and        codfr.code    = v-kod
                                no-lock no-error.
                                if avail codfr then v-text = v-text + codfr.name[1].
                                v-text = v-text  +  '<br/>' +  entry(3,sw-text[i],':') + '<br/>' .
                            end.
                            else  v-text = v-text  + sw-text[i] + '<br/>'.
                        end.
                        input stream in2 close.
                   end.
                    v-str = replace (v-str, "\{v-mt\}", v-text).
                  end.
                  leave.
                end.
                put stream out unformatted v-str skip.
            end.

            input stream in1 close.
            output stream out close.

            unix silent value('cptwin ' + v-ofile + ' winword').
            unix silent value('rm -f ' + v-ofile).

        end.
        else if lch.value1 = '710' then do:

            run lcmtlch.p ('710', no) no-error.
        end.
        else do:
            run lcmtlch.p ('720', no) no-error.
        end.
    end.

    when 3 then do:
            output stream out to MT730.txt.
            put stream out unformatted 'MT730: Acknowledgement' skip
                                        'To Institution '.
            find first lch where lch.lc = s-lc and lch.kritcode = 'InsTo730' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted 'Priority N' skip(2).

            put stream out unformatted "20:Sender's Reference" skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'SendRef' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted "21:Receiver's Reference" skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'ReceRef' no-lock no-error.
            if avail lch then put stream out unformatted lch.value1 skip.

            put stream out unformatted '30:Date of the Message Being Acknowledged' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'DtMBA' no-lock no-error.
            if avail lch then put stream out unformatted datestr(lch.value1) skip.

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
            unix silent cptwin MT730.txt winword.
            unix silent rm -f MT730.txt.

    end.
    when 2 then do:

        /*******************/
        /*if s-fmt = '760' then v-infile  = "/data/docs/" + "ApplExpg.htm".
        else-*/ v-infile  = "/data/docs/" + "ApplExlc.htm".
        v-ofile = "CoverSheet.htm".
        output stream out to value(v-ofile).
        /********/

        input from value(v-infile).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*v-expgnum*" then do:
                    v-str = replace (v-str, "v-expgnum", s-lc).
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
                if v-str matches "*v-issbank*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'IssBank' no-lock no-error.
                    if avail lch then do:
                        find first swibic where swibic.bic = lch.value1 no-lock no-error.
                        if avail swibic then v-str = replace (v-str, "v-issbank", swibic.name).
                        else  v-str = replace (v-str, "v-issbank", " ").
                    end.
                    else  v-str = replace (v-str, "v-issbank", " ").
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
    end.
end case.