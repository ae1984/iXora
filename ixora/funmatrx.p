/* funmatrx.p
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
        26/12/03 nataly  для платежей типа MDD передается значение , что выгоняется осн сумма или %%
*/

/* funmatrx.p from s-funstl.p
   Fun Mature Date TRX with TRX Generator 
   Started 21/04/1999: Last Mo: 22/04/1999   */

{proghead.i}
/* W/T */
DEF SHARED VAR srem  AS CHAR FORMAT "x(75)"  EXTENT 5.
DEF SHARED VAR wfln LIKE wf.ln.
DEF SHARED VAR s-bank LIKE bankl.bank.
DEF SHARED VAR s-fun LIKE fun.fun.  /* acct # */
DEF SHARED VAR s-jh  LIKE jh.jh.
DEF SHARED VAR s-gl LIKE gl.gl.     /* payment gl # */
DEF SHARED VAR s-acc LIKE jl.acc.   /* payment acct # */
def shared var s-amt as decimal. 
define new shared variable s-source like remtrz.source.
DEF NEW SHARED VAR s-nostro as char.
def new shared var s-ba as char. 
DEF VAR vrem AS cha FORMAT "x(55)" EXTENT 7.
DEF VAR vamt LIKE jl.dam.   /* 1 level - Principal (Open Amount) */
def var vamt1 like vamt.    /* 2 level - Acrrued Interests       */
def var vamt2 like vamt.    /* 3 level - fun.interest - 2 level  */
def var vdel as char format "X(1)" init "^". 
def var remline1 as char. 
def var remline2 as char. 
def var remline3 as char. 
def var trxcode as char format "X(7)". 
def var v-party as char. 
def var vparam as char.
DEF VAR vans AS LOG INIT FALSE.
def var rcode as integer.
def var rdes as char.
def var samt1 like jl.dam.
def var samt2 like jl.dam.

DEF VAR deal-gl like sysc.inval. /* промежут. var */
def new shared var vjh like jh.jh.
define variable kas as character.

/*03/03/2004*/
define new shared variable vamt11 as decimal.
define new shared variable vamt21 as decimal.

define variable vamt3  as decimal.
define variable vamt-p as decimal.
define variable vamt-k as decimal.
define variable vamt-b as decimal.
define shared variable s-frem like remtrz.remtrz.
define variable rcd as logical.
define variable s-glrem like gl.gl.
define variable ja-ne as logical.
define variable m-dt as date.
define variable v-weekbeg as integer init 2.
define variable v-weekend as integer init 6.


form bankl.name                      label "Контрагент...."
     fun.fun                         label "Номер сделки.." 
     kas                             no-label skip
     vamt1  format ">>>,>>>,>>9.99"  label "Долг суммы...."
     vamt11 format ">>>,>>>,>>9.99"  label "Оплата........" 
     validate(vamt11 >= 0 and vamt11 <= vamt1," ") skip
     vamt2  format ">>>,>>>,>>9.99"  label "Долг процентов"
     vamt21 format ">>>,>>>,>>9.99"  label "Оплата........"
     validate(vamt21 >= 0 and vamt21 <= vamt2," ") skip
     ja-ne                           label "OK ?.........."
     vamt3  format ">>>,>>>,>>9.99"  label "Превышение...."
     with side-label overlay row 6 centered frame pay.


find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc
then v-weekbeg = sysc.inval.
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc
then v-weekend = sysc.inval.


FIND fun WHERE fun.fun EQ s-fun exclusive-lock.
find gl where gl.gl = fun.gl no-lock.
find bankl where bankl.bank = fun.bank no-lock.
find first bankt where bankt.cbank = bankl.cbank and 
     bankt.crc = fun.crc and bankt.racc = "1" and
     bankt.subl = "DFB" no-lock no-error .
if not available bankt
then do:
     message "Отсутствует запись для банка" +
             bankl.cbank + "в таблице BANKT!".
     pause .
     undo,return "1".
end.     
m-dt = g-today + bankt.vdate .
if m-dt = g-today and bankt.vtime < time
then m-dt = m-dt + 1 .
repeat:
   find hol where hol.hol eq m-dt no-lock no-error.
   if not available hol and 
          weekday(m-dt) ge v-weekbeg and
          weekday(m-dt) le v-weekend 
   then leave.
   else m-dt = m-dt + 1.
