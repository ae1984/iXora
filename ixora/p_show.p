/* p_show.p
 * MODULE
        Название модуля
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
        25.04.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
*/
{global.i }
def input parameter s-aaa like aaa.aaa.

def stream  nur.

def var vfdt as date label "С" format "99/99/9999".
def var vtdt as date label "По" format "99/99/9999".
def var exist as log initial false.

output stream  nur to rpt.img .

update vfdt vtdt
  with side-label row 13 overlay centered frame opt.

hide all.

find first accr where accr.aaa = s-aaa and accr.fdt >= vfdt and accr.fdt <= vtdt no-lock no-error.
if not avail accr then do:
 message "По данному счету начислений в заданный период нет " s-aaa view-as alert-box.
 pause 5.
 return.
end.

def temp-table wrk
    field v-date as date format "99/99/9999"
    field v-voz like accr.accrued
    field v-ost like accr.bal
    field v-stav like accr.rate.

find first cmp no-lock no-error.

for each accr where accr.aaa = s-aaa and accr.fdt >= vfdt and accr.fdt <= vtdt no-lock:
    create wrk.
    assign
     wrk.v-date = accr.fdt
     wrk.v-voz = accr.accrued
     wrk.v-ost = accr.bal
     wrk.v-stav = accr.rate.
end.

display '   Ждите...   '  with row 5 frame ww centered .

put stream nur skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name ) format 'x(79)' at 02 skip(1).

find aaa where aaa.aaa = s-aaa no-lock no-error.
find cif where cif.cif = aaa.cif  no-lock no-error.

if not available aaa then do:
 message "Нет клиента со счетом " s-aaa VIEW-AS ALERT-BOX.
 return.
end.

put stream nur skip
" Начисленное вознаграждение" SKIP(2)
"Клиент " cif.cif " " trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(60)' skip
"Счет "  aaa.aaa skip.

put stream nur ' ' fill( '-', 817 ) format 'x(72)' skip.
put stream nur ' Дата' format "x(11)" '|' format "x" ' Начисленное вознаграждение ' format "x(28)" '|' format "x" space(5) ' Остаток ' format "x(9)" '|' format "x" space (5) ' % Ставка ' format "x(10)" skip.
put stream nur ' ' fill( '-', 817 ) format 'x(72)'.

exist = false.
for each wrk where no-lock.
    put stream nur  wrk.v-date format '99/99/9999' at 2 wrk.v-voz format '->>>>>>>>>9.99' at 12 v-ost format '->>>>>>>>>9.99' at 41 v-stav format '->>>>>>>>>9.99' at 60 skip.
    exist = true.
end.

    output stream nur close.

if not g-batch then do:
   pause 0 before-hide.
   run menu-prt( 'rpt.img' ).
   pause 0 no-message.
   pause before-hide.
 end.