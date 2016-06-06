/* vip_prate.i
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
        10.06.2009 k.gitalov
 * CHANGES
*/

/*
  GetListCRC      Возвращает список неповторяющихся валют счетов клиента
  CheckAccCount   Проверка на кол-во разновалютных счетов клиента
  FormatOper      Возвращает список возможных комбинаций операций конвертаций для данной валюты
  EncodeOper      Возвращает закодированный вид переданной операции - Покупка USD = 1_2 
  DecodeOper      Возвращает 'человеческий' вид переданной операции - 1_2 = Покупка USD
  ListOper        Возвращает все возможные операции конвертаций для данного клиента 
  GetCRCcode      Возвращает код валюты для данной операции
*/
/********************************************************************************************************************/
function GetListCRC returns char (input CL as CLASS ClientClass).
  /* Возвращает список неповторяющихся валют счетов клиента*/
  def var AccList as char.           /* Список счетов клиента */
  def var IntList as char init "".   /* Список валют счетов клиента */
  def var curr-acc as char init "".  /* Текущий обрабатываемый счет, валюта */
  def var acc-index as int.          /* Индекс текущего счета, валюты */
  def var acc-count as int.          /* Кол-во счетов, валют клиента */
  def var CRC AS CLASS CurrencyClass.
  CRC = new CurrencyClass().
    
  AccList = CL:FindAcc().
  acc-count = NUM-ENTRIES(AccList,"|").
  /* Получили список счетов клиента */
  DO acc-index = 1 to acc-count:
     curr-acc =  ENTRY(acc-index,AccList,"|").
     def var Itmp as int.
     Itmp = CRC:get-crc(curr-acc).
     if LOOKUP(STRING(Itmp),IntList) = 0 then 
     do:
      if LENGTH(IntList) > 0 then do: IntList = IntList + ",". end.
      IntList = IntList + STRING(Itmp). 
     end.
  END. 
  
  if VALID-OBJECT(CRC)  then DELETE OBJECT CRC NO-ERROR .
  return IntList. 
end function.
/********************************************************************************************************************/
function CheckAccCount returns log (input CL as CLASS ClientClass).
  /* Проверка на кол-во разновалютных счетов клиента*/
  if NUM-ENTRIES(GetListCRC(CL),",") > 1 then return true.
  else return false.
end function.

/********************************************************************************************************************/
function FormatOper returns char (input cur-crc as char, input list-crc as char, input list-oper as char).
  /* Возвращает список возможных комбинаций операций для данной валюты */
   def var crc-count as int.
   def var crc-index as int.
   def var cur-crc2 as char.
   def var Oper as char init "".
   def var tmpOper as char init "".
   
   crc-count = NUM-ENTRIES(list-crc,",").
   DO crc-index = 1 to crc-count:
      cur-crc2 =  ENTRY(crc-index,list-crc,",").
      if cur-crc <> cur-crc2 then
      do:
        tmpOper = cur-crc + "_" + cur-crc2.
        if LOOKUP(tmpOper,list-oper) = 0 then
        do:
          if LENGTH(Oper) > 0 or LENGTH(list-oper) > 0 then do: Oper = Oper + ",". end.
          Oper = Oper + tmpOper. 
        end.
        tmpOper = cur-crc2 + "_" + cur-crc.
        if LOOKUP(tmpOper,list-oper) = 0 then
        do:
          if LENGTH(Oper) > 0 or LENGTH(list-oper) > 0 then do: Oper = Oper + ",". end.
          Oper = Oper + tmpOper. 
        end.
      end.
   END. 
 
  return Oper.  /*"1_2,2_1,1_3,3_1"*/
end function.
/********************************************************************************************************************/
function EncodeOper returns char (input soper as character).
  /* возвращает закодированный вид переданной операции - Покупка USD*/
  def var val1 as char.
  def var val2 as char.
  def var dlm as int.
  def var len as int.
  def var Oper as char.
  def var Result as char.
  def var CRC AS CLASS CurrencyClass.
  CRC = new CurrencyClass().
  
  
  dlm = INDEX(soper," ").
  len = LENGTH(soper).
  Oper = SUBSTRING(soper,1,dlm - 1). 
  
  if Oper = "Покупка" then
  do:
   val1 = "1".
   val2 = STRING(CRC:get-id-crc(SUBSTRING(soper,dlm + 1,len))). 
   Result = val1 + "_" + val2.
  end.
  else do:
    if Oper = "Продажа" then
    do:
      val2 = "1".
      val1 = STRING(CRC:get-id-crc(SUBSTRING(soper,dlm + 1,len))). 
      Result = val1 + "_" + val2.
    end.
    else do:
      if Oper = "Конвертация" then
      do:
         Oper = SUBSTRING(soper,dlm + 1 ,len).
         dlm  = INDEX(Oper,"->").
         len  = LENGTH(Oper).
         val1 =  STRING(CRC:get-id-crc(SUBSTRING(Oper,1,dlm - 1))).
         val2 =  STRING(CRC:get-id-crc(SUBSTRING(Oper,dlm + 2,len))).
         Result = val1 + "_" + val2.
      end.
      else Result = "".
    end.
    
  end.
  
  if VALID-OBJECT(CRC)  then DELETE OBJECT CRC NO-ERROR .
  return Result.