end.
 


IF m-dt < fun.duedt 
THEN DO:
     message "Не наступил срок завершения (" fun.duedt "). Подолжить ?"
     update vans.
     IF not vans  
     then undo,return "1".
END.
v-party = s-fun.
srem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
if fun.grp < 50
then kas = "Кредит".
else kas = "Депозит".
if gl.type = "A"
then do:
     vamt-p = fun.dam[1] - fun.cam[1].
     vamt-k = fun.dam[4] - fun.cam[4].
     vamt-b = fun.dam[5] - fun.cam[5].
     vamt1 = vamt-p + vamt-k + vamt-b.
     vamt2 = /*fun.interest*/ fun.dam[2] - fun.cam[2].
     if vamt2 < 0 then vamt2 = - vamt2.
end.          
else if gl.type = "L"
then do:
     vamt1 = fun.cam[1] - fun.dam[1].
     vamt2 = /*fun.interest -*/ fun.cam[2] - fun.dam[2]. 
     if vamt2 < 0 then vamt2 = - vamt2.
     s-amt = vamt1 + vamt2.
end.
vamt3 = s-amt - vamt1 - vamt2.
vamt11 = vamt1.
vamt21 = vamt2.
if vamt3 < 0
then do:
     vamt21 = vamt21 + vamt3.
     if vamt21 < 0
     then do:
          vamt11 = s-amt.
          vamt21 = 0.
     end.
     vamt3 = 0.
end.
find bankl where bankl.bank = fun.bank no-lock.
ja-ne = false.
display fun.fun
        bankl.name
        kas
        vamt1 
        vamt11
        vamt2
        vamt21
        ja-ne
        vamt3
        with frame pay.
if gl.type = "L" or gl.type = "A" and s-amt >= vamt1 + vamt2
then do:
     update vamt11 with frame pay. 
     update vamt21 with frame pay. 
     update  ja-ne with frame pay.
     if not ja-ne
     then undo,return "1".
end.     
else if gl.type = "A" and s-amt < vamt1 + vamt2
then do:
     repeat on endkey undo,return "1":
        update vamt11  with frame pay.
        if frame pay vamt11 entered
        then do:
             if s-amt - vamt11 > vamt2
             then undo,retry.
             vamt21 = s-amt - vamt11.
             display vamt21 with frame pay.
        end.     
        update vamt21 with frame pay.        
        if frame pay vamt21 entered
        then do:
             if s-amt - vamt21 > vamt1
             then undo,retry.
             vamt11 = s-amt - vamt21.
             display vamt11 with frame pay.
        end.       
        update vamt11 with frame pay. 
        update vamt21 with frame pay. 
        update ja-ne with frame pay.
        if ja-ne
        then leave.
     end.
end.
vrem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
vrem[2] = "Срок: " + STRING(fun.rdt) + "-" +  STRING(fun.duedt) +
          "(" + STRING(fun.duedt - fun.rdt) + " Дней)".
vrem[3] = "% ставка:" + STRING(fun.intrate) + "%".
vrem[4] = "Номер сделки:" + s-fun.
vrem[5] = "aaa".
remline1 = vrem[1] + vdel + vrem[2] + vdel + vrem[3] + vdel + vrem[4] + 
           vdel + vrem[5]. 

 /*  ROPYGL и RMPYGL для дилинга !!!; переход на новую GL */



vrem[1] = fun.fun + " " + fun.bank + " " + fun.cst.
vrem[2] = "" + STRING(fun.amt) +  "*" + 
          STRING(fun.intrate) + "%" + "*" +
          STRING(fun.duedt - fun.rdt) + "(" + 
          STRING(fun.duedt) + "-" + STRING(fun.rdt) + ")" + "/" + 
          STRING(fun.basedy).
vrem[3] = "Ref:" + s-fun.
remline3 = vrem[1] + vdel + vrem[2] + vdel + vrem[3] +
           vdel + vrem[4] + vdel + vrem[5]. 

s-amt = vamt11 + vamt21.
s-nostro = fun.payacc.  /* Mature */
s-ba = fun.accpay.
 
