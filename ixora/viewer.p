/* viewer.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Просмотр сделок
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
        23.09.05 ten 
 * CHANGES
      
*/
{mainhead.i MMD}
define variable v-bankl like bankl.bank.
def var v-add as dec format ">>>.999".
define new shared variable v-fungrp like fungrp.fungrp.
DEF VAR vgl LIKE gl.gl.
def var p-open as decimal.
def var v-open as decimal.
def var vdeal like deal.deal.
def var v-close as decimal.
def var p-close as decimal.
define variable v-crc like crc.crc.
define variable v-code like crc.code.
def var v-grp as char.
DEF VAR days AS INT FORMAT "999" LABEL "DAYS " INITIAL 360.

define variable c-gl as character.
define variable scn-s as decimal.
define variable scf-s as decimal.
define variable dkav  as decimal.
define variable ckav  as decimal.
define variable dblok as decimal.
define variable cblok as decimal.
define variable v-klmbd as integer.
define variable kl-n as character.
define variable ndn-s as decimal.
define variable ndf-s as decimal.


/*{global.i}*/

  prompt "Введите номер сделки" vdeal with frame deal1 row 5 no-label centered.
  find deal where deal.deal eq input vdeal  no-error.
  if not avail deal 
  then do:
       message "Не найдена сделка " input vdeal.
       pause.
       undo, retry.
  end.

  v-fungrp = deal.grp.

 if (v-fungrp = 228 or v-fungrp = 229 or v-fungrp = 230 or v-fungrp = 231)  then do: 

{ver.f}
   clear frame deal2.
   find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.     
          v-add = deal.brkgfee.
          v-bankl = deal.bank.
          p-open = deal.prn / 100.
          v-open = round(p-open * deal.ncrc[2],2).
          p-close = round((p-open * deal.intrate / 100 / 365 * deal.trm + p-open),4).
          v-close = round(p-close * deal.ncrc[2],2).
         
  find dfb where dfb.dfb = deal.atvalueon[1] no-lock no-error.
       if available dfb
          then do:
               v-crc = dfb.crc.
               find crc where crc.crc = v-crc no-lock no-error.
               v-code = crc.code.
               display v-crc v-code with frame deal2.
          end.     

       vgl = fungrp.gl.
       display vgl WITH FRAME deal2.
            
  FIND bankl WHERE bankl.bank EQ deal.bank no-lock no-error.
          FIND gl WHERE gl.gl EQ deal.gl no-lock no-error.
          FIND codfr WHERE codfr.codfr EQ 'secur' 
          and codfr.code = deal.rem[3] no-lock no-error.
          if available codfr then display codfr.name[1] with frame deal2.
          if available gl
          then display gl.des with frame deal2.
          if available bankl
          then display bankl.name with frame deal2.
          DISP v-fungrp 
               p-open
               v-open
               p-close
               v-close
               deal.gl @ vgl 
               deal.deal 
               v-bankl 
               deal.yield 
               deal.intrate 
               deal.maturedt                
               deal.trm 
               deal.regdt 
               deal.rem[3]
               deal.ncrc[1] 
               deal.ncrc[2]
               deal.arrange 
               deal.atvalueon[3] 
               v-add  format "->>>.999"
          WITH FRAME deal2.
      
  if avail codfr then displ codfr.name[1] with frame deal2.
end.
else do:
clear frame deal.
          deal.intamt = deal.prn * deal.intrate * deal.trm / (days * 100).
          if deal.intamt > 0 and deal.prn > 0 and deal.intrate > 0 and 
             deal.trm > 0
          then days = deal.prn * deal.intrate * deal.trm / 
                      (100 * deal.intamt).

{ver1.f}      
    find fun where fun.fun eq deal.deal  no-error.
    if fun.interest > 0 
    then fun.basedy = fun.amt * fun.trm *
                      fun.intrate / fun.interest / 100.
    find sub-cod where sub-cod.sub = "FUN" and sub-cod.acc = fun.fun and 
         sub-cod.d-cod = "klmbd" exclusive-lock no-error.
    if available sub-cod
    then v-klmbd = integer(sub-cod.ccode).
    else v-klmbd = 0.
    find codfr where codfr.codfr = "klmbd" and 
         codfr.code = string(v-klmbd,"999") no-lock no-error.
    kl-n = codfr.name[1].
    ndn-s = round(v-klmbd * (fun.dam[1] - fun.cam[1]) / 100,2).
    find trxbal where trxbal.subled =  "FUN" and trxbal.acc = fun.fun and 
         trxbal.level = 3 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then ndf-s = trxbal.cam - trxbal.dam.
    else ndf-s = 0.
    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 6 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then scf-s = trxbal.dam - trxbal.cam.
    else scf-s = 0.
    scn-s = fun.amt.
    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 4 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then do:
         dkav = trxbal.dam.
         ckav = trxbal.cam.
    end.
    else do:
         dkav = 0.
         ckav = 0.
    end.     

    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 5 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then do:
         dblok = trxbal.dam.
         cblok = trxbal.cam.
    end.
    else do:
         dblok = 0.
         cblok = 0.
    end.
    find fungrp where fungrp.fungrp = v-fungrp no-lock no-error.
    if available fungrp
    then do:
         find gl where gl.gl = fun.gl no-lock no-error.
         c-gl = string(gl.gl) + " " + gl.des.
    end.

      fun.trm = fun.duedt - fun.rdt.
          FIND bankl WHERE bankl.bank EQ fun.bank no-lock no-error.
               fun.cst = bankl.name.
          DISP v-fungrp 
               deal.deal 
               bankl.bank 
               fun.rdt
               fun.trm 
               deal.prn
               fun.intrate 
               fun.interest 
               deal.maturedt
/*               deal.valdt */
               fun.duedt                
/*               deal.regdt */
               deal.inttype 
               fun.rem
               fun.cam[1]
               fun.cam[2]
               fun.dam[1]
               fun.dam[2]
               fun.basedy
               fun.crc
               c-gl
               dkav
               ckav
               dblok
               cblok
               scn-s
               scf-s
               v-klmbd
               fun.cst
          WITH FRAME fun.

end.