/* h-pklass.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Выбор классификации в реестре (дебиторы)
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
        05/01/2004 sasco
 * CHANGES

*/



{global.i}
{itemlist.i 
       &file = "codfr"
       &frame = "  row 5 centered scroll 1 10 down overlay title 'КЛАССИФИКАЦИЯ В РЕЕСТРЕ' "
       &where = " codfr.codfr = 'pklass' and codfr.code <> 'msc' "
       &flddisp = "codfr.code FORMAT 'x(3)' LABEL 'КОД' 
                   codfr.name[1] FORMAT 'x(35)' LABEL 'НАИМЕНОВАНИЕ'
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" }
