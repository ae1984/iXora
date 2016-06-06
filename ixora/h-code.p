/* h-code.p
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

/*
  h-vcode.p
*/
{global.i}
{itemlist.i   &var = "def var vcode like nmbr.code."
              &file = "nmbr"
              &frame = "row 3 centered scroll 1 14 down overlay
                         title "" NUMBER  CODE """
              &where = "true"
              &flddisp = "nmbr.code nmbr.des nmbr.prefix"
              &chkey = "code"
              &chtype = "string"
              &index  = "code"
              &codeadd = "if frame-value = "" "" then
                         do:
                             {imesg.i 9205}.
                             pause 1.
                             next.
                         end."
                             }
