/* deal2.p
 * MODULE
        Модуль ЦБ 
 * DESCRIPTION
        Открытие и редактирование сделок по ЦБ 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dealval2.p
 * MENU
        11-9-2 
 * BASES
        BANK 
 * AUTHOR
        24/11/03 nataly
 * CHANGES
       25/11/03 nataly было добавлено автоматическое открытие счетов SCU
       27/11/03 nataly при удалении было добавлено удаление SCU
       19/12/03 nataly при редактировании счета нельзя редактировать дату валютирования
       28/07/04 tsoy   Добавил дополнительные поля, (Доходность к погашению, Дата выплаты купона, 
                                                     Дней до погашения, Дней до выплаты купона).
                                                     их можно редактриовать всегда.
      01.09.2004 tsoy  обновление значений Дней до погашения, Дней до выплаты купона.
	19.04.2006 u00121 - перекомпиляция, в связи с багами работы программы на реальной базе
*/

   
{mainhead.i MMD}

DEF NEW SHARED VAR s-deal LIKE deal.deal.
def  new shared var vdeal like deal.deal.
DEF new shared VAR vnew AS LOG.
DEF new shared VAR vedit AS LOG.
DEF new shared VAR vfun AS LOG.

DEF VAR vyield LIKE deal.yield.
DEF VAR vgl LIKE gl.gl.
DEF VAR vacc LIKE deal.deal.
DEF VAR fv AS cha.
DEF VAR inc AS INT.
DEF VAR vans AS LOG.
DEF VAR vnxt AS INT.
DEF VAR vseoul AS LOG.
DEF VAR vbaseday LIKE sysc.inval.
DEF VAR scrc LIKE crc.crc.
define variable v-rate like crc.rate[1].
define variable v-crc like crc.crc.
define variable v-code like crc.code.
define variable v-bankl like bankl.bank.
define variable v-weekbeg as integer init 2.
define variable v-weekend as integer init 6.
DEF VAR cmd AS cha FORM "x(6)" EXTENT 5
  INIT ["CREATE", " EDIT ", "DELETE", " PRINT", " QUIT "].
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 360.
DEF VAR v-deal LIKE deal.deal.
define variable v-scugrp like scugrp.scugrp.
def new shared var s-lgr like lgr.lgr.

{deal2.f}
                                                                            
FIND sysc WHERE sysc.sysc EQ "basedy" NO-LOCK NO-ERROR.
IF AVAIL sysc THEN
vbaseday = sysc.inval.
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc
then v-weekbeg = sysc.inval.
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc
then v-weekend = sysc.inval.

on help of deal.rem[3] in frame deal do: run h-secur.  
                    deal.rem[3]:screen-value = return-value.
                    deal.rem[3] = deal.rem[3]:screen-value. 
               end.
on help of deal.ncrc[1] in frame deal do: 
                  message 'Справочник не предусмотрен!'.  
                  pause 100.
                 end.

on help of deal.ncrc[2] in frame deal do: 
                  message 'Справочник не предусмотрен!'.  
                  pause 100.
                 end.

on help of deal.dval[4] in frame deal do: run h-emittype.  
                    deal.dval[4] :screen-value = return-value.
                    deal.dval[4]  = deci(deal.dval[4] :screen-value). 
               end.

on help of deal.dval[5] in frame deal do: run h-emitview.  
                    deal.dval[5] :screen-value = return-value.
                    deal.dval[5]  = deci(deal.dval[5] :screen-value). 
               end.


REPEAT:

  vnew = FALSE.
  vedit = FALSE.
  /*  clear frame deal.*/
  VIEW FRAME deal.
  pause 0.
  DISP cmd WITH FRAME slct.
  CHOOSE FIELD cmd WITH FRAME slct.
  DO TRANSACTION:
     IF FRAME-VALUE EQ "create" 
     THEN DO:
          vgl = 0.
          CLEAR FRAME deal.
          DO ON ERROR UNDO, RETRY:
             update v-scugrp with frame deal.
             find scugrp where scugrp.scugrp = v-scugrp no-lock no-error.
             if not available scugrp
             then undo,retry.
             vgl = scugrp.gl.
             display vgl WITH FRAME deal.
             FIND gl WHERE gl.gl EQ vgl NO-ERROR.
             IF NOT AVAIL gl THEN
             DO:
               message "Не найден счет " vgl " в Главной Книге".
               pause.
               UNDO, RETRY.
             END.
          END. /* do on error for gl checking */
          DISP gl.des WITH FRAME deal.

          run acng(vgl,true,output vacc).
          find first fun where fun.fun = vacc no-error.
          if avail fun then delete fun.
          CREATE deal.
          deal.regdt = g-today.
          IF INPUT deal.deal EQ ""                              
          THEN deal.deal = vacc.
          deal.grp = v-scugrp.
          DISP deal.deal WITH FRAME deal.
          deal.gl = vgl.
          vnew = TRUE.
     END. /* create */
  END. /* transaction */

