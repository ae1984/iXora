/* cifnoacc.i
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Описание
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
        29/05/2008 alex
 * BASES
        BANK
 * CHANGES
*/

define variable v-sysc as char init ''.
define variable v-sysl as logical init no.
define variable q as integer.
define variable k as logical.

find first sysc where sysc.sysc = "idnoacc" no-lock no-error.
if avail(sysc) then do:
    v-sysc = sysc.chval.
    v-sysl = sysc.loval.
end.
else do:
    create sysc.
    assign sysc.sysc = "idnoacc"
           sysc.des = "Работа без акцепта"
           sysc.loval = no.
end.

k = false.
do q = 1 to num-entries(v-sysc):
    if g-ofc eq entry(q, v-sysc, ",") then k = true.
end.

function permis returns logical.    
    if v-sysl and k then return(true).
    else
    if cif.type ne "P" or (cif.type eq "P" and cif.crg eq "") then return(true).
    else return(false).
end function.