/* aaal-csa.p
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

/* checked */
/* aaaq-csa.p

   31.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/

def new shared var vled like led.led init "CSA".
def var qaaa like aaa.aaa.
define buffer b-aaa for aaa.
define var grobal  like jl.dam.
define var avabal  like grobal.
define var intrat  like rate.rate.
define var mtddb   like grobal.
define var mtdcr   like grobal.
define var ytdint  like grobal.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.

{mainhead.i CSAQ} /* CLUB SAVINGS DEPOSIT INQUIRY */

{aaaq-csa.f}

outer:
repeat:
  clear frame aaa.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq "" then do:
                  update qaaa with frame aaa.
                  find aaa where aaa.aaa = qaaa no-error.
                  if not available aaa then undo,retry.
                  end.
                 else display g-aaa @ qaaa    with frame aaa.
  /* editing: {gethelp.i} end. */
  find aaa where aaa.aaa = qaaa.
  find cif of aaa.
  find lgr where lgr.lgr eq aaa.lgr.
  if lgr.led ne "CSA"
  then do:
         bell.
         {mesg.i 8214}.
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
  avabal = aaa.cbal - aaa.hbal.
  ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  display
     cif.cif
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname qaaa
     cif.tel aaa.sta
     grobal aaa.hbal
     avabal aaa.accrued
     intrat
     ytdint
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt
     aaa.fbal
     with frame aaa.
     pause.
     leave.
  /*
  inner:
  repeat:
    update vdet with frame aaa.
    if vdet eq true
    then do:
           for each aas where aas.aaa eq aaa.aaa and aas.sic eq "SP":
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
  end.*/
end.
