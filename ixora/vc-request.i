/* vc-request.i
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
        20.01.2011 aigul - а основе vc-alldoc.i
 * CHANGES

*/

def new shared var s-{&headkey} like {&head}.{&headkey}.
def new shared variable s-newrec as logical.
def new shared frame {&frame}.
def buffer bufhead for {&head}.

g-fname = caps("{&option}").

{opt-prmt.i}

{&var}
def var vans1 as logi.
def var vsele as cha form "x(12)" extent 9
initial ["Поиск", "Новый", "Редактиров", "Удалить", "История", "Печать","", "", "Выход"].

form vsele with col 67 row 4 1 col no-label overlay frame vsele.
{{&frame}.f}
{&start}

s-{&headkey} = 0.

outer:
repeat:
  hide message no-pause.

  if s-{&headkey} = 0 then do:
    clear frame {&frame}.
    {&clearframe}
    view frame {&frame}.
    {&viewframe}
  end.
  else do:
    find {&head} where {&head}.{&headkey} = s-{&headkey} no-lock no-error.
    {&predisplay}
    display {&display} with frame {&frame}.
    {&postdisplay}
  end.

  inner:
  repeat:
    display vsele[1] vsele[2] vsele[3] vsele[4] vsele[5] vsele[6] vsele[7]
      vsele[8] vsele[9] with frame vsele.
    choose field vsele auto-return with frame vsele.

    if keyfunction(lastkey) eq "RETURN" or
       keyfunction(lastkey) eq "GO" then leave inner.
  end.

/*     message keyfunction(lastkey). pause 5.*/

  if keyfunction(lastkey) eq "END-ERROR" then leave outer.


  if frame-index eq 1 then do:
    {&no-find}
    clear frame {&frame}.
    {&clearframe}
    {&prefind}

    run h-request.
    find {&head} where {&head}.{&headkey} = s-{&headkey} no-lock no-error.

    {&postfind}
    s-newrec = false.
    pause 0.
  end.

  else
  if frame-index eq 2 then do:
    {&no-add}
    do transaction on error undo, retry:
      s-newrec = true.
      s-{&headkey} = 0.
      clear frame {&frame}.
      {&clearframe}
      {&precreate}
      create {&head}.
      {&head}.{&headkey} = next-value(vc-{&headkey}).
      s-{&headkey} = {&head}.{&headkey}.
      {&postcreate}
      {&head}.rwho = g-ofc.
      {&head}.rdt = g-today.
      {&predisplay}
      {&postdisplay}
      display {&display} with frame {&frame}.
      {&postdisplay}
      {&no-update}
      {&preupdate}
      {&update}
      {&postupdate}
    end.
    s-newrec = false.
    pause 0.
  end. /* add */

  else
  if frame-index = 3 /*"Редактир"*/ and s-{&headkey} <> 0 then do :
    {&no-update}
    find current {&head} no-lock.
    if {&head}.cdt = ? and {&head}.cwho = "" then do:
      do transaction on error undo, retry:
        find current {&head} exclusive-lock.
        {&preupdate}
        {&update}
        find current {&head} no-lock.
        {&postupdate}
      end.
    end.
    else do:
      bell.
      message "  Нельзя редактировать акцептованный документ !"
          view-as alert-box button ok title "".
    end.
  end.

  else
  if frame-index = 4 /*"Удалить"*/ and s-{&headkey} <> 0 then do :
    {&no-del}
    find current {&head} no-lock.
    if {&head}.cdt = ? and {&head}.cwho = "" then do transaction :
      vans1 = no.
      {mesg.i 0824} update vans1.
      if not vans1 then do:
        bell.
        undo, next outer.
      end.
      {mesg.i 0805}.
      {&predelete}
      find current {&head} exclusive-lock.
      {&delete}
      {&postdelete}
      s-{&headkey} = 0.
      pause 0.
    end.
    else do:
      bell.
      message "  Нельзя удалить акцептованный документ !"
          view-as alert-box button ok title "".
    end.
  end.
  else
  if frame-index = 5 /*"История"*/ and s-{&headkey} <> 0 then do:
    run vcrequesthis.
    pause 0.
  end.
  else
  if frame-index = 6 /*"Печать"*/ and s-{&headkey} <> 0 then do :
    run vcrequestprint.
    pause 0.
  end.
  else
  if frame-value = "Выход" then leave outer.

  else
  if frame-value = " " then do:
  /* {mesg.i 9205}.
     pause 2.*/
  end.

/*  else
  if frame-index = 10 / *"Печать ист."* /  and s-{&headkey} <> 0 then do:
    run {&head}hisp.
    pause 0.
  end.*/
  {&endr1}
end.

hide message.
pause 0.
{&end}




