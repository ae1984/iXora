/* tmpt.p
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

  for each aal where aal.aaa eq "0900185"
		   and aal.regdt eq /* g-today */ 08/16/91
		   and (aal.aax eq 66 or aal.aax eq 12):
    display aal.
    end.
