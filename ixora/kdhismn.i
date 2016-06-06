/* kdlonmn.i
       Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
    Форма для ведения клиента
     Просмотр / редактирование досье клиента
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
   20.07.2003 marinav
 * CHANGES
   08.01.04 marinav - убрана возможность поиска клиента
    05/09/06   marinav - добавление индексов
*/


{opt-prmt.i}
{pk-sysc.i}

def new shared frame kdlon.
define new shared frame menu.
define new shared var s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.
def var num as inte.

run kdnlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.

def var v-i as integer.

{kdlon.f}

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
end. /* main */

