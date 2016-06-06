/* io-chpool.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Формирование выписок и остатков для корпоративных клиентов интернет-банкинга.
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
        BANK COMM
 * AUTHOR
        26.07.2010 k.gitalov
 * CHANGES
        16.05.2011 k.gitalov добавил возможность формировать выписку для всех клиентов
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{classes.i}
{srvcheck.i}
{sysc.i}
{nbankBik.i}

define variable ptpsession as handle.
define variable consumerH as handle.
define variable replyMessage as handle.
define variable v-terminate as log no-undo.
v-terminate = no.

run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").  /*боевой*/
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507"). /*тестовый*/

run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.

run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (THIS-PROCEDURE,"requestHandler",output consumerH).

run receiveFromQueue in ptpsession ("CASH_POOLING", ?, consumerH).
run startReceiveMessages in ptpsession.


run waitForMessages in ptpsession ("inWait", THIS-PROCEDURE, ?).
message "Завершение работы".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.

/****************************************************************************************************************/
def new shared temp-table balance
             field acc as char
             field crc as char
             field cifname as char
             field avail-balance as deci
             field total-balance as deci
             field over as deci
             field used_over as deci.
/****************************************************************************************************************/
def new shared temp-table extract
             field ext_account as char     /*счет клиента*/
             field sender_account as char  /*счет отправителя*/
             field sender_bic as char      /*Бик банка отправителя*/
             field income as deci          /*Входящий остаток*/
             field outcome as deci         /*Исходящий остаток*/
             field oper_code as char       /*номер платежа*/
             field oper_date as date       /*Дата проведения платежа*/
             field num_doc as char         /*номер платежного поручения*/
             field deal_code as char       /*идентификатор документа rmz или jou*/
             field date_doc as date        /*дата создания документа*/
             field date_val as date        /*дата валютирования или дата проводки*/
             field plat_value as int       /*Признак исход-й или входящий платеж (0-исходящий 1-входящ)*/
             field name as char            /*Название получателя или отправителя если платеж входящий*/
             field account as char         /*счет получателя*/
             field debit as deci           /*сумма по дебету*/
             field credit as deci          /*сумма по кредиту*/
             field currency_code as char   /*код валюты платежа (KZT, USD, EUR, RUR)*/
             field knp as char             /*код назначения платежа*/
             field knp_name as char        /*Название кода  назначения платежа*/
             field bank_bic as char        /*бик банка получателя*/
             field bank_name as char       /*Наименование банка получателя*/
             field payment_details as char /*Детали платежа*/
             field create_time as int.     /*Время создания проводки*/

/****************************************************************************************************************/
def var tmp_acc as char.
def var tmp_repno as char.
def buffer b-cashpool for comm.cashpool.
/****************************************************************************************************************/
function GetNormSumm returns char (input summ as deci):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then
   do:
    ss1 = summ.
    ret = string(ss1,">>>>>>>>>>>>>>>>9.99").
   end.
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,">>>>>>>>>>>>>>>>9.99")).
   end.
   return trim(ret).
end function.
/****************************************************************************************************************/
function GetDocCount returns int ():
  def var I as int init 0.
  for each extract no-lock:
    I = I + 1.
  end.
  return I.
end function.
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/
function GetRepNo returns int (input pCif as char, input acc as char):
  def buffer b-cashpool for comm.cashpool.
  def buffer b-cashpoolfill for comm.cashpool.
  def var RepNo as int init 0.

  find first b-cashpool where b-cashpool.cif = pCif and b-cashpool.isgo = true exclusive-lock no-error.
  if avail b-cashpool then
  do:
      if b-cashpool.acc = acc then
      do:
        b-cashpool.report = b-cashpool.report + 1.
        RepNo = b-cashpool.report.
      end.
      else do:
        find first b-cashpoolfill where b-cashpoolfill.cifgo = b-cashpool.cif and b-cashpoolfill.isgo = false and b-cashpoolfill.txb = b-cashpool.txb and b-cashpoolfill.acc = acc exclusive-lock no-error.
        if avail b-cashpoolfill then
        do:
          b-cashpoolfill.report = b-cashpoolfill.report + 1.
          RepNo = b-cashpoolfill.report.
        end.
      end.
  end.
  release b-cashpool.
  release b-cashpoolfill.
  return RepNo.
