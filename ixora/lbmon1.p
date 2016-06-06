/* lbmon1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define shared temp-table lbrep
  field cdep as char format 'x(25)'
  field depnamelong as char format 'x(25)' label "Подразделение"
  field depnameshort as char format 'x(14)'.

def query q1 for lbrep.

def browse b1 
    query q1 no-lock
    display 
        lbrep.depnamelong no-label
        with 14 down title "Выберите департамент".

def frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        run lbrmz.p (lbrep.cdep) "lb".
        run lbrmz.p (lbrep.cdep) "lbg" "append".
        run menu-prt("rpt.img").
    
        open query q1 for each lbrep.
    end.  


open query q1 for each lbrep.
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.
hide frame fr1.

return.


