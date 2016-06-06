/* r-riskline.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        02.04.2013 dmitriy. ТЗ 1690
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var dt as date.

def new shared temp-table wrk1 no-undo
    field nom as int
    field name as char
    field beta as int.

def new shared temp-table wrk2 no-undo
    field id as int
    field nom as int
    field name as char
    field income as deci
    field inc-gl as char
    field expense as deci
    field exp-gl as char
    field bal as deci
    field risksum as deci.

def new shared temp-table wrk-gl no-undo
    field br  as char
    field dt  as date
    field gl  as int
    field gl4 as char
    field bal as deci
    field crc as int
    field skv as int
    field tot as logi
    field totlev as int
    field totgl as int
    field des as char
    field include as logi init no
    index gl4 gl4.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.

def var file1 as char.
def var v-shifr as logi init yes.
def stream v-out.

dt = today.

def frame fr1
    dt     format  "99/99/9999"  label "Дата                   " skip
    v-shifr format "Да/Нет"      label "Формировать расшифровку"
with side-labels centered row 15 title "Операционные риски по направлениям деятельности".

update dt v-shifr with frame fr1.

{r-riskline_wrk.i}
{r-brfilial.i &proc = "r-riskline2"}
{r-riskline.i}

run PrintRep.

if v-shifr then do:
    run PrintShifr.
    /*run PrintGl7.*/
end.

hide frame fr1.

procedure PrintRep:
    message "Формирование отчета...".

    file1 = "r-risk.html".
    output to value(file1).
    {html-title.i}

    put  unformatted
       "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
       "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
        "<TR align=""center""><TD colspan=""8"">Расчет операционного риска по направлениям деятельности АО ""FORTEBANK"" по состоянию на </TD></tr>"
        "<TR align=""center""><TD colspan=""8"">" dt format "99.99.9999" "</TR>"
        "<TR></TR>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
        "<TR align=""center"">"
        "<TD rowspan=""2"">№</TD>"
        "<TD rowspan=""2"">Направление деятельности</TD>"
        "<TD rowspan=""2"">Бета,%</TD>"
        "<TD rowspan=""2"">Виды операций и услуг</TD>"
        "<TD colspan=""3"">Критерии расчета</TD>"
        "<TD rowspan=""2"">Операционный риск</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD>Доходы</TD>"
        "<TD>Расходы</TD>"
        "<TD>Валовый доход</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD>1</TD>"
        "<TD>2</TD>"
        "<TD>3</TD>"
        "<TD>4</TD>"
        "<TD>5</TD>"
        "<TD>6</TD>"
        "<TD>7</TD>"
        "<TD>8</TD>"
        "</TR>".


    for each wrk1 no-lock:
        put unformatted "<TR valign=""top"">".
        if wrk1.nom = 1 then put unformatted "<TD rowspan=""9"">" wrk1.nom "</TD><TD rowspan=""9"">" wrk1.name "</TD><TD rowspan=""9"">" wrk1.beta "</TD>".
        if wrk1.nom = 2 then put unformatted "<TD rowspan=""6"">" wrk1.nom "</TD><TD rowspan=""6"">" wrk1.name "</TD><TD rowspan=""6"">" wrk1.beta "</TD>".
        if wrk1.nom = 3 then put unformatted "<TD rowspan=""3"">" wrk1.nom "</TD><TD rowspan=""3"">" wrk1.name "</TD><TD rowspan=""3"">" wrk1.beta "</TD>".
        if wrk1.nom = 4 then put unformatted "<TD rowspan=""6"">" wrk1.nom "</TD><TD rowspan=""6"">" wrk1.name "</TD><TD rowspan=""6"">" wrk1.beta "</TD>".
        if wrk1.nom = 5 then put unformatted "<TD rowspan=""2"">" wrk1.nom "</TD><TD rowspan=""2"">" wrk1.name "</TD><TD rowspan=""2"">" wrk1.beta "</TD>".
        if wrk1.nom = 6 then put unformatted "<TD rowspan=""5"">" wrk1.nom "</TD><TD rowspan=""5"">" wrk1.name "</TD><TD rowspan=""5"">" wrk1.beta "</TD>".
        if wrk1.nom = 7 or wrk1.nom = 8 or wrk1.nom = 9 then put unformatted "<TD>" wrk1.nom "</TD><TD>" wrk1.name "</TD><TD>" wrk1.beta "</TD>".

        for each wrk2 where wrk2.nom = wrk1.nom no-lock:
            put unformatted
                "<TD>" wrk2.name "</TD>"
                "<TD>" replace(string(round(wrk2.income / 1000, 2)), ".", ",") "</TD>"
                "<TD>" replace(string(round(wrk2.expense / 1000, 2)), ".", ",") "</TD>"
                "<TD>" replace(string(round(wrk2.bal / 1000, 2)), ".", ",") "</TD>"
                "<TD>" replace(string(round(wrk2.risksum / 1000, 2)), ".", ",") "</TD>"
                "</TR>".
        end.
    end.

    put unformatted "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    message "". pause 0.
