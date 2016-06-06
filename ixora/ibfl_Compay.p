/* ibfl_Compay.p
 * MODULE
        ИБФЛ 
 * DESCRIPTION
        коммунальные платежи клиента ИБФЛ
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
        13/05/2013 k.gitalov
 * BASES
        COMM TXB
 * CHANGES
*/

{xmlParser.i}

define input parameter p-cif as character no-undo.
define input parameter p-acc_from as character no-undo.
define input parameter p-amount as character no-undo.
define input parameter p-data as character no-undo.
define input parameter p-std as class GlobalClass.
define input parameter p-type as character no-undo.
define output parameter p-replyText as character.
define output parameter p-err as character no-undo.

define buffer b-cif for txb.cif.
define buffer b-aaa for txb.aaa.
define buffer b-arp for txb.arp.
define buffer b-crc for txb.crc.

define variable l_card_acc_from as log init false. /*true если счет снятия карточный*/
define variable i_crc_acc_from as int init 0.      /*валюта счета снятия*/
define variable c_cif_from as character no-undo.   /*cif код владельца счета снятия*/
define variable crc_acc_from as character no-undo. /*код валюты счета снятия */
define variable cif_geo as character no-undo.      /*признак резидентства*/

define variable v-out as log.
define variable v-des as char.
define variable tmp-char as character no-undo.
define variable TypeOperation as character no-undo init "".

define variable v-param as character.
define variable vrem as character init "Коммунальный платеж".
define variable vdel as character init "^".
define variable rcode as integer.
define variable rdes as character.



define variable xmltmp as character no-undo.
define variable PayType as integer.
define variable Supp_id as character no-undo.
define variable Ap_type as character no-undo.
define variable Ap_code as character no-undo.
define variable payacc as character no-undo.
define variable CurInvoice as character no-undo.
define variable v-Suppcom as character no-undo.
define variable pos as integer.
define variable s-jh as integer.

define variable  Client AS CLASS ClientClass_txb.
define variable  SP  as class SUPPCOMClass.    /* Класс данных поставщиков */
define variable  Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
define variable  Usr as class ACCOUNTClass.    /* Класс данных плательщиков */

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   return.
end.
s-ourbank = trim(sysc.chval).

if p-cif = "" then do:
  p-err = "Отсутствует код клиента во входящем сообщении!".
  message "ERR: ibfl_" + p-type + " -> " + p-err.
  return.  
end.

/*************************************************************************************************/
xmltmp = GetParamValueOne(p-data,"Data").
payacc = GetParamValueOne(xmltmp,"account").
Supp_id = GetParamValueOne(xmltmp,"Supp_id").
Ap_type = GetParamValueOne(xmltmp,"Ap_type").
Ap_code = GetParamValueOne(xmltmp,"Ap_code").
PayType = integer(GetParamValueOne(xmltmp,"Type")).
CurInvoice = GetParamValueOne(xmltmp,"invoice").
/*************************************************************************************************/
{ibfl.i}

if Ap_type = "1" and (Ap_code = "1" or 
                      Ap_code = "3" or 
                      Ap_code = "7" or 
                      Ap_code = "503" or 
                      Ap_code = "504" or 
                      Ap_code = "228" or 
                      Ap_code = "298" or 
                      Ap_code = "462" or 
                      Ap_code = "502" or 
                      Ap_code = "542") then do:
                          
  payacc = GetNormTel(payacc).
end.
/*
|Dalacom  1        1       |
|Pathword 1        3       |
|City     1        7       |
|Beeline( 1        228     |
|Казахтел 1        298     |
|Tele2    1        462     |
|ДОС(КарТ 1        502     |
|ACTIV    1        503     |
|KCELL    1        504     |
|INFOSMS. 1        542     |

|Dalacom                                 1          1|
|Pathword                                1          3|
|City                                    1          7|
|ACTIV                                   1        185|
|KCELL                                   1        186|
|Beeline(КарТел)                         1        228|
|Казахтелеком                            1        298|
|Tele2                                   1        462|
|ДОС(КарТел)                             1        502|
|INFOSMS.KZ                              1        542|
*/

find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then do:
  if comm.pksysc.loval = no then
  do:
    p-err = "Прием платежей в данное время недоступен!".
    message "ERR: ibfl_" + p-type + " -> " + p-err.
    return. 
  end.
