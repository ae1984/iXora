/* rep_obm.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по нал обменным операциям
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
            Luiza
 * CHANGES
        14/02/2013 Luiza - ТЗ 1712 данные выводить в валюте
        02/08/2013 Luiza - ТЗ 2007 корректировка поля 200
*/


{mainhead.i}

def new shared var dt1 as date.
def new shared var dt2 as date.
def new shared var fil-cnt as char.
def new shared var fil-int as int init 0.
def var ful as logic format "да/нет" no-undo.

def stream out.
def stream m-out.

def frame f-date
   dt1 label "Начало" format "99/99/99" validate(dt1 <= today, "Некорректная дата!") skip
   dt2 label "Конец " format "99/99/99" /*validate(dt2 >= dt1,"Некорректная дата!")*/ skip
   ful label " С расшифровкой" skip
with side-labels centered row 7 title "Параметры отчета".
update  dt1 dt2 ful with frame f-date.

define new shared temp-table wrk no-undo
    field fil as char
    field doc as char
    field jh as int
    field dat as date
    field fio as char
    field crc as int
    field vrate as decim
    field ratus as decim
    field namecrc as char
    field gld as int
    field sumd as decim
    field sumtngd as decim
    field glc as int
    field sumc as decim
    field sumtngc as decim
    field dc as char
    field rem as char
    field nal as logic
    index ind is primary fil jh.

define temp-table wrk1 no-undo
    field str as int
    field num as char
    field vid as char
    field sum as decim
    field sumus as decim
    field sumeu as decim
    field sumru as decim
    field sumcn as decim
    field kol as logic
    index ind is primary str.

    create wrk1.
    wrk1.kol = no.
    wrk1.str = 1.
    wrk1.num = "100".
    wrk1.vid = "Количество обменных операций с физическими лицами, проведенных через обменные пункты".
    create wrk1.
    wrk1.kol = yes.
    wrk1.str = 2.
    wrk1.num = "200".
    wrk1.vid = "Оборот обменных операций (покупка и продажа наличной иностранной валюты), всего".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 3.
    wrk1.num = "".
    wrk1.vid = "Операции по покупке наличной иностранной валюты у физических лиц.".
    create wrk1.
    wrk1.kol = yes.
    wrk1.str = 4.
    wrk1.num = "210".
    wrk1.vid = "Куплено наличной иностранной валюты, всего".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 5.
    wrk1.num = "110".
    wrk1.vid = "Количество операций по покупке наличной иностранной валюты".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 6.
    wrk1.num = "".
    wrk1.vid = "в том числе на сумму:".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 7.
    wrk1.num = "111".
    wrk1.vid = "до 500 тысяч тенге (включительно)	".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 8.
    wrk1.num = "112".
    wrk1.vid = "свыше 500 тысяч тенге до 1 миллиона тенге (включительно)".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 9.
    wrk1.num = "113".
    wrk1.vid = "свыше 1 миллиона тенге	".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 10.
    wrk1.num = "".
    wrk1.vid = "Операции покупки наличной иностранной валюты на сумму свыше 10 тысяч долларов США в эквиваленте	".
    create wrk1.
    wrk1.kol = yes.
    wrk1.str = 11.
    wrk1.num = "215".
    wrk1.vid = "куплено всего".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 12.
    wrk1.num = "115".
    wrk1.vid = "количество операций по покупке".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 13.
    wrk1.num = "".
    wrk1.vid = "Операции по продаже наличной иностранной валюты физическим лицам".
    create wrk1.
    wrk1.kol = yes.
    wrk1.str = 15.
    wrk1.num = "220".
    wrk1.vid = "Продано наличной иностранной валюты, всего".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 16.
    wrk1.num = "120".
    wrk1.vid = "Количество операций по продаже наличной иностранной валюты".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 17.
    wrk1.num = "".
    wrk1.vid = "в том числе на сумму:".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 18.
    wrk1.num = "121".
    wrk1.vid = "до 500 тысяч тенге (включительно)".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 19.
    wrk1.num = "122".
    wrk1.vid = "свыше 500 тысяч тенге до 1 миллиона тенге (включительно)".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 20.
    wrk1.num = "123".
    wrk1.vid = "свыше 1 миллиона тенге".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 21.
    wrk1.num = "".
    wrk1.vid = "Операции продажи наличной иностранной валюты на сумму свыше 10 тысяч долларов США в эквиваленте	".
    create wrk1.
    wrk1.kol = yes.
    wrk1.str = 22.
    wrk1.num = "225".
    wrk1.vid = "продано всего".
    create wrk1.
    wrk1.kol = no.
    wrk1.str = 23.
    wrk1.num = "125".
    wrk1.vid = "количество операций по продаже".


