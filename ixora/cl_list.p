/* cl_list.p
 * MODULE
     Операционный модуль
 * DESCRIPTION
     Список счетов клиентов с нулевым остатком по которым не было движений более одного года для менеджера.
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
     05.05.2004 dpuchkov
 * CHANGES
     12.05.05 dpuchkov добавил проверку на вывод закрытых счетов
     13.05.05 dpuchkov добавил вывод счетов созданных в период более года назад
     27.10.11 lyubov - вывод только юр.лиц, у которых по всем счетам остаток 0,00 и не было движений ни по одному из счетов в течение года
     24.07.12 id00810 - исключеы группы счетов 143,144,145 (Т/С юр.лица ДПК)
     28.05.2013 dmitriy - ТЗ 1733. Выбор Юр/Физ
*/


{mainhead.i}
def var managername  as char.
def var v-ofc like ofc.ofc.
def var d_date as date.
def var d_date_fin as date.
def var out as char.
def var file1 as char format "x(20)".
def var acctype as logical.
def var v-sel as char.

def buffer b-aaa for aaa.
def buffer b-jl for jl.

define temp-table tmp_t1
       field  gl_name like  aaa.name label "name" column-label "name"
       field  gl_desc like aaa.aaa label "desc" column-label "desc"
       field  gl_cif like aaa.cif label "cif" column-label "cif".

define temp-table tmp_t2
       field  gl_name like  aaa.name label "name" column-label "name"
       field  gl_desc like aaa.aaa label "desc" column-label "desc"
       field  gl_cif like aaa.cif label "cif" column-label "cif".

file1 = "file1.html".

d_date = g-today - 365.
d_date_fin = g-today .
v-ofc = g-ofc.


repeat:
    run sel ("Выбор: Юридические лица/Физические лица", " 1. Юридические лица | 2. Физические лица | 3. Выход").
    v-sel = return-value.

    case v-sel:
        when '1' then  run RepB .
        when '2' then  run RepP.
        when '3' then  return.
        otherwise return.
    end case.
end.


procedure RepB:
    display "....... Ж Д И Т Е ......."  with row 12 frame ww centered.
    pause 0.

    for each aaa where aaa.sta <> "C" and aaa.regdt <= d_date  no-lock :
        find first cif where cif.cif = aaa.cif and (cif.type = "B" or cif.type = "b") no-lock no-error.
        if avail cif then do:
            find first b-aaa where b-aaa.cif = cif.cif and (b-aaa.cr[1] - b-aaa.dr[1] <> 0) no-lock no-error.
            if not avail b-aaa then do:
                find first lgr where lgr.lgr = aaa.lgr no-lock  no-error.
                if available lgr then
                if lgr.led = "DDA" then do:
                    if can-do('143,144,145',lgr.lgr) then next.
                    if aaa.cr[1] - aaa.dr[1] = 0 then do:
                        find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin   no-lock no-error.
                        if not avail jl then do:
                            find first aas where aas.aaa = aaa.aaa no-lock no-error.
                            if avail aas then do:
                                create tmp_t1.
                                update
                                tmp_t1.gl_name = aaa.name.
                                tmp_t1.gl_desc = aaa.aaa.
                                tmp_t1.gl_cif = aaa.cif.
                            end.
                            else do:
                                create tmp_t2.
                                update
                                tmp_t2.gl_name = aaa.name.
                                tmp_t2.gl_desc = aaa.aaa.
                                tmp_t2.gl_cif = aaa.cif.
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.

    for each tmp_t1:
        for each aaa where aaa.cif = tmp_t1.gl_cif and aaa.aaa <> tmp_t1.gl_desc no-lock:
            find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin no-lock no-error.
            if avail jl then do:
                delete tmp_t1.
                leave.
            end.
        end.
    end.

    for each tmp_t2:
        for each aaa where aaa.cif = tmp_t2.gl_cif and aaa.aaa <> tmp_t2.gl_desc no-lock:
            find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin no-lock no-error.
            if avail jl then do:
                delete tmp_t2.
                leave.
            end.
        end.
    end.

    run PrintRep("юридических").

    EMPTY TEMP-TABLE tmp_t1.
    EMPTY TEMP-TABLE tmp_t2.
