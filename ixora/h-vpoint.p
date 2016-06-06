/* h-vpoint.p
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

/* help for points  */
{global.i}
  {itemlist.i
         &where = "true"
         &file = "point"
         &frame = "row 5 centered scroll 1 12 down overlay "
         &flddisp = "point.point point.name point.addr[1]"
         &chkey = "point"
         &chtype = "integer"
         &index  = "point"      /*       &file */
         &funadd = "if frame-value = "" "" then do:
                      {imesg.i 9205}.
                      pause 1.
                      next.
                    end."
         &set = "b"}
