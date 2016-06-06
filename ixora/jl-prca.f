/* jl-prca.f
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
        24.05.2004 nadejda - убран логин офицера из распечатки
        06.03.2012 damir - переход на новые форматы, нередактируемые документы.
        13.03.2012 damir - добавил возможность печати на матричный принтер пользователей которые есть в printofc.
*/


/* sasco . принтер из OFC
*/

def shared var v-point like point.point.
def var v-ndoc as char format "x(10)".

find point where point.point = v-point no-lock no-error.
find first ujo where ujo.jh = s-jh no-lock no-error.
if avail ujo then v-ndoc = trim(string(ujo.docnum)).
find first cmp no-lock no-error.
find first ofc where ofc.ofc = jh.who no-lock no-error.

put skip(3)
"============================================================================="
skip
cmp.name "Кассовый Операционный Ордер"
jh.jdt " " string(time,"HH:MM") "   * " ofc.name skip
point.addr[1] skip.
if point.addr[2] <> " " then put point.addr[2] skip.
if point.addr[3] <> " " then put point.addr[3] skip.
put point.regno skip point.licno " Документ " trim(string(v-ndoc))skip
" " jh.jh " " jh.cif " " jh.party  skip
"=============================================================================".

put stream v-out unformatted
    "<P align=left><FONT size=2>" cmp.name + "  Кассовый Операционный Ордер  " + string(jh.jdt,"99/99/9999") + "  " +
    string(time,"HH:MM") + "  *  " + ofc.name "</FONT></P>" skip
    "<P align=left><FONT size=2>" point.addr[1] "</FONT></P>" skip.
if point.addr[2] <> " " then put stream v-out unformatted
    "<P align=left><FONT size=2>" point.addr[2] "</FONT></P>" skip.
if point.addr[3] <> " " then put stream v-out unformatted
    "<P align=left><FONT size=2>" point.addr[3] "</FONT></P>" skip.
put stream v-out unformatted
    "<P align=left><FONT size=2>" point.regno "</FONT></P>" skip
    "<P align=left><FONT size=2>" point.licno + "  Документ  " + trim(string(v-ndoc)) "</FONT></P>" skip
    "<P align=left><FONT size=2>" string(jh.jh) + "  " + jh.cif + "  " + jh.party "</FONT></P>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
for each jl of jh use-index jhln where jl.gl = sysc.inval no-lock break by jl.crc :
    find crc of jl.
    if jl.dam gt 0 then do:
        xin = jl.dam. xout = 0. intot = intot + xin.
    end.
    else do:
        xin = 0. xout = jl.cam.  outtot = outtot + xout.
    end.
    disp
        crc.des label "ВАЛЮТА  " xin (sub-total by jl.crc) xout(sub-total by jl.crc)
    with no-box down frame inout.

    put stream v-out unformatted
        "<TR align=left><FONT size=2>" skip
        "<TD>ВАЛЮТА  " crc.des "</TD>" skip
        "<TD>" string(xin,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" string(xout,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "</FONT></TR>" skip.
end.

put stream v-out unformatted
    "</TABLE>" skip.

put
"============================================================================="
skip
"                  |                   |                   |                 "
skip
"=============================================================================".

/* by sasco */
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).


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

