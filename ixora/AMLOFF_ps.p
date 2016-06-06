/* AMLOFF_ps.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Отправка данных по AMLOffline
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
        29/06/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        07/07/2010 madiyar - теперь соединение с соником устанавливается один раз до начала отправки пачки
        12/07/2010 madiyar - в передаваемых суммах десятичный разделитель - запятая
        22/07/2010 galina - перекомпиляция
        27/07/2010 madiyar - не выводим мини-карточки с РНН=1 и 111111111111
        26/08/2010 madiyar - добавил в конце v-operationReason код филиала и логин пользователя
        31/08/2010 galina - убрала отладочное сообщение
        01/09/2010 madiyar - добавил debitBank, creditBank
        21/10/2010 madiyar - мелкое исправление
        19/11/2010 madiyar - выгрузка удаленных операций
        03/03/2011 madiyar - мелкие правки, снял ограничение на 300 символов в комментарии
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

{srvcheck.i}
{nbankBik.i}
if not isProductionServer() then return.

def var v-bank as char no-undo.
def var v-bankOperationID as char no-undo.      /* jou000073a */
def var v-issueDBID as char no-undo.            /* 1 */
def var v-currencyCode as char no-undo.         /* KZT */
def var v-accountDebit as char no-undo.         /* Счет Дт */
def var v-accountCredit as char no-undo.        /* Счет Кт */
def var v-operationDateTime as char no-undo.    /* Дата и время в формате "01.01.2010 21:01:03" */
def var v-bsAccountDebit as char no-undo.       /* Бал. счет Дт */
def var v-bsAccountCredit as char no-undo.      /* Бал. счет Кт */
def var v-baseAmount as deci no-undo.           /* Сумма KZT */
def var v-currencyAmount as deci no-undo.       /* Сумма в валюте */
def var v-operationEKNP as char no-undo.        /* ЕКНП */
def var v-debitName as char no-undo.            /* Наим. клиента Дт */
def var v-creditName as char no-undo.           /* Наим. клиента Кт */
def var v-debitRegOpenDate as char no-undo.     /* Дата регистрации ЮЛ Дт */
def var v-creditRegOpenDate as char no-undo.    /* Дата регистрации ЮЛ Кт */
def var v-anonymousBool as char no-undo.        /* Анонимность участника - 0 или 1 */
def var v-debitCountryCode as char no-undo.     /* Код страны Дт, KAZ */
def var v-creditCountryCode as char no-undo.    /* Код страны Кт, KAZ */
def var v-debitClientId as char no-undo.        /* id клиента Дт */
def var v-creditClientId as char no-undo.       /* id клиента Кт */
def var v-docCategory as char no-undo.          /* категория документа */
def var v-docType as char no-undo.              /* тип документа */
def var v-operationReason as char no-undo.      /* основание платежа */
def var v-dClientType as char no-undo.          /* тип клиента Дт (1 ЮЛ, 2 ФЛ, 3 ИП) */
def var v-cClientType as char no-undo.          /* тип клиента Кт (1 ЮЛ, 2 ФЛ, 3 ИП) */
def var v-blagotvor as char no-undo.

def var v-debitBank as char no-undo.
def var v-creditBank as char no-undo.

def var v-bankwho as char no-undo.

def var v-extdc as char no-undo.
def var v-extname as char no-undo.
def var v-extcountry as char no-undo.

def var i as integer no-undo.
def var v-out as integer no-undo.

function stripXMLTags returns char (input str as char).
    def var res as char no-undo.
    def var ii as integer no-undo.
    do ii = 1 to length(str):
        if asc(substring(str,ii,1)) <> 22 then res = res + substring(str,ii,1).
    end.
    res = replace(res,'<','').
    res = replace(res,'>','').
    res = replace(res,'&','').
    res = replace(res,'№','N').
    res = replace(res,'«','"').
    res = replace(res,'»','"').
    return res.
end function.

