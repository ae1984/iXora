/* cr_send.p
 * MODULE
        Отправка сообщений для программы Кредитный регистр
 * DESCRIPTION
        Отправка сформированного сообщения в sonic
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
 * AUTHOR
        10/06/2010 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        28/04/2011 k.gitalov - возможность работы с тестовой базой
        17/05/2011 id00810 - дополнила условие выгрузки остатка remaining_liability
        18/07/2011 kapar - изменил условие выгрузки остатка remaining_liability
        03/04/2012 k.gitalov - изменил коннект к сонику
*/

{global.i}
{credreg.i}
{srvcheck.i}

def var sMess as char init "Сообщение для кредитного регистра".
def var p-opErr as logi no-undo.
def var p-opErrDes as char no-undo.
def var q_name as char init "credregQ".

def var ptpsession as handle.
def var messageh as handle.
def var v-i as integer no-undo.
def var v-d as date no-undo.
def var v-r as deci no-undo.
def var v-l as logi no-undo.
def var v-stop as logi no-undo.




def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

p-opErr = yes.
p-opErrDes = "Неизвестная ошибка".

/***********************************************************************************************/
function GetSqlDate returns char(input ndt as DATE):
 def var Ret as char.
 def var YY as int.
 def var MM as int.
 def var DD as int.
 YY = YEAR(ndt).
 MM = MONTH(ndt).
 DD = DAY(ndt).
 Ret = string(YY,"9999") + "-" + string(MM,"99") + "-" + string(DD,"99").
 return Ret.
end function.
/***********************************************************************************************/
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setbrokerurl in ptpsession ("tcp://172.16.1.22:2507").
else run setbrokerurl in ptpsession ("tcp://172.16.1.12:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginsession in ptpsession.


run createtextmessage in ptpsession (output messageh).
run settext in messageh ("Начало передачи данных").
run setStringProperty in messageh("CredRegStart","Start").
run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).
run deletemessage in messageh.



   for each cr_wrk  where /*cr_wrk.is_natural_person = 0  and cr_wrk.id_credit_type >= 7*/ no-lock:

     /* create a message */
     run createtextmessage in ptpsession (output messageh).
     /* build request string */
     run settext in messageh (sMess).
     /******************************************************************************************************/
         if cr_wrk.bik_main_office <> '' then run setStringProperty in messageh("bik_main_office", cr_wrk.bik_main_office ).
	     if cr_wrk.bik_filial <> '' then run setStringProperty in messageh("bik_filial",cr_wrk.bik_filial).
	     if cr_wrk.data_rep <> ? then run setStringProperty in messageh("data_rep",GetSqlDate(cr_wrk.data_rep)).
	     if cr_wrk.contract_number <> '' then run setStringProperty in messageh("contract_number",cr_wrk.contract_number).
	     if cr_wrk.contract_date <> ? then run setStringProperty in messageh("contract_date",GetSqlDate(cr_wrk.contract_date)).
	     if cr_wrk.is_natural_person <> ? then run setStringProperty in messageh("is_natural_person",string(cr_wrk.is_natural_person)).
	     if cr_wrk.rnn <> '' then run setStringProperty in messageh("rnn",cr_wrk.rnn).
	     if cr_wrk.okpo <> '' then run setStringProperty in messageh("okpo",cr_wrk.okpo).
	     if cr_wrk.name <> '' then run setStringProperty in messageh("name",cr_wrk.name).
	     if cr_wrk.last_name <> '' then run setStringProperty in messageh("last_name",cr_wrk.last_name).
	     if cr_wrk.first_name <> '' then run setStringProperty in messageh("first_name",cr_wrk.first_name).
	     if cr_wrk.middle_name <> '' then run setStringProperty in messageh("middle_name",cr_wrk.middle_name).
	     if cr_wrk.address <> '' then run setStringProperty in messageh("address",cr_wrk.address).
	     if cr_wrk.id_region <> ? then run setStringProperty in messageh("id_region",string(cr_wrk.id_region)).
	     if cr_wrk.is_resident <> ? then run setStringProperty in messageh("is_resident",string(cr_wrk.is_resident)).
	/**/ if cr_wrk.id_nonresident_country <> ?  then run setStringProperty in messageh("id_nonresident_country",string(cr_wrk.id_nonresident_country)).
	     if cr_wrk.is_small_enterprise <> ?  then run setStringProperty in messageh("is_small_enterprise",string(cr_wrk.is_small_enterprise)).
	/**/ if cr_wrk.id_otrasl <> ? then run setStringProperty in messageh("id_otrasl",string(cr_wrk.id_otrasl)).
	     if cr_wrk.id_form_law <> ? then run setStringProperty in messageh("id_form_law",string(cr_wrk.id_form_law)).
	     if cr_wrk.id_special_rel_with_bank <> ? then run setStringProperty in messageh("id_special_rel_with_bank",string(cr_wrk.id_special_rel_with_bank)).
	     if cr_wrk.id_credit_type <> ? then run setStringProperty in messageh("id_credit_type",string(cr_wrk.id_credit_type)). /* 1-кредит 7-гарантия */
	     if cr_wrk.is_credit_line <> ? then run setStringProperty in messageh("is_credit_line",string(cr_wrk.is_credit_line)).
	     if cr_wrk.name_beneficiary <> '' then run setStringProperty in messageh("name_beneficiary",cr_wrk.name_beneficiary).
	     if cr_wrk.begin_date_by_contract <> ? then run setStringProperty in messageh("begin_date_by_contract",GetSqlDate(cr_wrk.begin_date_by_contract)).
	     if cr_wrk.expire_date_by_contract <> ? then run setStringProperty in messageh("expire_date_by_contract",GetSqlDate(cr_wrk.expire_date_by_contract)).
	     if cr_wrk.id_currency <> ? then run setStringProperty in messageh("id_currency",string(cr_wrk.id_currency)).
