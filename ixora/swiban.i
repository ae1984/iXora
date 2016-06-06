/* swiban.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Проверка счета IBAN на валидность
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
        BANK COMM         
 * AUTHOR
        06.05.2010 k.gitalov
 * CHANGES
       
*/

def var LastAcc as char.
/*******************************************************************************************/
function CheckOldAcc returns log (input AccNo as char):
   def var ValidData as char extent 12 init ["0","1","2","3","4","5","6","7","8","9","-","/"].
   def var AccLen as int.
   def var i as int.
   def var j as int.
   def var r as log init false.
   AccLen = length(AccNo).
   
   repeat i = 1 to AccLen:
    repeat j = 1 to 12:
     if substr(AccNo,i,1) = ValidData[j] then
     do:
       r = true.
     end.
    end.
    if not r then do: message "Недопустимый символ '" substr(AccNo,i,1) "' в номере счета!" view-as alert-box. return false. end.
    r = false.
   end.
   
   return true.
end function.
/*******************************************************************************************/
function CheckIban returns log (input AccNo as char):
   def var KK as int.
   def var Rez as int.
   def var IAcc as DECIMAL.
   def var TmpStr as char.
   def var AccLen as int.
   def var i as int.
   def var j as int.
   def var r as log init false.
   AccLen = length(AccNo).
   KK = integer(substr(AccNo,3,2)).
   def var Sval as char extent 26 init 
   ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"].
   def var Ival as char extent 26 init
   ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35"].
  
   substr(AccNo,3,2,"character") = "00".
   TmpStr = substr(AccNo,1,4).
   AccNo = trim(substr(AccNo,5, length(AccNo))).
   AccNo = AccNo + TmpStr.
   TmpStr = "".
   repeat i = 1 to AccLen:
    repeat j = 1 to 26:
     if substr(AccNo,i,1) = Sval[j] then
     do:
       TmpStr = TmpStr + Ival[j].
       r = true.
     end.
    end.
    if not r then TmpStr = TmpStr + substr(AccNo,i,1).
    r = false.
   end.
   
   if not CheckOldAcc(TmpStr) then return false.
   else AccNo = TmpStr.
   j=0.
   AccLen = length(AccNo).
   repeat i = 1 to AccLen:
      j = ( j * 10 + int(substr(AccNo,i,1)) ) modulo 97.
   end.
   
   Rez = 98 - j. 
   if KK <> Rez then return false.
     
   return true.
