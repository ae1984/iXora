/* pcfundc.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff, Salary: Редактирование данных, открытие карточек и счетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        08.02.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        05/08/2013 galina - ТЗ1912 выводим не полный номер карточки согласно требованиям безопасности
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF

*/

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.

def stream out.
def var v-select as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var v-fname  as char no-undo.
def var v-month  as char no-undo init 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря'.
def var v-day  as char no-undo init 'Первое,Второе,Третье,Четвертое,Пятое,Шестое,Седьмое,Восьмое,Девятое,Десятое,
Одиннадцатое,Двенадцатое,Тринадцатое,Четырнадцатое,Пятнадцатое,Шестнадцатое,Семнадцатое,Восемнадцатое,Девятнадцатое,Двадцатое,
Двадцать первое,Двадцать второе,Двадцать третье,Двадцать четвертое,Двадцать пятое,Двадцать шестое,Двадцать седьмое,Двадцать восьмое,Двадцать девятое,Тридцатое,
Тридцать первое'.


do while true on endkey undo, return:
    run sel2 ("Выберите :", " 1. Заявление на установление кредитного лимита | 2. Заявление на изменение кред. лимита | 3. Заявление на закрытие кредитного лимита | 4. Заявление на доп. услуги | 5. Согласие ГЦВП и КБ | 6. Выход ", output v-select).
    case v-select:
        when 1 then v-fname = 'estabreq.htm'.
        when 2 then v-fname = 'changreq.htm'.
        when 3 then v-fname = 'closereq.htm'.
        when 4 then v-fname = 'pcreqdop.htm'.
        when 5 then v-fname = 'pcsalagreem.htm'.
        when 6 then return.
    end.

    v-infile  = "/data/docs/" + v-fname.
    v-ofile = "Request.htm".
    output stream out to value(v-ofile).

    find first pcstaff0 where pcstaff0.aaa = v-aaa and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
    find first pkanketa where pkanketa.aaa = pcstaff0.aaa and pkanketa.credtype = s-credtype no-lock no-error.
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
               v-str = replace (v-str, "v-work", cif.prefix + ' ' + cif.name).
               next.
            end.

            if v-str matches "*v-name*" then do:
               v-str = replace (v-str, "v-name", pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname).
               next.
            end.

            if v-str matches "*v-addr1*" then do:
               v-str = replace (v-str, "v-addr1", pcstaff0.addr[1]).
               next.
            end.

            if v-str matches "*v-addr2*" then do:
               v-str = replace (v-str, "v-addr2", pcstaff0.addr[2]).
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

            if v-str matches "*v-issdt*" then do:
               v-str = replace (v-str, "v-issdt", string(pcstaff0.issdt)).
               next.
            end.

            if v-str matches "*v-expdt*" then do:
               v-str = replace (v-str, "v-expdt", string(pcstaff0.expdt)).
               next.
            end.

            if v-str matches "*v-card*" then do:
               v-str = replace (v-str, "v-card", string(substr(pcstaff0.pcard,1,6) + '******' + substr(pcstaff0.pcard,13,4))).
               next.
            end.

            if v-str matches "*v-contract*" then do:
               v-str = replace (v-str, "v-contract", pkanketa.rescha[1]).
               next.
            end.

            if v-str matches "*v-contrdt*" then do:
               v-str = replace (v-str, "v-contrdt", string(pkanketa.resdat[1])).
               next.
            end.

            if v-str matches "*v-schet*" then do:
               v-str = replace (v-str, "v-schet", pcstaff0.aaa).
               next.
            end.

            if v-str matches "*v-mail*" then do:
               v-str = replace (v-str, "v-mail", pcstaff0.mail).
               next.
            end.

            if v-str matches "*v-nomdoc*" then do:
               v-str = replace (v-str, "v-nomdoc", pcstaff0.nomdoc).
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
