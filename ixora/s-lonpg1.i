/* s-lonpg1.i
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

/*-------------------------------
  #3.Pamatsummu izmai‡as
-------------------------------*/
display w-pg.nr
        w-pg.dt
        w-pg.duedt
        w-pg.atl
        w-pg.iem
with frame pg.
display w-pg.rdt
        w-pg.duedt
        w-pg.opnamt
        w-pg.prem
        w-pg.who
        w-pg.whn
with frame br.
pause 0.
update w-pg.nr
       w-pg.iem
       go-on("PF1" "CURSOR-UP" "CURSOR-DOWN") with frame pg.
if length(w-pg.nr) = 1
then  w-pg.nr = " " + w-pg.nr.
