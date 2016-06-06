/* svl31.p
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
def var yn as log initial "no" format "Да/Нет". 
{global.i}
{lgps.i}
{rmz.f}
{ps-prmt.i}
find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
    message "Отсутствует запись RMCASH в таблице SYSC!" .
    return.
    end  .
v-cashgl = sysc.inval .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.
message "Вы уверены?" update yn . 
if yn then 
do transaction :

 find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
 if available remtrz and remtrz.jh1 = ? then do :
 
  find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
    if not avail bankl then do:
      message "Отсутствует запись в таблице BANKL!".
      pause .
      undo .
      return . 
    end.

     find first bankt where bankt.cbank = bankl.cbank 
      and bankt.crc = remtrz.fcrc
                 and bankt.racc = "1" no-lock no-error .
     
          if not avail bankt then do:
          message "Отсутствует запись в таблице BANKT!".
          pause .
          undo .
          return .
          end.

     
     if bankl.nu = "u" then sender = "u". else sender = "n" .
     remtrz.dracc = bankt.acc.
     remtrz.scbank = bankl.cbank . 
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
   v-text = "Д.Сч. и ДСГК переопределены для " + remtrz.remtrz .
   run lgps.
   release remtrz.
   Message "Выполнено.". bell . pause .    
end.
else do :
  Message "1 проводка выполнена. Невозмлжно отредактировать!". pause . 
end.
end.
