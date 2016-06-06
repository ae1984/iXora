/* mainlc1.i
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
        09/09/2010 galina - скопировала из mainln.i с изменениями
* BASES
        BANK
 * CHANGES
        24/11/2010 galina - добавила новый параметр presubprg
        14/12/2010 vera   - изменения в add - только после {&presubprg} генерится новый номер аккредитива и создается запись в LC
        17/01/2011 id00810 - изменения в add - изменение транзакционного блока
        21/01/2011 id00810 - v-max = 13
        04/02/2011 evseev - исправил display s-{&head} на display s-{&headkey} (119 строка)
*/


define new shared variable s-{&headkey} like {&head}.{&headkey}.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.

define new shared frame {&framename}.

define var v-max as int initial 13.

{menuvar.i new
"s-main = ""MAIN"". s-opt = ""{&option}"". s-page = 1."}

if {&findcon} then s-hideone = false.
              else s-hideone = true.

if {&addcon} then s-hidetwo = false.
             else s-hidetwo = true.

s-page = 1.
{&lang}.
run optmenus.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

{{&formname}.f}

{&start}

main:
repeat:
  hide message.
  clear frame {&framename}.
  {&clearframe}
  view frame {&framename}.
  {&viewframe}

  choose:
  repeat:
    view frame mainhead.
    display s-sign s-menu with no-box no-label frame menu.
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
      /*message "left 1....." frame-index v-max s-page view-as alert-box.*/
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

  if s-page eq 1 and (frame-index eq 1 or frame-index eq 2) then do:
    if frame-index eq 1 and s-menu[1] ne " " then do:
          {&prefind}
          {&postfind}
          pause 0.
          {&presubprg}
          run {&subprg}.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
          do transaction on error undo, retry:
            {&preadd}
            {&presubprg} do:
                run {&numprg}.
                create {&head}.
                {&head}.{&headkey} = s-{&headkey}.
                {&postadd}
                display s-{&headkey} with frame {&framename}.
                s-newrec = true.
                pause 0.
            end.
          end.
          {&presubprg}
          run {&subprg}.
     end. /* add */
    s-newrec = false.
    s-page = 1.
    s-main = "MAIN".
    s-opt = "{&option}".
    run optmenus.
  end.
  else do:
    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-max + frame-index - 2  and optitem.proc <> '' no-lock no-error.

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