/*<> ?*/ if cr_wrk.sum_total_by_contract <> ? then run setStringProperty in messageh("sum_total_by_contract",string(cr_wrk.sum_total_by_contract,">>>>>>>>>>>9.99")).
/*<> ?*/ if cr_wrk.crediting_rate_by_contract <> ? then run setStringProperty in messageh("crediting_rate_by_contract",string(cr_wrk.crediting_rate_by_contract,">>9.99")).
	     if cr_wrk.begin_date_in_fact <> ? then run setStringProperty in messageh("begin_date_in_fact",GetSqlDate(cr_wrk.begin_date_in_fact)).
	     if cr_wrk.sum_given_in_fact > 0 then run setStringProperty in messageh("sum_given_in_fact",string(cr_wrk.sum_given_in_fact,">>>>>>>>>>>9.99")).
	     if cr_wrk.total_sum_given_in_fact > 0 then run setStringProperty in messageh("total_sum_given_in_fact",string(cr_wrk.total_sum_given_in_fact,">>>>>>>>>>>9.99")).
	     if cr_wrk.crediting_rate_in_fact > 0 then run setStringProperty in messageh("crediting_rate_in_fact",string(cr_wrk.crediting_rate_in_fact,">>9.99")).
	     if cr_wrk.date_end_of_prolongation <> ? then run setStringProperty in messageh("date_end_of_prolongation",GetSqlDate(cr_wrk.date_end_of_prolongation)).
	     if cr_wrk.id_cred_object > 0 then run setStringProperty in messageh("id_cred_object",string(cr_wrk.id_cred_object)).
	     if cr_wrk.id_source_of_finance > 0 then run setStringProperty in messageh("id_source_of_finance",string(cr_wrk.id_source_of_finance)).
	     if cr_wrk.id_classification_category <> ? then run setStringProperty in messageh("id_classification_category",string(cr_wrk.id_classification_category)).
	     if cr_wrk.id_credit_kind_of_payment <> ? then run setStringProperty in messageh("id_credit_kind_of_payment",string(cr_wrk.id_credit_kind_of_payment)).
/*<> ?*/ if cr_wrk.cost_of_guarantee <> ? then run setStringProperty in messageh("cost_of_guarantee",string(cr_wrk.cost_of_guarantee,">>>>>>>>>>>9.99")).
	     if cr_wrk.id_account_current_debt > 0 then run setStringProperty in messageh("id_account_current_debt",string(cr_wrk.id_account_current_debt)).
	     if cr_wrk.id_account_overdue_debt > 0 then run setStringProperty in messageh("id_account_overdue_debt",string(cr_wrk.id_account_overdue_debt)).
	     if cr_wrk.id_account_write_off_bal_debt > 0 then run setStringProperty in messageh("id_account_write_off_bal_debt",string(cr_wrk.id_account_write_off_bal_debt)).
