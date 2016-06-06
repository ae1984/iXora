/* CLGetSumListener.p
 * MODULE
        Кредитный лимит - cкоринг
				Кредитный лимит - этап главбуха
 * DESCRIPTION
        Получение суммы платежа в текущем месяце для бизнес-процессов установление/изменение кредитного лимита
				Получение количество просрочек и дней просрочек
				Получение данных о блокировке ПТП, картотеки
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.1.1
 * AUTHOR
        18/03/2013 anuar
 * BASES
        BANK COMM
 * CHANGES
				27.08.2013 anuar - ТЗ 2046 - отправка данных ИИН, номера договора и одобренной суммы из заявки в таблицу pc_lncontr
				12.09.2013 anuar - ТЗ 2060 - отправка номера счета, даты установления лимита в OW, даты начала КД, даты окончания КД, ГЭСВ по КД из заявки в таблицу pc_lncontr
				17.10.2013 anuar - определяем филиал не по коду филиала, переданного из заявки, а по двум последним цифрам счета

*/


{global.i}
{srvcheck.i}
define new shared variable vIsIinExist      as logical		no-undo.
define new shared variable vIin             as character	no-undo. /* Иин сотрудника*/
define new shared variable vSum	            as character	no-undo. /* Сумма платежа в текущем месяце */ 
define new shared variable vDays						as character	no-undo. /* Количество дней просрочек */
define new shared variable vCounts					as character	no-undo. /* Количество просрочек */ 
define new shared variable vBlock						as character	no-undo. /* Блокировка ПТП, картотека */ 
define new shared variable vBranch          as character	no-undo. /* Филиал вида TXB## */

define new shared variable vProcNum         as character	no-undo. /* Номер процесса, он же номер договора */
define new shared variable vLim			        as character	no-undo. /* Сумма кредитного лимита */

define new shared variable vAcc   					as character	no-undo. /* Номер счета */
define new shared variable vOwLimdt					as date				no-undo. /* Дата установления лимита в OW по КД */
define new shared variable vStdate					as date				no-undo. /* Дата начала кредитного договора */
define new shared variable vEdate 					as date				no-undo. /* Дата окончания кредитного договора */
define new shared variable vEff_  					as character	no-undo. /* ГЭСВ по кредитному договору, % */

define new shared variable vErrorsProgress  as character	no-undo.
vErrorsProgress = "".

define new shared variable g-today2					as date				no-undo.
g-today2 = g-today.

define variable v-terminate									as logical		no-undo.
v-terminate = no.

define variable ptpsession   as handle.
define variable consumerH    as handle.
define variable replyMessage as handle.


/******************************************************************/
/*run jms/jmssession.p persistent set ptpsession ("-SMQConnect").*/
RUN jms/ptpsession.p PERSISTENT SET ptpsession ("").
if isProductionServer() then do:
    run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
end.
else do:
    run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").
end.
/******************************************************************/
run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").


run beginSession in ptpsession.
run createTextMessage in ptpsession (output replyMessage).
run createMessageConsumer in ptpsession (
    this-procedure,
    "requestHandler",
    output consumerH).
run receiveFromQueue in ptpsession ("cl_getsum_queue",
    ?,
    consumerH).
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait", this-procedure, ?).

procedure requestHandler:
    define input parameter	requestH						as handle.
    define input parameter	msgConsumerH				as handle.
    define output parameter replyH							as handle.
    define variable					replyText						as character.
    define variable					msgText						  as character.
    define variable					vpNames							as character no-undo.
    define variable					vMessageGUID				as character no-undo.


    msgText = DYNAMIC-FUNCTION('getText':U in requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then
    do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then
            v-terminate = yes.
    end.
    else
    do:

        vpNames = DYNAMIC-FUNCTION('getPropertyNames':U in requestH).

        if lookup("MessageGUID", vpNames) > 0 then
            vMessageGUID = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "MessageGUID").
				if lookup("Iin", vpNames) > 0 then
						vIin = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Iin").
        if lookup("Sum", vpNames) > 0 then
            vSum = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Sum").
				if lookup("Days", vpNames) > 0 then
						vDays = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Days").
				if lookup("Counts", vpNames) > 0 then
						vCounts = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Counts").
				if lookup("Block", vpNames) > 0 then
						vBlock = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Block").
				if lookup("Branch", vpNames) > 0 then
						vBranch = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Branch").
				if lookup("ProcNum", vpNames) > 0 then
						vProcNum = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "ProcNum").
				if lookup("Lim", vpNames) > 0 then
						vLim = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Lim").

				if lookup("Acc", vpNames) > 0 then
						vAcc = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Acc").
				if lookup("OwLimdt", vpNames) > 0 then
						vOwLimdt = date(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "OwLimdt")).
				if lookup("Stdate", vpNames) > 0 then
						vStdate = date(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Stdate")).
				if lookup("Edate", vpNames) > 0 then
						vEdate = date(DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Edate")).
				if lookup("Eff_", vpNames) > 0 then
						vEff_ = DYNAMIC-FUNCTION('getCharProperty':U in requestH, "Eff_").
	
	if vAcc <> "" then
	  vBranch = "TXB" + substr(vAcc,19,2).


        if connected ("txb") then  disconnect "txb".
        find first comm.txb where comm.txb.bank = vBranch and comm.txb.consolid no-lock no-error.
        if available comm.txb then
        do:
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            /*connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -UU " + comm.txb.login + " -P " + comm.txb.login) no-error.*/
            if error-status:error then
                run WriteError.
            if connected ("txb") then
            do:
                run cl_getsum_proc.p.
                disconnect "txb".
            end.
            else
                vErrorsProgress = vErrorsProgress + "Ошибка подключения к филиалу,".
        end.
        else
        do:
            vErrorsProgress = vErrorsProgress + "Филиал: " + vBranch + " не найден в списке,".
        end.

        run setBooleanProperty in replyMessage ("IsIinExist", vIsIinExist).
        run setStringProperty in replyMessage ("Sum", vSum).
				run setStringProperty in replyMessage ("Days", vDays).
				run setStringProperty in replyMessage ("Counts", vCounts).
				run setStringProperty in replyMessage ("Block", vBlock).

        if vErrorsProgress <> "" then
            run setStringProperty in replyMessage ("ErrorsProgress", SUBSTRING (vErrorsProgress, 1, LENGTH (vErrorsProgress) - 1)).
        else
            run setStringProperty in replyMessage ("ErrorsProgress", vErrorsProgress).

        run setStringProperty in replyMessage ("MessageGUID", vMessageGUID).

        vIsIinExist = false.
        vIin = "".
        vSum = "".
				vDays = "".
				vCounts = "".
				vBlock = "".
				vBranch = "".
				vProcNum = "".
				vLim = "".
				vAcc = "".
				vOwLimdt = g-today2.
				vStdate = g-today2.
				vEdate = g-today2.
				vEff_ = "".

        vErrorsProgress = "".


        run deleteMessage in requestH.
        replyH = replyMessage.
        run setText in replyH (replyText).

    end.
end.

function inWait returns logical.
    return not(v-terminate).
end.


procedure WriteError:
    define variable i as integer no-undo.
    if error-status:error then
    do i = 1 to error-status:num-messages:
        vErrorsProgress = vErrorsProgress + string(error-status:get-message(i)) + ",".
    end.
end procedure.