end function.
/****************************************************************************************************************/
function GetTxbBase returns char (input pacc as char).
  def var ccode as char.
  /* bpav TXB09*/
  /* для теста картела
  if pacc = "KZ11470172203A378716" or pacc = "KZ25470272203A369816" then ccode = "TXB09".
  else ccode = "TXB" + substr(pacc,19,2).
  */
  ccode = "TXB" + substr(pacc,19,2).
  return ccode.
end function.
/****************************************************************************************************************/

/****************************************************************************************************************/

procedure requestHandler:
    def input parameter requestH as handle.
    def input parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var msgText as char no-undo.
    def var pNames as char no-undo.
    def var pCif as char no-undo.
    def var pType as char no-undo.
    def var pAccount as char no-undo.
    def var pFromDate as date no-undo init ? .
    def var pToDate as date no-undo init ? .

    def var pUsr_name as char no-undo.
    def var pUsr_rnn as char no-undo.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).


    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then
    do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:


       pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).

       if lookup("EXT_ID",pNames)  > 0 then pCif      = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "EXT_ID").
       if lookup("TYPE",pNames) > 0 then pType = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TYPE").
       if lookup("ACCOUNT",pNames) > 0 then pAccount = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "ACCOUNT").
       if lookup("FROMDATE",pNames) > 0 then pFromDate  = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "FROMDATE")) no-error.
       if lookup("TODATE",pNames) > 0 then pToDate  = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TODATE")) no-error.


       run deleteMessage in requestH.


       if pFromDate = ? then pFromDate = g-today.
       if pToDate = ? then pToDate = g-today.


       /*---------------------------------------------------------------------------------------------------*/


       case pType:
         when "BALANCE"  then do:


            find first b-cashpool where b-cashpool.isgo = true and b-cashpool.cif = pCif no-lock no-error.
            if avail b-cashpool then
            do:

              find first comm.txb where comm.txb.bank = b-cashpool.txb and comm.txb.consolid = true no-lock no-error.
              if avail comm.txb then
              do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

                empty temp-table balance.

                run io-chpbal( pCif ).

                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                 run appendText in replyH ("<CATALOG>").

                  for each balance:

                   run appendText in replyH ("<ACCOUNT>").
                    run appendText in replyH ("<NUMBER>" + balance.acc + "</NUMBER>").
                    run appendText in replyH ("<CURRENCY>" + balance.crc + "</CURRENCY>").
                    run appendText in replyH ("<CIFNAME>" + balance.cifname + "</CIFNAME>").
                    run appendText in replyH ("<AVAILABLE_BALANCE>" + GetNormSumm(balance.avail-balance) + "</AVAILABLE_BALANCE>").
                    run appendText in replyH ("<TOTAL_BALANCE>" + GetNormSumm(balance.total-balance) + "</TOTAL_BALANCE>").
                    run appendText in replyH ("<OVERDRAFT>" + GetNormSumm(balance.over) + "</OVERDRAFT>").
                    run appendText in replyH ("<USED_OVERDRAFT>" + GetNormSumm(balance.used_over) + "</USED_OVERDRAFT>").
                   run appendText in replyH ("</ACCOUNT>").

                  end.

                 run appendText in replyH ("</CATALOG>").



              end.
              else do:
                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Ошибка - нет записи TXB!" + "</error>").
              end.
            end.
            else do:
             replyH = replyMessage.
             run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Пользователь не является корпоративным клиентом!" + "</error>").
            end.

         end.
         /*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
         when "EXTRACT"  then do:

            find first b-cashpool where b-cashpool.isgo = true and b-cashpool.cif = pCif no-lock no-error.
            if avail b-cashpool then
            do:

              find first comm.txb where comm.txb.bank = b-cashpool.txb and comm.txb.consolid = true no-lock no-error.
              if avail comm.txb then
              do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

                empty temp-table extract.

                /*run io-chpext( pCif , pAccount , pFromDate , pToDate , g-today ).*/
                run io-chpext( pCif , pAccount , pFromDate , pToDate , g-today ,output pUsr_name ,output pUsr_rnn).

                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                 run appendText in replyH ("<CATALOG>").
                 run appendText in replyH ("<TOTAL_COUNT>" + string(GetDocCount())+ "</TOTAL_COUNT>").  /* //общее количество записей */
			     run appendText in replyH ("<BEGIN_DATE>" + GetDate(pFromDate) + "</BEGIN_DATE>").
			     run appendText in replyH ("<END_DATE>" + GetDate(pToDate) + "</END_DATE>").
			     run appendText in replyH ("<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>").   /* //счет клиента если по всем счетам то пусто*/
			     run appendText in replyH ("<BANK_BIC>" + v-clecod + "</BANK_BIC>").
			     run appendText in replyH ("<BANK_OKPO>41151107</BANK_OKPO>").
			     run appendText in replyH ('<BANK_NAME>' + v-nbankru + '</BANK_NAME>').
			     run appendText in replyH ("<BANK_RNN>600400585309</BANK_RNN>").
			     run appendText in replyH ("<CLIENT_CODE>" + pCif + "</CLIENT_CODE>").
			     run appendText in replyH ("<CREATE_DATE>" + GetDate(today) + " " + string(time,"HH:MM:SS") + "</CREATE_DATE>").
			     run appendText in replyH ("<CLIENT_NAME>" + b-cashpool.name + "</CLIENT_NAME>").
                 run appendText in replyH ("<CLIENT_RNN>" + b-cashpool.rnn + "</CLIENT_RNN>").


                 tmp_acc = ''.
                 tmp_repno = ''.
                 /*********************************************************************************************/
                  for each extract:
                    if tmp_acc <> extract.ext_account then
                    do:
                       tmp_acc = extract.ext_account.
                       tmp_repno = string( GetRepNo( pCif , extract.ext_account ) ).
                    end.

