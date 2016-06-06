/* kdmonmn.i 
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Форма для ведения клиента
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
run kdnlmenu.
run kdmonnew .
        
 * MENU
        1.11
 * AUTHOR
       25.02.05 marinav
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
def var v-nom as integer.
def var v-dat1 as date.
def var v-dat2 as date.

define buffer b-cif for cif.
define buffer b-kdcifhis for kdcifhis.
define buffer b-kdaffilh for kdaffilh.


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
  find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom no-lock no-error.
  if avail kdcifhis then do:
      if s-ourbank <> "TXB00" and (kdcifhis.bank <> s-ourbank) then do:
        message "Клиент другого филиала!".
        return.
      end.
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
  else do:
    s-kdcif = "".
  end.

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

     update s-kdcif with frame kdmon.
     find last kdcifhis where kdcifhis.bank = s-ourbank and kdcifhis.kdcif = s-kdcif no-lock no-error.
     if not avail kdcifhis then do:

        find last kdcif where kdcif.kdcif = s-kdcif no-lock no-error.
        if not avail kdcif then do:
            message skip " Клиент в базе не найден!" skip(1)
           view-as alert-box buttons ok title " ОШИБКА ! ".
          bell. undo, retry.
        end.
        find last kdaffilh where kdaffilh.kdcif = s-kdcif and kdaffilh.code = '18' no-lock no-error.
        if not avail kdaffilh then do:
            message skip " Мониторинги по этому клиенту не проводились !~n Выберите пункт 'Новый' для создания нового мониторинга." skip(1)
           view-as alert-box buttons ok title " ОШИБКА ! ".
          bell. undo, retry.
        end.
         
        /*перенести клиента из kdcif в kdcifhis и kdaffilh 
        create kdcifhis.
        buffer-copy kdcif to kdcifhis.
        kdcifhis.nom = 1. kdcifhis.regdt = g-today. kdcifhis.who = g-ofc. 
        for each kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = '' no-lock.
            create kdaffilh.
            buffer-copy kdaffil to kdaffilh.
        end.
        for each kdaffilh. kdaffilh.nom = 1. end.
         */
  
     end.
      
     {itemlist.i 
       &file = "kdaffilh"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' МОНИТОРИНГ ' "
       &where = " kdaffilh.kdcif = s-kdcif and kdaffilh.code = '18' "
       &flddisp = "kdaffilh.nom 
                   kdaffilh.kdcif FORMAT 'x(9)' 
                   kdaffilh.datres[1] 
                   kdaffilh.datres[2] " 
       &chkey = "nom "
       &chtype = "integer"
       &index  = "cifnom" }

     s-nom = kdaffilh.nom . 
     pause 0.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
      find optitem where optitem.optmenu eq s-main and optitem.ln eq frame-index no-lock no-error. 
      if avail optitem and chkrights(optitem.proc) then do:
        message "Создать новый мониторинговый отчет клиента ? " update v-ans.
        if v-ans eq false then do:
          undo, next main.
        end.
        do transaction on error undo, retry:
          update s-kdcif with frame kdmon.
          find last kdcifhis where kdcifhis.bank = s-ourbank and kdcifhis.kdcif = s-kdcif no-lock no-error.
          if not avail kdcifhis then do:
             find first kdcif where kdcif.kdcif = s-kdcif no-lock no-error.
             if not avail kdcif then do:
                 message skip " Клиент в базе не найден!" skip(1)
                view-as alert-box buttons ok title " ОШИБКА ! ".
               bell. undo, retry.
             end.
             else do: 
                /*перенести клиента из kdcif в kdcifhis*/ 
                s-nom = 1.
                create kdcifhis.
                buffer-copy kdcif to kdcifhis.
                kdcifhis.nom = 1. kdcifhis.who = g-ofc. kdcifhis.regdt = g-today.
                for each kdaffil where kdaffil.kdcif = s-kdcif and lookup(code , '01,02,11') > 0 no-lock.
                    create kdaffilh.
                    buffer-copy kdaffil to kdaffilh.
                end.
                for each kdaffilh where kdaffilh.kdcif = s-kdcif. kdaffilh.nom = 1. kdaffilh.who = g-ofc. kdaffilh.whn = g-today. end.
             end.
          
          end.
          else do:
              find last b-kdcifhis where b-kdcifhis.bank = s-ourbank and b-kdcifhis.kdcif = s-kdcif no-lock no-error. 
              s-nom = b-kdcifhis.nom + 1.
              create kdcifhis.
              kdcifhis.nom = s-nom .          
              buffer-copy b-kdcifhis except b-kdcifhis.nom to kdcifhis.
              for each b-kdaffilh where b-kdaffilh.kdcif = s-kdcif and b-kdaffilh.nom = s-nom - 1 and lookup(code , '01,02,11') > 0 no-lock.
                  create kdaffilh.
                  kdaffilh.nom  = s-nom .
                  buffer-copy b-kdaffilh except b-kdaffilh.nom to kdaffilh.
              end.
          end.

          form skip(1) v-dat1 label '        С  ' 
                       v-dat2 label '      по  '  skip(1) 
                       with side-label row 5 centered 
                       title 'Укажите даты начала и конца периода для фин анализа' frame dat .
          
          update v-dat1 v-dat2 with frame dat.
          find last kdaffilh where kdaffilh.kdcif = s-kdcif and kdaffilh.nom = s-nom and kdaffilh.code = '18' no-error.
          if not avail kdaffilh then do:
             create kdaffilh.
             assign kdaffilh.bank = s-ourbank kdaffilh.kdcif = s-kdcif  
                    kdaffilh.code = '18' kdaffilh.who = g-ofc kdaffilh.whn = g-today kdaffilh.nom = s-nom.
          end.
          kdaffilh.datres[1] = v-dat1. 
          kdaffilh.datres[2] = v-dat2.
          find current kdaffilh no-lock no-error.
          pause 0.
          s-newrec = false.
        end.
      end.
      else
          message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !" 
              view-as alert-box button ok title "".
    end.
    run kdmonnew .
    s-newrec = false.
    s-page = 1.
    run kdnlmenu.
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


