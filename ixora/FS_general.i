/* FS_general.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - FS_GA.p,FS_KA.p,7SB_rep.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK
 * CHANGES
        28.01.2013 damir - Внедрено Т.З. № 1217,1218,1227.
*/
def {1} shared var v-dtb as date.
def {1} shared var v-dte as date.
def {1} shared var v-gldate as date.
def {1} shared var s-includetoday as logi init yes.
def {1} shared var s-RepName as char.

define {1} shared temp-table tgl
    field txb as char
    field gl as inte
    field gl4 as inte
    field gl7 as inte
    field gl-des as char
    field crc as inte
    field sum as deci /*Если задается отчетная дата - остаток за дату*/
    field sum_crcpro as deci /*Если задается отчетная дата - остаток за дату*/
    field sum_beg as deci /*Если задается отчетный период - остаток на начало периода*/
    field sum_end as deci /*Если задается отчетный период - остаток на конец периода*/
    field type as char
    field sub-type as char
    field totlev as inte
    field totgl as inte
    field level as inte
    field code as char
    field grp as inte
    field acc as char
    field acc-des as char
    field geo as char
index idx1 is primary gl7
index idx2 txb ascending
           sub-type ascending
           acc ascending
           level ascending
index idx3 sub-type ascending
           gl ascending
index idx4 sub-type ascending
index idx5 txb ascending
           sub-type ascending
           gl4 ascending.

def {1} shared temp-table t-wrk
    field txb as char
    field namebnk as char
    field sub as char
    field acc as char
    field cif as char /*CIF-код клиента*/
    field type as char /*Тип клиента - B - юридическое лицо, P - физическое лицо*/
    field geo as char /*Гео код*/
    field cgr as inte /*Текущая группа клиента*/
    field cifloncode as char /*Код заемщика*/
    field codfr_lnopf as char /*В справочнике - Организационно-правовая форма хозяйствования - ОПФ*/
    field cgrname as char
    field clientname as char
    field aaa as char
    field poolId as char /*Код пула по МСФО*/
    field grp as inte
    field lcnt as char /*№ Договора*/
    field objekts as char /*Объект кредитования*/
    field rdt as date /*Дата регистрации*/
    field duedt as date /*Дата окончания действия*/
    field rdt_1 as date /*дата открытия после пролонгации*/
    field duedt_1 as date /*дата закрытия после пролонгации*/
    field rdt_2 as date /*Дата начала купона,ценные бумаги*/
    field duedt_2 as date /*Дата погашения купона,ценные бумаги*/
    field overdueDay_lev_7 as inte
    field overdueDay_lev_9 as inte
    field dnpogash as inte /*Количество дней до погашения*/
    field mtpogash as inte /*Количество до погашения в месяцах*/
    field codesrok as char /*Код срока оставшегося до погашения*/
    field classcateg as char /*Классификационная категория*/
    field dprolong as date /*Дата прологанции*/
    field do_vostr as deci /*До востребования*/
    field prem_his as deci
    field lnpmt as char /*Периодичность платежей для кредитов*/
    field lnpmt% as char /*Периодичность платежей для кредитов - %*/
    field per1-30 as deci
    field per31-90 as deci
    field per91-180 as deci
    field per181-365 as deci
    field per366-730 as deci
    field per731-1095 as deci
    field per1096-1825 as deci
    field per1826 as deci
    field days_7 as deci /*Т.З. № 1332*/
    field days_30 as deci /*Т.З. № 1332*/
    field days_60 as deci /*Т.З. № 1332*/
    field days_90 as deci /*Т.З. № 1332*/
    field days_180 as deci /*Т.З. № 1332*/
    field more_days as deci /*Т.З. № 1332*/
    field nin as char /*НИН,ценные бумаги*/
    field discount as deci
    field gua as char
    field lon as char
    field clmain as char
    field bal_1 as deci /*Если задается отчетная дата - остаток за дату*/
    field bal_1_beg as deci /*Если задается отчетный период - остаток на начало периода*/
    field bal_1_end as deci /*Если задается отчетный период - остаток на конец периода*/
    field bal_2 as deci
    field bal_7 as deci /*Если задается отчетная дата - остаток за дату*/
    field bal_7_beg as deci /*Если задается отчетный период - остаток на начало периода*/
    field bal_7_end as deci /*Если задается отчетный период - остаток на конец периода*/
    field bal_9 as deci
    field bal_49 as deci
    field bal_41 as deci
    field bal_42 as deci
    field bal_6 as deci
    field bal_36 as deci
    field bal_37 as deci
    field crc as inte
    field gl_4 as inte
    field gl_7 as inte
    field acc-des as char
    field bal_16 as deci /*Штрафы*/
    field obesdes as char /*Вид залога*/
    field sumgarant as deci /*Сумма гарантий*/
    field sumdepcrd as deci /*Сумма депозитов*/
    field obesall as deci /*Общее обеспечение*/
    field obessum_kzt as deci
    field obesall_lev19 as deci /*Общее обеспечение - уровень 19*/
    field neobesp as deci /*Необеспеченная часть*/
    field otrasl as char /*Отрасль экономики (ОКЭД)*/
    field lonstat as inte /*Классификация займа*/
    field apz as char /*Описание классификации займа*/
    field codeuse as char /*Код целевого использования*/
    field prcKfn as deci /*Процент резерва КФН*/
    field codeclass as char /*Разделение по классификации Т.З.№ 1218*/
    field procmsfo as deci /*Процент резерва МСФО Т.З. № 1227*/
    field orienofloan as char /*Отраслевая направленность займа*/
    field attribute as char /*Признак связанности лиц с банком особыми отношениями*/
index idx1 is primary txb ascending
                      sub ascending
                      acc ascending
index idx2 sub ascending
index idx3 txb ascending
           sub ascending
           lon ascending.

def {1} shared temp-table t-gldy
    field gl_4 as inte
    field gl as inte
    field txb as char
    field balkzt as deci
    field balkzt_beg as deci
    field balkzt_end as deci
index idx1 is primary gl ascending
                      txb ascending.

def {1} shared temp-table t-TmpRep
    field txb as char
    field namebnk as char
    field jh as inte
    field whn as date
    field trx as char
    field D_gl4 as inte
    field D_gl as inte
    field D_gl7 as inte
    field D_gldes as char
    field D_geo as char
    field D_acc as char
    field D_crc as inte
    field D_cgrname as char
    field C_gl4 as inte
    field C_gl as inte
    field C_gl7 as inte
    field C_gldes as char
    field C_geo as char
    field C_acc as char
    field C_crc as inte
    field C_cgrname as char
    field KOd as char
    field KBe as char
    field KNP as char
    field amt as deci
    field amtkzt as deci
    field rem as char
    field crcrate as deci
index idx1 is primary txb ascending
                      jh ascending
index idx2 txb ascending
           jh ascending
           D_gl ascending
           C_gl ascending
           amt ascending.


