/* aaaq-cda.p
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25/01/2011 evseev - % ставка из счета для 518,519,520
        07.08.2013 evseev - tz-1834
        15.08.2013 evseev - перекомпиляция
        09.09.2013 evseev - tz-1376
*/

/* aaaq-cda.p
*/

def new shared var vled like led.led initial "cda".
def var qaaa like aaa.aaa.
define buffer b-aaa for aaa.
define var grobal  like jl.dam.
define var avabal  like grobal.
define var intrat  like rate.rate.
define var mtddb   like grobal.
define var mtdcr   like grobal.
define var ytdint  like grobal.
define var mbal    like grobal.
define var vdaytm  as int.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
def var vterm as inte.
def var vday as inte.
def var v-staname as char.


{mainhead.i TDQRY}  /* TIME DEPOSIT INQUIRY */

{aaaq-cda.f}

outer:
repeat:
  clear frame faaa.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq "" then do :
                    update qaaa with frame faaa.
                    find aaa where aaa.aaa eq qaaa no-lock no-error.
                    if not available aaa then undo,retry.
                 end.
                 else do:
                    qaaa = g-aaa.
                    display qaaa with frame faaa.
                 end.
 /*  editing: {gethelp.i} end. */
  find aaa where aaa.aaa eq qaaa no-lock.
  find cif of aaa no-lock.
  find crc of aaa no-lock.
  find lgr where lgr.lgr eq aaa.lgr no-lock.
  if lgr.led ne "CDA" then do:
         bell.
         {mesg.i 8212}.
         undo, retry.
  end.

  if (lookup(lgr.lgr,"518,519,520") = 0) then do:
      if lgr.lookaaa eq true then do:
         if aaa.pri ne "F" then do:
            find pri where pri.pri eq aaa.pri no-lock no-error.
            intrat = pri.rate + aaa.rate.
         end.
         else intrat = aaa.rate.
      end.
      else do:
         if aaa.pri ne "F" then do:
            find pri where pri.pri eq lgr.pri no-lock.
            intrat = pri.rate + lgr.rate.
         end.
         else intrat = lgr.rate.
      end.
  end.
  else do:
     intrat = aaa.rate.
  end.
  find first sysc where sysc.sysc = "vip-com" no-lock no-error.
  if avail sysc and sysc.chval matches "*" + aaa.aaa + "*" then do:
      find last compens_data where compens_data.acc = aaa.aaa no-lock no-error.
      if avail compens_data then  intrat = compens_data.rate.
  end.

  vdaytm = aaa.expdt - aaa.regdt.
  if lgr.complex  eq false then
     mbal = aaa.opnamt * (1 + aaa.rate * vdaytm / aaa.base / 100).
  else mbal = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100, vdaytm).
  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal - aaa.hbal.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb  = aaa.dr[1] - aaa.mdr[1].
  mtdcr  = aaa.cr[1] - aaa.mcr[1].
  vterm = aaa.expdt - g-today /*+ 1*/.
  vday  = aaa.expdt - aaa.regdt.
  v-staname = "".
  if aaa.sta = "A" then v-staname = "активный".
  else if aaa.sta = "C" then v-staname = "закрыт".
  else if aaa.sta = "N" then v-staname = "новый".
  else if aaa.sta = "E" then v-staname = "закрытие счета".

/*
     "КОД КЛИЕНТА: -" cif.cif
     "НАИМЕНОВАНИЕ:" at 41 cif.sname format "x(20)" skip skip
     "НОМЕР СЧЕТА:" qaaa "(" aaa.gl ")"
     "ВАЛЮТА СЧЕТА:    " at 41 crc.code skip
     "ГРУППА СЧЕТА:" lgr.des
     "СТАТУС: " at 41 aaa.sta "-" v-staname skip
     "СРОК ВКЛАДА(В ДНЯХ) :" vday
     "ПРОЦЕНТ    %" at 41 intrat skip
     "ОСТАЛОСЬ(ДНЕЙ):" vterm skip
     "ДАТА ОТКР. :" aaa.regdt format "99/99/9999"
     "СУММА ОТКР.:" at 41 aaa.opnamt skip
     "ДАТА ЗАКР. :"  aaa.expdt format "99/99/9999"
     "СУММА ЗАКР.:" at 41 mbal skip skip
     "ПОСЛ.ДЕБЕТ::" aaa.lstdb
     "ДАТА ПОСЛЕДНЕГО ДЕБЕТА:" at 41 aaa.ddt format "99/99/9999" skip
     "ПОСЛ.КРЕДИТ:" aaa.lstcr
     "ДАТА ПОСЛЕДНЕГО КРЕДИТА:" at 41 aaa.cdt format "99/99/9999" skip
*/

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
     vday
     intrat
     vterm
     aaa.regdt
     aaa.opnamt
     aaa.expdt
     mbal
     aaa.lstdb
     aaa.ddt
     aaa.lstcr
     aaa.cdt
     with frame faaa no-label.
  message "F4 - выход; P - % за каждый день".
  inner:
  repeat:
      readkey.
      if keyfunction(lastkey) eq "END-ERROR" then do:
         hide frame faaa.
         leave inner.
      end.
      if keyfunction(lastkey) eq "P" then do:
         if available aaa then run p_show (aaa.aaa).
         readkey pause 0.
      end.
      apply lastkey.
  end.
end.