end function.
/*******************************************************************************************/
function CheckLen returns int (input AccNo as char):
   def var AccLen as int.  
   def var Country as char.
   AccLen = length(AccNo).
   if AccLen < 6 then return 0.
   
  
    Country = substr(AccNo,1,2).
     case Country:
      when 'AL' then do: /*Албания*/
        if AccLen = 28 then return 2.
        else return 1.
      end.
      when 'AD' then do: /*Андорра*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'AT' then do: /*Австрия*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'BE' then do: /*Бельгия*/
        if AccLen = 16 then return 2.
        else return 1.
      end.
      when 'BA' then do: /*Босния и Герцеговина*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'BG' then do: /*Болгария*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'HR' then do: /*Хорватия*/
        if AccLen = 21 then return 2.
        else return 1.
      end.
      when 'CY' then do: /*Кипр*/
        if AccLen = 28 then return 2.
        else return 1.
      end.
      when 'CZ' then do: /*Чешская республика*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'DK' then do: /*Дания*/
        if AccLen = 18 then return 2.
        else return 1.
      end.
      when 'EE' then do: /*Эстония*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'FO' then do: /*Фарерские острова*/
        if AccLen = 18 then return 2.
        else return 1.
      end.
      when 'FI' then do: /*Финляндия*/
        if AccLen = 18 then return 2.
        else return 1.
      end.
      when 'FR' then do: /*Франция*/
        if AccLen = 27 then return 2.
        else return 1.
      end.
      when 'GE' then do: /*Грузия*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'DE' then do: /*Германия*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'GI' then do: /*Гибралтар*/
        if AccLen = 23 then return 2.
        else return 1.
      end.
      when 'GR' then do: /*Греция*/
        if AccLen = 27 then return 2.
        else return 1.
      end.
      when 'GL' then do: /*Гренландия*/
        if AccLen = 18 then return 2.
        else return 1.
      end.
      when 'HU' then do: /*Венгрия*/
        if AccLen = 28 then return 2.
        else return 1.
      end.
      when 'IS' then do: /*Исландия*/
        if AccLen = 26 then return 2.
        else return 1.
      end.
      when 'IE' then do: /*Ирландия*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'IL' then do: /*Израиль*/
        if AccLen = 23 then return 2.
        else return 1.
      end.
      when 'IT' then do: /*Италия*/
        if AccLen = 27 then return 2.
        else return 1.
      end.
      when 'KZ' then do: /*Казахстан*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'LV' then do: /*Латвия*/
        if AccLen = 21 then return 2.
        else return 1.
      end.
      when 'LB' then do: /*Ливан*/
        if AccLen = 28 then return 2.
        else return 1.
      end.
      when 'LI' then do: /*Лихтенштейн*/
        if AccLen = 21 then return 2.
        else return 1.
      end.
      when 'LT' then do: /*Литва*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'LY' then do: /*Люксембург*/
        if AccLen = 20 then return 2.
        else return 1.
      end.
      when 'MK' then do: /*Македония*/
        if AccLen = 19 then return 2.
        else return 1.
      end.
      when 'MT' then do: /*Мальта*/
        if AccLen = 31 then return 2.
        else return 1.
      end.
      when 'MU' then do: /*Маврикий*/
        if AccLen = 30 then return 2.
        else return 1.
      end.
      when 'MC' then do: /*Монако*/
        if AccLen = 27 then return 2.
        else return 1.
      end.
      when 'ME' then do: /*Черногория*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'NL' then do: /*Нидерланды */
        if AccLen = 18 then return 2.
        else return 1.
      end.
      when 'NO' then do: /*Норвегия*/
        if AccLen = 15 then return 2.
        else return 1.
      end.
      when 'PL' then do: /*Польша*/
        if AccLen = 28 then return 2.
        else return 1.
      end.
      when 'PT' then do: /*Португалия*/
        if AccLen = 25 then return 2.
        else return 1.
      end.
      when 'RO' then do: /*Румыния*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'SM' then do: /*Сан - Марино*/
        if AccLen = 27 then return 2.
        else return 1.
      end.
      when 'SA' then do: /*Саудовская Аравия*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'RS' then do: /*Сербия*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      when 'SK' then do: /*Словакия*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'SI' then do: /*Словения*/
        if AccLen = 19 then return 2.
        else return 1.
      end.
      when 'ES' then do: /*Испания*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'SE' then do: /*Швеция*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'CH' then do: /*Швейцария*/
        if AccLen = 21 then return 2.
        else return 1.
      end.
      when 'TN' then do: /*Тунис*/
        if AccLen = 24 then return 2.
        else return 1.
      end.
      when 'TR' then do: /*Турция*/
        if AccLen = 26 then return 2.
        else return 1.
      end.
      when 'GB' then do: /*Великобритания*/
        if AccLen = 22 then return 2.
        else return 1.
      end.
      otherwise do:
        return 1.
      end.
     end case.
    
end function.
/*******************************************************************************************/
function CheckAccEx returns log (input AccNo as char):
    find first comm.swaccex where comm.swaccex.acc = AccNo no-lock no-error.
    if avail comm.swaccex then return true.
    else return false.
end function.
/*******************************************************************************************/
function CheckAcc returns log (input-output AccNo as char):
   def var TmpAcc as char.
   def var Ret as int.
   def var rez as log.
   if substr(AccNo,1,1) = "/" then do: TmpAcc = caps( substr( AccNo,2, length(AccNo) ) ). end.
   else do: /* просто текст или ничего... даем заполнять форму дальше  */ AccNo = "". return true.  end.
   
   Ret = CheckLen(TmpAcc).
   if Ret = 0 then do: message "Неверный формат номера счета!" view-as alert-box. return false. end.
   if Ret = 2 then do: if not CheckIban(TmpAcc) then  return false. end.
   if Ret = 1 then 
   do: 
     if CheckAccEx(TmpAcc) then return true.
     if not CheckOldAcc(TmpAcc) then
     do:
      if LastAcc = AccNo then
      do:
         run yn("","Вы уверены что счет " + TmpAcc + " правильный?","","", output rez). 
         if rez then 
         do:
           /* swin.content[2]:screen-value  in frame ord-info = "OK".*/
           create comm.swaccex.
                  comm.swaccex.txb = comm-txb().
                  comm.swaccex.acc = TmpAcc.
                  comm.swaccex.who =  userid('bank').
           LastAcc = "".       
           return true.
         end.
      end.
      LastAcc = AccNo.
      return false. 
     end. 
   end.
   return true.
end function.
/*******************************************************************************************/
