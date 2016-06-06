/* deal.p
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
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       24/11/03 nataly была доработана форма вывода данных при отсутствии кодификатора codfr
       22.12.03 nataly вставлена проверка на группу счета
       31.12.03 nataly была добавлена проверка на sub-cod
       18.03.04 nataly добавлено автоматическая генерация счета fun для тенговых сделок + генерация проводки для счетов 2-го класса
       07.04.2004 nadejda - исправлено обновление статуса после проводки
       30.06.2004 tsoy - Партнер берется из справочника конрагентов добавлено поле тикет
       31.08.2004 tsoy - Добавил поле N номер аккредитива
       21.01.2004 u00121 - вынес счета ARP в переменную sysc = dealac
       01/03/2005 nataly - добавлено fun.basedy = days
       02/12/08 marinav - валюта 11 на  3
*/

/* deal.p
   оформление межбанковской сделки
   изменения от 13.10.2000 - новый deal.f */
 
   
{mainhead.i MMD}

DEF NEW SHARED VAR s-deal LIKE deal.deal.

DEF VAR vyield LIKE deal.yield.
DEF VAR vnew AS LOG.
DEF VAR vedit AS LOG.
DEF VAR vgl LIKE gl.gl.
DEF VAR vacc LIKE deal.deal.
DEF VAR fv AS cha.
DEF VAR inc AS INT.
DEF VAR vans AS LOG.
DEF VAR vnxt AS INT.
DEF VAR vseoul AS LOG.
DEF VAR vbaseday LIKE sysc.inval.
DEF VAR scrc LIKE crc.crc.
define variable v-crc like crc.crc.
define variable v-code like crc.code.
define variable v-bankl like bankl.bank.
define variable v-weekbeg as integer init 2.
define variable v-weekend as integer init 6.
DEF VAR cmd AS cha FORM "x(6)" EXTENT 5
  INIT ["CREATE", " EDIT ", "DELETE", " PRINT", " QUIT "].
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 360.
DEF VAR v-deal LIKE deal.deal.
define variable v-fungrp like fungrp.fungrp.
def new shared var s-lgr like lgr.lgr.

def var vparam as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".
def var v-jh as integer.
def  new shared var s-jh like jh.jh.
DEFINE var code AS integer.

def var v-arp as char.
def var v-crc1 as integer.
def var arpKZT as char. /*init "002904072".*/
def var arpUSD as char. /*init "000076368".*/
def var arpEUR as char. /*init "000076669".*/
def var arpRUR as char. /*init "000076070".*/

/*u00121 21/01/05*****************************************/
def var i as int.
find first sysc where sysc = 'dealac' no-lock no-error.
if avail sysc then
do:
    do i = 1 to num-entries(sysc.chval):
        if lookup("1",entry(i,sysc.chval,";")) > 0  then
                arpKZT = entry(2,entry(i,sysc.chval),";").
        if lookup("2",entry(i,sysc.chval,";")) > 0  then
                arpUSD = entry(2,entry(i,sysc.chval),";").
        if lookup("4",entry(i,sysc.chval,";")) > 0  then
                arpRUR = entry(2,entry(i,sysc.chval),";").
        if lookup("3",entry(i,sysc.chval,";")) > 0  then
                arpEUR = entry(2,entry(i,sysc.chval),";").
    end.
end.
else 
/*u00121 21/01/05*****************************************/	


def var v-grp as char.


{deal.f}
                                                                            
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

