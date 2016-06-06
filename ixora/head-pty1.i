/* head-pty1.i
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

/* head-pty.i  same as head-a.i for pty use only  extent changed to 19
     08/12/91 Yoosun Kim */
def buffer kpty for {&file}.
{&var}
def var vans1 as log.
def var vsele as cha form "x(12)" extent 15
 initial ["Следующий", "Редакция", "Удалить",
          "Выход" /*, "{&other1}"*/ , "{&other2}", "{&other3}", "{&other4}",
                  "{&other5}", "{&other6}", "{&other7}", "{&other8}",
                  "{&other9}", "{&other10}" , "{&other11}", "{&other12}" /*,
                  "{&other13}", "{&other14}" */].
/*
if g-permit = 0
   then do: vsele[2] = "    ".  vsele[3] = "    ". end.
*/
/* these 2 vars required by gethelp */

form vsele with frame vsele {&vseleform}.
form {&form} with frame {&file} {&frame}.
{&start}

outer:
repeat:
  clear frame {&file}.
  prompt {&file}.{&file} with frame {&file}.

  if input {&file}.{&file} eq "" then do:
     {mesg.i 0208}.
     next.
  end.
  find {&file} where {&file}.{&file} eq input {&file}.{&file}
               {&where} no-lock no-error.
  if not available {&file} /* and g-permit > 0 */ then do:
     do transaction :
            {mesg.i 0802}.
            create {&file}.
            /* h-rec = recid({&file}).  */
            {&file}.{&file} = input {&file}.{&file}.
            {&newonly}
            {&newdft}
            {&preupdt}
            update {&fldupdt} with frame {&file}.
            {&file}.who = g-ofc.
            {&file}.whn = today.
            {&file}.tim = time.
            {&newupdt}
            {&posupdt}
            {{&pospost}}
            find current {&file} no-lock.
     end.
     {&postupdate}
  end.
  v{&file} = {&file}.{&file}.

  {&startr1}
  
  inner:
  repeat:
          view frame {&file}.
          {&predisp}
          display {&flddisp} with frame {&file}.
          /* pause 0. */
    view frame vsele.
    display vsele with frame vsele.

    choose field vsele auto-return  with frame vsele.
    hide frame vsele.
    if frame-value = "Редакция" then do:
      do transaction :
           {&no-edit}
                   find current {&file} exclusive-lock.
                   {&prepost}
                   {&preupdt}
                   update {&fldupdt} with frame {&file}.

                   {&file}.who = g-ofc.
                   {&file}.whn = today.
                   {&file}.tim = time.
                   {&posupdt}
                   {{&pospost}}
                   find current {&file} no-lock.
      end.
      {&postupdate}
    end.
    else if frame-value = "Выход"
    then leave outer.
    else if frame-value = "Удалить"
    then do transaction :
           {&no-del}
                    vans1 = no.
                    {mesg.i 0824} update vans1.
                    if vans1 then do:
                            {mesg.i 0805}.
                            find current {&file} exclusive-lock.
                            {&prepost}
                            {&preupdt}
                            {&delonly}
                            delete {&file}.
                            leave.
                         end.
                    else {mesg.i 0212}.
    end.
    else if frame-value = "Следующий" then leave.
    else if frame-value = " " then do:
                                   {mesg.i 9205}.
                                   pause 2.
                              end.

    else if frame-value = "{&other1}"
         then do:        {&no-1}
                         if search("{&prg1}" + ".r") ne ?
                         then do:
                                {&start1}
                                run {&prg1}.
                                {&end1}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.

    else if frame-value = "{&other2}"
         then do:        {&no-2}
                         if search("{&prg2}" + ".r") ne ?
                         then do:
                                {&start2}
                                run {&prg2}.
                                {&end2}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other3}"
         then do:
                 {&no-3}
                         if search("{&prg3}" + ".r") ne ?
                         then do:
                                {&start3}
                                run {&prg3}.
                                {&end3}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other4}"
         then do:
                 {&no-4}
                         if search("{&prg4}" + ".r") ne ?
                         then do:
                                {&start4}
                                run {&prg4}.
                                {&end4}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other5}"
         then do:
                 {&no-5}
                         if search("{&prg5}" + ".r") ne ?
                         then do:
                                {&start5}
                                run {&prg5}.
                                {&end5}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other6}"
         then do:
                 {&no-6}
                         if search("{&prg6}" + ".r") ne ?
                         then do:
                                {&start6}
                                run {&prg6}.
                                {&end6}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other7}"
         then do:
                 {&no-7}
                         if search("{&prg7}" + ".r") ne ?
                         then do:
                                {&start7}
                                run {&prg7}.
                                {&end7}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other8}"
         then do:
                 {&no-8}
                         if search("{&prg8}" + ".r") ne ?
                         then do:
                                {&start8}
                                run {&prg8}.
                                {&end8}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other9}"
         then do:
                 {&no-9}
                         if search("{&prg9}" + ".r") ne ?
                         then do:
                                {&start9}
                                run {&prg9}.
                                {&end9}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
    else if frame-value = "{&other10}"
         then do:
                 {&no-10}
/*                         if search("{&prg10}" + ".r") ne ? 
                         then do:*/
                                {&start10}
                                run {&prg10}.
                                {&end10}
/*                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.*/
         end.
  end.
  {&endr1}
end.
hide message.
pause 0.
{&end}
