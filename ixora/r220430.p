/* r220430.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Мониторинг карточных счетов
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
        05.02.2013 dmitriy. ТЗ 1641
 * BASES
        BANK COMM
 * CHANGES
        02.07.2013 dmitriy - ТЗ 1873. Добавлен столбец код клиента
        12.08.2013 dmitriy - ТЗ 2026. Добавлен столбец "Продукт"
        08.10.2013 dmitriy - ТЗ 2037. Добавлен столбец "Спец.инструкции"
*/

{global.i}

def new shared temp-table wrk
    field bank     as char
    field cif      as char
    field cifname  as char
    field cifacc   as char
    field acclgr   as int
    field gl       as int
    field ost      as deci
    field prod     as char
    field sp_inst  as char
    index ind is primary bank cifacc.

def var file1 as char.
def var i  as int.
def new shared var v-dt as date.
def new shared var v-today as date.

define frame fr1
    v-dt     format  "99/99/9999"  label  "         Дата "
with side-labels centered row 15 title    "Список карточных счетов по ГК 220430".

v-dt = g-today.
v-today = g-today.

update  v-dt with frame fr1.

{r-brfilial.i &proc = "r220430b"}
run PrintRep.

procedure PrintRep:
    file1 = "FSKAmsfo.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
    "<HEAD>"                                          skip
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
    "<TR align=""center""><td colspan=""7"">Список карточных счетов по ГК 220430</td></tr>"
    "<TR align=""center""><td colspan=""7"">на " v-dt format "99.99.9999" "</td></tr>"
    "<tr></tr>"
    "</TABLE>".

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
    "<TR align=""center"" valign=""top"">"
    "<TD>№ п/п</TD>"
    "<TD>Наименование филиала</TD>"
    "<TD>ФИО клиента</TD>"
    "<TD>Код клиента</TD>"
    "<TD>Номер счета клиента</TD>"
    "<TD>Счет ГК</TD>"
    "<TD>Группа</TD>"
    "<TD>Продукт</TD>"
    "<TD>Сумма остатка</TD>"
    "<TD>Спец. инструкции</TD>"
    "</TR>".

    i = 1.
    for each wrk no-lock:
        put unformatted
        "<TR>"
        "<TD>" i           "</TD>"
        "<TD>" wrk.bank    "</TD>"
        "<TD>" wrk.cifname "</TD>"
        "<TD>" wrk.cif     "</TD>"
        "<TD>" wrk.cifacc  "</TD>"
        "<TD>" wrk.gl      "</TD>"
        "<TD>" wrk.acclgr  "</TD>"
        "<TD>" wrk.prod    "</TD>"
        "<TD>" replace(string(round(wrk.ost, 2)), ".", ",") "</TD>"
        "<TD>" wrk.sp_inst "</TD>"
        "</TR>".
        i = i + 1.
    end.

    put unformatted
    "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).

end procedure.


