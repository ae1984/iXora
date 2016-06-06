/* h-pid.p
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

/* h-pid.p */
{global.i}
define var vselect as cha format "x".

  do:
       {itemlist.i
        &var = "def var vnum like fproc.pid."
        &where = "true"
        &frame = "row 2 centered scroll 1 15 down overlay top-only"
        &index = "pid"
        &predisp =" "
        &chkey = "pid"
        &chtype = "string"
        &file = "fproc"
        &flddisp = "fproc.pid column-label 'Код' fproc.des 
         column-label 'Описание'"
        &funadd = "if frame-value = "" ""
                     then do:
                          bell.
                          {imesg.i 9206}.
                          pause 1.
                          next.
                   end."
        &set = "d"
       }
end.
