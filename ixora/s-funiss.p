/* s-funiss.p
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

/* s-funiss.p
*/

{proghead.i}
/* W/T */
DEF SHARED VAR srem AS CHAR FORMAT "x(75)" EXTENT 5. /* only difference */
DEF SHARED VAR wfln LIKE wf.ln.

DEF SHARED VAR s-bank LIKE bank.bank.
DEF SHARED VAR s-fun LIKE fun.fun.  /* acct # */
DEF SHARED VAR s-jh  LIKE jh.jh.
DEF SHARED VAR s-gl LIKE gl.gl.     /* payment gl # */
DEF SHARED VAR s-acc LIKE jl.acc.   /* payment acct # */
DEF NEW SHARED VAR s-consol LIKE jh.consol INITIAL FALSE.
DEF NEW SHARED VAR s-aah  as int.
DEF NEW SHARED VAR s-line AS INT.
DEF NEW SHARED VAR s-force AS LOG INITIAL FALSE.
DEF NEW SHARED VAR v-rem LIKE rem.rem.

DEF VAR vrem AS cha EXTENT 7.
DEF VAR vamt LIKE jl.dam.
DEF VAR vln AS INT.
DEF VAR deal-gl like sysc.inval. /* промежут. var */


FIND fun WHERE fun.fun EQ s-fun.
RUN x-jhnew.
FIND jh WHERE jh.jh = s-jh.
jh.crc = fun.crc.
srem[1] = fun.fun + " " + fun.bank + " " +  fun.cst.
jh.party = fun.fun.  /* fun.bank + "  " + fun.cst.  */
IF LENGTH(jh.party) GT 30 THEN
jh.party = SUBSTRING(jh.party,1,30).
vln = 1.

IF fun.itype EQ "a" THEN
DO:

  /* fund issue principal */
  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  jl.gl = fun.gl.
  jl.crc = fun.crc.
  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.amt.
    vamt = jl.dam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.

    /*
    */

  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.amt.
    vamt = jl.cam.
    /*
    */
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.
  END.
  vrem[1] = jl.rem[1].
  vrem[2] = jl.rem[2].
  vrem[3] = jl.rem[3].
  vrem[4] = jl.rem[4].
  vrem[5] = jl.rem[5].

  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ s-fun /* jl.acc */ NO-ERROR.
    fun.dam[gl.level] = fun.dam[gl.level] + jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] + jl.cam.
  END.
  vln = vln + 1.

  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.rem[1] = vrem[1].
  jl.rem[2] = vrem[2].
  jl.rem[3] = vrem[3].
  jl.rem[4] = vrem[4].
  jl.rem[5] = vrem[5].
  /*
  IF gl.type = "A" THEN
  FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
  ELSE
  FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.  */
   /*  ROPYGL и RMPYGL для дилинга !!!; переход на новую GL */
  IF gl.type = "A" THEN DO:
    FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.
  ELSE do:
    FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.


  FIND bank WHERE bank.bank EQ fun.dfb NO-LOCK.
  jl.gl = deal-gl.
  jl.crc = fun.crc.
  jl.acc = fun.fun.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.

  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = vamt.

    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    FIND bank WHERE bank.bank EQ fun.tbank NO-LOCK.
    jl.rem[2] = "T/F:" + bank.name.
    FIND bank WHERE bank.bank EQ fun.bank NO-LOCK.
    jl.rem[3] = "A/C:" + bank.name.
    IF fun.acct NE "" THEN
    jl.rem[4] = "A/C#:" + fun.acct.
    ELSE
    jl.rem[4] = "A/C#:" + bank.acct.
    jl.rem[5] = "Ref:" + s-fun.

    FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
    IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
    DO:
      /* 14/12/95 у нас sysc.loval = false всегда !!!! ---------
      FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.
      IF jl.gl = sysc.inval THEN
      DO:
	/*
	s-jh = jl.jh.
	s-jln = jl.ln.
	s-amt = jl.cam. */
	jl.rem[1] = " ".
	jl.rem[2] = " ".
	jl.rem[3] = " ".
	jl.rem[4] = " ".
	jl.rem[5] = " ".
	jl.rem[1] = srem[1].
	jl.rem[2] = srem[2].
	jl.rem[3] = srem[3].
	jl.rem[4] = srem[4].
	jl.rem[5] = srem[5].
	FIND wf WHERE wf.ln = wfln NO-ERROR.
	IF AVAILABLE wf THEN
	DO:
	  wf.jh = jl.jh.
	  wf.jln = jl.ln.
	END.
      END. ----------------------------------- */
    END.
  END.

  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = vamt.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.
  END.

  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  /*
  {jlupd-r.i}
  */
  {jlupd-r.i}
  vln = vln + 1.