end.
else do:
   p-err = "Неверные настройки системы!".
   message "ERR: ibfl_" + p-type + " -> " + p-err.
   return.  
end.    
/*************************************************************************************************/
{compayshared.i "new"}
/***********************************************************************************************************/
/* возвращает кол-во аккаунтов найденных в темп таблице */
function InvoiceCount returns int ():
  def var InList as char init "".
  def var Count as int init 0.
  for each wrk no-lock:
    if LENGTH(InList) = 0 then do: InList = wrk.Invoice. Count = 1. end.
    else do:
      if LOOKUP(wrk.Invoice,InList,"|") = 0 then do: InList = InList + "|" + wrk.Invoice. Count = Count + 1. end.
    end.
  end.
 return Count.
end function.
/***********************************************************************************************************/
/* возвращает список аккаунтов найденных в темп таблице */
function ListInvoice returns char ():
  def var InList as char init "".
  for each wrk no-lock:
    if LENGTH(InList) = 0 then InList = "<invoice>" + wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit + "</invoice>".
    else InList = InList + "<invoice>" + wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit + "</invoice>".
    /*
    else do:
      if LOOKUP(wrk.Invoice,InList,"|") = 0 then InList = InList + "|" + wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit.
    end.
    */
  end.
 return InList.
end function.
/***********************************************************************************************************/

 SP  = NEW SUPPCOMClass().
 if not SP:Find-First("ap_type = " + Ap_type + " and ap_code = " + Ap_code + " and txb = '" + s-ourbank + "' and (type = 2 or type = 3)") then do:
   p-err = "Не найден указанный поставщик услуг!". 
   message "ibfl_" + p-type + " -> " + p-err.
 end.
 else message "ibfl_" + p-type + " -> Provider Name = " + SP:name. 
  
/*************************************************************************************************/  
 if p-err = "" then do:
     Doc = NEW COMPAYDOCClass(p-std).
     Doc:AddData(). 
     Doc:SetSuppData(SP).
     Usr = NEW ACCOUNTClass(p-std,Doc:supp_id).
      if not Doc:CheckAcc(payacc) then do:
        p-err = "Ошибка при проверке лицевого счета!".
        message "ibfl_" + p-type + " -> " + p-err.
      end.  
 end.
