/* s-funstl.p
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

/* s-funstl.p
*/

{proghead.i}
/* W/T */
DEF SHARED VAR srem  AS CHAR FORMAT "x(75)"  EXTENT 5.
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

DEF VAR vrem AS cha FORMAT "x(55)" EXTENT 7.
DEF VAR vamt LIKE jl.dam.
DEF VAR vln AS INT.
DEF VAR vans AS LOG INIT FALSE.

DEF VAR deal-gl like sysc.inval. /* промежут. var */

FIND fun WHERE fun.fun EQ s-fun NO-LOCK.

IF g-today < fun.duedt THEN
DO:
  {mesg.i 5200}.
  {mesg.i 0928} UPDATE vans.
  IF vans EQ FALSE THEN
  LEAVE.
  /* undo, retry. */
END.
RUN x-jhnew.
FIND jh WHERE jh.jh = s-jh.
jh.crc = fun.crc.
jh.party = fun.fun .
srem[1] = fun.fun + " " + fun.bank + " " + fun.cst.

vln = 1.
/*
*/
IF fun.itype EQ "A" THEN
DO:

  /* fund pay principal */
  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.crc = fun.crc.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  jl.gl = gl.gl.
  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.amt.
    vamt = jl.cam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Ref:" + s-fun.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.amt.
    vamt = jl.dam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Ref:" + s-fun.
  END.

  /*
  */
  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ jl.acc NO-ERROR.
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
  jl.crc = fun.crc.
  /*find bank where bank.bank eq fun.dfb no-lock.  SV */

 /*  ROPYGL и RMPYGL для дилинга !!!; переход на новую GL */
  IF gl.type = "L" THEN DO:
    FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.
  ELSE do:
    FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.
  jl.gl = deal-gl.
  jl.acc = fun.fun.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "D".
    jl.dam = vamt + fun.interest.
    jl.rem[2] = "Ref: " + s-fun.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "C".
    jl.cam = vamt + fun.interest.
    /*find bank where bank.bank eq fun.tbank no-lock. SV */
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "T/F:". /* + bank.name.
    find bank where bank.bank eq fun.bank no-lock.*/
    jl.rem[3] = "A/C:". /*+ bank.name.*/
    jl.rem[4] = "A/C#:". /*+ bank.acct.*/
    jl.rem[5] = "Ref:" + s-fun.

    FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
    IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
    DO:
      /* 14/12/95 у нас sysc.loval = false всегда !!!! ---------
      FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.

      IF jl.gl = sysc.inval THEN
      DO:
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
      END. ------------------------------------------------- */
    END.
  END.
  /*
  */
  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  {jlupd-r.i}
  vln = vln + 1.

  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.crc = fun.crc.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  /*
  jl.gl = gl.gl1.  /* interest gl # */
  */

  /* for accrued int. method */

  FIND sysc WHERE sysc.sysc = "DAYACR" NO-LOCK.

  IF sysc.loval = TRUE THEN
  jl.gl = gl.autogl.
  ELSE
  jl.gl = gl.gl1.

  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.interest.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.interest.
  END.
  jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
  jl.rem[2] = "" + STRING(fun.amt) +  "*"
    + STRING(fun.intrate) + "%" + "*"
    + STRING(fun.duedt - fun.rdt)
    + "(" + STRING(fun.duedt) + "-" + STRING(fun.rdt) + ")"
    + "/" + STRING(fun.basedy).
  jl.rem[3] = "Ref:" + s-fun.
  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ jl.acc NO-ERROR.
    fun.dam[gl.level] = fun.dam[gl.level] + jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] + jl.cam.
  END.

  vln = vln + 1.
END. /* accrual case */

