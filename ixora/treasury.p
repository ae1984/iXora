/* treasury.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
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
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.3.5:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.2.77:2507").
run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.
run createXMLMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (THIS-PROCEDURE,"requestHandler",output consumerH).
run receiveFromQueue in ptpsession ("TREASURY", ?, consumerH).
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
             field cif as char
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

def buffer b-treasury for comm.treasury.
def buffer b2-treasury for comm.treasury.
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
function GetTxbBase returns char (input pacc as char).
  def var ccode as char.
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
    def var pLogin as char no-undo.
    def var pAccount as char no-undo.
    def var pFromDate as date no-undo init ? .
    def var pToDate as date no-undo init ? .

    def var pUsr_name as char no-undo.
    def var pUsr_rnn as char no-undo.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:
        pNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).
        if lookup("EXT_ID",pNames)  > 0 then pCif = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "EXT_ID").
        if lookup("TYPE",pNames) > 0 then pType = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "TYPE").
        if lookup("login",pNames) > 0 then pLogin = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "login").

        message "*****************************************************".
        message string(today,"99/99/9999").
        message string(time,"HH:MM:SS").
        message string(pNames).
        message "*****************************************************".
        message "           EXT_ID = " string(pCif).
        message "             TYPE = " string(pType).
        message "            login = " string(pLogin).
        message "*****************************************************".

        run deleteMessage in requestH.

        if pFromDate = ? then pFromDate = g-today.
        if pToDate = ? then pToDate = g-today.

        case pType:
            when "TREASURY_BALANCE" then do:
                find first b-treasury where b-treasury.isgo = true and b-treasury.cif = pCif and b-treasury.login = pLogin no-lock no-error.
                if avail b-treasury and b-treasury.cwho <> "" and b-treasury.cwhn <> ? then do:
                    find first b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = b-treasury.cif and b2-treasury.login = b-treasury.login and b2-treasury.cwho <> "" and b2-treasury.cwhn <> ? no-lock no-error.
                    if avail b2-treasury then do:

                       replyH = replyMessage.
                       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").

                       empty temp-table balance.

                       for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = b-treasury.cif and b2-treasury.login = b-treasury.login and b2-treasury.cwho <> "" and b2-treasury.cwhn <> ? no-lock
                       break by b2-treasury.txb:
                          if first-of(b2-treasury.txb) then do:
                             find first comm.txb where comm.txb.bank = b2-treasury.txb and comm.txb.consolid = true no-lock no-error.
                             if avail comm.txb then do:
                                if connected ("txb") then disconnect "txb".
                                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                             end.
                          end.
                          run io-trebal(b2-treasury.cif,b2-treasury.acc).
                       end.
                       if connected ("txb") then disconnect "txb".

                       run appendText in replyH ("<CATALOG>").
                       for each balance no-lock:
                          run appendText in replyH ("<ACCOUNT>").
                          run appendText in replyH ("<NUMBER>" + balance.acc + "</NUMBER>").
                          run appendText in replyH ("<CURRENCY>" + balance.crc + "</CURRENCY>").
                          run appendText in replyH ("<CIF>" + balance.cif + "</CIF>").
                          run appendText in replyH ("<CIFNAME>" + balance.cifname + "</CIFNAME>").
                          run appendText in replyH ("<TOTAL_BALANCE>" + GetNormSumm(balance.total-balance) + "</TOTAL_BALANCE>").
                          run appendText in replyH ("</ACCOUNT>").
                       end.
                       run appendText in replyH ("</CATALOG>").

                    end.
                    else do:
                       replyH = replyMessage.
                       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Данные не найдены либо не акцептованы!" + "</error>").
                    end.
                end.
                else do:
                    replyH = replyMessage.
                    run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?><error>" + "Пользователь не является корпоративным клиентом!" + "</error>").
                end.
            end.
        end.
    end.
end.
/****************************************************************************************************************/
function inWait returns logical.
    return not(v-terminate).
end.
/****************************************************************************************************************/





