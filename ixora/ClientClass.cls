/* ClientClass.cls
 * MODULE
        
 * DESCRIPTION
        Класс клиентов - Данные по клиенту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK       
 * AUTHOR
        25.12.2008 k.gitalov
 * CHANGES
        09.06.2009 id00205 Добавил функцию FindClientNo
*/


CLASS ClientClass:
 def public   var  clientno     as char.                                 /* ID клиента  */
 def public   var  clientname   as char format "x(45)".                  /* Клиент      */
 def public   var  clienttype   as char.                                 /* Тип клиента  p - физ лицо , b - юр лицо*/
 def public   var  ofc          as char.                                 /* Контролирующий офицер */
 def public   var  rnn          as char.                                 /* РНН клиента*/
 def private  var  acclist      as char no-undo.                         /* Список счетов клиента */
 /*************************************************************************************************************/
 CONSTRUCTOR  public ClientClass(INPUT std AS CLASS GlobalClass):

 END CONSTRUCTOR.
 /*************************************************************************************************************/
 CONSTRUCTOR  public ClientClass():
     
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 DESTRUCTOR  public ClientClass():

 END DESTRUCTOR.
 /*************************************************************************************************************/

 /* Поиск данных клиента по номеру счета      */ 
 method public log FindClient(INPUT AccNo as char): /* Параметр - номер счета клиента */
       InitVars().
       def buffer b-aaa for aaa.
       find b-aaa where b-aaa.aaa = AccNo no-lock no-error.
       if not available b-aaa then 
       do:    
         message "Счет" AccNo "не найден !" view-as alert-box. 
         return false.                       
       end.
       else do: 
         def buffer b-cif for cif.
         find b-cif where b-cif.cif eq b-aaa.cif no-lock no-error.
          if not available b-cif then
          do:
                message "Не найден клиент " b-aaa.cif "в таблице CIF"  view-as alert-box.
                return false.
          end.      
          else do:
                clientname = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
                clientno   = b-cif.cif.
                clienttype = b-cif.type.
                ofc        = b-cif.fname.
                rnn        = b-cif.jss.
                return true.
          end.       
       end.
 end method.
 
 /*************************************************************************************************************/
  /* Поиск данных клиента по ID клиента      */
  method public log FindClientNo(INPUT Client as char): /* Параметр - ID клиента */
       InitVars().
       def buffer b-aaa for aaa.
       find first b-aaa where b-aaa.cif = Client  no-lock no-error.
       if not available b-aaa then 
       do:    
         message "Клиент" Client "не найден !" view-as alert-box. 
         return false.                       
       end.
       else do: 
         def buffer b-cif for cif.
         find b-cif where b-cif.cif eq b-aaa.cif no-lock no-error.
          if not available b-cif then
          do:
                message "Не найден клиент " b-aaa.cif "в таблице CIF"  view-as alert-box.
                return false.
          end.      
          else do:
                clientname = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
                clientno   = Client. /*b-cif.cif.*/
                clienttype = b-cif.type.
                ofc        = b-cif.fname.
                rnn        = b-cif.jss.
                return true.
          end.       
       end.
 end method.
 
 /*************************************************************************************************************/
 method private void InitVars():
        clientname = "".
        clientno   = "".
        clienttype = "".
        ofc        = "".
        rnn        = "".
 end method.
 /*************************************************************************************************************/

 /* Поиск всех счетов клиента символ разделитель "|" */
 method public char FindAcc():
    acclist = "".
    if clientno <> "" then do:
       def buffer b-aaa for aaa.
       def buffer b-lgr for lgr.
        for each b-aaa where b-aaa.cif = clientno and b-aaa.sta <> 'C' no-lock break by b-aaa.crc:
          find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> 'oda' no-lock no-error.
          if available b-lgr then 
          do:
           if acclist <> "" then acclist = acclist + "|".
           acclist = acclist + b-aaa.aaa.
          end.
        end.
    end.    
    else acclist = "".
    if acclist = "" then do: message "У клиента нет активных счетов" view-as alert-box. end.
    return acclist.
 end method.
 /*************************************************************************************************************/
 
 /* Поиск счетов клиента с валютой curr */
 method public char FindAcc(input curr as int):
    acclist = "".
    if clientno <> "" then do:
       def buffer b-aaa for aaa.
       def buffer b-lgr for lgr.
        for each b-aaa where b-aaa.crc = curr and b-aaa.cif = clientno and b-aaa.sta <> 'C' no-lock break by b-aaa.crc:
          find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> 'oda' no-lock no-error.
          if available b-lgr then 
          do:
           if acclist <> "" then acclist = acclist + "|".
           acclist = acclist + b-aaa.aaa.
          end.
        end.
    end.    
    else acclist = "".
    if acclist = "" then do: message "У клиента нет счета в такой валюте" view-as alert-box. end.
    return acclist.
 end method.
 /*************************************************************************************************************/
 /* Проверяет достаточно ли средств на счете acc для снятия суммы sum */
 method public log check-sum(input acc as char, input sum as decimal):
    def buffer b-aaa for aaa.
    def buffer b-crc for crc.
    find first b-aaa where b-aaa.aaa = acc.
    if avail b-aaa then
    do:
      find b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
      if b-aaa.cr[1] - b-aaa.dr[1] >= sum then return true.
      else do:
       message "На счете" acc "нет средств для снятия" round(sum,2) b-crc.code " ! " view-as alert-box.
       return false.
      end. 
    end.
    else do:
      message "Счет" acc "не найден !" view-as alert-box. 
      return false.
    end.
 end method.
 /*************************************************************************************************************/
 /* Проверка на дебетовое сальдо */
 method public log check-debsald(input acc as char):
   def buffer b-aaa for aaa.
   find first b-aaa where b-aaa.aaa = acc.
   if avail b-aaa then
   do:
     if b-aaa.cr[1] - b-aaa.dr[1] < 0 then return false.
     else return true.
   end.
   else do:
      message "Счет" acc "не найден !" view-as alert-box. 
      return false.
   end.
 end method.  
 /*************************************************************************************************************/
END CLASS.