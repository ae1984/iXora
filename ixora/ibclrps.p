/* ibclrps.p
 * MODULE
       Internet Office
 * DESCRIPTION
       Список клиентов Internet Office по филиалу
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
       
 * CHANGES
*/

run connib.
run ibclrps1.
if connected ('ib') then disconnect 'ib'.
