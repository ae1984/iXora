/* h-krittype.p
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

/* h-procval.p ПотребКредит
   Список типов параметров в анкете

  29.01.2003 nadejda
*/


{global.i}

{itemlist.i 
         &where = " bookcod.bookcod = 'pkkrtype' "
         &frame = " row 5 centered scroll 1 12 down overlay "
         &index = " sort "
         &chkey = "code"
         &chtype = "string"
         &file = "bookcod"
         &flddisp = " bookcod.code format 'x(10)' bookcod.name "
}

