/* SMS_ps.p
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
        17/08/09 id00205
 * CHANGES
        05.07.2013 Lyubov - ТЗ 1943, отправка не более 200 смс за сессию


*/

DEFINE VARIABLE hSocket     AS HANDLE  NO-UNDO.
DEFINE VARIABLE lRC         AS LOGICAL NO-UNDO.
DEFINE VARIABLE mReseivData AS MEMPTR  NO-UNDO.
DEFINE VARIABLE mSendData   AS MEMPTR  NO-UNDO.
DEFINE VARIABLE vStatus     AS INTEGER INIT 0.
DEFINE VARIABLE dlm         AS CHAR INIT "^".
DEFINE VARIABLE RetData     AS CHAR.
def var i as int.

/*if not connected("comm") then run conncom.*/

define buffer b-smspool for comm.smspool.
PAUSE 0 BEFORE-HIDE.


/*------------------------------------  START  ----------------------------------------------*/
  CREATE SOCKET hSocket.

  hSocket:CONNECT('-H 10.0.0.61 -S 2009') NO-ERROR.
  if not hSocket:CONNECTED() then
  do:
    message "Нет соединения с сервером!" view-as alert-box. return.
  end.
  hSocket:SET-READ-RESPONSE-PROCEDURE("ProcessServerResponse",THIS-PROCEDURE).

  REPEAT ON STOP UNDO, LEAVE ON QUIT UNDO, LEAVE:
     if vStatus <> 0 then LEAVE.
     WAIT-FOR READ-RESPONSE OF hSocket.
  END.

  RUN UpdateStatus.

  /******************************************************************************************/
   i = 0.
   for each smspool where smspool.state = 2 no-lock:
   i = i + 1.
    RUN SendData(smspool.id,smspool.tell,smspool.mess).
    if i >= 200 then leave.
   end.
  /******************************************************************************************/


  hSocket:DISCONNECT() NO-ERROR.

  DELETE OBJECT hSocket.
  SET-SIZE ( mReseivData ) = 0.
  SET-SIZE ( mSendData ) = 0.

/*  if connected("comm") then disconnect "comm".*/

/*------------------------------------  STOP  ----------------------------------------------*/

PROCEDURE ProcessServerResponse:
  DEFINE VARIABLE cReceivData AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iMessageSize AS INTEGER NO-UNDO.

  IF SELF:CONNECTED() = FALSE THEN do: vStatus = 1. /*message "Нет соединения" view-as alert-box. LEAVE.  RETURN. */ end.

  iMessageSize = hSocket:GET-BYTES-AVAILABLE().

  if iMessageSize > 0 then
  do:

    SET-SIZE(mReseivData) = iMessageSize + 1.

    hSocket:READ(mReseivData, 1 , iMessageSize, 1 ).

    cReceivData = GET-STRING(mReseivData,1).

    RetData = RetData + cReceivData.

    if R-INDEX(RetData,";") > 1 then
    do:
      /* Получен сигнал окончания передачи*/
       vStatus = 2.
       LEAVE.
    end.

  end.

END PROCEDURE.

/*------------------------------------------------------------------------------*/
PROCEDURE SendData:
 def input param id as int.
 def input param tell as char.
 def input param mess as char.
 def var MessSize as int.
 def var Data as char.

 Data = String(id) + dlm + mess + dlm + tell + '\n'.

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
    /*message "Ошибка при передаче данных!" view-as alert-box.*/
    vStatus = 3.
    LEAVE.
    RETURN.
   END.
   else do:

     find  b-smspool where b-smspool.id = id exclusive-lock no-error.
     if avail b-smspool then
     do:
      b-smspool.state = 1.
      release b-smspool.
     end.

   end.
 end.
END PROCEDURE.
/*------------------------------------------------------------------------------*/

PROCEDURE UpdateStatus:
    def var StVal as char.
    def var i as int.
    def var p as int.
    def var idmess as int.
    def var stmess as int.

    i = R-INDEX(RetData,";").
    RetData = SUBSTRING(RetData , 1 , i - 4 ).

    do i = 1 to num-entries(RetData, ","):
      StVal = entry(i, RetData, ",").
      if length(StVal) >= 3 then
      do:
        p = R-INDEX(StVal,dlm).
        if p > 1 then
        do:
          idmess = INTEGER( SUBSTRING(StVal,1, p - 1 ) ).
          stmess = INTEGER( SUBSTRING(StVal,p + 1 ,LENGTH(StVal)) ).
          find last b-smspool where b-smspool.id = idmess exclusive-lock no-error.
          if avail b-smspool then
          do:
            b-smspool.state = stmess.
            release b-smspool.
          end.
        end.
      end.
    end.

END PROCEDURE.
/*------------------------------------------------------------------------------*/