/* aaal-cda.p
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

/* aaaq-cda.p
   31.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
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
  if lgr.led ne "CDA"
  then do:
         bell.
         {mesg.i 8212}.
         undo, retry.
       end.
  if lgr.lookaaa eq true
  then do:
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

  /*display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname qaaa  aaa.gl
     cif.tel
     aaa.sta   crc.code
     grobal vday  aaa.hbal vdet
     avabal vstop vterm
     aaa.accrued
     intrat
     ytdint
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt aaa.opnamt
     aaa.expdt
     mbal
     aaa.fbal
     with frame faaa no-label.*/

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

     pause.
     leave.
/*  inner:
  repeat:
    update vdet  with frame faaa.
    if vdet eq true
    then do:
           for each aas where aas.aaa eq aaa.aaa and aas.sic eq "HB":
             {aq-cdahb.f}
             display aas.regdt aas.chkamt aas.payee with frame hb.
           end.
           vdet = false.
         end.

    update vrel with frame faaa
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
     update vstop with frame faaa
    editing:
      readkey.
      if keyfunction(lastkey) eq "END-ERROR" then leave inner.
      apply lastkey.
    end.
    if vstop eq true
    then do:
           for each aas where aas.aaa eq aaa.aaa and aas.sic eq "SP":
             {aq-cdasp.f}
             display aas.chkdt aas.chkno aas.chkamt aas.payee
             with frame sp.
           end.
           vstop = false.
         end.
  end.*/
end.
