/* dcdocs .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC - формирование документов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-1 опция Docs
 * AUTHOR
        04/01/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        10/02/2012 id00810 -  - для ODC
        06.03.2012 Lyubov  - "dc" изменила на "idc"
        24.05.2012 Lyubov  - для idc берем шаблон ApplDC
        21.06.2012 Lyubov  - поправила формат суммы
 */

{global.i}
def shared var s-lc     like lc.lc.
def shared var s-lcprod as char.
def var v-list   as char no-undo.
def var v-sel    as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def var i        as int  no-undo.
def var k        as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-amt    as char no-undo.
def var v-name   as char no-undo.
def var v-crcc   as char no-undo.
def var v-docum  as char no-undo.
def var v-doc    as char no-undo extent 2.
def stream out.

def new shared var s-jh     like jh.jh .

if s-lcprod = 'idc' then assign v-list = ' MT 410 | Cover Sheet | Авизование | Payment Order '
                               v-doc[1] = "ApplDC.htm"
                               v-doc[2] = "idc.htm" .
else assign v-list = ' Payment Order | Internal Cover Sheet | External Cover Sheet '
            v-doc[1] = "ApplODC.htm"
            v-doc[2] = "odc.htm" .
run sel2('Docs',v-list, output v-sel).
case v-sel:
    when 1 then do:
        if s-lcprod = 'idc' then  do:
            find first lch where lch.lc = s-lc  and lch.kritcode = 'MT410' no-lock no-error.
            if avail lch and lookup(lch.value1,v-logsno) > 0 then do:
                message 'Your choice had not been to create this type of document!' view-as alert-box.
                return.
            end.
            else do:
                run lcmtlch ('410',no).
            end.
        end.
        else do:
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
    end.

    when 2 then do:
        assign v-infile  =  "/data/docs/" + v-doc[1]
               v-ofile   = v-doc[1].
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
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Client' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-clname", trim(substr(lch.value1,1,35))).
                    else  v-str = replace (v-str, "v-clname", "___________________").
                    next.
                end.
                if v-str matches "*v-ben*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'Drawer' no-lock no-error.
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
                            if avail crc then v-amt = v-amt + ' ' + crc.code.
                        end.
                        v-str = replace (v-str, "v-amt", v-amt).
                    end.
                    else  v-str = replace (v-str, "v-amt", "0.00").
                    next.
                end.
                if v-str matches "*v-rembank*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'RemBank' no-lock no-error.
                    if avail lch then do:
                        find first swibic where swibic.bic = lch.value1 no-lock no-error.
                        if avail swibic then v-str = replace (v-str, "v-rembank", swibic.name).
                        else  v-str = replace (v-str, "v-rembank", " ").
                    end.
                    else  v-str = replace (v-str, "v-rembank", " ").
                    next.
                end.
                if v-str matches "*v-dtadv*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtAdv' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtadv", lch.value1).
                    else  v-str = replace (v-str, "v-dtadv", " ").
                    next.
                end.
                if v-str matches "*v-dtexp*" then do:
                    find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                    if avail lch then v-str = replace (v-str, "v-dtexp", lch.value1).
                    else  v-str = replace (v-str, "v-dtexp", " ").
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
        output stream out close.

        unix silent value("cptwin " + v-ofile + " winword").
        unix silent value("rm -r " + v-ofile).
    end.
    when 3 then do:
            assign v-infile  = "/data/docs/" + v-doc[2]
                   v-ofile = v-doc[2].

            /*v-sum = 0.*/
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then do:
                find first crc where crc.crc = integer(lch.value1) no-lock no-error.
                if avail crc then v-crcc = crc.code.
            end.

            output stream out to value(v-ofile).
            /********/

            input  from value(v-infile).
            repeat:
                import  unformatted v-str.
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
                    if v-str matches "*\{v-rembank\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'RemBank' no-lock no-error.
                        if avail lch then do:
                            find first swibic where swibic.bic = lch.value1 no-lock no-error.
                            if avail swibic then v-str = replace (v-str, "\{v-rembank\}",  swibic.name + ',' + swibic.cnt).
                            else v-str = replace (v-str, "\{v-rembank\}", lch.value1).
                        end.
                        else  v-str = replace (v-str, "\{v-rembank\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-docs\}*" then do:
                        if v-docum = '' then do:
                            find first lch where lch.lc = s-lc and lch.kritcode = 'Docs' no-lock no-error.
                            if avail lch then do:
                                assign k = length(lch.value1)
                                       i = 1.
                                repeat:
                                    v-docum = v-docum + trim(substr(lch.value1,i,55)) +  '<br/>'.
                                    k = k - 55.
                                    if k <= 0 then leave.
                                    i = i + 55.
                                end.
                            end.
                        end.
                        v-str = replace (v-str, "\{v-docs\}", v-docum).
                        next.
                    end.
                    if v-str matches "*\{v-by\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
                        if avail lch then do:
                            find first LCkrit where LCkrit.dataCode = lch.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
                            if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
                                find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = lch.value1 no-lock no-error.
                                if avail codfr then do:
                                    if s-lcprod = 'idc' then v-str = replace (v-str, "\{v-by\}", codfr.name[2]).
                                    else v-str = replace (v-str, "\{v-by\}", lc(codfr.name[1])).
                                end.
                                else  v-str = replace (v-str, "\{v-by\}", " ").
                            end.
                            else  v-str = replace (v-str, "\{v-by\}", " ").
                        end.
                        else  v-str = replace (v-str, "\{v-by\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-tenor\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Tenor' no-lock no-error.
                        if avail lch then do:
                            find first LCkrit where LCkrit.dataCode = lch.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
                            if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
                                find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = lch.value1 no-lock no-error.
                                if avail codfr then v-str = replace (v-str, "\{v-tenor\}", codfr.name[2]).
                                else  v-str = replace (v-str, "\{v-tenor\}", " ").
                            end.
                            else  v-str = replace (v-str, "\{v-tenor\}", " ").
                        end.
                        else  v-str = replace (v-str, "\{v-tenor\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-text\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
                        if avail lch then do:
                            if lch.value1 = '1' then v-str = replace (v-str, "\{v-text\}", 'обеспечить сумму документов на текущем счете клиента в ' + v-crcc + ' для дальнейшей оплаты.').
                            else v-str = replace (v-str, "\{v-text\}", 'произвести акцепт документов/переводного векселя и оплатить указанную сумму.').
                        end.
                        else  v-str = replace (v-str, "\{v-text\}", " ").
                        next.
                    end.

                    if v-str matches "*\{v-benef\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Client' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-benef\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-benef\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-client\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Client' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-client\}", trim(substr(lch.value1,1,35))).
                        else  v-str = replace (v-str, "\{v-client\}", " ").
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
                    if v-str matches "*\{v-drawer\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Drawer' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-drawer\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-drawer\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-drawer1\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'Drawer' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-drawer1\}", trim(substr(lch.value1,1,35))).
                        else  v-str = replace (v-str, "\{v-drawer1\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-trnum\}*" then do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'TRNum' no-lock no-error.
                        if avail lch then v-str = replace (v-str, "\{v-trnum\}", lch.value1).
                        else  v-str = replace (v-str, "\{v-trnum\}", " ").
                        next.
                    end.
                    if v-str matches "*\{v-pusto\}*" then v-str = replace (v-str, "\{v-pusto\}", '').
                    leave.
                end.
                put stream out unformatted v-str skip.
            end.

            input  close.
            output stream out close.

            unix silent value('cptwin ' + v-ofile + ' winword').
            unix silent value('rm -f ' + v-ofile).

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