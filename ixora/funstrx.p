/* funstrx.p
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
     01.04.2004   tsoy  две новые переменные vamt11 vamt21 как new shared  и vamt11 = fun.amt.
*/

/* funstrx.p from s-funiss.p
   TRX Generator version: Start Date Fun TRX 
*/

{proghead.i}
/* W/T */
DEF SHARED VAR srem AS CHAR FORMAT "x(75)" EXTENT 5. /* only difference */
DEF SHARED VAR s-fun LIKE fun.fun.  /* acct # */
def shared var s-amt as decimal.
define new shared variable s-source like remtrz.source.
def new shared var s-nostro like fun.rcvacc.
def new shared var s-ba as char.
DEF VAR vamt LIKE jl.dam.
def var vdel as char format "X(1)" init "^". 
define shared variable s-frem like remtrz.remtrz.
define variable s-glrem like gl.gl.
define variable vparam as character.
define variable vjh as integer.
define variable rcode as integer.
define variable rdes as character.
define variable ja-ne as logical.
define variable rcd as logical.

define new shared variable vamt11 as decimal init 0.
define new shared variable vamt21 as decimal init 0.


FIND fun WHERE fun.fun EQ s-fun exclusive-lock.
find gl where gl.gl eq fun.gl no-lock. 
FIND bankl WHERE bankl.bank EQ fun.bank NO-LOCK.

srem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
srem[2] = "Срок: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
          "(" + STRING(fun.duedt - fun.rdt) + " Дней)".
srem[3] = "% ставка:" + STRING(fun.intrate) + "%".
srem[4] = "Сумма % : " + STRING(fun.interest).
srem[5] = "Номер сделки: " + s-fun.
IF gl.type EQ "A" 
THEN DO:
     srem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
     FIND bankl WHERE bankl.bank = fun.tbank NO-LOCK.
     srem[2] = "Коррбанк" + bankl.name.
     FIND bankl WHERE bankl.bank EQ fun.bank NO-LOCK.
     srem[3] = "Коррбанк:" + bankl.name.
     IF fun.acct NE "" 
     THEN srem[4] = "Счет:" + fun.acct.
     ELSE srem[4] = "Счет:" + bankl.acct.
END.


IF fun.itype = "A" 
then vamt = fun.amt.
else if fun.itype = "D" 
then vamt = fun.amt - fun.interest.


s-nostro = fun.payacc.  /* Mature */ 
s-ba = fun.accpay. 

IF gl.type = "A" 
THEN DO:
     s-amt = vamt.
     s-source = "MDL".
     vamt11 = fun.amt.
     run rmoutmar. 
     if return-value = "1"
     then undo,retry.
     /*
     /*           !!!!         */
     find aaa where aaa.aaa = "2010000011" no-lock.
     vparam = fun.fun + vdel + string(s-amt) + vdel +
              fun.fun + vdel + srem[1] + vdel + string(s-amt) + vdel + 
              string(aaa.gl) + vdel + aaa.aaa  .
     run trxgen("MAR0036","^",vparam,"","",output rcode, output rdes,
         input-output vjh).
     if rcode <> 0 
     then do :
          message "Ошибка " rcode rdes view-as alert-box.
          undo,return.
     end.
     fun.jh1 = vjh.
     /* */     
     */
     fun.sts = 1.
     fun.ddt[1] = g-today.
     pause 0.
END.
else if gl.type = "L"
then do:
     run chkfunps(s-frem,"MMR",output rcd). 
     if not rcd
     then do:
          message "Нет такого перевода !".
          pause. 
          undo,retry.
     end.
     find remtrz where remtrz.remtrz = s-frem no-lock.
     if trim(remtrz.INFO[10]) <> ""
     then s-glrem = integer(trim(remtrz.INFO[10])).
     vparam = s-fun + vdel + string(s-amt) + vdel +
              string(fun.crc) + vdel + string(s-glrem) + vdel + 
              fun.fun + vdel +  srem[1] + vdel + srem[2] + vdel + 
              srem[3] + vdel + srem[4] + vdel + srem[5].
     run trxgen("MAR0037","^",vparam,"fun",fun.fun,output rcode, output rdes,              input-output vjh). 
     
     if rcode <> 0 
     then do :
          message "Ошибка " rcode rdes view-as alert-box.
          pause.
     end.
     else do:
          find remtrz where remtrz.remtrz = s-frem no-lock no-error.
          ja-ne = available remtrz.
          if ja-ne 
          then do:
               find first que where que.remtrz = s-frem no-lock no-error.
               if available que 
               then do:
                    if remtrz.jh2 = vjh and que.pid = "F"
                    then ja-ne = true.
                    else do:
                         run fungoF(s-frem,"MMR",vjh,output ja-ne).
                    end.
               end.
          end.
          if ja-ne
          then do:
               find deal where deal.deal = fun.fun exclusive-lock.
               deal.fun = fun.fun.
               release deal.
               fun.sts = 1.   
               fun.cdt[1] = g-today.
               fun.remin = s-frem.
               fun.jh2 = vjh.
               run marvou(vjh).
          end.
          else do:
               bell.
               message "В операции не найден перевод !".
               pause.
               undo,return.
          end.
     end.
end.

PAUSE 0.        
