/* head-a.i
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

/* head-a.i

   edith4.i ---> head.i
   01-26-89 by WR

   &file                                &var .. setup var
   &line                                &vseleform .. 1 col overlay row 3
   &form                                &no-del
                                        &no-edit .. if true no edit
   &frame                               &start &end
   &newdft     : New default value      &startr1 &endr1
   &fldupdt  &preupdt  &posupdt
   &flddisp  &predisp
   &no-1 .... &no-10
   &other1 ........ &other 10 ....blank allowed
   &prg1 .......... &prg10    ....
   &start1 .......  &start10    &end1 .....
*/
{&var}
def var vans as log.
def var vsele as cha form "x(12)" extent 14
 initial ["Next", "Edit", "Delete", "Quit",
          "{&other1}", "{&other2}", "{&other3}", "{&other4}",
          "{&other5}", "{&other6}", "{&other7}", "{&other8}",
          "{&other9}", "{&other10}"].


/* these 2 vars required by gethelp */
define var fv  as cha.
define var inc as int.

form vsele with frame vsele {&vseleform}.
form {&form} with frame {&file} {&frame}.
{&start}
outer:
repeat:
  clear frame {&file}.
  prompt-for {&file}.{&file} with frame {&file}
  editing: {gethelp.i} end.

  find {&file} using {&file}.{&file} no-error.
  if not available {&file}
  then do :
         {mesg.i 0802}.
         create {&file}.
         {&file}.{&file} = input {&file}.{&file}.
         {&newdft}
         {&preupdt}
         update {&fldupdt} with frame {&file}
         editing:
           {gethelp.i}
         end.

         {&file}.who = userid('bank').
         {&file}.whn = g-today.
         {&file}.tim = time.
         {&posupdt}
       end.
  s-{&file} = {&file}.{&file}.
  {&startr1}
  inner:
  repeat:
          view frame {&file}.
          {&predisp}
          display {&flddisp} with frame {&file}.
          pause 0.
    display vsele[1] with frame vsele.
    if vsele[2] ne "" then display vsele[2] with frame vsele.
    if vsele[3] ne "" then display vsele[3] with frame vsele.
    if vsele[4] ne "" then display vsele[4] with frame vsele.
    if vsele[5] ne "" then display vsele[5] with frame vsele.
    if vsele[6] ne "" then display vsele[6] with frame vsele.
    if vsele[7] ne "" then display vsele[7] with frame vsele.
    if vsele[8] ne "" then display vsele[8] with frame vsele.
    if vsele[9] ne "" then display vsele[9] with frame vsele.
    if vsele[10] ne "" then display vsele[10] with frame vsele.


    choose field vsele auto-return  with frame vsele.
    hide frame vsele.
    if frame-value = "Edit"
    then do:
           {&no-edit}
                   {&preupdt}
                   {&prepost}
                   update {&fldupdt} with frame {&file}
                   editing: {gethelp.i} end.

                   {&file}.who = userid('bank').
                   {&file}.whn = g-today.
                   {&file}.tim = time.
                   {&posupdt}
                   {&pospost}
                   {&file}.whn = g-today.
                   {&file}.who = userid('bank').
         end.
    else if frame-value = "Quit"
    then leave outer.
    else if frame-value = "Delete"
    then do:
           {&no-del}
                    vans = no.
                    {mesg.i 0824} update vans.
                    if vans
                    then do:
                            {mesg.i 0805}.
                            {&preupdt}
                            {&prepost}
                            delete {&file}.
                            leave.
                         end.
                    else do:
                            {mesg.i 0212}.
                         end.
         end.
    else if frame-value = "Next" then leave.
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
                         if search("{&prg10}" + ".r") ne ?
                         then do:
                                {&start10}
                                run {&prg10}.
                                {&end10}
                              end.
                         else do:
                                {mesg.i 0210}.
                                pause 2.
                         end.
         end.
  end.
  {&endr1}
end.
{&end}
