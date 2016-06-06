/* vcdocfil.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Копирование справочника Основание закрытия контракта на филиалы
 * RUN
        
 * CALLER
       vcreason.p  
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
       26.05.2008 galina   
 * CHANGES
       27.05.2008 galina - перекопеляция
        
*/


def input parameter p-code like bank.{&head}.code.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if txb.sysc.chval = "TXB00"  then return.

find bank.{&head} where bank.{&head}.codfr = {&codfr} and  bank.{&head}.code = p-code no-lock no-error.
find txb.{&head} where txb.{&head}.codfr = {&codfr} and  txb.{&head}.code = p-code exclusive-lock no-error.
do transaction on error undo, retry:
  if not avail txb.{&head} then do:
    create txb.{&head}.
    txb.{&head}.code = p-code.
    txb.{&head}.codfr = bank.{&head}.codfr. 
    txb.{&head}.level = bank.{&head}.level. 
    txb.{&head}.tree-node = bank.{&head}.tree-node.
  end.
    txb.{&head}.name[1] = bank.{&head}.name[1]. 
    txb.{&head}.name[2] = bank.{&head}.name[2]. 
    txb.{&head}.name[5] = bank.{&head}.name[5]. 
end.

