/* 9-st.p
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
        21.11.2005 nataly внесены изменения
*/

 

unix silent value ("echo > rpt.img").

if not connected ("comm") then run comm-con.
run 9-st2. pause 0.
run menu-prt( 'rpt.img' ). 
pause 0.
