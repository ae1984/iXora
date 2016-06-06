/* output.p
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
*/

def var pmt as char.
def var type as char.
def var dtout as date.
find last cls no-lock no-error.
dtout = if available cls then cls.cls + 1 else today.
message 'Ждите! Формируется ведомость квитовки за' dtout '...'.
pause 0.
output to output.914.
for each remtrz where 
    remtrz.jh1    ne ?     and
    remtrz.jh1    ne 0     and
    remtrz.valdt2 = dtout  and 
    remtrz.tcrc   = 1      and 
    remtrz.cover  <3       and 
    remtrz.source ne "lbi" and 
/*  remtrz.rdt    = dtout  and */
    remtrz.ptype  = "6" no-lock break by remtrz.cover.

    type = if remtrz.cover = 1 then "C" else "G".
    pmt = string(remtrz.payment,"zzzzzzzzzzzzzzz9.99-").
    pmt = replace( pmt, ".", ",").
    display type remtrz.remtrz pmt format "x(20)".

end.
output close.
unix value( 'cptwout914' ).

