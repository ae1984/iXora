/* s-lonpg3.i
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

/*----------------------
  #3.PiezЁmes
----------------------*/
display w-pg.dt
        w-pg.iem
        w-pg.who
        w-pg.whn
with frame pg.
pause 0.
update w-pg.iem
       go-on("PF1" "CURSOR-UP" "CURSOR-DOWN") with frame pg.
if frame pg w-pg.iem entered
then do:
     w-pg.who = userid("bank").
     w-pg.whn = string(today,"99/99/9999").
     display w-pg.who
             w-pg.whn
     with frame pg.
end.
