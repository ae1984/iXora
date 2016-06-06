/* delnbal.p
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

{global.i}
def shared var s-remtrz like que.remtrz .
find first que where que.remtrz = s-remtrz no-lock .
find first remtrz where remtrz.remtrz = que.remtrz no-lock .

      /*    nbal cancel   */

{canbal.i}

      /*      end nbal    */
