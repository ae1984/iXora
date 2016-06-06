/* accmaina.p
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
        31.12.1999 pragma
 * CHANGES
        11.02.1997 AGA     - заблокиpовано изменение статуса и удаление счета; оставлен только пpосмотp
        25.08.2003 nadejda - сделан запрос на номер счета без всяких условий
*/

{mainhead.i CFSTS}  /*  ACCOUNT MANAGEMENT  */

define buffer b-aaa for aaa.
def var s_aaa like aaa.aaa.
define var grobal like aas.chkamt decimals 2.
define var avabal like aas.chkamt decimals 2.
define var crline like aas.chkamt decimals 2.
define var crused like aas.chkamt decimals 2.
define var mtddb  like aas.chkamt decimals 2.
define var mtdcr  like aas.chkamt decimals 2.
define var ytdint like aas.chkamt decimals 2.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
define var vans    as log.
def var sstop as char format "x(15)" .
def var spnum as int format "zz9".
def var shold as char format "x(15)" .
def var shnum as int format "zz9".

{accmaint.f}

outer:
repeat:
  clear frame aaa.
  pause 0.
  crline = 0.
  crused = 0.
  if keyfunction(lastkey) eq "end-error" then return.
/* 25.08.2003 nadejda
  if g-aaa eq "" then prompt-for aaa.aaa with frame aaa.
                 else display g-aaa @ aaa.aaa with frame aaa.
*/  
  
  prompt-for aaa.aaa with frame aaa.

  find aaa using aaa.aaa no-lock no-error.
  find cif of aaa no-lock no-error.
  find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
  if aaa.loa ne "" and lgr.led eq "DDA"
  then do:
         find b-aaa where b-aaa.aaa eq aaa.loa no-lock no-error.
         crline = b-aaa.dr[5] - b-aaa.cr[5].
         crused = b-aaa.dr[1] - b-aaa.cr[1].
       end.
 
  if lgr.led eq "DDA" or lgr.lgr eq "151" then do:       
         s_aaa  = aaa.craccnt.
  end.

  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal + crline - crused.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  spnum = 0.
  shnum = 0.

 for each aas where aas.aaa eq aaa.aaa no-lock :
    if aas.sic = "SP" then spnum = spnum + 1.
    else  if aas.sic = "HB" then shnum = shnum + 1.
  end.
 if spnum > 0 then sstop = string(spnum) + " STOP PAYMENT".
              else sstop = "NO STOP PAYMENT".
 if shnum > 0 then shold = string(shnum) + " HOLD BALANCE".
              else shold = "NO HOLD BALANCE".

  display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname aaa.aaa s_aaa
     cif.tel aaa.sta aaa.grp
     grobal shold aaa.hbal
     avabal aaa.accrued
     crline ytdint
     crused
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     aaa.fbal
     sstop
     with frame aaa.

 if shnum > 0 then color display  messages  shold with frame aaa.
              else color display  input  shold with frame aaa.

 if spnum > 0   then do:
    color display  messages  sstop with frame aaa.
    pause 1.

for each aas where aas.aaa eq aaa.aaa no-lock:
  find sic of aas no-lock no-error.
  display aas.sic sic.des label "DESCRIPTION"  aas.regdt
          aas.chkdt aas.chkno aas.chkamt
          with row 9  9 down  overlay  centered
    title " Special Instructions for (" + string(aas.aaa) + ")" frame aas.
  end.
  /*
  update  aaa.sta with no-validate frame aaa.
  if frame aaa aaa.sta entered then do:
    aaa.cltdt = g-today.
    aaa.who = g-ofc.
  end.   только для пpосмотpа   */

end.
else do:
  color display  input  sstop with frame aaa.
  /*
  {mesg.i 0916}.
  update  aaa.sta with no-validate frame aaa.
  if frame aaa aaa.sta entered then do:
    aaa.cltdt = g-today.
    aaa.whn = g-today.
    aaa.who = g-ofc.
  end.   только для пpосмотpа   */

  if keyfunction(lastkey) eq "GO"
    then do:
      bell.
      /*
      {mesg.i 0824} update vans.
      if vans then do:
        if can-find(first aal of aaa)
          then do:
            bell.
            {mesg.i 2202}.
            undo, retry.
          end.
        delete aaa.
      end.     */
    end.    
end.
end.
