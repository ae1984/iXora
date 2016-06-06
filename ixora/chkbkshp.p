/* chkbkshp.p
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

/*chkbkshp.p*/
def shared var s-aaa like chkbk.aaa .
def shared frame chkbk.
{chkbk.f}
view frame chkbk.
find chkbk where chkbk.aaa = s-aaa.
do on error undo,retry:
update chkbk.sdate validate(chkbk.sdate ge chkbk.odate , "")
       with frame chkbk.
find first chkbksts where chkbksts.done = true and chkbksts.prob eq false
   no-error.
   if available chkbksts then chkbk.chkbksts = chkbksts.chkbksts.
   find chkbkord where chkbkord.chkbkord = chkbk.chkbkord.
   chkbkord.sdate = chkbk.sdate.
   chkbkord.sts = chkbk.chkbksts.
end.
disp chkbk.chkbksts with frame chkbk.
