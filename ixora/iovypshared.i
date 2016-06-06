/* iovypshared.i
 * MODULE
        Название модуля - Процесс Sonic - VIPISKA.
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - iovyp.p,iovyp2.p,iovyp3.p,iovyp4.p,iovyp5.p,iovyp6.p,iovyp22.p,iovyp23.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        02.01.2013 damir - Переход на ИИН/БИН.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Оптимизация кода.
*/
define {1} shared variable d_gtday as date.

def {1} shared temp-table t-payment no-undo
  field num_doc as char             /*NUM_DOC*/
  field date_doc as date            /*DATE_DOC */
  field payer_name as char          /*PAYER_NAME*/
  field payer_rnn as char           /*PAYER_RNN*/
  field payer_account as char       /*PAYER_ACCOUNT */
  field payer_code as char          /*PAYER_CODE */
  field amount as char              /*AMOUNT */
  field value_date as date          /*VALUE_DATE */
  field payer_bank_bic  as char     /*PAYER_BANK_BIC */
  field payer_bank_name as char     /*PAYER_BANK_NAME */
  field rcpnt_name as char          /*RCPT_NAME */
  field rcpnt_rnn as char           /*RCPT_RNN */
  field rcpnt_account as char       /*RCPT_ACCOUNT */
  field rcpnt_code as char          /*RCPT_CODE */
  field rcpnt_bank_name as char     /*RCPT_BANK_NAME*/
  field rcpnt_bank_bic as char      /*RCPT_BANK_BIC*/
  field payments_details as char    /*PAYMENT_DETAILS*/
  field destination_code as char.   /*DESTINATION_CODE*/

def {1} shared temp-table t-doc no-undo
  field oper_code as integer
  field num_doc as char
  field deal_type as char
  field deal_code as char
  field date_doc  as date
  field name as char
  field account as char
  field dam as deci
  field cam as deci
  field bank_bic as char
  field bank_name as char
  field des as char
  field tim as integer
  field crc as char
  field kod as char             /*КОд*/
  field kbe as char             /*KBE*/
  field knp as char
  field rnn as char             /*РНН*/
  field nominale as deci
  index idx is primary oper_code.

def {1} shared temp-table cred no-undo
  field num as inte
  field dt as date
  field sumcred as char
  field sumproc as char
  field plateg as char
  field ostat as char.

def {1} shared temp-table t-accnt no-undo
  field numder as char
  field currency as char
  field available_balance as char
  field total_balance as char
  field freeze as char
  field recent as char.

def {1} shared temp-table t-accnt-depo no-undo
  field numder as char
  field currency as char
  field available_balance as char
  field total_balance as char
  field freeze as char
  field intrate as char
  field accrate as char
  field intpaid as char
  field recent as char
  field aux_acc as char.

def {1} shared temp-table t-ink no-undo
  field aaa as char
  field currency as char
  field datetime as char
  field summa as char
  field vid_operacii as char
  field kbk as char
  field num as char
  field ink_status as char.