def buffer b-amloffline for amloffline.
def var v-country2 as char no-undo.
def var v-txb as char no-undo.
def var fs as char no-undo init "A,B,C,D,E,F,H,K,L,M,N,O,P,Q,R,S,T".
def var fsb as char no-undo init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16|TXB00".
def var fsbname as char no-undo.
fsbname = v-nbankru + ",".
fsbname = fsbname + "Филиал " + v-nbankru + " по Актюбинской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Костанайской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Жамбылской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Западно-Казахстанской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Карагандинской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " в г. Семей,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Акмолинской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " в г. Астана,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Павлодарской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Северо-Казахстанской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Атырауской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Мангистауской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " в г. Жезказган,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Восточно-Казахстанской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " по Южно-Казахстанской области,".
fsbname = fsbname + "Филиал " + v-nbankru + " в г. Алматы".
def var fsbrdt as char no-undo.
fsbrdt = "02.07.2007 00:00:00,".
fsbrdt = fsbrdt + "17.03.2008 00:00:00,".
fsbrdt = fsbrdt + "21.04.2008 00:00:00,".
fsbrdt = fsbrdt + "06.03.2008 00:00:00,".
fsbrdt = fsbrdt + "08.02.2008 00:00:00,".
fsbrdt = fsbrdt + "11.03.2008 00:00:00,".
fsbrdt = fsbrdt + "15.08.2008 00:00:00,".
fsbrdt = fsbrdt + "03.03.2008 00:00:00,".
fsbrdt = fsbrdt + "04.03.2008 00:00:00,".
fsbrdt = fsbrdt + "03.03.2008 00:00:00,".
fsbrdt = fsbrdt + "31.01.2008 00:00:00,".
fsbrdt = fsbrdt + "28.03.2008 00:00:00,".
fsbrdt = fsbrdt + "04.04.2008 00:00:00,".
fsbrdt = fsbrdt + "26.03.2008 00:00:00,".
fsbrdt = fsbrdt + "26.03.2008 00:00:00,".
fsbrdt = fsbrdt + "27.03.2008 00:00:00,".
fsbrdt = fsbrdt + "28.01.2008 00:00:00".

def var v-path as char no-undo.
v-path = '/data/b'.

def var cif2 as char no-undo.

def var nmess as integer no-undo.
nmess = 0.

def var q_name as char no-undo.
q_name = "AMLOfflineQ".

def var ptpsession as handle.
def var messageh as handle.


/*
for each amloffline where amloffline.sts = "sent" no-lock:
    if (amloffline.sdt < today) or (amloffline.sdt = today and ((time - amloffline.stim) > 1200)) then do transaction:
        find first b-amloffline where rowid(b-amloffline) = rowid(amloffline) exclusive-lock.
        b-amloffline.sts = "new".
        find current b-amloffline no-lock.
    end.
end.
*/

find first amloffline where (amloffline.sts = "new") or (amloffline.sts = "predel") no-lock no-error.
if avail amloffline then do:
    run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
    run setbrokerurl in ptpsession ("172.16.1.22:2507").

    run setUser in ptpsession ("SonicClient").
    run setPassword in ptpsession ("SonicClient").

    run beginsession in ptpsession no-error.
    if error-status:error then v-out = 1.

    if v-out = 0 then do:
        run createtextmessage in ptpsession (output messageh) no-error.
        if error-status:error then v-out = 2.
    end.
end.
else return.

if v-out > 0 then do:
    run deletesession in ptpsession no-error.
    run savelog('aml','AMLOFF_ps-> err=' + string(v-out)).
    hide message no-pause.
    message 'AMLOFF_ps-> err=' + string(v-out).
    return.
end.

for each amloffline where amloffline.sts = "predel" no-lock:
    v-bank = amloffline.bank.
    v-bankOperationID = amloffline.operCode.
    v-issueDBID = string(amloffline.issueDBID).

    if v-out = 0 then do:
        run settext in messageh (v-bankOperationID + ' ' + v-issueDBID) no-error.
        if error-status:error then v-out = 3.
    end.

    /* add parameters */
    if v-out = 0 then do:
        run setStringProperty in messageh("bank", v-bank) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("bankOperationID", v-bankOperationID) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("issueDBID", v-issueDBID) no-error.
        if error-status:error then v-out = 4.
    end.

    /* send a message to a queue */
    if v-out = 0 then do:
        do transaction:
            find first b-amloffline where rowid(b-amloffline) = rowid(amloffline) exclusive-lock.
            b-amloffline.sdt = today.
            b-amloffline.stim = time.
            b-amloffline.sts = "sent".
            find current b-amloffline no-lock.
        end.
        run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?) no-error.
        if error-status:error then do:
            do transaction:
                find first b-amloffline where rowid(b-amloffline) = rowid(amloffline) exclusive-lock.
                b-amloffline.sdt = ?.
                b-amloffline.stim = ?.
                b-amloffline.sts = "predel".
                find current b-amloffline no-lock.
            end.
            v-out = 5.
        end.
    end.

    if v-out <> 0 then do:
        run savelog('aml','AMLOFF_ps-> err=' + string(v-out) + ' ' + v-bank + ' ' + v-bankOperationID + ' issueDBID=' + v-issueDBID).
        hide message no-pause.
        message 'AMLOFF_ps-> err=' + string(v-out) + ' ' + v-bank + ' ' + v-bankOperationID + ' issueDBID=' + v-issueDBID.
        leave.
    end.
