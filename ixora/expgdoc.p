/*expgdoc .p
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
        31/01/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    21/02/2011 id00810 - поменяла формат исх.сообщения на МТ768,
                         убрала при печати сумм комиссий проверку lcres.jh ne 0
    16/06/2011 id00810 - авизование - один документ(expg.htm) вместо трех
    18/07/2011 id00810 - авизование - если нет входящего документа, то 3-ий лист частично заполняется (цитата...конец цитаты)
    25/07/2011 id00810 - ошибка при подсчете суммы комиссий
    11/08/2011 id00810 - подсчет суммы комиссий вынесен за repeat
    30/11/2011 id00810 - в тексте авизования убрала БИК банка из v-sender
    07/12/2011 id00810 - добавлены поля в Cover Sheet
    11/05/2012 Lyubov  - добавила To Institution в МТ768
    07/06/2012 Lyubov  - проверка отправки mt 768
    21.06.2012 Lyubov  - довабила v-type, v-sign(1,2), v-resp, поправила формат сумм
    21.06.2012 Lyubov  - поправила формат суммы
    18.07.2012 Lyubov  - исправлен формат даты для Cover Sheet
    26.07.2012 Lyubov  - на время отсутсвия дир. деп-та ТФ, в док-т ставится подпись начальника ОП и ТФ
    14.08.2012 Lyubov  - исправила наименования полей в МТ768 в соотв-вии со стандартами
    06.06.2013 Lyubov  - ТЗ №1879, проверка значения в поле Dste для Cover Sheet
*/

{global.i}
def shared var s-lc like LC.LC.
def stream out.
def stream in1.
def stream in2.
def var v-sel     as int  no-undo.
def var v-infile  as char no-undo.
def var v-infile1 as char no-undo.
def var v-ofile   as char no-undo.
def var v-str     as char no-undo.
def var v-amt     as char no-undo.
def var i         as int  no-undo.
def var j         as int  no-undo.
def var k         as int  no-undo.
def var v-kod     as char no-undo.
def var v-sum     as deci no-undo.
def var v-sum1    as deci no-undo.
def var v-sum2    as deci no-undo.
def var v-result  as char no-undo.
def var sw-text   as char no-undo extent 1000.
def var v-text    as char no-undo.
def var v-name    as char no-undo.
def var v-sp      as char no-undo.
def var sum       as char no-undo.
def var v-dtdt    as char no-undo.

function datestr returns char (input p-dtin as char).
    def var v-dt as char.
    v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
    return v-dt.
end function.

find first lch where lch.lc = s-lc and lch.kritcode = 'MT768' no-lock no-error.
if avail lch and lch.value1 = 'NO' then v-sp = 'Авизование | Cover Sheet '.
 else v-sp = ' Авизование | Cover Sheet | MT768 '.
