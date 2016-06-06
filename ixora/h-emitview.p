/* emitview.p
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
        06.09.04 tsoy
 * CHANGES
*/

{global.i}
{itemlist.i 
       &where = " codfr.codfr eq 'emitview'  "
       &file = "codfr"
       &frame = "width 67 row 4 centered scroll 1 12 down overlay "
       &flddisp = "' ' codfr.code format 'x(12)' LABEL 'Код' ' '
                   codfr.name[1] FORMAT 'x(30)' LABEL 'НАИМЕНОВАНИЕ' ' '
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "codfr" }
return frame-value.



