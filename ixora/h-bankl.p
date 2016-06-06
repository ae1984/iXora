/* h-bankl.p
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

/* h-bankl.p */


define variable qw as integer format "z".
{proghead.i}
update "1) Request   2) All  " qw with no-box no-label row 3 frame opt.

if qw eq 1 then do:
    {itemlist.i
        &defvar = "def var qw as integer format "z"."
        &file = "bankl"
        &var = "def var vname like bankl.bank."
        &start = "{imesg.i 9823} update vname.
            vname = ""*"" + vname + ""*""".
        &where = "bankl.name matches vname"
        &frame = "row 5 centered scroll 1 12 down overlay "
        &form = "bankl.bank bankl.name"
        &index = "bank"
        &chkey = "bank"
        &chtype = "string"
        &flddisp = "bankl.bank bankl.name"
        &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end."
        &set = "1"}
        frame-value = frame-value.
   end.

else if qw eq 2 then do:
    {itemlist.i
        &defvar = " "
        &file = "bankl"
        &where = "true"
        &frame = "row 5 centered scroll 1 12 down overlay "
        &form = "bankl.bank bankl.name"
        &index = "bank"
        &chkey = "bank"
        &chtype = "string"
        &flddisp = "bankl.bank bankl.name"
        &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end."
        &set = "2"}
        frame-value = frame-value.
   end.