end function.
/********************************************************************************************************************/
function DecodeOper returns char (input soper as character).
  /* возвращает 'человеческий' вид переданной операции - "1_2"*/
  def var dlm as int.
  def var len as int.
  def var val1 as int.
  def var val2 as int.
  def var Result as char init "".
  def var CRC AS CLASS CurrencyClass.
  CRC = new CurrencyClass().
  
  dlm = INDEX(soper,"_").
  len = LENGTH(soper).
  val1 = integer(SUBSTRING(soper,1,dlm - 1)).
  val2 = integer(SUBSTRING(soper,dlm + 1,len)).

  if val1 = 1 then
  do:
    Result = "Покупка ".
    Result = Result + CRC:get-code(val2).
  end.
  else do:
   if val2 = 1 then
   do:
    Result = "Продажа ".
    Result = Result + CRC:get-code(val1).
   end.
   else do:
    Result = "Конвертация ".
    Result = Result + CRC:get-code(val1) + "->" + CRC:get-code(val2).
   end.
  end.
  
  if VALID-OBJECT(CRC)  then DELETE OBJECT CRC NO-ERROR .
  return Result.
end function.
/********************************************************************************************************************/
function ListOper returns char (input CL AS Class ClientClass).
  /* возвращает все возможные операции для данного клиента*/
  def var IntList as char init "".   /* Список валют счетов клиента */
  def var curr-acc as char init "".  /* Текущий обрабатываемый счет, валюта */
  def var acc-index as int.          /* Индекс текущего счета, валюты */
  def var acc-count as int.          /* Кол-во счетов, валют клиента */
  def var OperList as char init "".  /* Список кодированных операций клиента */
  def var ReturnList as char init "". /* Возвращаемый список */
  
  IntList = GetListCRC(CL).
  /* Получили список неповторяющихся валют счетов клиента */
  acc-count = NUM-ENTRIES(IntList,",").
  DO acc-index = 1 to acc-count:
     curr-acc =  ENTRY(acc-index,IntList,",").
     OperList = OperList + FormatOper(curr-acc,IntList,OperList).
  END. 
  /* Получили список кодированных операций*/
  acc-count = NUM-ENTRIES(OperList,",").
  DO acc-index = 1 to acc-count:
     curr-acc =  ENTRY(acc-index,OperList,",").
     if LENGTH(ReturnList) > 0 then do: ReturnList = ReturnList + ",". end.
     ReturnList = ReturnList + DecodeOper(curr-acc).
  END.  
  
  return  ReturnList. /* "Покупка USD,Продажа USD,Покупка EUR,Продажа EUR,Конвертация USD->EUR".*/
end function.
/********************************************************************************************************************/
function GetCRCcode returns char (input soper as character).
  /* Возвращает код валюты для данной операции */
  def var dlm as int.
  def var len as int.
  def var val1 as int.
  def var val2 as int.
  def var Result as char.
  def var CRC AS CLASS CurrencyClass.
  CRC = new CurrencyClass().
  
  dlm = INDEX(soper,"_").
  len = LENGTH(soper).
  val1 = integer(SUBSTRING(soper,1,dlm - 1)).
  val2 = integer(SUBSTRING(soper,dlm + 1,len)).
  
  if val1 = 1 then
  do:
    Result = CRC:get-code(val2).
  end.
  else do:
    if val2 = 1 then
    do:
      Result = CRC:get-code(val1).
    end.
    else do:
      Result = CRC:get-code(val2).
    end.
  end.
  
  if VALID-OBJECT(CRC)  then DELETE OBJECT CRC NO-ERROR .
  return Result.
end function.
/********************************************************************************************************************/
