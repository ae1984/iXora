/* pkankmn.i
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Меню и форма для операций с кредитом
 * RUN

 * CALLER
        pkanklon.p, pklonnew.p
 * SCRIPT

 * INHERIT

 * MENU
        4.x.2, 4.x.3
 * AUTHOR
        08.02.2003 nadejda
 * CHANGES
        17.02.2003 nadejda - включена возможность удаления анкеты, проверяется только статус
        09.09.2003 nadejda - ужесточена проверка при удалении анкеты - проверяется на существование оборотов по открытым счетам, если есть, то не удалять
        11.02.2004 nadejda - удаляемые анкеты не удаляются, а переносятся в таблицы pkankdel, pkankhdel
        12.02.2004 nadejda - добавлена дата опердня удаления
        13.02.2004 nadejda - подсказка при вводе причины удаления
        26.11.2004 saltanat - сделала возможность для Потребкредитов вывода номера последней редактированной анкеты.
        17.05.05   marinav - для карточек в цель кредита записывается вид карточного договора
        19.04.06 Natalya D. - добавила Подарочные карты (s-credtype = '9')
        29/05/2006 madiyar - v-anktype (повторная, рефинансирование, казпочта)
        22/02/2008 madiyar - расширил фреймы
        30/09/2009 galina - добавила вывод номера родительской анкеты на анкете созаемщика
        11/05/2010 galina - добавила поля "Статус КД" и "Дата стат.КД"
        17/06/2010 galina - добавила поле "Поручитель"
*/



{opt-prmt.i}

def new shared frame pkank.
define new shared frame menu.
define new shared variable s-newrec as logical.
define variable v-procro as char.
define variable v-ans as logical.
def var v-crccod as char.
def var v-reason as char.
def var v-kkcard as char.
def stream s1.

run pknlmenu.

form s-sign[1] s-menu s-sign[2] with frame menu col 1 row 1 width 110 no-box no-label.

def var v-i as integer.

{pkanklon.f}

hide message no-pause.
clear frame pkank.

view frame pkank.

if s-credtype = "3" then displ v-labelcomiss with frame pkank.


