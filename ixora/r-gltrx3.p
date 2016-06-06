/* r-gltrx3.p
 * MODULE
         Транзакции по счетам главной книги
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
   last: 05.12.2001, sasco - печатать без разрыва страниц - {report1.i 0}
         26.12.2001, sasco - если нет оборотов, то и не печатать
         21.05.2003, nataly  в назначении платежа вместо "Внебалансовый ордер" (rem[1])
                             выдается rem[2]
         02.02.10 marinav - расширение поля счета до 20 знаков
         26.05.10 marinav - занулять начальное сальдо при  if first-of(gl.gl)
         19.01.11 Luiza  -  расширила формат для вывода данных jl.dam и jl.cam  format "zz,zzz,zzz,zzz,zz9.99CR"
         21.01.11 Luiza  -  уменьшила формат для вывода данных примечания с 43 до 35  v-rem format "x(35)"
         06.03.2012 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
         07.03.12 damir - убрал keyord.i
*/

{mainhead.i} /* REPORT JOURNAL TRANSACTION */

define var fdt as date.
define var tdt as date.
define var vgl like gl.gl.
define var vtitle2 as char form "x(132)".
define var vwho like jl.who.
define var vcif like cif.cif.
define var vst  like jl.dam.
define var ven  like jl.dam.
define var ven1  like jl.dam.
define var vlog as log init false.
define variable dag as date.
def var v-rem as char.
def var ofi as char.

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

fdt = g-today.
tdt = g-today.

{image1.i rpt.img}
{r-gltrx2.f}

find sysc where sysc.sysc eq "BEGDAY" no-lock no-error.

if g-batch eq false then do:
    update {r-gltup3.f}
end.
if fdt gt tdt then return.
if vgl eq 0 and year(fdt) ne year(tdt) then do:
    message "Для счетов дохода/расхода такой период недопустим"
    view-as alert-box.
    return.
end.

find gl where gl.gl eq vgl no-lock no-error.
if gl.type eq "R" or gl.type eq "E" then do:
    if year(fdt) ne year(tdt) then do:
        message "Для счетов дохода/расхода такой период недопустим"
        view-as alert-box.
        return.
    end.
end.

{image2.i}

{report1.i 63}
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[1] = 1 then do:
    output close.
    output to value(vimgfname) page-size 0 append.
end.


vtitle2 = {r-gltvt2.f}

form
    jl.jh
    jl.dam  format "zz,zzz,zzz,zzz,zz9.99CR"
    jl.cam  format "zz,zzz,zzz,zzz,zz9.99CR"
    jl.acc  format "x(20)"  v-rem format "x(35)" jh.cif format "x(6)" jl.who
with no-label width 142 down frame detail.

find first cmp no-lock no-error.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then ofi = "Исп. " + caps(g-ofc).

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

