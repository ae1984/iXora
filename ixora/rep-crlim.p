/* rep-crlim.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        17.07.2013 dmitriy. ТЗ 1640
 * BASES
        BANK COMM
 * CHANGES
        18.09.2013 dmitriy - Дополнение к ТЗ 1640 от 02.09.2013 - Добавление новых столбцов в загружаемый файл
*/

def new shared temp-table wrk-dat no-undo
    field bank as char
    field dt  as date
    field CONTRACT_NUMBER as char
    field CONTRACT_NAME as char
    field PRODUCT as char
    field DEPOSIT as char
    field CR_LIMIT as char
    field DATE_CR_LIM as char
    field CONTR_STATUS as char
    field AMOUNT_AVAILABLE as char
    field LOAN as char
    field PAYM_DUE as char
    field OVL as char
    field OVL_OVD as char
    field OVD_30 as char
    field OVD_MORE_30 as char
    field OVD_MORE_60 as char
    field OVD_MORE_90 as char
    field OVD_OUT as char
    field LOAN_INT as char
    field INT_RP as char
    field OVD_PENALTY_INT as char
    field INT_OVD_30 as char
    field INT_OVD_MORE_30 as char
    field INT_OVD_MORE_60 as char
    field INT_OVD_MORE_90 as char
    field INT_OVD_OUT as char
    field SUMM_ALL_WRITING as char
    field DATE_LAST_REPAYMENT as char
    field LAST_SUMM_REPAYMENT as char
    field SUMM_ALL_ACCRUAL_REWARD as char
    field SUMM_ALL_RECEIVE_REWARD as char
    index idx is primary bank ascending CONTRACT_NUMBER ascending.

def var file1 as char.
def var i as int.
def new shared var s-dt as date.

s-dt = today.
update s-dt label ' На дату' format '99/99/9999' validate (s-dt <= today, " Дата должна быть не позже текущей!") skip
with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "rep-crlim2"}



file1 = "pc_crlim.html".
output to value(file1).
{html-title.i}

put  unformatted
   "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
   "<HEAD>"                                       skip
" <!--[if gte mso 9]><xml>"                       skip
" <x:ExcelWorkbook>"                              skip
" <x:ExcelWorksheets>"                            skip
" <x:ExcelWorksheet>"                             skip
" <x:Name>17161</x:Name>"                         skip
" <x:WorksheetOptions>"                           skip
" <x:Selected/>"                                  skip
" <x:DoNotDisplayGridlines/>"                     skip
" <x:TopRowVisible>52</x:TopRowVisible>"          skip
" <x:Panes>"                                      skip
" <x:Pane>"                                       skip
" <x:Number>3</x:Number>"                         skip
" <x:ActiveRow>12</x:ActiveRow>"                  skip
" <x:ActiveCol>24</x:ActiveCol>"                  skip
" </x:Pane>"                                      skip
" </x:Panes>"                                     skip
" <x:ProtectContents>False</x:ProtectContents>"   skip
" <x:ProtectObjects>False</x:ProtectObjects>"     skip
" <x:ProtectScenarios>False</x:ProtectScenarios>" skip
" </x:WorksheetOptions>"                          skip
" </x:ExcelWorksheet>"                            skip
" </x:ExcelWorksheets>"                           skip
" <x:WindowHeight>7305</x:WindowHeight>"          skip
" <x:WindowWidth>14220</x:WindowWidth>"           skip
" <x:WindowTopX>120</x:WindowTopX>"               skip
" <x:WindowTopY>30</x:WindowTopY>"                skip
" <x:ProtectStructure>False</x:ProtectStructure>" skip
" <x:ProtectWindows>False</x:ProtectWindows>"     skip
" </x:ExcelWorkbook>"                             skip
"</xml><![endif]-->"                              skip
"<meta http-equiv=Content-Language content=ru>"   skip.

put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
    "<TR align=""center""><TD colspan=""15"">Остатки по кредитным лимитам на " s-dt format "99.99.9999" " </TD></tr>"
    "<TR align=""center""><TD colspan=""15"">( " v-bankname " )</TD></tr>"
    "<TR></TR>"
    "</TABLE>".

put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

