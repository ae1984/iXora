/* image2.i
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

/* image2.i
   image file handle part 2

   1. Include this file right after user specified selections.
   2. If user specified selections and this file are included in
      "do on error undo, retry:" loop, say no returns to user selctions and
      escape key return to the beginning of the program.
   3. If delete is true then rename current file to "filename.bak".
   4. Refer xfh001.i and xfh003.i and xas001.i, xfh008.i.

   6.15.87:
     a. This change does not affect all previous programs.
     b. If user wants override options, just pass any character other than
        blank.
   10.9.87:
     a. This change does not affect all previous programs.
     b. Just chek file existance because of change of default of
        append or overwrite question.
*/

if "{2}" = "" and g-batch eq false then do:
  {mesg.i 0928}. 
  update vans with column 30 row 22  no-label no-box frame vv.
  if not vans then undo, retry.
end.

if g-batch eq false then do:
  hide message no-pause.
  {mesg.i 0702} vimgfname.
end.

if not vappend then do:
  {file-ext.i vimgfname}
  if search(vimgfname) eq vimgfname then do:
    if opsys = "unix" then do:
      if search(vfilebody + ".bak") eq vfilebody + ".bak" then
        unix silent rm -f value(vfilebody + ".bak").
      unix silent mv value(vimgfname) value(vfilebody + ".bak").
    end.
    else if opsys = "msdos" then do:
      if search(vfilebody + ".bak") eq vfilebody + ".bak" then
        dos silent del value(vfilebody + ".bak").
      dos silent ren value(vimgfname) value(vfilebody + ".bak").
    end.
  end.
end. /* if not append */
