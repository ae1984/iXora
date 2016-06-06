/* browform.i
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

sub-cod.d-cod format 'x(10)' column-label 'Справочник' 
         sub-cod.ccode  
             validate(isvalidcod(sub-cod.ccode, output errormess), errormess)
       format 'x(9)' column-label ' Код ' 
         codname format 'x(45)' column-label ' Описание ' 
         sub-cod.rdt    column-label 'Дата' 
         v-from column-label ''


