/* repo.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       24/11/03 nataly была доработана форма вывода данных при отсутствии кодификатора codfr
       30/12/03 nataly была добавлена автоматическая возможность открытия fun-счета
       15.01.04 nataly при просмотре и редактировании для сделок РЕПО
                значение fun.cst заменяется на deal.atvalueon[3].
       01/03/04 nataly добавлено vnew or vnew  при редактировании
       16/03/04 nataly сохраняем дату пролонгации сделок РЕПО
       23/09/05 ten добавлена переменная v-add - курс валюты, fun.vop = сумма объема открытия =  deal.vop  .
       23/09/05 ten fun.vcb - вид ценных бумаг, fun.nom - сумма по номиналу = номин * кол-во ЦБ * курс. fun.pamt = сумма %.
       13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/



/*{mainhead.i MMD}*/
{global.i}
define variable new_document as logical.
define variable var_handle   as widget-handle.
DEF NEW SHARED VAR s-deal LIKE deal.deal.

DEF VAR vyield LIKE deal.yield.
DEF VAR vnew AS LOG.
DEF VAR vedit AS LOG.
DEF VAR vlong AS LOG.

def new shared var vdeal like deal.deal.

def buffer b-deallong for deallong.
DEF VAR vgl LIKE gl.gl.
def var v-add as dec.
DEF VAR vacc LIKE deal.deal.
DEF VAR fv AS cha.
DEF VAR inc AS INT.
DEF VAR vans AS LOG.
DEF VAR vans2 AS LOG format "да/нет".
DEF VAR vnxt AS INT.
DEF VAR vseoul AS LOG.
DEF VAR vbaseday LIKE sysc.inval.
DEF VAR scrc LIKE crc.crc.
define variable v-crc like crc.crc.
define variable v-code like crc.code.
define variable v-bankl like bankl.bank.
define variable v-weekbeg as integer init 2.
define variable v-weekend as integer init 6.
DEF VAR cmd AS cha FORM "x(9)" EXTENT 9
  INIT ["CREATE", " EDIT ", "PROLONG", "HISLNG", "DELETE", "PRINT", "OPEN/CLOSE",  " QUIT "].
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 360.
DEF VAR v-deal LIKE deal.deal.
define new shared variable v-fungrp like fungrp.fungrp.
def new shared var s-lgr like lgr.lgr.

def var p-open as decimal.
def new shared var v-open as decimal.
def var v-close as decimal.
def var p-close as decimal.
def var v-income as decimal.
def var v-grp as char.
def var v-matured as  date.
def var v-error as char.
def var d-close as date.
def var snom as int.
{repo.f}


FIND sysc WHERE sysc.sysc EQ "basedy" NO-LOCK NO-ERROR.
IF AVAIL sysc THEN
vbaseday = sysc.inval.
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc
then v-weekbeg = sysc.inval.
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc
then v-weekend = sysc.inval.

find sysc where sysc.sysc = 'repogr' no-lock no-error.
if avail sysc then v-grp = sysc.chval.


on help of deal.rem[3] in frame deal2 do: run h-secur.
                    deal.rem[3]:screen-value = return-value.
                    deal.rem[3] = deal.rem[3]:screen-value.
               end.
on help of deal.ncrc[1] in frame deal2 do:
                  message 'Справочник не предусмотрен!'.
                  pause 100.
                 end.

on help of deal.ncrc[2] in frame deal2 do:
                  message 'Справочник не предусмотрен!'.
                  pause 100.
                 end.

