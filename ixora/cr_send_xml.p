/* cr_send_xml.p
 * MODULE
        Отправка сообщений для программы Кредитный регистр
 * DESCRIPTION
        Формирование xml-файла для отправки в Модернизированный кредитный регистр
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
        22/07/2013 Sayat(id01143) - ТЗ 1254 от 09/01/2012 "Касательно модернизации АИП «Кредитный Регистр»" (на основе cr_send)
 * BASES
        BANK COMM
 * CHANGES
        31/10/2013 sayat(id01143) - ТЗ 2154 от 18/10/2013 счет 3305 не передается, а балансовые счета 1434 и 1428 передаются с детализацией (например 1434191 вместо 1434000 и т.д.)

*/

def input parameter dat as date no-undo.
def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.
def input parameter num as char .

{credreg1.i}
{srvcheck.i}

def shared var g-today as date.
def shared var rates as deci extent 20.
def shared var crates as char extent 20.

function date_str returns char (input v-date as date) .
   return (string(year(v-date)) + "-" + string(month(v-date),'99') + "-" + string(day(v-date),'99')).
end.

function date_prior returns date (input v-date as date) .
    def var vyear as inte no-undo.
    def var vmonth as inte no-undo.
    vmonth = month(v-date) - 1.
    vyear = year(v-date).
    if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
    return (date(vmonth,day(v-date),vyear)).
end.

def var numcred as integer no-undo.
def var v-currency as int no-undo.
def var v-id_credit_type as char no-undo.
def var s-currency as char no-undo.
def var v-find as char  no-undo.
def var v-find1 as char  no-undo.
def var v-id_region as char no-undo.
def var v-id_classification_category as char no-undo.
def var k as int init 0.
def var pledgestype as char.
def var pledgesno as char.
def var pledgessum as deci.

numcred = 0.
for each cr_wrk where cr_wrk.id_credit_type = 1 no-lock:
    numcred = numcred + 1.
end.

define stream m-out.
output stream m-out to "nkred.xml".
define stream v-out.
output stream v-out to "nkred.htm".

put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
put stream m-out unformatted '<batch>' skip.
put stream m-out unformatted '<info>' skip.
put stream m-out unformatted '<creditor>' skip.
put stream m-out unformatted '<docs>' skip.
put stream m-out unformatted '<doc doc_type="15">' skip.
put stream m-out unformatted '<no>FOBAKZKA</no>' skip.
put stream m-out unformatted '</doc>' skip.
put stream m-out unformatted '</docs>' skip.
put stream m-out unformatted '</creditor>' skip.
put stream m-out unformatted '<account_date>' + date_str(g-today) + '</account_date>' skip.
put stream m-out unformatted '<report_date>' + date_str(dat) + '</report_date>' skip.
put stream m-out unformatted '<actual_credit_count>' + string(numcred) + '</actual_credit_count>' skip.
put stream m-out unformatted '</info>' skip.
put stream m-out unformatted '<packages>' skip.

