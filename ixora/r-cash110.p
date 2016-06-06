/* r-cash110.p
 * MODULE
         Транзакции по счетам главной книги 100110
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
 * BASES
        BANK COMM
 * AUTHOR
        11.12.10 marinav
 * CHANGES
        02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
        07.03.12 damir - убрал keyord.i
        24.07.2012 damir - добавил cashrep.i, изменение формата вывода в WORD.
*/

{mainhead.i }
{cashrep.i}

define var fdt as date.
define var tdt as date.
define var vgl like gl.gl.
define var vtitle2 as char form "x(132)".
define var vtitle3 as char form "x(132)".
define var v-bal1  like jl.dam.
define var v-bal2  like jl.dam.
define var v-end1  like jl.dam.
define var v-end2  like jl.dam.
def var v-arp like arp.arp.
def var v-rem as char.
def var v-glacc as int format ">>>>>>".
def var v-depart as inte.
def var v-nom as inte format "zz9".
def buffer b-jl for jl.
def var v-tim as char.
def var ofi as char format "x(12)".

def temp-table cas
 field crc as char
 field bal1 as deci
 field dam  as deci
 field cam  as deci
 field bal2 as deci.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/reportdel.htm".
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
vgl = 100110.

{image1.i rpt.img}
update
    fdt      label " Начало периода   "  help " Задайте дату отчета" skip
    tdt      label " Конец периода    "  help " Задайте дату отчета" skip
with row 8 centered  side-label frame opt title "Отчет по кассовым оборотам 100110".
hide frame  opt.

find gl where gl.gl eq vgl no-lock no-error.
{image2.i}
{report1.i 63}

vtitle2 = "Операция          Дебет           Кредит                      ПРИМЕЧАНИЕ                     Исполнитель Время    Акцепт".

form
    jl.jh
    jl.dam  format "zzz,zzz,zz9.99"
    jl.cam  format "zzz,zzz,zz9.99"
    v-rem format "x(53)" jl.who v-tim jl.teller
with no-label width 132 down frame detail.

find first cmp no-lock no-error.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then ofi = "Исп. " + caps(g-ofc).

