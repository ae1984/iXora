/* aat-bat2.p
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

/* chkbat2.p
   aat-bat2.p
   Simon Kim
*/

{proghead.i "BATCH CHECK ENTRY MENU"}

define new shared var s-aat like aat.aat.
define new shared var s-line as int.
define new shared var s-force as log initial false.
define new shared var s-bat like bat.bat.
define buffer b-bat for bat.
define buffer b-aaa for aaa.

define var vln like aal.ln.
define var vout as char.
define var vans as log.
define var vaaa like aaa.aaa.
define var vbal like aaa.cbal.
define var vava like aaa.cbal.
define var vcrc like crc.crc.
define var vchk like bat.chkno.
define var vtrue as logical init false.
define var toavail as dec decimals 2 label "Avail-Bal" init 0.
define var cravail like aaa.cbal label "Cr-Avail" init 0.

form bat.ln bat.aaa vava bat.amt vchk bat.sta
     with row 3 centered 15 down overlay frame bat
     title "BATCH CHECK ENTRY ( BATCH NO : "
                        + string(s-bat) + " )".

{mesg.i 6808} update s-bat.

if s-bat eq 0 then run nxtbat.

find first bat where bat.bat eq s-bat no-error.
if available bat then vcrc = bat.crc.
if not available bat then do:
  update vcrc validate(can-find(crc where crc.crc eq vcrc),"Invalid Entry...")
         label "ENTER CURRENCY: "
         with row 8 centered side-label.
end. /* if not abailable bat */


if available bat and bat.who ne g-ofc and g-ofc ne "root"
  then do:
    bell.
    {mesg.i 0602}.
    return.
  end.

vln = 1.

for each bat where bat.bat eq s-bat by bat.ln:
  vchk = bat.chkno.
  vava = bat.abal.
  display bat.ln bat.aaa vava bat.amt vchk bat.sta
          with frame bat.
  down 1 with frame bat.
  vln = bat.ln + 1.
end. /* for each bat */

repeat:
  find first bat where bat.bat eq s-bat no-error.
  prompt-for bat.ln help "Enter 0 or Press Return-Key for New Number.."
             with frame bat.
  if input bat.ln eq 0
    then do:
      create bat.
      bat.bat = s-bat.
      bat.ln  = vln.
      bat.crc = vcrc.
      bat.who = userid('bank').
      bat.regdt = g-today.
      bat.tim = time.
      vln = vln + 1.
      display bat.ln with frame bat.
  end. /* if input bat.ln */
  else do:
      find bat where bat.bat eq s-bat and bat.ln eq input bat.ln.
      if bat.stn eq 9
        then do:
          bell.
          {mesg.i 0222}.
          undo, retry.
        end. /* if bat.stn eq 9 */
      find aaa where aaa.aaa eq bat.aaa.
  end. /* else do */
  update bat.aaa with frame bat.

  find aaa where aaa.aaa eq bat.aaa.
  if aaa.crc ne vcrc then do:
    {mesg.i 9813}. pause 1.
    undo,retry.
  end.
  if aaa.sta eq "C" then do:
     {mesg.i 6207}.  pause 1.
     undo, retry.
  end.
  find cif where aaa.cif eq cif.cif.
  message trim(trim(cif.prefix) + " " + trim(cif.sname)).

  find last b-bat where b-bat.regdt eq g-today
                and b-bat.aaa eq aaa.aaa and b-bat.stn eq 0 no-error.
  find prev b-bat where b-bat.regdt eq g-today
                and b-bat.aaa eq aaa.aaa and b-bat.stn eq 0 no-error.
  if available b-bat then vbal = b-bat.abal - b-bat.amt.
  else do:
    if aaa.loa ne ""
      then do:
         find b-aaa where b-aaa.aaa = aaa.loa no-lock.
         cravail = (b-aaa.dr[5] - b-aaa.cr[5])
                      - (b-aaa.dr[1] - b-aaa.cr[1]).
    end. /* if aaa.loa ne "" */
    vbal = aaa.cbal + cravail - aaa.hbal.
  end. /* else do */
  vava = vbal.
  disp vava with frame bat.
  update bat.amt validate(bat.amt le vbal,"EXCEED THE AMOUNT....")
         with frame bat.
  bat.abal = vbal.

  if bat.amt eq 0
    then do:
      delete bat.
      undo,retry.
  end.  /* if bat.amt eq 0 */

  inner:
  repeat:
    vchk = 0.
    bat.chkno = 0.
    update vchk with frame bat.
    for each b-bat where b-bat.aaa eq aaa.aaa /* consider check book file */ :
      if b-bat.chkno eq vchk then do:
        {mesg.i 6204}. pause 3.
        vtrue = true.
        vln = 0.
        undo inner,retry inner.
      end. /* if bat.chkno eq vchk */
    end. /* for each bat */
    if vtrue = false then do:
      bat.chkno = vchk.
      leave inner.
    end.
  end. /* inner */
  find first aas where aas.aaa eq bat.aaa and aas.chkno eq bat.chkno no-error.
  if available aas
    then do:
      bell.
      {mesg.i 8820}.
      clear frame bat.
      undo, retry.
    end.
  display bat.sta with frame bat.
  if bat.amt eq 0  or bat.chkno eq 0
    then do:
      delete bat.
      vln = vln - 1.
    end.  /* if bat.amt eq 0 */
  down 1 with frame bat.
end. /* repeat */
