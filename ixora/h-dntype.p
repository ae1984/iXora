/* h-dntype.p
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

/* h-docs.p Валютный контроль
   help на тип документа

   18.10.2002 nadejda создан
*/

def shared var s-contract like vccontrs.contract.
def shared var s-dnvid as char.

{global.i}

{itemlist.i  
       &file = "codfr"
       &frame = " width 44 row 4 centered scroll 1 12 down overlay "
       &where = " codfr.codfr = 'vcdoc' and index(s-dnvid, codfr.name[5]) > 0 "
       &flddisp = "' ' codfr.code label 'КОД' 
                   codfr.name[1] label 'НАИМЕНОВАНИЕ' format 'x(30)'" 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" }