end.

for each amloffline where amloffline.sts = "new" no-lock:
    v-bank = amloffline.bank.
    v-bankOperationID = amloffline.operCode.
    v-issueDBID = string(amloffline.issueDBID).
    v-anonymousBool = '0'.
    v-debitClientId = amloffline.debitClientId.
    v-creditClientId = amloffline.creditClientId.
    v-docCategory = amloffline.docCategory.
    v-docType = amloffline.docType.
    v-bankwho = trim(trim(amloffline.regbank) + " " + trim(amloffline.regwho)).
    v-debitBank = amloffline.debitBank.
    v-creditBank = amloffline.creditBank.

    assign v-currencyCode = ''
           v-accountDebit = ''
           v-accountCredit = ''
           v-operationDateTime = ''
           v-bsAccountDebit = ''
           v-bsAccountCredit = ''
           v-baseAmount = 0
           v-currencyAmount = 0
           v-operationEKNP = ''
           v-debitName = ''
           v-creditName = ''
           v-debitRegOpenDate = ''
           v-creditRegOpenDate = ''
           v-debitCountryCode = ''
           v-creditCountryCode = ''
           v-operationReason = ''
           v-dClientType = ''
           v-cClientType = ''.

    find first comm.txb where comm.txb.bank = amloffline.bank and comm.txb.consolid no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run AMLfindoper(v-bankOperationID,
                        output v-currencyCode,
                        output v-accountDebit,
                        output v-accountCredit,
                        output v-bsAccountDebit,
                        output v-bsAccountCredit,
                        output v-operationDateTime,
                        output v-baseAmount,
                        output v-currencyAmount,
                        output v-operationEKNP,
                        output v-operationReason,
                        output v-blagotvor,
                        output v-extcountry
                        ).
         if amloffline.bnName <> '' then do:
            if amloffline.debitClientId = '' then assign v-debitName = amloffline.bnName v-debitCountryCode = v-extcountry.
            else
            if amloffline.creditClientId = '' then assign v-creditName = amloffline.bnName v-creditCountryCode = v-extcountry.
         end.
    end.

    case amloffline.dClientIxoraType:
        when "bank" then do:
            find first comm.txb where comm.txb.bank = v-debitClientId and comm.txb.consolid no-lock no-error.
            if avail comm.txb then do:
                /*
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                run AMLfindbank(output v-debitName, output v-debitRegOpenDate).
                */
                v-debitName = entry(lookup(v-debitClientId,fsb),fsbname) no-error.
                v-debitRegOpenDate = entry(lookup(v-debitClientId,fsb),fsbrdt) no-error.
                v-debitCountryCode = "398".
                v-dClientType = "1".
            end.
        end.
        when "cifm" then do:
            find first cifmin where cifmin.cifmin = v-debitClientId no-lock no-error.
            if avail cifmin and cifmin.rnn <> '1' and cifmin.rnn <> '111111111111' then do:
                v-debitName = cifmin.fam + ' ' + cifmin.name + ' ' + cifmin.mname.
                if num-entries(cifmin.addr) = 7 then do:
                    v-country2 = entry(1,cifmin.addr).
                    if num-entries(v-country2,'(') = 2 then v-debitCountryCode = substr(entry(2,entry(1,cifmin.addr),'('),1,2).
                end.
                find first code-st where code-st.code = v-debitCountryCode no-lock no-error.
                if avail code-st then v-debitCountryCode = code-st.cod-ch.
                /*
                1 Юридическое лицо
                2 Физическое лицо
                3 Индивидуальный предприниматель
                4 Внешний клиент (НОВОЕ ЗНАЧЕНИЕ СПРАВОЧНИКА)
                */
                v-dClientType = '4'.
            end.
        end.
        when "cif" then do:
            v-txb = entry(lookup(substring(v-debitClientId,1,1),fs),fsb) no-error.
            if (v-txb <> '') and (v-txb <> ?) then do:
                cif2 = ''.
                do i = 1 to num-entries(v-txb,"|"):
                    find first comm.txb where comm.txb.bank = entry(i,v-txb,"|") and comm.txb.consolid no-lock no-error.
                    if avail comm.txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                        run AMLfindcln(entry(1,v-debitClientId),output cif2, output v-debitName, output v-debitCountryCode, output v-debitRegOpenDate, output v-dClientType).
                        if connected ("txb") then disconnect "txb".
                    end.
                    if cif2 <> '' then leave.
                end.
            end.
        end.
    end.

    case amloffline.cClientIxoraType:
        when "bank" then do:
            find first comm.txb where comm.txb.bank = v-creditClientId and comm.txb.consolid no-lock no-error.
            if avail comm.txb then do:
                v-creditName = entry(lookup(v-creditClientId,fsb),fsbname) no-error.
                v-creditRegOpenDate = entry(lookup(v-creditClientId,fsb),fsbrdt) no-error.
                v-creditCountryCode = "398".
                v-cClientType = "1".
            end.
        end.
        when "cifm" then do:
            find first cifmin where cifmin.cifmin = v-creditClientId no-lock no-error.
            if avail cifmin and cifmin.rnn <> '1' and cifmin.rnn <> '111111111111' then do:
                v-creditName = cifmin.fam + ' ' + cifmin.name + ' ' + cifmin.mname.
                if num-entries(cifmin.addr) = 7 then do:
                    v-country2 = entry(1,cifmin.addr).
                    if num-entries(v-country2,'(') = 2 then v-creditCountryCode = substr(entry(2,entry(1,cifmin.addr),'('),1,2).
                end.
                find first code-st where code-st.code = v-creditCountryCode no-lock no-error.
                if avail code-st then v-creditCountryCode = code-st.cod-ch.
                /*
                1 Юридическое лицо
                2 Физическое лицо
                3 Индивидуальный предприниматель
                4 Внешний клиент (НОВОЕ ЗНАЧЕНИЕ СПРАВОЧНИКА)
                */
                v-cClientType = '4'.
            end.
        end.
        when "cif" then do:
            v-txb = entry(lookup(substring(v-creditClientId,1,1),fs),fsb) no-error.
            if (v-txb <> '') and (v-txb <> ?) then do:
                cif2 = ''.
                do i = 1 to num-entries(v-txb,"|"):
                    find first comm.txb where comm.txb.bank = entry(i,v-txb,"|") and comm.txb.consolid no-lock no-error.
                    if avail comm.txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                        run AMLfindcln(entry(1,v-creditClientId),output cif2,output v-creditName, output v-creditCountryCode, output v-creditRegOpenDate, output v-cClientType).
                        if connected ("txb") then disconnect "txb".
                    end.
                    if cif2 <> '' then leave.
                end.
            end.
        end.
    end.

    if v-debitName <> '' then v-debitName = stripXMLTags(v-debitName).
    if v-creditName <> '' then v-creditName = stripXMLTags(v-creditName).
    if v-operationReason <> '' then v-operationReason = stripXMLTags(v-operationReason).

    /*
    if length(v-operationReason) > 300 - (length(v-bankwho) + 1) then v-operationReason = substring(v-operationReason,1,300 - (length(v-bankwho) + 1)).
    */
    v-operationReason = v-operationReason + ' ' + v-bankwho.

    /*
    run kfmAMLOfflineSendMsg (rowid(amloffline),
                              v-bank,
                              v-bankOperationID,
                              v-issueDBID,
                              v-currencyCode,
                              v-accountDebit,
                              v-accountCredit,
                              v-operationDateTime,
                              v-bsAccountDebit,
                              v-bsAccountCredit,
                              replace(trim(string(v-baseAmount,">>>>>>>>>>>9.99")),'.',','),
                              replace(trim(string(v-currencyAmount,">>>>>>>>>>>9.99")),'.',','),
                              v-operationEKNP,
                              v-debitName,
                              v-creditName,
                              v-debitRegOpenDate,
                              v-creditRegOpenDate,
                              v-anonymousBool,
                              v-debitCountryCode,
                              v-creditCountryCode,
                              v-debitClientId,
                              v-creditClientId,
                              v-docCategory,
                              v-docType,
                              v-operationReason,
                              v-dClientType,
                              v-cClientType,
                              v-blagotvor,
                              output v-out
                              ).
    */

    if v-out = 0 then do:
        run settext in messageh (v-bankOperationID + ' ' + v-issueDBID) no-error.
        if error-status:error then v-out = 3.
    end.

    /* add parameters */
    if v-out = 0 then do:
        run setStringProperty in messageh("bank", v-bank) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("bankOperationID", v-bankOperationID) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("issueDBID", v-issueDBID) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("currencyCode", v-currencyCode) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("accountDebit", v-accountDebit) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("accountCredit", v-accountCredit) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("operationDateTime", v-operationDateTime) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("bsAccountDebit", v-bsAccountDebit) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("bsAccountCredit", v-bsAccountCredit) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("baseAmount", replace(trim(string(v-baseAmount,">>>>>>>>>>>9.99")),'.',',')) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("currencyAmount", replace(trim(string(v-currencyAmount,">>>>>>>>>>>9.99")),'.',',')) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("operationEKNP", v-operationEKNP) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("debitName", v-debitName) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("creditName", v-creditName) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("debitRegOpenDate", v-debitRegOpenDate) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("creditRegOpenDate", v-creditRegOpenDate) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("anonymousBool", v-anonymousBool) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("debitCountryCode", v-debitCountryCode) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("creditCountryCode", v-creditCountryCode) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("debitClientId", v-debitClientId) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("creditClientId", v-creditClientId) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("docCategory", v-docCategory) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("docType", v-docType) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("operationReason", v-operationReason) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("dClientType", v-dClientType) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("cClientType", v-cClientType) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("goodWill", v-blagotvor) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("debitBank", v-debitBank) no-error.
        if error-status:error then v-out = 4.
    end.
    if v-out = 0 then do:
        run setStringProperty in messageh("creditBank", v-creditBank) no-error.
        if error-status:error then v-out = 4.
    end.

    /*
    output to snd.txt append.
    put unformatted "----------------" skip.
    put unformatted "bank=" + v-bank skip
    "bankOperationID=" + v-bankOperationID skip
    "issueDBID=" + v-issueDBID skip
    "currencyCode=" + v-currencyCode skip
    "accountDebit=" + v-accountDebit skip
    "accountCredit=" + v-accountCredit skip
    "operationDateTime=" + v-operationDateTime skip
    "bsAccountDebit=" + v-bsAccountDebit skip
    "bsAccountCredit=" + v-bsAccountCredit skip
    "baseAmount=" + replace(trim(string(v-baseAmount,">>>>>>>>>>>9.99")),'.',',') skip
    "currencyAmount=" + replace(trim(string(v-currencyAmount,">>>>>>>>>>>9.99")),'.',',') skip
    "operationEKNP=" + v-operationEKNP skip
    "debitName=" + v-debitName skip
    "creditName=" + v-creditName skip
    "debitRegOpenDate=" + v-debitRegOpenDate skip
    "creditRegOpenDate=" + v-creditRegOpenDate skip
    "anonymousBool=" + v-anonymousBool skip
    "debitCountryCode=" + v-debitCountryCode skip
    "creditCountryCode=" + v-creditCountryCode skip
    "debitClientId=" + v-debitClientId skip
    "creditClientId=" + v-creditClientId skip
    "docCategory=" + v-docCategory skip
    "docType=" + v-docType skip
    "operationReason=" + v-operationReason skip
    "dClientType=" + v-dClientType skip
    "cClientType=" + v-cClientType skip
    "goodWill=" + v-blagotvor skip.
    output close.
    */

    /* send a message to a queue */
    if v-out = 0 then do:
        do transaction:
            find first b-amloffline where rowid(b-amloffline) = rowid(amloffline) exclusive-lock.
            b-amloffline.sdt = today.
            b-amloffline.stim = time.
            b-amloffline.sts = "sent".
            find current b-amloffline no-lock.
        end.
        run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?) no-error.
        if error-status:error then do:
            do transaction:
                find first b-amloffline where rowid(b-amloffline) = rowid(amloffline) exclusive-lock.
                b-amloffline.sdt = ?.
                b-amloffline.stim = ?.
                b-amloffline.sts = "new".
                find current b-amloffline no-lock.
            end.
            v-out = 5.
        end.
    end.

    if v-out <> 0 then do:
        run savelog('aml','AMLOFF_ps-> err=' + string(v-out) + ' ' + v-bank + ' ' + v-bankOperationID).
        hide message no-pause.
        message 'AMLOFF_ps-> err=' + string(v-out) + ' ' + v-bank + ' ' + v-bankOperationID.
        leave.
    end.

   /* nmess = nmess + 1.
    if (nmess mod 50) = 0 then do:
        hide message no-pause.
        message nmess.
    end.*/

    /*
    pause.
    */

end.

run deletemessage in messageh no-error.
run deletesession in ptpsession no-error.