upper:
  DO TRANSACTION:
     IF FRAME-VALUE EQ " edit " 
     THEN DO:
          clear frame deal.
          PROMPT deal.deal WITH FRAME deal.
          FIND deal WHERE deal.deal EQ INPUT deal.deal NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.
          vfun = true.
          IF deal.fun NE "" 
          THEN DO:
               vfun = false.
               message "Произведена транзакция - редактирование недопустимо".
               pause.
          END.
      
          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          v-scugrp = deal.grp.
          FIND codfr WHERE codfr.codfr EQ 'secur' 
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal.
          if available gl
          then display gl.des with frame deal.
          v-rate = decimal(deal.ncrc[3] / 100).

          if (deal.maturedt - g-today) > 0 then  
              deal.dval[2] = deal.maturedt      - g-today.

          if (date(deal.info[2]) - g-today) > 0 then          
              deal.dval[3] = date(deal.info[2]) - g-today.

          DISP v-scugrp 
               deal.gl @ vgl 
               deal.deal 
               v-bankl 
               deal.atvalueon[3]
               deal.dval[4] 
               deal.dval[5] 
               days 
               deal.prn
               deal.yield 
               v-crc 
               v-code
               v-rate
               deal.intrate 
               deal.intamt 
               deal.valdt 
               deal.maturedt                
               deal.trm 
               deal.regdt 
               deal.inttype 
               deal.totamt 
               deal.broke 
               deal.rem[3]
               deal.ncrc[1] 
               deal.ncrc[2] 
               deal.arrange
               deal.dval[6]
               deal.info[3]
               deal.dval[1] 
               deal.info[2] 
               deal.dval[2] 
               deal.dval[3] 
              /* deal.atvalueon[1]                
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]*/
          WITH FRAME deal.
          if avail codfr then displ codfr.name[1] with frame deal.

          vedit = TRUE.
     END. /* edit */
     ELSE IF FRAME-VALUE EQ "delete" 
     THEN DO:
          CLEAR FRAME deal.
          PROMPT deal.deal WITH FRAME deal.
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
          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
/*          if available bankl
          then display bankl.name with frame deal.*/
          DISP deal.gl @ vgl 
               deal.deal 
               v-bankl 
               deal.atvalueon[3] 
               deal.dval[4] 
               deal.dval[5] 
               days 
               deal.prn 
               deal.yield
               deal.intrate 
               deal.intamt 
               deal.valdt 
               deal.maturedt 
               deal.trm
               deal.regdt 
               deal.inttype 
               deal.totamt 
               deal.broke 
               deal.rem[3] 
               /*codfr.name[1]*/
               deal.ncrc[1] 
               deal.ncrc[2] 
               deal.arrange 
               deal.dval[6]
               deal.info[3]
               deal.dval[1] 
               deal.info[2] 
               deal.dval[2] 
               deal.dval[3] 
              /* deal.atvalueon[1] 
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]*/
          WITH FRAME deal.
          if avail codfr then displ codfr.name[1] with frame deal.

          vans = false.
          message "Удалить сделку " input deal.deal " ? (Да/Нет)" update vans.
          IF vans 
          then do:
               find scu where deal.deal = scu.scu no-error.
               if avail scu then do:
                 find first jl where jl.acc = scu.scu no-lock no-error.
                 if avail jl then do:
                      message "По счету " scu.scu " была произведена транзакция!  Удаление невозможно! " view-as alert-box .
                      pause.
                      UNDO, RETRY.
                 end.
                 message 'no jl avail!!!' view-as alert-box.
                delete scu.
               end.
               DELETE deal.
               message 'Сделка успешно удалена!' view-as alert-box.
               clear frame deal.
          end.
     END. /* delete */
     ELSE IF FRAME-VALUE EQ " quit " 
     THEN RETURN.
     ELSE IF FRAME-VALUE EQ " print" 
     THEN DO:
          PROMPT deal.deal WITH FRAME deal.
          FIND deal WHERE deal.deal EQ INPUT deal.deal NO-ERROR.
          IF NOT AVAIL deal THEN
          DO:
            message "Не найдена сделка " input deal.deal.
            pause.
            UNDO, RETRY.
          END.

          output to rpt.img .

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          if available gl
          then display gl.des with frame deal.
