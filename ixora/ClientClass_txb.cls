/* ClientClass_txb.cls
 * MODULE
        Название модуля
 * DESCRIPTION
        Данные по клиенту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25.12.2008 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
        09.06.2009 id00205 Добавил функцию FindClientNo
        14.05.2013 damir - Внедрено Т.З. № 1731.
        12/09/2013 k.gitalov внедрение ИБФЛ
*/
CLASS ClientClass_txb:
 def public   var  clientno     as char.                                 /* ID клиента  */
 def public   var  clientname   as char format "x(45)".                  /* Клиент      */
 def public   var  clienttype   as char.                                 /* Тип клиента  p - физ лицо , b - юр лицо*/
 def public   var  ofc          as char.                                 /* Контролирующий офицер */
 def public   var  rnn          as char.                                 /* РНН клиента*/
 def private  var  acclist      as char no-undo.                         /* Список счетов клиента */
 define public variable cif_geo as character no-undo.                    /*Признак резидентства*/
 
 DEFINE public VARIABLE GlobalVar AS CLASS GlobalClass.
 
 define private buffer b-aaa for txb.aaa.
 define private buffer b-crc for txb.crc.
 define private buffer b-aas for txb.aas.
 define private buffer b-lgr for txb.lgr.
 define private buffer b-cif for txb.cif.
 /*************************************************************************************************************/
 CONSTRUCTOR  public ClientClass_txb(INPUT std AS CLASS GlobalClass):
   GlobalVar = std.
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 CONSTRUCTOR  public ClientClass_txb():

 END CONSTRUCTOR.
 /*************************************************************************************************************/
 DESTRUCTOR  public ClientClass_txb():

 END DESTRUCTOR.
 /*************************************************************************************************************/

 /* Поиск данных клиента по номеру счета      */
 method public log FindClient(INPUT AccNo as char): /* Параметр - номер счета клиента */
       InitVars().
       find b-aaa where b-aaa.aaa = AccNo no-lock no-error no-wait.
       if not available b-aaa then
       do:
         message "Счет" AccNo "не найден !" view-as alert-box.
         return false.
       end.
       else do:
         
         find b-cif where b-cif.cif eq b-aaa.cif no-lock no-error no-wait.
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
                
                if b-cif.geo = "021" then cif_geo = "1".
                else cif_geo = "2".
                return true.
          end.
       end.
 end method.

 /*************************************************************************************************************/
  /* Поиск данных клиента по ID клиента      */
  method public log FindClientNo(INPUT Client as char): /* Параметр - ID клиента */
    InitVars().
    find b-cif where b-cif.cif eq Client no-lock no-error no-wait.
    if not available b-cif then
    do:
        message "Не найден клиент " Client "в таблице CIF"  view-as alert-box.
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
    if acclist ne "" then acclist = acclist + "|" + "ALL".
    return acclist.
 end method.
 /*************************************************************************************************************/

 /* Поиск счетов клиента с валютой curr */
 method public char FindAcc(input curr as int):
    acclist = "".
    if clientno <> "" then do:
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
      
    def var vbal as deci.
    def var vavl as deci.
    def var vhbal as deci.
    def var vfbal as deci.
    def var vcrline as deci.
    def var vcrlused as deci.
    def var vooo as char.           
    def var d_sumfreez as decimal decimals 2.  /* Минимальный остаток на депозите   */
    
    
            
    
    run aaa-bal777_txb(acc, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
    
    message "run check-sum acc =" + acc + "~n" +
            "vbal    = " + string(vbal) + "~n" +
            "vavl    = " + string(vavl) + "~n" +
            "vhbal   = " + string(vhbal) + "~n" +
            "vfbal   = " + string(vfbal) + "~n".
            
    find first b-aaa where b-aaa.aaa = acc no-lock no-error.
    if avail b-aaa then
    do:
      find first b-lgr where b-lgr.lgr = b-aaa.lgr no-lock no-error.
      if b-lgr.led <> "TDA" then do:
        /*Текущий счет*/
        if vavl < sum /*and (vhbal >= sum)*/ then
        do: /*Операция требует разморозки средств, по текущим счетам автоматическая разморозка не предусмотрена!*/     
          message "Недостаточно средств на счете <> TDA". 
          return false.
        end.
        else return true.  
      end.
      else do:
        /*Депозит*/
        if b-lgr.tlimit[3] = 0 and not ((b-lgr.feensf <> 1  and b-lgr.feensf <> 2 and b-lgr.feensf <> 3 and b-lgr.feensf <> 6 and b-lgr.feensf <> 4 and b-lgr.feensf <> 5 and b-lgr.feensf <> 7 ) and lookup(b-lgr.lgr, "A38,A39,A40") = 0) then 
        do:
           message "Депозит не является сберегательным с изъятием.".
           return false.
        end.
        if b-lgr.usdval = False then d_sumfreez = b-lgr.tlimit[1].
        else do:
            find last b-crc where b-crc.crc = b-lgr.crc no-lock no-error.
            if avail b-crc then d_sumfreez = b-lgr.tlimit[1] / b-crc.rate[1].
        end.
        if (vbal - sum) < d_sumfreez then 
        do:
          message "Сумма изъятия превышает неснижаемый остаток по депозиту".
          return false.  
        end.
        /*Здесь потом доработать на определение суммы всех инструкций, и при b-aas < sum , дать списать sum*/
        find first b-aas where b-aas.aaa = b-aaa.aaa and b-aas.ln <> 7777777  no-lock no-error.
        if available b-aas then do:
          message "На счет наложены специальные инструкции". 
          return false. 
        end.
        /*Все проверки прошли*/
        return true.
      end.    
    end.
    else do:
      message "Счет" acc "не найден !" view-as alert-box.
      return false.
    end.
    
    
    
    find first b-aaa where b-aaa.aaa = acc no-lock no-error no-wait.
    if avail b-aaa then
    do:
      find b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
      if b-aaa.cr[1] - b-aaa.dr[1] >= sum then return true.
      else do:
       message "На счете" acc "нет средств для снятия" round(sum,2) b-crc.code " ! " view-as alert-box.
       return false.
      end.
    end.
     
 end method.
 /*************************************************************************************************************/
 /* true если счет депозитный*/
 method public log IsDepoAcc(input vaaa as character):
    find first b-aaa where b-aaa.aaa = vaaa no-lock no-error.
    if avail b-aaa then
    do: 
      find first b-lgr where b-lgr.lgr = b-aaa.lgr no-lock no-error.
      if b-lgr.led = "TDA" then return true.
      else return false.    
    end.
    else return false.     
 end method.
 /*************************************************************************************************************/
 /* Разморозка необходимой суммы на депозитном счете клиента*/
 method public log RemHoldDepo(input vaaa as char , input vamt as deci):
  
    def var vbal as deci.
    def var vavl as deci.
    def var vhbal as deci.
    def var vfbal as deci.
    def var vcrline as deci.
    def var vcrlused as deci.
    def var vooo as char.           
    define variable RealHold as decimal.
    
    run aaa-bal777_txb(vaaa, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
    
    message "RemHoldDepo acc =" + vaaa + "~n" +
            "vbal    = " + string(vbal) + "~n" +
            "vavl    = " + string(vavl) + "~n" +
            "vhbal   = " + string(vhbal) + "~n" +
            "vfbal   = " + string(vfbal) + "~n".
    
    if vavl >= vamt then return true.
    else do:
      RealHold =  vamt - vavl. 
    end.    
    if RealHold <= 0 then return false.
            
    def var vln as inte initial 7777777.
    define variable Rez as log init false.
    def var v-propath as char no-undo.
     
     v-propath = propath.
     propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.
     do transaction:
         find first b-aaa where b-aaa.aaa = vaaa exclusive-lock no-error no-wait.
         if not available b-aaa then do:
          message "RemHoldDepo ACC = [" + vaaa + "] not found...".   
          return false.
         end. 
         find first b-aas where b-aas.aaa = vaaa and b-aas.ln = vln exclusive-lock no-error. /* no-wait.*/
         if available b-aas then do:
            b-aas.chkdt = GlobalVar:g-today.
            b-aas.whn = today.
            b-aas.who = GlobalVar:g-ofc.
            b-aas.tim = time.
            b-aas.chkamt = b-aas.chkamt - RealHold.
            b-aaa.hbal = b-aaa.hbal - RealHold.
            if b-aaa.hbal < 0 then b-aaa.hbal = 0.
            message "RemHoldDepo HBAL = [" + string(b-aaa.hbal) + "]".
            Rez = true.
         end.
         else do:
           message "b-aas not avail...".
           Rez = true.
         end.  
     end. /*transaction*/    
        
     release b-aaa.
     release b-aas.  
     propath = v-propath no-error.
         
  return Rez.       
 end method.
/*************************************************************************************************************/
 
  /* Проверка на дебетовое сальдо */
 method public log check-debsald(input acc as char):
   find first b-aaa where b-aaa.aaa = acc no-lock no-error no-wait.
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


