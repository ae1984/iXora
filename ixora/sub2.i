﻿/* sub.i
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
        02.11.2004 saltanat - такая же как sub.i, но с проверкой прав доступов на вверхнее меню 
        21/02/2008 madiyar - v-max = 9
        22/02/2008 madiyar - перекомпиляция
        12.01.2009 galina - добавила проверку наличия пункта верхнего меню перед вызовом процедуры
*/

/* sub.i
*/

define shared variable s-{&headkey} like {&head}.{&headkey}.
define shared variable s-title as character.
define shared variable s-newrec as logical.

define shared frame {&framename}.

define variable v-ans as logical.
define variable v-max as int initial 9.

define variable v-procro as char.

{opt-prmt.i}

find {&head} where {&where} {&head}.{&headkey} eq s-{&headkey}.

{menuvar.i new
"s-main = ""SUB"". s-opt = ""{&option}"". s-page = 1."}

if {&updatecon} then s-hideone = false.
                else s-hideone = true.
if {&deletecon} then s-hidetwo = false.
                else s-hidetwo = true.

s-page = 1.
run optmenus.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&formname}.f}

{&start}

main:
repeat:
  hide message.
  view frame {&framename}.
  {&viewframe}
  {&display}

  choose:
  repeat:
/* view frame mainhead.*/
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
        run optmenus.
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
        run optmenus.
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
     s-newrec eq true then do transaction:

    if s-newrec eq true or frame-index eq 1 and s-menu[1] ne " " then do:
      if s-newrec eq true then do :
        {&newpreupdate}
      end.
      {&preupdate}
      update {&update} with frame {&framename}.
      {&postupdate}

      if s-newrec eq true then do:
        {&newpostupdate}
      end.
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
      {&predelete}
      delete {&head}.
      {&postdelete}
      clear frame {&framename}.
      {&clearframe}
      leave main.
    end.
  end.
  else do:
    find optitem where optitem.optmenu eq s-opt and  optitem.ln eq (s-page - 1) * v-max + frame-index - 2 no-lock no-error.
    if avail optitem then do:
        if chkrights(optitem.proc) then do:
          if search(optitem.proc + ".r") <> ? then do:
            {&prerun}
            run value(optitem.proc).
            {&postrun}
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
              {&prerun}
              run value(optitem.proc).
              {&postrun}
            end.
            else do:
              {mesg.i 0210}.
            end.
          end.
        end.
       /* 02.11.2004 saltanat - заменено на обработку вверхнего меню с проверкой на право доступа.
        find optitem where optitem.optmenu eq s-opt
                      and  optitem.ln eq (s-page - 1) * v-max + frame-index - 2.
        if search(optitem.proc + ".r") <> ? then do:
          {&prerun}
          run value(optitem.proc).
          {&postrun}
        end.
        else do:
          {mesg.i 0210}.
        end. */
      end.
      end. /*avail optitem*/
end. /* main */
{&end}
