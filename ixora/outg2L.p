/* outg2L.p
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

{global.i}
def shared var s-remtrz like remtrz.remtrz.
def shared frame remtrz.
def var v-date as date.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def var dtt1 as cha format "x(70)". 
def var dtt2 as cha format "x(70)". 
def var sublist as cha .
def var ourbank as cha . 
def var sender like ptyp.sender . 
def var receiver like ptyp.receiver . 
 find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
 sublist = sysc.chval.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Записи OURBNK нет в файле sysc !!".
   pause .
   undo .
   return .
  end.
 ourbank = sysc.chval.


{lgps.i}
{rmz.f}


do transaction :
find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .

if remtrz.rbank ne ourbank  and rbank ne "" then do:
   message "  Банк-получатель не " + ourbank + "  !! " .  pause .
   bell . bell .
   undo . 
   return .
end.
if remtrz.jh2 ne ?   then do:
  message "  2 проводка уже сделана " + ourbank + "  !! " .
    pause .   bell . bell .
    return .
   end.




if remtrz.rbank = "" then do: 
 remtrz.rbank = ourbank . 
 remtrz.rcbank = ourbank . 
display remtrz.rbank remtrz.rcbank with frame remtrz . 
find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
if avail bankl then 
  if bankl.nu = "u" then sender  = "u". else sender  = "n" .
 find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
if avail bankl then
 if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .

if remtrz.scbank = ourbank then sender = "o" .   
if remtrz.rcbank = ourbank then receiver  = "o" .

if remtrz.ptype ne "H" and remtrz.ptype ne "M"  then do :
  find first ptyp where ptyp.sender = sender and
  ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then
  remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".
 end .
 find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error . 
 if avail que then  
 que.ptype = remtrz.ptype . 
 if sender = "o" and receiver = "o" then remtrz.ptype = "M".

 find first ptyp where ptyp.ptype = remtrz.ptype no-lock .
 display  remtrz.ptype ptyp.des with frame remtrz.
end .

 if available remtrz then do :
    do on error undo,retry :
     update remtrz.rsub validate(remtrz.rsub ne "","")  with frame remtrz .
     if lookup(remtrz.rsub,sublist) = 0 then undo , retry .
    end .
  if remtrz.source = "I" then do:
   if remtrz.rsub ne ""
   then do:
     update remtrz.racc validate(remtrz.racc ne "","") with frame remtrz.
     remtrz.ba = remtrz.racc .
     display remtrz.ba with frame remtrz . pause 0 . 
   end .

 update remtrz.ord validate(remtrz.ord ne "","") with frame remtrz.
 remtrz.ordcst[1] = remtrz.ord.
 update remtrz.bn with frame remtrz.
 remtrz.ben[1] = trim(remtrz.bn[1]) + " " +  trim(remtrz.bn[2])
          + " " + trim(remtrz.bn[3]).
      do on error undo , leave  :
        dtt1 = remtrz.rcvinfo[1] .
        dtt2 = remtrz.rcvinfo[2] .
        
        update  dtt1 dtt2 with overlay  no-label top-only row 8 1 col centered
        title "  Детали платежа " frame adsd.
        remtrz.detpay[1] = substr(dtt1,1,35) .
        remtrz.detpay[2] = substr(dtt1,36,35) .
        remtrz.detpay[3] = substr(dtt2,1,35) .
        remtrz.detpay[4] = substr(dtt2,36,35) .
        remtrz.rcvinfo[1] = dtt1 .
        remtrz.rcvinfo[2] = dtt2 .
      end.
     end. 
  v-text = remtrz.remtrz + " ТИП = " + remtrz.ptype + " " 
  + " Изменение признака платежа сделан пользователем " + g-ofc + " ПрПл = " 
    + remtrz.rsub  . 
  run lgps .
  que.df = today . 
  release remtrz.
end.
end.