/*************************************************************************************************/ 
 if p-err = "" then do: 
  if Doc:ap_check > 0 then do: 
     /*Наличие онлайн проверки по авангард плат*/
     if not Usr:FindAcc(payacc) then Usr:acc = payacc.
     empty temp-table wrk.
     run ap_check( Usr ,output rcode, output p-err).
     if rcode <> 0 then do: 
       message "ibfl_" + p-type + " -> " + p-err.
     end.
     else do:
            v-Suppcom = "503,504,5,526,545,546,547,548,549,530,608,536,538,550,539,551,552,537,541,531,540,534,543,523,506,533,535,588,604,618,553,554,555,556,557,558,559,560,561," +
                     "562,563,564,565,566,567,568,569,585,591,592,593,598,607,609,610,611,612,613,614,615,617,620,570,572,573,542,622,623,624,625,626,627,628,629,635,636,637,638,639," +
                     "640,641,642,643,644,645,646,647,648,649,650,654,655,656,657,525,529,589,590,594,595,597,600,603,605,606,651,652,653".

                     if lookup(string(Doc:ap_code),trim(v-Suppcom)) > 0 then do: /*AKTIV KCELL и т.д. и т.п.*/
                         if Usr:FindAcc(payacc) then Doc:SetUsrData(Usr).
                         else do:
                           Doc:payacc  = payacc.
                           Doc:payrnn  = "000000000000".
                           Doc:payaddr = "NO ADDRESS".
                           Doc:payname = "NO NAME".
                         end.
                      pos = 3.
                     end.
                     else do:
                        find first wrk no-lock no-error.
                        if avail wrk then
                        do:
                         /**************************************************************/
                         if  InvoiceCount() > 1 then do:
                           if CurInvoice = "" then do:
                                 p-replyText = "<Data><Supp_id>" + Supp_id + "</Supp_id><account>" + payacc + "</account>" + ListInvoice() + "</Data>".
                                 if VALID-OBJECT(SP) then DELETE OBJECT SP NO-ERROR .
                                 if VALID-OBJECT(Doc) then DELETE OBJECT Doc NO-ERROR .
                                 if VALID-OBJECT(Usr) then DELETE OBJECT Usr NO-ERROR .
                                 return.
                           end.
                         end.
                         else do:
                           find first wrk no-lock no-error.
                           if avail wrk then CurInvoice = wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit.
                           else do: 
                             p-err = "Ошибка при получении данных платежа!". 
                             message "ibfl_" + p-type + " -> " + p-err.
                           end.
                         end.

                         if p-err = "" and (CurInvoice = "" or CurInvoice = ?) then
                         do:
                           p-err = "Ошибка при получении инвойса!". 
                           message "ibfl_" + p-type + " -> " + p-err.  
                         end.
                         /*CurInvoice выбрали*/
                        end.
                        else do: 
                           p-err = "Нет данных по этому номеру счета!". 
                           message "ibfl_" + p-type + " -> " + p-err. 
                        end.
                        pos = 2.
                        if p-err = "" then do:
                            
                         find first wrk where (wrk.Invoice + " " + wrk.NamSub + " " + wrk.Unit) = CurInvoice.
                         if avail wrk then
                         do:
    
                             if INDEX(wrk.Invoice,Usr:acc) > 0 then /*если в инвойсе присутствует номер счета то...*/
                             do:
                              /*
                                Тип провайдера  (Асибо):
                                Во временной таблице wrk может вернуться несколько номеров счетов с соответствующими начальными цифрами введенного счета
                                записи wrk содержат номера счетов ФИО и адрес
                              */
                              if not Usr:FindUser(wrk.Invoice,wrk.NamSub,wrk.Unit) then
                              do: /*не нашли... новенький*/
                                Doc:payacc = wrk.Invoice.
                                Doc:payname = CAPS(wrk.NamSub).
                                Doc:payaddr = CAPS(wrk.Unit).
                                Doc:payrnn = "000000000000".
                              end.
                              else do:
                                /*нашли в базе*/
                                if Usr:payname <> wrk.NamSub or Usr:addr <> wrk.Unit then
                                do: /*еще и не соответствуют данные 0_o*/
                                  /*
                                  message "Данные полученные от сервиса не соответствуют локальным! \n"
                                       "Будет создана новая запись!" view-as alert-box.
                                       */
                                  Usr:acc_id = ?.
                                  Doc:payacc =  wrk.Invoice.
                                  Doc:payname = CAPS(wrk.NamSub).
                                  Doc:payaddr = CAPS(wrk.Unit).
                                  Doc:payrnn  = "000000000000".
                                end.
                                else  Doc:SetUsrData(Usr).
                                /*все ок...*/
                              end.
                             end.
                             else do:
                              /*
                                Тип провайдера  (Отис):
                                Во временной таблице wrk может вернуться несколько инвойсов
                                записи wrk содержат номер инвойса, номер договора, дату выставления счета, сумму к оплате
                              */
                              define variable tmpname as character.
                              define variable tmpacc as character.
                              tmpname = Usr:name.
                              tmpacc =  Usr:acc.
                              if not Usr:FindUser(Usr:acc,Usr:name,wrk.NamSub) then
                              do: /*не нашли... новенький*/
                                Doc:payacc = tmpacc.
                                Doc:payname = CAPS(Usr:name).
                                Doc:payaddr = CAPS(wrk.NamSub). /*номер договора */
                                Doc:payrnn = "000000000000".
    
                                v-Suppcom = "298".
                                if lookup(string(Doc:ap_code),trim(v-Suppcom)) > 0 then do:
                                    if Doc:payname = "" then Doc:payname = CAPS(wrk.NamSub).
                                end.
                              end.
                              else do:
                                /*нашли в базе*/
                                if Usr:payname <> tmpname or Usr:addr <> CAPS(wrk.NamSub) then
                                do: /*еще и не соответствуют данные 0_o*/
                                /*
                                  message "Данные полученные от сервиса не соответствуют локальным! \n"
                                       "Будет создана новая запись!" view-as alert-box.
                                       */
                                  Usr:acc_id = ?.
                                  Doc:payacc  = Usr:acc.
                                  Doc:payname = tmpname.
                                  Doc:payaddr = CAPS(wrk.NamSub). /*номер договора*/
                                  Doc:payrnn  = "000000000000".
                                end.
                                else  Doc:SetUsrData(Usr).
                                /*все ок...*/
                              end.
                              /* Doc:summ = wrk.ForPay.*/
                             end.
    
                             if wrk.ForPay <> 0 and wrk.ForPay <> ? then Doc:summ = wrk.ForPay.
    
                             pos = 3.
    
                         end.
                         else do:
                           p-err = "Ошибка при инициализации аккаунта!". 
                           message "ibfl_" + p-type + " -> " + p-err.
                         end.
                        end.    
                     end.
     end.
  end.
  else do: 
     /* проверки по авангардплат - нет*/
     if Usr:FindAcc(payacc) then Doc:SetUsrData(Usr).
     else do:
       Doc:payacc  = payacc.
       Doc:payrnn  = "000000000000".
       Doc:payaddr = "NO ADDRESS".
       Doc:payname = "NO NAME".
     end.
     pos = 3.
  end.     
 end.  
