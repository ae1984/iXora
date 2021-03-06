﻿/* sisn.i
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
        21/02/2008 madiyar - максимальное число пунктов верхнего меню v-max = 15
        12.01.2009 galina - добавила проверку наличия пункта верхнего меню перед вызовом процедуры
*/

/* sisn.i
*/

define shared variable s-{&headkey} like {&head}.{&headkey}.
define shared variable s-newrec as logical.
define shared frame {&pre}{&head}{&post}.

define variable v-ans as logical.
define variable v-procro as char.

define var v-max as int initial 15.

{opt-prmt.i}

find {&head} where {&head}.{&headkey} eq s-{&headkey}.

{nlvar.i new
"s-main = ""SUB"". s-opt = ""{&option}"". s-page = 1."}

if "{&noedt}" eq "true" then s-noedt = true.
if "{&nodel}" eq "true" then s-nodel = true.

{&variable}

s-page = 1.
run nlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&pre}{&head}{&post}.f}
{&frame}

{&start}

main:
repeat:
  hide message.
  {&predisplay}
  {&display}
  {&postdisplay}
  view frame {&pre}{&head}{&post}.
  {&viewframe}

  choose:
  repeat:
    display s-sign s-menu with no-box no-label frame menu.
    if s-newrec eq true then leave choose.
    choose field s-menu no-error with frame menu.
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
    then do:
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run nlmenu.
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
        run nlmenu.
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

  if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) or
     s-newrec eq true then do:

    if s-newrec eq true or frame-index eq 1 and s-menu[1] ne " " then do:
      {&no-update}
      {&preupdate}
      {&update}
      {&postupdate}    
      s-newrec = false.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
      bell.
      {mesg.i 0824} update v-ans.
      if v-ans eq false then do:
        bell.
        undo, next main.
      end.
      {&no-delete}
      {&predelete}
      {&delete}
      {&postdelete}   
      clear frame {&pre}{&head}{&post}.
      {&clearframe}
      leave main.
    end.
  end.
  else do:
    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-max + frame-index - 2 no-lock no-error.
    if avail optitem then do:
        if chkrights(optitem.proc) then do:
          if search(optitem.proc + ".r") <> ? then do:
            run value(optitem.proc).
            pause 0.
          end.
          else do:
            {mesg.i 0210}.
          end.
        end.
        else do:
          v-procro = trim(chkproc-ro(s-opt, optitem.proc)).
    
          if v-procro = "" or v-procro = "?" then do:
            bell.
            message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !" 
                view-as alert-box button ok title "".
          end.
          else do: /* процедура только для чтения */
            if search(v-procro + ".r") <> ? then do:
              run value(v-procro).
              pause 0.
            end.
            else do:
              {mesg.i 0210}.
            end.
          end.
        end.
    end.  
  end.
end. /* main */
{&end}



