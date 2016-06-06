/* repbonus.p
 * MODULE
       Internet Office
 * DESCRIPTION
      подключение ib
 * RUN
       Способ вызова программы, описание параметров, примеры вызова
 * CALLER
       nmenu.p
 * SCRIPT
       Список скриптов, вызывающих этот файл
 * INHERIT
       Список вызываемых процедур
 * MENU
       Перечень пунктов Меню Прагмы
 * AUTHOR
        26.010.11 Luiza
 * CHANGES
*/

run connib.
run repbonus1.
if connected ('ib') then disconnect 'ib'.