REPEAT:
  vnew = FALSE.
  vedit = FALSE.
    clear frame deal2.
  VIEW FRAME deal2.
  DISP cmd WITH FRAME slct.
  CHOOSE FIELD cmd WITH FRAME slct.
  DO TRANSACTION:
     IF FRAME-VALUE EQ "create"
     THEN DO:
          vgl = 0.
          CLEAR FRAME deal2.
          DO ON ERROR UNDO, RETRY:
             update v-fungrp with frame deal2.
             find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
             if not available fungrp or  lookup(string(v-fungrp), v-grp) = 0
             then do:
               message 'Выбранная группа не является группой РЕПО!'.
               undo,retry.
             end.
             vgl = fungrp.gl.
             display vgl WITH FRAME deal2.
             FIND gl WHERE gl.gl EQ vgl NO-ERROR.
             IF NOT AVAIL gl THEN
             DO:
               message "Не найден счет " vgl " в Главной Книге".
               pause.
               UNDO, RETRY.
             END.
          END. /* do on error for gl checking */
          DISP gl.des WITH FRAME deal2.
          run acng(vgl,true,output vacc).
          find first fun where fun.fun = vacc no-error.
          if avail fun then delete fun.
          CREATE deal.
          deal.regdt = g-today.
          IF INPUT deal.deal EQ ""
          THEN deal.deal = vacc.
          deal.grp = v-fungrp.
          DISP deal.deal WITH FRAME deal2.
          deal.gl = vgl.
          vnew = TRUE.
     END. /* create */
  END. /* transaction */

  DO TRANSACTION:

     if frame-value eq "OPEN/CLOS"
     then do:

          hide frame slct.
          update vdeal label "Введите номер РЕПО"  with frame deal row 5 no-label centered.
      /*    hide frame deal.*/
          find deal where deal.deal eq input vdeal no-error.
          find fun where fun.fun eq deal.deal no-lock no-error.
        if fun.sts = 0
           and deal.fun = ""
           then run openrepo (vdeal).
           else run clrepo (vdeal).

  end.
  end.


  DO TRANSACTION:

     IF FRAME-VALUE EQ " edit "
     THEN DO:
          clear frame deal2.
          PROMPT deal.deal WITH FRAME deal2.
          FIND deal WHERE deal.deal EQ INPUT deal.deal NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.
          IF deal.fun NE ""
          THEN DO:
               message "Произведена транзакция - редактирование недопустимо".
               /* {mesg.i 0268}.  */
               pause.
               UNDO, RETRY.
          END.
          v-fungrp = deal.grp.
          v-add = deal.brkgfee.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
           if not available fungrp then message 'no grp!'.
     if not available fungrp or  lookup(string(deal.grp), v-grp) = 0
             then do:
               message 'Набранный счет не относится к группе РЕПО!'.
               undo,retry.
             end.

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          FIND codfr WHERE codfr.codfr EQ 'secur'
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal2.
          if available gl
          then display gl.des with frame deal2.
          if available bankl
          then display bankl.name with frame deal2.
          DISP v-fungrp
               deal.gl @ vgl
               deal.deal
               v-bankl
             /*  days
               deal.prn*/
               deal.yield
               deal.intrate
             /*  deal.intamt */
             /*  deal.valdt */
               deal.maturedt
               deal.trm
               deal.regdt
           /*    deal.inttype
               deal.totamt
               deal.broke */
               deal.rem[3]
    /*           codfr.name[1]*/
               deal.ncrc[1]
               deal.ncrc[2]
               v-add
               deal.arrange
            /*   deal.atvalueon[1]
               deal.atvalueon[2] */
               deal.atvalueon[3]
              /* deal.atmaton[1]
               deal.atmaton[2]
               deal.atmaton[3]
               deal.rem[1]
               deal.rem[2] */
          WITH FRAME deal2.
          vedit = TRUE.
        if avail codfr then displ codfr.name[1] with frame deal2.
     END. /* edit */
     /*05/11/03 nataly*/
     ELSE if frame-value eq "HISLNG"
       then do:
         clear frame deal2.
          PROMPT deal.deal no-label  WITH FRAME deal  col 10 row 10
           title 'Введите счет FUN '.
          FIND deal WHERE deal.deal EQ INPUT deal.deal no-lock NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.
      find gl where gl.gl = deal.gl no-lock no-error.
       if gl.type = 'A' then
        run hisdealA.p(deal.deal).
       else  run hisdealP.p(deal.deal).
       end. /*HISLNG*/

    ELSE IF FRAME-VALUE EQ "prolong"
     THEN DO:

         clear frame deal2.
          PROMPT deal.deal no-label  WITH FRAME deal  col 10 row 10
           title 'Введите счет FUN '.
          /* update v-deal v-matured WITH FRAME deal  col 10 row 10
           title 'Введите счет FUN и дату окончания '.*/
          FIND deal WHERE deal.deal EQ INPUT deal.deal no-lock NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.
/*
          IF deal.fun NE ""
          THEN DO:
               message "Произведена транзакция - редактирование недопустимо".
               /* {mesg.i 0268}.  */
               pause.
               UNDO, RETRY.
          END.
