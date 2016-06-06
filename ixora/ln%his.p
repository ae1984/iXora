/* ln%his.p
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

def var flag as inte initial 1.
def shared var s-lon like lnsch.lnn.
def var trecc as recid.
def var clinn as inte.
start: repeat:
  if flag = 1 then do:
   run ln%his1(output flag, input-output clinn, input-output trecc).
     next start.
  end.
  if flag = 2 then do:
   run ln%his2(output flag, input-output clinn, input-output trecc).
     next start.
  end.
  leave start.
end.

