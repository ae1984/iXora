/* r-priz12.p
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
        17.08.2006 Natalia D. - оптимизация: убрала сортировку, т.к.при отсутствии записи в loncon, программа вылетала.
*/

{mainhead.i "CLRBAL12"}
{lonlev.i}
def var v-err as log.
def var v-bal as dec.
def var vtitle-1 as char format "x(60)".
def var v-cnt as int.
def var v-max as int.
def var v-str as char.
def var v-recid as recid.
def var v-yes as log label "Все кредиты [yes] / Кредиты с остатком [no]"
initial no.

def temp-table wt
    field d-cod as char
    field rlength as int
    field clength as int
    index wt d-cod.

/*
def stream s-out .
output stream s-out to rpt.img.
*/

find sysc where sysc.sysc eq "lonacr" no-lock no-error.



{image1.i rpt.img}
update v-yes with frame a centered side-label.
{image2.i}
{report1.i 59}

if v-yes then
vtitle = "Все кредиты".
else 
vtitle = "Кредиты с остатком".
/*
"Список кредитов для которых не будут начисляться % за " 
*/
"за "
+ string(g-today).

for each sub-dic where sub-dic.sub eq "LON" no-lock :
    create wt.
    wt.d-cod = sub-dic.d-cod.
    wt.rlength = 0.
    wt.clength = 0.
end.     


for each lon no-lock /*, loncon where loncon.lon eq lon.lon*/ , each wt
/*break by lon.cif by loncon.lcnt*/
:
    find loncon where loncon.lon = lon.lon no-lock no-error.
    if not avail loncon then next. 
    v-bal = 0.
    for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
    no-lock :
    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then 
    v-bal = v-bal + (trxbal.dam - trxbal.cam).
    end.
    if v-bal eq 0 and not v-yes then next.
 
find sub-cod where sub-cod.sub eq "lon" and 
sub-cod.d-cod eq wt.d-cod and sub-cod.acc eq lon.lon no-lock no-error.
if available sub-cod then do:
/*
create wt.
wt.lon = lon.lon.
wt.d-cod = sub-cod.d-cod.
wt.ccode = sub-cod.ccode.
wt.rcode = sub-cod.rcode.
*/
if wt.clength lt length(sub-cod.ccode) then 
wt.clength = length(sub-cod.ccode).
if wt.rlength lt length(sub-cod.rcode) then
wt.rlength = length(sub-cod.rcode).

end.
end.


repeat : 
    v-cnt = 0.
    for each wt :
        if wt.rlength eq 0 then v-cnt = v-cnt + wt.clength.
        else v-cnt = v-cnt + wt.rlength.
        v-cnt = v-cnt + 1.
    end.
    if v-cnt lt 233 - 38 then leave.
    v-recid = ?.
    v-max = 0.
    for each wt :
        if wt.rlength eq 0 then do:
            if v-max lt wt.clength then do: 
                v-max = wt.clength.
                v-recid = recid(wt).
            end.
        end.
        else 
        if v-max lt wt.rlength then do:
            v-max = wt.rlength.
            v-recid = recid(wt).
        end.
    end.
    if v-max eq integer(v-max * 0.75) then v-max = v-max - 1.
    else v-max = integer(v-max * 0.75).
    find wt where recid(wt) eq v-recid.
    if v-max le 0 then do:
        if wt.rlength eq 0 then wt.clength = 0.
        else wt.rlength = 0.
    end.
    else 
    if wt.rlength eq 0 then wt.clength = v-max.
    else wt.rlength = v-max.
end.

v-str = 
/*
"1234567890123456789012345678901234567890
*/
"Кредит    Клиент      Договор     Грп."
.
/*
fill(" ",38).
*/

v-cnt = 0.
for each wt :
v-cnt = v-cnt + 1.
if wt.rlength eq 0 then v-max = wt.clength.
else v-max = wt.rlength.
v-str = v-str + trim(string(v-cnt,">>>>9")). 
v-max = v-max - length(trim(string(v-cnt,">>>>9"))).
if v-max gt 0 then v-str = v-str + fill(" ",v-max). 
v-str = v-str + " ".
end.

vtitle-1 = v-str.
{report2.i 232 
"vtitle-1 format ""x(194)"" skip fill(""="",232) format ""x(232)"" skip" aa}


for each lon no-lock /*, loncon where loncon.lon eq lon.lon*/ 
/*break by lon.cif by loncon.lcnt*/ :
   find loncon where loncon.lon = lon.lon no-lock no-error.
   if not avail loncon then next. 
    v-bal = 0.
    for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
    no-lock :
    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then 
    v-bal = v-bal + (trxbal.dam - trxbal.cam).
    end.
    if v-bal eq 0 and not v-yes then next.
put lon.lon " " lon.cif " " loncon.lcnt format "x(16)" " "
lon.grp format ">9" " " .
 
/*
     find last lonhar use-index lonln where lonhar.lon = f-var and
          lonhar.fdt < p-fdt no-lock no-error.
if available lonhar
     then do:
     w-lh.lonstat = lonhar.lonstat.
     w-lh.who = lonhar.who.
     do i = 1 to 10:
        w-lh.rez-char[i] = lonhar.rez-char[i].
        w-lh.rez-dec[i] = lonhar.rez-dec[i].
     end.
     do i = 1 to 5:
        w-lh.rez-int[i] = lonhar.rez-int[i].
        w-lh.rez-log[i] = lonhar.rez-log[i].
     end.
     w-lh.finrez = lonhar.finrez.
end.
*/


for each wt :
find sub-cod where sub-cod.sub eq "lon" and 
sub-cod.d-cod eq wt.d-cod and sub-cod.acc eq lon.lon no-lock no-error.
if wt.rlength eq 0 then v-max = wt.clength. else v-max = wt.rlength.

if available sub-cod then do:
if sub-cod.rcode eq "" then v-str = sub-cod.ccode. else v-str = sub-cod.rcode.
if length(v-str) ge v-max then v-str = substring(v-str,1,v-max).
else v-str = v-str + fill(" ",v-max - length(v-str)).
end.
else v-str = fill(" ",v-max).
v-str = v-str + " " .
put unformatted v-str.
end.
put skip.
end.

put skip(2).

v-cnt = 0.
for each wt :
v-cnt = v-cnt + 1.
put string(v-cnt,">>>>9") format "x(5)" " ".
find codific where codific.codfr eq wt.d-cod no-lock no-error.
if available codific then put unformatted codific.name.
put skip.
end.



{report3.i " " aa}
{image3.i}

/*
output stream s-out close.
*/
