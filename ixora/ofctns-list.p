/* ofctns-list.p
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

/* ofctns-list.p
   список офицеров с табельными номерами и отделами из ЗАРПЛАТЫ 
   
   07.2002 nadejda создан
*/

def shared temp-table t-tn
  field tn as char
  field name as char
  field depname as char
  field dep as char 
  field fired as logical
  index itn tn.

for each t-tn. delete t-tn. end.

for each alga.tn by alga.tn.tn:
  create t-tn.
  t-tn.tn = alga.tn.tn.
  t-tn.name = alga.tn.uzv.
  t-tn.dep = alga.tn.pd.
  t-tn.fired = no.
  find alga.pd where alga.pd.pd = alga.tn.pd no-lock no-error.
  if available alga.pd then 
    t-tn.depname = alga.pd.pdnos.
end.

for each alga.tnd by alga.tnd.tn:
  find t-tn where t-tn.tn = alga.tnd.tn no-lock no-error.
  if not avail t-tn then do:
    create t-tn.
    t-tn.tn = alga.tnd.tn.
    t-tn.name = alga.tnd.uzv.
    t-tn.dep = alga.tnd.pd.
    t-tn.fired = yes.
    find alga.pd where alga.pd.pd = alga.tnd.pd no-lock no-error.
    if available alga.pd then
      t-tn.depname = alga.pd.pdnos.
  end.
end.

