/* r-glamt.p
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
        07/09/06 marinav - убраны whole-index 
*/



{mainhead.i}

define variable ledger like glday.gl.
define variable asdate as date.
define variable amount like glday.bal initial 0.
{r-glamt.f}

{image1.i rpt.img}

update ledger asdate with frame glamt.

{image2.i}
{report1.i 125}

find gl where gl.gl eq ledger no-lock no-error.
if not avail gl then return.

vtitle = arrput[1] + string(ledger) + gl.des + arrput[2] + string(asdate) + chr(13) + chr(10) + arrput[3].

for each crc where crc.sts <> 9:

    find last glday where glday.gl eq ledger and glday.crc eq crc.crc  and glday.gdt le asdate no-lock no-error.

    {report2.i 125 "vtitle"}

    find last crchis where crchis.crc eq glday.crc and crchis.rdt le asdate
        no-lock no-error.

    amount = amount + glday.bal * crchis.rate[1] / crchis.rate[9].

    display  crchis.code bal bal * crchis.rate[1] / crchis.rate[9]  format "z,zzz,zzz,zzz,z99.99-" with no-labels.
end.

display skip(2) arrput[4] space(20) amount with no-labels.

{report3.i}
{image3.i}