/*<> ?*/ if cr_wrk.rem_current_debt <> ? then run setStringProperty in messageh("rem_current_debt",string(cr_wrk.rem_current_debt,">>>>>>>>>>>9.99")).
	     if cr_wrk.rem_overdue_debt > 0 then run setStringProperty in messageh("rem_overdue_debt",string(cr_wrk.rem_overdue_debt,">>>>>>>>>>>9.99")).
	     if cr_wrk.rem_write_off_balance_debt > 0 then run setStringProperty in messageh("rem_write_off_balance_debt",string(cr_wrk.rem_write_off_balance_debt,">>>>>>>>>>>9.99")).
	     if cr_wrk.rem_cr_rate_curr_debt > 0 then run setStringProperty in messageh("rem_cr_rate_curr_debt",string(cr_wrk.rem_cr_rate_curr_debt,">>>>>>>>>>>9.99")).
	     if cr_wrk.rem_cr_rate_overdue_debt > 0 then run setStringProperty in messageh("rem_cr_rate_overdue_debt",string(cr_wrk.rem_cr_rate_overdue_debt,">>>>>>>>>>>9.99")).
	     if cr_wrk.rem_cr_rate_write_off_bal_debt > 0 then run setStringProperty in messageh("rem_cr_rate_write_off_bal_debt",string(cr_wrk.rem_cr_rate_write_off_bal_debt,">>>>>>>>>>>9.99")).

         /*if cr_wrk.remaining_liability > 0 or (cr_wrk.remaining_liability = 0 and cr_wrk.expire_date_in_fact <> ?) then run setStringProperty in messageh("remaining_liability",string(cr_wrk.remaining_liability)).*/
         if cr_wrk.id_credit_type = 1 Then do:
	       if cr_wrk.remaining_liability > 0 and cr_wrk.expire_date_in_fact <> ? then run setStringProperty in messageh("remaining_liability",string(cr_wrk.remaining_liability)).
         end. else
           if cr_wrk.remaining_liability > 0 or (cr_wrk.remaining_liability = 0 and cr_wrk.expire_date_in_fact <> ?) then run setStringProperty in messageh("remaining_liability",string(cr_wrk.remaining_liability)).

         if cr_wrk.date_cr_acc_write_off_bal_debt <> ? then run setStringProperty in messageh("date_cr_acc_write_off_bal_debt",GetSqlDate(cr_wrk.date_cr_acc_write_off_bal_debt)).
	     if cr_wrk.date_cred_write_off_balance <> ? then run setStringProperty in messageh("date_cred_write_off_balance",GetSqlDate(cr_wrk.date_cred_write_off_balance)).
	     if cr_wrk.expire_date_in_fact <> ? then run setStringProperty in messageh("expire_date_in_fact",GetSqlDate(cr_wrk.expire_date_in_fact)).
	     if cr_wrk.req_sum_of_provisions > 0 then run setStringProperty in messageh("req_sum_of_provisions",string(cr_wrk.req_sum_of_provisions,">>>>>>>>>>>9.99")).
	     if cr_wrk.fact_sum_of_provisions > 0 then run setStringProperty in messageh("fact_sum_of_provisions",string(cr_wrk.fact_sum_of_provisions,">>>>>>>>>>>9.99")).
	     if cr_wrk.comment1 <> '' then run setStringProperty in messageh("comment1",cr_wrk.comment1).
	     if cr_wrk.comment2 <> '' then run setStringProperty in messageh("comment2",cr_wrk.comment2).

        /******************************************************************************************************/
        /* send a message to a queue */
        run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).
        run deletemessage in messageh.

        hide message no-pause.
        message "Передача данных - " LN[i].
        if i = 8 then i = 1.
        else i = i + 1.


       /*
        message "всего 1" view-as alert-box.
        leave.
     */
   end. /* for each cr_wrk */



     run createtextmessage in ptpsession (output messageh).
     run settext in messageh ("Завершение передачи").
     run setStringProperty in messageh("CredRegEnd",g-ofc + "@metrocombank.kz").
     run sendtoqueue in ptpsession (q_name, messageh, ?, ?, ?).
     run deletemessage in messageh.


run deletesession in ptpsession.

   hide message no-pause.
  message "По окончании экспорта Вам будет выслано уведомление" view-as alert-box.
p-opErr = no.
p-opErrDes = ''.