on help of deal.broke in frame deal do: run h-fbank.  
                    deal.broke = return-value. 
                    displ deal.broke with frame  deal.
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
             update v-fungrp with frame deal.
             find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
             if not available fungrp or lookup(string(v-fungrp), v-grp) > 0 
             then do:
               message 'Выбранная группа является группой РЕПО!'.
               undo,retry.
             end.
             if not available fungrp
             then undo,retry.
             vgl = fungrp.gl.
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
          deal.grp = v-fungrp.
          DISP deal.deal WITH FRAME deal.
          deal.gl = vgl.
          vnew = TRUE.
     END. /* create */
  END. /* transaction */
  
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
          IF deal.fun NE "" 
          THEN DO:
               message "Произведена транзакция - редактирование недопустимо".
               /* {mesg.i 0268}.  */
               pause.
               UNDO, RETRY.
          END.
      
          v-fungrp = deal.grp.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
              if not available fungrp or  lookup(string(deal.grp), v-grp) > 0
             then do:
               message 'Набранный счет относится к группе РЕПО!' view-as alert-box.
               undo,retry.
             end.

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          FIND codfr WHERE codfr.codfr EQ 'secur' 
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal.
          if available gl
          then display gl.des with frame deal.
          if available bankl
          then display bankl.name with frame deal.
          DISP v-fungrp 
               deal.gl @ vgl 
               deal.deal 
               v-bankl 
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
               deal.info[1]
               deal.rem[3]
    /*           codfr.name[1]*/
               deal.ncrc[1] 
               deal.ncrc[2] 
               deal.arrange 
               deal.atvalueon[1]                
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]
          WITH FRAME deal.
          vedit = TRUE.
        if avail codfr then displ codfr.name[1] with frame deal.
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

          v-fungrp = deal.grp.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
             if not available fungrp or  lookup(string(deal.grp), v-grp) > 0
             then do:
               message 'Набранный счет относится к группе РЕПО!' view-as alert-box.
               undo,retry.
             end.

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          if available bankl
          then display bankl.name with frame deal.
          DISP deal.gl @ vgl 
               deal.deal 
               v-bankl 
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
               deal.info[1]
               deal.rem[3] 
              /* codfr.name[1]*/
               deal.ncrc[1] 
               deal.ncrc[2] 
               deal.arrange 
               deal.atvalueon[1] 
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]
          WITH FRAME deal.
          if avail codfr then displ codfr.name[1] with frame deal.
          vans = false.
          message "Удалить сделку " input deal.deal " ? (Да/Нет)" update vans.
          IF vans 
          then do:
               DELETE deal.
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

          v-fungrp = deal.grp.
          find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
              if not available fungrp or  lookup(string(deal.grp), v-grp) > 0
             then do:
               message 'Набранный счет относится к группе РЕПО!' view-as alert-box.
               undo,retry.
             end.

          FIND bankl WHERE bankl.bank EQ deal.bank no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-error.
          if available gl
          then display gl.des with frame deal.
          if available bankl
          then display bankl.name with frame deal.
          DISP deal.gl @ vgl 
               deal.deal 
               v-bankl 
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
               deal.info[1]
               deal.rem[3] 
               deal.ncrc[1]
               deal.ncrc[2]
               deal.arrange 
               deal.atvalueon[1] 
               deal.atvalueon[2]
               deal.atvalueon[3] 
               deal.atmaton[1] 
               deal.atmaton[2]
               deal.atmaton[3] 
               deal.rem[1] 
               deal.rem[2]
          WITH FRAME deal.
          vans = false.
          message "Распечатать сделку " input deal.deal " (Да/Нет)" update vans.
          IF NOT vans 
          THEN UNDO, RETRY.
          s-deal = deal.deal.
          PAUSE 0.
          RUN dealfrm.
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
          FIND gl WHERE gl.gl EQ deal.gl.
          update v-fungrp with frame deal.
          if frame deal v-fungrp entered
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
               display vgl gl.des with frame deal.
          end.
          UPDATE v-bankl WITH FRAME deal.
          if frame deal v-bankl entered 
          then do:
               deal.valdt = ?.
               display deal.valdt with frame deal.
               deal.bank = v-bankl.
               FIND bankl WHERE bankl.bank EQ v-bankl NO-ERROR.
               IF AVAIL bankl 
               THEN DISP bankl.name WITH FRAME deal.
               ELSE DO:
                    message "Банк " v-bankl " не найден в справочнике bankl".
                    pause.
                    UNDO, RETRY.
               END.
          end.       
          UPDATE deal.prn format "z,zzz,zzz,zzz,zz9.99"
                 VALIDATE (prn NE 0 , " ") WITH FRAME deal.
          do on error undo,retry:
             update v-crc with frame deal.
             find crc where crc.crc = v-crc no-lock.
             v-code = crc.code.
             display v-code with frame deal.
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
                    if v-fungrp <> 232 then do:
                         deal.atvalueon[1] = dfb.dfb.
                         deal.atvalueon[2] = dfb.name.
                         deal.atmaton[1] = dfb.dfb.
                         deal.atmaton[2] = dfb.name.
                         display deal.atvalueon[1]
                                 deal.atvalueon[2]
                                 deal.atmaton[1]
                                 deal.atmaton[2] with frame deal.
                    end.
               end. 
          end.                 
          UPDATE deal.regdt with frame deal.
          update deal.valdt with frame deal.
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
          UPDATE deal.broke deal.info[1] WITH FRAME deal.
          IF deal.broke NE " " 
          THEN DO:
               UPDATE deal.rem[3] WITH FRAME deal.
          FIND codfr WHERE codfr.codfr EQ 'secur' 
          and codfr.code = deal.rem[3] no-error.
          if available codfr then display codfr.name[1] with frame deal.