IF fun.itype EQ "D" THEN
DO:

  /* fund pay principal */
  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.crc = fun.crc.
  FIND gl WHERE gl.gl EQ fun.gl.
  jl.gl = gl.gl.
  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.amt - fun.interest.
    vamt = jl.cam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Ref:" + s-fun.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.amt - fun.interest.
    vamt = jl.dam.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Term: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
      "(" + STRING(fun.duedt - fun.rdt) + "Days)".
    jl.rem[3] = "Int Rate:" + STRING(fun.intrate) + "%".
    jl.rem[4] = "Ref:" + s-fun.
  END.

  /*
  */
  FIND gl WHERE gl.gl EQ jl.gl.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ jl.acc NO-ERROR.
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
  jl.crc = fun.crc.
  FIND bank WHERE bank.bank EQ fun.dfb NO-LOCK.

  /*
  IF gl.type = "L" THEN
  FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
  ELSE
  FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.    */
  /*  ROPYGL и RMPYGL для дилинга !!!; переход на новую GL */
  IF gl.type = "L" THEN DO:
    FIND sysc WHERE sysc.sysc = "ROPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.
  ELSE do:
    FIND sysc WHERE sysc.sysc = "RMPYGL" NO-LOCK.
    deal-gl  = int(entry(2,sysc.chval)).
  END.


  jl.gl = deal-gl.
  jl.acc = " ".
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "D".
    jl.dam = vamt + fun.interest.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    jl.rem[2] = "Ref: " + s-fun.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "C".
    jl.cam = vamt + fun.interest.
    jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
    FIND bank WHERE bank.bank EQ fun.tbank NO-LOCK.
    jl.rem[2] = "T/F:" + bank.name.
    FIND bank WHERE bank.bank EQ fun.bank NO-LOCK.
    jl.rem[3] = "A/C:" + bank.name.
    jl.rem[4] = "A/C#:" + bank.acct.
    jl.rem[5] = "Ref:" + s-fun.
    FIND sysc WHERE sysc.sysc = "wiretf" NO-LOCK NO-ERROR.
    IF sysc.loval = TRUE AND sysc.chval = "chemlink" THEN
    DO:
	 /* 14/12/95 у нас sysc.loval = false всегда !!!! ---------
      FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.
      IF jl.gl = sysc.inval THEN
      DO:
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
      END. ------------------------------------ */
    END.
  END.
  /*
  */
  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  {jlupd-r.i}
  vln = vln + 1.

  /*
  */

  CREATE jl.
  jl.jh = jh.jh.
  jl.ln = vln.
  jl.who = jh.who.
  jl.jdt = jh.jdt.
  jl.whn = jh.whn.
  jl.crc = fun.crc.
  FIND gl WHERE gl.gl EQ fun.gl NO-LOCK.
  /*
  jl.gl = gl.gl1.  /* interest gl # */
  */

  /* for accrued int. method */

  FIND sysc WHERE sysc.sysc = "DAYACR" NO-LOCK.

  IF sysc.loval = TRUE THEN
  jl.gl = gl.autogl.

  ELSE
  jl.gl = gl.gl1.

  jl.acc = s-fun.
  IF gl.type EQ "A" THEN
  DO:
    jl.dc = "C".
    jl.cam = fun.interest.
  END.
  IF gl.type EQ "L" THEN
  DO:
    jl.dc = "D".
    jl.dam = fun.interest.
  END.

  jl.rem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
  jl.rem[2] = "" + STRING(fun.amt) +  "*"
    + STRING(fun.intrate) + "%" + "*"
    + STRING(fun.duedt - fun.rdt)
    + "(" + STRING(fun.duedt) + "-" + STRING(fun.rdt) + ")"
    + "/" + STRING(fun.basedy).
  jl.rem[3] = "Ref:" + s-fun.
  FIND gl WHERE gl.gl EQ jl.gl NO-LOCK.
  IF gl.subled EQ "fun"
    THEN
  DO:
    FIND fun WHERE fun.fun EQ jl.acc NO-ERROR.
    fun.dam[gl.level] = fun.dam[gl.level] + jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] + jl.cam.
  END.

  vln = vln + 1.
END. /* discount case */

FIND gl WHERE gl.gl = fun.gl NO-LOCK.
IF gl.type = "L" THEN
DO:
  s-fun = fun.fun.
  s-jh = jh.jh.
  /*
  run funremo.
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