*/
          v-fungrp = deal.grp.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
           if not available fungrp then message 'no grp!'.
        if not available fungrp or  lookup(string(deal.grp), v-grp) = 0
             then do:
               message 'Набранный счет не относится к группе РЕПО!'.
               undo,retry.
             end.
          update v-matured label 'Введите дату окон сделки, к-ую надо продлить или отредактировать' WITH FRAME deal22  col 10 row 10.

          find deal where deal.deal = INPUT deal.deal and  deal.matured = v-matured no-lock no-error.
           if not avail deal then find  b-deallong where   b-deallong.deal = INPUT deal.deal and b-deallong.matured = v-matured no-error.
          if not avail deal and not avail b-deallong  then do:
               message 'Среди сделок и ее пролонгаций нет той, дата окончания которой  ' string(v-matured) '!'. pause 2.
               undo,retry.
           end.

/*продление осн сделки*/
         if avail deal then do:
           find  deallong where   deallong.deal = INPUT  deal.deal and deallong.regdt = v-matured no-error.
           if not avail deallong
           then   do:
                vans2 = false.
                pause 0.
                message "Создать  пролонгирующую сделку? deal "  update vans2.
                if vans2 then  do:
                 create deallong.
                 buffer-copy deal to deallong.
                 deallong.regdt = deal.matured.
                 deallong.matured = deallong.matured + 1.
           /*по-старому*/

            p-open = deallong.prn / 100.
            v-open = round(p-open * deallong.ncrc[2],2).



            p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).

            v-close = round(p-close * deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).

           /*с пересчетом*/
            deallong.prn = p-close * 100.
            p-open = deallong.prn / 100.
            v-open = round(p-open * deallong.ncrc[2],2).

            p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
            v-close = round(p-close * deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).
           end. /*vans2*/
           else do:
               message "Пролонгация сделки отменена ! ".
               pause.
               UNDO, RETRY.
           end.
          end.  /*not avail deallong*/
          else do:
            p-open = deallong.prn / 100.
            v-open = round(p-open * deallong.ncrc[2],2).

            p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
            v-close = round(p-close * deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).
          end.
          end. /*if avail deal*/

