/* proghead.i
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

/* proghead.i
   Program head
   05-21-87 created by yong k. yoon
   12-07-88 revised by Simon Y. Kim
   {1} = procedure description
*/

{global.i}
/*
def var v-mdes like g-mdes.

if g-tty ne 0 or g-proc eq "x-jls"
  then v-mdes = g-mdes.
  else v-mdes = "{1}".
*/
if g-batch eq false then
display
  g-fname g-mdes g-ofc to 71 g-today to 80
  with no-box no-label row 1 col 1 frame heading.
