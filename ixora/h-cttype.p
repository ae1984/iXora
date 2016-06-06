/* h-cttype.p
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

/* h-cttype.p Валютный контроль
   help на тип контракта 

   18.10.2002 nadejda создан   
*/

{global.i}
{itemlist.i 
       &file = "codfr"
       &frame = "width 52 row 4 centered scroll 1 12 down overlay "
       &where = " codfr.codfr = 'vccontr' and codfr.code <> 'msc' "
       &flddisp = "' ' codfr.code FORMAT 'x(3)' LABEL 'КОД' ' '
                   codfr.name[1] FORMAT 'x(40)' LABEL 'НАИМЕНОВАНИЕ ТИПА КОНТРАКТА' ' '
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "codfr" }