/*продление пролонгации*/
           if not avail deal then do:
            find  b-deallong where   b-deallong.deal = INPUT deal.deal and b-deallong.regdt = v-matured no-error.
           if not avail b-deallong              then   do:
                vans2 = false.
                pause 0.
                message "Создать  пролонгирующую сделку? deallong "  update vans2.
                if vans2 then  do:
                 create deallong.
                 find  b-deallong where   b-deallong.deal = INPUT deal.deal and b-deallong.matured = v-matured no-error.
                 buffer-copy b-deallong except b-deallong.matured to deallong .
                 deallong.regdt = deallong.matured.
                 deallong.matured = deallong.matured + 1.
           /*по-старому*/
            p-open = deallong.prn / 100.
            v-open = round(p-open * deallong.ncrc[2],2).

            p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
            v-close = round(p-close * deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).

           /*с пересчетом*/
            deallong.prn = p-close * 100.
            p-open = deallong.prn / 100.
            v-open = round(p-open * deallong.ncrc[2],2).

            p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
            v-close = round(p-close * deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).
           end. /*vans2*/
           else do:
               message "Пролонгация сделки отменена ! ".
               pause.
               UNDO, RETRY.
           end.
          end.  /*not avail b-deallong*/
          else do:
            p-open = b-deallong.prn / 100.
            v-open = round(p-open * b-deallong.ncrc[2],2).

            p-close = round((p-open * b-deallong.intrate / 100 / 365 * b-deallong.trm + p-open),4).
            v-close = round(p-close * b-deallong.ncrc[2],2).
            v-income = round(v-close - v-open,2).

            find  deallong where   deallong.deal = INPUT deal.deal and deallong.regdt = v-matured no-error.
          end.
          end.  /*not avail deal*/

          FIND gl WHERE gl.gl EQ deal.gl no-error.
          FIND codfr WHERE codfr.codfr EQ 'secur'
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deallong.
          if available gl
          then display gl.des with frame deallong.

          DISP v-fungrp
               deallong.gl @ vgl
               deallong.deal

               deallong.yield
               deallong.intrate
               deallong.maturedt
               deallong.trm
               deallong.regdt
               deallong.rem[3]
               deallong.ncrc[1]
               deallong.ncrc[2]
             /*  deallong.arrange
               deallong.atvalueon[3] */
          WITH FRAME deallong.
          vlong = TRUE.
     END. /* prolong */

     ELSE IF FRAME-VALUE EQ "delete"
     THEN DO:
          CLEAR FRAME deal2.
          PROMPT deal.deal WITH FRAME deal2.
          FIND deal WHERE deal.deal EQ INPUT deal.deal NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.
          IF deal.fun NE ""
          THEN DO:
               message "Произведена транзакция - удаление недопустимо".
               pause.
               UNDO, RETRY.
          END.

          v-fungrp = deal.grp.
          v-add = deal.brkgfee.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
              if not available fungrp or  lookup(string(deal.grp), v-grp) = 0
              then do:
               message 'Набранный счет не относится к группе РЕПО!'.
               undo,retry.
             end.
          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          if available bankl
          then display bankl.name with frame deal2.
          DISP deal.gl @ vgl
               deal.deal
               v-bankl
               deal.atvalueon[3]
               deal.rem[3]
               deal.yield
               deal.intrate
            /*   deal.intamt
               deal.valdt */
               deal.maturedt
               deal.trm
               deal.regdt
              /* deal.inttype
               deal.totamt
               deal.broke
               deal.rem[3] */
               deal.ncrc[1]
               deal.ncrc[2]
               v-add
           /*    deal.arrange
               deal.atvalueon[1]
               deal.atvalueon[2]
               deal.atvalueon[3]
               deal.atmaton[1]
               deal.atmaton[2]
               deal.atmaton[3]
               deal.rem[1]
               deal.rem[2]   */
          WITH FRAME deal2.
          FIND codfr WHERE codfr.codfr EQ 'secur'
          and codfr.code = deal.rem[3] no-error.
          if avail codfr then displ codfr.name[1] with frame deal2.

          if deal.intrate > 0 and deal.trm > 0 and deal.ncrc[2] > 0  then do:
           p-open = deal.prn / 100.
           v-open = round(p-open * deal.ncrc[2],2).


           p-close = round((p-open * deal.intrate / 100 / 365 * deal.trm + p-open),4).
           v-close = round(p-close * deal.ncrc[2],2).
           v-income = round(v-close - v-open,2).
           deal.yield = v-income.
           deal.vop = v-open.
           displ p-open with frame deal2.
           displ v-open with frame deal2.
           displ p-close with frame deal2.
           displ v-close with frame deal2.
           displ deal.yield with frame deal2.
          end.

             find dfb where dfb.dfb = deal.atvalueon[1] no-lock no-error.
             if available dfb
             then do:
                v-crc = dfb.crc.
                find crc where crc.crc = v-crc no-lock.
                v-code = crc.code.
                display v-crc v-code with frame deal2.
             end.
          vans = false.
          pause 0.
          message "Удалить сделку " input deal.deal " ? (Да/Нет)" update vans.
          IF vans
          then do:
            find fun where fun.fun  = deal.deal no-error.
            if avail fun and  fun.dam[1] = fun.cam[1]  and  fun.dam[2] = fun.cam[2] then delete fun.
            if avail fun and ( fun.dam[1] <> fun.cam[1]  or  fun.dam[2] <> fun.cam[2]) then do:
               message "Произведена транзакция - удаление недопустимо".
               pause.
               UNDO, RETRY.
          end.
             DELETE deal.
             clear frame deal2.
         end.
     END. /* delete */
     ELSE IF FRAME-VALUE EQ " quit "
     THEN RETURN.
     ELSE IF FRAME-VALUE EQ " print"
     THEN DO:
          PROMPT deal.deal WITH FRAME deal2.
          FIND deal WHERE deal.deal EQ INPUT deal.deal NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.

          v-fungrp = deal.grp.
          v-add = deal.brkgfee.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
              if not available fungrp or  lookup(string(deal.grp), v-grp) = 0
             then do:
               message 'Набранный счет не относится к группе РЕПО!'.
               undo,retry.
             end.

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          if available gl
          then display gl.des with frame deal2.
          if available bankl
          then display bankl.name with frame deal2.
       /*   DISP deal.gl @ vgl
               deal.deal
               v-bankl
               days
               deal.prn
               deal.yield
               deal.intrate
               deal.intamt
          /*     deal.valdt */
               deal.maturedt
               deal.trm
               deal.regdt