for each crc no-lock where crc.sts ne 9 break by crc.crc:
    if first(crc) eq false then page.
    find first jl where jl.jdt ge fdt and jl.jdt le tdt and (vgl eq 0 or jl.gl eq vgl) and jl.crc = crc.crc no-lock no-error.

    if not available jl then  next.

    vtitle =  {r-gltvt.f}

    {report2.i 132 "vtitle2 fill(""="",132) format ""x(132)"" "}

    put stream v-out unformatted
        "<TR align=left>" skip
        "<TD colspan=8>" cmp.name + "  " + string(today,"99/99/9999") + "  " + string(time,"HH:MM:SS") + "  " + ofi "</TD>" skip
        "</TR>" skip
        "<TR align=left>" skip
        "<TD colspan=8>" g-fname + "  Транзакции по счетам главной книги с " + string(fdt,"99/99/9999") + "  на  " +
        string(tdt,"99/99/9999") "</TD>" skip
        "</TR>" skip
        "<TR align=left>" skip
        "<TD colspan=8>" vtitle "</TD>" skip
        "</TR>" skip
        "<TR align=center><FONT size=2>" skip
        "<TD>ТРАНЗАКЦИЯ</TD>" skip
        "<TD width=30%>ДЕБЕТ</TD>" skip
        "<TD width=30%>КРЕДИТ</TD>" skip
        "<TD>ПРИМЕЧАНИЕ</TD>" skip
        "<TD colspan=2>ОТВЕТИСПОЛНИТЕЛЬ</TD>" skip
        "</FONT></TR>" skip.

    for each jl no-lock where jl.jdt ge fdt and  jl.jdt le tdt and  jl.crc eq crc.crc use-index jdt ,
    each gl no-lock where gl.gl eq jl.gl and  (gl.gl eq vgl or vgl eq 0) ,jh no-lock where jh.jh eq jl.jh break by gl.gl
    by jl.jdt by jl.dam by jl.cam by jl.jh by jl.ln:

        if first-of(gl.gl) then do:
            vst = 0.
            if gl.type eq "A" or gl.type eq "E" then vlog = true.
            else vlog = false.

            find last glday where glday.gdt lt fdt and  glday.gl eq gl.gl and glday.crc eq crc.crc no-lock no-error.
            if available glday then do:
                if (gl.type eq "R" or gl.type eq "E") and year(fdt) ne year(glday.gdt) then vst = 0.
                else do.
                    if vlog eq true then vst = glday.dam - glday.cam.
                    else vst = glday.cam - glday.dam.
                end.
            end.

            ven = vst.

            if not first(gl.gl) then page.

            {r-gltsb.f}

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=6>СЧЕТ ГК  " string(gl.gl) + "  НАИМЕНОВАНИЕ  " + gl.des "</TD>" skip
                "</FONT></TR>" skip
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=6>НАЧАЛЬНЫЙ БАЛАНС  " string(vst,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</FONT></TR>" skip.

        end.

        if jl.rem[1] matches '*внебалансовый ордер*' then  v-rem = jl.rem[2].
        else v-rem = jl.rem[1].

        display
            jl.jh jl.dam jl.cam jl.acc v-rem jh.cif jl.who string(jh.tim,"HH:MM")
        with frame detail.

        put stream v-out unformatted
            "<TR align=center><FONT size=2>" skip
            "<TD>" string(jl.jh) "</TD>" skip
            "<TD>" string(jl.dam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(jl.cam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD align=left>" v-rem "</TD>" skip
            "<TD>" jl.who "</TD>" skip
            "<TD>" string(jh.tim,"HH:MM") "</TD>" skip
            "</FONT></TR>" skip.

        down 1 with frame detail.
        if vlog eq true then ven = ven + jl.dam - jl.cam.
        else ven = ven - jl.dam + jl.cam.
        accumulate jl.dam (total by jl.jdt) jl.cam (total by jl.jdt).
        if last-of(jl.jdt) then do:
            underline jl.dam jl.cam with frame detail.
            down 1 with frame detail.
            display
                accum sub-total by jl.jdt jl.dam @ jl.dam format "zz,zzz,zzz,zzz,zz9.99CR"
                accum sub-total by jl.jdt jl.cam @ jl.cam format "zz,zzz,zzz,zzz,zz9.99CR"
                string(jl.jdt) @ v-rem
            with frame detail.
            down 2 with frame detail.

            put stream v-out unformatted
                "<TR align=center><FONT size=2>" skip
                "<TD></TD>" skip
                "<TD>" string(accum sub-total by jl.jdt jl.dam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum sub-total by jl.jdt jl.cam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(jl.jdt,"99/99/9999") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.
        end.  /* if last-of(jl.jdt) */

        if last-of(gl.gl) then do:
            if fdt ne tdt then do:
                underline jl.dam jl.cam with frame detail.
                down 1 with frame detail.
                display
                    accum total jl.dam @ jl.dam format "zz,zzz,zzz,zzz,zz9.99CR"
                    accum total jl.cam @ jl.cam format "zz,zzz,zzz,zzz,zz9.99CR"
                with frame detail.
             end. /* if fdt ne tdt */

             down 1 with frame detail.

            {r-glteb.f}

            put stream v-out unformatted
                "<TR align=center><FONT size=2>" skip
                "<TD></TD>" skip
                "<TD>" string(accum total jl.dam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum total jl.cam,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip
                "<TR align=center><FONT size=2>" skip
                "<TD colspan=3 align=rigth>КОНЕЧНЫЙ БАЛАНС</TD>" skip
                "<TD>" string(ven1,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.

        end.
    end. /* for each jl */
end.  /*for each crc */

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

{report3.i}
/*{image3.i}*/

pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.
