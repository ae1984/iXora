/* h-kb4.p
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

/* h-bank.p */


define variable qw as integer format "z".
{proghead.i}

    {itemlist.i
        &defvar = " "
        &file = "bank"
        &where = "true"
        &frame = "row 5 centered scroll 1 12 down overlay "
        &form = "bank.bank bank.name"
        &index = "bank"
        &chkey = "bank"
        &chtype = "string"
        &flddisp = "bank.bank bank.name"
        &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end."
        &set = "2"}
        frame-value = frame-value.
