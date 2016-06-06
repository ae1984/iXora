/* vc-dolgs.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма и меню для редактирования документов
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
        24/06/04 saltanat
 * BASES
        BANK COMM
 * CHANGES
        28.12.2010 aigul - Добавила Удаление и убрала Акцепт всех доков
        27.01.2011 aigul -  разрешить акцепт непогашенных док-в
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/

def new shared var s-{&headkey} like {&head}.{&headkey}.
def new shared variable s-newrec as logical.
def new shared frame {&frame}.
def buffer bufhead for {&head}.

g-fname = caps("{&option}").

{opt-prmt.i}

{&var}
def var vans1 as logi.
def var v-termlist as char.
def var v-{&headkey} like {&head}.{&headkey}.
def var vsele as cha form "x(12)" extent 12
initial ["Поиск","Новый","Редактиров",/*"Погасить",*/"Удалить","Акцепт",/*"Акцепт.все",*/"История",/*"Документ", "Комиссия",*/"","","","Просмотр документа","Сканировать","Выход"].

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
    display vsele[1] vsele[2] vsele[3] vsele[4] vsele[5] vsele[6] vsele[7] vsele[8] vsele[9] vsele[10] vsele[11] vsele[12] with frame vsele.
    choose field vsele auto-return with frame vsele.

    if keyfunction(lastkey) eq "RETURN" or keyfunction(lastkey) eq "GO" then leave inner.
  end.

  if keyfunction(lastkey) eq "END-ERROR" then leave outer.

  if frame-index eq 1 then do:
    {&no-find}
    clear frame {&frame}.
    {&clearframe}
    {&prefind}

    run h-{&headkey}.
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
      display {&display} with frame {&frame}.
      {&postdisplay}
      {&no-update}
      {&preupdate}
      {&update}
      {&postupdate}
    end.
    s-newrec = false.
    pause 0.

    {&postaddhis}
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
  /*"Погасить"*/
  /*else if frame-index = 4  and s-{&headkey} <> 0 then do :
    {&no-pog}
    find current {&head} no-lock.
    if {&head}.cdt = ? and {&head}.cwho = "" then do transaction :
      vans1 = no.
      {mesg.i 0970} update vans1.
      if not vans1 then do:
        bell.
        undo, next outer.
      end.
      {mesg.i 0805}.
      {&prepog}
      find current {&head} exclusive-lock.
      {&pog}
      {&postpog}
      pause 0.
    end.
    else do:
      bell.
      message "  Нельзя погашать акцептованный документ !"
          view-as alert-box button ok title "".
    end.
  end.
  */
  /*"Удалить"*/
  else if frame-index = 4 and s-{&headkey} <> 0 then do :
    {&no-del}
    find current {&head} no-lock.
    /*if {&head}.cdt <> ? and {&head}.cwho <> "" then do transaction :*/
      vans1 = no.
      {mesg.i 0824} update vans1.
      if not vans1 then do:
        bell.
        undo, next outer.
      end.
      {mesg.i 0805}.
      {&predelete}
      find current {&head} exclusive-lock.

      run vc-oper("3",trim(string(s-{&headkey})),"{&head}").

      {&delete}
      {&postdelete}
      s-{&headkey} = 0.
      pause 0.

      {&postdelhis}
    /*end.
    else do:
      bell.
      message "  Нельзя удалить не акцептованный документ !"
          view-as alert-box button ok title "".
    end.*/
  end.

  else
  if frame-index = 5 /*"Акцепт"*/ and s-{&headkey} <> 0 then do:
    {&no-update}
    if chkrights("{&option}" + "ac") then do: /* можно! */
      /*find current {&head} no-lock.
      if {&head}.pdt <> ? and {&head}.pwho <> "" then do transaction :*/
        if {&head}.cdt = ? then do:
            vans1 = no.
            message " Утвердить данные ? " view-as alert-box button yes-no title "" update vans1.
            if vans1 then do transaction on error undo, retry:
                find current {&head} exclusive-lock.
                update {&head}.cdt = g-today
                {&head}.cwho = g-ofc.
                /* if not {&head}.origin then {&head}.origin = yes.    */
                find current {&head} no-lock.
            end.
        end.
        else do:
            vans1 = no.
            message " Снять отметку об утверждении данных ? " view-as alert-box button yes-no
            title "" update vans1.
            if vans1 then do transaction on error undo, retry:
                find current {&head} exclusive-lock.
                update {&head}.cdt = ?
                {&head}.cwho = ''.
                find current {&head} no-lock.
            end.
        end.
        displ {&head}.cwho {&head}.cdt with frame {&frame}.
      /*end.
      else do:
           bell.
           message "  Нельзя акцептовать непогашенный документ !"
              view-as alert-box button ok title "".
      end.*/
    end.
    else do:
      bell.
      message "   У вас нет прав для выполнения процедуры 'Акцепт' !"
          view-as alert-box button ok title "".
    end.
  end.
  /* Акцепт.все */
  /*else
  if frame-index = 6  then do:
    {&no-update}
    if chkrights("{&option}" + "al") then do:
      message skip
         "Будет произведено акцептование всех документов данного типа !" skip(1)
         "Вы уверены ?" skip(1)
         view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice as logical.
      if v-choice then do transaction on error undo, retry:
        v-{&headkey} = s-{&headkey}.
        for each bufhead where bufhead.contract = s-contract and
             lookup(bufhead.dntype, s-vcdoctypes) > 0 and bufhead.cdt = ? no-lock:
          find {&head} where {&head}.{&headkey} = bufhead.{&headkey} exclusive-lock.
          update {&head}.cdt = g-today
                 {&head}.cwho = g-ofc.
          find current {&head} no-lock.
        end.
      end.
      s-{&headkey} = v-{&headkey}.
      if s-{&headkey} <> 0 then do:
        find {&head} where {&head}.{&headkey} = s-{&headkey} no-lock no-error.
        displ {&head}.cwho {&head}.cdt with frame {&frame}.
      end.
    end.
    else do:
      bell.
      message "   У вас нет прав для выполнения процедуры 'Акцепт.все' !"
          view-as alert-box button ok title "".
    end.
  end.*/
  else if frame-index = 6 /*"История"*/ and s-{&headkey} <> 0 then do:
    run {&head}his.
    pause 0.
  end.
  else if frame-index = 10 and s-{&headkey} <> 0 then do: /*Просмотр документа*/
    run vc-oper("1",trim(string(s-{&headkey})),"{&head}").
  end.
  else if frame-index = 11 and s-{&headkey} <> 0 then do: /*Сканировать*/
    run vc-oper("2",trim(string(s-{&headkey})),"{&head}").
  end.
  else if frame-index = 12 then leave outer.
  else if frame-value = " " then do:
    /*{mesg.i 9205}.
    pause 2.*/
  end.
  /*else if frame-index = 10 / *"Печать ист."* /  and s-{&headkey} <> 0 then do:
    run {&head}hisp.
    pause 0.
  end.*/

  {&endr1}
end.

hide message.
pause 0.
{&end}
