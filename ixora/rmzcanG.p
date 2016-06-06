/* rmzcanG.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Удаление/сторнирование 1 и 2 проводки внешнего платежа - не знаю, чем отличается от rmzcano - только что не по-русски
 * RUN
        верхнее меню в пунктах платежной системы
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-...
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08.10.2003 nadejda - удаление специнструкции, наложенной на счет клиента при второй проводке внешнего входящего валютного платежа
        09.10.2003 nadejda - если вторая проводка была блокировкой суммы на транзитном счете валютного контроля, то удаление записи в списке блокированных сумм
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        31/07/2007 madiyar - убрал упоминание удаленной таблицы sta
*/

/* caremin.p */

{global.i}
{lgps.i}
{ps-prmt.i}
DEF var p1 AS log .
DEF var p2 AS log .
DEFINE SHARED var s-remtrz LIKE remtrz.remtrz.
DEF SHARED FRAME remtrz.
DEF NEW SHARED var s-sta as char format "x(2)" label "State".
DEF NEW SHARED var s-rem LIKE rem.rem.
DEF NEW SHARED var s-ref LIKE rem.ref.


DEFINE NEW SHARED var s-jh LIKE jh.jh.
DEFINE NEW SHARED var s-consol LIKE jh.consol init FALSE.
DEFINE NEW SHARED var s-aah as int.
DEFINE NEW SHARED var s-line AS int.
DEFINE NEW SHARED var s-force AS log init TRUE.
DEFINE NEW SHARED var jh5 LIKE remtrz.jh1.
DEFINE NEW SHARED var vjh5 LIKE remtrz.jh2.
DEF NEW SHARED var rem5 LIKE rem.rem.

DEF var cans AS log.
DEF buffer b-jh FOR jh.
DEF buffer b-jl FOR jl.
DEF var djh LIKE jh.jh.
DEF var dvjh LIKE jh.jh.
DEF var v-jhdel AS log.
DEF buffer tgl FOR gl.
DEF var acode LIKE crc.code.
DEF var bcode LIKE crc.code.
def var rcode as int.
def var rdes as cha .
define variable v-sts like jh.sts .

djh = ?.
dvjh = ?.

DEF var ourbank AS char.

FIND sysc WHERE sysc.sysc = "ourbnk" NO-LOCK NO-ERROR .
IF NOT AVAIL sysc OR sysc.chval = "" THEN
DO:
  DISPLAY " This isn't record OURBNK in sysc file !!".
  PAUSE .
  UNDO .
  RETURN .
END.
ourbank = sysc.chval.

FIND sysc WHERE sysc.sysc = "CASHGL" NO-LOCK no-error.

{rmz.f}

DO TRANSACTION :

  FIND remtrz WHERE remtrz.remtrz = s-remtrz EXCLUSIVE-LOCK.
     FIND que WHERE que.remtrz = s-remtrz EXCLUSIVE-LOCK NO-ERROR.
       IF AVAIL  que THEN
       DO:
       que.dw = today.
       que.tw = TIME.
       que.pid = "GD".
       que.con = "W".
       que.rcod = "0".
       que.pri = integer(que.pvar).
       v-text = s-remtrz + " was selected and send by
       route " +
       "( que.pid = " + que.pid + " )" .
        RUN lgps. 
    END.
     release que.


  IF remtrz.jh1 ne ? THEN
  DO:
    jh5 = remtrz.jh1.
    FIND jh WHERE jh.jh eq remtrz.jh1 EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE jh THEN
    remtrz.jh1 = ?.
    ELSE
    DO:
      p1 = FALSE  .
      p2 = NO .
      FOR EACH jl OF jh NO-LOCK :
        IF jl.gl eq sysc.inval THEN
        DO:
          p1 = TRUE .
        END .
        IF jl.sts eq 6 THEN
        DO:
          p2 = TRUE .
        END .
      END .
      IF p1 AND  p2 THEN
      DO:
        MESSAGE "Casher's transaction and sts eq 6 !!! "
          CHR(7) CHR(7) CHR(7).
        PAUSE .
        RETURN.
      END.
      rem5 = substr(jh.party,1,10) .
    END.
  END.

  IF remtrz.jh2 ne ? THEN
  DO:
    vjh5 = remtrz.jh2.
    FIND jh WHERE jh.jh eq remtrz.jh2 EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE jh THEN
    remtrz.jh2 = ?.
  END.
  ELSE
  DO:
    FIND FIRST rem WHERE rem.rem = rem5 EXCLUSIVE-LOCK NO-ERROR .
    IF AVAIL rem THEN
    remtrz.jh2 = rem.vjh .
  END.


  IF remtrz.jh1 eq ?
    THEN
  DO:
    BELL.
    {mesg.i 0214}.
    PAUSE 3.
    UNDO, RETRY.
  END.
  {mesg.i 0823} UPDATE cans.
  IF NOT cans THEN
  UNDO.

  FIND jh WHERE jh.jh eq remtrz.jh1 EXCLUSIVE-LOCK NO-ERROR.
  rem5 = substr(jh.party,1,10) .
  s-jh = remtrz.jh1.
  IF jh.post eq TRUE
    THEN
  DO:
