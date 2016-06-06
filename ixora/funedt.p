/* funedt.p
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
*/


{proghead.i "TRANSFER DEAL INFO TO FUND FILE"}

DEF NEW SHARED VAR s-jh LIKE jh.jh LABEL "CONTROL#".
DEF NEW SHARED VAR srem AS CHAR FORMAT "x(75)" EXTENT 5.
DEF NEW SHARED VAR s-amt as decimal.
DEF NEW SHARED VAR vtpy AS cha FORM "x(70)".
DEF NEW SHARED VAR vtpyac AS cha FORM "x(12)".
DEF NEW SHARED VAR vcdt AS cha FORM "x(40)".
DEF NEW SHARED VAR kbank LIKE bankl.bank.
DEF NEW SHARED VAR wfln AS INT FORM "zzzzz9".
DEF NEW SHARED VAR vbank LIKE bankl.bank.
DEF NEW SHARED VAR vcom AS cha FORM "x(70)".
define new shared variable s-frem like remtrz.remtrz.
define variable yes-no as logical init false.

DEF SHARED VAR s-fun LIKE fun.fun.
DEF SHARED VAR vans AS LOG.

DEF VAR fv AS cha.
DEF VAR inc AS INT.
DEF VAR vacc LIKE fun.fun.
DEF VAR vdfbnm LIKE bankl.name.
DEF VAR vdfbacct LIKE bankl.acct LABEL "A/C#".
DEF VAR vdfbacc LIKE bankl.acc .

DEF VAR kans AS LOG INIT TRUE.
DEF VAR vdfb LIKE fun.dfb.
DEF VAR v-trx LIKE jh.jh.

{funedt.f}

FIND fun WHERE fun.fun EQ s-fun no-lock.
FIND fungrp WHERE fungrp.fungrp EQ fun.grp no-lock.
FIND gl WHERE gl.gl EQ fun.gl no-lock NO-ERROR.
/*   -12/12/95--------------------------
FIND sysc WHERE sysc.sysc EQ "defdfb" NO-LOCK.
vdfb = sysc.chval.
    -----------------------------        */
vdfbacc = fun.bank.

DISP fun.fun fun.gl gl.sname fun.grp fungrp.des fun.ddt[5] fun.bank fun.cst
  fun.amt fun.rdt fun.duedt fun.trm fun.intrate
  fun.interest fun.itype
  fun.dfb
  WITH FRAME fun.
FIND dfb WHERE dfb.dfb EQ fun.dfb NO-ERROR.
IF AVAIL dfb THEN DO: vdfbnm = dfb.name. vdfbacct = dfb.dfb. END.
              ELSE DO: vdfbnm = "".        vdfbacct = "".        END.
DISP vdfbnm vdfbacct fun.tbank fun.acct fun.who
  fun.rem WITH FRAME fun.

FIND sysc WHERE sysc.sysc EQ "wiretf" NO-LOCK NO-ERROR.
IF sysc.loval EQ TRUE AND sysc.chval EQ "chemlink" THEN
do:
  /* ---12/12/95-----------------у нас sysc,loval = false  всегда!!!
  s-amt = fun.amt.
  srem[1] = " ".
  srem[2] = " ".
  srem[3] = " ".
  srem[4] = " ".
  srem[5] = " ".
  FIND gl WHERE gl.gl = fun.gl .
  FIND sysc WHERE sysc.sysc = "DBGL" NO-LOCK NO-ERROR.
  IF sysc.chval = fun.dfb AND s-amt GT 0 AND gl.type = "A" THEN
  DO:
    {mesg.i 0985} UPDATE kans.
    IF kans = FALSE THEN
    UNDO,LEAVE.
    HIDE ALL.
    FIND bankl WHERE bankl.bank = fun.bank NO-LOCK.
    vtpy = bankl.name.
    vcdt = fun.crbank.
    vtpyac = fun.acct.
    kbank = fun.bank.
    vbank = fun.tbank.
    vcom  = "REF:" + s-fun.
        run s-dbgla. 
    IF LASTKEY EQ KEYCODE("PF4") OR LASTKEY EQ KEYCODE("F4") THEN UNDO, NEXT.
    HIDE ALL.
  end.  then do 
  -------------------------------------*/
end.   /* wiretf eq true */
{mesg.i 0881} UPDATE vans.
IF NOT vans 
THEN UNDO, RETURN.

/*if fun.sts eq 0 then run s-funiss. else if fun.sts eq 1 then run s-funstl.*/


IF fun.sts <> 0
then do: 
     if gl.type EQ "A" 
     THEN DO:   /* Placed */
          MESSAGE "Введите номер входящего перевода" UPDATE s-frem.
          if lastkey = keycode("F4")
          then undo,return.
          find remtrz where remtrz.remtrz = s-frem no-lock no-error.
          
          IF NOT AVAILABLE remtrz 
          THEN DO:
               MESSAGE "Перевод не найден" . 
               BELL. BELL.
               pause.
               UNDO, RETRY.
          END.
          if remtrz.tcrc <> fun.crc
          then do:
               message "Валюта перевода " + string(remtrz.tcrc) + 
               " не совпадает с валютой сделки " + string(fun.crc).
               pause.
               undo,retry.
          end.     
          s-amt = remtrz.payment.
     END.
     RUN funmatrx.  /*s-funstl.*/
END.

ELSE IF fun.sts EQ 0 
THEN do:

     if gl.type EQ "L" then do:
     
          MESSAGE "Введите номер входящего перевода" UPDATE s-frem.
          if lastkey = keycode("F4")
          then undo,return.
          find remtrz where remtrz.remtrz = s-frem no-lock no-error.
          
          IF NOT AVAILABLE remtrz 
          THEN do:
               MESSAGE "Перевод не найден" . 
               BELL. BELL. 
               pause.
               UNDO, RETRY.
          end.

          if remtrz.tcrc <> fun.crc
          then do:
               message "Валюта перевода " + string(remtrz.tcrc) + 
               " не совпадает с валютой сделки " + string(fun.crc).
               pause.
               undo,retry.
          end. 
          s-amt = fun.amt.
          if fun.itype = "D"
          then s-amt = s-amt - fun.interest.
          if remtrz.payment <> s-amt
          then do:
               message "Сумма перевода " + string(remtrz.payment) + 
               " не совпадает с суммой сделки " + string(s-amt).
               pause.
               undo,retry.
          end. 
          s-amt = remtrz.payment.

     end.
     message "Starting Start Date TRX". 
     RUN funstrx.    /*s-funiss.*/
     pause 0.
end.

HIDE FRAME fun.
pause 0.


