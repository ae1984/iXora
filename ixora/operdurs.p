/* operdurs.p
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

define input parameter ss_aaa as char.
define input parameter dat as date.

find first debet_restr where debet_restr.aaa = ss_aaa no-lock no-error.

if avail debet_restr then                                                               /*редактирование*/
   run limdeb (false, ss_aaa, dat).              
else                                                                                    /*ввод нового ограничения*/
   run limdeb (true, ss_aaa, dat).



