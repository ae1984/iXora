/* aaaq-sav.p
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

/* aaaq-sav.p
*/

def new shared var vled like led.led init "SAV".
def var qaaa like aaa.aaa.
define buffer b-aaa for aaa.

define var grobal  like jl.dam.
define var avabal  like grobal.
define var lstint  like grobal.
define var mtddb   like grobal.
define var mtdcr   like grobal.
define var ytdint  like grobal.
define var intrat  like rate.rate.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
def var v-staname as char.

{mainhead.i SAVQ}  /*  SAVINGS ACCOUNT INQUIRY  */

{aaaq-sav.f}

outer:
repeat:
  clear frame aaa.
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
  /* editing: {gethelp.i} end. */
  find aaa where aaa.aaa eq qaaa no-lock.
  find crc where crc.crc eq aaa.crc no-lock.
  find cif of aaa no-lock no-error.
  find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
  if lgr.led ne "SAV"
  then do:
         bell.
         {mesg.i  8217}.
         undo, retry.
       end.
  if lgr.lookaaa eq true
  then do:
         find pri where pri.pri eq aaa.pri no-lock no-error.
         intrat = pri.rate + aaa.rate.
       end.
  else do:
         find pri where pri.pri eq lgr.pri no-lock no-error.
         intrat = pri.rate + lgr.rate.
       end.

   find last aal where aal.aaa eq aaa.aaa and aal.aax eq 66 no-lock no-error.
  if available aal then lstint = aal.amt.
  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal - aaa.hbal.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].

/*
     "КОД КЛИЕНТА: -" cif.cif
     "КЛИЕНТ: " at 25 cif.sname format "x(35)" skip skip
     "НОМЕР СЧЕТА: "  qaaa "(" aaa.gl ")"
     "ВАЛЮТА СЧЕТА: " at 41 crc.code skip
     "ГРУППА СЧЕТА:" lgr.des format "x(25)"
     "СТАТУС: " at 41 aaa.sta skip
     "ДАТА ОТКРЫТИЯ :" aaa.regdt skip
     "ПОСЛ. ДЕБЕТ:" aaa.lstdb
     "ПОСЛ.ДЕБЕТ :" at 41 aaa.ddt skip
     "ПОСЛ.КРЕДИТ:" aaa.lstcr
     "ПОСЛ.КРЕДИТ:" at 41 aaa.cdt skip
*/
  v-staname = "".
  if aaa.sta = "A" then v-staname = "активный".
  else if aaa.sta = "C" then v-staname = "закрыт".
  else if aaa.sta = "N" then v-staname = "новый".
  else if aaa.sta = "E" then v-staname = "закрытие счета".

  display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname
     qaaa
     aaa.gl
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
  message "F4 - выход".
  inner:
  repeat:
      readkey.
      if keyfunction(lastkey) eq "END-ERROR" then do:
         hide frame faaa.
         leave inner.
      end.
  end.
end.
