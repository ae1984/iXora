﻿/* h-codfr2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        F2 для справочников в codfr не включаем msc
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
        11/09/2008 galina
 * CHANGES
*/

/* 

*/



{global.i}

   def input parameter v-codfr as char.
   define output parameter v-cod as char.

   def temp-table t-ln
      field code like codfr.code
      field name like codfr.name[1]
    index main is primary code ASC.
    for each codfr where codfr.codfr = v-codfr and codfr.code <> "msc" no-lock.
      create t-ln.
      assign t-ln.code = codfr.code
             t-ln.name = codfr.name[1].
    end.

find first t-ln no-error.
if not avail t-ln then do:
  message skip " Справочника нет !" skip(1) view-as alert-box button ok title "".
  return.
end.
                    
{itemlist.i 
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'КОД ' format 'x(6)'
                    t-ln.name label 'ЗНАЧЕНИЕ' format 'x(50)'
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" 
}

v-cod = frame-value.
