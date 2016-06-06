/* chkbkprb.p
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

/*chkbkprb.p*/
{global.i}
def shared var s-chkbk like chkbk.chkbk .
def shared frame chkbk .
{chkbk.f}
view frame chkbk.

find chkbk where chkbk.chkbk = s-chkbk.
do on error undo,retry:
update chkbk.chkbksts
       with frame chkbk.
find first chkbksts where chkbksts.chkbksts = chkbk.chkbksts and
     chkbksts.prob eq true no-error.
  if not available chkbksts then do:
     bell.
     {mesg.i 9202}.
     undo,retry.
  end.

      chkbk.pbdt = g-today.
update chkbk.pbdt chkbk.probm with frame chkbk.
end.
