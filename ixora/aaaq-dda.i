/* aaaq-dda.i
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

/* aaaq-dda.i
*/

define var grobal  as dec format "zz,zzz,zzz.99-".
define var avabal  as dec format "zz,zzz,zzz.99-".
define var crline  as dec format "zz,zzz,zzz.99-" init 0.
define var crused  as dec format "zz,zzz,zzz.99-" init 0.
define var mtddb   as dec format "zz,zzz,zzz.99-".
define var mtdcr   as dec format "zz,zzz,zzz.99-".
define var ytdint  as dec format "zz,zzz,zzz.99-".
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
def var sstop as char format "x(15)" .
def var spnum as int format "zz9".
def var shold as char format "x(15)" .
def var shnum as int format "zz9".
def var vpreaaa as cha form "x(16)".
def var vaaaloa as cha form "x(16)".
def var g-cif as char format "x(8)".

/*{proghead.i "DDA Account Inquiry"}*/

form
     "CIF# -" {1}.cif.cif skip
     {1}.cif.sname             "ACCT#" at 41 {1}.aaa.aaa skip
     {1}.cif.tel               "STATUS      " at 41 {1}.aaa.sta skip
     "GROSS   BAL" grobal  shold at 41 {1}.aaa.hbal vdet skip
     "AVAIL   BAL" avabal
     "INT    ACCR" at 41 {1}.aaa.accrued format "zz,zzz,zzz.99-"  skip
     "CREDIT LINE" crline  "INT PD  YTD" at 41 ytdint  skip
     "CREDIT USED" crused  skip
                           {1}.cif.pss at 41 skip
     "LAST  DEBIT" {1}.aaa.lstdb
                           "LAST DB DATE" at 41 {1}.aaa.ddt skip
     "LAST CREDIT" {1}.aaa.lstcr
                           "LAST CR DATE" at 41 {1}.aaa.cdt skip
                           "OPEN    DATE" at 41 {1}.aaa.regdt skip(1)
     "Related A/C" vrel     sstop at 41 vstop skip(1)
     "FLOAT INFORMATION" skip
     "1" {1}.aaa.fbal[1]
     "3" {1}.aaa.fbal[3]
     "5" {1}.aaa.fbal[5]
     "7" {1}.aaa.fbal[7] skip
     "2" {1}.aaa.fbal[2]
     "4" {1}.aaa.fbal[4]
     "6" {1}.aaa.fbal[6] skip
     with title " ACCOUNT INFORMATION        BRANCH: " + {1}.cmp.name + " "
          centered row 3 no-label frame aaa.

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
if {1}.lgr.led ne "DDA" then do:
  bell.
  {mesg.i 8215}.
  undo, retry.
end.
if {1}.aaa.loa ne "" then do:
  vpreaaa = {1}.aaa.aaa.
  vaaaloa = {1}.aaa.loa.
  find {1}.aaa where {1}.aaa.aaa eq vaaaloa.
  crline = {1}.aaa.dr[5] - {1}.aaa.cr[5].
  crused = {1}.aaa.dr[1] - {1}.aaa.cr[1].
  find {1}.aaa where {1}.aaa.aaa eq vpreaaa.
end.
grobal = {1}.aaa.cr[1] - {1}.aaa.dr[1].
avabal = {1}.aaa.cbal + crline - crused - {1}.aaa.hbal.
ytdint = ({1}.aaa.dr[2] - {1}.aaa.idr[2]) - ({1}.aaa.cr[2] - {1}.aaa.icr[2]).
mtddb = {1}.aaa.dr[1] - {1}.aaa.mdr[1].
mtdcr = {1}.aaa.cr[1] - {1}.aaa.mcr[1].
spnum = 0.
shnum = 0.
for each {1}.aas where {1}.aas.aaa eq {1}.aaa.aaa  no-lock :
  if {1}.aas.sic = "SP"
    then spnum = spnum + 1.
    else  if {1}.aas.sic = "HB" then shnum = shnum + 1.
end.
if spnum > 0
  then sstop = string(spnum) + " STOP PAYMENT".
  else sstop = "NO STOP PAYMENT".
if shnum > 0
  then shold = string(shnum) + " HOLD BALANCE".
  else shold = "NO HOLD BALANCE".
pause 0.
display {1}.cif.cif trim(trim({1}.cif.prefix) + " " + trim({1}.cif.sname)) @ {1}.cif.sname {1}.aaa.aaa {1}.cif.tel {1}.aaa.sta
        grobal shold {1}.aaa.hbal avabal {1}.aaa.accrued crline ytdint
        crused {1}.cif.pss {1}.aaa.lstdb {1}.aaa.ddt {1}.aaa.lstcr {1}.aaa.cdt
        {1}.aaa.regdt {1}.aaa.fbal sstop
        with frame aaa.
if spnum > 0
  then color display  messages  sstop with frame aaa.
  else color display  input sstop with frame aaa.
if shnum > 0
  then color display  messages  shold with frame aaa.
  else color display  input shold with frame aaa.
inner:
repeat:
  update vdet with frame aaa.
  if vdet eq true then do:
    for each {1}.aas where {1}.aas.aaa eq {1}.aaa.aaa and {1}.aas.sic eq "HB":
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
      disp {1}.aas.chkdt {1}.aas.chkno {1}.aas.chkamt {1}.aas.payee
           {1}.aas.expdt
           with title " STOP PAYMENT "
           down centered row 4 overlay top-only frame sp.
    end.
    vstop = false.
  end.
end.
