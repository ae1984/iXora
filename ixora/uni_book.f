/* uni_book.f
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

/* uni_book.f
   Форма вывода для общих справочников comm

   24.01.2003 nadejda
*/

form 
    t-cods.choice no-label format "x"
    t-cods.code  label "КОД" format "x(10)"
    t-cods.name  label "НАИМЕНОВАНИЕ" format "x(45)"
with 11 down title v-bookname overlay centered row 6 frame uni_book.
