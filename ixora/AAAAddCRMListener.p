/* AAAAddCRMListener.p
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
        --/--/2011
 * BASES
        BANK COMM
 * CHANGES
        08.05.2012 k.gitalov перекомпиляция
				26.07.2013 anuar добавил vRelatedStatus
*/


{global.i}
{srvcheck.i}
DEF NEW SHARED VAR vIsCifExist AS logical NO-UNDO.
DEF NEW SHARED VAR vIsAAAExist AS logical NO-UNDO.
DEF NEW SHARED VAR vCif AS CHAR NO-UNDO.
DEF NEW SHARED VAR vCur AS CHAR NO-UNDO.
DEF NEW SHARED VAR vAaa AS CHAR NO-UNDO.
DEF NEW SHARED VAR s-lgr AS CHAR NO-UNDO.
DEF NEW SHARED VAR vStaffId AS CHAR NO-UNDO.
DEF NEW SHARED VAR vAaaList AS CHAR NO-UNDO.
DEF NEW SHARED VAR vRelatedStatus AS CHAR NO-UNDO. /* Anuar 26.07.2013 */
DEF NEW SHARED VAR vBranch AS CHAR NO-UNDO.

DEF NEW SHARED VAR g-today2 AS date NO-UNDO.
g-today2 = g-today.

DEF NEW SHARED VAR g-ofc2 AS CHAR NO-UNDO.
g-ofc2 = g-ofc.

DEF NEW SHARED VAR vErrorsProgress AS CHAR NO-UNDO.
vErrorsProgress = "".

DEF VAR v-terminate AS logical no-undo.
v-terminate = no.

DEF VAR ptpsession AS HANDLE.
DEF VAR consumerH AS HANDLE.
DEF VAR replyMessage AS HANDLE.


/******************************************************************/
/*run jms/jmssession.p persistent set ptpsession ("-SMQConnect").*/
RUN jms/ptpsession.p PERSISTENT SET ptpsession ("").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").
/******************************************************************/
run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").


RUN beginSession IN ptpsession.
RUN createTextMessage IN ptpsession (OUTPUT replyMessage).
RUN createMessageConsumer IN ptpsession (
                              THIS-PROCEDURE,
                             "requestHandler",
                              OUTPUT consumerH).
RUN receiveFromQueue IN ptpsession ("SQ2",
                                     ?,
                                     consumerH).
RUN startReceiveMessages IN ptpsession.
RUN waitForMessages IN ptpsession ("inWait", THIS-PROCEDURE, ?).

PROCEDURE requestHandler:
DEF INPUT PARAMETER requestH AS HANDLE.
DEF INPUT PARAMETER msgConsumerH AS HANDLE.
DEF OUTPUT PARAMETER replyH AS HANDLE.
DEF VAR replyText AS CHAR.
DEF VAR msgText AS CHAR.
DEF VAR vpNames AS CHAR NO-UNDO.
DEF VAR vMessageGUID AS CHAR NO-UNDO.

msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then
    do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then
            v-terminate = yes.
    end.
else
do:

vpNames = DYNAMIC-FUNCTION('getPropertyNames':U IN requestH).

if lookup("MessageGUID", vpNames) > 0 then
    vMessageGUID = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "MessageGUID").

if lookup("Cif", vpNames) > 0 then
    vCif = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Cif").
if lookup("StaffId", vpNames) > 0 then
    vStaffId = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "StaffId").
if lookup("Branch", vpNames) > 0 then
    vBranch = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Branch").
if lookup("Cur", vpNames) > 0 then
    vCur = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Cur").

/*подключено только к базе караганды. После теста закоментировать */
/* vBranch = "TXB05". */


if connected ("txb") then
    disconnect "txb".
 find first comm.txb where comm.txb.bank = vBranch and comm.txb.consolid no-lock no-error.
 if avail comm.txb then do:
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
    IF ERROR-STATUS:ERROR THEN
        run WriteError.
    if connected ("txb") then
        do:
            run AAAAddCRMProc.
            disconnect "txb".
        end.
    else
        vErrorsProgress = vErrorsProgress + "Ошибка подключения к филиалу,".
end.
else
    do:
        vErrorsProgress = vErrorsProgress + "Филиал: " + vBranch + " не найден в списке,".
    end.



RUN setBooleanProperty IN replyMessage ("IsCifExist", vIsCifExist).
RUN setBooleanProperty IN replyMessage ("IsAAAExist", vIsAAAExist).
RUN setStringProperty IN replyMessage ("AAA", vAaa).
RUN setStringProperty IN replyMessage ("AAAList", vAaaList).
RUN setStringProperty IN replyMessage ("RelatedStatus", vRelatedStatus).
IF vErrorsProgress <> "" THEN
    RUN setStringProperty IN replyMessage ("ErrorsProgress", SUBSTRING (vErrorsProgress, 1, LENGTH (vErrorsProgress) - 1)).
ELSE
    RUN setStringProperty IN replyMessage ("ErrorsProgress", vErrorsProgress).
RUN setStringProperty IN replyMessage ("MessageGUID", vMessageGUID).

vErrorsProgress = "".
vCif = "".
vAaa = "".
vCur = "".
vAaaList = "".
vRelatedStatus = "".

RUN deleteMessage IN requestH.
replyH = replyMessage.
RUN setText IN replyH (replyText).

END.
END.

FUNCTION inWait RETURNS LOGICAL.
RETURN not(v-terminate).
END.


procedure WriteError:
DEF VAR i AS INTEGER NO-UNDO.
IF ERROR-STATUS:ERROR THEN
    DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        vErrorsProgress = vErrorsProgress + string(ERROR-STATUS:GET-MESSAGE(i)) + ",".
    END.
end procedure.

