/* a_rep.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчеты по клиентским операциям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
	BANK COMM
 * AUTHOR
        14/02/2012 Luiza
 * CHANGES
            23/08/2012 Luiza - добавила 100100 для обменных операций
            18.09.2012 Lyubov - ТЗ 1500, добавлена курсовая разница и тип операции
*/


{mainhead.i}

def var v-op as int.
def var v-op1 as int.
def var v-op3 as int.
def new shared var v-ch as int.
def new shared var v-dt1 as date.
def new shared var v-dt2 as date.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def var ch as char.
def new shared var v-sh as char.

def stream v-out.
def var prname as char.

run sel2 ("Выберите :", " 1. Переводные операции | 2. Кассовые операции | 3. Комиссии и урегулирование вознаграждений
                        | 4. Обменные операции | 5. Выход ", output v-op).
if keyfunction (lastkey) = "end-error" then return.
if (v-op < 1) or (v-op > 4) then return.

if v-op = 3 then do:
    run sel2 ("Выберите удержание комиссии:", " 1. Удержание комиссии со счета клиента | 2. Удержание комиссии без открытия счета
    | 3. Урегулирование вознаграждений | 4. Выход ", output v-op3).
    if keyfunction (lastkey) = "end-error" then return.
    if (v-op3 < 1) or (v-op3 > 3) then return.
end.
if v-op3 <> 1 and v-op3 <> 3 /*and v-op <> 4*/ then do:
    run sel2 ("Сформировать отчет :", " 1. По счету ГК 100100 | 2. По счету ГК 100500 | 3. По счетам ГК 100100 и 100500
                            | 4. Выход ", output v-ch).
    if keyfunction (lastkey) = "end-error" then return.
    if (v-ch < 1) or (v-ch > 3) then return.
end.

def frame f-date
   v-dt1 label "Начало" format "99/99/99" validate(v-dt1 <= today, "Некорректная дата!") skip
   v-dt2 label "Конец " format "99/99/99" /*validate(v-dt2 >= v-dt1,"Некорректная дата!")*/ skip
with side-labels centered row 7 title "Параметры отчета".
update  v-dt1 v-dt2 with frame f-date.

case v-op:
    when 1 then do:
        run sel2 ("Выберите Переводные операции:", " 1. Переводы без открытия счета | 2. Быстрые переводы | 3. Выход ", output v-op1).
        if keyfunction (lastkey) = "end-error" then return.
        if (v-op1 < 1) or (v-op1 > 2) then return.
        if v-op1 = 1 then do:
            define new shared temp-table wrk no-undo
                field v-fil as char
                field v-doc as char
                field v-jh as int
                field v-date as date
                field v-fio as char
                field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
                field v-sum2 as decim
                field v-sum3 as decim
                field v-sum4 as decim
                field v-sum6 as decim
                field v-sum as decim
                field v-sumk as decim
                field v-rem as char
                field v-countr as char
                field tip as char
                field v-sp as char
                field v-id as char
                index ind1 is primary v-fil v-sp v-doc.

            /*run txbs ("a_rep1").*/ /* переводы без открытия счета*/
            prname = "a_rep1".
        end.
        if v-op1 = 2 then do:
            define new shared temp-table wrk1 no-undo
                field v-fil as char
                field v-doc as char
                field v-jh as int
                field v-date as date
                field v-fio as char
                field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
                field v-sum2 as decim
                field v-sum3 as decim
                field v-sum4 as decim
                field v-sum6 as decim
                field v-sumk as decim
                field v-rem as char
                field v-countr as char
                field tip as char
                field sys as char
                field v-sp as char
                field v-id as char
                index ind1 is primary v-fil v-sp v-doc.

            /*run txbs ("a_rep2").  быстрые переводы */
            prname = "a_rep2".
        end.

    end.
    when 2 then do:
        define new shared temp-table wrk2 no-undo
            field v-fil as char
            field v-doc as char
            field v-jh as int
            field v-date as date
            field v-fio as char
            field v-crc as char
            field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
            field v-sum2 as decim format ">>>,>>>,>>>,>>>,>>9.99"
            field v-sum3 as decim format ">>>,>>>,>>>,>>>,>>9.99"
            field v-sumk as decim format ">>>,>>>,>>>,>>>,>>9.99"
            field v-rem as char
            field v-sp as char
            field v-id as char
            index ind1 is primary v-fil v-sp v-doc.

         /*run txbs ("a_rep3"). кассовые операции */
             prname = "a_rep3".
    end. /*  v-op = 2.*/
    when 3 then do:
        if v-op3 = 1 then do:
            define new shared temp-table wrk3 no-undo
                field v-fil as char
                field v-doc as char
                field v-jh as int
                field v-date as date
                field v-fio as char
                field v-chet as char
                field v-crck as char
                field v-sumk as decim format ">>>,>>>,>>>,>>>,>>9.99"
                field v-tar as char
                field v-rem as char
                field v-sp as char
                field v-id as char
                index ind1 is primary v-fil v-sp v-doc.
            /*run txbs ("a_rep4").  комиссии со счета */
            prname = "a_rep4".
        end.
        if v-op3 = 2 then do:
            define new shared temp-table wrk4 no-undo
                field v-fil as char
                field v-doc as char
                field v-jh as int
                field v-date as date
                field v-fio as char
                field v-crck as char
                field v-sumk as decim format ">>>,>>>,>>>,>>>,>>9.99"
                field v-tar as char
                field v-rem as char
                field v-sp as char
                field v-id as char
                index ind1 is primary v-fil v-sp v-doc.
            /*run txbs ("a_rep5").  комиссии без открытия счета */
            prname = "a_rep5".
        end.
        if v-op3 = 3 then do:

            run sel1 ("Выберите шаблон:", " 1. uni0025 | 2. uni0074  | 3. uni0093 | 4. uni0052
                                | 5. uni0068 | 6. uni0118 | 7. uni0163 | 8. vnb0024 | 9. Выход ").
            define new shared temp-table wrk5 no-undo
                field v-fil as char
                field v-uni as char
                field v-name as char
                field v-doc as char
                field v-jh as int
                field v-date as date
                field v-sum as decim format ">>>,>>>,>>>,>>>,>>9.99"
                field v-crc as char
                field v-chet as char
                field v-fio as char
                field v-rem as char
                field v-sp as char
                field v-id as char
                index ind1 is primary v-fil v-sp v-doc.
            /*run txbs ("a_rep6").  Урегулирование */
            prname = "a_rep6".
        end.
    end. /*  v-op = 3.*/
    when 4 then do:
        define new shared temp-table wrk6 no-undo
        field v-fil as char
        field v-doc as char
        field v-jh as int
        field v-date as date
        field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
        field v-crc1 as char
        field v-sum2 as decim format ">>>,>>>,>>>,>>>,>>9.99"
        field v-crc2 as char
        field v-rate as decim
        field v-exp as decim
        field v-rev as decim
        field v-rem as char
        field v-sp as char
        field v-id as char
        field v-type as char
        index ind1 is primary v-fil v-sp v-doc.
       /* run txbs ("a_rep7").  обменные операции */
            prname = "a_rep7".
    end. /*  v-op = 4.*/
    when 5 then return.
    OTHERWISE leave.
end case.  /* v-op */

{r-brfilial.i &proc = value(prname)}

if v-fil-int > 1 then v-fil-cnt = "консолидированный отчет".
if v-ch = 1 then ch = " по счету ГК 100100 ".
if v-ch = 2 then ch = " по счету ГК 100500 ".
if v-ch = 3 then ch = " по счетам ГК 100100 и 100500 ".

output stream v-out to a_rep.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    if v-op = 1 then do:
        if v-op1 = 1 then do:
            put stream v-out unformatted  "<h3>Отчет по переводам без открытия счета" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>№ Документа</B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ФИО<br>клиента </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>KZT </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>USD </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>EUR </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>RUB </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>GBP </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>прочие валюты </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Доход </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> назначение </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Страна<br>получения/отправл </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Тип </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
            "</tr>" skip.
            for each wrk break by wrk.v-fil:
                if first-of(wrk.v-fil) then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk.v-fil "</TD></TR>" skip.
                end.
                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk.v-doc "</TD>" skip
                "<TD align=""center"">" wrk.v-jh "</TD>" skip
                "<TD align=""left"">" wrk.v-date "</TD>" skip
                "<TD align=""left"">" wrk.v-fio "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum3,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum4,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum6,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk.v-sumk,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" wrk.v-rem "</TD>" skip
                "<TD align=""left"">" wrk.v-countr "</TD> " skip
                "<TD align=""center"">" wrk.tip "</TD>" skip
                "<TD align=""left"">" wrk.v-sp "</TD> " skip
                "<TD align=""left"">" wrk.v-id "</TD></TR>" skip.
            end.
            put stream v-out unformatted "</table>".
        end.
        if v-op1 = 2 then do:
            put stream v-out unformatted  "<h3>Отчет по быстрым переводам" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ФИО<br>клиента </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>KZT </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>USD </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>EUR </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>RUB </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>GBP </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Доход </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> назначение </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Страна<br>получения/отправл </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Тип </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Система </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
            "</tr>" skip.
            for each wrk1 break by wrk1.v-fil:
                if first-of(wrk1.v-fil) then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk1.v-fil "</TD></TR>" skip.
                end.
                put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk1.v-doc "</TD>" skip
                "<TD align=""center"">" wrk1.v-jh "</TD>" skip
                "<TD align=""left"">" wrk1.v-date "</TD>" skip
                "<TD align=""left"">" wrk1.v-fio "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sum1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sum2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sum3,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sum4,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sum6,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk1.v-sumk,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" wrk1.v-rem "</TD>" skip
                "<TD align=""left"">" wrk1.v-countr "</TD> " skip
                "<TD align=""left"">" wrk1.tip "</TD> " skip
                "<TD align=""left"">" wrk1.sys "</TD>" skip
                "<TD align=""left"">" wrk1.v-sp "</TD> " skip
                "<TD align=""left"">" wrk1.v-id "</TD></TR>" skip.
            end.
            put stream v-out unformatted "</table>".
        end.
    end.
    if v-op = 2 then do:
        put stream v-out unformatted  "<h3>Отчет по кассовым операциям" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
       put stream v-out unformatted "<tr align=center>"
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Клиент </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>прихода </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>расхода </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>инкассация </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Доход </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> назначение </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
        "</tr>" skip.
        for each wrk2 break by wrk2.v-fil:
            if first-of(wrk2.v-fil) then do:
                put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk2.v-fil "</TD></TR>" skip.
             end.
            put stream v-out  unformatted "<TR> <TD>" wrk2.v-doc "</TD>" skip
            "<TD align=""center"">" wrk2.v-jh "</TD>" skip
            "<TD align=""left"">" wrk2.v-date "</TD>" skip
            "<TD align=""left"">" wrk2.v-fio "</TD>" skip
            "<TD align=""left"">" wrk2.v-crc "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk2.v-sum1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk2.v-sum2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk2.v-sum3,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk2.v-sumk,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""left"">" wrk2.v-rem "</TD>" skip
            "<TD align=""left"">" wrk2.v-sp "</TD> " skip
            "<TD align=""left"">" wrk2.v-id "</TD></TR>" skip.
        end.
        put stream v-out unformatted "</table>".
    end.
    if v-op = 3 then do:
        if v-op3 = 1 then do:
            put stream v-out unformatted  "<h3>Отчет по комиссиям со счета клиента" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Клиент </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Счет клиента </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта<br>комиссии </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>комиссии </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Код<br>тарифа </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Назначение </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
            "</tr>" skip.
            for each wrk3 break by wrk3.v-fil:
                if first-of(wrk3.v-fil) then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk3.v-fil "</TD></TR>" skip.
                end.
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk3.v-doc "</TD>" skip
                "<TD align=""center"">" wrk3.v-jh "</TD>" skip
                "<TD align=""left"">" wrk3.v-date "</TD>" skip
                "<TD align=""left"">" wrk3.v-fio "</TD>" skip
                "<TD align=""left"">" wrk3.v-chet "</TD>" skip
                "<TD align=""left"">" wrk3.v-crck "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk3.v-sumk,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""center"">" wrk3.v-tar "</TD>" skip
                "<TD align=""left"">" wrk3.v-rem "</TD>" skip
                "<TD align=""left"">" wrk3.v-sp "</TD> " skip
                "<TD align=""left"">" wrk3.v-id "</TD></TR>" skip.
            end.
            put stream v-out unformatted "</table>".
        end.
        if v-op3 = 2 then do:
            put stream v-out unformatted  "<h3>Отчет по комиссиям без открытия счета" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Клиент </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта<br>комиссии </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>комиссии </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Код<br>тарифа </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Назначение </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
            "</tr>" skip.
            for each wrk4 break by wrk4.v-fil:
                if first-of(wrk4.v-fil) then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk4.v-fil "</TD></TR>" skip.
                end.
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk4.v-doc "</TD>" skip
                "<TD align=""center"">" wrk4.v-jh "</TD>" skip
                "<TD align=""left"">" wrk4.v-date "</TD>" skip
                "<TD align=""left"">" wrk4.v-fio "</TD>" skip
                "<TD align=""left"">" wrk4.v-crck "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk4.v-sumk,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""center"">" wrk4.v-tar "</TD>" skip
                "<TD align=""left"">" wrk4.v-rem "</TD>" skip
                "<TD align=""left"">" wrk4.v-sp "</TD> " skip
                "<TD align=""left"">" wrk4.v-id "</TD></TR>" skip.
            end.
            put stream v-out unformatted "</table>".
        end.
        if v-op3 = 3 then do:
            put stream v-out unformatted  "<h3>Отчет по урегулированию вознаграждений" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

            put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
            put stream v-out unformatted "<tr align=center>"
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Шаблон </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Наименование<br>шаблона </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма </B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта</B></FONT></TD>" skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Счет </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Клиент </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Назначение </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
                 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
            "</tr>" skip.
            for each wrk5 break by wrk5.v-fil:
                if first-of(wrk5.v-fil) then do:
                    put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk5.v-fil "</TD></TR>" skip.
                end.
                put stream v-out  unformatted "<TR> <TD align=""left"">" wrk5.v-uni "</TD>" skip
                "<TD align=""center"">" wrk5.v-name "</TD>" skip
                "<TD align=""center"">" wrk5.v-doc "</TD>" skip
                "<TD align=""center"">" wrk5.v-jh "</TD>" skip
                "<TD align=""left"">" wrk5.v-date "</TD>" skip
                "<TD align=""right"">" replace(trim(string(wrk5.v-sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD align=""left"">" wrk5.v-crc "</TD>" skip
                "<TD align=""left"">" wrk5.v-chet "</TD>" skip
                "<TD align=""left"">" wrk5.v-fio "</TD>" skip
                "<TD align=""left"">" wrk5.v-rem "</TD>" skip
                "<TD align=""left"">" wrk5.v-sp "</TD> " skip
                "<TD align=""left"">" wrk5.v-id "</TD></TR>" skip.
            end.
            put stream v-out unformatted "</table>".
        end.
    end.
    if v-op = 4 then do:
        put stream v-out unformatted  "<h3>Отчет по обменным операциям" ch "за период с " string(v-dt1) " по " string(v-dt2) "(" v-fil-cnt ")" "</h3>" skip.

        put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
        put stream v-out unformatted "<tr align=center>"
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № Документа </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> № транзакции </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Дата </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>принятия </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта<br>принятия </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Сумма<br>на выдачу </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Валюта<br>выдачи </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Курс </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Курс. разница<br>доход </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Курс. разница<br>расход </B></FONT></TD>" skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Назначение </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ЦОК/СПФ </B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id</B></FONT></TD>"  skip
             "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Тип операции </B></FONT></TD>"  skip
        "</tr>" skip.
        for each wrk6 break by wrk6.v-fil:
            if first-of(wrk6.v-fil) then do:
                put stream v-out  unformatted "<TR> <TD bgcolor=""#95B2D1""><align=""left"">" wrk6.v-fil "</TD></TR>" skip.
            end.
            put stream v-out  unformatted "<TR> <TD align=""left"">" wrk6.v-doc "</TD>" skip
            "<TD align=""center"">" wrk6.v-jh "</TD>" skip
            "<TD align=""left"">" wrk6.v-date "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk6.v-sum1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""center"">" wrk6.v-crc1 "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk6.v-sum2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""center"">" wrk6.v-crc2 "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk6.v-rate,'->>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk6.v-rev,'->>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right"">" replace(trim(string(wrk6.v-exp,'->>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""left"">" wrk6.v-rem "</TD>" skip
            "<TD align=""left"">" wrk6.v-sp "</TD> " skip
            "<TD align=""left"">" wrk6.v-id "</TD>" skip
            "<TD align=""left"">" wrk6.v-type "</TD></TR>" skip.
      end.
        put stream v-out unformatted "</table>".
    end.
    output stream v-out close.
    unix silent value("cptwin a_rep.html excel").
    hide message no-pause.
    return.
