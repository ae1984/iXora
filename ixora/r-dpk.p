/* r-dpk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет о состоянии выпуска загруженных карт
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16.1.6
 * AUTHOR
        20.02.2013 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        04.07.2013 dmitriy - ТЗ 1940.
        30.09.2013 dmitriy - ТЗ 1983.
*/

{global.i}

def new shared temp-table wrk no-undo
field branch as char
field cmpcode as int
field name as char
field bin as char
field acc as char
field sts as char
field whn as date
field comp as char
field prod as char
field ofc as char
field load_type as char
field profit as char
field ofc2 as char
field deb as char
field cred as char
index acc is primary branch acc.

def new shared var v-dt1 as date.
def new shared var v-dt2 as date.

def var v-sel as int.
def var file1 as char.
def var i as int.
def var v-list as char init "1) Все загруженные|2) Отконтролированные|3) Неотконтролированные|4) Выпущенные".

define frame fr1
    v-dt1        format  "99/99/9999"  label  "       С"
    v-dt2        format  "99/99/9999"  label  "По"                    skip
with side-labels centered row 15 title "Отчет о состоянии выпуска загруженных карт".

run sel2 ("Выберите тип отчета", v-list, output v-sel).


if v-sel <> 3 then do:
    update v-dt1 v-dt2 with frame fr1.
end.
else do:
    v-dt1 = g-today.
    v-dt2 = g-today.
end.


{r-brfilial.i &proc="r-dpk2 (v-sel)"}

find first cmp no-lock no-error.

file1 = "r-DPK.html".
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

    "<TR align=""center"" style=""font-size:8pt;""><TD colspan=""14"">Отчет о состоянии выпуска загруженных карт</TD></tr>"
    "<TR align=""center"" style=""font-size:8pt;""><TD colspan=""14"">По типу " substr(entry(v-sel, v-list,'|'), 3) " </TD></tr>"
    "<TR align=""center"" style=""font-size:8pt;""><TD colspan=""14""> С " v-dt1 format "99.99.9999" " По " v-dt2 format "99.99.9999" "</TD></tr>"
    "<TR align=""center"" style=""font-size:8pt;""><TD colspan=""14"">" v-bankname "</TD></tr>"

    "</TABLE>".

put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

put unformatted
    "<TR align=""center"" style=""font-size:8pt;"">"
    "<TD>№</TD>"
    "<TD>Филиал</TD>"
    "<TD>ФИО</TD>"
    "<TD>ИИН/БИН</TD>"
    "<TD>Счет клиента</TD>"
    "<TD>Статус выпуск</TD>"
    "<TD>Дата изменения</TD>"
    "<TD>Компания</TD>"
    "<TD>Продукт</TD>"
    "<TD>Сотрудник</TD>"
    "<TD>Тип загрузки</TD>"
    "<TD>Подразделение</TD>"
    "<TD>Приход</TD>"
    "<TD>Выдача</TD>"
    "</TR>".

i = 1.
if cmp.code = 0 then do:
    for each wrk no-lock:
        run CreateRep.
    end.
end.
else do:
    for each wrk where wrk.cmpcode = cmp.code no-lock:
        run CreateRep.
    end.
end.

{html-end.i " "}
output close.
unix silent cptwin value(file1) excel.

procedure CreateRep:
    put unformatted
    "<TR align=""center"" style=""font-size:8pt;"">"
    "<TD>" i "</TD>"
    "<TD>" wrk.branch    "</TD>"
    "<TD>" wrk.name      "</TD>"
    "<TD>'" wrk.bin      "</TD>"
    "<TD>" wrk.acc       "</TD>"
    "<TD>" wrk.sts       "</TD>"
    "<TD>" wrk.whn       "</TD>"
    "<TD>" wrk.comp      "</TD>"
    "<TD>" wrk.prod      "</TD>"
    "<TD>" wrk.ofc       "</TD>"
    "<TD>" wrk.load_type "</TD>"
    "<TD>" wrk.profit    "</TD>"
    "<TD>" wrk.deb       "</TD>"
    "<TD>" wrk.cred      "</TD>"
    "</TR>".
    i = i + 1.
end procedure.
