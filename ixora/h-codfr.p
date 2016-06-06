/* h-codfr.p
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

/* h-codfr  F2 для справочников в codfr

               ЭКД

  24.07.03 marinav

*/



{global.i}

   def input parameter v-codfr as char.
   define output parameter v-cod as char.

   def temp-table t-ln
      field code like codfr.code
      field name like codfr.name[1]
    index main is primary code ASC.
    for each codfr where codfr.codfr = v-codfr no-lock.
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

