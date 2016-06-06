/* aaaq-oda.p
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

 /* aaaq-oda.p
*/

def new shared var vled like led.led init "ODA".
def var qaaa like aaa.aaa.
define buffer b-aaa for aaa.
define var grobal  like jl.dam.
define var avabal  like jl.dam.
define var crline  like jl.dam.
define var crused  like jl.dam.
define var mtddb   like jl.dam.
define var mtdcr   like jl.dam.
define var ytdint  like jl.dam.
define var vnet    like jl.dam.
def var v-int like aaa.accrued.
def var v-intrat like aaa.accrued.

define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
def var sstop as char format "x(16)" .
def var spnum as int format "zz9".
def var shold as char format "x(16)" .
def var shnum as int format "zz9".
def var mtd like jl.dam.
def var ytd like jl.dam.
def var vcnt as int format "z,zzz9".
{proghead.i "ODA Account Inquiry"}

{aaaq-oda.f}

repeat:
  clear frame aaa.
  crline = 0.
  crused = 0.
  if keyfunction(lastkey) eq "end-error" then return.

  if g-aaa eq "" then do:
                  update qaaa with frame aaa.
                  find aaa where aaa.aaa = qaaa no-lock no-error.
                  if not available aaa then undo,retry.
                  end.
                 else
                 do:
                 qaaa = g-aaa.
                 display qaaa with frame aaa.
                 end.

  find aaa where aaa.aaa eq qaaa no-lock.
  find cif of aaa no-lock.
  find lgr where lgr.lgr eq aaa.lgr no-lock.
  if lgr.led ne "ODA"
  then do:
         bell.
         message "NOT ODA ACCOUT ".
         undo, retry.
       end.

  crline = aaa.opnamt.
  crused = aaa.dr[1].
  avabal = aaa.opnamt + aaa.cr[1] - aaa.dr[1].
  vnet   = aaa.cbal.
  vcnt = aaa.cnt[1] + aaa.cnt[2] + aaa.cnt[3]
       - aaa.mcnt[1] - aaa.mcnt[2] - aaa.mcnt[3]  .
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].

 find crc of aaa.

 if day(g-today) ne 1 then
 mtd = aaa.mtdacc.
 /*
 round
 (aaa.mtdacc / ((g-today) - date(month(g-today),1,year(g-today))),crc.decpnt).
 */
 else mtd = 0.
 ytd = round(aaa.ytdacc / ((g-today) - date(1,1,year(g-today))),crc.decpnt).
 mtd = mtd * -1.
 ytd = ytd * -1.

  if lgr.lookaaa eq true
  then do:
         find pri where pri.pri eq aaa.pri no-lock no-error.
         v-intrat = pri.rate + aaa.rate.
       end.
  else do:
         find pri where pri.pri eq lgr.pri no-lock no-error.
         v-intrat = pri.rate + lgr.rate.
       end.

  v-int = - ( aaa.mtdacc + aaa.cr[1] - aaa.dr[1] ) * v-intrat / aaa.base / 100.



  display
     cif.cif   crc.code
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname qaaa
     cif.tel aaa.sta
     avabal vnet  vcnt
     crline ytdint
     v-int
     crused aaa.rate
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     aaa.fbal
     mtd
     ytd
     with frame aaa.
  end.
