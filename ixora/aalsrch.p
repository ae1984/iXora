/* aalsrch.p
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

/* aalsrch.p
*/

{proghead.i "SEARCH TELLER TRANSACTION"}

define var vregdt like aal.regdt.
define var vaax   like aal.aax.
define var vfamt   like aal.amt label "AMOUNT FROM".
define var vtamt   like aal.amt label "AMOUNT TO".

repeat:
  update vregdt vaax vfamt vtamt
    with row 3 centered 2 col frame opt.

  for each aal where aal.regdt eq vregdt
		and  aal.aax eq vaax
		and  aal.amt ge vfamt
		and  aal.amt le vtamt
	       use-index regdt:
    display aal.aaa aal.aah format 'zzzzzzz9' aal.ln aal.amt aal.who aal.whn
      with centered.
 end.
end.
