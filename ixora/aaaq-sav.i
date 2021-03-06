﻿/* aaaq-sav.i
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

/* aaaq-sav.i
*/

define var grobal  as dec format "z,zzz,zzz,zzz.99CR".
define var avabal  as dec format "z,zzz,zzz,zzz.99CR".
define var intrat  as dec format "zz.9999" decimals 4.
define var lstint  as dec format "z,zzz,zzz,zzz.99CR".
define var mtddb   as dec format "z,zzz,zzz,zzz.99CR".
define var mtdcr   as dec format "z,zzz,zzz,zzz.99CR".
define var ytdint  as dec format "z,zzz,zzz,zzz.99CR".
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.

{proghead.i "Savings Account Inquiry"}

form "CIF# -" {1}.cif.cif skip
     {1}.cif.sname             "ACCT#" at 41 {1}.aaa.aaa skip
     {1}.cif.tel               "STATUS      " at 41 {1}.aaa.sta skip
     "GROSS   BAL" grobal  "HOLD    BAL" at 41 {1}.aaa.hbal vdet skip
     "AVAIL   BAL" avabal
     "INT    ACCR" at 41 {1}.aaa.accrued format "zz,zzz,zzz.99CR"  skip
     "INTEREST  %" intrat  "INT PD  YTD" at 41 ytdint  skip
     "LAST INT PD" lstint  skip
                          {1}.cif.pss at 41 skip
     "LAST  DEBIT" {1}.aaa.lstdb
                           "LAST DB DATE" at 41 {1}.aaa.ddt skip
     "LAST CREDIT" {1}.aaa.lstcr
                           "LAST CR DATE" at 41 {1}.aaa.cdt skip
                           "OPEN    DATE" at 41 {1}.aaa.regdt skip(1)
     "Related A/C" vrel    "Stop Payment" at 41 vstop skip(1)
     "FLOAT INFORMATION" skip
     "1" {1}.aaa.fbal[1]
     "3" {1}.aaa.fbal[3]
     "5" {1}.aaa.fbal[5]
     "7" {1}.aaa.fbal[7] skip
     "2" {1}.aaa.fbal[2]
     "4" {1}.aaa.fbal[4]
     "6" {1}.aaa.fbal[6] skip
     with title " ACCOUNT INFORMATION       BRANCH: " + {1}.cmp.name + " "
     centered row 3 no-label frame aaa.

clear frame aaa.
find first {1}.cmp.
find {1}.aaa where {1}.aaa.aaa eq "{2}".
find {1}.cif of {1}.aaa.
find {1}.lgr where {1}.lgr.lgr eq {1}.aaa.lgr.
if {1}.lgr.led ne "SAV" then do:
  bell.
  {mesg.i 8217}.
  undo, retry.
end.
if {1}.lgr.lookaaa eq true then do:
  find {1}.pri where {1}.pri.pri eq {1}.aaa.pri.
  intrat = {1}.pri.rate + {1}.aaa.rate.
end.
else do:
  find {1}.pri where {1}.pri.pri eq {1}.lgr.pri.
  intrat = {1}.pri.rate + {1}.lgr.rate.
end.

/* find last aal where aal.aaa eq aaa.aaa and aal.aax eq no-error. */
if available {1}.aal then lstint = {1}.aal.amt.
grobal = {1}.aaa.cr[1] - {1}.aaa.dr[1].
avabal = {1}.aaa.cbal - {1}.aaa.hbal.
ytdint = ({1}.aaa.dr[2] - {1}.aaa.idr[2]) - ({1}.aaa.cr[2] - {1}.aaa.icr[2]).
mtddb = {1}.aaa.dr[1] - {1}.aaa.mdr[1].
mtdcr = {1}.aaa.cr[1] - {1}.aaa.mcr[1].
display {1}.cif.cif trim(trim({1}.cif.prefix) + " " + trim({1}.cif.sname)) @ {1}.cif.sname {1}.aaa.aaa {1}.cif.tel {1}.aaa.sta
        grobal {1}.aaa.hbal avabal {1}.aaa.accrued intrat ytdint
        lstint {1}.cif.pss {1}.aaa.lstdb {1}.aaa.ddt {1}.aaa.lstcr {1}.aaa.cdt
        {1}.aaa.regdt {1}.aaa.fbal
        with frame aaa.
inner:
repeat:
  update vdet with frame aaa.
  if vdet eq true then do:
    for each {1}.aas where {1}.aas.aaa eq {1}.aaa.aaa and {1}.aas.sic eq "SP":
      display {1}.aas.regdt {1}.aas.chkamt {1}.aas.payee {1}.aas.expdt
              with title " HOLD BALANCE "
              down centered row 4 overlay top-only frame hb.
    end.
    vdet = false.
  end.

  update vrel with frame aaa editing:
    readkey.
    if keyfunction(lastkey) eq "END-ERROR" then leave inner.
    apply lastkey.
  end.
  if vrel eq true then do:
    g-cif = {1}.aaa.cif.
    {aaaq-rel.i {1}}
    g-cif = "".
  end.

  update vstop with frame aaa editing:
    readkey.
    if keyfunction(lastkey) eq "END-ERROR" then leave inner.
    apply lastkey.
  end.
  if vstop eq true then do:
    for each {1}.aas where {1}.aas.aaa eq {1}.aaa.aaa and {1}.aas.sic eq "SP":
      display {1}.aas.chkdt {1}.aas.chkno {1}.aas.chkamt {1}.aas.payee
              {1}.aas.expdt
              with title " STOP PAYMENT "
              down centered row 4 overlay top-only frame sp.
    end.
    vstop = false.
  end.
end.
