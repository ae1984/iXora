/* lsch.i
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
        22/12/11 kapar изменил уловие с "<" на "<=" в (dlopnamt <= *.stval) чтобы узбежать бесконечных циклов
*/

def var vvopnamt like lon.opnamt.
def var dlopnamt like lon.opnamt.

for each lnsch where {&where-h}:
 if lnsch.stdat < vregdt then lnsch.stdat = vregdt.
 if lnsch.stdat > vduedt then lnsch.stdat = vduedt.
end.
for each lnsci where {&where-i}:
 if lnsci.idat < vregdt then lnsci.idat = vregdt.
 if lnsci.idat > vduedt then lnsci.idat = vduedt.
end.
for each lnscg where {&where-g}:
 if lnscg.stdat < vregdt then lnscg.stdat = vregdt.
 if lnscg.stdat > vduedt then lnscg.stdat = vduedt.
end.
for each lnsch where {&where-h}:
 vvopnamt = vvopnamt + lnsch.stval.
end.
dlopnamt = vopnamt - vvopnamt.
if dlopnamt > 0
then do:
     find last lnscg where {&where-g}.
     lnscg.stval = lnscg.stval + dlopnamt.
     find last lnsch where {&where-h}.
     lnsch.stval = lnsch.stval + dlopnamt.
end.
else if dlopnamt < 0
then do:
     dlopnamt = - dlopnamt.
     find last lnscg where {&where-g}.
     repeat:
        if dlopnamt <= lnscg.stval
        then do:
             lnscg.stval = lnscg.stval - dlopnamt.
             leave.
        end.
        else if dlopnamt > lnscg.stval
        then do:
             dlopnamt = dlopnamt - lnscg.stval. lnscg.stval = 0.
             find prev lnscg where {&where-g}.
        end.
        else if dlopnamt = 0
        then leave.
     end.
     dlopnamt = vvopnamt - vopnamt.
     find last lnsch where {&where-h}.
     repeat:
        if dlopnamt <= lnsch.stval
        then do:
             lnsch.stval = lnsch.stval - dlopnamt.
             leave.
        end.
        else if dlopnamt > lnsch.stval
        then do:
             dlopnamt = dlopnamt - lnsch.stval. lnsch.stval = 0.
             find prev lnsch where {&where-h}.
        end.
        else if dlopnamt = 0
        then leave.
     end.

     for each lnsch where {&where-h} and lnsch.stval = 0:
         delete lnsch.
     end.
     for each lnscg where {&where-g} and lnscg.stval = 0:
         delete lnscg.
     end.
end.