put unformatted
    "<TR align=""center"">"
    "<TD bgcolor=""#CCCCCC""> № </TD>"
    "<TD bgcolor=""#CCCCCC""> Филиал </TD>"
    "<TD bgcolor=""#CCCCCC""> CONTRACT_NUMBER </TD>"
    "<TD bgcolor=""#CCCCCC""> CONTRACT_NAME </TD>"
    "<TD bgcolor=""#CCCCCC""> PRODUCT </TD>"
    "<TD bgcolor=""#CCCCCC""> DEPOSIT </TD>"
    "<TD bgcolor=""#CCCCCC""> CR_LIMIT </TD>"
    "<TD bgcolor=""#CCCCCC""> DATE_CR_LIM </TD>"
    "<TD bgcolor=""#CCCCCC""> CONTR_STATUS </TD>"
    "<TD bgcolor=""#CCCCCC""> AMOUNT_AVAILABLE </TD>"
    "<TD bgcolor=""#CCCCCC""> LOAN </TD>"
    "<TD bgcolor=""#CCCCCC""> PAYM_DUE </TD>"
    "<TD bgcolor=""#CCCCCC""> OVL </TD>"
    "<TD bgcolor=""#CCCCCC""> OVL_OVD </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_30 </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_MORE_30 </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_MORE_60 </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_MORE_90 </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_OUT </TD>"
    "<TD bgcolor=""#CCCCCC""> LOAN_INT </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_RP </TD>"
    "<TD bgcolor=""#CCCCCC""> OVD_PENALTY_INT </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_OVD_30 </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_OVD_MORE_30 </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_OVD_MORE_60 </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_OVD_MORE_90 </TD>"
    "<TD bgcolor=""#CCCCCC""> INT_OVD_OUT </TD>"
    "<TD bgcolor=""#CCCCCC""> SUMM_ALL_WRITING </TD>"
    "<TD bgcolor=""#CCCCCC""> DATE_LAST_REPAYMENT </TD>"
    "<TD bgcolor=""#CCCCCC""> LAST_SUMM_REPAYMENT </TD>"
    "<TD bgcolor=""#CCCCCC""> SUMM_ALL_ACCRUAL_REWARD </TD>"
    "<TD bgcolor=""#CCCCCC""> SUMM_ALL_RECEIVE_REWARD </TD>"
    "</TR>".

i = 1.
for each wrk-dat no-lock:
    put unformatted
        "<TR>"
        "<TD>" i "</TD>"
        "<TD>" bank "</TD>"
        "<TD>" CONTRACT_NUMBER "</TD>"
        "<TD>" CONTRACT_NAME "</TD>"
        "<TD>" PRODUCT "</TD>"
        "<TD>" replace(string(DEPOSIT), ".", ",") "</TD>"
        "<TD>" replace(string(CR_LIMIT), ".", ",") "</TD>"
        "<TD>" DATE_CR_LIM "</TD>"
        "<TD>" CONTR_STATUS "</TD>"
        "<TD>" replace(string(AMOUNT_AVAILABLE), ".", ",") "</TD>"
        "<TD>" replace(string(LOAN), ".", ",") "</TD>"
        "<TD>" replace(string(PAYM_DUE), ".", ",") "</TD>"
        "<TD>" replace(string(OVL), ".", ",") "</TD>"
        "<TD>" replace(string(OVL_OVD), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_30), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_MORE_30), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_MORE_60), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_MORE_90), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_OUT), ".", ",") "</TD>"
        "<TD>" replace(string(LOAN_INT), ".", ",") "</TD>"
        "<TD>" replace(string(INT_RP), ".", ",") "</TD>"
        "<TD>" replace(string(OVD_PENALTY_INT), ".", ",") "</TD>"
        "<TD>" replace(string(INT_OVD_30), ".", ",") "</TD>"
        "<TD>" replace(string(INT_OVD_MORE_30), ".", ",") "</TD>"
        "<TD>" replace(string(INT_OVD_MORE_60), ".", ",") "</TD>"
        "<TD>" replace(string(INT_OVD_MORE_90), ".", ",") "</TD>"
        "<TD>" replace(string(INT_OVD_OUT), ".", ",") "</TD>"
        "<TD>" replace(string(SUMM_ALL_WRITING), ".", ",") "</TD>"
        "<TD>" DATE_LAST_REPAYMENT "</TD>"
        "<TD>" replace(string(LAST_SUMM_REPAYMENT), ".", ",") "</TD>"
        "<TD>" replace(string(SUMM_ALL_ACCRUAL_REWARD), ".", ",") "</TD>"
        "<TD>" replace(string(SUMM_ALL_RECEIVE_REWARD), ".", ",") "</TD>"
        "</TR>".
    i = i + 1.
end.

put unformatted "</TABLE>".

{html-end.i " "}
output close.
unix silent cptwin value(file1) excel.

empty temp-table wrk-dat.





