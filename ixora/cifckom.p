/* cifkcom.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Отчет по клиентам выбранной категории - комиссии по платежам и конвертациям
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
 * AUTHOR
        02.12.2003 sasco
 * CHANGES
        04.12.2003 sasco Добавил поиск комиссии по joudoc'ам и перевод всех комиссий на доллары США
        08.12.2003 sasco Переделал поиск комиссий за конвертации (dealing_doc)
        24.12.2003 sasco Добавил обработку платежей (RMZ) с нулевой комиссией
        01.04.2004 - suchkov - Переделал вывод в csv на вывод в html.
        27.02.2013 dmitriy - ТЗ 1700. Изменение формы отчета и алгоритма его формирования
*/

{global.i}

def temp-table wrk
    field code as int
    field name as char
    index code is primary code ascending.

def temp-table rep
    field cif     as  char
    field cifname as  char
    field kat     as  char
    field katcode as  char
    field aaa     as  char
    field crc     as  int
    field crccode as  char
    field ost1    as  deci
    field ost2    as  deci
    field dt      as  deci
    field ct      as  deci
    index cifkat katcode ascending cif ascending
    index crc crc ascending.

def var v-ind as integer.
def var s-trw as character.
def var v-d1 as date.
def var v-d2 as date.
def var v-crc like crc.crc.
def var file1 as char.
def var i as int.
def var v-kat as char.
def var v-dt as deci.
def var v-ct as deci.
def var v-ost1 as deci.
def var v-ost2 as deci.

define frame fr1
    v-d1         format  "99/99/9999"  label  "Начало периода "    skip
    v-d2         format  "99/99/9999"  label  "Конец периода  "    skip
with side-labels centered row 10 title "Отчет по остаткам".


update v-d1 v-d2 with frame fr1.
hide frame fr1.

for each codfr where codfr.codfr = 'cifkat' and codfr.name[1] <> "" no-lock:
   create wrk.
   wrk.code = int(codfr.code).
   wrk.name = codfr.name[1].
end.

s-trw = "1)  Все|".

i = 2.
for each wrk no-lock:
    s-trw = s-trw + string(i) + ")  " + wrk.name + "|".
    i = i + 1.
end.

run sel2 ("Выберите категорию клиентов", s-trw, output v-ind).

run FindData(v-ind).
run PrintRep.

procedure FindData:
    def input parameter p-ind as integer.
    v-kat = trim(substr(entry(p-ind, s-trw, "|"), 5)).

    CASE v-kat:
        WHEN "Все" THEN DO:
            for each cif no-lock:
                run CreateRep.
            end.
        END.

        WHEN "Без категории" THEN DO:
            for each cif where cif.trw = "" no-lock:
                run CreateRep.
            end.
        END.

        OTHERWISE DO:
            find first codfr where codfr.codfr = "cifkat" and codfr.name[1] = v-kat no-lock no-error.
            if avail codfr then do:
                for each cif where cif.trw = codfr.code no-lock:
                    run CreateRep.
                end.

            end.
        END.
    END CASE.

end procedure.

