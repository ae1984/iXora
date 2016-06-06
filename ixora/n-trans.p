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
        02/11/05 nataly  - изменен порядок присвоения nmbr
        12/07/06 nataly добавила обработку корректировки данных через s-nomer1
*/

/*n-remtrz.p
 13/09/95  */
def shared var g-lang as char.
define shared variable s-nomer1 like translat.nomer.
 find nmbr where nmbr.code eq "translat" exclusive-lock no-error.
 if not available nmbr then do:
    bell.
    {mesg.i 9860}.
    undo,retry.
 end.
 nmbr.nmbr = nmbr.nmbr + 1.
 s-nomer1 = nmbr.prefix + string(nmbr.nmbr,nmbr.fmt) + nmbr.sufix.
 
 release nmbr.


