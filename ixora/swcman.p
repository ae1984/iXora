/* swcman.p
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
def var yn as log initial "no" .
def var upb as log init "no". 
def var v-ordins as char.

{global.i}
{lgps.i}
{rmz.f}
{ps-prmt.i}
find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
    message " Записи RMCASH нет в файле sysc . " .
    return.
    end  .
v-cashgl = sysc.inval .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Записи OURBNK нет в файле sysc  !!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

do transaction :

 find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
 if available remtrz and remtrz.jh1 = ? then do :

   v-psbank = remtrz.sbank.
   update v-psbank with frame remtrz.
   
    if v-psbank ne "" then do:
     find first bankl where bankl.bank = v-psbank no-lock no-error.
     if not avail bankl then do :
         message " ОШИБКА !!! Нет записи в файле BANKL !!!".
         pause.
         undo.
         return.
     end.
    end.
    else do :
     display remtrz.ordins with row 10 column 10 1 column overlay
      frame ord.
     message "Изменить БАНК-ОТПРАВИТЕЛЬ ? " update upb.
     find first bankl where bankl.bank = v-psbank no-lock no-error.
     if remtrz.scbank = "" then
        remtrz.scbank = bankl.cbank.
     if upb then do :
      if avail bankl then do : 
       v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " " +
           trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
       remtrz.ordins[1] = substr(v-ordins,1,35).
       remtrz.ordins[2] = substr(v-ordins,36,35).
       remtrz.ordins[3] = substr(v-ordins,71,35).
       remtrz.ordins[4] = substr(v-ordins,106,35).
      end.
       update remtrz.ordins with row 10 column 10 1 column overlay
             frame ord.
     end.
    end.
   remtrz.sbank = v-psbank.

   update remtrz.scbank validate(can-find (bankl where
      bankl.bank = remtrz.scbank ), "Банк не существует") with frame remtrz.

   find first bankt where bankt.cbank = remtrz.scbank and 
   bankt.crc = remtrz.fcrc and bankt.racc = "1" no-lock no-error .
   if not avail bankt then do:
       message " ОШИБКА !!! Нет записи в файле BANKT  !!! ".
       pause .
       undo .
       return.
   end.

     remtrz.dracc = bankt.acc.
            
     find first bankl where bankl.bank = remtrz.scbank no-lock no-error.
     if avail bankl then 
     remtrz.saddr = bankl.crbank.
     if bankt.subl = "dfb"
       then do:
         find first dfb where dfb.dfb = bankt.acc no-lock.
         remtrz.drgl = dfb.gl.
         find gl where gl.gl = remtrz.drgl no-lock.
       end.
     if bankt.subl = "cif"
       then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.drgl = aaa.gl.
          find gl where gl.gl = remtrz.drgl no-lock.
       end.
      display remtrz.scbank remtrz.dracc remtrz.drgl gl.sub
       with frame remtrz.
   v-text = " БАНКП и КорО исправлены вручную для  " + remtrz.remtrz .
   run lgps.
   release remtrz.
 end.
 else do :
   Message " 1 проводка сделана. Невозможно изменить !!". pause . 
 end.
end.
