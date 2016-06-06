/* h-kbud.p
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

{global.i}
{itemlist.i 
       &file = "budcodes"
       &where = " true "
       &frame = "row 2 centered scroll 1 15 down overlay "
       &flddisp = "budcodes.code column-label 'КБК' label 'КБК'
                   budcodes.name1 format 'x(60)' label 'Описание кода' column-label 'Описание кода' "
       &chkey = "code"
       &chtype = "integer"
       &index  = "code"
}