{r-brfilial.i &proc = "rep_obm1"}.

for each wrk.
    for each wrk1.
        case wrk1.num:
                when "100" then do:
                    if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                    if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                    if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                    wrk1.sum = wrk1.sum + 1.
                end.
                /*when "200" then do:
                    if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + wrk.sumd + wrk.sumc.
                    if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + wrk.sumd + wrk.sumc.
                    if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + wrk.sumd + wrk.sumc.
                    wrk1.sum = wrk1.sum + wrk.sumtngd + wrk.sumtngc.
                end.*/
                /* куплено */
                when "210" then do:
                    if wrk.dc = "c" then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + wrk.sumd .
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + wrk.sumd .
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + wrk.sumd .
                        wrk1.sum = wrk1.sum + wrk.sumtngd.
                    end.
                end.
                when "110" then do:
                    if wrk.dc = "c"  then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "111" then do:
                    if wrk.dc = "c"  and wrk.sumtngd <= 500000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "112" then do:
                    if wrk.dc = "c"  and wrk.sumtngd > 500000 and wrk.sumtngd <= 1000000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "113" then do:
                    if wrk.dc = "c"  and wrk.sumtngd > 1000000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "215" then do:
                    if wrk.dc = "c"  and wrk.sumtngd > (10000 * wrk.ratus) then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + wrk.sumd .
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + wrk.sumd .
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + wrk.sumd .
                        wrk1.sum = wrk1.sum + wrk.sumtngd.
                    end.
                end.
                when "115" then do:
                    if wrk.dc = "c" and wrk.sumtngd > (10000 * wrk.ratus) then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                /* продано */
                when "220" then do:
                    if wrk.dc = "d"  then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + wrk.sumc .
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + wrk.sumc .
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + wrk.sumc .
                        wrk1.sum = wrk1.sum + wrk.sumtngc.
                    end.
                end.
                when "120" then do:
                    if wrk.dc = "d"  then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "121" then do:
                    if wrk.dc = "d"  and wrk.sumtngc <= 500000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "122" then do:
                    if wrk.dc = "d"  and wrk.sumtngc > 500000 and wrk.sumtngc <= 1000000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "123" then do:
                    if wrk.dc = "d"   and wrk.sumtngc > 1000000 then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
                when "225" then do:
                    if wrk.dc = "d" and wrk.sumtngc > (10000 * wrk.ratus)then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + wrk.sumc .
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + wrk.sumc .
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + wrk.sumc .
                        wrk1.sum = wrk1.sum + wrk.sumtngc.
                    end.
                end.
                when "125" then do:
                    if wrk.dc = "d" and wrk.sumtngc > (10000 * wrk.ratus) then do:
                        if wrk.crc = 2 then wrk1.sumus = wrk1.sumus + 1.
                        if wrk.crc = 3 then wrk1.sumeu = wrk1.sumeu + 1.
                        if wrk.crc = 4 then wrk1.sumru = wrk1.sumru + 1.
                        wrk1.sum = wrk1.sum + 1.
                    end.
                end.
        end case.
    end.
end.
/* в тыс еденицах */
for each wrk1 where wrk1.kol.
    if wrk1.sum <> 0 then wrk1.sum = round((wrk1.sum / 1000),0).
    if wrk1.sumus <> 0 then wrk1.sumus = round((wrk1.sumus / 1000),0).
    if wrk1.sumeu <> 0 then wrk1.sumeu = round((wrk1.sumeu / 1000),0).
    if wrk1.sumru <> 0 then wrk1.sumru = round((wrk1.sumru / 1000),0).
end.
/* пересчет итоговых */
def buffer b-wrk1 for wrk1.

