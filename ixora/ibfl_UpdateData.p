/* ibfl_UpdateData.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для обновления данных клиента ИБФЛ
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
        20/08/2013 k.gitalov
 * BASES
        COMM TXB
 * CHANGES
*/

{srvcheck.i}

def input parameter p-cif as char no-undo.  /*cif code*/
def input parameter p-phone as char no-undo.   /*номер телефона*/
define output parameter p-err as character no-undo.

define variable replyText as character.

if p-cif = "" then do:
  p-err = "ERR: ibfl_UpdateData -> no cif".
  message p-err.
  return.  
end.
if p-phone <> "" then do:
  message "ibfl_UpdateData -> update user phone cif = " + p-cif + " phone = " + p-phone. 
  find first txb.cif where txb.cif.cif = p-cif exclusive-lock no-error no-wait.
  if available txb.cif then do:
     txb.cif.fax = p-phone. 
  end.    
  else do:
    p-err = "ERR: ibfl_UpdateData -> table cif not available...".
    message p-err.
    return.
  end.
end.

/******************************************************************************/
  run ibfl_init(p-cif, output replyText, output p-err).
/******************************************************************************/

if p-err <> "" then do:
  message "ERR: ibfl_UpdateData ->" + p-err.
  return.  
end.
              

DEFINE VARIABLE ptpsession AS HANDLE.
DEFINE VARIABLE messageH AS HANDLE.
run jms/jmssession.p persistent set ptpsession ("-SMQConnect").

/*    RUN setBrokerURL IN ptpsession ("tcp://172.16.2.77:2507").   */
if isProductionServer() then do:
    RUN setBrokerURL IN ptpsession ("tcp://172.16.3.5:2507").
end.
else do:
    RUN setBrokerURL IN ptpsession ("tcp://172.16.2.77:2507").
end.




       run setUser in ptpsession ('SonicClient').
       run setPassword in ptpsession ('SonicClient').
       RUN beginSession IN ptpsession.
       run createXMLMessage in ptpsession (output messageH).

       RUN setStringProperty IN messageH ("TYPE", "CLIENT").

       run appendText in messageH (replyText).
        
       RUN sendToQueue IN ptpsession ("CLIENTS", messageH, ?, ?, ?).

       RUN deleteMessage IN messageH.
       RUN deleteSession IN ptpsession.
       