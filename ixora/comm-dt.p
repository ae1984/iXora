/* comm-dt.p
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
def var seltxb as int.
seltxb = comm-cod().

define input parameter s-jh as char.
for each tax where tax.txb = seltxb and tax.comdoc = s-jh use-index comdoc:
    tax.comdoc = ?.
end.

for each commonpl where commonpl.txb = seltxb and commonpl.prcdoc = s-jh use-index prcdoc:
    commonpl.prcdoc = ?.
end.

for each commonpl where commonpl.txb = seltxb and commonpl.comdoc = s-jh use-index comdoc:
    commonpl.comdoc = ?.
end.

for each kaztel where kaztel.txb = seltxb and kaztel.com1doc = s-jh use-index com1doc:
    kaztel.com1doc = ?.
end.

for each kaztel where kaztel.txb = seltxb and kaztel.comdoc = s-jh use-index comdoc:
    kaztel.comdoc = ?.
end.
    
