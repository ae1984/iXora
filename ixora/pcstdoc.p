/* pcstdoc.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff, Salary: Печать заявлений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-2
 * AUTHOR
        29/05/2012 id00810
 * BASES
 		BANK COMM
 * CHANGES
        23/08/2012 id00810 - доработка для Salary, переход на ИИН
        25/12/2012 id00810 - перкомпиляция
        13.05.2013 Lyubov  - ТЗ № 1539, добавлено согласие в ГЦВП и КБ, заявление на ДУ, заявление на выдачу карт/пин-конверта
        01.08.2013 Lyubov  - ТЗ 1941, в заявление подтягиеваем резидество из salary-файла
        05/08/2013 galina - ТЗ1912 выводим не полный номер карточки согласно требованиям безопасности
        29.11.2013 Lyubov - ТЗ 1878, вывод всех документов в одном окне MS Word

*/

def var v-select  as int  no-undo.
def var v-bank    as char no-undo.
def var v-rnn     as char no-undo.
def var v-iin     as char no-undo.
def var v-str     as char no-undo.
def var v-name    as char no-undo.
def var v-latname as char no-undo.
def var v-mail    as char no-undo.
def var v-addr1   as char no-undo.
def var v-addr2   as char no-undo.
def var v-work    as char no-undo.
def var v-birthdt as char no-undo.
def var v-birtplc as char no-undo.
def var v-schet   as char no-undo.
def var v-tel     as char no-undo.
def var v-telh    as char no-undo.
def var v-telm    as char no-undo.
def var v-cword   as char no-undo.
def var v-nomdoc  as char no-undo.
def var v-issdt   as char no-undo.
def var v-expdt   as char no-undo.
def var v-issdoc  as char no-undo.
def var v-infile  as char no-undo.
def var v-ofile   as char no-undo init 'zayav.htm'.
def var v-ofile1  as char no-undo init 'zayavvv.htm'.
def var v-rezid   as char no-undo.
def var v-crcc    as char no-undo.
def var v-type    as char no-undo.
def var i         as int  no-undo.
def var v-txt     as char no-undo init 'ИИН'.
def var v-txt1    as char no-undo.
def var v-dir     as char no-undo.
def var v-label   as char no-undo init ' ИИН клиента '.
def var v-nomer   as char no-undo.
def var v-yes     as logi no-undo init no.
def buffer b-pcstaff0 for pcstaff0.
def stream v-out.

def var v-month  as char no-undo init 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря'.
def var v-day  as char no-undo init 'Первое,Второе,Третье,Четвертое,Пятое,Шестое,Седьмое,Восьмое,Девятое,Десятое,
Одиннадцатое,Двенадцатое,Тринадцатое,Четырнадцатое,Пятнадцатое,Шестнадцатое,Семнадцатое,Восемнадцатое,Девятнадцатое,Двадцатое,
Двадцать первое,Двадцать второе,Двадцать третье,Двадцать четвертое,Двадцать пятое,Двадцать шестое,Двадцать седьмое,Двадцать восьмое,Двадцать девятое,Тридцатое,
Тридцать первое'.

def frame f-rnn skip(1)
  v-label no-label format 'x(13)'
  v-rnn   no-label format "x(12)" colon 12 help "Введите значение (12 цифр)" /* клиента; F2- помощь; F4-выход"*/
  with  centered side-label row 7 title 'Печать документов'.

{global.i}
{nbankBik.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.

unix silent value("rm -f " + v-ofile).

on help of v-rnn in frame f-rnn do:
    {itemlist.i
         &set     = "iin"
         &file    = "pcstaff0"
         &frame   = "row 7 centered scroll 1 10 down width 55 overlay "
         &where   = " pcstaff0.bank = v-bank "
         &flddisp = " pcstaff0.iin label 'ИИН' format 'x(12)' pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname label 'ФИО клиента' format 'x(40)' "
         &chkey   = "iin"
         &index   = "iin"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
    v-rnn = pcstaff0.iin.
    displ v-rnn with frame f-rnn.
end.

repeat:
    assign v-select = 0
           v-rnn    = ''
           i        = 0.
    run sel2 (" Печать документов ", "1. По одному клиенту (" + v-txt + ") |2. По всем новым клиентам |3. Выход ", output v-select).
    if keyfunction (lastkey) = "end-error" then return.
    case v-select:
        when 1 then do:
            displ v-label with frame f-rnn.
            update v-rnn with frame f-rnn.
            find first pcstaff0 where pcstaff0.bank = v-bank  and pcstaff0.iin = v-rnn no-lock no-error.
            if not avail pcstaff0 then do:
                message "Нет данных для печати по клиенту с таким " + v-txt + "!" view-as alert-box title " Внимание! ".
                next.
            end.
        end.
        when 2 then do:
            v-rnn = '*'.
        end.
        otherwise return.
    end.
    if v-rnn = '*' then do:
        find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.sts = 'new' no-lock no-error.
        if not avail pcstaff0 then do:
            message "Нет новых клиентов!" view-as alert-box title " Внимание! ".
            return.
        end.
    end.

    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
    if avail pksysc then v-dir = pksysc.chval.

    find first cmp no-lock no-error.

    for each pcstaff0 where pcstaff0.bank = v-bank and ((pcstaff0.sts = 'new' and v-rnn = '*') or pcstaff0.iin = v-rnn) no-lock.
        i = i + 1.
        assign v-name    = caps(pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname)
               v-latname = pcstaff0.namelat
               v-mail    = pcstaff0.mail
               v-cword   = pcstaff0.cword
               v-addr1   = pcstaff0.addr[1]
               v-addr2   = pcstaff0.addr[2]
               v-telh    = pcstaff0.tel[1]
               v-telm    = pcstaff0.tel[2]
               v-nomdoc  = pcstaff0.nomdoc
               v-issdt   = string(pcstaff0.issdt,'99/99/9999')
               v-expdt   = if pcstaff0.expdt ne ? then string(pcstaff0.expdt,'99/99/9999') else ' __/__/____'
               v-issdoc  = pcstaff0.issdoc
               v-iin     = pcstaff0.iin
               v-birthdt = string(pcstaff0.birth,'99/99/9999')
               v-birtplc = pcstaff0.bplace
               v-schet   = pcstaff0.aaa
               v-type    = ''
               v-rezid   = if pcstaff0.rez then 'резидент' else 'нерезидент'.

        find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = pcstaff0.aaa and pkanketa.rnn = pcstaff0.iin no-lock no-error.
        if avail pkanketa then v-nomer = string(pkanketa.ln).

        if pcstaff0.cifb = v-bank then v-work = replace(cmp.name,'"',"'").
        else do:
            if pcstaff0.cifb begins 'txb' then v-work = v-nbankru.
            else do:
                find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                if avail cif then v-work = cif.name.
            end.
        end.
        v-work = replace(v-work,'"',"'").
        find first crc where crc.crc = pcstaff0.crc no-lock no-error.
        if avail crc then v-crcc = crc.code.
        find first codfr where codfr.codfr =  'pctype'
                           and codfr.code  = pcstaff0.pctype
                           no-lock no-error.
        if avail codfr then v-type = codfr.name[1].

        if pcstaff0.sts <> "OK" then do:
            if pcstaff0.bplace <> '' and pcstaff0.salary <> 0 and pcstaff0.hdt <> ? then do:
                v-infile = pksysc.chval + 'pcsalagreem.htm'.
                {pcstdoc.i}
                output stream v-out close.
                output stream v-out to value(v-ofile1).

                input from value(v-ofile).
                repeat:
                    import unformatted v-str.
                    v-str = trim(v-str).
                    repeat:
                        if v-str matches "*</body>*" then do:
                            v-str = replace(v-str,"</body>","").
                            next.
                        end.
                        if v-str matches "*</html>*" then do:
                            v-str = replace(v-str,"</html>","").
                            next.
                        end.
                        if v-str matches "*v-day*" then do:
                           v-str = replace (v-str, "v-day", entry(day(pcstaff0.birth),v-day,',')).
                           next.
                        end.

                        if v-str matches "*v-month*" then do:
                           v-str = replace (v-str, "v-month", entry(month(pcstaff0.birth),v-month,',')).
                           next.
                        end.

                        if v-str matches "*y1*" then do:
                           v-str = replace (v-str, "y1", substr(string(year(pcstaff0.birth),'9999'),1,1)).
                           next.
                        end.

                        if v-str matches "*y2*" then do:
                           v-str = replace (v-str, "y2", substr(string(year(pcstaff0.birth),'9999'),2,1)).
                           next.
                        end.

                        if v-str matches "*y3*" then do:
                           v-str = replace (v-str, "y3", substr(string(year(pcstaff0.birth),'9999'),3,1)).
                           next.
                        end.

                        if v-str matches "*y4*" then do:
                           v-str = replace (v-str, "y4", substr(string(year(pcstaff0.birth),'9999'),4,1)).
                           next.
                        end.
                        else v-str = trim(v-str).
                        leave.
                    end.
                    put stream v-out unformatted v-str skip.
                end.
                input close.
                output stream v-out close.
            end.

            v-infile = pksysc.chval + (if pcstaff0.pcprod = 'salary' then 'pccredreq.htm' else 'pcstzayav.htm').
            {pcstdoc.i}
            output stream v-out close.
            output stream v-out to value(v-ofile1).
            input from value(v-ofile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream v-out unformatted v-str skip.
            end.
            input close.
            output stream v-out close.

            v-infile = pksysc.chval + 'pcreqdop.htm'.
            {pcstdoc.i}
            output stream v-out close.
            output stream v-out to value(v-ofile1).
            input from value(v-ofile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream v-out unformatted v-str skip.
            end.
            input close.
            output stream v-out close.
        end.
        if pcstaff0.sts = "OK" then do:
            v-infile = pksysc.chval + 'pcsalpin.htm'.
            {pcstdoc.i}
            output stream v-out close.
            output stream v-out to value(v-ofile1).
            input from value(v-ofile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*v-cexp*" then do:
                        find first pccards where pccards.aaa = pcstaff0.aaa and pccards.sts <> 'Closed' no-lock no-error.
                        if avail pccards then v-str = replace(v-str,"v-cexp",string(pccards.expdt)).
                        next.
                    end.
                    if v-str matches "*v-card*" then do:
                        v-str = replace(v-str,"v-card", substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13,4)).
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream v-out unformatted v-str skip.
            end.
            input close.
            output stream v-out close.

        end.
        v-yes = yes.
    end.

    unix silent value("cptwin " + v-ofile1 + " winword").
    unix silent value("rm -f " + v-ofile).
    unix silent value("rm -f " + v-ofile1).

    if v-yes then do:
        for each pcstaff0 where pcstaff0.bank = v-bank and ((pcstaff0.sts = 'new' and v-rnn = '*') or pcstaff0.iin = v-rnn) no-lock.
            if pcstaff0.sts = 'new' then do:
                find first b-pcstaff0 where recid(b-pcstaff0) = recid(pcstaff0) exclusive-lock no-error.
                b-pcstaff0.sts = 'print'.
                find current b-pcstaff0 no-lock no-error.
            end.
        end.
    end.
end.
