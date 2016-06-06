/* pltque2.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
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
        TXB COMM 
 * AUTHOR
       19/11/2010 id00004
 * CHANGES
       12/09/2013 k.gitalov внедрение ИБФЛ

*/





{xmlParser.i}

def input parameter pAccount as char no-undo.
def output parameter rcod as char.
def output parameter rdes as char.

define variable v-out as log.
define variable v-des as char.
define variable tmp-char as character.                        
                        
  find last txb.aaa where txb.aaa.aaa = pAccount no-lock no-error.
  if avail txb.aaa then do:
    if (txb.aaa.lgr = "138" or txb.aaa.lgr = "139" or txb.aaa.lgr = "140") and txb.aaa.gl = 220430 then do:
      /*карт-счет*/
      run ow_send("GetBalance","",pAccount,"","","","","","","",output v-des,output v-out).
      if not v-out then do:
        rcod = "0".
        rdes = "Ошибка проверки остатка на счете". 
        return. 
      end.  
      rcod = "1".  
      rdes = GetParamValueOne(v-des,"Available"). 
    end.    
    else do:
        find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        if txb.lgr.led = "TDA" then do:
         /*Депозит, отображаем замороженную сумму*/
         rcod = "1".
         rdes = string(txb.aaa.hbal,">>>>>>>>>>>9.99") .
        end.
        else do:
         /*текущий*/  
         rcod = "1".
         rdes = string(txb.aaa.cbal - txb.aaa.hbal,">>>>>>>>>>>9.99") .
        end. 
    end.
  end.
  else do:

     rcod = "0".
     rdes = "Не найден счет" .
  end.