/*               deal.brkgfee = deal.prn * deal.brkg * deal.trm / (days * 100).
               DISP deal.brkgfee WITH FRAME deal.*/
               UPDATE deal.ncrc[1] WITH FRAME deal.
               UPDATE deal.ncrc[2] WITH FRAME deal.
               UPDATE deal.arrange WITH FRAME deal.
          END.

          if v-fungrp = 232 then do:
              UPDATE deal.info[3] WITH FRAME deal.
          end.

      find sub-cod where sub-cod.sub = 'fun' and 
            sub-cod.acc = deal.deal and sub-cod.d-cod = 'secek'   no-error.
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
      
          IF gl.type EQ "L" 
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
               END.
               deal.atmaton[2] = dfb.name.
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
          END. /* if gl.type eq "A" */
          UPDATE deal.rem[1] deal.rem[2] WITH FRAME deal.
          deal.who = USERID('bank').
          deal.tim = TIME.

        if (vnew or vedit) and (v-crc = 1 or v-crc = 2 or v-crc = 3 or v-crc = 4) then do: /*открытие fun*/
         find fun where fun.fun = deal.deal exclusive-lock no-error.
         if not available fun
         then create fun.
         fun.fun = deal.deal.
         fun.gl = deal.gl.
         find gl where gl.gl eq fun.gl no-lock.
         fun.grp = deal.grp.
         fun.bank = deal.bank.
         find bankl where bankl.bank eq deal.bank no-lock.
         fun.cst = bankl.name.
/*          15/01/04 было заменено для сделок РЕПО  
         fun.cst = deal.atvalueon[3].*/
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
         if gl.type eq "A" 
         then fun.ref = deal.rem[1].
         else fun.ref = deal.rem[2].   
         fun.basedy = days.
       /* append for accrued system by S.Kuzema */
         fun.zalog  = deal.zalog.
         fun.geo    = deal.geo.
         fun.lonsec = deal.lonsec.
         fun.risk   = deal.risk.
         fun.penny  = deal.penny.

         fun.sts = 0.
         release fun.
        end. /*открытие fun*/
         find fun where fun.fun = deal.deal no-lock no-error.
        if vnew and (v-crc = 1 or v-crc = 2 or v-crc = 3 or v-crc = 4) and string(fun.gl) begins '2' then do: /*создание проводки*/
          message "Создать проводку (Да/Нет)?"    update vans.
          IF vans then do:
             /*nazn = '' + string(v-dat3) + ' сумма USD ' +  string(v-sum).*/
             if v-crc = 1 then v-arp = arpKZT.
              else if v-crc = 2 then v-arp = arpUSD.
               else if v-crc = 3 then v-arp = arpEUR.
                else if v-crc = 4 then v-arp = arpRUR.

             vparam = string(fun.amt) + vdel + v-arp + vdel + fun.fun .
             run trxgen("uni0167", vdel, vparam, "FUN", fun.fun, output rcode, output rdes, input-output v-jh). 
          end.
           if rcode ne 0 then do:
             code = 1.
             message " Не удалось сформировать проводку ARP - FUN " fun.fun ", " string(fun.amt) " -> " rdes 
                 view-as alert-box button ok title " ОШИБКА ! ". 
           end.
           else do:
             release jl. release jh.
             
             /* 07.04.2004 nadejda */
             do transaction:
               find current fun exclusive-lock.
               fun.sts = 1.
               find current fun no-lock.
             end.
             
             vans = no.
             message " Создана проводка " v-jh "~n Печатать ваучер ?" view-as alert-box button yes-no title "" update vans.
             if vans then do:
               s-jh =  v-jh.
               run vou_bank(1).
             end.
          end.
        end. /*создание проводки*/
        v-jh = 0.
        clear frame deal.

     END. /* vnew or vedit */
  END. /* transaction */
END. /* repeat */


