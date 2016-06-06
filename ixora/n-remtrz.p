/* n-remtrz.p
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

/*n-remtrz.p
 13/09/95  */
def shared var g-lang as char.
define shared variable s-remtrz like remtrz.remtrz.
 find nmbr where nmbr.code eq "REMTRZ" exclusive-lock no-error.
 if not available nmbr then do:
    bell.
    {mesg.i 9860}.
    undo,retry.
 end.
 s-remtrz = nmbr.prefix + string(nmbr.nmbr,nmbr.fmt) + nmbr.sufix.
 nmbr.nmbr = nmbr.nmbr + 1.
 release nmbr.


