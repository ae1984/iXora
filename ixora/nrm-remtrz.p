/* nrm-remtrz.p
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

/*nrm-remtrz.p
 13/09/97  remout  PNP */
define shared variable srm-remtrz like shtbnk.remtrz.remtrz.
 find shtbnk.nmbr where shtbnk.nmbr.code eq "REMTRZ" exclusive-lock no-error.
 if not available nmbr then do:
    bell.
    undo,retry.
 end.
  srm-remtrz = shtbnk.nmbr.prefix + string(shtbnk.nmbr.nmbr,shtbnk.nmbr.fmt) + 
   shtbnk.nmbr.sufix.
  shtbnk.nmbr.nmbr = shtbnk.nmbr.nmbr + 1.
