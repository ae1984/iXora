/* p-ofc.p
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

def shared var vpoint like ppoint.point.
def var vdep1 like ppoint.depart.
def new shared var vpoint1 like ppoint.point.

vpoint1 = vpoint.

update vpoint1 label " Пункт" with side-label row 3 frame dep overlay no-hide
  centered.  update vdep1 label "Департамент"
  help " Ввод департамента, 0 - Все " with side-label row 3 frame dep
  overlay no-hide centered.

if vdep1 = 0 then do :

for each ofc where ofc.regno > vpoint1 * 1000 and
         ofc.regno < (vpoint1 + 1 ) * 1000 no-lock break by regno by ofc :
  vdep1 = ofc.regno - vpoint1 * 1000.
  display ofc.ofc label "Офицер" ofc.name label "Имя, фамилия" vdep1 
  label "Департамент"  with row 6 title "Список офицеров" 12 down frame ofc
  overlay no-hide centered.
end.
end.
else do :
for each ofc where ofc.regno = vpoint1 * 1000 + vdep1 no-lock :
  display ofc.ofc label "Офицер" ofc.name label "Имя, фамилия"
  with row 6 title "Список офицеров" 12 down frame ofc1
          overlay no-hide centered.
end.
end.

hide all.