/*               deal.inttype
               deal.totamt
               deal.broke */
               deal.rem[3]
               deal.ncrc[1]
               deal.ncrc[2]
               v-add
/*               deal.arrange
               deal.atvalueon[1]
               deal.atvalueon[2]*/
               deal.atvalueon[3]
          /*     deal.atmaton[1]
               deal.atmaton[2]
               deal.atmaton[3]
               deal.rem[1]
               deal.rem[2] */
          WITH FRAME deal2.*/
          vans = false.
          message "Распечатать сделку " input deal.deal " (Да/Нет)" update vans.
          IF NOT vans
          THEN UNDO, RETRY.
          s-deal = deal.deal.
          PAUSE 0.
          RUN dealfrm.
          PAUSE 0.
     END. /* print */
     IF vlong
     THEN DO:
               find dfb where dfb.dfb = deallong.atvalueon[1] no-lock no-error.
               if available dfb
               then do:
                    v-crc = dfb.crc.
                    find crc where crc.crc = v-crc no-lock.
                    v-code = crc.code.
                    display v-crc v-code with frame deallong.
               end.
          if deallong.intrate > 0 and deallong.trm > 0 and deallong.ncrc[2] > 0  then do:
           p-open = deallong.prn / 100.
           v-open = round(p-open * deallong.ncrc[2],2).
           p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
           v-close = round(p-close * deallong.ncrc[2],2).
           v-income = round(v-close - v-open,2).
          /* deallong.yield = v-income.*/
           displ p-open with frame deallong.
           displ v-open with frame deallong.
           displ p-close with frame deallong.
           displ v-close with frame deallong.
        /*   displ /*deallong.yield*/ v-income with frame deallong.*/
          end.

          UPDATE deallong.intrate format "zz9.9999" WITH FRAME deallong.

          UPDATE deallong.regdt with frame deallong.
          UPDATE p-open validate (p-open NE 0 , "Цена должна быть > 0! ") with frame deallong.
          v-open = round(p-open * deallong.ncrc[2],2).
          displ v-open with frame deallong.
          deallong.prn = p-open * 100.

          update deallong.maturedt WITH FRAME deallong.
          deallong.trm = deallong.maturedt - /*deal.valdt*/ deallong.regdt.
          display deallong.trm with frame deallong.

          p-close = round((p-open * deallong.intrate / 100 / 365 * deallong.trm + p-open),4).
          displ p-close with frame deallong.
          v-close = round(p-close * deallong.ncrc[2],2).
          displ v-close with frame deallong.

          v-income = round(v-close - v-open,2).
          deallong.yield = v-income.
          displ deallong.yield with frame deallong.

          /*16/03/04 nataly сохраняем дату пролонгации сделок РЕПО*/
          find fun where fun.fun = deallong.deal exclusive-lock no-error.
          if avail fun then fun.iddt = deallong.matured.

          message 'Сделка успешно продлена !' view-as alert-box.
     END. /*vlong*/
     IF vnew OR vedit
     THEN DO:
          if vedit
          then do:
               find dfb where dfb.dfb = deal.atvalueon[1] no-lock no-error.
               if available dfb
               then do:
                    v-crc = dfb.crc.
                    find crc where crc.crc = v-crc no-lock.
                    v-code = crc.code.
                    display v-crc v-code with frame deal2.
               end.
          end.
          if deal.intrate > 0 and deal.trm > 0 and deal.ncrc[2] > 0  then do:
           p-open = deal.prn / 100.
           v-open = round(p-open * deal.ncrc[2],2).
           p-close = round((p-open * deal.intrate / 100 / 365 * deal.trm + p-open),4).
           v-close = round(p-close * deal.ncrc[2],2).
           v-income = round(v-close - v-open,2).
           deal.yield = v-income.
           deal.vop = v-open.
           displ p-open with frame deal2.
           displ v-open with frame deal2.
           displ p-close with frame deal2.
           displ v-close with frame deal2.
         /*  find fun where fun.fun = INPUT deal.deal no-lock no-error.
           d-long = fun.iddt.
           displ d-long with frame deal2.*/
           displ deal.yield with frame deal2.
          end.

          v-bankl = deal.bank.
          if deal.inttype = ? or trim(deal.inttype) = ""
          then do:
               deal.inttype = "A".
              /* display deal.inttype with frame deal2.*/
          end.
          FIND gl WHERE gl.gl EQ deal.gl.
          if not vlong  then update v-fungrp with frame deal2.
          if frame deal2 v-fungrp entered
          then do:
               find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
               if not available fungrp
               then undo,retry.
               deal.grp = v-fungrp.
               deal.gl = fungrp.gl.
               find gl where gl.gl = deal.gl no-lock no-error.
               if not available gl
               then do:
                    message "Не найден счет " vgl " в Главной Книге".
                    pause.
                    undo,retry.
               end.
               vgl = gl.gl.
               display vgl gl.des with frame deal2.
          end.
          if not vlong then UPDATE v-bankl WITH FRAME deal2.
          if frame deal2 v-bankl entered
          then do:
               deal.valdt = ?.
             /*  display deal.valdt with frame deal2.*/
               deal.bank = v-bankl.
               FIND bankl WHERE bankl.bank EQ v-bankl NO-ERROR.
               IF AVAIL bankl
               THEN DISP bankl.name WITH FRAME deal2.
               ELSE DO:
                    message "Банк " v-bankl " не найден в справочнике bankl".
                    pause.
                    UNDO, RETRY.
               END.
          end.
          if not vlong then UPDATE deal.atvalueon[3] with frame deal2.