find first wrk1 where wrk1.num = "200".
find first b-wrk1 where b-wrk1.num = "210" no-lock.
wrk1.sumus = wrk1.sumus + b-wrk1.sumus.
wrk1.sumeu = wrk1.sumeu + b-wrk1.sumeu.
wrk1.sumru = wrk1.sumru + b-wrk1.sumru.
wrk1.sum = wrk1.sum + b-wrk1.sum.
find first b-wrk1 where b-wrk1.num = "220" no-lock.
wrk1.sumus = wrk1.sumus + b-wrk1.sumus.
wrk1.sumeu = wrk1.sumeu + b-wrk1.sumeu.
wrk1.sumru = wrk1.sumru + b-wrk1.sumru.
wrk1.sum = wrk1.sum + b-wrk1.sum.

find first cmp no-lock no-error.
if fil-int > 1 then fil-cnt = "консолидированный отчет".

output stream out to rep.html.
    put stream out unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream out unformatted  "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:15px"">" skip.
    put stream out unformatted
         "<tr><TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<TD> </TD>" skip
         "<tr> <TD colspan=7 align=right > Приложение 7-1  </TD> </tr>" skip
         "<tr> <TD colspan=7 align=right > к Правилам организации обменных операций </TD> </tr>" skip
         "<tr> <TD colspan=7 align=right > с наличной иностранной валютой </TD> </tr>" skip
         "<tr> <TD colspan=7 align=right > в Республике Казахстан  </TD> </tr>" skip
         "<tr> <TD colspan=7 align=right > Форма  </TD> </tr>" skip
         "<tr>  </tr>" skip
         "<tr>  </tr>" skip
         "</table>" skip.
    put stream out unformatted  "<h3> Отчет об обменных операциях, проведенных через обменные пункты c " dt1 " по " dt2  "</h3>" skip.
    put stream out unformatted  "<h3> " cmp.name "</h3>" skip.

    put stream out unformatted  "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:15px"">" skip.
    /*put stream out unformatted
         "<tr><TD colspan=7  align=right> в тыс.тенге </TD></tr>" skip
         "</table>" skip.*/

    put stream out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:15px"">" skip.
    put stream out unformatted "<tr align=center>"
     "<TD rowspan=2><FONT >Наименование показателя</FONT></TD>"  skip
         "<TD rowspan=2><FONT > Код строки </FONT></TD>"  skip
         "<TD rowspan=2><FONT > Все валюты <br> (тыс.тенге)</FONT></TD>"  skip
         "<TD colspan=4 ><FONT size=""2""> по видам валют </FONT></TD></tr>"  skip
         "<tr><TD ><FONT size=""2""> USD </B></FONT></TD>" skip
         "<TD ><FONT size=""2""> EUR </B></FONT></TD>" skip
         "<TD ><FONT size=""2""> RUB </B></FONT></TD>" skip
         "<TD ><FONT size=""2""> CNY </B></FONT></TD></tr>" skip
        "<tr><TD ><FONT align=center> 1 </FONT></TD>"  skip
             "<TD ><FONT align=center> 2 </FONT></TD>"  skip
             "<TD ><FONT align=center> 3 </FONT></TD>"  skip
             "<TD ><FONT align=center> 4 </B></FONT></TD>" skip
             "<TD ><FONT align=center> 5 </B></FONT></TD>" skip
             "<TD ><FONT align=center> 6 </B></FONT></TD>" skip
             "<TD ><FONT align=center> 7 </B></FONT></TD>" skip
        "</tr>" skip.
    for each wrk1 .
        if wrk1.num = "" then put stream out  unformatted "<TR> <TD colspan=7 align=""left""> <b>" wrk1.vid "</b></TD>" skip.
        else put stream out  unformatted "<TR> <TD align=""left"">" wrk1.vid "</TD>" skip.
        if wrk1.num <> "" then do:
            put stream out  unformatted "<TD align=""center"">" wrk1.num "</TD>" skip.
            if wrk1.sum <> 0 then put stream out  unformatted "<TD align=""right"">" replace(trim(string(wrk1.sum,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip. else put stream out  unformatted "<TD align=""right"">"  "</TD>" skip.
            if wrk1.sumus <> 0 then put stream out  unformatted "<TD align=""right"">" replace(trim(string(wrk1.sumus,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip. else put stream out  unformatted "<TD align=""right"">"  "</TD>" skip.
            if wrk1.sumeu <> 0 then put stream out  unformatted "<TD align=""right"">" replace(trim(string(wrk1.sumeu,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip. else put stream out  unformatted "<TD align=""right"">"  "</TD>" skip.
            if wrk1.sumru <> 0 then put stream out  unformatted "<TD align=""right"">" replace(trim(string(wrk1.sumru,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip. else put stream out  unformatted "<TD align=""right"">"  "</TD>" skip.
            if wrk1.sumcn <> 0 then put stream out  unformatted "<TD align=""right"">" replace(trim(string(wrk1.sumcn,'->>>>>>>>>>>9.99')),'.',',') "</TD></TR>" skip. else put stream out  unformatted "<TD align=""right"">"  "</TD></TR>" skip.
        end.
    end.
    put stream out unformatted "</table>".
output stream out close.
unix silent value("cptwin rep.html excel").

if ful then do:
    def stream m-out.
    output stream m-out to rr.htm.

    put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream m-out unformatted  "<h3> Реестр купленной и проданной наличной иностранной валюты c " dt1 "по " dt2  "</h3>" skip.

    put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream m-out unformatted "<tr><td rowspan=3 align=""center"" > Филиал </td>" skip
              "<td rowspan=3 align=""center"" > № докум </td>" skip
              "<td rowspan=3 align=""center"" > Транз </td>" skip
              "<td rowspan=3 align=""center"" > Дата </td>" skip
              "<td rowspan=3 align=""center""> ФИО, № документа клиента </td>" skip
              "<td rowspan=3 align=""center"" >Валюта</td>" skip
              "<td rowspan=3 align=""center"" >курс</td>" skip
              "<td colspan=6 align=""center"" > Сумма валюты</td></tr>" skip
              "<tr><td colspan=3 align=""center"" > Куплено</td>" skip
              "<td colspan=3 align=""center"" > Продано</td></tr>" skip
              "<tr><td> ГК дебет</td>" skip
              "<td align=""center"" > в валюте</td>" skip
              "<td align=""center"" > эквивалент в тенге </td>" skip
              "<td> ГК кредит </td>" skip
              "<td align=""center"" > в валюте </td>" skip
              "<td align=""center"" > эквивалент в тенге </td>" skip
              "<td > курс $ на день операции </td>" skip
              "<td > 10000 $ в тенге </td>" skip
              /*"<td align=""center"" > dc </td></tr>" skip*/
              "</tr>" skip.
        for each wrk.
            put stream m-out unformatted
                  "<tr><td>" wrk.fil "</td>" skip
                  "<td>" wrk.doc "</td>" skip
                  "<td>" wrk.jh "</td>" skip
                  "<td>" wrk.dat "</td>" skip
                  "<td>" wrk.fio "</td>" skip
                  "<td>" wrk.namecrc "</td>" skip
                  "<td>" replace(trim(string(wrk.vrate,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                  "<td>" wrk.gld "</td>" skip
                  "<td>" replace(trim(string(wrk.sumd,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                  "<td>" replace(trim(string(wrk.sumtngd,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                  "<td>" wrk.glc "</td>" skip
                  "<td>" replace(trim(string(wrk.sumc,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                  "<td>" replace(trim(string(wrk.sumtngc,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip.
                  if wrk.sumtngc > wrk.ratus * 10000 or wrk.sumtngd > wrk.ratus * 10000 then do:
                      put stream m-out unformatted "<td>" replace(trim(string(wrk.ratus,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                      "<td>" replace(trim(string(wrk.ratus * 10000,">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
                      "</tr>" skip.
                  end.
                  else do:
                      put stream m-out unformatted "<td>"  "</td>" skip
                      "<td>"  "</td>" skip
                      "</tr>" skip.
                  end.
                  /*"<td>" wrk.dc "</td>" skip*/

        end.
        put stream m-out unformatted "</table>" skip.

    output stream m-out close.
    unix silent cptwin rr.htm excel.
end.

hide message no-pause.
return.