/*          if available bankl
          then display bankl.name with frame deal.*/
          v-rate = decimal(deal.ncrc[3] / 100). 
          v-scugrp = deal.grp.
       DISP    v-scugrp 
               deal.gl @ vgl 
               deal.deal 
               v-bankl 
               deal.atvalueon[3]
               deal.dval[4] 
               deal.dval[5] 
               days 
               deal.prn
               deal.yield 
               v-crc 
               v-code
               v-rate
               deal.intrate 
               deal.intamt 
               deal.valdt 
               deal.maturedt 
               deal.trm
               deal.regdt 
               deal.inttype 
               deal.totamt 
               deal.broke 
               deal.rem[3] 
               deal.ncrc[1]
               deal.ncrc[2]
               deal.arrange 
               deal.dval[6]
               deal.info[3]
               deal.dval[1] 
               deal.info[2] 
               deal.dval[2] 
               deal.dval[3] 
            /*   deal.atvalueon[1] 
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]*/
          WITH FRAME deal.
          output close.
          pause 0.
          run menu-prt('rpt.img').
/*          vans = false.
          message "Распечатать сделку " input deal.deal " (Да/Нет)" update vans.
          IF NOT vans 
          THEN UNDO, RETRY.*/
          s-deal = deal.deal.
         /* PAUSE 0.
          RUN dealfrm.*/
          PAUSE 0.
     END. /* print */

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
                    display v-crc v-code with frame deal.
               end.     

          end. 
          if deal.intamt > 0 and deal.prn > 0 and deal.intrate > 0 and 
             deal.trm > 0
          then days = deal.prn * deal.intrate * deal.trm / 
                      (100 * deal.intamt).
          display days with frame deal.
          v-bankl = deal.bank.
          if deal.inttype = ? or trim(deal.inttype) = ""
          then do:
               deal.inttype = "A".
               display deal.inttype with frame deal.
          end. 

         if vedit and not vfun then do:

               
               
               UPDATE deal.dval[1] WITH FRAME deal.
               UPDATE deal.info[2] WITH FRAME deal.

               deal.dval[2] = deal.maturedt      - g-today.
               deal.dval[3] = date(deal.info[2]) - g-today.

               UPDATE deal.dval[2] WITH FRAME deal.
               UPDATE deal.dval[3] WITH FRAME deal.
               leave upper.
         end.



          FIND gl WHERE gl.gl EQ deal.gl.
          update v-scugrp with frame deal.
          if frame deal v-scugrp entered
          then do:
               find scugrp where scugrp.scugrp = v-scugrp no-lock no-error.
               if not available scugrp
               then undo,retry.
               deal.grp = v-scugrp.
               deal.gl = scugrp.gl.
               find gl where gl.gl = deal.gl no-lock no-error.
               if not available gl
               then do:
                    message "Не найден счет " vgl " в Главной Книге".
                    pause.
                    undo,retry.
               end.
               vgl = gl.gl.
               display vgl gl.des with frame deal.
          end.



          UPDATE v-bankl WITH FRAME deal.
          if frame deal v-bankl entered 
          then do:
               deal.valdt = ?.
               display deal.valdt with frame deal.
               deal.bank = v-bankl.
               FIND bankl WHERE bankl.bank EQ v-bankl NO-ERROR.
