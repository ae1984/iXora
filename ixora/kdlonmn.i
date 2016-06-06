/* kdlonmn.i
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Просмотр / редактирование досье клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3
 * AUTHOR
        01.12.2003 marinav
 * CHANGES
        20.05.03 marinav
        30/04/2004 madiyar - Просмотр досье филиалов в ГБ
                             Изменил pksysc на sysc
        30.09.2005 marinav - изменения для бизнес-кредитов
        10/05/2006 madiyar - изменения для кредитов клиентам Green House
*/


{opt-prmt.i}
{sysc.i}

def new shared frame kdlon.
define new shared frame menu.
define new shared var s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.
def var num as inte.
define var v-cod as char.

run kdnlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.

def var v-i as integer.

{kdlon.f}

on help of kdlon.manager in frame kdlon do:
  run uni_book ("kdbk", "*", output v-cod).
  kdlon.manager = entry(1, v-cod).
  displ kdlon.manager with frame kdlon.
end.

hide message no-pause.
clear frame kdlon.

view frame kdlon.


main:
repeat:
  hide message.
  {kdlonvew.i}

  choose:
  repeat:
    display s-sign s-menu with no-box no-label frame menu.
    choose field s-menu no-error with frame menu.
    if keyfunction(lastkey) eq "CURSOR-RIGHT" and frame-index eq v-kolmenu then do:
      if s-sign[2] ne ">" then do:
        bell.
      end.
      else do:
        s-page = s-page + 1.
        run kdnlmenu.
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
        run kdnlmenu.
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

    if s-newrec eq true or frame-index eq 1 and s-menu[1] ne " " then do: /* поиск */
     prompt-for kdcif.kdcif with frame kdlon.
     find first kdcif {1} using kdcif.kdcif no-lock no-error.
      if not avail kdcif then do:
          message skip " Клиент в базе не найден!" skip(1)
           view-as alert-box buttons ok title " ОШИБКА ! ".
        bell. undo, retry.
      end.

     find first kdlon where kdlon.kdcif = kdcif.kdcif no-lock no-error.
      if not avail kdlon then do:
          message skip " На этого клиента досье еще не заведено !" skip(1)
           "Выберите пункт меню 'Новый' " skip(1)
           view-as alert-box buttons ok title " ОШИБКА ! ".
        bell. undo, retry.
      end.
      s-kdcif = kdcif.kdcif.

     prompt-for kdlon.kdlon with frame kdlon.
     find first kdlon using kdlon.kdlon no-lock no-error.
      if not avail kdlon then do:
        {mesg.i 0232}.
        bell. undo, retry.
      end.
      s-kdlon = kdlon.kdlon.

     {kdlonvew.i}

    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
      find optitem where optitem.optmenu eq s-main and optitem.ln eq frame-index no-lock no-error.
      if chkrights(optitem.proc) then do:
      do transaction on error undo, retry:
        message "Создать новое досье ? " update v-ans.
        if v-ans eq false then do:
          undo, next main.
        end.
/*найти клиента*/
        prompt-for kdcif.kdcif with frame kdlon.
        find first kdcif {1} using kdcif.kdcif no-lock no-error.
         if not avail kdcif then do:
             message skip " Клиент в базе не найден!" skip(1)
             view-as alert-box buttons ok title " ОШИБКА ! ".
             bell. undo, retry.
         end.
         else if s-ourbank <> kdcif.bank then do: /* новые досье филиалов в ГБ не создаются */
                 message skip " В ГБ досье филиалов не создаются! " skip(1) view-as alert-box buttons ok title " Ошибка! ".
                 bell. undo, retry.
              end.
        s-kdcif = kdcif.kdcif.
        displ kdcif.name
              with frame kdlon.
/*создать на него досье*/
        num = next-value(kd-kod).
        s-kdlon = get-sysc-cha ("kdsym") + string(num).
        create kdlon.
        kdlon.bank = s-ourbank.
        kdlon.kdcif = s-kdcif.
        kdlon.kdlon = s-kdlon.
        kdlon.regdt = g-today.
        kdlon.who = g-ofc.
        kdlon.whn = today.
        kdlon.sts = '00'.
        update kdlon.manager with frame kdlon.
        {kdlonvew.i}
         s-page = 1.
         run kdnlmenu.
      end.
      end.
      else
          message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !"
              view-as alert-box button ok title "".
    end.
  end.
  else do:
    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-kolmenu + frame-index - 2
        no-lock no-error.
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
