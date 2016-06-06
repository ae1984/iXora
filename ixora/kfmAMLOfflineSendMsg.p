/* kfmAMLOfflineSendMsg.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Отправка сообщения с данными AMLOffline по одной операции
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
*/

def input parameter p-bank as char no-undo.
def input parameter p-bankOperationID as char no-undo.      /* jou000073a */
def input parameter p-issueDBID as char no-undo.            /* 1 */
def input parameter p-currencyCode as char no-undo.         /* KZT */
def input parameter p-accountDebit as char no-undo.         /* Счет Дт */
def input parameter p-accountCredit as char no-undo.        /* Счет Кт */
def input parameter p-operationDateTime as char no-undo.    /* Дата и время в формате "01.01.2010 21:01:03" */
def input parameter p-bsAccountDebit as char no-undo.       /* Бал. счет Дт */
def input parameter p-bsAccountCredit as char no-undo.      /* Бал. счет Кт */
def input parameter p-baseAmount as char no-undo.           /* Сумма KZT */
def input parameter p-currencyAmount as char no-undo.       /* Сумма в валюте */
def input parameter p-operationEKNP as char no-undo.        /* ЕКНП */
def input parameter p-debitName as char no-undo.            /* Наим. клиента Дт */
def input parameter p-creditName as char no-undo.           /* Наим. клиента Кт */
def input parameter p-debitRegOpenDate as char no-undo.     /* Дата регистрации ЮЛ Дт */
def input parameter p-creditRegOpenDate as char no-undo.    /* Дата регистрации ЮЛ Кт */
def input parameter p-anonymousBool as char no-undo.        /* Анонимность участника - 0 или 1 */
def input parameter p-debitCountryCode as char no-undo.     /* Код страны Дт, KAZ */
def input parameter p-creditCountryCode as char no-undo.    /* Код страны Кт, KAZ */
def input parameter p-debitClientId as char no-undo.        /* id клиента Дт */
def input parameter p-creditClientId as char no-undo.       /* id клиента Кт */
def input parameter p-docCategory as char no-undo.          /* категория документа */
def input parameter p-docType as char no-undo.              /* тип документа */
def input parameter p-operationReason as char no-undo.      /* основание платежа */
def input parameter p-dClientType as char no-undo.          /* тип клиента Дт (1 ЮЛ, 2 ФЛ, 3 ИП) */
def input parameter p-cClientType as char no-undo.          /* тип клиента Кт (1 ЮЛ, 2 ФЛ, 3 ИП) */
def input parameter p-blagotvor as char no-undo.            /* благотворительная организация */

def var q_name as char no-undo.
q_name = "AMLOfflineQ".

def var ptpsession as handle.
def var messageh as handle.

run jms/ptpsession.p persistent set ptpsession ("-h 10.0.0.52 -s 5162 ").
run setbrokerurl in ptpsession ("10.0.0.52:2507").

run setUser in ptpsession ("Administrator").
run setPassword in ptpsession ("Administrator").
run beginsession in ptpsession.

/* create a message */
run createtextmessage in ptpsession (output messageh).

/* build request string */
run settext in messageh (p-bankOperationID).

/* add parameters */
run setStringProperty in messageh("bank", p-bank).
run setStringProperty in messageh("bankOperationID", p-bankOperationID).
run setStringProperty in messageh("issueDBID", p-issueDBID).
run setStringProperty in messageh("currencyCode", p-currencyCode).
run setStringProperty in messageh("accountDebit", p-accountDebit).
run setStringProperty in messageh("accountCredit", p-accountCredit).
run setStringProperty in messageh("operationDateTime", p-operationDateTime).
run setStringProperty in messageh("bsAccountDebit", p-bsAccountDebit).
run setStringProperty in messageh("bsAccountCredit", p-bsAccountCredit).
run setStringProperty in messageh("baseAmount", p-baseAmount).
run setStringProperty in messageh("currencyAmount", p-currencyAmount).
run setStringProperty in messageh("operationEKNP", p-operationEKNP).
run setStringProperty in messageh("debitName", p-debitName).
run setStringProperty in messageh("creditName", p-creditName).
run setStringProperty in messageh("debitRegOpenDate", p-debitRegOpenDate).
run setStringProperty in messageh("creditRegOpenDate", p-creditRegOpenDate).
run setStringProperty in messageh("anonymousBool", p-anonymousBool).
run setStringProperty in messageh("debitCountryCode", p-debitCountryCode).
run setStringProperty in messageh("creditCountryCode", p-creditCountryCode).
run setStringProperty in messageh("debitClientId", p-debitClientId).
run setStringProperty in messageh("creditClientId", p-creditClientId).
run setStringProperty in messageh("docCategory", p-docCategory).
run setStringProperty in messageh("docType", p-docType).
run setStringProperty in messageh("operationReason", p-operationReason).
run setStringProperty in messageh("dClientType", p-dClientType).
run setStringProperty in messageh("cClientType", p-cClientType).
run setStringProperty in messageh("goodWill", p-blagotvor).

/* send a message to a queue */
run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).

run deletemessage in messageh.
run deletesession in ptpsession.
