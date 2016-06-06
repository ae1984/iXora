/* aaaq-cda.i
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

/* aaaq-cda.i */

define var vdet    as log.
define var grobal  as dec format "zz,zzz,zzz.99-".
define var avabal  as dec format "zz,zzz,zzz.99-".
define var intrat  as dec format "zz.9999" decimals 4.
define var mtddb   as dec format "zz,zzz,zzz.99-".
define var mtdcr   as dec format "zz,zzz,zzz.99-".
define var ytdint  like mtdcr.
define var vaccr   like mtdcr.
define var mbal    as dec format "zzz,zzz,zzz.99-".
define var vdaytm  as int.
define var vrel    as log.
define var vstop   as log.

{proghead.i}

form
     "CIF# -" {1}.cif.cif      {1}.aaa.sta at 71        skip
     {1}.cif.sname format "x(20)"
        {1}.cif.pss format "999-99-9999"
                    "ACCT#" at 41 {1}.aaa.aaa skip
     {1}.cif.jame              "HOLD    BAL" at 41 {1}.aaa.hbal vdet skip
     {1}.cif.tel               "RELATED A/C" at 41  vrel skip
     "GROSS   BAL" grobal  skip
     "AVAIL   BAL" avabal  "INTEREST  %" at 41 intrat skip
     "INT    ACCR" at 41 vaccr skip
       "INT PD  YTD" at 41 ytdint  skip(1)
     "LAST  DEBIT" {1}.aaa.lstdb
                           "LAST DB DATE" at 41 {1}.aaa.ddt skip
     "LAST CREDIT" {1}.aaa.lstcr
                           "LAST CR DATE" at 41 {1}.aaa.cdt skip(1)
     "OPEN    DATE" {1}.aaa.regdt "OPEN  AMOUNT" at 41 {1}.aaa.opnamt skip
     "MATURE  DATE" {1}.aaa.expdt "MATURE-VALUE" at 41 mbal skip
     "ROLL    OVER" {1}.aaa.rollover  skip
     "FLOAT INFORMATION" skip
     "1" {1}.aaa.fbal[1] format "zz,zzz,zzz.99"
     "3" {1}.aaa.fbal[3] format "zz,zzz,zzz.99"
     "5" {1}.aaa.fbal[5] format "zz,zzz,zzz.99"
     "7" {1}.aaa.fbal[7] format "zz,zzz,zzz.99" skip
     "2" {1}.aaa.fbal[2] format "zz,zzz,zzz.99"
     "4" {1}.aaa.fbal[4] format "zz,zzz,zzz.99"
     "6" {1}.aaa.fbal[6] format "zz,zzz,zzz.99" skip
     with title " ACCOUNT INFORMATION      BRANCH: " + {1}.cmp.name + " "
          centered row 1 no-label frame aaa.

pause 0.
clear frame aaa.
find first {1}.cmp.
find {1}.aaa where {1}.aaa.aaa eq "{2}" no-error.
if not avail {1}.aaa then do:
  {mesg.i 0265}.
  undo, retry.
end.
find {1}.cif of {1}.aaa.
find {1}.lgr where {1}.lgr.lgr eq {1}.aaa.lgr.
if {1}.lgr.led ne "CDA" then do:
  bell.
  {mesg.i 8213}.
  undo, retry.
end.
if {1}.lgr.lookaaa eq true then do:
  if {1}.aaa.pri ne "F" then do:
    find {1}.pri where {1}.pri.pri eq {1}.aaa.pri no-error.
    intrat = {1}.pri.rate + {1}.aaa.rate.
  end.
  else intrat = {1}.aaa.rate.
end.
else do:
  if {1}.aaa.pri ne "F" then do:
    find {1}.pri where {1}.pri.pri eq {1}.lgr.pri.
    intrat = {1}.pri.rate + {1}.lgr.rate.
  end.
  else intrat = {1}.lgr.rate.
end.
vdaytm = {1}.aaa.expdt - {1}.aaa.regdt.
if {1}.aaa.lgr eq "302"
  then mbal = {1}.aaa.opnamt * {1}.aaa.rate * vdaytm / 36500.
  else mbal = {1}.aaa.opnamt * exp(1 + {1}.aaa.rate / 36500, vdaytm).
grobal = {1}.aaa.cr[1] - {1}.aaa.dr[1].
avabal = {1}.aaa.cbal - {1}.aaa.hbal.
ytdint = ({1}.aaa.dr[2] - {1}.aaa.idr[2]) - ({1}.aaa.cr[2] - {1}.aaa.icr[2]).
mtddb  = {1}.aaa.dr[1] - {1}.aaa.mdr[1].
mtdcr  = {1}.aaa.cr[1] - {1}.aaa.mcr[1].
disp {1}.cif.cif trim(trim({1}.cif.prefix) + " " + trim({1}.cif.sname)) @ {1}.cif.sname {1}.aaa.aaa {1}.cif.tel
     {1}.cif.pss {1}.aaa.sta
     grobal {1}.aaa.hbal avabal {1}.aaa.accrued
     intrat ytdint {1}.cif.pss {1}.aaa.lstdb {1}.aaa.ddt
     {1}.aaa.lstcr {1}.aaa.cdt {1}.aaa.regdt {1}.aaa.opnamt
     {1}.aaa.expdt mbal {1}.aaa.fbal
     with frame aaa no-label.
inner:
repeat:
  update vdet  with frame aaa.
  if vdet eq true then do:
    for each {1}.aas where {1}.aas.aaa eq {1}.aaa.aaa and {1}.aas.sic eq "SP":
      disp {1}.aas.regdt {1}.aas.chkamt {1}.aas.payee {1}.aas.expdt
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
end. /* inner repeat */