end procedure.


procedure PrintShifr:
    message "Формирование расшифровки...".
    def var sum as deci.

    file1 = "r-risk.html".
    output to value(file1).
    {html-title.i}

    put  unformatted
       "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
       "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
        "<TR align=""center""><TD colspan=""5"">Расшифровка по счетам ГК по состоянию на </TD></tr>"
        "<TR align=""center""><TD colspan=""5"">" dt format "99.99.9999" "</TR>"
        "<TR></TR>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
        "<TR align=""center"">"
        "<TD>Филиал</TD>"
        "<TD>4-знач.<br>счет ГК</TD>"
        "<TD>6-знач.<br>счет ГК</TD>"
        "<TD>Наименование счета</TD>"
        "<TD>Баланс</TD>"
        "</TR>".

    for each comm.txb where comm.txb.consolid = yes no-lock:
        for each wrk-gl where wrk-gl.br = comm.txb.info and wrk-gl.bal <> 0 break by wrk-gl.gl4.
            accumulate wrk-gl.bal (TOTAL by wrk-gl.gl4).

            if last-of(wrk-gl.gl4) then do:
                sum = accum total by wrk-gl.gl4 wrk-gl.bal.

                put unformatted
                "<TD>" wrk-gl.br "</TD>"
                "<TD>" wrk-gl.gl4 "</TD>"
                "<TD>" wrk-gl.gl "</TD>"
                "<TD>" wrk-gl.des "</TD>"
                "<TD>" replace(string(round(sum / 1000, 2)), ".", ",")  "</TD>"
                "</TR>".
            end.
        end.
    end.

    put unformatted "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.

    message "". pause 0.
end procedure.

procedure PrintGl7:

    def buffer b-tgl for tgl.

    def var sum as deci.
    output stream v-out to avmm2.html.

    put stream v-out "<html><head><title>ForteBank</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
    style=""border-collapse: collapse"">"
    skip.

    put stream v-out  unformatted
    "<tr align=""center""><td>Приложение к детализированному плану счетов бухгалтерского учета для составления главной бухгалтерской книги банков второго уровня АО ""ForteBank""
    <br>" v-bankname "</td></tr><br><br>"
    skip(2).
    put stream v-out "<br><br><tr></tr>".


    put stream v-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
    style=""border-collapse: collapse" ">" skip
    "<tr style=""font:bold" "" ">"
    "<td colspan=""4"" bgcolor=""#CCCCCC"" align=""center"">Структура</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Наименование</td>".



    put stream v-out  unformatted "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">" string(dt) "</td>".


    put stream v-out  unformatted
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Всего</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Средний остаток за<br>указанный период</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Количество<br>дней</td></tr>"
    "<tr>"
    "<td bgcolor=""#CCCCCC"">'1-4</td>
    <td bgcolor=""#CCCCCC"">5</td>
    <td bgcolor=""#CCCCCC"">6</td>
    <td bgcolor=""#CCCCCC"">7</td>"
    "</tr>".


    for each tgl use-index tgl-id1 break by tgl.gl7:
        if first-of (tgl.gl7) then do:
            find first b-tgl where b-tgl.gl7 = tgl.gl7 and b-tgl.sum <> 0 no-lock no-error.
            if not avail b-tgl then next.

            put stream v-out  unformatted
            "<tr>
             <td align=""center"">" tgl.gl4  "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),5,1) "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),6,1) "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),7,1) "</td>
             <td align=""center"">" tgl.gl-des "</td>".

            put stream v-out  unformatted "<td align=""center"">" replace(string(sum / 1000),".",",")  "</td></TR>".

        end.
    end.

    put stream v-out "</table>" skip.
    put stream v-out "</body></html>" skip.
    output stream v-out close.
    unix silent cptwin avmm2.html excel.exe.
    unix silent rm avmm2.html.

    message "Формирование приложения к отчету выполнено".
    pause 2.

end procedure.