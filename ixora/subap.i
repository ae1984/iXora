/* subap.i
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

/*
   subz.i
*/

define shared variable s-title as character.
define shared variable s-newrec as logical.
define variable v-ans as logical.
define variable v-max as int initial 7.
{menuvar.i new
"s-main = ""SUB"". s-opt = v-option . s-page = 1."}
if {&updatecon} then s-hideone = false.
                else s-hideone = true.
if {&deletecon} then s-hidetwo = false.
                else s-hidetwo = true.
s-page = 1.
run otmens.
form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.
{&start}
main:

repeat on error undo,leave  :
 do trans :
  find {&head} where {&where} {&head}.{&headkey} eq s-{&headkey} no-lock .

  hide message.

  view frame {&framename}.
  {&viewframe}
  {&display}
   release remtrz .
 end .
  choose:
  repeat:
    view frame /* mainhead */ {&framename}.
    display s-sign s-menu with no-box no-label frame menu.
/*    pause 0 .  */ 
    
    if s-newrec eq true then leave choose.
    choose field s-menu {&choosekey}  no-error with frame menu.
    {&poschoose}
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
     then do :
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run otmens.
      end.
     end.
    else
    if keyfunction(lastkey) eq "CURSOR-LEFT" and frame-index eq 1
    then do:
      if s-sign[1] ne "<" then do:
        bell.
      end.
      else do:
        s-page = s-page - 1.
        run otmens.
      end.
    end.
    else
    if keyfunction(lastkey) eq "RETURN" or
       keyfunction(lastkey) eq "GO" then leave choose.
    else do:
      bell.
    end.
  end. /* choose */

  if keyfunction(lastkey) eq "END-ERROR" then leave main.
    find optitem where optitem.optmenu eq s-opt
                  and  optitem.ln eq (s-page - 1) * v-max + frame-index .
    if search(optitem.proc + ".r") <> ? then 
     do :
      {&prerun}
       run value(optitem.proc).
      {&postrun}
     end.
     else do:
      {mesg.i 0210}.
     end.
end. /* main */
{&end}
