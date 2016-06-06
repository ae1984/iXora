/* cm18_trx.p
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
 * BASES
        BANK COMM
 * AUTHOR
        13/02/2012 k.gitalov
 * CHANGES
        15/09/2012 k.gitalov Изменение строки соединения для администраторов и дежурных программистов

*/

{global.i}
{system.i}
{cm18.i}


def input param v-safe as char.
def input param v-side as char.
def input param v-comm as char.
def input param v-ext as char.
def output param v-data as char.
def output param v-rez as int.




DEFINE VARIABLE hSocket     AS HANDLE  NO-UNDO.
DEFINE VARIABLE mReseivData AS MEMPTR  NO-UNDO.
DEFINE VARIABLE mSendData   AS MEMPTR  NO-UNDO.
DEFINE VARIABLE vStatus     AS INTEGER INIT 0.
DEFINE VARIABLE cRequestData AS CHAR INIT "".
DEFINE VARIABLE cResponseData AS CHAR NO-UNDO.
DEFINE VARIABLE ConnectString AS CHAR.

def var ClientIP as char.
/*
Алексей ST00770 id00787
Константин ST00848 id00205
Луиза st00518 id00800
Иван ST33333 id00700
Антон ST55555 id00640
Саша ST99999 id00477
ЗЫ: впечатление, что все наши админы озабочены крутыми номерами... и как расплачиваться будут (за номера), когда машины купят о_О
*/

/***********************************************************************************************************/
function GetAdmName returns char ( input st_val as char ):
 def var STLIST as char init "ST00770.metrobank.kz,ST00848.metrobank.kz,ST33333.metrobank.kz,ST55555.metrobank.kz,ST99999.metrobank.kz,st00518.metrobank.kz".
 def var USRLIST as char format "x(25)" extent 6 init  ["id00787","id00205","id00700","id00640","id00477","id00800"].
   if st_val = "" then return "".
   return  USRLIST[LOOKUP(st_val , STLIST)].
end function.
/***********************************************************************************************************/

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).


PAUSE 0 BEFORE-HIDE.



cRequestData = "<Command>" + v-comm + "</Command><Data>" + v-ext + "</Data><Safe>" + v-safe + "</Safe><Side>" + v-side + "</Side>".
run savelog( "cm18_trx", "cRequestData=" + cRequestData ).

/*------------------------------------  START  ----------------------------------------------*/

if ClientIP = "" then do:
  input through askhost.
  import ClientIP.
  input close.
end.


if trim(g-fname) = "run" then quit.
if g-fname = "EKADM" then do:
  if GetAdmName(ClientIP) = g-ofc then ConnectString = "-H EK01 -S 2012".
  else do: message "O_O" view-as alert-box. quit. end.
end.
else ConnectString = "-H " + ClientIP + " -S 2012".


  CREATE SOCKET hSocket.
  hSocket:SET-SOCKET-OPTION("TCP-NODELAY", "FALSE" ).
  hSocket:CONNECT(ConnectString) NO-ERROR.
  if not hSocket:CONNECTED() then
  do:
    message "Нет связи с сервисом!" view-as alert-box.
    v-rez = 1001.
    return.
  end.

  hSocket:SET-READ-RESPONSE-PROCEDURE("ProcessServerResponse",THIS-PROCEDURE).

  /******************************************************************************************/
  RUN SendData(cRequestData ).
  /******************************************************************************************/


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


  run savelog( "cm18_trx", "cResponseData=" + cResponseData ).

  if cResponseData = "" then do: v-data = "". v-rez = 1002. /*Обрыв связи*/ end.
  else do:
   v-rez = integer(GetParamValue(cResponseData,"Result")).
   v-data = GetParamValue(cResponseData,"Data").
  end.

/*------------------------------------------------------------------------------*/
PROCEDURE SendData:
 def input param Data as char.
 def var MessSize as int.
 def var lRC as log no-undo.
 Data = Data + '\n'.

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

/*------------------------------------  STOP  ----------------------------------------------*/
PROCEDURE ProcessServerResponse:
  DEFINE VARIABLE cReceivData AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iMessageSize AS INTEGER NO-UNDO.
  DEFINE VARIABLE lRC AS LOG NO-UNDO.
  IF SELF:CONNECTED() = FALSE THEN do: vStatus = 1.  LEAVE.  RETURN.  end.

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

  end.

END PROCEDURE.

/**************************************************************************************************************/