if extract.date_doc < 05.07.2012 then do:
   extract.bank_bic = replace(extract.bank_bic,"fobakzka", "MEOKKZKA").
   extract.sender_bic = replace(extract.sender_bic,"fobakzka", "MEOKKZKA").
   extract.bank_name = replace(extract.bank_name,"fortebank", "МЕТРОКОМБАНК").
end.

                    run appendText in replyH ("<DOC>").
                    run appendText in replyH ("<REPORT_NUMBER>" + tmp_repno + "</REPORT_NUMBER>").
                    run appendText in replyH ("<EXT_ACCOUNT>" + extract.ext_account + "</EXT_ACCOUNT>").
                    run appendText in replyH ("<SENDER_ACCOUNT>" + extract.sender_account + "</SENDER_ACCOUNT>").
                    run appendText in replyH ("<SENDER_BIC>" + extract.sender_bic + "</SENDER_BIC>").
                    run appendText in replyH ("<INCOME>" + GetNormSumm(extract.income) + "</INCOME>").
                    run appendText in replyH ("<OUTCOME>" + GetNormSumm(extract.outcome) + "</OUTCOME>").
                    run appendText in replyH ("<OPER_CODE>" + extract.oper_code + "</OPER_CODE>").
                    run appendText in replyH ("<OPER_DATE>" + GetDate(extract.oper_date) + "</OPER_DATE>").
                    run appendText in replyH ("<NUM_DOC>" + extract.num_doc + "</NUM_DOC>").
                    run appendText in replyH ("<DEAL_CODE>" + extract.deal_code + "</DEAL_CODE>").
                    run appendText in replyH ("<DATE_DOC>" + GetDate(extract.date_doc) + "</DATE_DOC>").
                    run appendText in replyH ("<DATE_VAL>" + GetDate(extract.date_val) + "</DATE_VAL>").
                    run appendText in replyH ("<PLAT_VALUE>" + string(extract.plat_value) + "</PLAT_VALUE>").
                    run appendText in replyH ("<NAME><![CDATA[" + extract.name + "]]></NAME>").
                    run appendText in replyH ("<ACCOUNT>" + extract.account + "</ACCOUNT>").
                    run appendText in replyH ("<DEBIT>" + GetNormSumm(extract.debit) + "</DEBIT>").
                    run appendText in replyH ("<CREDIT>" + GetNormSumm(extract.credit) + "</CREDIT>").
                    run appendText in replyH ("<CURRENCY_CODE>" + extract.currency_code + "</CURRENCY_CODE>").
                    run appendText in replyH ("<KNP>" + extract.knp + "</KNP>").
                    run appendText in replyH ("<KNP_NAME>" + extract.knp_name + "</KNP_NAME>").
                    run appendText in replyH ("<BANK_BIC>" + extract.bank_bic + "</BANK_BIC>").
                    run appendText in replyH ("<BANK_NAME>" + extract.bank_name + "</BANK_NAME>").
                    run appendText in replyH ("<PAYMENT_DETAILS><![CDATA[" + extract.payment_details + "." + "]]></PAYMENT_DETAILS>").
                    run appendText in replyH ("<CREATE_TIME>" + string(extract.create_time,"HH:MM") + "</CREATE_TIME>").


                    run appendText in replyH ("</DOC>").
                  end.
                 /*********************************************************************************************/

                 run appendText in replyH ("</CATALOG>").


              end.
              else do:
                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Ошибка - нет записи TXB!" + "</error>").
              end.
            end.
            else do:  /* "Пользователь не является корпоративным клиентом!" */
            /*
             replyH = replyMessage.
             run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Пользователь не является корпоративным клиентом!" + "</error>").
             */

              find first comm.txb where comm.txb.bank = GetTxbBase(pAccount) and comm.txb.consolid = true no-lock no-error.
              if avail comm.txb then
              do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

                empty temp-table extract.

                /*run io-chpext( pCif , pAccount , pFromDate , pToDate , g-today ).*/
                run io-chpext( pCif , pAccount , pFromDate , pToDate , g-today ,output pUsr_name ,output pUsr_rnn).

                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                 run appendText in replyH ("<CATALOG>").
                 run appendText in replyH ("<TOTAL_COUNT>" + string(GetDocCount())+ "</TOTAL_COUNT>").  /* //общее количество записей */
			     run appendText in replyH ("<BEGIN_DATE>" + GetDate(pFromDate) + "</BEGIN_DATE>").
			     run appendText in replyH ("<END_DATE>" + GetDate(pToDate) + "</END_DATE>").
			     run appendText in replyH ("<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>").   /* //счет клиента если по всем счетам то пусто*/
			     run appendText in replyH ("<BANK_BIC>" + v-clecod + "</BANK_BIC>").
			     run appendText in replyH ("<BANK_OKPO>41151107</BANK_OKPO>").
			     run appendText in replyH ('<BANK_NAME>' + v-nbankru + '</BANK_NAME>').
			     run appendText in replyH ("<BANK_RNN>600400585309</BANK_RNN>").
			     run appendText in replyH ("<CLIENT_CODE>" + pCif + "</CLIENT_CODE>").
			     run appendText in replyH ("<CREATE_DATE>" + GetDate(today) + " " + string(time,"HH:MM:SS") + "</CREATE_DATE>").
                 run appendText in replyH ("<CLIENT_NAME>" + pUsr_name + "</CLIENT_NAME>").
                 run appendText in replyH ("<CLIENT_RNN>" + pUsr_rnn + "</CLIENT_RNN>").




                 tmp_acc = ''.
                 tmp_repno = ''.
                 /*********************************************************************************************/
                  for each extract:
                    if tmp_acc <> extract.ext_account then
                    do:
                       tmp_acc = extract.ext_account.
                       tmp_repno = "1" . /*string( GetRepNo( pCif , extract.ext_account ) ).*/
                    end.

