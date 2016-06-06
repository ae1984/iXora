/* lcadvdoc.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment - формирование документов
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
        13/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        18/11/2011 id00810 - некоторые изменения в тексте авизования
        21/12/2011 id00810 - для EXSBLC
*/

{global.i}
def shared var s-lc      like lc.lc.
def shared var s-lcamend like lcamend.lcamend.
def shared var s-lcprod  as   char.
def shared var s-lccor   like lcswt.lccor.
def var v-sel     as integer.
def var v-infile  as char.
def var v-infile1 as char.
def var v-ofile   as char.
def var v-str     as char.
def var v-amt     as char.
def var v-nr      as char.
def var i         as integer.
def var k         as integer.
def var j         as integer.
def var v-kod     as char.
def var v-doc     as char.
def var v-result  as char.
def var sw-text   as char extent 1000.
def var v-text    as char.
def stream out.
def stream in1.
def stream in2.

/*function datestr returns char (input p-dtin as char).

    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.*/

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'AdvBy' no-lock no-error.
if not avail lcamendh or lcamendh.value1 = '' then return.
v-doc = if lcamendh.value1 = '0' then ' MT 799 ' else ' Авизование изменения '.

run sel2('Docs',v-doc, output v-sel).
case v-sel:
    when 1 then do:
        if v-doc = ' MT 799 ' then do:
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
        else do:
            v-infile  = "/data/docs/" + lc(s-lcprod) + "adv.htm".
            v-ofile = lc(s-lcprod) + "adv.htm".
            output stream out to value(v-ofile).

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
                       v-nr = if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then 'DtIs' else 'Date'.
                       find first lch where lch.lc = s-lc and lch.kritcode = v-nr no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-dt\}", string(date(lch.value1),'99/99/9999')).
                        else  v-str = replace (v-str, "\{v-dt\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-dtadv\}*" then do:
                        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DtAmend' no-lock no-error.
                        if avail lcamendh then v-str = replace (v-str, "\{v-dtadv\}", string(date(lcamendh.value1),'99/99/9999')).
                        else  v-str = replace (v-str, "\{v-dtadv\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-dtadvamd\}*" then do:
                        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'DtAdvAmd' no-lock no-error.
                        if avail lcamendh then v-str = replace (v-str, "\{v-dtadvamd\}", string(date(lcamendh.value1),'99/99/9999')).
                        else  v-str = replace (v-str, "\{v-dtadvamd\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-who\}*" then do:
                        find first sysc where sysc.sysc = 'dkface' no-lock no-error.
                        if avail sysc then v-str = replace (v-str, "\{v-who\}", substr(entry(1,sysc.chval),index(entry(1,sysc.chval),' ') + 1)).
                        else v-str = replace (v-str, "\{v-who\}"," ").
                        next.
                    end.
                    if v-str matches "*\{v-sender\}*" then do:
                       find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'Sender' no-lock no-error.
                       if avail lcamendh then do:
                            find first swibic where swibic.bic = lcamendh.value1 no-lock no-error.
                            if avail swibic then v-str = replace (v-str, "\{v-sender\}",  swibic.name + ',' + swibic.cnt).
                            else v-str = replace (v-str, "\{v-sender\}", lch.value1).
                       end.
                       else  v-str = replace (v-str, "\{v-sender\}", " ").
                       next.
                    end.
                    if v-str matches "*\{v-benef\}*" then do:
                       find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                       if avail lch then v-str = replace (v-str, "\{v-benef\}", lch.value1).
                       else  v-str = replace (v-str, "\{v-benef\}", " ").
                       next.
                    end.
                    if v-str matches "*\{v-princ\}*" then do:
                       find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
                       if avail lch then v-str = replace (v-str, "\{v-princ\}", lch.value1).
                       else  v-str = replace (v-str, "\{v-princ\}", " ").
                       next.
                    end.
                    if v-str matches "*\{v-applic\}*" then do:
                       find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'Applic' no-lock no-error.
                       if avail lcamendh then v-str = replace (v-str, "\{v-applic\}", lcamendh.value1).
                       else  v-str = replace (v-str, "\{v-applic\}", " ").
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
                       v-nr = if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then 'SendRef' else 'TRNum'.
                       find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = v-nr no-lock no-error.
                       if avail lcamendh then v-str = replace (v-str, "\{v-CreditN\}", lcamendh.value1).
                       else  v-str = replace (v-str, "\{v-CreditN\}", " ").
                       next.
                    end.
                    if v-str matches "*\{v-bankref\}*" then do:
                        v-nr = if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then 'ReceRef' else 'RRef'.
                        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = v-nr no-lock no-error.
                        if avail lcamendh then v-str = replace (v-str, "\{v-bankref\}", lcamendh.value1).
                        else  v-str = replace (v-str, "\{v-bankref\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-mt\}*" then do:
                        find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend  = s-lcamend and lcamendh.kritcode = 'fname2' no-lock no-error.
                        if not avail lcamendh then v-str = replace (v-str, "\{v-mt\}", "").
                        else do:
                            v-infile1  = lcamendh.value1.
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

                                if index(sw-text[i],"\{2:O7") > 0 then do:
                                    find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,11) no-lock no-error.
                                    if not avail swibic
                                    then find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,8) + 'XXX' no-lock no-error.
                                    if not avail swibic then next.
                                    v-text = /*'ЦИТАТА' + '<br/>'
                                            +*/ codific.codfr  + ': ' + codific.name + '<br/>'
                                            + 'Status: Processed' + '<br/>'
                                            + 'From Institution ' + swibic.bic + '<br/>'
                                            + swibic.name + '<br/>'
                                            + 'Priority N' + '<br/>' + '<br/>'.

                                    next.
                                end.
                                if sw-text[i] begins ":" then do:
                                    v-kod = entry(2,sw-text[i],':').
                                    v-text = v-text  +  v-kod + ': '.
                                    find first codfr
                                    where      codfr.codfr   = 'MT' + substr(lcswt.mt,2)
                                    and        codfr.code    = v-kod
                                    no-lock no-error.
                                    if avail codfr then v-text = v-text +  codfr.name[1].
                                    v-text = v-text + '<br/>' + entry(3,sw-text[i],':') + '<br/>'.
                                end.
                                else v-text = v-text +  sw-text[i] + '<br/>'.
                            end.
                           /* v-text = v-text + '<br/>' + '<br/>' + 'КОНЕЦ ЦИТАТЫ'  + '<br/>' + '<br/>' +
                            'Пожалуйста тщательно ознакомьтесь с деталями данного изменения. Если Вы не готовы'  + '<br/>' +
                            'выполнить какое либо из условий данного изменения Вам следует связаться с Аппликантом или'  + '<br/>' +
                            'нашим банком для внесения соответствующих поправок / уточнений / изменений в условия'  + '<br/>' +
                            'аккредитива. '  + '<br/>' + '<br/>' +
                            'С Уважением,'  + '<br/>' +
                            'АО «МЕТРОКОМБАНК»'  + '<br/>' + '<br/>'.
                            */
                            input stream in2 close.
                            v-str = replace (v-str, "\{v-mt\}", v-text).
                        end.
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
    end.

end case.