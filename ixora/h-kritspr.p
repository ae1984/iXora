/* h-kritspr.p
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

/* h-kritspr.p ПотребКредит
   Список справочников анкеты

  27.01.2003 nadejda
*/


{global.i}

{itemlist.i 
         &where = " bookref.bookcod begins 'pkank' "
         &frame = " row 5 centered scroll 1 12 down overlay "
         &index = " bookcod "
         &chkey = "bookcod"
         &chtype = "string"
         &file = "bookref"
         &flddisp = " bookref.bookcod bookref.bookname "
}
