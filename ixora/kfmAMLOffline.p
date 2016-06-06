/* kfmAMLOffline.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Данные по AMLOffline
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
        22/07/2010 galina - добавила поля regwho и regbank
        26/08/2010 madiyar - добавил поля debitBank и creditBank
*/

def shared var g-ofc as char.

def input parameter p-bank as char no-undo.
def input parameter p-bankOperationID as char no-undo.      /* jou000073a */
def input parameter p-issueDBID as integer no-undo.         /* 1 */
def input parameter p-dClientIxoraType as char no-undo.     /* тип клиента Дт в Иксоре (cif, cifm, bank) */
def input parameter p-cClientIxoraType as char no-undo.     /* тип клиента Кт в Иксоре (cif, cifm, bank) */
def input parameter p-debitClientId as char no-undo.        /* id клиента Дт */
def input parameter p-creditClientId as char no-undo.       /* id клиента Кт */
def input parameter p-bnName as char no-undo.               /* Имя бенефициара */
def input parameter p-docCategory as char no-undo.          /* Категория документа */
def input parameter p-docType as char no-undo.              /* Тип документа */
def input parameter p-regwho as char no-undo.               /* логин исполнителя */
def input parameter p-regbank as char no-undo.              /* код филиала */
def input parameter p-debitBank as char no-undo.            /* банк клиента по дебету */
def input parameter p-creditBank as char no-undo.           /* банк клиента по кредиту */

create amloffline.
assign amloffline.bank = p-bank
       amloffline.operCode = p-bankOperationID
       amloffline.issueDBID = p-issueDBID
       amloffline.dClientIxoraType = p-dClientIxoraType
       amloffline.cClientIxoraType = p-cClientIxoraType
       amloffline.debitClientId = caps(p-debitClientId)
       amloffline.creditClientId = caps(p-creditClientId)
       amloffline.bnName = p-bnName
       amloffline.docCategory = p-docCategory
       amloffline.docType = p-docType
       amloffline.who = g-ofc
       amloffline.rdt = today
       amloffline.rtim = time
       amloffline.sts = 'new'
       amloffline.regwho = p-regwho
       amloffline.regbank = p-regbank
       amloffline.debitBank = p-debitBank
       amloffline.creditBank = p-creditBank.