if extract.date_doc < 05.07.2012 then do:
   extract.bank_bic = replace(extract.bank_bic,"fobakzka", "MEOKKZKA").
   extract.sender_bic = replace(extract.sender_bic,"fobakzka", "MEOKKZKA").
   extract.bank_name = replace(extract.bank_name,"fortebank", "МЕТРОКОМБАНК").
end.

                    run appendText in replyH ("<DOC>").
                    run appendText in replyH ("<REPORT_NUMBER>" + tmp_repno + "</REPORT_NUMBER>").
                    run appendText in replyH ("<EXT_ACCOUNT>" + extract.ext_account + "</EXT_ACCOUNT>").
                    run appendText in replyH ("<SENDER_ACCOUNT>" + extract.sender_account + "</SENDER_ACCOUNT>").
                    run appendText in replyH ("<SENDER_BIC>" + extract.sender_bic + "</SENDER_BIC>").
                    run appendText in replyH ("<INCOME>" + GetNormSumm(extract.income) + "</INCOME>").
                    run appendText in replyH ("<OUTCOME>" + GetNormSumm(extract.outcome) + "</OUTCOME>").
                    run appendText in replyH ("<OPER_CODE>" + extract.oper_code + "</OPER_CODE>").
                    run appendText in replyH ("<OPER_DATE>" + GetDate(extract.oper_date) + "</OPER_DATE>").
                    run appendText in replyH ("<NUM_DOC>" + extract.num_doc + "</NUM_DOC>").
                    run appendText in replyH ("<DEAL_CODE>" + extract.deal_code + "</DEAL_CODE>").
                    run appendText in replyH ("<DATE_DOC>" + GetDate(extract.date_doc) + "</DATE_DOC>").
                    run appendText in replyH ("<DATE_VAL>" + GetDate(extract.date_val) + "</DATE_VAL>").
                    run appendText in replyH ("<PLAT_VALUE>" + string(extract.plat_value) + "</PLAT_VALUE>").
                    run appendText in replyH ("<NAME><![CDATA[" + extract.name + "]]></NAME>").
                    run appendText in replyH ("<ACCOUNT>" + extract.account + "</ACCOUNT>").
                    run appendText in replyH ("<DEBIT>" + GetNormSumm(extract.debit) + "</DEBIT>").
                    run appendText in replyH ("<CREDIT>" + GetNormSumm(extract.credit) + "</CREDIT>").
                    run appendText in replyH ("<CURRENCY_CODE>" + extract.currency_code + "</CURRENCY_CODE>").
                    run appendText in replyH ("<KNP>" + extract.knp + "</KNP>").
                    run appendText in replyH ("<KNP_NAME>" + extract.knp_name + "</KNP_NAME>").
                    run appendText in replyH ("<BANK_BIC>" + extract.bank_bic + "</BANK_BIC>").
                    run appendText in replyH ("<BANK_NAME>" + extract.bank_name + "</BANK_NAME>").
                    run appendText in replyH ("<PAYMENT_DETAILS><![CDATA[" + extract.payment_details + "." + "]]></PAYMENT_DETAILS>").
                    run appendText in replyH ("<CREATE_TIME>" + string(extract.create_time,"HH:MM") + "</CREATE_TIME>").


                    run appendText in replyH ("</DOC>").
                  end.
                 /*********************************************************************************************/

                 run appendText in replyH ("</CATALOG>").


              end.
              else do:
                 replyH = replyMessage.
                 run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Ошибка - нет записи TXB!" + "</error>").
              end.

            end.

         end.
       end.
       /*---------------------------------------------------------------------------------------------------*/
       /*
       hide message no-pause.
       message pNames.
       */
    /* RUN sendToQueue IN ptpsession ("test1", replyH, ?, ?, ?).*/
    end.
end.
/****************************************************************************************************************/
function inWait returns logical.
    return not(v-terminate).
end.
/****************************************************************************************************************/


