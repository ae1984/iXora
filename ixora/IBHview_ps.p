/* IBHview_ps.p
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


{global.i}
def input param tsqn like ib.doc.id .
define new shared frame ibh .

find ib.doc where ib.doc.id = tsqn no-lock no-error .
if not avail ib.doc then do :
 message "Не найден документ " + string(tsqn) .
 pause.
 return .
end .

output to tmp_ps.img .
display 
  ib.doc.id label "Док.ном." format ">>>>>>>>>9" 
  ib.doc.type label "Тип " format "9"
  ib.doc.state label "Стат." format "9" 
  ib.doc.ref label "Ссыл.ном."
    skip 
  ib.doc.remtrz label "Ном.плат" 
  ib.doc.cif label "КодК" format "x(6)"
  ib.doc.valdate label "Дата валютир."
    skip
  ib.doc.ordacc label "СчДебет"
  ib.doc.benacc label "СчКред"
    skip
  ib.doc.amt label "Сумма   "
  ib.doc.crccode label "Вал"
    skip
  ib.doc.bbplc label "БанкПол " 
  ib.doc.bbcode[2] label "BIC банка пол."
  ib.doc.bbcode[1] label "Тип " 
    skip
  ib.doc.bbname[1] label "Наим банка" 
    skip
  ib.doc.bbname[2] label "Наим банка" 
    skip
  ib.doc.bbname[3] label "Наим банка"
    skip
  ib.doc.bbname[4] label "Наим банка" 
    skip
  ib.doc.benname[1] label "Получатель "
    skip
  ib.doc.benname[2] label "Получатель "
    skip
  ib.doc.benname[3] label "Получатель "
    skip
  ib.doc.benname[4] label "Получатель "
    skip
  ib.doc.charge label "Инф.банку" 
  ib.doc.urgency label "     Приоритет"
    skip
  ib.doc.ibcode[2] label "BIC банка посред"
  ib.doc.ibcode[1] label "Тип " 
    skip
  ib.doc.ibname[1] label "Посред"
    skip
  ib.doc.ibname[2] label "Посред"
    skip
  ib.doc.ibname[3] label "Посред"
    skip
  ib.doc.ibname[4] label "Посред"
    skip
  ib.doc.beninfo[1] label "Детали "
    skip
  ib.doc.beninfo[2] label "Детали "
    skip
  ib.doc.beninfo[3] label "Детали "
    skip
  ib.doc.beninfo[4] label "Детали "
    skip
  with side-label row 3 no-box scrollable .
output close .

unix ps_less tmp_ps.img.

