/* chkbkhis.p
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

/*chkbkhis.p*/

{mainhead.i}

repeat:
prompt-for chkbk.aaa  with row 3 1 col frame xxx.
find first chkbk where chkbk.aaa = input chkbk.aaa no-error.
if not available chkbk then do:
bell.
{mesg.i 0230}.
undo,retry.
end.

for each chkbk use-index aaa where chkbk.aaa = input chkbk.aaa
	      by chkbk.odate:
find chkbkby where chkbkby.chkbkby = chkbk.chkbkby.
find chkbktp where chkbktp.chkbktp = chkbk.chkbktp.
find chkbksts where chkbksts.chkbksts = chkbk.chkbksts.

disp chkbk.odate "  " chkbkby.des chkbk.byfee chkbk.sdate
     chkbk.chkfrm chkbk.chkto skip
     chkbk.deldt chkbktp.des " "
chkbk.chkfee chkbk.qty chkbk.chkbksts chkbksts.des skip(1)
with down  centered  overlay frame lines.  end. pause.
end.
