/* aaatoday.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       05/09/2006 u00600 - оптимизация
        27.01.10 marinav - расширение поля счета до 20 знаков
        06.03.2012 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
*/

{global.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

def var i as int.
def var j as int.
def var v-index as int.
def stream m-out.
def var dest as char.
def var v-first as log.
def var v-type as log.
def var s-type as char.
def var v-okey as log.
def var v-dbeg as date.
def var v-dend as date.
def var v-name as char.
def var v-sta as char.
def var v-ofic as char.
def var v-zakr as char.
def var v-cifname as char.
def var v-tmpaaa as char.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

def temp-table otl
    field str as char format "x(130)".
v-dbeg = g-today.
v-dend = g-today.

if v-noord = no then do:
    dest = "prit".
    {aaatoday.f}
    update vappend dest with frame image1.
end.

{aaatoday0.f}

find ofc where ofc.ofc = g-ofc no-lock no-error.

if vappend then output stream m-out to rpt.img append.
else output stream m-out to rpt.img.

{aaatoday1.f}
view stream m-out frame bab.
hide frame bab.

put stream v-out unformatted
    "<P align=left>ОТКРЫТЫЕ СЧЕТА С  " string(v-dbeg,"99/99/9999") + "  ПО  " + string(v-dend,"99/99/9999") ".</P>" skip
    "<P align=left>ИСПОЛНИТЕЛЬ:" ofc.name + "  ДАТА:  " + string(g-today,"99/99/9999") "</P>" skip
    "<P align=left>ДАТА РАСПЕЧАТКИ:" string(today,"99/99/9999") + "  " + string(time,"HH:MM:SS") "</P>" skip
    "<P align=left>" "</P>" skip.

{aaatoday2.f}

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream v-out unformatted
    "<TR align=center><FONT size=2>" skip
    "<TD>КИФ</TD>" skip
    "<TD>НАИМЕНОВАНИЕ, АДРЕС</TD>" skip
    "<TD>ТИП</TD>" skip
    "<TD>СЧЕТ КЛИЕНТА</TD>" skip
    "<TD>КТО <br> ОТКРЫЛ</TD>" skip
    "<TD>КОГДА <br> ОТКРЫЛ</TD>" skip
    "<TD>СТАТУС СЧЕТА</TD>" skip
    "</FONT></TR>" skip.

for each cif where (s-type = " " or cif.type = s-type) no-lock use-index cif break by cif.type by cif.cif:
    if first-of(cif.type) then do:
        v-type = no.
        v-okey = no.
        find ofc where ofc.ofc = g-ofc no-lock no-error.
        if ofc.expr[5] matches ( "*" + trim(cif.type) + "*") then v-okey = yes .
    end.
    if v-okey then do:
    v-first = yes.
    for each aaa where aaa.cif = cif.cif  no-lock use-index cif:
        if aaa.stadt >= v-dbeg and aaa.stadt <= v-dend then do:
            if v-first then do:
                for each otl :
                    delete otl.
                end.
                v-first = no.
                assign v-tmpaaa = "".
            end.
            create otl .
            otl.str = aaa.aaa + fill(" ",21 - length(aaa.aaa)).
            v-zakr  = string(aaa.stadt).
            v-ofic  = substring(aaa.who,1,10).
            v-sta   = string(aaa.sta).
            v-tmpaaa = aaa.aaa + fill(" ",21 - length(aaa.aaa)).
        end.
    end.
    if not v-first then do :
        v-type = yes.
        v-index = 0.
        for each otl :
            if v-index = 0 then do:
                v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                v-name = substring(v-cifname,1,61).
                do i = 1 to 3:
                    if v-name <> "" then do:
                        v-name = v-name + "  " + cif.addr[i].
                    end.
                end.
                otl.str =
                cif.cif + fill(" ",7 - length(cif.cif))
                + v-name + fill(" ",62 - length(v-name))
                + '   ' + substring(cif.type,1,1)
                + fill(" ",1 - length(cif.type)) + '   '
                + otl.str + '   ' + v-ofic
                + fill(" ",10 - length(v-ofic))
                + '    ' + v-zakr + fill (" ",8 - length(v-zakr))
                + '    ' + v-sta.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD>" cif.cif "</TD>" skip
                    "<TD>" v-name "</TD>" skip
                    "<TD align=center>" substring(cif.type,1,1) "</TD>" skip
                    "<TD>" v-tmpaaa "</TD>" skip
                    "<TD>" v-ofic "</TD>" skip
                    "<TD>" v-zakr "</TD>" skip
                    "<TD>" v-sta "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            else do:
                if v-index <= 3 then do:
                    v-name = substring(trim(cif.addr[v-index]),1,61).
                    otl.str = fill(" ",7)
                    + v-name + fill(" ",62 - length(v-name))
                    + '   ' + substring(cif.type,1,1)
                    + fill(" ",1 - length(cif.type)) + '   '
                    + otl.str + '   ' + v-ofic
                    + fill(" ",10 - length(v-ofic))
                    + '    ' + v-zakr + fill (" ",8 - length(v-zakr))
                    + '    ' + v-sta.

                    /*put stream v-out unformatted
                        "<TR align=left><FONT size=2>" skip
                        "<TD></TD>" skip
                        "<TD>" v-name "</TD>" skip
                        "<TD align=center>" substring(cif.type,1,1) "</TD>" skip
                        "<TD>" v-tmpaaa "</TD>" skip
                        "<TD>" v-ofic "</TD>" skip
                        "<TD>" v-zakr "</TD>" skip
                        "<TD>" v-sta "</TD>" skip
                        "</FONT></TR>" skip.*/
                end.
                else do:
                    otl.str = fill(" ",69)
                    + '   ' + substring(cif.type,1,1)
                    + fill(" ",1 - length(cif.type)) + '   '
                    + otl.str + '   ' + v-ofic
                    + fill(" ",10 - length(v-ofic))
                    + '    ' + v-zakr + fill (" ",8 - length(v-zakr))
                    + '    ' + v-sta.

                    /*put stream v-out unformatted
                        "<TR align=left><FONT size=2>" skip
                        "<TD></TD>" skip
                        "<TD></TD>" skip
                        "<TD align=center>" substring(cif.type,1,1) "</TD>" skip
                        "<TD>" v-tmpaaa "</TD>" skip
                        "<TD>" v-ofic "</TD>" skip
                        "<TD>" v-zakr "</TD>" skip
                        "<TD>" v-sta "</TD>" skip
                        "</FONT></TR>" skip.*/
                end.
            end.
            v-index = v-index + 1.
        end.
        repeat while v-index <= 3 :
            if cif.addr[v-index] = "" then leave .
            else do:
                create otl.
                otl.str = fill(" ",7) + cif.addr[v-index] .
            end.
            v-index = v-index + 1.
        end.
        for each otl :
            display stream m-out otl.str with no-label no-box width 142.
        end.
    end.
    if last-of(cif.type) and v-type then display stream m-out fill("-",130) format "x(130)"
    skip(5) with no-label no-box width 142.
    end.

    if i = j then do:
        display v-mess i with frame d no-label row 1 column 40.
        j = j + 100.
    end.
    i = i + 1.
    pause 0.
end.

put stream v-out unformatted
    "</TABLE>" skip
    "<P align=left>*****************Конец документа***********************</P>" skip.
output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

unix silent cptwin value(v-file2) winword.

output stream m-out close.

/*unix silent value(trim(dest)) rpt.img.*/

pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.
