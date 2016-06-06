/* ibcnf.p
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

/* --- CONFIRM ---
        returns "0" on yes, "1" otherwise
*/

def input parameter toask as char.

def var cnf as char no-undo init "Нет". /* label */

define frame ibconf
        "Для подтверждения своего выбора, введите слово Да" skip /* label */
        "нажатие F4 прервет операцию" skip /* label */
        toask format "x(40)" no-label view-as text skip
        cnf format "x(3)" label "Вы уверены? "
        with side-labels centered row 10
.

display toask with frame ibconf.
update cnf with frame ibconf no-error.
if error-status:error then return "1". 
if substring(cnf, 1, 1) = "Д" then return "0".
                              else return "1".

