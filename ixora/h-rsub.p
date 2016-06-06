/* h-rsub.p
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
        06.10.2003 nadejda  - поставлен размер фрейма и количество записей вместо h - 8
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* h-rsub.p */

{global.i}                                       
def temp-table gll field gllist as char format "x(6)".
def var i as int.
def var tt as cha.
def var h as int .
h = 0 .

find sysc where sysc.sysc = "PS_SUB" no-lock no-error.
tt = sysc.chval .
repeat :
 h = h + 1 .
 create gll .
 if index(tt,",") = 0 then do: gll.gllist = trim(tt) . leave . end .
  else gll.gllist = substr(tt,1,index(tt,",") - 1 ).
  tt = substr(tt,index(tt,",") + 1,length(sysc.chval)).
 if tt = "" then leave .
end.

  do:

       {browpnp.i
        &h = "8"
        &where = " true "
        &frame-phrase = "row 8 column 70
           scroll 1 8 down overlay no-label  "
        &seldisp = "gll.gllist"
        &predisp = " "
        &file = "gll"
        &disp = " gll.gllist  "
        &addupd = " gll.gllist "
        &upd    = " gll.gllist "
        &postupd = " "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " frame-value = gll.gllist . hide all . "
       }

end.

/*
        &h = "h"
        &where = " true "
        &frame-phrase = "row 8 column 70
           scroll 1 h down overlay no-label  "
*/