/*          UPDATE deal.broke WITH FRAME deal.
          IF deal.broke NE " "
          THEN DO: */
          if not vlong  then     UPDATE deal.rem[3] WITH FRAME deal2.
          FIND codfr WHERE codfr.codfr EQ 'secur'
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal2.
/*          end.*/
           if not vlong  then UPDATE deal.ncrc[1] WITH FRAME deal2.
           if not vlong  then UPDATE deal.ncrc[2] WITH FRAME deal2.


          UPDATE deal.intrate format "zz9.9999" WITH FRAME deal2.
          if not vlong  then UPDATE v-add format ">>>.999" WITH FRAME deal2 .
          deal.brkgfee = v-add.
        /*  UPDATE deal.prn format "z,zzz,zzz,zzz,zz9.99"
                 VALIDATE (prn NE 0 , " ") WITH FRAME deal.
          do on error undo,retry:
             update v-crc with frame deal.
             find crc where crc.crc = v-crc no-lock.
             v-code = crc.code.
             display v-code with frame deal.
          end.   */

          UPDATE deal.regdt with frame deal2.
/*          update deal.valdt with frame deal.*/
          UPDATE p-open validate (p-open NE 0 , "Цена должна быть > 0! ") with frame deal2.
          v-open = round(p-open * deal.ncrc[2],2).
          displ v-open with frame deal2.
          deal.prn = p-open * 100.

          update deal.maturedt WITH FRAME deal2.
          deal.trm = deal.maturedt - /*deal.valdt*/ deal.regdt.
          display deal.trm with frame deal2.

          p-close = round((p-open * deal.intrate / 100 / 365 * deal.trm + p-open),4).
          displ p-close with frame deal2.
          v-close = round(p-close * deal.ncrc[2],2).
          displ v-close with frame deal2.

          v-income = round(v-close - v-open,2).
          deal.yield = v-income.
          deal.vop = v-open.
          displ deal.yield with frame deal2.

          update v-crc with frame deal2.
          find crc where crc.crc = v-crc no-lock.
          v-code = crc.code.
          display v-code with frame deal2.

          if deal.regdt = ?
          then deal.regdt = g-today.
          if deal.valdt = ? or frame deal2 v-bankl entered or
             frame deal2 v-crc entered
          then do:
               find first bankt where bankt.cbank = bankl.cbank and
                    bankt.crc = v-crc and bankt.racc = "1" and
                    bankt.subl = "DFB" no-lock no-error .
               if not available bankt
               then do:
                    message "Отсутствует запись для банка " +
                            bankl.cbank + " в таблице BANKT!".
                    pause .
                    undo,retry .
               end.
               deal.valdt = g-today + bankt.vdate .
               if deal.valdt = g-today and bankt.vtime < time
               then deal.valdt = deal.valdt + 1 .
               repeat:
                  find hol where hol.hol eq deal.valdt no-lock no-error.
                  if not available hol and
                     weekday(deal.valdt) ge v-weekbeg and
                     weekday(deal.valdt) le v-weekend
                  then leave.
                  else deal.valdt = deal.valdt + 1.
               end.
               if frame deal2 v-bankl entered or frame deal2 v-crc entered
               then do:
                    find dfb where dfb.dfb = bankt.acc no-lock no-error.
                    if not available dfb
                    then do:
                         message "Отсутствует запись для банка " +
                                 v-bankl + " в таблице DFB!".
                         pause .
                         undo,retry .
                    end.
                    deal.atvalueon[1] = dfb.dfb.
                    deal.atvalueon[2] = dfb.name.
                    deal.atmaton[1] = dfb.dfb.
                    deal.atmaton[2] = dfb.name.