IF gl.type = "L" 
THEN DO:
     s-source = "MDD".

     run rmoutmar. 
     if return-value = "1"
     then return.
     fun.sts = 2.
     if vamt11 > 0
     then fun.ddt[1] = g-today.
     pause 0.
END.
else if gl.type = "A"
then do:
     run chkfunps(s-frem,"MMR",output rcd). 
     if not rcd
     then do:
          message "Нет такого перевода !".
          pause. 
          undo,return "1".
     end.
     find remtrz where remtrz.remtrz = s-frem no-lock.
     if trim(remtrz.INFO[10]) <> ""
     then s-glrem = integer(trim(remtrz.INFO[10])).
     if vamt-p > 0
     then do:
          if vamt-p >= vamt11
          then do:
               vamt-p = vamt11.
               vamt11 = 0.
               vamt-k = 0.
               vamt-b = 0.
          end.
          else vamt11 = vamt11 - vamt-p.
          vparam = v-party + vdel + string(vamt-p) + vdel + string(fun.crc) +
                   vdel + string(s-glrem) + vdel + s-fun + vdel + remline1.
                   
          trxcode = "MAR0038".
          run trxgen(trxcode,"^",vparam,"","",output rcode, output rdes,
                     input-output vjh). 
          if rcode <> 0 
          then do :
               message "Ошибка " rcode rdes view-as alert-box.
               undo,return "1".
          end.
     end.
     if vamt-k > 0
     then do:
          if vamt-k >= vamt11
          then do:
               vamt-k = vamt11.
               vamt11 = 0.
               vamt-b = 0.
          end.
          else vamt11 = vamt11 - vamt-k.
          vparam = v-party + vdel + string(vamt-k) + vdel + string(fun.crc) +
                   vdel + string(s-glrem) + vdel + s-fun + vdel + remline1.
                   
          trxcode = "MAR0046".
          run trxgen(trxcode,"^",vparam,"","",output rcode, output rdes,                              input-output vjh). 
          if rcode <> 0 
          then do :
               message "Ошибка " rcode rdes view-as alert-box.
               undo,return "1".
          end.
     end.
     if vamt-b > 0
     then do:
          vamt-b = vamt11.
          vparam = v-party + vdel + string(vamt-b) + vdel + string(fun.crc) +
                   vdel + string(s-glrem) + vdel + s-fun + vdel + remline1.
                   
          trxcode = "MAR0047".
          run trxgen(trxcode,"^",vparam,"","",output rcode, output rdes,                             input-output vjh). 
          if rcode <> 0 
          then do :
               message "Ошибка " rcode rdes view-as alert-box.
               undo,return "1".
          end.
     end.
     if vamt21 > 0
     then do:
          vparam = v-party +  vdel + string(vamt21) + vdel + string(fun.crc) +                    vdel + string(s-glrem) + vdel + s-fun + vdel + remline1.
                   
          trxcode = "MAR0048".
          run trxgen(trxcode,"^",vparam,"","",output rcode, output rdes,                             input-output vjh). 
          if rcode <> 0 
          then do :
               message "Ошибка " rcode rdes view-as alert-box.
               undo,return "1".
          end.
     end.
     if vamt3 > 0
     then do:
          vparam = v-party + vdel + string(vamt3) + vdel +                                       string(fun.crc) + vdel + string(s-glrem) + vdel + remline3. 
          if fun.crc = 1 then trxcode = "MAR0050".         
             else trxcode = "MAR0049".
          run trxgen(trxcode,"^",vparam,"","",output rcode, output rdes,                             input-output vjh). 
          if rcode <> 0 
          then do :
               message "Ошибка " rcode rdes view-as alert-box.
               undo,return "1".
          end.
     end.
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
          fun.sts = 2.   
          if fun.remin = ?
          then fun.remin = "".
          fun.remin = s-frem + "," + fun.remin.
          fun.jh2 = vjh.
          if vamt11 > 0
          then fun.cdt[1] = g-today.
          if vamt21 > 0
          then fun.cdt[2] = g-today.
          run marvou(vjh).
     end.
     else do:
          bell.
          message "В операции не найден перевод !".
          pause.
          undo,return "1".
     end.
end.

PAUSE 0. 