END. /* accrual case */
/* ------------------------ */

IF fun.itype EQ "D" THEN
DO:

  /* fund issue principal */
  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  jl.gl = fun.gl.
  jl.crc = fun.crc.
  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.amt - fun.interest.
    vamt = jl.dam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.
    /*
    */
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.amt - fun.interest.
    vamt = jl.cam.
    /*
    */
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.
  END.
  vrem[1] = jl.rem[1].
  vrem[2] = jl.rem[2].
  vrem[3] = jl.rem[3].
  vrem[4] = jl.rem[4].
  vrem[5] = jl.rem[5].

  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ s-fun /* jl.acc */ NO-ERROR.
    fun.dam[gl.level] = fun.dam[gl.level] + jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] + jl.cam.
  END.
  vln = vln + 1.

  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.rem[1] = vrem[1].
  jl.rem[2] = vrem[2].
  jl.rem[3] = vrem[3].
  jl.rem[4] = vrem[4].
  jl.rem[5] = vrem[5].
  /*
  IF gl.type = "A" THEN
  FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
  ELSE
  FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.  */
   /*  ROPYGL и RMPYGL для дилинга !!!; переход на новую GL */
  IF gl.type = "A" THEN DO:
    FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.
  ELSE do:
    FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.

  FIND bank WHERE bank.bank EQ fun.dfb NO-LOCK.
  jl.gl = deal-gl.
  jl.crc = fun.crc.
  jl.acc = " ".
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.amt - fun.interest.

    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    FIND bank WHERE bank.bank EQ fun.tbank NO-LOCK.
    jl.rem[2] = "T/F:" + bank.name.
    FIND bank WHERE bank.bank EQ fun.bank NO-LOCK.
    jl.rem[3] = "A/C:" + bank.name.
    IF fun.acct NE "" THEN
    jl.rem[4] = "A/C#:" + fun.acct.
    ELSE
    jl.rem[4] = "A/C#:" + bank.acct.
    jl.rem[5] = "Ref:" + s-fun.

    FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
    IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
    DO:
      /* 14/12/95 у нас sysc.loval = false всегда !!!! ---------
      FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.
      IF jl.gl = sysc.inval THEN
      DO:
	/*
	s-jh = jl.jh.
	s-jln = jl.ln.
	s-amt = jl.cam. */
	jl.rem[1] = " ".
	jl.rem[2] = " ".
	jl.rem[3] = " ".
	jl.rem[4] = " ".
	jl.rem[5] = " ".
	jl.rem[1] = srem[1].
	jl.rem[2] = srem[2].
	jl.rem[3] = srem[3].
	jl.rem[4] = srem[4].
	jl.rem[5] = srem[5].
	FIND wf WHERE wf.ln = wfln NO-ERROR.
	IF AVAILABLE wf THEN
	DO:
	  wf.jh = jl.jh.
	  wf.jln = jl.ln.
	END.
      END. ---------------------------------------- */
    END.
  END.

  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = vamt.

    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Int Amt: " + STRING(fun.interest).
    jl.rem[5] = "Ref: " + s-fun.
  END.

  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  /*
  {jlupd-r.i}
  */
  {jlupd-r.i}
  vln = vln + 1.
END. /* discount case */
/*  -------- ---------------- */

FIND gl WHERE gl.gl = fun.gl NO-LOCK.
IF gl.type = "A" THEN
DO:
  s-fun = fun.fun.
  s-jh = jh.jh.
  /*
  */
END.
PAUSE 0.
s-jh = jh.jh.
RUN x-jlvou.
FIND jh WHERE jh.jh = s-jh EXCLUSIVE-LOCK.
IF jh.sts NE 6 THEN
DO :
  FOR EACH jl OF jh :
    jl.sts = 5.
  END.
  jh.sts = 5.
END.
PAUSE 0.