procedure CreateRep:
    for each aaa where aaa.cif = cif.cif and aaa.sta <> "C" no-lock:
        find lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr and lgr.led = "ODA" then next.

        find first crc where crc.crc = aaa.crc no-lock no-error.

        v-ost1 = 0. v-ost2 = 0. v-dt = 0. v-ct = 0.

        find last histrxbal where histrxbal.subled = "cif" and histrxbal.acc = aaa.aaa and histrxbal.lev = 1 and histrxbal.dt < v-d1 no-lock no-error.
        if avail histrxbal then v-ost1 = histrxbal.cam - histrxbal.dam.

        for each jl where jl.acc = aaa.aaa and jl.jdt >= v-d1 and jl.jdt <= v-d2 and jl.lev = 1 no-lock:
            if jl.dc = "D" then v-dt = v-dt + jl.dam.
            if jl.dc = "C" then v-ct = v-ct + jl.cam.
        end.

        if v-d2 < g-today then do:
            find last histrxbal where histrxbal.subled = "cif" and histrxbal.acc = aaa.aaa and histrxbal.lev = 1 and histrxbal.dt <= v-d2 no-lock no-error.
            if avail histrxbal then v-ost2 = histrxbal.cam - histrxbal.dam.
        end.
        else if v-d2 = g-today then do:
            v-ost2 = aaa.cr[1] - aaa.dr[1].
        end.

        do transaction:
            create rep.
            rep.cif     = cif.cif.
            rep.cifname = cif.name.
            rep.kat     = v-kat.
            rep.katcode = cif.trw.
            rep.aaa     = aaa.aaa.
            rep.crc     = aaa.crc.
            rep.crccode = crc.code.
            rep.ost1    = v-ost1.
            rep.ost2    = v-ost2.
            rep.dt      = v-dt.
            rep.ct      = v-ct.
        end.
    end.
end procedure.

procedure PrintRep:
    file1 = "r-ost.html".
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
        "<TR align=""center""><TD colspan=""7"">Отчет по остаткам (категории)</TD></tr>"
        "<TR></TR>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
        "<TR align=""center"">"
        "<TD colspan=""7"">Период: " v-d1 format "99.99.9999" " - " v-d2 format "99.99.9999" "</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD>Категория:" v-kat "</TD>"
        "<TD>ИИК</TD>"
        "<TD>Валюта</TD>"
        "<TD>Входящий остаток</TD>"
        "<TD>Дебет</TD>"
        "<TD>Кредит</TD>"
        "<TD>Исходящий остаток</TD>"
        "</TR>".

    for each rep break by rep.cif:
        if first-of(rep.cif) then do:
            put unformatted
            "<TR>"
            "<TD>" rep.cifname "</TD>"
            "<TD>" rep.aaa "</TD>"
            "<TD>" rep.crccode "</TD>"
            "<TD>" replace(string(round(rep.ost1, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.dt, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.ct, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.ost2, 2)), ".", ",") "</TD>"
            "</TR>".
        end.
        else do:
            put unformatted
            "<TR>"
            "<TD>" "</TD>"
            "<TD>" rep.aaa "</TD>"
            "<TD>" rep.crccode "</TD>"
            "<TD>" replace(string(round(rep.ost1, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.dt, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.ct, 2)), ".", ",") "</TD>"
            "<TD>" replace(string(round(rep.ost2, 2)), ".", ",") "</TD>"
            "</TR>".
        end.
    end.

    put unformatted
    "<TR>"
    "<TD colspan=""2"" align=""right"">ИТОГО</TD>"
    "<TD>"  "</TD>"
    "<TD>"  "</TD>"
    "<TD>"  "</TD>"
    "<TD>"  "</TD>"
    "<TD>"  "</TD>"
    "</TR>".

    for each rep break by rep.crc.
        accumulate rep.ost1 (TOTAL by rep.crc).
        accumulate rep.ost2 (TOTAL by rep.crc).
        accumulate rep.dt (TOTAL by rep.crc).
        accumulate rep.ct (TOTAL by rep.crc).

        if last-of(rep.crc) then do:
            put unformatted
            "<TR>"
            "<TD colspan=""2"">"  "</TD>"
            "<TD>"  rep.crccode "</TD>"
            "<TD>"  replace(string(round(accum total by rep.crc rep.ost1, 2)), ".", ",") "</TD>"
            "<TD>"  replace(string(round(accum total by rep.crc rep.dt, 2)), ".", ",") "</TD>"
            "<TD>"  replace(string(round(accum total by rep.crc rep.ct, 2)), ".", ",") "</TD>"
            "<TD>"  replace(string(round(accum total by rep.crc rep.ost2, 2)), ".", ",") "</TD>"
            "</TR>".
        end.
    end.

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure.