/* funiss.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* funiss.p
*/

{mainhead.i }  /*  FUND MAINTENANCE  */

DEF NEW SHARED VAR s-bank LIKE bank.bank.
DEF NEW SHARED VAR s-fun LIKE fun.fun.  /* acct # */
DEF NEW SHARED VAR s-jh LIKE jh.jh.
DEF NEW SHARED VAR s-gl LIKE gl.gl.     /* payment gl # */
DEF NEW SHARED VAR s-acc LIKE jl.acc.   /* payment acct # */
DEF NEW SHARED VAR s-consol LIKE jh.consol INITIAL FALSE.
DEF NEW SHARED VAR s-aah  as int.
DEF NEW SHARED VAR s-line AS INT.
DEF NEW SHARED VAR s-force AS LOG INITIAL FALSE.
DEF NEW SHARED VAR vfun LIKE fun.fun.

DEF BUFFER b-jl FOR jl.
DEF BUFFER b-bank FOR bank.
DEF BUFFER b-jh FOR jh.

DEF VAR vrem AS cha.
DEF VAR vamt LIKE jl.dam.
DEF VAR vln AS INT.
DEF VAR v AS INT FORMAT "z".
DEF VAR vans AS LOG INIT FALSE.
DEF VAR ans AS LOG.
DEF VAR cmd AS cha FORMAT "x(6)" EXTENT 9 INITIAL
  ["NEXT","EDIT","ISSUE","SETTLE","HIST","PRINT","CNCL","DELETE","QUIT"].
DEF VAR vnew AS LOG.
DEF VAR vdfb LIKE bank.bank.
DEF VAR vdfbnm LIKE bank.name.
DEF VAR vdfbacct AS CHAR FORMAT "x(40)".
DEF VAR vacc LIKE fun.fun.
DEF VAR vjh LIKE jh.jh.

DEF NEW SHARED FRAME mk.
DEF NEW SHARED FRAME ms.

/* W/T */
DEF NEW SHARED VAR s-jln LIKE jl.ln.
DEF NEW SHARED VAR s-amt LIKE jl.cam.
DEF NEW SHARED VAR kbank LIKE bank.bank.
DEF NEW SHARED VAR vbank LIKE bank.bank.
DEF NEW SHARED VAR vcom  LIKE wf.com.
DEF NEW SHARED VAR vscom  LIKE wf.scom.
DEF NEW SHARED VAR vcdt   LIKE wf.cdt.
DEF NEW SHARED VAR vtpy   LIKE wf.tpy.
DEF NEW SHARED VAR vtpyac LIKE wf.tpyac.
DEF NEW SHARED VAR srem AS CHAR FORMAT "x(75)" EXTENT 5.
DEF NEW SHARED VAR wfln LIKE wf.ln.
DEF VAR kans AS LOG INIT TRUE.
{newfun.f}

FORM "DEBIT  AMOUNT :" fun.dam[1] "INTEREST RCVD:" fun.cam[2] SKIP
  "CREDIT AMOUNT :" fun.cam[1] "INTEREST PAID:" fun.dam[2]
  WITH CENTERED NO-BOX NO-LABEL ROW 19 FRAME funpay OVERLAY.
/*
*/
FORM cmd
  WITH CENTERED NO-BOX NO-LABEL ROW 21 FRAME slct.

FORM b-jl.gl b-jl.who b-jl.jdt b-jl.jh jh.post SKIP SPACE(30)
  b-jl.dam b-jl.cam WITH DOWN FRAME mk.
FORM vjh b-jl.gl b-jl.who b-jl.jdt b-jl.dam b-jl.cam jh.post
  WITH DOWN FRAME ms.

VIEW FRAME fun.
VIEW FRAME slct.

