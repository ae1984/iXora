/* credreg1.i
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Описание стандартных переменных и параметров
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        22/07/2013 Sayat(id01143) - ТЗ 1254 от 09/01/2012 "Касательно модернизации АИП «Кредитный Регистр»" (на основе credreg.i)
 * CHANGES
*/



define {1} shared temp-table cr_wrk
    field bik_main_office as char init ''
	field bik_filial as char init ''
	field data_rep as date init ?
	field contract_number as char init ''
	field contract_date as date init ?
	field is_natural_person as int init ? /* // 0 - юрики 1 - физики*/
	field rnn as char init ''
	field okpo as char init ''
	field name as char init ''
	field last_name as char init ''
	field first_name as char init ''
	field middle_name as char init ''
	field address as char init ''
	field id_region as int init ?
	field is_resident as int init ?
	field id_nonresident_country as int init ? /* // Иногда должно быть = NULL*/
	field is_small_enterprise as int init ?
	field id_otrasl as int init ? /* // Иногда должно быть = NULL*/
	field id_form_law as int init ?
	field id_special_rel_with_bank as int init ?
	field id_credit_type as int init ? /*  // 1-кредит 7-гарантия*/
	field is_credit_line as int init ?
	field name_beneficiary  as char init ''
	field begin_date_by_contract  as date init ?
	field expire_date_by_contract as date init ?
	field id_currency as int init ?
	field sum_total_by_contract as deci init ?
	field crediting_rate_by_contract as deci init ?
	field begin_date_in_fact as date init ?
	field sum_given_in_fact as deci init ?
	field total_sum_given_in_fact as deci init ?
	field crediting_rate_in_fact as deci init ?
	field date_end_of_prolongation as date init ?
	field id_cred_object as int init ?
	field id_source_of_finance as int init ?
	field id_classification_category as int init ?
	field id_credit_kind_of_payment as int init ?
	field cost_of_guarantee as deci init ?
	field id_account_current_debt as int init ?
	field id_account_overdue_debt as int init ?
	field id_account_write_off_bal_debt as int init ?
	field rem_current_debt as deci init ?
	field rem_overdue_debt as deci init ?
	field rem_write_off_balance_debt as deci init ?
	field rem_cr_rate_curr_debt as deci init ?
	field rem_cr_rate_overdue_debt as deci init ?
	field rem_cr_rate_write_off_bal_debt as deci init ?
	field remaining_liability as deci init ?
	field date_cr_acc_write_off_bal_debt as date init ?
	field date_cred_write_off_balance as date init ?
	field expire_date_in_fact as date init ?
	field req_sum_of_provisions as deci init ?
	field fact_sum_of_provisions as deci init ?
	field comment1 as char init ''
	field comment2 as char init ''
	field rem_overdue_date as date init ?
	field rem_cr_rate_overdue_date as date init ?
	field pss as char init ''
	field sufix as char init ''
    field balance_account1 as char init ''
    field balance_account2 as char init ''
    field cif as char init ''
    field mrnn as char init ''
    field mpss as char init ''
    field svreg as char init ''
    field bin as char init ''
    field vbin as logi init no
    field fil as char init ''
    field lon as char init ''
    field bal_acc1 as char init ''
    field bal_acc7 as char init ''
    field bal_acc13 as char init ''
    field bal_acc2 as char init ''
    field bal_acc9 as char init ''
    field bal_acc14 as char init ''
    field bal_acc42 as char init ''
    field bal_acc38 as char init ''
    field bal_acc567 as char init ''
    field is_se as int init 0
    field id_cred_tgt as int init ?
    field rem_discount as deci init ?.

define {1} shared temp-table cr_pled
    field fil as char init ''
    field lon as char init ''
    field cif as char init ''
    field dnum as char init ''
    field lonsec as integer init 0
    field secamt as deci init 0
    field crc as integer init 1
    field fdt as date init ?
    field tdt as date init ?
    field pledtype as char init ''.