/* LCsub.i
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
        09/09/2010 galina - скопировала из sub.i с изменениями
* BASES
        BANK
 * CHANGES
        20/04/2011 id00810 - вызов LCoptmenus вместо optmenus
        07.05.2011 Lyubov - добавила no-lock статус, чтобы запись не блокировалась
*/

/* sub.i
*/

define shared variable s-{&headkey} like {&head}.{&headkey}.
define shared variable s-title as character.
define shared variable s-newrec as logical.

define shared frame {&framename}.

define variable v-ans as logical.
define variable v-max as int initial 13.
define variable v-keybuffer as char initial ''.

find {&head} where {&where} {&head}.{&headkey} eq s-{&headkey} no-lock no-error.

{LCmenuvar.i new
"s-main = ""SUB"". s-opt = ""{&option}"". s-page = 1."}

if {&updatecon} then s-hideone = false.
                else s-hideone = true.
if {&deletecon} then s-hidetwo = false.
                else s-hidetwo = true.

s-page = 1.
run LCoptmenus.

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

    if length(keyfunction(lastkey)) = 1 then do:
      v-keybuffer = v-keybuffer + keyfunction(lastkey).
      if length(v-keybuffer) > 10 then v-keybuffer = substring(v-keybuffer,length(v-keybuffer) - 9,10).
    end.
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-max
    then do:
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run LCoptmenus.
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
        run LCoptmenus.
      end.
    end.
    else
    if keyfunction(lastkey) eq "{&mykey}"
    then do:
      {&myproc}
    end.
    {&otherkeys}
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
        if search(optitem.proc + ".r") <> ? then do:
          {&prerun}
          run value(optitem.proc).
          {&postrun}
        end.
        else do:
          {mesg.i 0210}.
        end.
    end.
  end.
end. /* main */
{&end}

