/* casher8n.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Общийй отчет по проведенным кассовым операциям
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
        22.08.2006 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
*/

{keyord.i} /*Переход на новые и старые форматы форм*/

def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-aah   like jh.jh     no-undo.
def var m-who   like aal.who   no-undo.
def var m-ln    like aal.ln    no-undo.
def var m-crc   like crc.crc   no-undo.
def var m-sumd  like aal.amt   no-undo.
def var m-sumk  like aal.amt   no-undo.
def var m-amtd  like aal.amt   no-undo.
def var m-amtk  like aal.amt   no-undo.
def var m-diff  like aal.amt   no-undo.
def var m-beg   like glbal.bal no-undo.
def var m-end   like glbal.bal no-undo.
def var m-att as log format "***/   " no-undo.
def var m-row as integer       no-undo.
def var m-cashgl like jl.gl    no-undo.
def var vprint as logical      no-undo.
def var dest as char           no-undo.
def var m-first as logical     no-undo.
def var m-firstout as logical  no-undo.

def buffer b-jl for jl.

def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field cam like glbal.cam.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

if v-noord = no then do:
    dest = "prit".
    {casher8.f}
    update vappend dest with frame image1.
end.

hide frame image1.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
    m-cashgl = inval.
    m-firstout = no.

    if vappend then output to rpt.img append. else output to rpt.img.
    {casher81.f}
    view frame a.

    put stream v-out unformatted
        "<P align=left>Все кассовые операции</P>" skip
        "<P align=left>Исполнитель  " g-ofc + " Дата  " + string(g-today,"99/99/9999") "</P>" skip
        "<P align=left>Дата печати   " string(today,"99/99/9999") + " " + string(time,"HH:MM:SS") "</P>" skip
        "<P></P>" skip
        "<P></P>" skip.

    put stream v-out unformatted
            "<TABLE bordercolor=""white"" width=""100%"" cellspacing=""0"" cellpadding=""0"" border = ""1"">" skip.

    find first jl where jl.jdt = g-today no-lock no-error.
    if available jl then do:
        for each jl  where jl.jdt = g-today no-lock break by jl.crc by jl.jh by jl.ln :
            if first-of(jl.crc) then do:
                find crc where crc.crc = jl.crc no-lock no-error.
                m-sumd = 0.
                m-sumk = 0.
                m-first = false.
            end.
            if jl.gl = m-cashgl then do:
                find jh where jh.jh = jl.jh no-lock no-error.
                if available jh then do:
                    m-aah = jl.jh.
                    m-who = jl.who.
                    m-ln = jl.ln.
                    m-amtd = 0.
                    m-amtk = 0.
                    if jl.dc eq "D" then do:
                        m-amtd = jl.dam.
                        m-sumd = m-sumd + m-amtd.
                    end.
                    else do:
                        m-amtk = jl.cam.
                        m-sumk = m-sumk + m-amtk.
                    end.

                    if not m-first then do:
                        view frame a86 .
                        put stream v-out unformatted
                            "<TR align=left><FONT size=2>" skip
                            "<TD>Номер операции</TD>" skip
                            "<TD>Исполн.</TD>" skip
                            "<TD>Лин</TD>" skip
                            "<TD>Дебет</TD>" skip
                            "<TD>Кредит</TD>" skip
                            "<TD>Акцепт</TD>" skip
                            "<TD>СТС</TD>" skip
                            "<TD>ВНM</TD>" skip
                            "</FONT></TR>" skip.
                        m-first = true.
                    end.

                    {casher83.f}
                    m-att =  jh.sts < 6 .
                    display m-aah m-who m-ln m-amtd m-amtk jl.teller jh.sts m-att with width 130 frame c no-box  no-hide overlay.

                    put stream v-out unformatted
                        "<TR align=left><FONT size=2>" skip
                        "<TD>" string(m-aah) "</TD>" skip
                        "<TD>" string(m-who) "</TD>" skip
                        "<TD>" string(m-ln) "</TD>" skip
                        "<TD>" string(m-amtd,"zzz,zzz,zzz,zzz.99-") "</TD>" skip
                        "<TD>" string(m-amtk,"zzz,zzz,zzz,zzz.99-") "</TD>" skip
                        "<TD>" string(jl.teller) "</TD>" skip
                        "<TD>" string(jh.sts) "</TD>" skip
                        "<TD>" string(m-att) "</TD>" skip
                        "</FONT></TR>" skip.
                end.
            end.
            if last-of(jl.crc) and m-first then do:
                find first cashf where cashf.crc = jl.crc.
                cashf.dam = cashf.dam + m-sumd .
                cashf.cam = cashf.cam + m-sumk .
                m-diff = m-sumd - m-sumk.
                {casher82a.f}
                display m-sumd m-sumk m-diff crc.code with frame ba no-box no-label.
                hide frame ba.
                hide frame a.
                display skip(1).

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Сумма</TD>" skip
                    "<TD colspan=3>" string(m-sumd,"zzz,zzz,zzz,zzz.99-") "</TD>" skip
                    "<TD colspan=3>" string(m-sumk,"zzz,zzz,zzz,zzz.99-") "</TD>" skip
                    "</FONT></TR>" skip
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Обороты</TD>" skip
                    "<TD colspan=3>" string(m-diff,"zzz,zzz,zzz,zzz.99-") "</TD>" skip
                    "<TD colspan=3>" crc.code "</TD>" skip
                    "</FONT></TR>" skip
                    "<TR>" skip
                    "<TD colspan=8 height=""20""></TD>" skip
                    "</TR>" skip.
            end.
        end.
        put stream v-out unformatted
            "</TABLE>" skip.
    end.

    put stream v-out unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
        "<TR align=left><FONT size=2>" skip
        "<TD>валюта</TD>" skip
        "<TD>Входящие остатки</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>Исходящ.остатки</TD>" skip
        "</FONT></TR>" skip.

    {casher85.f}

    for each crc where crc.sts ne 9 no-lock:
        find first cashf where cashf.crc = crc.crc no-lock no-error.
        find glbal where glbal.gl = m-cashgl and glbal.crc = crc.crc no-lock no-error.
        if available glbal then do:
            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" crc.code "</TD>" skip
                "<TD>" string(glbal.bal,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(cashf.dam,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(cashf.cam,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(glbal.bal + (cashf.dam - cashf.cam),"z,zzz,zzz,zz9.99-") "</TD>" skip
                "</FONT></TR>" skip.

            display crc.code
            glbal.bal format "z,zzz,zzz,zz9.99-"
            cashf.dam format "z,zzz,zzz,zz9.99-"
            cashf.cam format "z,zzz,zzz,zz9.99-"
            (glbal.bal + (cashf.dam - cashf.cam)) format "z,zzz,zzz,zz9.99-" skip(1) with no-label no-box.
        end.
        else do:
            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" crc.code "</TD>" skip
                "<TD></TD>" skip
                "<TD>" string(cashf.dam,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(cashf.cam,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.

            display crc.code
            cashf.dam format "z,zzz,zzz,zz9.99-"
            cashf.cam format "z,zzz,zzz,zz9.99-" with no-label no-box.
        end.
    end.

    put stream v-out unformatted
        "</TABLE>" skip
        "<P align=left>*****************Конец документа***********************</P>" skip.

    {casher85a.f}

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

    output close.
    pause 0	before-hide.
    run	menu-prt( "rpt.img" ).
    pause before-hide.
end.
else do:
    {casher85b.f}
end.
return.