put stream v-out unformatted "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.
put stream v-out unformatted
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
      "<td valign=""center"">package no</td>" skip
      "<td valign=""center"">primary_contract no</td>" skip
      "<td valign=""center"">date</td>" skip
      "<td valign=""center"">credit credit_type</td>" skip
      "<td valign=""center"">currency</td>" skip
      "<td valign=""center"">interest_rate_yearly</td>" skip
      "<td valign=""center"">contract_maturity_date</td>" skip
      "<td valign=""center"">actual_issue_date</td>" skip
      "<td valign=""center"">credit_purpose</td>" skip
      "<td valign=""center"">credit_object</td>" skip
      "<td valign=""center"">amount</td>" skip
      "<td valign=""center"">finance_source</td>" skip
      "<td valign=""center"">has_currency_earn</td>" skip
      "<td valign=""center"">country</td>" skip
      "<td valign=""center"">bank_relation</td>" skip
      "<td valign=""center"">region</td>" skip
      "<td valign=""center"">details</td>" skip
      "<td valign=""center"">names</td>" skip
      "<td valign=""center"">firstname</td>" skip
      "<td valign=""center"">lastname</td>" skip
      "<td valign=""center"">middlename</td>" skip
      "<td valign=""center"">legal_form</td>" skip
      "<td valign=""center"">doc doc_type=02</td>" skip
      "<td valign=""center"">doc doc_type=06</td>" skip
      "<td valign=""center"">doc doc_type=07</td>" skip
      "<td valign=""center"">doc doc_type=10</td>" skip
      "<td valign=""center"">doc doc_type=11</td>" skip
      "<td valign=""center"">enterprise_type</td>" skip
      "<td valign=""center"">econ_trade</td>" skip
      "<td valign=""center"">is_se</td>" skip
      "<td valign=""center"">head firstname</td>" skip
      "<td valign=""center"">head lastname</td>" skip
      "<td valign=""center"">head middlename</td>" skip
      "<td valign=""center"">head doc doc_type=02</td>" skip
      "<td valign=""center"">head doc doc_type=06</td>" skip
      "<td valign=""center"">head doc doc_type=11</td>" skip
      "<td valign=""center"">pledge_type</td>" skip
      "<td valign=""center"">pledge_no</td>" skip
      "<td valign=""center"">pledge_sum</td>" skip
      "<td valign=""center"">ОД</td>" skip
      "<td valign=""center"">ОД в валюте договора</td>" skip
      "<td valign=""center"">счет ОД</td>" skip
      "<td valign=""center"">проср ОД</td>" skip
      "<td valign=""center"">проср ОД в валюте договора</td>" skip
      "<td valign=""center"">счет проср ОД</td>" skip
      "<td valign=""center"">Дата выхода на просрочку</td>" skip
      "<td valign=""center"">Дата закрытия просрочки</td>" skip
      "<td valign=""center"">списанный ОД</td>" skip
      "<td valign=""center"">списанный ОД в валюте договора</td>" skip
      "<td valign=""center"">счет списанного ОД</td>" skip
      "<td valign=""center"">дата списания ОД</td>" skip
      "<td valign=""center"">вознагр(%)</td>" skip
      "<td valign=""center"">вознагр(%) в валюте договора</td>" skip
      "<td valign=""center"">счет вознагр(%)</td>" skip
      "<td valign=""center"">проср. вознагр(%)</td>" skip
      "<td valign=""center"">проср. вознагр(%) в валюте договора</td>" skip
      "<td valign=""center"">счет проср. вознагр(%)</td>" skip
      "<td valign=""center"">дата выхода на просрочку</td>" skip
      "<td valign=""center"">дата закрытия просрочки</td>" skip
      "<td valign=""center"">спис. вознагр(%)</td>" skip
      "<td valign=""center"">спис. вознагр(%) в валюте договора</td>" skip
      "<td valign=""center"">счет спис. вознагр(%)</td>" skip
      "<td valign=""center"">дата списания вознагр(%)</td>" skip
      "<td valign=""center"">дисконт</td>" skip
      "<td valign=""center"">дисконт в валюте договора</td>" skip
      "<td valign=""center"">счет дисконта</td>" skip
      "<td valign=""center"">classification</td>" skip
      "<td valign=""center"">provision balance_account</td>" skip
      "<td valign=""center"">provision balance_account_msfo</td>" skip
      "<td valign=""center"">provision value</td>" skip
      "<td valign=""center"">provision value_msfo</td> </tr>" skip.

