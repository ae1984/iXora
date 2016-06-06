/* x-jlvou.p
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
 * CHANGES
        07/12/2001 /sasco/ - настройка принтера из OFC
        09/09/2003 sasco печать БКС
        02.03.2004 kanat    - добавил вызов bks с параметром BWX для карточных транзакций
        24.05.2004 nadejda - убран логин офицера из распечатки
        29.09.2006 u00568 Evgeniy - по тз 469 пусть печатает чек бкс по 100200
        01.02.10 marinav - расширение поля счета до 20 знаков
        07.03.2012 damir - переход на новые форматы.
        26/08/2013 galina - ТЗ1231 закрыла поток v-out и убрала открытие файла v-file в word
*/


{global.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

def var vi as int.
define  shared   var s-jh like jh.jh .
define buffer bjl for jl.
def var vcash as log.
define var vdb as cha format "x(9)" label " ".
define var vcr as cha format "x(9)" label " ".
define var vdes  as cha format "x(32)" label " ". /* chart of account desc */
define var vname as cha format "x(30)" label " ". /* name of customer */
define var vrem as cha format "x(55)" extent 7 label " ".
define var vamt like jl.dam extent 7 label " ".
define var vext as cha format "x(40)" label " ".
define var vtot like jl.dam label " ".
define var vcontra as cha format "x(53)" extent 5 label " ".
define var vpoint as int.
define var inc as int.
define var tdes like gl.des.
define var tty as cha format "x(20)".
define var vconsol as log.
define var vcif as cha format "x(6)" label " ".
define var vofc like ofc.ofc label  " ".
def var vcrc like crc.code label " ".

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
define variable s_payment as character.

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

{x-jlvou.f}

find jh where jh.jh eq s-jh.
find sysc where sysc.sysc = "CASHGL".

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

output to vou.img page-size 0.
put skip(3)
"=============================================================================="
skip vcha1 skip .
put point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno skip.
put jh.jh " " jh.jdt " " string(time,"HH:MM") " "
jh.cif " " jh.party " * " ofc.name skip.
put
"------------------------------------------------------------------------------"
skip.

put stream v-out unformatted
    "<P align=center><FONT size=3>" vcha1 "</FONT></P>" skip
    "<P align=left><FONT size=2>" point.addr[1] "</FONT></P>" skip.
if point.addr[2] <> " " then put stream v-out unformatted
    "<P align=left><FONT size=2>" point.addr[2] "</FONT></P>" skip.
if point.addr[3] <> " " then put stream v-out unformatted
    "<P align=left><FONT size=2>" point.addr[3] "</FONT></P>" skip.
put stream v-out unformatted
    "<P align=left><FONT size=2>" point.regno "</FONT></P>" skip
    "<P align=left><FONT size=2>" point.licno "</FONT></P>" skip
    "<P align=left><FONT size=2>" string(jh.jh) + "  " + string(jh.jdt,"99/99/9999") + "  " + string(time,"HH:MM") +
    jh.cif + "  " + jh.party + " * " + ofc.name "</FONT></P>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

vcash = false.
xdam = 0. xcam = 0.
for each jl of jh use-index jhln break by jl.crc by jl.ln:
    find crc where crc.crc eq jl.crc.
    find gl of jl.
    if jl.gl = sysc.inval then vcash = true.
    if jl.dam ne 0 then do:
        xamt = jl.dam.
        xdam = xdam + jl.dam.
        xco  = "DR".
    end.
    else do:
        xamt = jl.cam.
        xcam = xcam + jl.cam.
        xco = "CR".
    end.
    displ
        jl.ln jl.gl gl.sname jl.acc format "x(21)" crc.code xamt xco
    with down width 132 frame jlprt no-label no-box.

    put stream v-out unformatted
        "<TR align=left><FONT size=2>" skip
        "<TD>" string(jl.ln) "</TD>" skip
        "<TD>" string(jl.gl) "</TD>" skip
        "<TD>" string(gl.sname) "</TD>" skip
        "<TD>" jl.acc "</TD>" skip
        "<TD>" crc.code "</TD>" skip
        "<TD>" string(xamt,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" xco "</TD>" skip
        "</FONT></TR>" skip.

    if last-of(jl.crc) then do:
        put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.

        put stream v-out unformatted
            "<TR align=rigth><FONT size=2>" skip
            "<TD colspan=5>" vcha2 "</TD>" skip
            "<TD>" string(xdam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" crc.code "</TD>" skip
            "</FONT></TR>" skip
            "<TR align=rigth><FONT size=2>" skip
            "<TD colspan=5>" vcha3 "</TD>" skip
            "<TD>" string(xcam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" crc.code "</TD>" skip
            "</FONT></TR>" skip.

        xcam = 0. xdam = 0.
    end.
end.

put stream v-out unformatted
    "</TABLE>" skip.

do:
    put "--------------------------------------"
        "----------------------------------------" skip(0).
    for each jl of jh where jl.ln = 1 use-index jhln break by jl.crc by jl.ln:
        if trim(jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5]) ne "" then
        do vi = 1 to 5 :
            if vi = 1 then do:
                def var ss as int.
                ss = 1.
                repeat:
                    if (trim(substring(jl.rem[vi],ss,60)) ne "" ) then do:
                        put "     " trim(substring(jl.rem[vi],ss,60)) format "x(60)" skip(0).
                        put stream v-out unformatted
                            "<P align=left><FONT size=2>" trim(substring(jl.rem[vi],ss,60)) "</FONT></P>" skip.
                    end.
                    else leave.
                    ss = ss + 60.
                end.
            end.
            else if (trim(jl.rem[vi]) ne "" ) then do:
                put "     " trim(rem[vi]) format "x(70)" skip(0).
                put stream v-out unformatted
                    "<P align=left><FONT size=2>" trim(rem[vi]) "</FONT></P>" skip.
            end.
        end.
    end.
end.

if vcash = true then put skip(2).

else put "======================================"
         "========================================" skip.
output stream v-out close.

/* by sasco, 7/12/2001 */
if vcash = false then
do:
   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if ofc.mday[2] = 1 then put skip(14).
   else put skip(1).
end.

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

/*output close.
unix silent cptwin value(v-file) winword.*/

if v-noord = no then do:
    unix silent prit -t vou.img.
end.

if vcash = true then do:
   s-jh = jh.jh.
   run jl-prca.
end.

if v-noord = no then do:
    s_payment = ''.
    if jh.sts = 6 then do:
    for each jl where jl.jh = jh.jh and jl.jdt = jh.jdt and (jl.gl = 100100  or jl.gl = 100200  or jl.gl = 100300) no-lock:
        find first crc where crc.crc = jl.crc no-lock no-error.
        s_payment = s_payment + string(jh.jh) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
        end.
        s_payment = right-trim(s_payment,"|").
        if s_payment <> '' then do:
            if jh.party = "BWX" then run bks (s_payment,"BWX").
            else run bks (s_payment,"TRX").
        end.
    end.
end.
pause 0.
