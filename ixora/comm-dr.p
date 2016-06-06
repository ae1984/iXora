/* comm-dr.p
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

{comm-txb.i}
define var seltxb as int.
seltxb = comm-cod().

define input parameter s-remtrz like remtrz.remtrz.
for each tax where tax.txb = seltxb and tax.senddoc = s-remtrz use-index senddoc:
    tax.senddoc = ?.
end.

for each commonpl where commonpl.txb = seltxb and commonpl.rmzdoc = s-remtrz use-index rmzdoc:
    commonpl.rmzdoc = ?.
end.

for each kaztel where kaztel.txb = seltxb and kaztel.rmzdoc = s-remtrz use-index rmzdoc: 
    kaztel.rmzdoc = ?.
end.
