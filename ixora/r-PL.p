/* r-PL.p
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
        18.04.2013 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var dt1 as date.
def new shared var dt2 as date.

define new shared temp-table repPL no-undo
    field br as int
    field dt as date
    field gl as int
    field gl4 as char
    field crc as int
    field bal as deci
    field tot as logi
    field totlev as int
    field totgl as int.

def temp-table rep
    field id as int
    field point as char
    field name as char
    field sum as deci extent 2
    field ch-sum as deci.

def new shared temp-table wrk-scu
    field scu as char
    field ref as char
    field isin as char
    field s4510 as deci
    field s5510 as deci
    field razn1 as deci
    field s4709 as deci
    field s5709 as deci
    field razn2 as deci
    field s4733 as deci
    field s5733 as deci
    field razn3 as deci
    field s4201 as deci
    field razn4 as deci
    index scu is primary scu.


def var file1  as char.
def var v-week as logi.

define frame fr1
dt1         format  "99/99/9999"   label  "Дата        "    skip
with side-labels centered row 10 title " P & L ".

dt1 = g-today .
displ dt1 with frame fr1.

update dt1 with frame fr1.

{r-brfilial.i &proc = "r-PL2"}

{r-PL.i}

run PrintPL.
run PrintSCU.

procedure PrintPL:
    def var dt as date.
    def var i as int.

    file1 = "r-PL.html".
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
        "<TR align=""center""><TD colspan=""5"">Доходы/Расходы по казначейским операциям (P&L)</TD></tr>"
        "<TR></TR>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
        "<TR align=""center"">
        <TD colspan=""2"" bgcolor=""#CCCCCC"">ДОХОДЫ/<br>РАСХОДЫ</TD>".


    put unformatted
        "<TD bgcolor=""#CCCCCC"">" dt1 - 7 format "99.99.9999" "</TD>"
        "<TD bgcolor=""#CCCCCC"">" dt1 format "99.99.9999" "</TD>".


    put unformatted "<TD bgcolor=""#CCCCCC"">НЕДЕЛЬНОЕ ИЗМЕНЕНИЕ</TD></tr>".

    for each rep no-lock:
        put unformatted
            "<TR>
            <TD>" rep.point "</TD>
            <TD>" rep.name "</TD>".

        put unformatted
            "<TD>" replace(string(round(rep.sum[1] / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.sum[2] / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(ch-sum / 1000, 2)), ".", ",") "</TD></tr>".
    end.

    put unformatted   "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure.

procedure PrintSCU:
    file1 = "r-SCU.html".
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
        "<TR align=""center""><TD colspan=""14"">ДОХОДЫ/РАСХОДЫ ПО ПОРТФЕЛЮ ЦЕННЫХ БУМАГ по состоянию на </TD></tr>"
        "<TR align=""center""><TD colspan=""14"">" dt1 format "99.99.9999" "</TR>"
        "<TR></TR>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
        "<TR align=""center"">"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">N счета<br>scu</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">Код ценной<br>бумаги</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">ISIN</TD>"
        "<TD rowspan=""2"" colspan=""2"" bgcolor=""#E6B9B8"">Доход от купли/<br>продажи</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">ИТОГО (Доход <br> (+)/ Расход (-))</TD>"
        "<TD colspan=""2"" bgcolor=""#E6B9B8"">ПЕРЕОЦЕНКА</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">ИТОГО (Доход <br> (+)/ Расход (-))</TD>"
        "<TD colspan=""2"" bgcolor=""#E6B9B8"">ПЕРЕОЦЕНКА</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">ИТОГО (Доход <br> (+)/ Расход (-))</TD>"
        "<TD rowspan=""2"" bgcolor=""#E6B9B8"">% доход</TD>"
        "<TD rowspan=""3"" bgcolor=""#E6B9B8"">ИТОГО (Доход <br> (+)/ Расход (-))</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD colspan=""2"" bgcolor=""#E6B9B8"">- нереализованная</TD>"
        "<TD colspan=""2"" bgcolor=""#E6B9B8"">- реализованная</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD bgcolor=""#E6B9B8"">4510</TD>"
        "<TD bgcolor=""#E6B9B8"">5510</TD>"
        "<TD bgcolor=""#E6B9B8"">4709</TD>"
        "<TD bgcolor=""#E6B9B8"">5709</TD>"
        "<TD bgcolor=""#E6B9B8"">4733</TD>"
        "<TD bgcolor=""#E6B9B8"">5733</TD>"
        "<TD bgcolor=""#E6B9B8"">4201</TD>"
        "</TR>".


    for each wrk-scu where wrk-scu.isin <> "" no-lock:
        put unformatted
            "<TR>"
            "<TD bgcolor=""#E6B9B8"">" wrk-scu.scu "</TD>"
            "<TD bgcolor=""#E6B9B8"">" wrk-scu.ref "</TD>"
            "<TD bgcolor=""#E6B9B8"">" wrk-scu.isin "</TD>"
            "<TD>" replace(string(round(wrk-scu.s4510 / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(wrk-scu.s5510 / 1000, 2)), ".", ",") "</TD>"
            "<TD bgcolor=""#E6B9B8"">" replace(string(round(wrk-scu.razn1 / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(wrk-scu.s4709 / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(wrk-scu.s5709 / 1000, 2)), ".", ",") "</TD>"
            "<TD bgcolor=""#E6B9B8"">" replace(string(round(wrk-scu.razn2 / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(wrk-scu.s4733 / 1000, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(wrk-scu.s5733 / 1000, 2)), ".", ",") "</TD>"
            "<TD bgcolor=""#E6B9B8"">" replace(string(round(wrk-scu.razn3 / 1000, 2)), ".", ",") "</TD>"
            "<TD bgcolor=""#E6B9B8"">" replace(string(round(wrk-scu.s4201 / 1000, 2)), ".", ",") "</TD>"
            "<TD bgcolor=""#E6B9B8"">" replace(string(round(wrk-scu.razn4 / 1000, 2)), ".", ",") "</TD>"
            "</TR>".
    end.

    put unformatted "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure.