/*************************************************************************************************/ 
 if p-err <> "" then do:
     run ClearData.
     return.
 end.  
/*************************************************************************************************/ 

                               
/*************************************************************************************************/
if p-type = "providerPaymentCommit" then do:
    if p-amount = "" then do:
       p-err = "Сумма не может быть пустой!".  
       message "ibfl_" + p-type + " -> " + p-err.
       return.  
    end.
        
    Doc:summ = decimal(p-amount).
 
    if Doc:summ = 0 or Doc:summ < Doc:minsum then do:
        p-err = "Минимальная сумма платежа" + string(Doc:minsum).  
        message "ibfl_" + p-type + " -> " + p-err.
        return.
    end.
    p-amount = string(Doc:comm_summ + decimal(p-amount)).
    /*************************************************************************************************/
    if p-acc_from = "" then do:
       p-err = "ERR: ibfl_" + p-type + " -> no acc_from".
       message p-err.
       return.  
    end.
    /*************************************************************************************************/
    
    find first b-aaa where b-aaa.aaa = p-acc_from no-lock no-error.
    if available b-aaa then do:
       if (b-aaa.lgr = "138" or b-aaa.lgr = "139" or b-aaa.lgr = "140") and b-aaa.gl = 220430 then l_card_acc_from = true.
       else l_card_acc_from = false.
       i_crc_acc_from = b-aaa.crc.
       c_cif_from = b-aaa.cif.
       find first b-crc where b-crc.crc = i_crc_acc_from no-lock.
       if available b-crc then crc_acc_from = b-crc.code.
    end. 
    else do:
       p-err = "Не найден счет для списания!". 
       message "ibfl_" + p-type + " -> " + p-acc_from + "  " + p-err.
       return.
    end.
    /*************************************************************************************************/
    if c_cif_from <> p-cif then do:
      p-err = "Неверный владелец счета!". 
      message "ibfl_" + p-type + " -> " + p-err.
      return.  
    end.
    /*************************************************************************************************/
    
    Client = NEW ClientClass_txb(p-std).
    if not l_card_acc_from then do:
      if Client:check-sum(p-acc_from, decimal(p-amount)) = false then 
      do:
        p-err = "Недостаток средств на счете " + p-acc_from.  
        message "ibfl_" + p-type + " -> " + p-err.
        return.
      end.  
    end.
    else do:
      run ow_send("GetBalance","",p-acc_from,"","","","","","","",output v-des,output v-out).
      if not v-out then do:
        p-err = "Ошибка проверки остатка на счете!". 
        message "ibfl_" + p-type + " -> " + v-des.
        return.
      end.    
      tmp-char = GetParamValueOne(v-des,"Available"). 
      if decimal(tmp-char) < decimal(p-amount) then do:
        p-err = "Недостаток средств на счете!". 
        message "ibfl_" + p-type + " -> " + p-err.
        return.
      end.  
    end.   
   /*************************************************************************************************/
end.
/*************************************************************************************************/

