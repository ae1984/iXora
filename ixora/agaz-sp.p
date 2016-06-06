/* agaz-sp.p
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

define temp-table tagaz like as-gazsp.

DEFINE QUERY q1 FOR as-gazsp.
DEFINE QUERY q2 FOR tagaz.

for each as-gazsp no-lock break by as-gazsp.name :
    if first-of(as-gazsp.name) then do:
        create tagaz.
        buffer-copy as-gazsp to tagaz.
    end.    
end.

def browse b1 
     query q1 no-lock
     displ as-gazsp.disc format 'x(15)' 
     with no-label 14 down title " Выберите ГРУ/КСК ".

def browse b2 
     query q2 no-lock
     display tagaz.name format 'x(10)'
     with no-label 2 down title "Выберите тип".

def frame fr1 
     b1 with centered overlay view-as dialog-box.
on return of b1 in frame fr1 do:
     apply "endkey" to frame fr1. 
end.  


def frame fr2 
     b2 with centered overlay view-as dialog-box.
on return of b2 in frame fr2 do:
     apply "endkey" to frame fr2. 
end.  


open query q2 for each tagaz.

if num-results("q2")=0 then
do:
     MESSAGE "2:Записи не найдены." 
     VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найден такой тип".
     return.                 
end.

b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr2.
apply "value-changed" to b2 in frame fr2.
WAIT-FOR endkey of frame fr2.

hide frame fr2.

open query q1 for each as-gazsp where as-gazsp.name = tagaz.name use-index disc.

if num-results("q1")=0 then
do:
     MESSAGE "1:Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найден КСК/ГРУ".
     return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.


return as-gazsp.disc
.

