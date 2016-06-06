/* LonAddCRMListener.p
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
*/

{global.i}
{srvcheck.i}
DEF NEW SHARED VAR vCif AS CHAR NO-UNDO.
DEF NEW SHARED VAR vStaffId AS CHAR NO-UNDO.
DEF NEW SHARED VAR vPasePier AS CHAR NO-UNDO.
DEF NEW SHARED VAR vGoal AS CHAR NO-UNDO.
DEF NEW SHARED VAR vLongrp AS INTEGER.
DEF NEW SHARED VAR vGua AS CHAR NO-UNDO.
DEF NEW SHARED VAR vAaa AS CHAR NO-UNDO.
DEF NEW SHARED VAR vLcnt AS CHAR NO-UNDO.
DEF NEW SHARED VAR vDateDog AS DATE NO-UNDO.
DEF NEW SHARED VAR vRdt AS DATE NO-UNDO.
DEF NEW SHARED VAR vDuedt AS DATE NO-UNDO.
DEF NEW SHARED VAR vOpnnamt AS DECIMAL NO-UNDO.
DEF NEW SHARED VAR vPrem AS DECIMAL NO-UNDO.
DEF NEW SHARED VAR vDay AS INTEGER NO-UNDO.
DEF NEW SHARED VAR vPlan AS INTEGER NO-UNDO.
DEF NEW SHARED VAR vCrc AS INTEGER NO-UNDO.
DEF NEW SHARED VAR vPenprem AS DECIMAL NO-UNDO.
DEF NEW SHARED VAR vPenprem7 AS DECIMAL NO-UNDO.
DEF NEW SHARED VAR vLonSec AS CHAR NO-UNDO.
DEF NEW SHARED VAR vIsCifExist AS logical.
DEF NEW SHARED VAR vIsAAAExist AS logical.
DEF NEW SHARED VAR vLon AS CHAR NO-UNDO.
DEF NEW SHARED VAR vAaaList AS CHAR NO-UNDO.
DEF NEW SHARED VAR vAaaLast AS CHAR NO-UNDO.
DEF NEW SHARED VAR vBranch AS CHAR NO-UNDO.
DEF NEW SHARED VAR vLonSecType AS INTEGER NO-UNDO.

DEF NEW SHARED VAR vLndtkk AS DATE NO-UNDO. /*  Дата утверждения КК */
DEF NEW SHARED VAR vLnprod AS CHAR NO-UNDO. /*Продукты из справочника*/


DEF NEW SHARED VAR vErrorsProgress AS CHAR NO-UNDO.
vErrorsProgress = "".

DEF NEW SHARED VAR g-today2 AS date NO-UNDO.
g-today2 = g-today.

DEF VAR v-terminate AS logical no-undo.
v-terminate = no.

DEF VAR ptpsession AS HANDLE.
DEF VAR consumerH AS HANDLE.
DEF VAR replyMessage AS HANDLE.

/******************************************************************/
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
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
RUN receiveFromQueue IN ptpsession ("SQ3",
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
if lookup("PasePier", vpNames) > 0 then
    vPasePier = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "PasePier").
if lookup("Goal", vpNames) > 0 then
    vGoal = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Goal").
if lookup("Longrp", vpNames) > 0 then
    vLongrp = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Longrp").
if lookup("Gua", vpNames) > 0 then
    vGua = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Gua").
if lookup("AAA", vpNames) > 0 then
    vAaa = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "AAA").
if lookup("Lcnt", vpNames) > 0 then
    vLcnt = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Lcnt").
if lookup("DateDog", vpNames) > 0 then
    vDateDog = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "DateDog")).
if lookup("Rdt", vpNames) > 0 then
    vRdt = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Rdt")).
if lookup("Duedt", vpNames) > 0 then
    vDuedt = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Duedt")).
if lookup("Opnnamt", vpNames) > 0 then
     /*vOpnnamt = decimal(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Opnnamt")).*/
     vOpnnamt = DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, "Opnnamt").
     /*message DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, "Opnnamt")view-as alert-box title "".*/
     /*return.*/
if lookup("Prem", vpNames) > 0 then
    vPrem = DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, "Prem").
if lookup("Day", vpNames) > 0 then
    vDay = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Day").
if lookup("Plan", vpNames) > 0 then
    vPlan = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Plan").
if lookup("Crc", vpNames) > 0 then
    vCrc = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Crc").
if lookup("Penprem", vpNames) > 0 then
    vPenprem = DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, "Penprem").
if lookup("Penprem7", vpNames) > 0 then
    vPenprem7 = DYNAMIC-FUNCTION('getDecimalProperty':U IN requestH, "Penprem7").
if lookup("LonSec", vpNames) > 0 then
    vLonSec = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "LonSec").
if lookup("Branch", vpNames) > 0 then
    vBranch = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Branch").
if lookup("LonSecType", vpNames) > 0 then
    vLonSecType = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "LonSecType").

if lookup("Lndtkk", vpNames) > 0 then
    vLndtkk = date(DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Lndtkk")).

if lookup("Lnprod", vpNames) > 0 then
    vLnprod = DYNAMIC-FUNCTION('getCharProperty':U IN requestH, "Lnprod").

/*подключено только к базе петропавл. После теста закоментировать */
/* vBranch = "TXB10". */

if connected ("txb") then
    disconnect "txb".
 find first comm.txb where comm.txb.bank = vBranch and comm.txb.consolid no-lock no-error.
 if avail comm.txb then do:
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
    IF ERROR-STATUS:ERROR THEN
        run WriteError.
    if connected ("txb") then
        do:
            run LonAddCRMProc.
            disconnect "txb".
        end.
    else
        vErrorsProgress = vErrorsProgress + "Ошибка подключения к филиалу,".
end.
else
    do:
        vErrorsProgress = vErrorsProgress + "Филиал: " + vBranch + " не найден в списке,".
    end.

RUN setBooleanProperty IN replyMessage ("IsCIFExist", vIsCifExist).
RUN setBooleanProperty IN replyMessage ("IsAAAExist", vIsAAAExist).
RUN setStringProperty IN replyMessage ("LON", vLon).
RUN setStringProperty IN replyMessage ("AAAList", vAaaList).
RUN setStringProperty IN replyMessage ("AAALast", vAaaLast).
RUN setStringProperty IN replyMessage ("MessageGUID", vMessageGUID).
IF vErrorsProgress <> "" THEN
    RUN setStringProperty IN replyMessage ("ErrorsProgress", SUBSTRING (vErrorsProgress, 1, LENGTH (vErrorsProgress) - 1)).
ELSE
    RUN setStringProperty IN replyMessage ("ErrorsProgress", vErrorsProgress).



vErrorsProgress = "".
vCif = "".
vStaffId = "".
vPasePier = "".
vGoal = "".
vLongrp = 0.
vGua = "".
vAaa = "".
vLcnt = "".
vDateDog = g-today2.
vRdt = g-today2.
vDuedt = g-today2.
vOpnnamt = 0.
vPrem = 0.
vDay = 0.
vPlan = 0.
vCrc = 0.
vPenprem = 0.
vPenprem7 = 0.
vLonSec = "".
vIsCifExist = false.
vIsAAAExist = false.
vLon = "".
vAaaList = "".
vAaaLast = "".
vBranch = "".
vLonSecType = 0.
vLndtkk = g-today2.
vLnprod = "".




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

