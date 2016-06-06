/* aaacnt.p
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

/* aaacnt.p
*/

{mainhead.i }  /*  SET UP COUNTER */

define var vcnt like aaa.cnt.

repeat:
  form aaa.aaa
       vcnt[1] space(4)
       vcnt[2] space(4)
       vcnt[3] space(4)
       vcnt[4] space(4)
       vcnt[5]
    with row 4 no-box no-label down frame aaa.
  display "ACCNT#" with frame cntlab.
  prompt-for aaa.aaa with frame aaa.
  find aaa using aaa.aaa.
  find lgr where lgr.lgr eq aaa.lgr.
  find led where led.led eq lgr.led.
  display led.cntlab[1] at 18
	  led.cntlab[2]
	  led.cntlab[3]
	  led.cntlab[4]
	  led.cntlab[5]
	  with row 3 no-box no-label no-hide frame cntlab.
  vcnt[1] = aaa.cnt[1] - aaa.mcnt[1].
  vcnt[2] = aaa.cnt[2] - aaa.mcnt[2].
  vcnt[3] = aaa.cnt[3] - aaa.mcnt[3].
  vcnt[4] = aaa.cnt[4] - aaa.mcnt[4].
  vcnt[5] = aaa.cnt[5] - aaa.mcnt[5].
  update vcnt with frame aaa.
  aaa.cnt[1] = aaa.mcnt[1] + vcnt[1].
  aaa.cnt[2] = aaa.mcnt[2] + vcnt[2].
  aaa.cnt[3] = aaa.mcnt[3] + vcnt[3].
  aaa.cnt[4] = aaa.mcnt[4] + vcnt[4].
  aaa.cnt[5] = aaa.mcnt[5] + vcnt[5].
end.
