/* ext940gen.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Формирование выписок в формате mt940
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
        18.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        12.02.2013 damir   - Внедрено Т.З. № 1698.
*/


{classes.i}
{srvcheck.i}
{nbankBik.i}


def input parameter pAccount as char.
def output parameter rcode as inte.
def output parameter rdes as char.


def new shared temp-table extract_tmp
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
  for each extract_tmp no-lock:
    I = I + 1.
  end.
  return I.
end function.
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
  return replace(string(dt,"99/99/9999"),"/",".").
end function.
/****************************************************************************************************************/
function GetTxbBase returns char (input pacc as char).
  def var ccode as char.
  ccode = "TXB" + substr(pacc,19,2).
  return ccode.
end function.
/****************************************************************************************************************/
function GetRepNo returns int (input pCif as char, input acc as char):
  def var RepNo as int init 1.

  return RepNo.
end function.



/***********************************************************************************************/
def var q_name as char init "MT940Queue".
def var ptpsession as handle.
def var requestMessage as handle.
def var replyMessage as handle.
def var p-rez as log.
def var pCif as char.
def var tmp_text as char.
def var pFromDate as date no-undo .
def var pToDate as date no-undo.
def var tmp_repno as char init "".
def var tmp_acc as char init "".
def var FileName as char.

/*
pFromDate = date(5,11,2011).
pToDate = date(5,11,2011).
*/

if pFromDate = ? then pFromDate = g-today.
if pToDate = ? then pToDate = g-today.


find first aaa where aaa.aaa = pAccount no-lock no-error.
if avail aaa then pCif = aaa.cif.

def var pUsr_name as char no-undo.
def var pUsr_rnn as char no-undo.


empty temp-table extract_tmp.
run extcre( pCif , pAccount , pFromDate  , pToDate , g-today ,output pUsr_name ,output pUsr_rnn).

find first extract_tmp no-lock no-error.
if not avail extract_tmp then do:
   rcode = 2.
   /*rdes = "Не найден счет " + pAccount + "cif=" + pCif.*/
   rdes = "Нет данных для формирования выписки MT940 для " + pAccount + " cif=" + pCif.
   return.
end.

/***********************************************************************************************/
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").  /*боевой*/
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507"). /*тестовый*/
/***********************************************************************************************/

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.


run createxmlmessage in ptpsession (output requestMessage).
run createmessageconsumer in ptpsession (this-procedure, "replyhandler", output replyMessage).
run startReceiveMessages in ptpsession.


FileName = "rep" + replace(string(today),"/","") + replace(string(time,"HH:MM:SS"),":","") + ".mt".

run SendRequest.

run requestreply in ptpsession ( q_name,
                                 requestMessage,
                                 ?, /* no reply selector */
                                 replyMessage,
                                 ?, /* priority */
                                 35000, /* Time to Live, milliseconds */
                                 "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
                                 ).

run deletemessage in requestMessage.
wait-for u1 of this-procedure.

/***********************************************************************************/

if p-rez = true then do:
  rcode = 0.
  rdes = FileName.
end.
else do:
  rcode = 1.
  rdes = tmp_text.
end.

message "Завершение работы".
/*unix silent cptwin value(FileName) iexplore.*/
/***********************************************************************************/


run stopReceiveMessages in ptpsession.
run deleteConsumer in ptpsession no-error.
run deleteSession in ptpsession.



/***********************************************************************************/
procedure replyhandler:
    define input parameter replyH as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.
    def var xmlText as char.
    def var p-out as char.
    tmp_text = "".
    output to value(FileName).

    p-out = DYNAMIC-FUNCTION('getCharProperty':U IN replyH, "REZULT").

    DO WHILE NOT DYNAMIC-FUNCTION('endOfStream' IN replyH):
       xmlText = DYNAMIC-FUNCTION('getTextSegment':U IN replyH).
       tmp_text = tmp_text + xmlText.
       put unformatted xmlText.
    END.

    output close.
    if p-out = "OK" then p-rez = true.
    else p-rez = false.


    run deletemessage in replyH.
    apply "u1" to this-procedure.
end.
/***********************************************************************************/

