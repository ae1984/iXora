/* aaal-dda.p
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
        09.09.2013 tz-1376
*/

/* aaaq-dda.p
*/

def new shared var vled like led.led init "DDA".
def var qaaa like aaa.aaa.
define buffer b-aaa for aaa.
def var s_aaa like aaa.aaa.
define var grobal  like jl.dam.
define var avabal  like jl.dam.
define var crline  like jl.dam.
define var crused  like jl.dam.
define var mtddb   like jl.dam.
define var mtdcr   like jl.dam.
define var ytdint  like jl.dam.

define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
def var sstop as char format "x(16)" .
def var spnum as int format "zz9".
def var shold as char format "x(16)" .
def var shnum as int format "zz9".
def var mtd like jl.dam.
def var ytd like jl.dam.
def var v-staname as char.
def var v-labelname as char.

{mainhead.i} /* "DDA Account Inquiry" */

{aaaq-dda.f}

outer:
repeat:
  clear frame aaa.
  crline = 0.
  crused = 0.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq "" then do:
                  update qaaa with frame aaa.
                  find aaa where aaa.aaa = qaaa no-error.
                  if not available aaa then undo,retry.
                  end.
                 else
                 do:  qaaa = g-aaa.
                 display g-aaa @ qaaa with frame aaa.  end.
  find aaa where aaa.aaa = qaaa.
  find cif of aaa.
  find lgr where lgr.lgr eq aaa.lgr.
  if lgr.led ne "DDA"
  then do:
         bell.
         {mesg.i 8215}.
         undo, retry.
       end.
  if lgr.led eq "DDA" or lgr.lgr eq "151" then do:
    s_aaa = aaa.craccnt.
  end.
  if aaa.craccnt  ne ""
  then do:
         find b-aaa where b-aaa.aaa eq aaa.craccnt.
         crline = b-aaa.opnamt.
         crused = b-aaa.dr[1] - b-aaa.cr[1].
       end.
  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal + crline - crused - aaa.hbal.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  spnum = 0.
  shnum = 0.
 for each aas where
  aas.aaa eq aaa.aaa  no-lock :
    if aas.sic = "SP" then
    spnum = spnum + 1.
  else  if aas.sic = "HB" then
    shnum = shnum + 1.
  end.
 if spnum > 0 then
 sstop = string(spnum) + " STOP PAYMENT:".
 else
 sstop = "NO STOP PAYMENT:".
 if shnum > 0 then
 shold = string(shnum) + " HOLD BALANCE:".
 else
 shold = "NO HOLD BALANCE:".
 find crc of aaa.
 if day(g-today) ne 1 then
 mtd = round
 (aaa.mtdacc / ((g-today) - date(month(g-today),1,year(g-today))),crc.decpnt).
 else mtd = 0.
 ytd = round(aaa.ytdacc / ((g-today) - date(1,1,year(g-today))),crc.decpnt).

  v-staname = "".
  if aaa.sta = "A" then v-staname = "активный".
  else if aaa.sta = "C" then v-staname = "закрыт".
  else if aaa.sta = "N" then v-staname = "новый".
  else if aaa.sta = "E" then v-staname = "закрытие счета".
  v-labelname = "НАИМЕНОВАНИЕ: ".
  if cif.type = "P" then v-labelname = "      КЛИЕНТ: ".

  /*display
     cif.cif   crc.code
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname qaaa s_aaa
     cif.tel aaa.sta
     grobal shold aaa.hbal
     avabal aaa.accrued
     crline ytdint
     crused aaa.rate
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     aaa.fbal
     sstop
     mtd
     ytd
     with frame aaa.*/

  display
     cif.cif
     v-labelname
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname
     qaaa
     s_aaa
     crc.code
     lgr.lgr
     lgr.des
     aaa.sta
     v-staname
     aaa.regdt
     aaa.lstdb
     aaa.ddt
     aaa.lstcr
     aaa.cdt
     with frame aaa.

  pause.
  leave.

 /*if spnum > 0   then
  color display  messages  sstop with frame aaa.
  else
  color display  input sstop with frame aaa.
 if shnum > 0   then
  color display  messages  shold with frame aaa.
  else
  color display  input shold with frame aaa.
  pause.
  leave.*/
  /*
  inner:
  repeat:
    update vdet with frame aaa.
    if vdet eq true
    then do:
           for each aas where aas.aaa eq aaa.aaa and aas.sic eq "HB":
             display aas.regdt aas.chkamt aas.payee aas.expdt
             with title " HOLD BALANCE "
             down centered row 4 overlay top-only frame hb.
           end.
           vdet = false.
         end.
    update vrel with frame aaa
    editing:
      readkey.
      if keyfunction(lastkey) eq "END-ERROR" then leave inner.
      apply lastkey.
    end.
    if vrel eq true
    then do:
           g-cif = aaa.cif.
           run aaaq-rel.
           g-cif = "".
         end.

    update vstop with frame aaa
    editing:
      readkey.
      if keyfunction(lastkey) eq "END-ERROR" then leave inner.
      apply lastkey.
    end.
    if vstop eq true
    then do:
           for each aas where aas.aaa eq aaa.aaa and aas.sic eq "SP":
             display aas.chkdt aas.chkno aas.chkamt aas.payee
             aas.expdt
             with title " STOP PAYMENT "
             down centered row 4 overlay top-only frame sp.
           end.
           vstop = false.
         end.
  end.****/
end.
