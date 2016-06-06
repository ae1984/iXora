/* gtecre.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        генерация номера нового GTEADV
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var s-lc like lc.lc.
def var v-lcid   as integer.
def var v-dt as char.
def var v-nom as int.
def buffer b-lc for lc.

function datestr returns char (input p-dtin as char).
def var v-dt as char.
v-dt = substr(string(year(date(p-dtin))),3,2) + string(month(date(p-dtin)),'99') + string(day(date(p-dtin)),'99').
return v-dt.
end function.

v-dt = datestr(string(g-today)).
s-lc = ''.
find last b-lc where b-lc.lc begins 'GTEADV' and substr(b-lc.lc,7,6) = v-dt no-lock no-error.
if avail b-lc then do:
    v-nom = int(substr(b-lc.lc,14)) + 1.
    if v-nom < 10 then
    s-lc = 'GTEADV' + v-dt + '/' + '0' + string(v-nom).
    else
    s-lc = 'GTEADV' + v-dt + '/' + string(v-nom).
end.
else s-lc = 'GTEADV' + v-dt + '/' + '01'.