/*
    RUN x-jhnew.
    FIND jh WHERE jh.jh eq s-jh EXCLUSIVE-LOCK NO-ERROR.
    FIND b-jh WHERE b-jh.jh eq remtrz.jh1 EXCLUSIVE-LOCK
      NO-ERROR.
    FOR EACH b-jl OF b-jh:
      IF b-jl.aah ge 0 THEN
      DO:
        CREATE jl.
        jl.jh = jh.jh.
        jl.ln = b-jl.ln.
        jl.who = jh.who.
        jl.jdt = jh.jdt.
        jl.whn = jh.whn.
        jl.sts = b-jl.sts.
        jl.rem[1] = b-jl.rem[1].
        jl.rem[2] = b-jl.rem[2].
        jl.rem[3] = b-jl.rem[3].
        jl.rem[4] = b-jl.rem[4].
        jl.rem[5] = b-jl.rem[5].
        jl.gl = b-jl.gl.
        jl.acc = b-jl.acc.
        jl.dam = b-jl.cam.
        jl.cam = b-jl.dam.
        IF b-jl.dc eq "D" THEN
        jl.dc = "C".
        ELSE
        jl.dc = "D".
        jl.consol = b-jl.consol.
        jl.crc = b-jl.crc.
        FIND gl WHERE gl.gl eq jl.gl NO-ERROR.
        s-force = TRUE.
        {jlupd-r.i}
      END.
    END.
    FIND b-jh WHERE b-jh.jh eq remtrz.jh1 EXCLUSIVE-LOCK
      NO-ERROR.
    jh.party = " for cancel " + string(b-jh.jh).
    djh = jh.jh.
    b-jh.party = TRIM(b-jh.party) + " cancel by "
      + string(jh.jh).
    jh.crc = b-jh.crc.
   */
   djh = ? .
   run trxstor(input s-jh, input 6, output djh, output rcode, output rdes).
        if rcode ne 0 then do:
               message rdes.
               pause . 
               undo, return .
           end.
    
    IF remtrz.jh1 eq remtrz.jh2 THEN
    remtrz.jh2 = ?.
    remtrz.jh1 = ?.
    v-text = "1TRX# " + string(s-jh) + " cancel was done for "
    + s-remtrz + " TRX# " + string(djh).
    RUN lgps.
  END.
  ELSE
  DO:
  /*
    RUN jlcopy.
    v-jhdel = YES.
    FOR EACH jl OF jh:
      IF jl.aah ge 0 THEN
      DO:
        FIND gl OF jl.
        {jlupd-f.i -}
        DELETE jl.
      END.
      ELSE
      v-jhdel = NO.
    END.
    */
    do transaction:
       find jh where jh.jh = s-jh no-error.
       if avail jh then v-sts = jh.sts.
       else v-sts = 0.
       run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                            message rdes.
                            undo, return .
                end.
            run trxdel (input s-jh, input true, output rcode, output rdes). 
                if rcode ne 0 then do:
                          message rdes.
                          if rcode = 50 then do:
                                             run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                                             return.
                                        end.     
                          else undo, return.
                end.
 
    remtrz.jh1 = ?.
    /*     if remtrz.sbank <> ourbank then remtrz.jh2 = ?.   */
    remtrz.rwho = USERID('bank').
    /*  ????????   rem.cwhn = today.        */
    remtrz.rtim = TIME.
    v-text = "1TRX delete was done for " + s-remtrz .
    RUN lgps.
    end. /* transaction */
  END.
  IF remtrz.jh2 ne ? THEN
  DO:
    FIND jh WHERE jh.jh eq remtrz.jh2 EXCLUSIVE-LOCK NO-ERROR.
    s-jh = remtrz.jh2.

      /* 07.10.2003 nadejda - снять специнструкцию по второй проводке, наложенную валютным контролем - если найдется :-) */
      if remtrz.tcrc <> 1 then do:
        find first jl where jl.jh = remtrz.jh2 and jl.sub = "cif" and jl.dc = "c" no-lock no-error.
        if avail jl then run jou-aasdel (jl.acc, remtrz.amt, remtrz.jh2).
        else do:
          /* если это была блокировка на транзитном счете - удалить запись из таблицы блокированных сумм */
          find first jl where jl.jh = remtrz.jh2 and jl.sub = "arp" and jl.dc = "c" no-lock no-error.
          if avail jl then run rmzcan-vcblk (remtrz.remtrz).
        end.
      end.
      /************************************/
    
    IF jh.post eq TRUE
      THEN
    DO:
    /*
      RUN x-jhnew.
      FIND jh WHERE jh.jh eq s-jh EXCLUSIVE-LOCK NO-ERROR.
      FIND b-jh WHERE b-jh.jh eq remtrz.jh2 EXCLUSIVE-LOCK NO-ERROR.
      FOR EACH b-jl OF b-jh:
        IF b-jl.aah ge 0 THEN
        DO:
         
          CREATE jl.
          jl.jh = jh.jh.
          jl.ln = b-jl.ln.
          jl.who = jh.who.
          jl.jdt = jh.jdt.
          jl.whn = jh.whn.
          jl.sts = b-jl.sts.
          jl.rem[1] = b-jl.rem[1].
          jl.rem[2] = b-jl.rem[2].
          jl.rem[3] = b-jl.rem[3].
          jl.rem[4] = b-jl.rem[4].
          jl.rem[5] = b-jl.rem[5].
          jl.gl = b-jl.gl.
          jl.acc = b-jl.acc.
          jl.dam = b-jl.cam.
          jl.cam = b-jl.dam.
          IF b-jl.dc eq "D" THEN
          jl.dc = "C".
          ELSE
          jl.dc = "D".
          jl.consol = b-jl.consol.
          jl.crc = b-jl.crc.
          FIND gl WHERE gl.gl eq jl.gl no-lock NO-ERROR.
          s-force = TRUE.
          {jlupd-r.i}
        END.
      END.
      FIND b-jh WHERE b-jh.jh eq remtrz.jh2 EXCLUSIVE-LOCK
        NO-ERROR.
      jh.party = " for cancel " + string(b-jh.jh).
      dvjh= jh.jh.
      b-jh.party = TRIM(b-jh.party) + "cancel by "
        + string(jh.jh).
      jh.crc = b-jh.crc.
      */
      
      dvjh = ? .
   run trxstor(input s-jh, input 6, output dvjh, output rcode, output rdes).
        if rcode ne 0 then do:
               message rdes.
               pause . 
               undo, return .
        end.
    
      remtrz.jh2 = ?.
      v-text = "2TRX# " + string(s-jh) + " cancel was done for " +
      s-remtrz + " TRX# " + string(dvjh).
      RUN lgps.
    END.
    ELSE
    DO:
      do transaction:
                run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                            message rdes.
                            undo, return .
                end.
            run trxdel (input s-jh, input true, output rcode, output rdes). 
                if rcode ne 0 then do:
                          message rdes.
                          if rcode = 50 then return.
                          else undo, return.
                end.
       /*
      RUN jlcopy.
      v-jhdel = YES.
      FOR EACH jl OF jh:
        IF jl.aah ge 0 THEN
        DO:
          FIND gl OF jl.
          {jlupd-f.i -}
          DELETE jl.
        END.
        ELSE
        v-jhdel = NO.
      END.
      */

      remtrz.jh2 = ?.
      remtrz.rwho = USERID('bank').
      /*           rem.cwhn = today.  ???????  */
      remtrz.rtim = TIME.
      v-text = "2TRX delete was done for " + s-remtrz .
      RUN lgps.
      end. /* transaction */ 
    END.
  END.
  DISPLAY remtrz.jh1 remtrz.jh2 WITH FRAME remtrz.
  PAUSE 0 .
  FIND FIRST rem WHERE rem.rem = rem5 EXCLUSIVE-LOCK NO-ERROR .
  IF AVAIL rem THEN
  DO:
    FIND FIRST cursta WHERE substr(cursta.ref,1,22) = substr(rem.ref,1,22)
      EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL cursta THEN
    DO :
      s-sta = "09".
      s-ref = cursta.ref.
      s-rem = rem.rem.
      RUN csin.
    END.
    RUN delecon.
    DELETE rem .
    v-text = rem5 + " delete was done for " + s-remtrz .
    RUN lgps.
  END .

END.
PAUSE 0 .


DO TRANS .
  IF djh ne ? THEN
  DO:
    s-jh = djh .
    RUN x-jlvou.
    FOR EACH jl WHERE jl.jh = djh EXCLUSIVE-LOCK .
      jl.sts = 6.
    END .
    jh.sts = 6 .
  END.
  IF dvjh ne ? THEN
  DO:
    s-jh = dvjh.
    RUN x-jlvou.
    FOR EACH jl WHERE jl.jh = dvjh EXCLUSIVE-LOCK .
      jl.sts = 6.
    END .
    jh.sts = 6 .
  END.
END .

MESSAGE " Cancel was done successfully ! " .
PAUSE.