for each crc no-lock where crc.crc <  5 break by crc.crc:
    assign v-nom = 0 v-arp = "" v-bal1 = 0 v-bal2 = 0.
    if first(crc) eq false then page.
    /*
    find first jl where jl.jdt = fdt and  jl.gl eq vgl and jl.crc = crc.crc no-lock no-error.
    if not available jl then  next.
    */
    find last glday where glday.gdt < fdt  and  glday.gl eq vgl and glday.crc eq crc.crc  no-lock no-error.
    if avail glday then v-bal1 = glday.dam - glday.cam.


    vtitle = "  Обороты по счету 100110 Наличность в хранилище c :" + string(fdt) + " по " + string(tdt)              .
    vtitle3 = " ВАЛЮТА   - " + caps(crc.des).

    {rep.i 132 "vtitle2 fill(""="",132) format ""x(132)"" "}

    create cas.
    cas.crc = crc.code.
    cas.bal1 = v-bal1.

    put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

    for each jl no-lock where jl.jdt >= fdt  and jl.jdt <= tdt  and  jl.gl eq vgl and  jl.crc eq crc.crc  use-index jdt
    ,each gl no-lock where gl.gl eq jl.gl, jh no-lock where jh.jh eq jl.jh  break by gl.gl by jl.jdt by jl.cam by jl.dam by jl.jh :
        if v-nom = 0  then do:
            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=7>" cmp.name + "  " + string(today,"99/99/9999") + string(time,"HH:MM:SS") + "  " + ofi "</TD>" skip
                "</TR>" skip
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=7>" vtitle "</TD>" skip
                "</TR>" skip
                "<TR align=left style=""font:bold;font-size:9.0pt"">" skip
                "<TD colspan=7>" vtitle3 "</TD>" skip
                "</TR>" skip
                "<TR align=center style=""font-size:9.0pt"">" skip
                "<TD>Операция</TD>" skip
                "<TD width=14%>Дебет</TD>" skip
                "<TD width=14%>Кредит</TD>" skip
                "<TD width=32%>ПРИМЕЧАНИЕ</TD>" skip
                "<TD>Исполнитель</TD>" skip
                "<TD>Время</TD>" skip
                "<TD>Акцепт</TD>" skip
                "</TR>" skip.

            display
            v-bal1 label "НАЛИЧНОСТЬ В ХРАНИЛИЩЕ       - 100110 "  with width 122 side-label frame gl.

            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=5>НАЛИЧНОСТЬ В ХРАНИЛИЩЕ - 100110</TD>" skip
                "<TD colspan=2>" string(v-bal1,"z,zzz,zzz,zz9.99-") "</TD>" skip
                "</TR>" skip.
        end.
        v-rem = trim(jl.rem[1] + jl.rem[2]).
        v-nom = v-nom + 1.
        v-tim = string(jh.tim,"HH:MM") .
        display jl.jh jl.dam jl.cam v-rem jl.who v-tim jl.teller  with frame detail.
        down 1 with frame detail.

        put stream v-out unformatted
            "<TR align=center style=""font-size:9.0pt"">" skip
            "<TD>" string(jl.jh) "</TD>" skip
            "<TD align=right>" string(jl.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD align=right>" string(jl.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD align=left>" v-rem "</TD>" skip
            "<TD>" jl.who "</TD>" skip
            "<TD>" v-tim "</TD>" skip
            "<TD>" jl.teller "</TD>" skip
            "</TR>" skip.

        v-bal1 = v-bal1 + jl.dam - jl.cam.
        accumulate jl.dam (total by jl.jdt)  jl.cam (total by jl.jdt).

        if last-of(jl.jdt) then do:
            underline jl.dam jl.cam with frame detail.
            down 1 with frame detail.
            display
            accum sub-total by jl.jdt jl.dam @ jl.dam  format "z,zzz,zzz,zz9.99"
            accum sub-total by jl.jdt jl.cam @ jl.cam  format "z,zzz,zzz,zz9.99" with frame detail.
            down 2 with frame detail.

            put stream v-out unformatted
                "<TR align=center style=""font-size:9.0pt"">" skip
                "<TD></TD>" skip
                "<TD align=right>" string(accum sub-total by jl.jdt jl.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD align=right>" string(accum sub-total by jl.jdt jl.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</TR>" skip.

            cas.dam = cas.dam + accum sub-total by jl.jdt jl.dam.
            cas.cam = cas.cam + accum sub-total by jl.jdt jl.cam.
        end.

        if last-of(gl.gl) then do:
            display v-bal1 label "НАЛИЧНОСТЬ В ХРАНИЛИЩЕ       - 100110 "  at 40  with side-label frame bal.

            put stream v-out unformatted
                "<TR align=center style=""font-size:9.0pt"">" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD colspan=3>НАЛИЧНОСТЬ В ХРАНИЛИЩЕ       - 100110</TD>" skip
                "<TD>" string(v-bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</TR>" skip.

            cas.bal2 = v-bal1.
        end.
    end. /* for each jl */
    put stream v-out unformatted
        "</TABLE>" skip.
    put stream v-out unformatted
        "<br clear=all style='page-break-before:always'>" skip.
end.  /*for each crc */

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=center style=""font-size:9.0pt"">" skip
    "<TD>Валюта</TD>" skip
    "<TD>Входящие остатки</TD>" skip
    "<TD>Дебет</TD>" skip
    "<TD>Кредит</TD>" skip
    "<TD>Исходящие остатки</TD>" skip
    "</TR>" skip.

page.
displ "Валюта 	Входящие остатки            Дебет           Кредит   Исходящие остатки" skip  with no-label width 132 frame itog.
displ "-------------------------------------------------------------------------------" skip  with no-label width 132 frame itog.
for each cas.
    displ cas.crc cas.bal1 format "z,zzz,zzz,zz9.99"  cas.dam format "z,zzz,zzz,zz9.99" cas.cam format "z,zzz,zzz,zz9.99" cas.bal2 format "z,zzz,zzz,zz9.99" with no-label width 132 frame itog1.
    put stream v-out unformatted
    "<TR align=center style=""font-size:9.0pt"">" skip
    "<TD>" string(cas.crc) "</TD>" skip
    "<TD align=right>" string(cas.bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
    "<TD align=right>" string(cas.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
    "<TD align=right>" string(cas.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
    "<TD align=right>" string(cas.bal2,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
    "</TR>" skip.
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

if v-norep = yes then unix silent cptwin value(v-file2) winword.

{report3.i}
/*{image3.i}*/

pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.

