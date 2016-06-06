/* cas8.p
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
       07.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
*/

/* Sushinin  Vladimir
Общий отчет по проведенным кассовым операциям
20.10.93.
*/

{keyord.i} /*Переход на новые и старые форматы форм*/

def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def buffer ppglday for pglday.
def var s-bday as log.
def var vdate as date.
def var m-crc like crc.crc.
def var m-sumd like aal.amt.
def var m-sumk like aal.amt.
def var m-amtd like aal.amt.
def var m-amtk like aal.amt.
def var m-diff like aal.amt.
def var m-beg like glbal.bal.
def var m-end like glbal.bal.
def var p-bal like pglbal.bal.
def var m-cashgl like jl.gl.
def var vprint as logical.
def var dest as char.
def var punum like point.point.
def var v-point like point.point.
def var prizn as logical init false.
def var s-target as date.
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

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   punum =  ofc.regno / 1000 - 0.5 .
end.

for each crc where crc.sts ne 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

if v-noord = no then do:
    dest = "prit".
    {cas8.f}
    update vappend dest with frame image1.
end.

if punum = 99 then do:
    update punum with frame im1.
end.

vdate = g-today - 1.
do:
    update vdate with frame i1.
    if vdate > (g-today - 1) then undo,retry.
end.

s-target = vdate .

/*s-target = g-today + 1.*/

find hol where hol.hol eq vdate no-error.
if not available hol and
   weekday(vdate) ge 2 and
   weekday(vdate) le 6
  then s-bday = true.
  else s-bday = false.

repeat while month(vdate) eq month(s-target):
  find hol where hol.hol eq s-target no-error.
  if not available hol and
     weekday(s-target) ge 2 and
     weekday(s-target) le 6
  then leave.
  else s-target = s-target - 1.
end.


find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
m-cashgl = inval.

if vappend then output to rpt.img append.
else output to rpt.img.
{cas81.f}
view frame a.

put stream v-out unformatted
    "<P align=left>Все кассовые операции за   " + string(vdate,"99/99/9999") + "  Пункт N  "  + string(punum) "</P>" skip
    "<P align=left>Исполнитель   " + g-ofc + "  Дата печати  " + string(today,"99/99/9999") + " " + string(time,"HH:MM:SS") "</P>" skip
    "<P></P>" skip.

for each jl where jl.jdt = vdate no-lock:

    /*
        find ofc where ofc.ofc = jl.who no-lock no-error.
        if available ofc then do:
            v-point = ofc.regno / 1000 - 0.5.
        end.
    */

    v-point = jl.point.


    find first cashf where cashf.crc = jl.crc.
    m-sumd = 0.
    m-sumk = 0.
    if jl.gl = m-cashgl then do:
        if jl.dc eq "D" then do:
            if v-point eq punum then do:
                m-amtd = jl.dam.
                m-sumd = m-sumd + m-amtd.
            end.
        end.
        else do:
            if v-point eq punum then do:
                m-amtk = jl.cam.
                m-sumk = m-sumk + m-amtk.
            end.
        end.
        cashf.dam = cashf.dam + m-sumd .
        cashf.cam = cashf.cam + m-sumk .
        m-diff = m-sumd - m-sumk.
    end.
end.  /*each jl*/

{casher08.f}

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream v-out unformatted
    "<TR align=left><FONT size=2>" skip
    "<TD>Валюта</TD>" skip
    "<TD>Входящий остаток</TD>" skip
    "<TD>Дебет</TD>" skip
    "<TD>Кредит</TD>" skip
    "<TD>Исходящий остаток</TD>" skip
    "</FONT></TR>" skip.

for each crc where crc.sts ne 9 no-lock:
    find first cashf where cashf.crc = crc.crc no-lock no-error.
    /*
    if vdate = g-today then do:
        for each pglbal where pglbal.gl = m-cashgl and pglbal.crc = crc.crc and
            pglbal.point = punum :
            p-bal = p-bal + pglbal.bal.
        end.
    end.
    */
    if vdate < g-today then do:
        for each pglbal where pglbal.point = punum and pglbal.gl = m-cashgl
            and pglbal.crc = crc.crc:
                find last pglday where pglday.gl = pglbal.gl and
                pglday.crc = pglbal.crc and pglday.point = pglbal.point
                and pglday.gdt le s-target and pglday.depart = pglbal.depart
                no-lock.
                if available pglday then p-bal = p-bal + pglday.bal.
        end.
    end.
    /*find first cashf where cashf.crc = crc.crc no-lock no-error.*/
    if p-bal <> 0 or cashf.dam <> 0 or cashf.cam <> 0 then do:
        display crc.code
        p-bal format "z,zzz,zzz,zz9.99-"
        cashf.dam format "z,zzz,zzz,zz9.99-"
        cashf.cam format "z,zzz,zzz,zz9.99-"
        (p-bal + (cashf.dam - cashf.cam)) format "z,zzz,zzz,zz9.99-" skip(1)
        with no-label no-box.

        put stream v-out unformatted
            "<TR align=left><FONT size=2>" skip
            "<TD>" crc.code "</TD>" skip
            "<TD>" string(p-bal,"z,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(cashf.dam,"z,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(cashf.cam,"z,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(p-bal + (cashf.dam - cashf.cam),"z,zzz,zzz,zz9.99-") "</TD>" skip
            "</FONT></TR>" skip.
    end.
    p-bal = 0.
end.

put stream v-out unformatted
    "</TABLE>" skip
    "<P align=left>*****************Конец документа***********************</P>" skip.

{casher18.f}

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
else display "Not found CASHGL in sysc".
return.
