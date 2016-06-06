/* comm-dj.p
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

define input parameter s-jou like joudoc.docnum.

for each tax where tax.txb = seltxb and tax.taxdoc = s-jou use-index taxdoc:
    tax.taxdoc = ?.
end.

for each commonpl where commonpl.txb = seltxb and commonpl.joudoc = s-jou use-index joudoc:
    commonpl.joudoc = ?.
end.
    
for each kaztel where kaztel.txb = seltxb and kaztel.joudoc = s-jou use-index joudoc:
    kaztel.joudoc = ?.
end.