/*                    display deal.atvalueon[1]
                            deal.atvalueon[2]
                            deal.atmaton[1]
                            deal.atmaton[2] with frame deal.*/
               end.
         /* end.                 */

/*          update deal.inttype WITH FRAME deal.
          UPDATE days WITH FRAME deal.
  */
   /*       deal.intamt = deal.prn * deal.intrate * deal.trm / (days * 100).
          DISP deal.intamt  WITH FRAME deal.

          IF deal.inttype EQ "A"
          THEN DO:
               deal.totamt = deal.prn + deal.intamt.
               deal.yield = 0.
          END.
          ELSE IF deal.inttype EQ "D"
          THEN DO:
               deal.totamt = deal.prn - deal.intamt.
               FIND sysc WHERE sysc.sysc EQ "eliba" NO-LOCK.
               IF deal.gl EQ INTEGER(sysc.chval)
               THEN DO:
                    vyield = 1 - (deal.intrate * deal.trm / (days * 100)).
                    deal.yield = deal.intrate / vyield.
               END.
               ELSE DO:
                    vyield = deal.intrate * deal.trm / (days * 100).
                    deal.yield = deal.intrate / (1 + vyield).
               END.
          END.  */
/*          DISP deal.totamt format "z,zzz,zzz,zzz,zz9.99"
               deal.yield WITH FRAME deal.
               UPDATE deal.arrange WITH FRAME deal.*/
          END.

   /*25.12.03 nataly*/
      deal.valdt = g-today.

      find sub-cod where sub-cod.sub = 'fun' and
            sub-cod.acc = deal.deal and sub-cod.d-cod = 'secek'  no-error.
     if not available sub-cod  then do:
      create sub-cod.
      sub-cod.sub = 'fun'.
      sub-cod.acc = deal.deal.
      sub-cod.d-cod = 'secek'.
    end.


          display
             deal.geo
             deal.zalog
             deal.lonsec
             deal.risk
             deal.penny
             sub-cod.ccode
             with frame funacr. pause 0.

          update
              deal.geo
              deal.zalog
              deal.lonsec
              deal.risk
              deal.penny
             sub-cod.ccode
              with frame funacr.

          hide frame funacr.

