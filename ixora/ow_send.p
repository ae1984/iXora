/* ow_send.p
 * MODULE
        Коммунальные платежи - Авангард-Плат
 * DESCRIPTION
        Отправка запросов в Авангард-Плат
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
        12/05/2013 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
           
*/

{srvcheck.i}
{xmlParser.i}

def input parameter p-type as char no-undo.  /*Функция*/
def input parameter p-inn as char no-undo.   /*ИИН*/
def input parameter p-acc as char no-undo.   /*Номер счета*/
def input parameter p-date1 as char no-undo. /*Дата начала периода выбора*/
def input parameter p-date2 as char no-undo. /*Дата окончания периода выбора*/
def input parameter p-msg as char no-undo.   /*Message Code*/
def input parameter p-crc as char no-undo.   /*Код валюты*/
def input parameter p-amt as char no-undo.   /*Сумма*/
def input parameter p-rem as char no-undo.   /*Примечание*/
def input parameter p-frid as char no-undo.  /*Идентификатор операции*/


def output parameter p-message_out as longchar no-undo.
def output parameter p-code_out as log no-undo.



def var ptpsession as handle.
def var consumerh as handle.
def var requesth as handle.

define variable DataUser as character no-undo.
define variable DataPass as character no-undo.
define variable DataUrl as character no-undo.

run jms/jmssession.p persistent set ptpsession ("-SMQConnect").

/*
run setbrokerurl in ptpsession ("tcp://ST00848:2507").
*/

if isProductionServer() then 
do:
    run setBrokerURL in ptpsession ("tcp://172.16.1.22:2507").
    DataUser = "FORTE_IN".
    DataPass = "forte1234".
    DataUrl  = "jdbc:oracle:thin:@192.168.105.44:1521:produtf".
end. 
else 
do:
    run setBrokerURL in ptpsession ("tcp://172.16.1.12:2507").
    DataUser = "FORTE".
    DataPass = "forte1234".
    DataUrl  = "jdbc:oracle:thin:@192.168.105.45:1521:TESTUTF".
end.


/* Логирование потом убрать*/
function LogFile returns integer (input p-file as char, input p-mess as char).
    output to value(p-file) append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
    return 0.
end function.
/****************************************************************/
run setUser in ptpsession ('SonicClient').
run setPassword in ptpsession ('SonicClient').
run beginSession in ptpsession.


run createxmlmessage in ptpsession (output requesth).
run createmessageconsumer in ptpsession (this-procedure, "replyhandler", output consumerh).
run startreceivemessages in ptpsession.
run settext in requesth ("OW_MESSAGE").


run setStringProperty in requesth ("TYPE",p-type).
run setStringProperty in requesth ("IDN",p-inn).
run setStringProperty in requesth ("ACCOUNT",p-acc).
run setStringProperty in requesth ("BEGINDATE",p-date1).
run setStringProperty in requesth ("ENDDATE",p-date2).
run setStringProperty in requesth ("MSGCODE",p-msg).
run setStringProperty in requesth ("CURRENCY",p-crc).
run setStringProperty in requesth ("AMT",p-amt).
run setStringProperty in requesth ("REM",p-rem).
run setStringProperty in requesth ("FRID",p-frid).

run setStringProperty in requesth ("DataUser",DataUser).
run setStringProperty in requesth ("DataPass",DataPass).
run setStringProperty in requesth ("DataUrl",DataUrl).


LogFile("ow_send.log","Request  ->: " + "<TYPE>" + trim(p-type) + "</TYPE><IDN>" + trim(p-inn) + "</IDN><ACCOUNT>" + trim(p-acc) + "</ACCOUNT><BEGINDATE>" + trim(p-date1) + "</BEGINDATE><ENDDATE>" + trim(p-date2) + "</ENDDATE><MSGCODE>" + trim(p-msg) + "</MSGCODE><CURRENCY>" + trim(p-crc) + "</CURRENCY><AMT>" + trim(p-amt) + "</AMT><REM>" + trim(p-rem) + "</REM><FRID>" + trim(p-frid) + "</FRID>").


run requestreply in ptpsession ( "OPENWAY",
                                 requesth,
                                 ?, /* no reply selector */
                                 consumerh,
                                 ?, /* priority */
                                 35000, /* Time to Live, milliseconds */
                                 "NON_PERSISTENT" /* Persistency = off, i.e. messages are not available after broker restart */
                                 ).

run deletemessage in requesth.

wait-for u1 of this-procedure.

run stopReceiveMessages in ptpsession.
run deleteSession in ptpsession.


procedure replyhandler:
    define input parameter replyh as handle.
    define input parameter msgconsumerh as handle.
    define output parameter responseh as handle.
    def var v-reply as char no-undo.
    define variable pRez as character.
    define variable pRet as longchar.
    
    define variable v-out as log.
   /* p-message_out = dynamic-function('gettext':u in replyh).*/
    
    pRez = DYNAMIC-FUNCTION('getPropertyNames':U IN replyh).
    if lookup("ERROR",pRez)  > 0 then do:
      pRet = DYNAMIC-FUNCTION('getCharProperty':U IN replyh, "ERROR").
      p-code_out = false.
      p-message_out = pRet.
    end.  
    else do:
      p-message_out = dynamic-function('getlongtext':u in replyh). 
      if index(p-message_out,"ERROR") > 0 then p-code_out = false. 
      else
      if GetLongParamValueOne(p-message_out,"ErrorCode") <> "" then do: 
          p-message_out = GetLongParamValueOne(p-message_out,"ErrorDes"). p-code_out = false. 
      end.
      else p-code_out = true.   
    end.
    
    define variable tmp as character.
    define variable i as integer.
    if length(p-message_out) > 30000 then do:
       repeat i = 1 to length(p-message_out):
         tmp = substring(p-message_out,i,30000).
         LogFile("ow_send.log","Response <-: " + tmp).
         i = i + 30000.  
       end.     
    end.
    else do:
       tmp = p-message_out. 
       LogFile("ow_send.log","Response <-: " + tmp).
    end. 
          
    /*Заглушка на ошибку в OW (убрать когда исправят!)*/
    /*
    if index(p-message_out,"ORA-01000: maximum open cursors exceeded") > 0  then do:
       run ow_send("Disconnect","","","","","","","","","",output pRez,output v-out).
    end.
    */           
       
    run deletemessage in replyh.
    apply "u1" to this-procedure.
end.