if l_card_acc_from then TypeOperation = "FromCard".
else TypeOperation = "FromAcc".
 
    if p-type = "providerPaymentPrepare" then 
    do:
        if Doc:summ > 0 then p-amount = string(Doc:summ).
        else p-amount = "0".
        p-replyText = "<Data><Supp_id>" + Supp_id + "</Supp_id><account>" + payacc + "</account><summ>" + p-amount + "</summ></Data>".
    end.    
    if p-type = "providerPaymentCommit" then 
    do:
          
          if Usr:acc_id = ? or Usr:acc_id = 0 then
          do:  
            Usr:AddData().
            Usr:payname = Doc:payname.
            Usr:acc     = Doc:payacc.
            Usr:phone   = Doc:payphone.
            Usr:addr    = Doc:payaddr.
            Usr:rnn     = Doc:payrnn.
            if Usr:Post() then
            do:
              Usr:FindAcc(Doc:payacc).
              Doc:SetUsrData(Usr).
            end.
            else do: 
              message "Ошибка при добавлении счета!" view-as alert-box. 
              Usr:ClearData(). 
              run ClearData.
              return.
            end.
          end.
          
          
          if Doc:docno = ? or Doc:docno = 0 then
          do:             
            if not Doc:Post() then do:
              p-err = "Ошибка при сохранении документа!". 
              message "ibfl_" + p-type + " -> " + p-err.
              run ClearData.
              return.
            end.
            else message "ibfl_" + p-type + " -> Документ сохранен! Doc:docno = " + string(Doc:docno).
          end.
          
          message "Doc:acc_id    = " + string(Doc:acc_id) + "~n" +
                  "Doc:payname   = " + Doc:payname + "~n" +
                  "Doc:supp_id   = " + string(Doc:supp_id) + "~n" +
                  "Doc:suppname  = " + Doc:suppname + "~n" +
                  "Doc:docno     = " + string(Doc:docno) + "~n" +
                  "Doc:summ      = " + string(doc:summ) + "~n" +
                  "Doc:comm_summ = " + string(Doc:comm_summ).
          
              if Client:IsDepoAcc(p-acc_from) then
              do: 
                if not Client:RemHoldDepo(p-acc_from,decimal(p-amount)) then  
                do: 
                  /* Произошла ошибка разморозки депозита */
                  p-err = "Ошибка разморозки средств счета " + p-acc_from.
                  run ClearData. 
                  return.
                end. 
              end.
              
            v-out = no.
            s-jh = 0.
            run ibfl_compay_trx(Doc,p-acc_from,TypeOperation,output v-out,output s-jh).
            if not v-out then do:
                   p-err = "Ошибка при формировании проводки!". 
                   message "ibfl_" + p-type + " -> " + p-err.
                   if s-jh <> 0 then do:
                      message "Удаление проводки " + string(s-jh). 
                      run txb_trxgen('9999999', "^" , "Удаление","JOU",Doc:DocNo,0, output rcode, output rdes, input-output s-jh).
                      if rcode ne 0 then
                      do:
                        message "Ошибка удаления проводки rcode = " +  string(rcode) +  ":" +  rdes +   " " + string( s-jh ).
                        /* run mail*/
                      end. 
                      else message "Проводка удалена.". 
                   end. 
                   if Doc:DeleteDoc() then
                   do:
                     message "ibfl_" + p-type + " -> Документ удален.". 
                   end.
                   else do:
                     p-err = "Ошибка при удалении документа!". 
                     message "ibfl_" + p-type + " -> " + p-err. 
                   end.    
                   
               run ClearData.   
               return. 
            end.
            
            p-replyText = "<Data><Trx>" + string(Doc:jh) + "</Trx><Time>" + string(time,"HH:MM:SS")+ "</Time></Data>".
             
    end.    

procedure ClearData: 
    if VALID-OBJECT(SP) then DELETE OBJECT SP NO-ERROR .
    if VALID-OBJECT(Doc) then DELETE OBJECT Doc NO-ERROR .
    if VALID-OBJECT(Usr) then DELETE OBJECT Usr NO-ERROR . 
    if VALID-OBJECT(Client) then DELETE OBJECT Client NO-ERROR . 
end.
    
/*
GetParamValueTwo
tmp-char = GetParamValueOne(p-data-des,"Available").

<Data><Supp_id>1128</Supp_id><Type>2</Type><Ap_check>0</Ap_check><Ap_type>4</Ap_type><Ap_code>623</Ap_code><account>GGG333</account></Data>
<Data><Supp_id>1128</Supp_id><Type>2</Type><Ap_check>0</Ap_check><Ap_type>4</Ap_type><Ap_code>623</Ap_code><account>GGG333</account><summ>7777</summ></Data>
*/
/*
<invoice><ID>АА0000003</ID><num>2234/00</num><sum>22600.00</sum><date>20091111000000</date></invoice>


p-replyText = "<Data><Supp_id>" + sup_id + "</Supp_id><account>" + payacc + "</account><summ>2355</summ></Data>".
*/
run ClearData.

message p-type + " -> OK, CIF=" + p-cif + " msgBody=" + p-replyText.