/*          IF gl.type EQ "L"
          THEN DO:
               UPDATE deal.atvalueon[1]
                      VALIDATE(CAN-FIND(dfb WHERE dfb.dfb EQ
                               deal.atvalueon[1])," ") WITH FRAME deal.
               FIND dfb WHERE dfb.dfb EQ deal.atvalueon[1] NO-LOCK.
               deal.atvalueon[2] = dfb.name.
               scrc = dfb.crc.

               DISPLAY deal.atvalueon[2]
                       deal.valfrb
                       deal.atvalueon[3]
               WITH FRAME deal.
               UPDATE deal.valfrb
                      deal.atvalueon[3]
               WITH FRAME deal.

               DO ON ERROR UNDO,RETRY:
                  UPDATE deal.atmaton[1]
                         VALIDATE(CAN-FIND(dfb WHERE dfb.dfb EQ
                                  deal.atmaton[1]), " ") WITH FRAME deal.
                  FIND dfb WHERE dfb.dfb EQ deal.atmaton[1] NO-LOCK.
                  IF dfb.crc NE scrc
                  THEN DO:
                       message "Валюты отличаются для " deal.atvalueon[1]
                               " и " deal.atmaton[1].
                       pause.
                       UNDO,RETRY.
                  END.
               END.                deal.atmaton[2] = dfb.name.
               DISPLAY deal.atmaton[2]
                       deal.matfrb
                       deal.atmaton[3]
               WITH FRAME deal.
               UPDATE deal.matfrb
                      deal.atmaton[3]
               WITH FRAME deal.
          END.
          ELSE DO:
               UPDATE deal.atvalueon[1]
                      VALIDATE(CAN-FIND(dfb WHERE dfb.dfb EQ
                               deal.atvalueon[1]), " ") WITH FRAME deal.
               FIND dfb WHERE dfb.dfb EQ deal.atvalueon[1] NO-LOCK.
               scrc = dfb.crc.
               deal.atvalueon[2] = dfb.name.
               DISPLAY deal.atvalueon[2]
                       deal.valfrb
                       deal.atvalueon[3]
               WITH FRAME deal.
               UPDATE deal.valfrb
                      deal.atvalueon[3]
               WITH FRAME deal.


               deal.atmaton[1] = deal.atvalueon[1].
               DO ON ERROR UNDO,RETRY:
                  UPDATE deal.atmaton[1]
                         VALIDATE(CAN-FIND(dfb WHERE dfb.dfb EQ
                                  deal.atmaton[1]), " ") WITH FRAME deal.
                  FIND dfb WHERE dfb.dfb EQ deal.atmaton[1] NO-LOCK.
                  IF dfb.crc NE scrc
                  THEN DO:
                       message "Валюты отличаются для " deal.atvalueon[1]
                               " и " deal.atmaton[1].
                       pause.
                       UNDO,RETRY.
                  END.
               END.
               deal.atmaton[2] = dfb.name.
               DISPLAY deal.atmaton[2] WITH FRAME deal.
               UPDATE deal.matfrb
                      deal.atmaton[3]
               WITH FRAME deal.
          END.
*/
  /*      UPDATE deal.rem[1] deal.rem[2] WITH FRAME deal.*/
          deal.who = USERID('bank').
          deal.tim = TIME.
        if vnew or vedit then do: /*открытие fun*/
         find fun where fun.fun = deal.deal exclusive-lock no-error.
         if not available fun
         then create fun.
         fun.fun = deal.deal.
         fun.gl = deal.gl.

         find gl where gl.gl eq fun.gl no-lock.
         fun.grp = deal.grp.
         fun.bank = deal.bank.
         find bankl where bankl.bank eq deal.bank no-lock.
        /* fun.cst = bankl.name.
          15/01/04 было заменено для сделок РЕПО  */
         fun.cst = deal.atvalueon[3].
         fun.amt = deal.prn.
         fun.regdt = deal.valdt.
         fun.rdt = deal.valdt.
         fun.duedt = deal.maturedt.
         repeat:
           find hol where hol.hol eq fun.duedt no-lock no-error.
           if not avail hol and
              weekday(fun.duedt) ge v-weekbeg and
              weekday(fun.duedt) le v-weekend
           then leave.
           else fun.duedt = fun.duedt + 1.
         end.
         fun.trm = fun.duedt - fun.rdt.
         fun.intrate = deal.intrate.
         fun.interest = deal.intamt.
         fun.vop = deal.vop.
         fun.itype = deal.inttype.
         if gl.type eq "L"
         then fun.dfb = deal.atvalueon[1].
         else fun.dfb = deal.atmaton[1].
         find dfb where dfb.dfb = fun.dfb no-lock.
         fun.crc = dfb.crc.
         find bankl where bankl.bank eq fun.bank no-lock.
         fun.tbank = bankl.bank.
         fun.crbank = bankl.bank.
         fun.acct = bankl.acct.
         fun.who = g-ofc.
         fun.whn = g-today.
         {subadd-pc.i  &sub = "fun"}
         fun.rcvacc = deal.atvalueon[1].
         fun.payacc = deal.atmaton[1].
         fun.accrcv = deal.atvalueon[3].
         fun.accpay = deal.atmaton[3].
         fun.info[1] = deal.rem[1].
         fun.info[2] = deal.rem[2].
         fun.vcb = deal.rem[3].
      /*   fun.jh1 = deal.tim.*/
          fun.nom = v-add * deal.ncrc[1] * deal.ncrc[2].
         fun.pamt = deal.yield.
         if gl.type eq "A"
         then fun.ref = deal.rem[1].
         else fun.ref = deal.rem[2].

       /* append for accrued system by S.Kuzema */
         fun.zalog  = deal.zalog.
         fun.geo    = deal.geo.
         fun.lonsec = deal.lonsec.
         fun.risk   = deal.risk.
         fun.penny  = deal.penny.


         fun.sts = 0.
         release fun.

        end.
     END. /* vnew or vedit */

  END. /* transaction */
END. /* repeat */


