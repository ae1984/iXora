/* imlccre.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        генерация номера нового аккредитива
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        05/01/2011 id00810 - с нового года нумерация начинается заново
        19/01/2011 id00810 - для всех видов аккредитивов
        29/12/2011 id00810 - добавила DC
        17/01/2012 id00810 - ошибка при переходе на новый год: не учитывался продукт
        07/02/2012 id00810 - добавила ODC
        06.03.2012 Lyubov  - "dc" изменила на "idc"
        18.10.2012 Lyubov  - ТЗ 1350 добавлен новый продукт "corr"
*/

{global.i}

def shared var s-lc like lc.lc.
def shared var s-lcprod as char.
def var v-lcid   as integer.
def var v-length as integer.
def var v-choice  as logical.
def buffer b-lc for lc.

s-lc = ''.
v-length = length(s-lcprod).
find first b-lc where b-lc.lc begins s-lcprod  and substr(b-lc.lc,v-length + 5) = substr(string(year(g-today)),3,2) no-lock no-error.
if s-lcprod = 'imlc' then do:
   if not avail b-lc then current-value(lcid) = 0.
   v-lcid = next-value(lcid).
end.
if s-lcprod = 'exlc' then do:
   if not avail b-lc then current-value(exlcid) = 0.
   v-lcid = next-value(exlcid).
end.
if s-lcprod = 'pg' then do:
   if not avail b-lc then current-value(pgid) = 0.
   v-lcid = next-value(pgid).
end.

if s-lcprod = 'expg' then do:
   /* message 'Was this EXPG advised last year?' view-as alert-box question buttons YES-NO title ' Attention!'
    update v-choice.
    if v-choice then s-lc = 'EXPG00000/10'.
    else do:*/
        if not avail b-lc then current-value(expgid) = 0.
        v-lcid = next-value(expgid).
    /*end.*/
end.

if s-lcprod = 'sblc' then do:
   if not avail b-lc then current-value(sblcid) = 0.
   v-lcid = next-value(sblcid).
end.

if s-lcprod = 'exsblc' then do:
   if not avail b-lc then current-value(exsblcid) = 0.
   v-lcid = next-value(exsblcid).
end.

if s-lcprod = 'idc' then do:
   if not avail b-lc then current-value(dcid) = 0.
   v-lcid = next-value(dcid).
end.

if s-lcprod = 'odc' then do:
   if not avail b-lc then current-value(odcid) = 0.
   v-lcid = next-value(odcid).
end.

if s-lcprod = 'corr' then do:
   if not avail b-lc then current-value(corid) = 0.
   v-lcid = next-value(corid).
end.

/*if s-lc = '' then*/
s-lc = caps(s-lcprod) + string(v-lcid,'999') + '/' + substr(string(year(g-today)),3,2).
