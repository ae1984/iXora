/* h-secur.p
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
        17.05.2004 расширил поле Вид ЦБ на 2 знака 
*/

/* h-secur.p Ценные бумаги и МБД
   help на справочник ЦБ

   18.12.2002 nataly создан
*/

{global.i}
{itemlist.i 
       &where = " codfr.codfr eq 'secur'  "
       &file = "codfr"
       &frame = "width 67 row 4 centered scroll 1 12 down overlay "
       &flddisp = "' ' codfr.code format 'x(12)' LABEL 'Код' ' '
                   codfr.name[1] FORMAT 'x(30)' LABEL 'НАИМЕНОВАНИЕ' ' '
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "codfr" }
return frame-value.


