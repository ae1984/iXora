/* kdzalmn.i
 * MODULE
        Кредитный  Модуль
 * DESCRIPTION
        Обеспечение по досье
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6
 * AUTHOR
        03.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - вызов kdresum0.p вместо kdresum1.p
*/


{opt-prmt.i}
{pk-sysc.i}

def new shared frame kdzal.
define new shared frame menu.
define new shared var s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.
def var num as inte.

run kdnlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.

def var v-i as integer.

{kdrisk.f}

hide message no-pause.
clear frame kdrisk.

view frame kdrisk.


main:
repeat:
  hide message.
  {kdrisvew.i}

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
     prompt-for kdcif.kdcif with frame kdrisk.

     find first kdcif using kdcif.kdcif no-lock no-error.
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

     prompt-for kdlon.kdlon with frame kdrisk.
     find first kdlon using kdlon.kdlon no-lock no-error.
      if not avail kdlon then do:
        {mesg.i 0232}.
        bell. undo, retry.
      end.
      s-kdlon = kdlon.kdlon.

     {kdrisvew.i}
     if kdlon.sts = "01" then 
        run kdresum0.   /* madiar: был kdresum1 */

    end.
/*    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
        {kdzalvew.i}
         s-page = 1.
         run kdnlmenu.
    end. */
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