main:
repeat:
  hide message.
  find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
  if avail pkanketa then do:
    find lon where lon.lon = pkanketa.lon no-lock no-error.
    v-refusname = "".
    do v-i = 1 to num-entries(pkanketa.refusal):
      for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(v-i, pkanketa.refusal) no-lock:
        if v-refusname <> "" then v-refusname = v-refusname + ", ".
        v-refusname = v-refusname + bookcod.name.
      end.
    end.

    v-stsdescr = "".
    find bookcod where bookcod.bookcod = "pkstsank" and bookcod.code = pkanketa.sts no-lock no-error.
    if avail bookcod then v-stsdescr = bookcod.name.
    v-pkpartner = pkanketa.partner.
    find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
    if avail codfr then v-predpr = codfr.name[1].
                   else v-predpr = "".

    if s-credtype = "4" or s-credtype = "9" then do:
      find bookcod where bookcod.bookcod = 'kktype' and bookcod.code = pkanketa.partner no-lock no-error.
      if avail bookcod then v-predpr = bookcod.name.
                       else v-predpr = "".
    end.

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "kdsts" no-lock no-error.
    if avail pkanketh then do:
        v-kdsts = pkanketh.value1.
        if v-kdsts = '05' or v-kdsts = '06' then v-kddt = date(pkanketh.value2).
        if v-kdsts = '07' then v-kdguaran = pkanketh.value2.
        if v-kdsts <> '05' and v-kdsts <> '06' then v-kddt = ?.
        if v-kdsts <> '07' then v-kdguaran = ''.
    end.
    else assign v-kdsts = "" v-kddt = ? v-kdguaran = "".

    v-kdstsdes = "".
    find first codfr where codfr.codfr = 'kdsts' and codfr.code = v-kdsts no-lock no-error.
    if avail codfr then v-kdstsdes = codfr.name[1].

    find crc where crc.crc = pkanketa.crc no-lock no-error.
    v-crccod = crc.code.

    if pkanketa.rescha[5] <> "" and entry (1, pkanketa.rescha[5], "|") <> "" then
      v-jhcomiss = integer (entry (1, pkanketa.rescha[5], "|")).

    v-kkcard = pkanketa.goal.
    if s-credtype = '4' or s-credtype = '9' then do:
       find bookcod where bookcod.bookcod = "kkcard" and bookcod.code = pkanketa.goal no-lock no-error.
       if avail bookcod then v-kkcard = bookcod.name.
    end.

    if pkanketa.id_org <> '' then v-anktype = "[" + pkanketa.id_org + "]".
    else do:
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
      if avail pkanketh and trim(pkanketh.rescha[3]) <> '' then v-anktype = "[повторная]".
      else do:
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
        if avail pkanketh and pkanketh.rescha[1] <> '' and pkanketh.resdec[1] > 0 then v-anktype = "[рефин-е]".
        else v-anktype = "".
      end.
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "mainln" no-lock no-error.
      if avail pkanketh and pkanketh.value1 <> '' then v-anktype = "[№ " + pkanketh.value1 + "]".
    end.

    displ
      s-pkankln
      v-anktype
      pkanketa.rdt
      pkanketa.rwho
      pkanketa.cdt
      v-stsdescr
      pkanketa.cwho
      pkanketa.rnn
      pkanketa.sts
      pkanketa.bank
      pkanketa.name
      pkanketa.rating
      pkanketa.refusal + " : " + v-refusname @ pkanketa.refusal
      pkanketa.summax
      pkanketa.billsum
      pkanketa.sumavans
      pkanketa.sumavans%
      pkanketa.sumq
      pkanketa.srokmin
      pkanketa.cif
      pkanketa.lon
      pkanketa.aaa
      v-kkcard @ pkanketa.goal
      v-kdsts v-kdstsdes v-kddt v-kdguaran
      v-pkpartner
      pkanketa.summa
      pkanketa.srok
      pkanketa.rateq
      pkanketa.duedt
      pkanketa.trx1
      pkanketa.trx2
      pkanketa.sernom
      v-predpr
      v-crccod @ v-crccod1
      v-crccod @ v-crccod2
      v-crccod @ v-crccod3
      /*v-crccod @ v-crccod4*/
      v-crccod @ v-crccod5
      lon.day when avail lon
      lon.lcr when avail lon
      pkanketa.aaaval
      v-labelcomiss when s-credtype = "3"
      v-jhcomiss when s-credtype = "3"
      with frame pkank.
  end.
  else
    s-pkankln = 0.

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
        run pknlmenu.
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
        run pknlmenu.
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

      if search('pkcif.lst') <> ? then do: input stream
      s1   from pkcif.lst. repeat on endkey undo,leave: import stream s1 s-pkankln.
      leave.   end. input stream s1 close. pause 0. end.

      update s-pkankln with frame pkank.

      output stream s1 to pkcif.lst. export stream s1 s-pkankln. output stream s1 close. pause 0.

      find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
      if not avail pkanketa then do:
        {mesg.i 0232}.
        bell. undo, retry.
      end.
    end.
    else
    if frame-index eq 2 and s-menu[2] ne " " and s-pkankln <> 0 then do:
      find optitem where optitem.optmenu eq s-main and optitem.ln eq frame-index no-lock no-error.
      if chkrights(optitem.proc) then do transaction:
        find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
        if pkanketa.sts >= "30" then do:
          message "~nОткрыты счета - нельзя удалить анкету !~n" view-as alert-box title " ВНИМАНИЕ ! ".
          undo, next main.
        end.

        if pkanketa.lon <> "" then do:
          find first jl where jl.acc = pkanketa.lon no-lock no-error.
          if avail jl then do:
            message "~nОткрыт ссудный счет и существует транзакция N" jl.jh "по данному счету - нельзя удалить анкету !~n" view-as alert-box title " ВНИМАНИЕ ! ".
            undo, next main.
          end.
        end.

        if pkanketa.aaaval <> "" then do:
          find first jl where jl.acc = pkanketa.aaaval no-lock no-error.
          if avail jl then do:
            message "~nОткрыт текущий счет в валюте и существует транзакция N" jl.jh "по данному счету - нельзя удалить анкету !~n" view-as alert-box title " ВНИМАНИЕ ! ".
            undo, next main.
          end.
        end.

        if pkanketa.aaa <> "" then do:
          find first jl where jl.acc = pkanketa.aaa no-lock no-error.
          if avail jl then do:
            message "~nОткрыт текущий счет в KZT и существует транзакция N" jl.jh "по данному счету - нельзя удалить анкету !~n" view-as alert-box title " ВНИМАНИЕ ! ".
            undo, next main.
          end.
        end.

        {mesg.i 0824} update v-ans.
        if not v-ans then do:
          undo, next main.
        end.

        update v-reason view-as editor size 50 by 3 no-label
          help " Напишите причину, затем нажмите F1 для продолжения работы"
          validate (v-reason <> "", " Укажите причину удаления анкеты!")
          with centered overlay row 12 title " ПРИЧИНА УДАЛЕНИЯ АНКЕТЫ " frame f-delank.
        hide frame f-delank.

        for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln exclusive-lock:
          create pkankhdel.
          buffer-copy pkanketh to pkankhdel.
          delete pkanketh.
        end.
        release pkanketh.
        release pkankhdel.

        find current pkanketa exclusive-lock.

        create pkankdel.
        buffer-copy pkanketa to pkankdel.
        assign pkankdel.delwho = g-ofc
               pkankdel.deldt = g-today
               pkankdel.delwhn = today
               pkankdel.deltim = time
               pkankdel.delreason = v-reason.

        delete pkanketa.
        release pkanketa.
        release pkankdel.

        s-pkankln = 0.

        clear frame pkank.
        s-page = 1.
        run pknlmenu.
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