outer:
REPEAT:
  vnew = FALSE.
  PROMPT-FOR fun.fun WITH FRAME fun.
  FIND fun USING fun.fun NO-ERROR.
  IF NOT AVAILABLE fun
    THEN
  DO:
    BELL.
    {mesg.i 5801}
    UPDATE ans.
    IF ans EQ FALSE THEN
    NEXT.
    CREATE fun.
    UPDATE fun.crc fun.basedy WITH FRAME fun.
    UPDATE fun.gl WITH FRAME fun.
    FIND gl WHERE gl.gl EQ fun.gl.
    {mesg.i 0913}.
    UPDATE fun.fun WITH FRAME fun
    EDITING:
      READKEY.
      IF KEYFUNCTION(LASTKEY) EQ "GO"
        THEN
      DO:
        FIND nmbr WHERE nmbr.code = gl.code.
        {nmbr-acc.i nmbr.prefix
          nmbr.nmbr
          nmbr.fmt
          nmbr.sufix}
        DISPLAY vacc @ fun.fun WITH FRAME fun.
        /* s-acc = vacc. */
        nmbr.nmbr = nmbr.nmbr + 1.
        LEAVE.
      END.  /* do: end */
      ELSE
      APPLY LASTKEY.
    END. /* editing: end */
    /*
    assign fun.fun.
    */
    vnew = TRUE.
  END.

  FIND gl WHERE gl.gl EQ fun.gl NO-ERROR.
  IF AVAILABLE gl THEN
  DISPLAY gl.sname WITH FRAME fun.
  DISPLAY fun.crc fun.basedy fun.gl WITH FRAME fun.

  IF fun.bank NE "" THEN
  DO:
    FIND bank WHERE bank.bank EQ fun.bank NO-ERROR.
    IF AVAILABLE bank THEN
    DISPLAY bank.name @ fun.cst
      WITH FRAME fun.
  END.
  DISPLAY fun.grp fun.bank
    fun.rdt fun.ddt[5] fun.duedt fun.trm
    WITH FRAME fun.
  DISPLAY /* fun.iddt  */
    fun.amt fun.intrate fun.interest fun.itype
    WITH FRAME fun.

  IF fun.dfb NE "" THEN
  DO:
    FIND bank WHERE bank.bank EQ fun.dfb NO-ERROR.
    vdfbnm = bank.name.
    vdfbacct = bank.acct.
    DISPLAY fun.dfb vdfbnm vdfbacct WITH FRAME fun.
  END.

  IF fun.bank NE "" THEN
  DO:
    FIND bank WHERE bank.bank EQ fun.bank.
    IF fun.acct EQ "" THEN
    fun.acct = bank.acct.
    FIND bank WHERE bank.bank EQ fun.tbank.
    IF AVAILABLE bank THEN
    DISPLAY fun.tbank bank.name @ fun.crbank fun.acct
      WITH FRAME fun.
  END.

  fun.who = g-ofc.
  DISPLAY fun.who WITH FRAME fun.
  /*
  find last jl
  where jl.acc eq fun.fun.
  display jl.jh @ s-jh with frame fun.
  */
  /* display fun.rmk with frame newfun. */
  DISPLAY fun.rem WITH FRAME fun.
  DISPLAY fun.dam[1] fun.cam[2] fun.cam[1] fun.dam[2]
    WITH FRAME funpay.

  DISPLAY cmd AUTO-RETURN WITH FRAME slct.
  s-fun = fun.fun.
  s-gl = fun.gl.


  inner:
  REPEAT:
    DISPLAY cmd AUTO-RETURN WITH FRAME slct.
    IF vnew EQ FALSE
      THEN
    CHOOSE FIELD cmd WITH FRAME slct.

    IF FRAME-VALUE EQ "EDIT" OR vnew EQ TRUE
      THEN
    DO:
      vnew = TRUE.
      fun.ddt[5] = g-today.
      UPDATE fun.crc fun.basedy WITH FRAME fun.
      UPDATE  fun.bank VALIDATE(bank EQ "" OR
        CAN-FIND(bank WHERE bank.bank EQ bank),"")
        WITH FRAME fun.
      FIND bank WHERE bank.bank EQ fun.bank.
      DISPLAY bank.name @ fun.cst WITH FRAME fun.
      fun.cst = bank.name.
      UPDATE
        fun.cst fun.amt fun.ddt[5]
        WITH FRAME fun.
      fun.rdt = fun.ddt[5].
      UPDATE fun.rdt
        WITH FRAME fun.
      IF fun.duedt EQ ? THEN
      fun.duedt = g-today + 1.
      UPDATE fun.duedt
        WITH FRAME fun.
      REPEAT:
        FIND hol WHERE hol.hol EQ fun.duedt NO-ERROR.
        IF NOT AVAILABLE hol AND WEEKDAY(fun.duedt) GE 2 AND
          WEEKDAY(fun.duedt) LE 6
          THEN
        LEAVE.
        ELSE
        fun.duedt = fun.duedt + 1.
      END.
      DISPLAY fun.duedt WITH FRAME fun.
      fun.trm = fun.duedt - fun.rdt.
      UPDATE fun.trm  WITH FRAME fun.
      fun.duedt = fun.rdt + fun.trm.
      REPEAT:
        FIND hol WHERE hol.hol EQ fun.duedt NO-ERROR.
        IF NOT AVAILABLE hol AND WEEKDAY(fun.duedt) GE 2 AND
          WEEKDAY(fun.duedt) LE 6
          THEN
        LEAVE.
        ELSE
        fun.duedt = fun.duedt + 1.
      END.
      fun.trm = fun.duedt - fun.rdt.
      DISPLAY fun.duedt fun.trm WITH FRAME fun.
      /* -- */

      FIND gl WHERE gl.gl EQ fun.gl.
      fun.grp = gl.grp.

      UPDATE fun.intrate WITH FRAME fun.

      fun.interest = fun.amt * (fun.duedt - fun.rdt)
      * fun.intrate / fun.basedy / 100.
      FIND crc OF fun.
      fun.interest = ROUND(fun.interest,crc.decpnt).

      UPDATE  fun.interest WITH FRAME fun.
      UPDATE fun.itype WITH FRAME fun.

      DISPLAY /* fun.iddt */
        fun.intrate fun.itype fun.interest
        WITH FRAME fun.

      UPDATE fun.dfb WITH FRAME fun.
      FIND bank WHERE bank.bank EQ fun.dfb.
      vdfbnm = bank.name.
      vdfbacct = bank.acct.
      DISPLAY fun.dfb vdfbnm vdfbacct WITH FRAME fun.

      FIND bank WHERE bank.bank EQ fun.bank.
      IF bank.acc = " " AND bank.crbank = " " THEN
      DO:
        fun.tbank = bank.bank.
        fun.crbank = bank.name.
      END.
      ELSE
      IF bank.acc = " " AND bank.crbank NE " " THEN
      fun.crbank = bank.name.
      ELSE
      IF bank.acc NE " " AND bank.crbank EQ " " THEN
      fun.tbank = bank.acc .
      ELSE
      DO:
        fun.tbank = bank.acc.
        fun.crbank = bank.crbank.
      END.
      fun.acct = bank.acct.

      UPDATE fun.tbank WITH FRAME fun.
      FIND bank WHERE bank.bank EQ fun.tbank.
      DISPLAY fun.tbank
        bank.name @ fun.crbank fun.acct WITH FRAME fun.
      fun.crbank = bank.name.
      UPDATE fun.crbank fun.acct WITH FRAME fun.
      fun.who = g-ofc.

      UPDATE fun.who WITH FRAME fun.
      /* update fun.rmk with frame newfun. */
      UPDATE fun.rem WITH FRAME fun.
      UPDATE fun.dam[1] fun.cam[2] fun.cam[1] fun.dam[2]
        WITH FRAME funpay.
      s-fun = fun.fun.
      s-gl = fun.gl.
      NEXT outer.
    END.

    ELSE
    IF FRAME-VALUE EQ "QUIT" THEN
    RETURN.
    ELSE
    IF FRAME-VALUE EQ "DELETE "
      THEN
    DO:
      {mesg.i 0824} UPDATE ans.
      IF ans EQ FALSE THEN
      NEXT.
      DELETE fun.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "NEXT"
      THEN
    DO:
      CLEAR FRAME fun.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "ISSUE"
      THEN
    DO :

      IF NOT(fun.dam[1] EQ 0 AND fun.cam[1] EQ 0)
        THEN
      DO:
        {mesg.i 5201}.
        UNDO, RETRY.
      END.

      s-amt = fun.amt.
      srem[1] = " ".
      srem[2] = " ".
      srem[3] = " ".
      srem[4] = " ".
      srem[5] = " ".
      FIND gl WHERE gl.gl = fun.gl .
      FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
      IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
      DO:
        /* 14/12/95 у нас sysc.loval = false всегда!!!-------
        FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.
        IF sysc.chval = fun.dfb AND s-amt GT 0 AND gl.type = "A"
          THEN
        DO TRANSACTION:

          {mesg.i 0985} UPDATE kans.
          IF kans = FALSE THEN
          UNDO,LEAVE.
          HIDE ALL.
          FIND bank WHERE bank.bank = fun.bank NO-LOCK.
          vtpy = bank.name.
          vcdt = fun.crbank.
          vtpyac = fun.acct.
          kbank = fun.bank.
          vbank = fun.tbank.
          vcom  = "REF:" + s-fun.
          RUN s-dbgla.
          IF LASTKEY = KEYCODE ( "PF4" ) OR LASTKEY = KEYCODE ( "F4" ) THEN
          UNDO, NEXT outer.
          HIDE ALL.
        END.  -------------------------------------------*/
      END.
      RUN s-funiss.
      PAUSE 0.
      DISPLAY s-jh WITH FRAME fun.
      VIEW FRAME heading.
      VIEW FRAME fun.
      VIEW FRAME slct.
      DISP fun.dam[1] fun.dam[2] fun.cam[1] fun.cam[2] WITH FRAME funpay.
      PAUSE 0.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "SETTLE"
      THEN
    DO:

      IF fun.dam[1] - fun.cam[1] EQ 0 THEN
      DO:
        {mesg.i 5202}.
        UNDO, RETRY.
      END.
      FIND gl WHERE gl.gl = fun.gl .
      /* ----------------------------------------------------
      FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR. 
      похоже, что этот оператор лишний - значение из sysc не
      исплз. , а далее поиск нового sysc  AGA -------------*/
      IF fun.itype = "A" THEN
      s-amt = fun.amt + fun.interest.
      ELSE
      s-amt = fun.amt .
      srem[1] = " ".
      srem[2] = " ".
      srem[3] = " ".
      srem[4] = " ".
      srem[5] = " ".
      FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
      IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
      DO:
        /* 14/12/95 у нас sysc.loval = false всегда!!!-------
        IF sysc.chval = fun.dfb AND s-amt GT 0 AND gl.type = "L"
          THEN
        DO TRANSACTION:

          {mesg.i 0985} UPDATE kans.
          IF kans = FALSE THEN
          UNDO,LEAVE.
          HIDE ALL.
          FIND bank WHERE bank.bank = fun.bank NO-LOCK.
          vtpy = bank.name.
          vcdt = fun.crbank.
          vtpyac = fun.acct.
          kbank = fun.bank.
          vbank = fun.tbank.
          vcom  = "REF:" + s-fun.
          RUN s-dbgla.
          IF LASTKEY = KEYCODE ( "PF4" ) OR LASTKEY = KEYCODE ( "F4" ) THEN
          UNDO, NEXT outer.
          HIDE ALL.
        END. ------------------------------------------------ */
      END.
      RUN s-funstl.
      PAUSE 0.
      DISPLAY s-jh WITH FRAME fun.
      VIEW FRAME heading.
      VIEW FRAME fun.
      VIEW FRAME slct.
      DISP fun.dam[1] fun.dam[2] fun.cam[1] fun.cam[2] WITH FRAME funpay.
      PAUSE 0.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "HIST"
      THEN
    DO:
      /* run q-fun. */
      {mesg.i 0864}
      UPDATE v.
      IF v EQ 1 THEN
      DO:
        FOR EACH jl WHERE jl.acc EQ fun.fun BREAK BY jl.jh:
          IF FIRST-OF(jl.jh) THEN
          DO:
            FIND jh WHERE jh.jh EQ jl.jh.
            FOR EACH b-jl WHERE b-jl.jh EQ jh.jh:
              DISPLAY b-jl.gl b-jl.who b-jl.jdt b-jl.jh
                b-jl.dam b-jl.cam jh.post WITH FRAME mk.
              DOWN WITH FRAME mk.
            END.
          END.
          DOWN 1 WITH FRAME mk.
        END.
        PAUSE.
        CLEAR FRAME mk ALL NO-PAUSE.
      END. /* end of v */
      IF v EQ 2 THEN
      DO:
        RUN q-fun.
      END.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "PRINT"
      THEN
    DO:
      RUN funvou.
      DISPLAY s-jh WITH FRAME fun.
      PAUSE 5.
      NEXT outer.
    END.
    ELSE
    IF FRAME-VALUE EQ "CNCL"
      THEN
    DO:
      FOR EACH jl WHERE jl.acc EQ fun.fun BREAK BY jl.jh:
        IF FIRST-OF(jl.jh) THEN
        DO:
          FIND jh WHERE jh.jh EQ jl.jh.
          FOR EACH b-jl WHERE b-jl.jh EQ jh.jh:
            DISPLAY b-jl.jh @ vjh b-jl.gl b-jl.who b-jl.jdt
              b-jl.dam b-jl.cam jh.post WITH FRAME ms.
            DOWN WITH FRAME ms.
          END.
        END.
        DOWN 1 WITH FRAME ms.
        /*  {chkwt.i}  */
      END.
      PAUSE.
      /* clear frame ms all no-pause. */
      PROMPT-FOR vjh WITH FRAME ms.
      FIND jh WHERE jh.jh EQ INPUT vjh.
      IF AVAILABLE jh     /* when there is a control #  */
        THEN
      DO:
        IF jh.post EQ TRUE   /* when this is posted already */
          THEN
        DO:
          RUN x-jhnew.
          FIND jh  WHERE jh.jh EQ s-jh.
          FIND b-jh WHERE b-jh.jh EQ vjh.
          jh.crc = b-jh.crc.
          jh.cif = b-jh.cif.
          jh.party = b-jh.party.
          FOR EACH b-jl OF b-jh:
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
            jl.crc = b-jl.crc.
            jl.acc = b-jl.acc.
            jl.dam = b-jl.cam.
            jl.cam = b-jl.dam.
            IF b-jl.dc EQ "D"
              THEN
            jl.dc = "C".
            ELSE
            jl.dc = "D".
            jl.consol = b-jl.consol.
            FIND gl WHERE gl.gl EQ jl.gl.
            /* temporarily updated with jlupd-r.i
            {jlupd-r.old}
            */
            {jlupd-r.i}
          END.
          /* run x-jlvou. */     /* print cancel voucher automatically */
        END.
        ELSE
        DO:      /* when not posted yet */
          FOR EACH jl OF jh:
            FIND gl WHERE gl.gl EQ jl.gl.
            /* temporarily updated with jlupd-f.i
            {jlupd-f.old}
            */
            {jlupd-f.i}
            DELETE jl.
          END.
        END.
      END.
      /* register cancel date, recover l/c amount and commision */
      /* only when there is a control # */
      NEXT outer.
    END.    /* end cancel */
  END. /* inner */
END. /* outer */

