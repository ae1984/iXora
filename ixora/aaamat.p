/* aaamat.p
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

/* tdamat.p
*/

{mainhead.i } /* MATURING ACCOUNT */

define buffer b-aaa for aaa.
define var grobal  as dec format "zz,zzz,zzz.99-".
define var avabal  as dec format "zz,zzz,zzz.99-".
define var intrat  as dec format "zz.9999" decimals 4.
define var mtddb   as dec format "zz,zzz,zzz.99-".
define var mtdcr   as dec format "zz,zzz,zzz.99-".
define var ytdint  as dec format "zz,zzz,zzz.99-".
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
define var voldacc as dec decimals 2.
define var vintpay as log label "PAY INTEREST?".
define var vpenalty as dec format "zz,zzz,zzz.99-" label "PENALTY".
define var vans as log.

define new shared var s-aaa like aaa.aaa.
define new shared var s-aax as int.
define new shared var s-amt as dec.
define new shared var s-stn as int.
define new shared var s-intr as log initial true.
define new shared var s-force as log.
define new shared var s-jh like jh.jh.
define new shared var s-regdt as date.
define new shared var s-bal as dec.
define new shared var s-aah as int.

form
     "CIF# -" cif.cif skip
     cif.sname             "ACCT#" at 41 aaa.aaa skip
     cif.tel               "STATUS      " at 41 aaa.sta skip
     "GROSS   BAL" grobal  "HOLD    BAL" at 41 aaa.hbal vdet skip
     "AVAIL   BAL" avabal
     "INT    ACCR" at 41 aaa.accrued format "zz,zzz,zzz.99-"  skip
     "INTEREST  %" intrat  "INT PD  YTD" at 41 ytdint  skip
                           "INT PD  YTD" at 41 ytdint  skip
                           skip
                           cif.pss at 41 skip
     "LAST  DEBIT" aaa.lstdb
                           "LAST DB DATE" at 41 aaa.ddt skip
     "LAST CREDIT" aaa.lstcr
                           "LAST CR DATE" at 41 aaa.cdt skip
                           "OPEN    DATE" at 41 aaa.regdt skip(1)
     "EARLY WITHDRAWAL PENALTY" vpenalty skip
     with title " ACCOUNT INFORMATION " centered row 3 no-label frame aaa.

outer:
repeat:
  clear frame aaa.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq ""
    then prompt-for aaa.aaa with frame aaa.
    else display g-aaa @ aaa.aaa with frame aaa.
  /* editing: {gethelp.i} end. */
  find aaa using aaa.aaa.
  find cif of aaa.
  find lgr where lgr.lgr eq aaa.lgr.
  /*
  if lgr.led ne "CDA"
  then do:
         bell.
         {mesg.i 8212}.
         undo, retry.
       end. */
  if aaa.sta eq "M"
  then do:
         bell.
         {mesg.i 8818}.
         undo, retry.
       end.
  if lgr.lookaaa eq true
  then do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq aaa.pri no-error.
         intrat = pri.rate + aaa.rate.
         end.
         else intrat = aaa.rate.
       end.
  else do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq lgr.pri.
         intrat = pri.rate + lgr.rate.
         end.
         else intrat = lgr.rate.
       end.

  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname aaa.aaa
     cif.tel aaa.sta
     grobal aaa.hbal
     avabal aaa.accrued
     intrat
     ytdint
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     with frame aaa.

  {mesg.i 8814} update vans.
  if vans eq false then next.

  vintpay = true.
  vpenalty = 0.

  if aaa.expdt gt g-today
    then do:
      bell.
      {mesg.i 6807}.
      vpenalty = (aaa.cr[1] - aaa.dr[1]) * 30 * intrat / aaa.base / 100.
      update /* vintpay */ vpenalty with frame aaa.
    end.

  if vintpay eq true
    then do:
      s-aaa = aaa.aaa.
      s-aax = 66.
      s-amt = round(aaa.accrued,2).
      s-stn = 0.
      s-intr = true.
      s-force = true.
/*      run s-aahadd.*/
    end.
  /* else do: if vintpay eq false
    end.
  */

  if vpenalty gt 0
    then do:
      s-aaa = aaa.aaa.
      s-aax = 12.
      s-amt = vpenalty.
      s-stn = 0.
      s-intr = true.
      s-force = true.
      /*run s-aahadd.*/
    end.

  aaa.accrued = 0.
  aaa.sta = "M".
end.
