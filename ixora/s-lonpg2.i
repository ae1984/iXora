/* s-lonpg2.i
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

/*----------------------------------
  #3.Procentu izmai‡as
----------------------------------*/
display w-pg.dt
        w-pg.amt
        w-pg.dn
        w-pg.prc
        w-pg.iem
with frame pg.
display w-pg.who
        w-pg.whn
with frame br.
pause 0.
if w-pg.dt = ?
then update w-pg.dt
            go-on("PF1" "CURSOR-UP" "CURSOR-DOWN") with frame pg.
update w-pg.amt
       w-pg.dn
       w-pg.prc
       w-pg.iem
       go-on("PF1" "CURSOR-UP" "CURSOR-DOWN") with frame pg.
if frame pg w-pg.amt entered or
   frame pg w-pg.dn entered  or
   frame pg w-pg.prc entered or
   frame pg w-pg.iem entered
then do:
     w-pg.who = userid("bank").
     w-pg.whn = string(today,"99/99/9999").
end.
