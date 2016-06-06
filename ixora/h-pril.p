/* h-pril.p
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
       &file = "codfr"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = "codfr.codfr = 'spril' "
       &flddisp = "codfr.code FORMAT ""x(5)"" LABEL ""КОД ""
                   codfr.name[1] FORMAT ""x(50)"" LABEL ""НАИМЕНОВАНИЕ""" 
       &chkey = "code"
       &chtype = "string"
       &index  = "codfr" }