numcred = 1.
for each cr_wrk no-lock:
    /*if cr_wrk.address = '' then next.*/
    /*case cr_wrk.id_currency:
        when 4 then do: v-currency = 1. s-currency = 'KZT'. end.
        when 3 then do: v-currency = 2. s-currency = 'USD'. end.
        when 112 then do: v-currency = 3. s-currency = 'RUB'. end.
    end case.*/


    /*case cr_wrk.id_credit_type:
        when 1 then v-id_credit_type = '01'.
        when 2 then v-id_credit_type = '02'.
        when 6 then v-id_credit_type = '06'.
        when 12 then v-id_credit_type = '12'.
        when 13 then v-id_credit_type = '13'.
    end case.
    */
    v-id_credit_type = string(cr_wrk.id_credit_type,'99').
    v-id_classification_category = '10'.
    case cr_wrk.id_classification_category:
        when 1 then v-id_classification_category = '10'.
        when 2 then v-id_classification_category = '21'.
        when 3 then v-id_classification_category = '22'.
        when 4 then v-id_classification_category = '23'.
        when 5 then v-id_classification_category = '24'.
        when 6 then v-id_classification_category = '25'.
        when 7 then v-id_classification_category = '30'.
    end case.


    case cr_wrk.id_region:
        when 2 then v-id_region = '75'. /* г. Алматы */
        when 4 then v-id_region = '15'. /* Актобе, Актюбинская обл */
        when 10 then v-id_region = '39'. /* Костанай, Костанайская обл */
        when 8 then v-id_region = '31'. /* Тараз, Жамбылская обл */
        when 7 then v-id_region = '27'. /* Уральск, ЗКО */
        when 9 then v-id_region = '35'. /* Караганда, Карагандинская обл */
        when 15 then v-id_region = '63'. /* Семей, ВКО */
        when 3 then v-id_region = '11'. /* Кокшетау, Акмолинская обл */
        when 1 then v-id_region = '71'. /* г. Астана */
        when 13 then v-id_region = '55'. /* Павлодар, Павлодарская обл */
        when 16 then v-id_region = '59'. /* Петропавловск, СКО */
        when 6 then v-id_region = '23'. /* Атырау, Атырауская обл */
        when 12 then v-id_region = '47'. /* Актау, Мангистауская обл */
        when 9 then v-id_region = '35'. /* Жезказган, Карагандинская обл */
        when 15 then v-id_region = '63'. /* Усть-Каменогорск, ВКО */
        when 14 then v-id_region = '51'. /* Шымкент, ЮКО */
    end case.

    /*if (cr_wrk.contract_date > date_prior(dat)) then do:*/
    if (true) then do:
        /*if cr_wrk.contract_number = 'PG006/13' or cr_wrk.contract_number = 'PG009/13' then
            put stream m-out unformatted '<package no="' + string(numcred) + '" operation_type="insert">' skip.*/
        /*else*/
        /*put stream m-out unformatted '<package no="' + string(numcred) + '" operation_type="update">' skip.*/
        if cr_wrk.contract_date >= dt1 then put stream m-out unformatted '<package no="' + string(numcred) + '" operation_type="insert">' skip.
        else put stream m-out unformatted '<package no="' + string(numcred) + '" operation_type="update">' skip.
        put stream m-out unformatted '<primary_contract>' skip.
        put stream m-out unformatted '<no>' + replace(cr_wrk.contract_number,'№','N') + '-' + cr_wrk.cif + '</no>' skip.
        put stream m-out unformatted '<date>' + date_str(cr_wrk.contract_date) + '</date>' skip.
        put stream m-out unformatted '</primary_contract>' skip.
        put stream m-out unformatted '<credit credit_type="' + string(v-id_credit_type) + '">' skip.
        put stream m-out unformatted '<currency>' + crates[cr_wrk.id_currency] + '</currency>' skip.
        if cr_wrk.crediting_rate_by_contract <> ? then
            put stream m-out unformatted '<interest_rate_yearly>' + trim(string(cr_wrk.crediting_rate_in_fact,"->>>>>>>>>>>9")) + '</interest_rate_yearly>' skip.
        if cr_wrk.expire_date_by_contract <> ? then
            put stream m-out unformatted '<contract_maturity_date>' + date_str(cr_wrk.expire_date_by_contract) + '</contract_maturity_date>' skip.
        put stream m-out unformatted '<actual_issue_date>' + date_str(cr_wrk.begin_date_by_contract) + '</actual_issue_date>' skip.
        if cr_wrk.id_cred_tgt <> ? then
            put stream m-out unformatted '<credit_purpose>' string(cr_wrk.id_cred_tgt,"99") '</credit_purpose>' skip.
        if cr_wrk.id_cred_object <> ? then
            put stream m-out unformatted '<credit_object>' string(cr_wrk.id_cred_object,"99") '</credit_object>' skip.
        if sum_total_by_contract <> ? then
            put stream m-out unformatted '<amount>' + trim(string(cr_wrk.sum_total_by_contract,"->>>>>>>>>>>9")) + '</amount>' skip.
        if cr_wrk.id_source_of_finance <> ? then
            put stream m-out unformatted '<finance_source>' string(cr_wrk.id_source_of_finance,"99") '</finance_source>' skip.
        if v-currency <> 1 then
            put stream m-out unformatted '<has_currency_earn>0</has_currency_earn>' skip.
        put stream m-out unformatted '</credit>' skip.

        put stream m-out unformatted '<subjects>' skip.
        put stream m-out unformatted '<subject>' skip.
        if cr_wrk.is_natural_person = 1 then do:
            put stream m-out unformatted '<person>' skip.
            put stream m-out unformatted '<country>398</country>' skip.
            put stream m-out unformatted '<bank_relations>' skip.
            put stream m-out unformatted '<bank_relation>' + string(cr_wrk.id_special_rel_with_bank,'99') + '</bank_relation>' skip.
            put stream m-out unformatted '</bank_relations>' skip.
            put stream m-out unformatted '<addresses>' skip.
            put stream m-out unformatted '<address type="FA">' skip.
            put stream m-out unformatted '<region>' + v-id_region + '</region>' skip.
            put stream m-out unformatted '<details>' + cr_wrk.address + '</details>' skip.
            put stream m-out unformatted '</address>' skip.
            put stream m-out unformatted '</addresses>' skip.
            put stream m-out unformatted '<names>' skip.
            put stream m-out unformatted '<name lang="RU">' skip.
            put stream m-out unformatted '<firstname>' + replace(cr_wrk.first_name,'.','') + '</firstname>' skip.
            put stream m-out unformatted '<lastname>' + replace(cr_wrk.last_name,'.','') + '</lastname>' skip.
            if cr_wrk.middle_name <> "" Then
                put stream m-out unformatted '<middlename>' + replace(cr_wrk.middle_name,'.','') + '</middlename>' skip.
            put stream m-out unformatted '</name>' skip.
            put stream m-out unformatted '</names>' skip.
            if trim(cr_wrk.pss + cr_wrk.rnn + cr_wrk.bin) <> '' then do:
                put stream m-out unformatted '<docs>' skip.
                if trim(cr_wrk.pss) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="02">' skip.
                    put stream m-out unformatted '<no>' + replace(cr_wrk.pss,'№','N') + '</no>' skip. /*+*/
                    put stream m-out unformatted '</doc>' skip.
                end.
                if trim(cr_wrk.rnn) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="11">' skip.
                    put stream m-out unformatted '<no>' + cr_wrk.rnn + '</no>' skip. /*+*/
                    put stream m-out unformatted '</doc>' skip.
                end.
                if trim(cr_wrk.bin) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="06">' skip.
                    put stream m-out unformatted '<no>' + cr_wrk.bin + '</no>' skip. /*+*/
                    put stream m-out unformatted '</doc>' skip.
                end.
                put stream m-out unformatted '</docs>' skip.
            end.
            put stream m-out unformatted '</person>' skip.
        end.
        else do:
            put stream m-out unformatted '<organization>' skip.
            put stream m-out unformatted '<country>398</country>' skip.
            put stream m-out unformatted '<bank_relations>' skip.
            put stream m-out unformatted '<bank_relation>' + string(cr_wrk.id_special_rel_with_bank,'99') + '</bank_relation>' skip.
            put stream m-out unformatted '</bank_relations>' skip.
            put stream m-out unformatted '<addresses>' skip.
            put stream m-out unformatted '<address type="FA">' skip.
            put stream m-out unformatted '<region>' + v-id_region + '</region>' skip.
            put stream m-out unformatted '<details>' + cr_wrk.address + '</details>' skip.
            put stream m-out unformatted '</address>' skip.
            put stream m-out unformatted '</addresses>' skip.
            put stream m-out unformatted '<names>' skip.
            put stream m-out unformatted '<name lang="RU">' + cr_wrk.name + '</name>' skip.
            put stream m-out unformatted '</names>' skip.
            put stream m-out unformatted '<head>' skip.
            put stream m-out unformatted '<names>' skip.
            put stream m-out unformatted '<name lang="RU">' skip.
            put stream m-out unformatted '<firstname>' + replace(cr_wrk.last_name,'.','') + '</firstname>' skip.
            put stream m-out unformatted '<lastname>' + replace(cr_wrk.first_name,'.','') + '</lastname>' skip.
            if cr_wrk.middle_name <> "" Then
                put stream m-out unformatted '<middlename>' + replace(cr_wrk.middle_name,'.','') + '</middlename>' skip.
            put stream m-out unformatted '</name>' skip.
            put stream m-out unformatted '</names>' skip.
            if  trim(cr_wrk.mpss + cr_wrk.mrnn) <> '' then do:
                put stream m-out unformatted '<docs>' skip.
                if trim(cr_wrk.mpss) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="02">' skip.
                    put stream m-out unformatted '<no>' + replace(cr_wrk.mpss,'№','N') + '</no>' skip.
                    put stream m-out unformatted '</doc>' skip.
                end.
                if trim(cr_wrk.mrnn) <> '' then do:
                    if cr_wrk.vbin then do:
                        put stream m-out unformatted '<doc doc_type="06">' skip.
                        put stream m-out unformatted '<no>' + cr_wrk.mrnn + '</no>' skip.
                        put stream m-out unformatted '</doc>' skip.
                    end.
                    else do:
                        put stream m-out unformatted '<doc doc_type="11">' skip.
                        put stream m-out unformatted '<no>' + cr_wrk.mrnn + '</no>' skip.
                        put stream m-out unformatted '</doc>' skip.
                    end.
                end.
                put stream m-out unformatted '</docs>' skip.
            end.
            put stream m-out unformatted '</head>' skip.
            put stream m-out unformatted '<legal_form>' + string(cr_wrk.id_form_law,'99') + '</legal_form>' skip.
            if trim(cr_wrk.svreg + cr_wrk.rnn + cr_wrk.bin) <> '' then do:
                put stream m-out unformatted '<docs>' skip.
                if trim(cr_wrk.svreg) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="10">' skip.
                    put stream m-out unformatted '<no>' + replace(cr_wrk.svreg,'№','N') + '</no>' skip.
                    put stream m-out unformatted '</doc>' skip.
                end.
                if trim(cr_wrk.rnn) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="11">' skip.
                    put stream m-out unformatted '<no>' + cr_wrk.rnn + '</no>' skip.
                    put stream m-out unformatted '</doc>' skip.
                end.
                if trim(cr_wrk.bin) <> '' then do:
                    put stream m-out unformatted '<doc doc_type="07">' skip.
                    put stream m-out unformatted '<no>' + cr_wrk.bin + '</no>' skip.
                    put stream m-out unformatted '</doc>' skip.
                end.
                put stream m-out unformatted '</docs>' skip.
            end.
            put stream m-out unformatted '<enterprise_type>' string(cr_wrk.is_small_enterprise,'99') '</enterprise_type>' skip.
            put stream m-out unformatted '<econ_trade>' string(cr_wrk.id_otrasl,"99") '</econ_trade>' skip.
            if cr_wrk.is_se = 1 then
                put stream m-out unformatted '<is_se>1</is_se>' skip.
            put stream m-out unformatted '</organization>' skip.
        end.
        put stream m-out unformatted '</subject>' skip.
        put stream m-out unformatted '</subjects>' skip.
        /*Обеспечения*/
        put stream m-out unformatted '<pledges>' skip.
        k = 0.
        pledgestype = ''.
        pledgesno = ''.
        pledgessum = 0.
        for each cr_pled where cr_pled.cif = cr_wrk.cif and cr_pled.lon = cr_wrk.lon and cr_pled.fil = cr_wrk.fil and cr_pled.lonsec <> 5 no-lock:
            k = k + 1.
            put stream m-out unformatted '<pledge>' skip.
            /*case cr_pled.lonsec:
                when 1 then put stream m-out unformatted '<pledge_type>06</pledge_type>' skip.
                when 2 then put stream m-out unformatted '<pledge_type>32</pledge_type>' skip.
                when 3 then put stream m-out unformatted '<pledge_type>02</pledge_type>' skip.
                when 4 then put stream m-out unformatted '<pledge_type>43</pledge_type>' skip.
                when 6 then put stream m-out unformatted '<pledge_type>10</pledge_type>' skip.
            end case.*/
            put stream m-out unformatted '<pledge_type>' + cr_pled.pledtype + '</pledge_type>' skip.
            if pledgestype <> '' then pledgestype = pledgestype + ';'.
            pledgestype = pledgestype + cr_pled.pledtype.
            put stream m-out unformatted '<contract>' skip.
            put stream m-out unformatted '<no>' + cr_pled.dnum + '</no>' skip.
            put stream m-out unformatted '</contract>' skip.
            if pledgesno <> '' then pledgesno = pledgesno + ';'.
            pledgesno = pledgesno + cr_pled.dnum.
            put stream m-out unformatted '<value>' + trim(string(round(cr_pled.secamt,0),'->>>>>>>>>>>>9')) + '</value>' skip.
            pledgessum = pledgessum + cr_pled.secamt.
            put stream m-out unformatted '</pledge>' skip.
        end.
        if k = 0 then do:
            put stream m-out unformatted '<pledge>' skip.
            find first cr_pled where cr_pled.cif = cr_wrk.cif and cr_pled.lon = cr_wrk.lon and cr_pled.fil = cr_wrk.fil and cr_pled.lonsec = 5 no-lock no-error.
            if avail cr_pled then
                put stream m-out unformatted '<pledge_type>' + cr_pled.pledtype + '</pledge_type>' skip.
            else
                put stream m-out unformatted '<pledge_type>47</pledge_type>' skip.
            put stream m-out unformatted '</pledge>' skip.
            pledgestype = '47'.
            pledgesno = ''.
            pledgessum = 0.
        end.
        put stream m-out unformatted '</pledges>' skip.
        put stream m-out unformatted '<change>' skip.
        if cr_wrk.rem_current_debt <> ? or abs(cr_wrk.rem_overdue_debt) > 0 or abs(cr_wrk.rem_write_off_balance_debt) > 0
        or (cr_wrk.rem_cr_rate_curr_debt <> ? and cr_wrk.bal_acc2 <> '')  or abs(cr_wrk.rem_cr_rate_overdue_debt) > 0 or abs(cr_wrk.rem_cr_rate_write_off_bal_debt) > 0
        or abs(cr_wrk.rem_discount) > 0 then do:
            put stream m-out unformatted '<remains>' skip.
            if cr_wrk.rem_current_debt <> ? or abs(cr_wrk.rem_overdue_debt) > 0 or abs(cr_wrk.rem_write_off_balance_debt) > 0 then do:
                /*Основной долг*/
                put stream m-out unformatted '<debt>' skip.
                /*Непросроченная задолженность*/
                if cr_wrk.rem_current_debt <> ? then do:
                    put stream m-out unformatted '<current>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_current_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_current_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc1 + '</balance_account>' skip.
                    put stream m-out unformatted '</current>' skip.
                end.
                /*Просроченная задолженность*/
                if abs(cr_wrk.rem_overdue_debt) > 0 and cr_wrk.bal_acc7 <> '' then do:
                    put stream m-out unformatted '<pastdue>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_overdue_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc7 + '</balance_account>' skip.
                    if cr_wrk.rem_overdue_date <> ? then put stream m-out unformatted '<open_date>' + date_str(cr_wrk.rem_overdue_date) + '</open_date>' skip.
                    /*put stream m-out unformatted '<close_date></close_date>' skip.*/
                    put stream m-out unformatted '</pastdue>' skip.
                end.
                /*Списанная задолженность*/
                if abs(cr_wrk.rem_write_off_balance_debt) > 0 and cr_wrk.date_cr_acc_write_off_bal_debt <> ? and cr_wrk.bal_acc13 <> '' then do:
                    put stream m-out unformatted '<write_off>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_write_off_balance_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_write_off_balance_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc13 + '</balance_account>' skip.
                    put stream m-out unformatted '<date>' + date_str(cr_wrk.date_cr_acc_write_off_bal_debt) + '</date>' skip.
                    /*put stream m-out unformatted '<close_date></close_date>' skip.*/
                    put stream m-out unformatted '</write_off>' skip.
                end.
                put stream m-out unformatted '</debt>' skip.
            end.
            if (cr_wrk.rem_cr_rate_curr_debt <> ? and cr_wrk.bal_acc2 <> '') or abs(cr_wrk.rem_cr_rate_overdue_debt) > 0 or abs(cr_wrk.rem_cr_rate_write_off_bal_debt) > 0 then do:
                /*Вознаграждение*/
                put stream m-out unformatted '<interest>' skip.
                /*Непросроченная задолженность*/
                if cr_wrk.rem_cr_rate_curr_debt <> ? and cr_wrk.bal_acc2 <> '' then do:
                    put stream m-out unformatted '<current>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_cr_rate_curr_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_cr_rate_curr_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc2 + '</balance_account>' skip.
                    put stream m-out unformatted '</current>' skip.
                end.
                /*Просроченная задолженность*/
                if abs(cr_wrk.rem_cr_rate_overdue_debt) > 0 and cr_wrk.rem_cr_rate_overdue_date <> ? and cr_wrk.bal_acc9 <> '' then do:
                    put stream m-out unformatted '<pastdue>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_cr_rate_overdue_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_cr_rate_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc9 + '</balance_account>' skip.
                    if cr_wrk.rem_cr_rate_overdue_date <> ? then put stream m-out unformatted '<open_date>' + date_str(cr_wrk.rem_cr_rate_overdue_date) + '</open_date>' skip.
                    /*put stream m-out unformatted '<close_date></close_date>' skip.*/
                    put stream m-out unformatted '</pastdue>' skip.
                end.
                /*Списанная задолженность*/
                if abs(cr_wrk.rem_cr_rate_write_off_bal_debt) > 0 and cr_wrk.date_cred_write_off_balance <> ? then do:
                    put stream m-out unformatted '<write_off>' skip.
                    put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_cr_rate_write_off_bal_debt,"->>>>>>>>>>>9")) + '</value>' skip.
                    put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_cr_rate_write_off_bal_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                    /*put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc14 + '</balance_account>' skip.*/
                    put stream m-out unformatted '<date>' + date_str(cr_wrk.date_cred_write_off_balance) + '</date>' skip.
                    /*put stream m-out unformatted '<close_date></close_date>' skip.*/
                    put stream m-out unformatted '</write_off>' skip.
                end.
                put stream m-out unformatted '</interest>' skip.
            end.

            if cr_wrk.rem_discount <> ? and cr_wrk.bal_acc42 <> '' then do:
                put stream m-out unformatted '<discount>' skip.
                put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_discount,"->>>>>>>>>>>9")) + '</value>' skip.
                put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_discount /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
                put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc42 + '</balance_account>' skip.
                put stream m-out unformatted '</discount>' skip.
            end.
            put stream m-out unformatted '</remains>' skip.
        end.
        put stream m-out unformatted '<credit_flow>' skip.
        put stream m-out unformatted '<classification>' + v-id_classification_category + '</classification>' skip.
        if (cr_wrk.fact_sum_of_provisions <> ? or cr_wrk.req_sum_of_provisions <> ?) /*and cr_wrk.bal_acc38 <> ''*/ and cr_wrk.bal_acc567 <> '' then do:
            put stream m-out unformatted '<provision>' skip.
            /*put stream m-out unformatted '<balance_account>' + cr_wrk.bal_acc38 + '</balance_account>' skip.*/
            put stream m-out unformatted '<balance_account_msfo>' + cr_wrk.bal_acc567 + '</balance_account_msfo>' skip.
            if cr_wrk.fact_sum_of_provisions <> ? and cr_wrk.fact_sum_of_provisions <> 0 then
                put stream m-out unformatted '<value>' + trim(string(cr_wrk.fact_sum_of_provisions,"->>>>>>>>>>>9")) + '</value>' skip.
            if cr_wrk.req_sum_of_provisions <> ? and cr_wrk.req_sum_of_provisions <> 0 then
                put stream m-out unformatted '<value_msfo>' + trim(string(cr_wrk.req_sum_of_provisions,"->>>>>>>>>>>9")) + '</value_msfo>' skip.
            put stream m-out unformatted '</provision>' skip.
        end.
        put stream m-out unformatted '</credit_flow>' skip.
        put stream m-out unformatted '</change>' skip.
        put stream m-out unformatted '</package>' skip.
    end.
    else do:
        put stream m-out unformatted '<packages>' skip.
        put stream m-out unformatted '<package no="' + string(numcred) + '" operation_type="update">' skip.
        put stream m-out unformatted '<primary_contract>' skip.
        put stream m-out unformatted '<no>' + replace(cr_wrk.contract_number,'№','N') + '</no>' skip.
        put stream m-out unformatted '<date>' + date_str(cr_wrk.contract_date) + '</date>' skip.
        put stream m-out unformatted '</primary_contract>' skip.
        put stream m-out unformatted '<change>' skip.
        put stream m-out unformatted '<remains>' skip.
        /*Основной долг*/
        put stream m-out unformatted '<debt>' skip.
        /*Непросроченная задолженность*/
        if cr_wrk.rem_current_debt <> ? then do:
            put stream m-out unformatted '<current>' skip.
            put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_current_debt,"->>>>>>>>>>>9")) + '</value>' skip.
            put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_current_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
            put stream m-out unformatted '<balance_account>' + cr_wrk.balance_account1 + '</balance_account>' skip.
            put stream m-out unformatted '</current>' skip.
        end.
        /*Просроченная задолженность*/
        if cr_wrk.rem_overdue_debt <> ? then do:
            put stream m-out unformatted '<pastdue>' skip.
            put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_overdue_debt,"->>>>>>>>>>>9")) + '</value>' skip.
            put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
            put stream m-out unformatted '<balance_account>' + cr_wrk.balance_account2 + '</balance_account>' skip.
            put stream m-out unformatted '<open_date>' + date_str(cr_wrk.rem_overdue_date) + '</open_date>' skip.
            /*put stream m-out unformatted '<close_date></close_date>' skip.*/
            put stream m-out unformatted '</pastdue>' skip.
        end.
        put stream m-out unformatted '</debt>' skip.

        /*Вознаграждение*/
        put stream m-out unformatted '<interest>' skip.
        /*Непросроченная задолженность*/
        if cr_wrk.rem_cr_rate_curr_debt <> ? then do:
            put stream m-out unformatted '<current>' skip.
            put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_cr_rate_curr_debt,"->>>>>>>>>>>9")) + '</value>' skip.
            put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_cr_rate_curr_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
            put stream m-out unformatted '<balance_account>' + cr_wrk.balance_account1 + '</balance_account>' skip.
            put stream m-out unformatted '</current>' skip.
        end.
        /*Просроченная задолженность*/
        if cr_wrk.rem_cr_rate_overdue_debt <> ? then do:
            put stream m-out unformatted '<pastdue>' skip.
            put stream m-out unformatted '<value>' + trim(string(cr_wrk.rem_cr_rate_overdue_debt,"->>>>>>>>>>>9")) + '</value>' skip.
            put stream m-out unformatted '<value_currency>' + trim(string(cr_wrk.rem_cr_rate_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) + '</value_currency>' skip.
            put stream m-out unformatted '<balance_account>' + cr_wrk.balance_account2 + '</balance_account>' skip.
            put stream m-out unformatted '<open_date>' + date_str(cr_wrk.rem_cr_rate_overdue_date) + '</open_date>' skip.
            /*put stream m-out unformatted '<close_date></close_date>' skip.*/
            put stream m-out unformatted '</pastdue>' skip.
        end.
        put stream m-out unformatted '</interest>' skip.
        put stream m-out unformatted '</remains>' skip.

        put stream m-out unformatted '<credit_flow>' skip.
        if cr_wrk.fact_sum_of_provisions <> ? or cr_wrk.req_sum_of_provisions <> ? then do:
            put stream m-out unformatted '<classification>' + v-id_classification_category + '</classification>' skip.
            put stream m-out unformatted '<provision>' skip.
            put stream m-out unformatted '<balance_account>' + cr_wrk.balance_account1 + '</balance_account>' skip.
            put stream m-out unformatted '<balance_account_msfo>' + cr_wrk.balance_account2 + '</balance_account_msfo>' skip.
            if cr_wrk.fact_sum_of_provisions <> ? then
                put stream m-out unformatted '<value>' + trim(string(cr_wrk.fact_sum_of_provisions,"->>>>>>>>>>>9")) + '</value>' skip.
            if cr_wrk.req_sum_of_provisions <> ? then
                put stream m-out unformatted '<value_msfo>' + trim(string(cr_wrk.req_sum_of_provisions,"->>>>>>>>>>>9")) + '</value_msfo>' skip.
            put stream m-out unformatted '</provision>' skip.
        end.
        put stream m-out unformatted '</credit_flow>' skip.
        put stream m-out unformatted '</change>' skip.
        put stream m-out unformatted '</package>' skip.
    end.

    put stream v-out unformatted '<tr>' skip
        '<td>' string(numcred) '</td>' skip
        '<td>' cr_wrk.contract_number + '-' + cr_wrk.cif '</td>' skip
        '<td>' date_str(cr_wrk.contract_date) '</td>' skip
        '<td>' string(v-id_credit_type) '</td>' skip
        '<td>' crates[cr_wrk.id_currency] '</td>' skip
        '<td>' trim(string(cr_wrk.crediting_rate_by_contract,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' date_str(cr_wrk.expire_date_by_contract) '</td>' skip
        '<td>' date_str(cr_wrk.begin_date_by_contract) '</td>' skip
        '<td>' string(cr_wrk.id_cred_tgt,"99") '</td>' skip
        '<td>' string(cr_wrk.id_cred_object,"99") '</td>' skip
        '<td>' trim(string(cr_wrk.sum_total_by_contract,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' string(cr_wrk.id_source_of_finance,"99") '</td>' skip
        '<td>' 0 '</td>' skip
        '<td>' 398 '</td>' skip
        '<td>' string(cr_wrk.id_special_rel_with_bank,'99') '</td>' skip
        '<td>' v-id_region '</td>' skip
        '<td>' cr_wrk.address '</td>' skip
        '<td>' cr_wrk.name '</td>' skip
        '<td>' cr_wrk.first_name '</td>' skip
        '<td>' cr_wrk.last_name '</td>' skip
        '<td>' cr_wrk.middle_name '</td>' skip
        '<td>' cr_wrk.id_form_law '</td>' skip
        '<td>' cr_wrk.pss '</td>' skip
        '<td>' cr_wrk.bin '</td>' skip
        '<td>' cr_wrk.bin '</td>' skip
        '<td>' cr_wrk.svreg '</td>' skip
        '<td>' cr_wrk.rnn '</td>' skip
        '<td>' string(cr_wrk.is_small_enterprise,'99') '</td>' skip
        '<td>' string(cr_wrk.id_otrasl,"99") '</td>' skip
        '<td>' cr_wrk.is_se '</td>' skip
        '<td>' replace(cr_wrk.last_name,'.','') '</td>' skip
        '<td>' replace(cr_wrk.first_name,'.','') '</td>' skip
        '<td>' replace(cr_wrk.middle_name,'.','') '</td>' skip
        '<td>' cr_wrk.mpss '</td>' skip
        '<td>' cr_wrk.mrnn '</td>' skip
        '<td>' cr_wrk.mrnn '</td>' skip
        '<td>' pledgestype '</td>' skip
        '<td>' pledgesno '</td>' skip
        '<td>' trim(string(pledgessum,'->>>>>>>>>>>>>>>9')) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_current_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_current_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc1 '</td>' skip
        '<td>' trim(string(cr_wrk.rem_overdue_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc7 '</td>' skip
        '<td>' date_str(cr_wrk.rem_overdue_date) '</td>' skip
        '<td>'  '</td>' skip
        '<td>' trim(string(cr_wrk.rem_write_off_balance_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(rem_write_off_balance_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc13 '</td>' skip
        '<td>' date_str(cr_wrk.date_cr_acc_write_off_bal_debt) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_curr_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_curr_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc2 '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_overdue_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_overdue_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc9 '</td>' skip
        '<td>' date_str(cr_wrk.rem_cr_rate_overdue_date) '</td>' skip
        '<td>'  '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_write_off_bal_debt,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_cr_rate_write_off_bal_debt /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc14 '</td>' skip
        '<td>' date_str(cr_wrk.date_cred_write_off_balance) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_discount,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.rem_discount /  rates[cr_wrk.id_currency],"->>>>>>>>>>>9")) '</td>' skip
        '<td>' cr_wrk.bal_acc42 '</td>' skip
        '<td>' v-id_classification_category '</td>' skip
        '<td>' cr_wrk.bal_acc38 '</td>' skip
        '<td>' cr_wrk.bal_acc567 '</td>' skip
        '<td>' trim(string(cr_wrk.fact_sum_of_provisions,"->>>>>>>>>>>9")) '</td>' skip
        '<td>' trim(string(cr_wrk.req_sum_of_provisions,"->>>>>>>>>>>9")) '</td>' skip
        '</tr>' skip.
    numcred = numcred + 1.
end.

put stream m-out unformatted '</packages>' skip.
put stream m-out unformatted '</batch>' skip.


output stream m-out close.

/*
unix silent cp nkred.xml value("/data/log/nkred.xml").
unix silent win2koi nkred.xml wnkred.xml
unix silent koi2utf wnkred.xml kkredit.xml.
*/

v-find = ''.
input through value( "find /data/log/nkred.xml;echo $?").
repeat:
    import unformatted v-find.
end.
if v-find = "0" then unix silent value("rm /data/log/nkred.xml").
unix silent cp nkred.xml value("/data/log/nkred.xml").

unix silent koi2utf nkred.xml nkredit.xml.

v-find1 = ''.
input through value( "find `askhost`:c:/credreg/nkredit" + num + ".xml;echo $?").
repeat:
    import unformatted v-find1.
end.
if v-find1 = "0" then unix silent value("rm `askhost`:c:/credreg/nkredit" + num + ".xml").
unix silent scp -q nkredit.xml value(" Administrator@`askhost`:c:/credreg/nkredit" + num + ".xml").

put stream v-out unformatted "</table></body></html>".
output stream v-out close.
unix silent cptwin nkred.htm excel.
