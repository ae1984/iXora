/* h-market.p
 * MODULE
        Сделки Forex
 * DESCRIPTION
       справочник мест сделок
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
        19.04.2004 tsoy
 * CHANGES
*/

{global.i}
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where   = "codfr.codfr = 'frxmkt'"
       &frame   = "row 5 centered scroll 1 12 down overlay "
       &form    = "codfr.code codfr.name[1] "
       &index   = "codfr"
       &chkey   = "code"
       &chtype  = "string"
       &file    = "codfr"
       &flddisp = "codfr.code codfr.name[1] label ""Name"" "
       &funadd  = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
