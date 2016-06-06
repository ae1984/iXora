/* mnfinmn.i
 * MODULE
        Кредитное досье Мониторинг
 * DESCRIPTION
    Форма для ведения клиента
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.11.2
 * AUTHOR
   01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


{opt-prmt.i}

def new shared frame kdmon.
define new shared frame menu.
define new shared var s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.

run kdnlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.

def var v-i as integer.

{kdmon.f}

hide message no-pause.
clear frame kdmon.

view frame kdmon.


main:
repeat:
  hide message.
  find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom and (kdcifhis.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdcifhis then do:
      find first codfr where codfr.codfr = "lnopf" and codfr.code = kdcifhis.lnopf no-lock no-error.
      if avail codfr then v-lnopf = codfr.name[1].
   
      find first codfr where codfr.codfr = "ecdivis" and codfr.code = kdcifhis.ecdivis no-lock no-error.
      if avail codfr then v-ecdivis = codfr.name[1].
    displ 
      s-kdcif kdcifhis.regdt kdcifhis.who kdcifhis.bank kdcifhis.mname
      kdcifhis.prefix kdcifhis.rnn  kdcifhis.name
      kdcifhis.fname kdcifhis.lnopf v-lnopf kdcifhis.ecdivis v-ecdivis kdcifhis.urdt 
      kdcifhis.urdt1 kdcifhis.regnom kdcifhis.addr[1]
      kdcifhis.addr[2] kdcifhis.tel kdcifhis.sotr kdcifhis.chief[1] kdcifhis.job[1]
      kdcifhis.docs[1] kdcifhis.rnn_chief[1] kdcifhis.chief[2]
      with frame kdmon.
      pause 0.
  end.
  else
    s-kdcif = "".

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

    find optitem where optitem.optmenu eq s-opt and optitem.ln eq (s-page - 1) * v-kolmenu + frame-index - 2 no-lock no-error.
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