procedure SendRequest:

                 run setText in requestMessage ("<?xml version=""1.0"" encoding=""UTF-8""?>").
                 run appendText in requestMessage ("<CATALOG>").
                 run appendText in requestMessage ("<TOTAL_COUNT>" + string(GetDocCount())+ "</TOTAL_COUNT>").  /* //общее количество записей */
			     run appendText in requestMessage ("<BEGIN_DATE>" + GetDate(pFromDate) + "</BEGIN_DATE>").
			     run appendText in requestMessage ("<END_DATE>" + GetDate(pToDate) + "</END_DATE>").
			     run appendText in requestMessage ("<CLIENT_ACCOUNT>" + pAccount + "</CLIENT_ACCOUNT>").   /* //счет клиента если по всем счетам то пусто*/
			     run appendText in requestMessage ("<BANK_BIC>" + v-clecod + "</BANK_BIC>").
			     run appendText in requestMessage ("<BANK_OKPO>41151107</BANK_OKPO>").
			     run appendText in requestMessage ('<BANK_NAME>' + v-nbankru + '</BANK_NAME>').
			     run appendText in requestMessage ("<BANK_RNN>600400585309</BANK_RNN>").
			     run appendText in requestMessage ("<CLIENT_CODE>" + pCif + "</CLIENT_CODE>").
			     run appendText in requestMessage ("<CREATE_DATE>" + GetDate(today) + " " + string(time,"HH:MM:SS") + "</CREATE_DATE>").
                 run appendText in requestMessage ("<CLIENT_NAME>" + pUsr_name + "</CLIENT_NAME>").
                 run appendText in requestMessage ("<CLIENT_RNN>" + pUsr_rnn + "</CLIENT_RNN>").




                 tmp_acc = ''.
                 tmp_repno = ''.
                 /*********************************************************************************************/
                  for each extract_tmp:
                    if tmp_acc <> extract_tmp.ext_account then
                    do:
                       tmp_acc = extract_tmp.ext_account.
                       tmp_repno = string( GetRepNo( pCif , extract_tmp.ext_account ) ).
                    end.

                    run appendText in requestMessage ("<DOC>").
                    run appendText in requestMessage ("<REPORT_NUMBER>" + tmp_repno + "</REPORT_NUMBER>").
                    run appendText in requestMessage ("<EXT_ACCOUNT>" + extract_tmp.ext_account + "</EXT_ACCOUNT>").
                    run appendText in requestMessage ("<SENDER_ACCOUNT>" + extract_tmp.sender_account + "</SENDER_ACCOUNT>").
                    run appendText in requestMessage ("<SENDER_BIC>" + extract_tmp.sender_bic + "</SENDER_BIC>").
                    run appendText in requestMessage ("<INCOME>" + GetNormSumm(extract_tmp.income) + "</INCOME>").
                    run appendText in requestMessage ("<OUTCOME>" + GetNormSumm(extract_tmp.outcome) + "</OUTCOME>").
                    run appendText in requestMessage ("<OPER_CODE>" + extract_tmp.oper_code + "</OPER_CODE>").
                    run appendText in requestMessage ("<OPER_DATE>" + GetDate(extract_tmp.oper_date) + "</OPER_DATE>").
                    run appendText in requestMessage ("<NUM_DOC>" + extract_tmp.num_doc + "</NUM_DOC>").
                    run appendText in requestMessage ("<DEAL_CODE>" + extract_tmp.deal_code + "</DEAL_CODE>").
                    run appendText in requestMessage ("<DATE_DOC>" + GetDate(extract_tmp.date_doc) + "</DATE_DOC>").
                    run appendText in requestMessage ("<DATE_VAL>" + GetDate(extract_tmp.oper_date) + "</DATE_VAL>").
                    run appendText in requestMessage ("<PLAT_VALUE>" + string(extract_tmp.plat_value) + "</PLAT_VALUE>").
                    run appendText in requestMessage ("<NAME><![CDATA[" + extract_tmp.name + "]]></NAME>").
                    run appendText in requestMessage ("<ACCOUNT>" + extract_tmp.account + "</ACCOUNT>").
                    run appendText in requestMessage ("<DEBIT>" + GetNormSumm(extract_tmp.debit) + "</DEBIT>").
                    run appendText in requestMessage ("<CREDIT>" + GetNormSumm(extract_tmp.credit) + "</CREDIT>").
                    run appendText in requestMessage ("<CURRENCY_CODE>" + extract_tmp.currency_code + "</CURRENCY_CODE>").
                    run appendText in requestMessage ("<KNP>" + extract_tmp.knp + "</KNP>").
                    run appendText in requestMessage ("<KNP_NAME>" + extract_tmp.knp_name + "</KNP_NAME>").
                    run appendText in requestMessage ("<BANK_BIC>" + extract_tmp.bank_bic + "</BANK_BIC>").
                    run appendText in requestMessage ("<BANK_NAME>" + extract_tmp.bank_name + "</BANK_NAME>").
                    run appendText in requestMessage ("<PAYMENT_DETAILS><![CDATA[" + extract_tmp.payment_details + "." + "]]></PAYMENT_DETAILS>").
                    run appendText in requestMessage ("<CREATE_TIME>" + string(extract_tmp.create_time,"HH:MM") + "</CREATE_TIME>").


                    run appendText in requestMessage ("</DOC>").
                  end.
                 /*********************************************************************************************/

                 run appendText in requestMessage ("</CATALOG>").



end procedure.



