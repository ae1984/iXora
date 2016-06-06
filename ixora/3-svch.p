/* 3-svch.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Корректировка комиссии в платеже в 5-2-8
 * RUN
        
 * CALLER
        верхнее меню
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-2-8
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        23.09.2003 nadejda  - проверка введенной суммы комиссии с учетом минимальной и максимальной суммы
        26.09.2003 nadejda  - добавлено определение комиссии по умолчанию для внешних валютных платежей и проверка при вводе кода комиссии
	02/06/2004 valery   - запретил изменять сумму комиссии если она расчиталась атоматически. Разрешено только если код комисси не выбран и сумма комиссии равна нулю
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        12.07.2006 ten      - убрал доступ в данный пункт
*/

def shared var s-remtrz like remtrz.remtrz.
def new shared var ee5 as cha initial "2" .
def shared frame remtrz.
def var v-date as date.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def var v-cashgl like gl.gl.
def var sender as cha.
def var receiver as cha.
def var ourbank as cha.
def var vbal as dec.
def buffer xaaa for aaa.
def var ibal as dec.
def var v-sub as char.

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if avail remtrz and remtrz.source = "IBH" then do:
message "Доступ в данный пункт запрещен!" view-as alert-box information button  ok.
return.
end.

{lgps.i}
{rmz.f}

{comchk.i}

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
    message " Записи RMCASH нет в sysc файле . " .
    return.
    end  .
v-cashgl = sysc.inval .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Записи OURBNK нет в sysc файле !!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

do transaction :

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if remtrz.ptype = "8" then do :
   Message "Невозможно изменить комиссионные для типа платежа 8 !".
   pause.
   return.
end.
if available remtrz and 
  ( (remtrz.source ne "H" and remtrz.jh2 = ?)
   or (remtrz.source = "H" and  remtrz.jh1 = ? ))
   then do :
   if remtrz.sbank = ourbank then sender = "o". else sender = "n".
   if remtrz.rbank = ourbank then receiver = "o". else receiver = "n".

   find first bankt where bankt.cbank = remtrz.scbank and
        bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
   if avail bankt then v-sub =  bankt.subl.

   update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
   if remtrz.source = "H" then ee5 = "5" . 

   /* определение кода комиссии */
   if remtrz.svccgr = 0 and sender = "o" and receiver = "n" and remtrz.fcrc <> 1 then do:
     /* если это внешний валютный платеж, то проставить по умолчанию комиссию за счет отправителя */
     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
     if avail aaa then do:
       {comdef.i &cif = " aaa.cif "}
     end.
   end.

   update remtrz.svccgr validate(chkkomcod(remtrz.svccgr), v-msgerr) with frame remtrz .
   if remtrz.svccgr > 0 then do:
    run comiss2 (output v-komissmin, output v-komissmax).

    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) 
                        and tarif2.stat = "r" no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp .
    display remtrz.svccgl pakal remtrz.svca with frame remtrz .
   end.
  
  if remtrz.svccgr = 0 then remtrz.svca = 0. /*valery 02/06/2004 если код комиссии выбран равным 0, то о какой сумме комиссии может идти речь, обнуляем предыдущее показание*/
  if remtrz.svca = 0 then do:  /*valery 02/06/2004 если сумма коммиссии оказалась после выбора кода комиссии нулевой, то только тогда позволяем ее редактировать*/
    update remtrz.svca validate (chkkomiss(remtrz.svca), v-msgerr) with frame remtrz.
  end. /*иначе, если сумма комиссии расчиталась автоматом, то нельзя ее редактировать*/

 if remtrz.svca > 0 then do:
   if sender = "o" and remtrz.dracc ne "" and remtrz.svcrc = remtrz.fcrc
    and remtrz.svcaaa eq "" and
     ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl )
   then  remtrz.svcaaa = remtrz.dracc .

   if receiver = "o" and remtrz.cracc ne "" and remtrz.svcrc = remtrz.tcrc
    and remtrz.svcaaa eq "" and
     ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.crgl )
   then  remtrz.svcaaa = remtrz.cracc .

   if receiver = "o" and remtrz.svcrc = remtrz.fcrc 
    and ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl ) and 
    remtrz.source = "sw" and remtrz.bi = "our" and v-sub = "cif" 
   then remtrz.svcaaa = remtrz.dracc.

    do on error undo,retry :
     update remtrz.svcaaa with frame remtrz.
/*  if remtrz.svcaaa ne "" then do:    */
      find first aaa where aaa.aaa = remtrz.svcaaa and aaa.crc = remtrz.svcrc
      no-lock no-error .
      if not avail aaa then undo,retry .
/*   end.    */
    end.
/*
   if remtrz.svcaaa eq "" then do:
       remtrz.svcgl = v-cashgl.
       Message " Service charge will be take through CASH G/L !!!! " .
       pause .
   end .
   else do :    */
     find aaa where aaa.aaa = remtrz.svcaaa no-lock .
     remtrz.svcgl = aaa.gl .

      

/* end.      */
   do on error undo,retry :
     update svccgl  with frame remtrz .
     find first gl where  gl.gl = remtrz.svccgl and gl.sub eq "" no-lock
          no-error .
     if not avail gl then undo,retry .
   end.
 end.
 else do:
     remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
     remtrz.svccgl = 0.
 end.

 display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.
     
     find first aaa where aaa.aaa = remtrz.svcaaa no-lock no-error .
     if avail aaa and remtrz.source = 'H' then do:
     if aaa.craccnt ne "" then
     find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error .
     if available xaaa then
     vbal = aaa.cbal - aaa.hbal + xaaa.cbal.
     else vbal = aaa.cbal - aaa.hbal.
     if remtrz.svcaaa = remtrz.dracc then
     ibal = vbal - remtrz.amt - remtrz.svca.
     else ibal = vbal - remtrz.svca .
                                            
     if ibal < 0 then    MESSAGE  "СУММА ПЛАТЕЖА + КОМИССИЯ БОЛЬШЕ ОСТАТКА НА      СЧЕТЕ " + remtrz.svcaaa.
     

    end.

  if remtrz.svcrc entered or remtrz.svccgr entered or remtrz.svcaaa entered or
     remtrz.svccgl entered or remtrz.svca entered then do :
    v-text = " Комиссия изменена для платежа  " + remtrz.remtrz .
    run lgps.
  end.
release remtrz.
end.
else do :
  Message " Проводка сделана. Комиссию изменить невозможно !!". pause.
end.
end.
