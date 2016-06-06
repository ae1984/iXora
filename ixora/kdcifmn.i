/*
 * MODULE
        Кредитное досье
 * DESCRIPTION
    Форма для ведения клиента
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        1.11.2
 * AUTHOR
        20.07.2003 marinav
 * CHANGES
        20.07.03 marinav
        30/04/2004 madiyar - работа с досье филиала в ГБ
        30.09.2005 marinav - изменения для бизнес-кредитов
        10/05/2006 madiyar - изменения для кредитов клиентам Green House
    05/09/06   marinav - добавление индексов
    04/11/2010 galina - копируем данные первого руководителя из карточки клиента
*/


{opt-prmt.i}

def new shared frame kdcif.
define new shared frame menu.
define new shared var s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.
define buffer b-cif for cif.

run kdnlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 no-box no-label.

def var v-i as integer.

{kdcif.f}

hide message no-pause.
clear frame kdcif.

view frame kdcif.


main:
repeat:
  hide message.
  find kdcif where kdcif.kdcif = s-kdcif no-lock no-error.
  if avail kdcif then do:
      if s-ourbank <> "TXB00" and (kdcif.bank <> s-ourbank) then do:
        message "Клиент другого филиала!".
        return.
      end.
      find first codfr where codfr.codfr = "lnopf" and codfr.code = kdcif.lnopf no-lock no-error.
      if avail codfr then v-lnopf = codfr.name[1].

      find first codfr where codfr.codfr = "ecdivis" and codfr.code = kdcif.ecdivis.
      if avail codfr then v-ecdivis = codfr.name[1].
    displ
      s-kdcif kdcif.regdt kdcif.who kdcif.bank kdcif.mname kdcif.manager
      kdcif.prefix kdcif.rnn  kdcif.name
      kdcif.fname kdcif.lnopf v-lnopf kdcif.ecdivis v-ecdivis kdcif.urdt
      kdcif.urdt1 kdcif.regnom kdcif.addr[1]
      kdcif.addr[2] kdcif.tel kdcif.sotr kdcif.chief[1] kdcif.job[1]
      kdcif.docs[1] kdcif.rnn_chief[1] kdcif.chief[2]
      with frame kdcif.
      pause 0.
  end.
  else do:
    s-kdcif = "".
    /* message "esdfserfgvserg" view-as alert-box buttons ok. */
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

     update s-kdcif with frame kdcif.
     find first kdcif where kdcif.kdcif = s-kdcif {1} no-lock no-error.
     {3}
      if not avail kdcif then do:
        find cif where cif.cif = s-kdcif no-lock no-error.
        {4}
        if avail cif then do:
           message skip " Клиент найден в базе операционного департамента~n
и будет перенесен в базу Кредитного досье !~n
В пункте 'Редактировать' заполните недостающие поля! "
                     skip(1) view-as alert-box button ok title "".
           create kdcif.
           {2}
           kdcif.kdcif = s-kdcif.
           kdcif.prefix = cif.prefix.
           kdcif.regdt = g-today.
           kdcif.who = g-ofc.
           kdcif.bank = s-ourbank.
           kdcif.name = cif.name.
           kdcif.fname = cif.sname.
           kdcif.rnn = cif.jss.
           kdcif.addr[1] = cif.addr[1].
           kdcif.addr[2] = cif.addr[2].
           kdcif.tel = cif.tel.
           kdcif.sotr = cif.cust-since.
           kdcif.regnom  = cif.ref[8].
           kdcif.urdt = cif.expdt.
           kdcif.lnopf = 'msc'.
           kdcif.chief[1] = 'msc'.
           kdcif.ecdivis = 'msc'.
           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'clnchf'
                               and sub-cod.ccode = 'chief' no-lock no-error.
           if avail sub-cod then kdcif.chief[1] = sub-cod.rcode.

           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'lnopf'
                               no-lock no-error.
           if avail sub-cod then kdcif.lnopf = sub-cod.ccode.

           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'clnchfrnn'
                               and sub-cod.ccode = 'chfrnn' no-lock no-error.
           if avail sub-cod then kdcif.rnn_chief[1] = sub-cod.rcode.

           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'clnchfdnum'
                               and sub-cod.ccode = 'chfdocnum' no-lock no-error.
           if avail sub-cod then kdcif.docs[1] = sub-cod.rcode.

           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'clnchfddt'
                               and sub-cod.ccode = 'chfdocdt' no-lock no-error.
           if avail sub-cod then do:
               if trim(kdcif.docs[1]) <> '' then kdcif.docs[1] = trim(kdcif.docs[1]) + ' '.
               kdcif.docs[1] =  kdcif.docs[1] + sub-cod.rcode.
           end.

           find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-kdcif
                               and sub-cod.d-cod = 'clnbk'
                               and sub-cod.ccode = 'mainbk' no-lock no-error.

           if avail sub-cod then kdcif.chief[2] = sub-cod.rcode.
           find first b-cif where caps(b-cif.name) = caps(kdcif.chief[1]) no-lock no-error.
           if avail b-cif then assign kdcif.docs[1] = cif.pss
                                      kdcif.rnn_chief[1] = cif.jss.
           find first sub-cod where sub = 'cln' and acc = s-kdcif and d-cod = 'ecdivis'
                         no-lock no-error.
           if avail sub-cod then kdcif.ecdivis = sub-cod.ccode.
           find first sub-cod where sub = 'lon' and d-cod = 'lnopf'
                         no-lock no-error.
           if avail sub-cod then kdcif.lnopf = sub-cod.ccode.
           run kdpoisk(1, '').
           run kdpoisk(2, kdcif.chief[1]).
          /*run kdpoisk(2, kdcif.chief[2]).*/
        end.
        else do:
          message skip " Клиент в базе не найден!" skip(1)
           view-as alert-box buttons ok title " ОШИБКА ! ".
          bell. undo, retry.
        end.
      end.
     pause 0.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " then do:
      find optitem where optitem.optmenu eq s-main and optitem.ln eq frame-index no-lock no-error.
      if chkrights(optitem.proc) then do:
        message "Создать нового клиента ? " update v-ans.
        if v-ans eq false then do:
          undo, next main.
        end.
        do transaction on error undo, retry:
          find nmbr where nmbr.code = "CIF" exclusive-lock.
          s-kdcif = string(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
          nmbr.nmbr = nmbr.nmbr + 1.
          release nmbr.
          create kdcif.
          {2}
          kdcif.kdcif = s-kdcif.
          kdcif.regdt = g-today.
          kdcif.who = g-ofc.
          kdcif.bank = s-ourbank.
          kdcif.lnopf = 'msc'.
          kdcif.chief[1] = 'msc'.
          kdcif.ecdivis = 'msc'.
          pause 0.
          s-newrec = true.
        end.
      end.
      else
          message "   У вас нет прав для выполнения процедуры " + optitem.proc + " !"
              view-as alert-box button ok title "".
    end.
    run kdcifnew .
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
