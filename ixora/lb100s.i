/* lb100s.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Для программы формирования файла сообщения при выгрузке
        Определение переменных из sysc
 * RUN
        
 * CALLER
        lb100.p, lb100g.p, lb100tax.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-5-10
 * AUTHOR
        20.04.2004 nadejda - вынесено из lb100.p
 * CHANGES
*/

def var max102 as dec initial 0. 

find sysc where sysc.sysc = "lbto" + if {1} = "c" then "" else {1} no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  v-text = " ERROR !!! There isn't record LBTO" + if {1} = "c" then "" else caps({1}) + " in sysc file !! ".
  message v-text .
  return .
end.
v-unidir = sysc.chval .



find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  message " There isn't record OURBNK in sysc file !! " .
  return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "lbmfo" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  v-text = " ERROR !!! There isn't record LBMFO in sysc file !! ".
  message v-text .
  return .
 end.
v-lbmfo = sysc.chval .

 
find first sysc where sysc.sysc begins "swicod" no-lock no-error .
if not avail sysc then do :
  message " There isn't SWICOD record in sysc  " .  
  return .
end .
ourbic = sysc.chval .

find first bankl where bankl.bank = v-lbmfo no-lock no-error .
if not avail bankl then do:
  message " There isn't " + v-lbmfo +  " bank  code in bankl file " . 
  pause . 
  return . 
end.
lbbic = substring(bankl.bic,3) .                                  

find first sysc where sysc.sysc = "lbterm" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи lbterm в файле sysc".
  run lgps.
end.
v-tnum = trim(sysc.chval).                     

find first sysc where sysc.sysc = "clecod" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи clecod в файле sysc".
  run lgps.
end.
v-clecod = trim(sysc.chval).

find sysc where sysc.sysc = "regstr" no-lock no-error .
if avail sysc then regs = sysc.chval .
regs = regs + "!" .

if {1} <> "g" then do:
  find sysc where sysc.sysc = "netgro" no-lock no-error.
  if avail sysc then max102 = sysc.deval.
end.

