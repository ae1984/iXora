/* io-chpbal.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование остатков по счетам для корпоративных клиентов интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        COMM TXB
 * AUTHOR
         26.07.2010 k.gitalov

*/

define input param pCif as char.

def buffer b-cashpool for comm.cashpool. 
def buffer b-cashpoolfill for comm.cashpool.

def shared temp-table balance
             field acc as char
             field crc as char
             field cifname as char
             field avail-balance as deci
             field total-balance as deci
             field over as deci
             field used_over as deci.
             
/******************************************************************************************************************/
function GetCifName returns char ( input icif as char):
  def buffer b-cif for txb.cif.
  def buffer b-sysc for txb.sysc.
  def var citi as char init "".
  find b-sysc where b-sysc.sysc = 'citi' no-lock no-error.
  if avail b-sysc then do:
   citi = "г." + trim(b-sysc.chval).
  end.
  
  find b-cif where b-cif.cif eq icif no-lock no-error. 
  if avail b-cif then
  do:
    return citi + " " + trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
  end.
  else return icif.
end function.           
/******************************************************************************************************************/           
function CreateRec returns int (input iCif as char , input iAcc as char ):
   def buffer b-aaa for txb.aaa.
   def buffer b-crc for txb.crc.
   def var vbal as deci. /*Остаток*/
   def var vavl as deci. /*Доступный остаток*/
   def var vhbal as deci.
   def var vfbal as deci.
   def var vcrline as deci. /*Овердрафт*/
   def var vcrlused as deci. /*Использованный овердрафт*/
   def var vooo as char.
   find first b-aaa where b-aaa.cif = iCif and b-aaa.aaa = iAcc no-lock no-error.
   find last b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
   if avail b-aaa and avail b-crc then
   do:
     run bal-txb (input b-aaa.aaa , output vbal , output vavl , output vhbal , output vfbal ,output  vcrline , output vcrlused ,output  vooo).
     create balance.
          balance.acc = iAcc.
          balance.crc = b-crc.code.
          balance.cifname = GetCifName(b-aaa.cif).
          balance.avail-balance = vavl.
          balance.total-balance = vbal.
          balance.over = vcrline.
          balance.used_over = vcrlused. 
   end. 
   return 0.
end function.
/******************************************************************************************************************/


   find first b-cashpool where b-cashpool.cif = pCif and b-cashpool.isgo = true no-lock no-error.
   if avail b-cashpool then
   do:
      CreateRec( b-cashpool.cif,b-cashpool.acc).
      for each b-cashpoolfill where b-cashpoolfill.cifgo = b-cashpool.cif and b-cashpoolfill.isgo = false and b-cashpoolfill.txb = b-cashpool.txb no-lock:
        CreateRec( b-cashpoolfill.cif,b-cashpoolfill.acc).
      end.
   end. 
  
 