run sel2('Docs',v-sp, output v-sel).
case v-sel:
    when 3 then do:
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

            put stream out unformatted '30:Date of the Message Being Acknowledged' skip.
            find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
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
            unix silent cptwin MT768.txt winword.
            unix silent rm -f MT768.txt.

    end.
    when 2 then do:

          /*******************/
        v-infile  = "/data/docs/" + "ApplExpg.htm".
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
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Sender' no-lock no-error.
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
                    v-dtdt = string(date(lch.value1),'99/99/9999').
                    if avail lch and lch.value1 <> ? then v-str = replace (v-str, "v-date", v-dtdt).
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
    when 1 then do:

        v-infile  = "/data/docs/" + "expg.htm".
        v-ofile = "expg.htm".
        find first lcres where lcres.lc = s-lc and lcres.com and  lcres.comcode = '955' /*and lcres.jh ne 0*/ no-lock no-error.
        if avail lcres then v-sum1 = lcres.amt.
        find first lcres where lcres.lc = s-lc and lcres.com and  lcres.comcode = '944' /*and lcres.jh ne 0*/ no-lock no-error.
        if avail lcres then v-sum2 = lcres.amt.
        v-sum = v-sum1 + v-sum2.

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
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-dt\}", string(date(lch.value1),'99/99/9999')).
                    else  v-str = replace (v-str, "\{v-dt\}", " ").
                    next.
                end.
                if v-str matches "*\{v-dtadv\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-dtadv\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-dtadv\}", " ").
                    next.
                end.
                if v-str matches "*\{v-resp\}*" then do:
                    find first sysc where sysc.sysc = 'dkface' no-lock no-error.
                    if avail sysc then do:
                        if sysc.stc = 'f' then v-str = replace (v-str, "\{v-resp\}","Уважаемая ").
                                          else v-str = replace (v-str, "\{v-resp\}","Уважаемый ").
                    end.
                    else v-str = replace (v-str, "\{v-resp\}"," ").
                    next.
                end.
                if v-str matches "*\{v-who\}*" then do:
                    find first sysc where sysc.sysc = 'dkface' no-lock no-error.
                    if avail sysc then v-str = replace (v-str, "\{v-who\}", substr(entry(1,sysc.chval),index(entry(1,sysc.chval),' ') + 1)).
                    else v-str = replace (v-str, "\{v-who\}"," ").
                    next.
                end.
                if v-str matches "*\{v-sender\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Sender' no-lock no-error.
                    if avail lch then do:
                        find first swibic where swibic.bic = lch.value1 no-lock no-error.
                        if avail swibic then v-str = replace (v-str, "\{v-sender\}", swibic.name).
                        else v-str = replace (v-str, "\{v-sender\}", lch.value1).
                    end.
                    else  v-str = replace (v-str, "\{v-sender\}", " ").
                    next.
                end.
                if v-str matches "*\{v-type\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Type' no-lock no-error.
                    if avail lch then do:
                        find first codfr where codfr.codfr = 'expgtype' and codfr.code = lch.value1 no-lock no-error.
                        if avail codfr then v-str = replace (v-str, "\{v-type\}",codfr.name[3]).
                    end.
                    else v-str = replace (v-str, "\{v-who\}"," ").
                    next.
                end.
                if v-str matches "*\{v-benef\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-benef\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-benef\}", " ").
                    next.
                end.
                if v-str matches "*\{v-sum1\}*" then do:
                    if v-sum1 <> 0 then do:
                        sum = replace(trim(string(v-sum1,'>>>,>>9.99')),',',' ').
                        v-str = replace (v-str, "\{v-sum1\}",sum).
                    end.
                    else  v-str = replace (v-str, "\{v-sum1\}", " ").
                    next.
                end.
                if v-str matches "*\{v-sum2\}*" then do:
                    if v-sum2 <> 0 then do:
                        sum = replace(trim(string(v-sum2,'>>>,>>9.99')),',',' ').
                        v-str = replace (v-str, "\{v-sum2\}", sum).
                    end.
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
                        /*v-amt = trim(replace(string(deci(lch.value1),'>>>>>>>>9.99'),'.',',')).*/
                        v-amt = replace(trim(string(deci(lch.value1),'>>>,>>>,>>9.99')),',',' ').
                        v-str = replace (v-str, "\{v-amt\}", v-amt).
                    end.
                    else  v-str = replace (v-str, "\{v-amt\}", "0,00").
                    next.
                end.
                if v-str matches "*\{v-trnum\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-trnum\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-trnum\}", " ").
                    next.
                end.
                if v-str matches "*\{v-bankref\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'BankRef' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-bankref\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-bankref\}", " ").
                    next.
                end.
                if v-str matches "*\{v-princ\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-princ\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-princ\}", " ").
                    next.
                end.
                if v-str matches "*\{v-dtexp\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-dtexp\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-dtexp\}", " ").
                    next.
                end.
                if v-str matches "*\{v-seqtot\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'SeqTot' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-seqtot\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-seqtot\}", " ").
                    next.
                end.
                if v-str matches "*\{v-furid\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'FurId' no-lock no-error.
                    if avail lch then do:
                        find first codfr where codfr.codfr = 'pgfurid'
                                           and codfr.code =  lch.value1
                                           no-lock no-error.
                        if avail codfr then v-str = replace (v-str, "\{v-furid\}", codfr.name[1]).
                        else v-str = replace (v-str, "\{v-furid\}", lch.value1).
                    end.
                    else  v-str = replace (v-str, "\{v-furid\}", " ").
                    next.
                end.
                if v-str matches "*\{v-apprule\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'AppRule' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "\{v-apprule\}", lch.value1).
                    else  v-str = replace (v-str, "\{v-apprule\}", " ").
                    next.
                end.
                if v-str matches "*\{v-sign1\}*" then do:
                    /*find first pksysc where pksysc.sysc = 'mddir-r' no-lock no-error.
                    if avail pksysc then*/
                    v-str = replace (v-str, "\{v-sign1\}", 'Начальник ОП и ТФ Райжанова Д.Б.').
                    /*else  v-str = replace (v-str, "\{v-sign1\}", " ").*/
                    next.
                end.
                if v-str matches "*\{v-sign2\}*" then do:
                    find first pksysc where pksysc.sysc = 'mdchief' no-lock no-error.
                    if avail pksysc then v-str = replace (v-str, "\{v-sign2\}", 'Начальник ОДО ' + ' ' + pksysc.chval).
                    else  v-str = replace (v-str, "\{v-sign2\}", " ").
                    next.
                end.
                if v-str matches "*\{v-detgar\}*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DetGar' no-lock no-error.
                    if avail lch then do:
                        v-str = replace (v-str, "\{v-detgar\}", lch.value1).
                        v-str = replace (v-str, chr(1), "<br>").
                    end.
                    else  v-str = replace (v-str, "\{v-detgar\}", " ").
                end.
                if v-str matches "*\{v-sum\}*" then do:
                    sum = replace(trim(string(v-sum,'>>>,>>9.99')),',',' ').
                    v-str = replace (v-str, "\{v-sum\}", sum).
                end.

                if v-str matches "*\{v-mt\}*" then do:
                   find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' no-lock no-error.
                   if avail lch then do:
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

                        if index(sw-text[i],"\{2:O760") > 0 then do:
                            find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,11) no-lock no-error.
                            if not avail swibic
                            then find first swibic where swibic.bic = substr(sw-text[i],index(sw-text[i],"\{2:O7") + 17,8) + 'XXX' no-lock no-error.
                            if not avail swibic then next.
                            v-text = codific.codfr + ': ' + codific.name  + '<br/>'
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
                   /*else v-text = 'ЦИТАТА'  + '<br/>'.

                    v-text = v-text  + '<br/>'  + '<br/>' + 'КОНЕЦ ЦИТАТЫ'  + '<br/>'  + '<br/>' +
                  'Пожалуйста тщательно ознакомьтесь с деталями данной гарантии. Если Вы не готовы'  + '<br/>' +
                  'выполнить какое либо из условий гарантии Вам следует связаться с Принципалом или'  + '<br/>' +
                  'нашим банком для внесения соответствующих поправок / уточнений / изменений в условия'  + '<br/>' +
                  'гарантии. '  + '<br/>'  + '<br/>' +
                  'С Уважением,'  + '<br/>' +
                  'АО «МЕТРОКОМБАНК»'  + '<br/>'  + '<br/>'.*/
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
end case.