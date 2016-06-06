/* h-mname.p
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

/* h-mname.p
   Справочник категорий клиентов
   вызывается по F2 из редактирования данных клиента

   25.06.2003 nadejda
*/
{global.i}
{itemlist.i 
       &file = "bookcod"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = "bookcod.bookcod = 'clnkateg'"
       &flddisp = "bookcod.code FORMAT 'x(5)' LABEL 'КОД ' help ' Код категории клиента'
                   bookcod.name FORMAT 'x(50)' LABEL 'КАТЕГОРИЯ КЛИЕНТОВ'" 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" }