/*               IF AVAIL bankl 
               THEN DISP bankl.name WITH FRAME deal.*/
               IF NOT AVAIL bankl then  DO:
                    message "Банк " v-bankl " не найден в справочнике bankl".
                    pause.
                    UNDO, RETRY.
               END.
          end. 
          UPDATE deal.atvalueon[3] with frame deal.
          UPDATE deal.dval[4] with frame deal.
          UPDATE deal.dval[5] with frame deal.                
          UPDATE deal.prn format "z,zzz,zzz,zzz,zz9.99"
                 VALIDATE (prn NE 0 , " ") WITH FRAME deal.
          do on error undo,retry:
             update v-crc with frame deal.
             find crc where crc.crc = v-crc no-lock.
             v-code = crc.code.
             display v-code with frame deal.
            if v-crc <> 1 then update v-rate with frame deal.
             deal.ncrc[3] = v-rate * 100.
          end.   
          if deal.regdt = ?
          then deal.regdt = g-today.
          if deal.valdt = ? or frame deal v-bankl entered or 
             frame deal v-crc entered
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
               if frame deal v-bankl entered or frame deal v-crc entered
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
                 /*   display deal.atvalueon[1]
                            deal.atvalueon[2]
                            deal.atmaton[1]
                            deal.atmaton[2] with frame deal.*/
               end. 
          end.                 
          UPDATE deal.regdt with frame deal.
         if vnew then update deal.valdt with frame deal.
          update deal.maturedt WITH FRAME deal.
          deal.trm = deal.maturedt - deal.valdt.
          display deal.trm with frame deal.
          UPDATE deal.intrate format "zz9.9999" WITH FRAME deal.
    
          update deal.inttype WITH FRAME deal.
          UPDATE days WITH FRAME deal.

          deal.intamt = deal.prn * deal.intrate * deal.trm / (days * 100).
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
          END. 
          DISP deal.totamt format "z,zzz,zzz,zzz,zz9.99"
               deal.yield WITH FRAME deal.
          UPDATE deal.broke WITH FRAME deal.
          IF deal.broke NE " " 
          THEN DO:
               UPDATE deal.rem[3] WITH FRAME deal.
           message deal.rem[3]. pause 400.
          FIND codfr WHERE codfr.codfr EQ 'secur' 
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal.
/*               deal.brkgfee = deal.prn * deal.brkg * deal.trm / (days * 100).
               DISP deal.brkgfee WITH FRAME deal.*/
               UPDATE deal.ncrc[1] WITH FRAME deal.
               UPDATE deal.ncrc[2] WITH FRAME deal.
               UPDATE deal.arrange WITH FRAME deal.
          END.

      find sub-cod where sub-cod.sub = 'scu' and 
            sub-cod.acc = deal.deal  and sub-cod.d-cod = 'secek'  no-error.
     if not available sub-cod  then do:
      create sub-cod. 
      sub-cod.sub = 'scu'. 
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
      
        /*  IF gl.type EQ "L" 
          THEN DO:
             /*  UPDATE deal.atvalueon[1]
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
               */
             /*  DO ON ERROR UNDO,RETRY:
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
               END. */
               deal.atmaton[2] = dfb.name.
               DISPLAY deal.atmaton[2] 
                       deal.matfrb 
                       deal.atmaton[3]
               WITH FRAME deal.
               UPDATE deal.matfrb 
                      deal.atmaton[3]
               WITH FRAME deal.
          END.*/
        /*  ELSE DO:
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
             /*  DO ON ERROR UNDO,RETRY:
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
               END. */
               deal.atmaton[2] = dfb.name.
               DISPLAY deal.atmaton[2] WITH FRAME deal.
               UPDATE deal.matfrb 
                      deal.atmaton[3]
               WITH FRAME deal.
          END. */ /* if gl.type eq "A" */
        /*  UPDATE deal.rem[1] deal.rem[2] WITH FRAME deal.
          deal.who = USERID('bank').
          deal.tim = TIME.*/
    vdeal = deal.deal. 
                         UPDATE deal.dval[6]  WITH FRAME deal.
                         UPDATE deal.info[3]  WITH FRAME deal.
                         UPDATE deal.dval[1]  WITH FRAME deal.
                         UPDATE deal.info[2]  WITH FRAME deal.
                         deal.dval[2] = deal.maturedt      - g-today.
                         deal.dval[3] = date(deal.info[2]) - g-today.
                         UPDATE deal.dval[2]  WITH FRAME deal.
                         UPDATE deal.dval[3]  WITH FRAME deal.
                         
     run dealval2.
     
     END. /* vnew or vedit */
  END. /* transaction */
END. /* repeat */