end procedure.

procedure RepP:
    display "....... Ж Д И Т Е ......."  with row 12 frame ww centered.
    pause 0.

    for each aaa where aaa.sta <> "C" and aaa.regdt <= d_date  no-lock :
        find first cif where cif.cif = aaa.cif and (cif.type = "P" or cif.type = "p") no-lock no-error.
        if avail cif then do:
            find first b-aaa where b-aaa.cif = cif.cif and (b-aaa.cr[1] - b-aaa.dr[1] <> 0) no-lock no-error.
            if not avail b-aaa then do:
                find first lgr where lgr.lgr = aaa.lgr no-lock  no-error.
                if available lgr then
                if lgr.led = "SAV" then do:
                    if can-do('138,139,140',lgr.lgr) then next.
                    if aaa.cr[1] - aaa.dr[1] = 0 then do:
                        find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin   no-lock no-error.
                        if not avail jl then do:
                            find first aas where aas.aaa = aaa.aaa no-lock no-error.
                            if avail aas then do:
                                create tmp_t1.
                                update
                                tmp_t1.gl_name = aaa.name.
                                tmp_t1.gl_desc = aaa.aaa.
                                tmp_t1.gl_cif = aaa.cif.
                            end.
                            else do:
                                create tmp_t2.
                                update
                                tmp_t2.gl_name = aaa.name.
                                tmp_t2.gl_desc = aaa.aaa.
                                tmp_t2.gl_cif = aaa.cif.
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.

    for each tmp_t1:
        for each aaa where aaa.cif = tmp_t1.gl_cif and aaa.aaa <> tmp_t1.gl_desc no-lock:
            find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin no-lock no-error.
            if avail jl then do:
                delete tmp_t1.
                leave.
            end.
        end.
    end.

    for each tmp_t2:
        for each aaa where aaa.cif = tmp_t2.gl_cif and aaa.aaa <> tmp_t2.gl_desc no-lock:
            find last jl where jl.acc = aaa.aaa and jl.jdt >= d_date and jl.jdt <= d_date_fin no-lock no-error.
            if avail jl then do:
                delete tmp_t2.
                leave.
            end.
        end.
    end.

    run PrintRep("физических").

    EMPTY TEMP-TABLE tmp_t1.
    EMPTY TEMP-TABLE tmp_t2.
end procedure.

procedure PrintRep:
    def input parameter p-str as char.

    output to value(file1).
    {html-title.i}
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Список счетов клиентов " p-str " лиц c нулевым остатком, у которых отсутствуют движения за период с "d_date " по "d_date_fin " на которые наложены спец. инструкции  " + "</P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        "<TD>Клиент</TD>" skip
        "<TD>Счёт</TD>" skip
        "</TR>" skip.

    for each tmp_t1 no-lock:
        put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
        put unformatted
            "<td>" tmp_t1.gl_name format "x(50)" "</td>" skip
            "<td>" tmp_t1.gl_desc  "</td>" skip.
    end.

    put unformatted "</TABLE>" skip.

    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Список счетов клиентов " p-str " лиц c нулевым остатком, у которых отсутствуют движения за период с "d_date " по "d_date_fin " без спец. инструкций  " + "</P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        "<TD>Клиент</TD>" skip
        "<TD>Счёт</TD>" skip
        "</TR>" skip.

    for each tmp_t2  no-lock :
        put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
        put unformatted
            "<td>" tmp_t2.gl_name format "x(50)" "</td>" skip
            "<td>" tmp_t2.gl_desc  "</td>" skip.
    end.

    {html-end.i " "}
    output close.
    hide frame ww.
    unix silent cptwin value(file1) iexplore.
end procedure.
