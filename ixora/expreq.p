/* pcfundc.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Заявления
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
*/

def shared var v-cifcod   as char no-undo.
def shared var s-credtype as char.
def shared var v-bank     as char no-undo.
def shared var s-ln       as inte no-undo.

def stream out.
def var v-select as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-date   as char no-undo.
def var v-mon    as inte no-undo.
def var v-fname  as char no-undo.
def var v-staj   as char no-undo.

def var v-month  as char no-undo init 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря'.
def var v-day  as char no-undo init 'Первое,Второе,Третье,Четвертое,Пятое,Шестое,Седьмое,Восьмое,Девятое,Десятое,
Одиннадцатое,Двенадцатое,Тринадцатое,Четырнадцатое,Пятнадцатое,Шестнадцатое,Семнадцатое,Восемнадцатое,Девятнадцатое,Двадцатое,
Двадцать первое,Двадцать второе,Двадцать третье,Двадцать четвертое,Двадцать пятое,Двадцать шестое,Двадцать седьмое,Двадцать восьмое,Двадцать девятое,Тридцатое,
Тридцать первое'.


do while true on endkey undo, return:
    run sel2 ("Выберите :", " 1. Заявление на предост. ЭК и открытие счета | 2. Заявление на полное/частичное доср.погашение | 3. Согласие ГЦВП и КБ  | 4. Выход ", output v-select).
    case v-select:
        when 1 then v-fname = 'expreqpred.htm'.
        when 2 then v-fname = 'expreqpog.htm'.
        when 3 then v-fname = 'pcsalagreem.htm'.
        when 4 then return.
    end.

    if v-select <> 0 then do:
        v-infile  = "/data/docs/" + v-fname.
        v-ofile = "Request.htm".
        output stream out to value(v-ofile).

        find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.credtype = s-credtype and pkanketa.ln = s-ln no-lock no-error.
        if pkanketa.sts = '111' then do:
            message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
            return.
        end.
        find first pcstaff0 where pcstaff0.cif = v-cifcod and pcstaff0.iin = pkanketa.rnn no-lock no-error.
            input from value(v-infile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:

                    if v-str matches "*v-iin*" then do:
                       v-str = replace (v-str, "v-iin", pcstaff0.iin).
                       next.
                    end.

                    if v-str matches "*v-work*" then do:
                       find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                       if pcstaff0.cifb begins "txb" then  v-str = replace (v-str, "v-work", "AO 'ForteBank'").
                       else do:
                           if avail cif then v-str = replace (v-str, "v-work", cif.prefix + ' ' + cif.name).
                           else v-str = replace (v-str, "v-work", '').
                       end.
                       next.
                    end.

                    if v-str matches "*v-name*" then do:
                       v-str = replace (v-str, "v-name", pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname).
                       next.
                    end.

                    if v-str matches "*v-telh*" then do:
                       v-str = replace (v-str, "v-telh", pcstaff0.tel[1]).
                       next.
                    end.

                    if v-str matches "*v-telm*" then do:
                       v-str = replace (v-str, "v-telm", pcstaff0.tel[2]).
                       next.
                    end.

                    if v-str matches "*v-nomdoc*" then do:
                       v-str = replace (v-str, "v-nomdoc", pcstaff0.nomdoc).
                       next.
                    end.

                    if v-str matches "*v-issdoc*" then do:
                       v-str = replace (v-str, "v-issdoc", substr(pcstaff0.issdoc,1,25)).
                       next.
                    end.

                    if v-str matches "*v-iday*" then do:
                       v-date = string(pcstaff0.issdt,'99/99/9999').
                       v-str = replace (v-str, "v-iday", entry(1,v-date,'/')).
                       next.
                    end.

                    if v-str matches "*v-imon*" then do:
                       v-date = string(pcstaff0.issdt,'99/99/9999').
                       v-mon = int(entry(2,v-date,'/')).
                       v-str = replace (v-str, "v-imon", entry(v-mon,v-month,',')).
                       next.
                    end.

                    if v-str matches "*v-iyear*" then do:
                       v-date = string(pcstaff0.issdt,'99/99/9999').
                       v-str = replace (v-str, "v-iyear", entry(3,v-date,'/')).
                       next.
                    end.

                    if v-str matches "*v-eday*" then do:
                       v-date = string(pcstaff0.expdt,'99/99/9999').
                       v-str = replace (v-str, "v-eday", entry(1,v-date,'/')).
                       next.
                    end.

                    if v-str matches "*v-emon*" then do:
                       v-date = string(pcstaff0.expdt,'99/99/9999').
                       v-mon = int(entry(2,v-date,'/')).
                       v-str = replace (v-str, "v-emon", entry(v-mon,v-month,',')).
                       next.
                    end.

                    if v-str matches "*v-eyear*" then do:
                       v-date = string(pcstaff0.expdt,'99/99/9999').
                       v-str = replace (v-str, "v-eyear", entry(3,v-date,'/')).
                       next.
                    end.


                    if v-str matches "*v-mail*" then do:
                       v-str = replace (v-str, "v-mail", string(pcstaff0.mail)).
                       next.
                    end.

                    if v-str matches "*v-educat*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'educat' no-lock no-error.
                       if avail pkanketh then v-str = replace (v-str, "v-educat", pkanketh.value1).
                       else v-str = replace (v-str, "v-educat", '').
                       next.
                    end.

                    if v-str matches "*v-marsts*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'emarsts' no-lock no-error.
                       if avail pkanketh then v-str = replace (v-str, "v-marsts", pkanketh.value1).
                       else v-str = replace (v-str, "v-marsts", '').
                       next.
                    end.

                    if v-str matches "*v-spwsta*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'espwork' no-lock no-error.
                       if avail pkanketh then do:
                           if pkanketh.value1 = 'yes' then v-str = replace (v-str, "v-spwsta", 'да').
                           else if pkanketh.value1 = 'no' then v-str = replace (v-str, "v-spwsta", 'нет').
                           else v-str = replace (v-str, "v-spwsta", '').
                       end.
                       else v-str = replace (v-str, "v-spwsta", '').
                       next.
                    end.

                    if v-str matches "*v-depent*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'echildn' no-lock no-error.
                       if avail pkanketh then v-str = replace (v-str, "v-depent", pkanketh.value1).
                       else v-str = replace (v-str, "v-depent", '').
                       next.
                    end.

                    if v-str matches "*v-depend1*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'echildl' no-lock no-error.
                       if avail pkanketh then v-str = replace (v-str, "v-depend1", pkanketh.value1).
                       else v-str = replace (v-str, "v-depend1", '').
                       next.
                    end.

                    if v-str matches "*v-stjl*" then do:
                       v-staj = ''.
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'experl' no-lock no-error.
                       if avail pkanketh then do:
                           if inte(pkanketh.value1) >= 6 and inte(pkanketh.value1) < 12 then v-staj = 'от 6 мес. до 1 года'.
                           if inte(pkanketh.value1) >= 12 and inte(pkanketh.value1) < 36 then v-staj = 'от 1 года до 3 лет'.
                           if inte(pkanketh.value1) >= 36 and inte(pkanketh.value1) < 60 then v-staj = 'от 3 лет до 5 лет'.
                           if inte(pkanketh.value1) >= 60 then v-staj = 'свыше 5 лет'.
                       end.
                       v-str = replace (v-str, "v-stjl",v-staj).
                       next.
                    end.

                    if v-str matches "*v-stjt*" then do:
                       v-staj = ''.
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'experlob' no-lock no-error.
                       if avail pkanketh then do:
                           if inte(pkanketh.value1) >= 6 and inte(pkanketh.value1) < 12 then v-staj = 'от 6 мес. до 1 года'.
                           if inte(pkanketh.value1) >= 12 and inte(pkanketh.value1) < 36 then v-staj = 'от 1 года до 3 лет'.
                           if inte(pkanketh.value1) >= 36 and inte(pkanketh.value1) < 60 then v-staj = 'от 3 лет до 5 лет'.
                           if inte(pkanketh.value1) >= 60 then v-staj = 'свыше 5 лет'.
                       end.
                       v-str = replace (v-str, "v-stjt", v-staj).
                       next.
                    end.

                    /**********************agreement******************************/
                    if v-str matches "*v-addr1*" then do:
                       v-str = replace (v-str, "v-addr1", pcstaff0.addr[1]).
                       next.
                    end.

                    if v-str matches "*v-issdt*" then do:
                       v-str = replace (v-str, "v-issdt", string(pcstaff0.issdt)).
                       next.
                    end.

                    if v-str matches "*v-expdt*" then do:
                       v-str = replace (v-str, "v-expdt", string(pcstaff0.expdt)).
                       next.
                    end.

                    if v-str matches "*v-birthdt*" then do:
                       v-str = replace (v-str, "v-birthdt", string(pcstaff0.birth)).
                       next.
                    end.

                    if v-str matches "*v-birtplc*" then do:
                       v-str = replace (v-str, "v-birtplc", pcstaff0.bplace).
                    end.

                    if v-str matches "*v-nomer*" then do:
                       v-str = replace (v-str, "v-nomer", string(pkanketa.ln)).
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

                    if v-str matches "*v-goal*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'evidfin' no-lock no-error.
                       if avail pkanketh then do:
                           if pkanketh.value1 = 'кредит' then v-str = replace (v-str, "v-goal", 'Потребительские цели').
                           if pkanketh.value1 = 'рефинансирование' then v-str = replace (v-str, "v-goal", 'Рефинансирование кредита').
                       end.
                       next.
                    end.

                    if v-str matches "*v-sum*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'esumtr' no-lock no-error.
                       if avail pkanketh then  v-str = replace (v-str, "v-sum", pkanketh.value1).
                       else v-str = replace (v-str, "v-sum", '').
                       next.
                    end.

                    if v-str matches "*v-srok*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'esroktr' no-lock no-error.
                       if avail pkanketh then  v-str = replace (v-str, "v-srok", pkanketh.value1).
                       else v-str = replace (v-str, "v-srok", '').
                       next.
                    end.

                    if v-str matches "*v-stav*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'eratrew' no-lock no-error.
                       if avail pkanketh then  v-str = replace (v-str, "v-stav", pkanketh.value1).
                       else v-str = replace (v-str, "v-stav", '').
                       next.
                    end.

                    if v-str matches "*v-met*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'emetam' no-lock no-error.
                       if avail pkanketh then  v-str = replace (v-str, "v-met", pkanketh.value1).
                       else v-str = replace (v-str, "v-met", '').
                       next.
                    end.

                    if v-str matches "*v-issu*" then do:
                       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'eissu' no-lock no-error.
                       if avail pkanketh then  v-str = replace (v-str, "v-issu", pkanketh.value1).
                       else v-str = replace (v-str, "v-issu", '').
                       next.
                    end.

                    if v-str matches "*vregn*" then do:
                       v-str = replace (v-str, "vregn", substr(pkanketa.bank,4) + '/' + string(pkanketa.ln)).
                       next.
                    end.

                    leave.
                end. /* repeat */
            /*end.*/
            put stream out unformatted v-str skip.
        end. /* repeat */
        input close.
        /********/
        output stream out close.

        unix silent value("cptwin " + v-ofile + " winword").
        unix silent value("rm -r " + v-ofile).
    end.
end.

