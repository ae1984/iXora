/* rate_toscr.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        04/04/2012 k.gitalov
 * BASES
        BANK
 * CHANGES
*/

{system.i}
{srvcheck.i}

DEFINE VARIABLE hSocket     AS HANDLE  NO-UNDO.
DEFINE VARIABLE mReseivData AS MEMPTR  NO-UNDO.
DEFINE VARIABLE mSendData   AS MEMPTR  NO-UNDO.
DEFINE VARIABLE vStatus     AS INTEGER INIT 0.
DEFINE VARIABLE cResponseData AS CHAR NO-UNDO.
DEFINE VARIABLE cRequestData AS CHAR NO-UNDO.
DEFINE VARIABLE ConnectString AS CHAR.
def var p-rez as log init false.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).


cRequestData = "<FILENAME>C:\\\\inetpub\\ScreenMap\\data\\" + s-ourbank + "</FILENAME><DATA>" .

for each crc where crc.crc <> 1 no-lock:
   cRequestData = cRequestData + crc.code + "1=" + trim(string(crc.rate[2],"->>>>>9.99")) + "&" + crc.code + "2=" + trim(string(crc.rate[3],"->>>>>9.99")) + "&".
end.

cRequestData = cRequestData + "TODAY=" + string(today,"99.99.9999") + "&TIME=" + string(time,"HH:MM:SS").
/*cRequestData = substr(cRequestData,1,length(cRequestData) - 1 ).*/
cRequestData = cRequestData + "</DATA>".


PAUSE 0 BEFORE-HIDE.

    if isProductionServer() then do:
      ConnectString = "-H 172.16.1.34 -S 2014".
    end.
    else do:
      ConnectString = "-H ST00320 -S 2014".
    end.


  CREATE SOCKET hSocket.
  hSocket:SET-SOCKET-OPTION("TCP-NODELAY", "FALSE" ).
  hSocket:CONNECT(ConnectString) NO-ERROR.
  if not hSocket:CONNECTED() then
  do:
    message "Нет связи с сервисом!" view-as alert-box.
    p-rez = false.
    return.
  end.

  hSocket:SET-READ-RESPONSE-PROCEDURE("ProcessServerResponse",THIS-PROCEDURE).

  /******************************************************************************************/
  RUN SendData(cRequestData ).
  /******************************************************************************************/
  REPEAT ON STOP UNDO, LEAVE ON QUIT UNDO, LEAVE:
     if vStatus <> 0 then LEAVE.
     WAIT-FOR READ-RESPONSE OF hSocket.
  END.
  /******************************************************************************************/
  hSocket:DISCONNECT() NO-ERROR.
  DELETE OBJECT hSocket.
  SET-SIZE ( mReseivData ) = 0.
  SET-SIZE ( mSendData ) = 0.

  def var ind1 as int.
  def var ind2 as int.
  def var rez as int.
  if cResponseData = "" then p-rez = false.
  else do:
   rez = integer(GetXMLParamValue(cResponseData,"RESULT")).
   if rez <> 0 then do: hide message no-pause. message "Ошибка при получении результата выполнения!" view-as alert-box. p-rez = false. end.
   else p-rez = true.
  end.

/*------------------------------------------------------------------------------*/
PROCEDURE SendData:
 def input param Data as char.
 def var MessSize as int.
 def var lRC as log no-undo.
 Data = Data + "\n".
 MessSize = LENGTH(Data).
 if MessSize > 0 then
 do:
   SET-SIZE(mSendData) = 0.
   SET-SIZE(mSendData) = MessSize + 1.
   SET-BYTE-ORDER(mSendData) = BIG-ENDIAN.
   PUT-LONG(mSendData,1) = MessSize + 1.
   PUT-STRING(mSendData,1) = Data.
   lRC = hSocket:WRITE(mSendData,1,MessSize) NO-ERROR.
   IF lRC = FALSE OR ERROR-STATUS:GET-MESSAGE(1) <> '' THEN
   DO:
    message "Ошибка при передаче данных!" view-as alert-box.
    vStatus = 2.
    LEAVE.
    RETURN.
   END.
   else do:
     vStatus = 0.
   end.
 end.
END PROCEDURE.
/*------------------------------------------------------------------------------*/
PROCEDURE ProcessServerResponse:
  DEFINE VARIABLE cReceivData AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iMessageSize AS INTEGER NO-UNDO.
  DEFINE VARIABLE lRC AS LOG NO-UNDO.
  IF SELF:CONNECTED() = FALSE THEN do: vStatus = 1. /* message "Нет соединения" view-as alert-box.*/ LEAVE.  RETURN.  end.
  iMessageSize = hSocket:GET-BYTES-AVAILABLE().
  if iMessageSize > 0 then
  do:
      SET-SIZE(mReseivData) = iMessageSize.
      lRC = hSocket:READ(mReseivData,1,iMessageSize,2) NO-ERROR.
      if lRC = FALSE OR ERROR-STATUS:GET-MESSAGE(1) <> '' THEN
      DO:
         vStatus = 2.
         LEAVE.
         RETURN.
      END.
      cReceivData = GET-STRING(mReseivData,1).
      cResponseData = cResponseData + cReceivData.
  end. /*iMessageSize > 0*/
END PROCEDURE.
