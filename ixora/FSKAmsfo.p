/* FSKAmsfo.p
 * MODULE
        Отчетность
 * DESCRIPTION
        Отчет ФС_КА_МСФО
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
        19.06.2013 dmitriy - ТЗ 1345
 * BASES
        BANK COMM
 * CHANGES

*/

{global.i}
def var d1 as date no-undo.
def var cntsum as decimal no-undo extent 19.
def new shared var v-reptype as integer no-undo.
v-reptype = 5.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.

def new shared temp-table wrk no-undo
    field bank as char
    field gl like lon.gl
    field name as char
    field geo as char
    field schet_gk as char
    field cif like lon.cif
    field ciftype like cif.type
    field lon like lon.lon
    field grp like lon.grp
    field clnsegm as char
    field pooln as char
    field bankn as char
    field crc like crc.crc
    field rdt like lon.rdt
    field isdt as date
    field duedt like lon.duedt
    field dprolong as date
    field prolong as int
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field pogosh as deci
    field prosr_od as deci
    field dayc_od as int
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field ind_od_kzt as deci
    field pogashen as logi format "да/нет"
    field prem as deci
    field prem_his as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci
    field dayc_prc as int
    field ind_prc as deci
    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field pol_prc_kzt_all as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field ind_prc_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field penalty_otsr as deci
    field uchastie as logi format "да/нет"
    field obessum_kzt as deci
    field obesdes as char
    field sumgarant as deci
    field sumdepcrd as deci
    field obesall as deci
    field obesall_lev19 as deci
    field neobesp as deci
    field otrasl as char
    field otrasl1 as char
    field finotrasl as char
    field finotrasl1 as char
    field rezprc_afn as deci
    field rezsum_afn as deci
    field rezsum_od as deci
    field rezsum_prc as deci
    field rezsum_pen as deci
    field rezsum_msfo as deci
    field rezprc_msfo as deci
    field num_dog like loncon.lcnt  /* номер договора */
    field tgt   as char
    field dtlpay as date
    field lpaysum as deci
    field kdstsdes as char
    field kodd  as char
    field rate  as char
    field valdesc  as char
    field valdesc_ob  as char
    field dt  as date
    field rel as char
    field bal11 as deci
    field lneko as char
    field rezid as char
    field val as char
    field scode as char
    field dpnv as date
    field nvng as deci
    field amr_dk  as deci /*Амортизация дисконта*/
    field zam_dk  as deci /*Дисконт по займам*/
    field bal34 as deci
    field lnprod as char
    field napr as char
    field nsumkr as deci
    field nsumkr_kzt as deci
    field lonstat as int
    field statname as char
    field tgt_code as char
    field zcode as char
    index ind is primary bank cif.

def new shared temp-table wrk2 no-undo
    field nom      as int
    field name     as char
    field stat     as int
    field od-gl    as char
    field vozn-gl  as char
    field disc-gl  as char
    field korr-gl  as char
    field prov1-gl as char
    field prov2-gl as char
    field obj      as char
    field geo      as char

    field od       as deci extent 8
    field vozn     as deci extent 8
    field disc     as deci extent 8
    field korr     as deci extent 8
    field prov1    as deci extent 8
    field prov2    as deci extent 8
    field discamt  as deci extent 8
    field obespamt as deci extent 8.



def buffer b-wrk2 for wrk2.

def var file1 as char.

d1 = g-today.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
with side-label row 5 centered frame dat.

def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
    find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
    if avail crchis then d-rates[crc.crc] = crchis.rate[1].
    c-rates[crc.crc] = crc.rate[1].
end.

def new shared var v-sum_msb as deci no-undo.
def new shared var v-dt as date no-undo.
v-sum_msb = 0.
v-dt = d1.

def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.

def var ii as int.

def var v-rate as deci.
def var sum_od as deci.
def var sum_disc as deci.
def var sum_korr as deci.
def var sum_vozn as deci.
def var sum_prov1 as deci.
def var sum_prov2 as deci.

v-pool[1] = "27,67".
v-poolName[1] = "Ипотечные займы".
v-poolId[1] = "ipoteka".
v-pool[2] = "28,68".
v-poolName[2] = "Автокредиты".
v-poolId[2] = "auto".
v-pool[3] = "20,60".
v-poolName[3] = "Прочие потребительские кредиты".
v-poolId[3] = "flobesp".
v-pool[4] = "90,92".
v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
v-poolId[4] = "metro".
v-pool[5] = "81,82".
v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
v-poolId[5] = "sotr".
v-pool[6] = "16,26,56,66".
v-poolName[6] = "Метро-экспресс МСБ".
v-poolId[6] = "express-msb".
v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[8] = "Инидивид. МСБ".
v-poolId[8] = "individ-msb".
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".
v-pool[10] = "95,96".
v-poolName[10] = "Ипотека «Астана бонус»".
v-poolId[10] = "astana-bonus".

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk2.
end.
if connected ("txb") then disconnect "txb".

v-sum_msb = round(v-sum_msb / 20,2).

{FSKAmsfo.i}
{r-brfilial.i &proc = "FSKAmsfo2(d1)"}

run PrintRep.
run PrintShifr.

procedure PrintShifr:
    message "Формирование расшифровки по банковским займам..." .

    file1 = "fska_shifr.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
    "<HEAD>"                                          skip
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
    "<TR align=""center""><td colspan=""6"">Расшифровка к отчету ""Стандартные и классифицированные активы"" за " v-dt "</td></tr>"
    "<tr></tr>"
    "</TABLE>".

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.


    put unformatted
                          "<tr style=""font:bold"">"
        /*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N бал. счета</td>"
        /*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
        /*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Резидентство</td>"
        /*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Пул МСФО</td>"
        /*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
        /*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N договора<BR>банк. займа</td>"
        /*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Объект<BR>кредитования</td>"
        /*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>кредита</td>"
        /*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>выдачи</td>"
        /*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок<BR>погашения</td>"
        /*11*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>пролонгации</td>"
        /*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в тенге)</td>"
        /*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. ОД(в тенге)</td>"
        /*28*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<BR>(в тенге)</td>"
        /*29*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %<BR>(в тенге)</td>"
        /*33*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
        /*37*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид залога</td>"
        /*38*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма гарантий,<BR>тенге</td>"
        /*39*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма депозитов,<BR>тенге</td>"
        /*40*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общее<BR>обеспечение</td>"
        /*41*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общее обесп<BR>Уровень 19</td>"
        /*42*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Необеспеченная<BR>часть, тенге</td>"
        /*43*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Отрасль<BR>экономики</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Категория</td>"
        /*44*/                  "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва АФН</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Резерв<BR>АФН (KZT)</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва МСФО</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО ОД,<BR>(KZT)</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО %%,<BR>(KZT)</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО Пеня,<BR>(KZT)</td>"
        /*45*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общая сумма резерва МСФО,<BR>(KZT)</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Истор.<br>ставка</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Дисконт<BR>по займам</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Отраслевая<br>направленность займа</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Код целевого использования</td>"
                                "<td bgcolor=""#C0C0C0"" align=""center"">Код заемщика</td>"
                                "</tr>" skip.

        for each wrk no-lock break by wrk.bank by wrk.cif:
          find first crc where crc.crc = wrk.crc no-lock no-error.

          put unformatted
                    "<tr>" skip
        /*1 */            "<td align=""center"">" wrk.schet_gk "</td>" skip
        /*2 */            "<td>" wrk.name "</td>" skip
        /*3 */            "<td>" wrk.cif "</td>" skip
                          "<td>" wrk.geo "</td>" skip
                          "<td>" wrk.bank "</td>" skip
                          "<td>" wrk.pooln "</td>" skip
        /*5 */            "<td>" wrk.grp "</td>" skip
        /*6 */            "<td>&nbsp;" wrk.num_dog "</td>" skip
        /*7 */            "<td>" wrk.tgt "</td>" skip
        /*8 */            "<td align=""center"">" crc.code "</td>" skip
        /*9 */            "<td>" wrk.rdt format "99/99/9999" "</td>" skip
        /*10*/            "<td>" wrk.duedt format "99/99/9999" "</td>" skip
        /*11*/            "<td>" wrk.dprolong format "99/99/9999" "</td>" skip
        /*19*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*20*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*28*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*29*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*33*/            "<td align=""right"">" replace(trim(string(wrk.penalty,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*37*/            "<td>" wrk.obesdes "</td>" skip
        /*38*/            "<td align=""right"">" replace(trim(string(wrk.sumgarant,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*39*/            "<td align=""right"">" replace(trim(string(wrk.sumdepcrd,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*40*/            "<td align=""right"">" replace(trim(string(wrk.obesall,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*41*/            "<td align=""right"">" replace(trim(string(wrk.obesall_lev19,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*42*/            "<td align=""right"">" replace(trim(string(wrk.neobesp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*43*/            "<td align=""right"">" wrk.otrasl "</td>" skip
                          "<td align=""right"">" wrk.statname "</td>" skip
        /*44*/            "<td align=""right"">" replace(trim(string(wrk.rezprc_afn,'>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.rezsum_afn,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.rezprc_msfo,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        /*45*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.rezsum_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.rezsum_pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.rezsum_msfo,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.prem_his,'>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk.zam_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" wrk.napr "</td>" skip
                          "<td align=""right"">" wrk.tgt_code "</td>" skip
                          "<td align=""right"">" wrk.zcode "</td>" skip
                          "</tr>" skip.

          cntsum[1] = cntsum[1] + wrk.opnamt_kzt.
          cntsum[2] = cntsum[2] + wrk.ostatok_kzt.
          cntsum[3] = cntsum[3] + wrk.prosr_od_kzt.
          cntsum[4] = cntsum[4] + wrk.ind_od_kzt.

          cntsum[5] = cntsum[5] + wrk.nach_prc_kzt.
          cntsum[18] = cntsum[18] + wrk.pol_prc_kzt.
          cntsum[6] = cntsum[6] + wrk.prosr_prc_kzt.
          cntsum[7] = cntsum[7] + wrk.ind_prc_kzt.

          cntsum[8] = cntsum[8] + wrk.obessum_kzt.
          cntsum[9] = cntsum[9] + wrk.sumgarant.
          cntsum[10] = cntsum[10] + wrk.sumdepcrd.
          cntsum[11] = cntsum[11] + wrk.obesall.
          cntsum[12] = cntsum[12] + wrk.obesall_lev19.
          cntsum[13] = cntsum[13] + wrk.neobesp.
          cntsum[16] = cntsum[16] + wrk.rezsum_afn.
          cntsum[14] = cntsum[14] + wrk.rezsum_msfo.
          cntsum[15] = cntsum[15] + wrk.prosr_prc_zabal.
          cntsum[17] = cntsum[17] + wrk.penalty_zabal.
          cntsum[19] = cntsum[19] + wrk.penalty_otsr.

        end. /* for each wrk */

        put unformatted "</table>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.


procedure PrintRep:
    file1 = "FSKAmsfo.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
    "<HEAD>"                                          skip
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
    "<TR align=""center""><td colspan=""6"">Стандартные и классифицированные активы</td></tr>"
    "<tr></tr>"
    "</TABLE>".

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
    "<TR align=""center"" valign=""top"">"
    "<TD rowspan=""4"" bgcolor=""#CCCCCC"">№</TD>"
    "<TD rowspan=""4"" bgcolor=""#CCCCCC"">Активы</TD>"

    "<TD rowspan=""2"" colspan=""8"" bgcolor=""#CCCCCC"">Стандартные</TD>"
    "<TD colspan=""40"" bgcolor=""#CCCCCC"">Сомнительные</TD>"
    "<TD rowspan=""2"" colspan=""8"" bgcolor=""#CCCCCC"">Безнадежные (в случае начисления провизий в размере 100%)</TD>"
    "<TD rowspan=""2"" colspan=""8"" bgcolor=""#CCCCCC"">Всего</TD>"
    "</TR><TR>"

    "<TD colspan=""8"" align=""center"" bgcolor=""#CCCCCC"">Сомнительные 1 категории (в случае начисления провизий в размере до 5%)</TD>"
    "<TD colspan=""8"" align=""center"" bgcolor=""#CCCCCC"">Сомнительные 2 категории (в случае начисления провизий в размере от 5% до 10%)</TD>"
    "<TD colspan=""8"" align=""center"" bgcolor=""#CCCCCC"">Сомнительные 3 категории (в случае начисления провизий в размере от 10% до 20%)</TD>"
    "<TD colspan=""8"" align=""center"" bgcolor=""#CCCCCC"">Сомнительные 4 категории (в случае начисления провизий в размере от 20% до 25%)</TD>"
    "<TD colspan=""8"" align=""center"" bgcolor=""#CCCCCC"">Сомнительные 5 категории (в случае начисления провизий в размере от 25% до 50%)</TD>"

    "</TR><TR>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Основной долг</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконт, премия</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Начисленное вознаграждение</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Положительная/отрицательная корректировка</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Дисконтированная (приведенная) стоимость будущих денежных потоков/стоимость, ожидаемая к получению</TD>"
    "<TD rowspan=""2"" bgcolor=""#CCCCCC"">Справочно: стоимость обеспечения включаемая в расчет</TD>"
    "<TD colspan=""2"" align=""center"" bgcolor=""#CCCCCC"">Провизии</TD>"

    "</TR><TR>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По основному долгу</TD>"
    "<TD align=""center"" bgcolor=""#CCCCCC"">По начисленному вознаграждению</TD>"

    "</TR><TR>"
    "<TD align=""center""></TD>"
    "<TD align=""center""></TD>"
    "<TD align=""center"">1</TD>"
    "<TD align=""center"">2</TD>"
    "<TD align=""center"">3</TD>"
    "<TD align=""center"">4</TD>"
    "<TD align=""center"">5</TD>"
    "<TD align=""center"">6</TD>"
    "<TD align=""center"">7</TD>"
    "<TD align=""center"">8</TD>"
    "<TD align=""center"">9</TD>"
    "<TD align=""center"">10</TD>"
    "<TD align=""center"">11</TD>"
    "<TD align=""center"">12</TD>"
    "<TD align=""center"">13</TD>"
    "<TD align=""center"">14</TD>"
    "<TD align=""center"">15</TD>"
    "<TD align=""center"">16</TD>"
    "<TD align=""center"">17</TD>"
    "<TD align=""center"">18</TD>"
    "<TD align=""center"">19</TD>"
    "<TD align=""center"">20</TD>"
    "<TD align=""center"">21</TD>"
    "<TD align=""center"">22</TD>"
    "<TD align=""center"">23</TD>"
    "<TD align=""center"">24</TD>"
    "<TD align=""center"">25</TD>"
    "<TD align=""center"">26</TD>"
    "<TD align=""center"">27</TD>"
    "<TD align=""center"">28</TD>"
    "<TD align=""center"">29</TD>"
    "<TD align=""center"">30</TD>"
    "<TD align=""center"">31</TD>"
    "<TD align=""center"">32</TD>"
    "<TD align=""center"">33</TD>"
    "<TD align=""center"">34</TD>"
    "<TD align=""center"">35</TD>"
    "<TD align=""center"">36</TD>"
    "<TD align=""center"">37</TD>"
    "<TD align=""center"">38</TD>"
    "<TD align=""center"">39</TD>"
    "<TD align=""center"">40</TD>"
    "<TD align=""center"">41</TD>"
    "<TD align=""center"">42</TD>"
    "<TD align=""center"">43</TD>"
    "<TD align=""center"">44</TD>"
    "<TD align=""center"">45</TD>"
    "<TD align=""center"">46</TD>"
    "<TD align=""center"">47</TD>"
    "<TD align=""center"">48</TD>"
    "<TD align=""center"">49</TD>"
    "<TD align=""center"">50</TD>"
    "<TD align=""center"">51</TD>"
    "<TD align=""center"">52</TD>"
    "<TD align=""center"">53</TD>"
    "<TD align=""center"">54</TD>"
    "<TD align=""center"">55</TD>"
    "<TD align=""center"">56</TD>"
    "<TD align=""center"">57</TD>"
    "<TD align=""center"">58</TD>"
    "<TD align=""center"">59</TD>"
    "<TD align=""center"">60</TD>"
    "<TD align=""center"">61</TD>"
    "<TD align=""center"">62</TD>"
    "<TD align=""center"">63</TD>"
    "<TD align=""center"">64</TD>"

    "</TR>".

    /* Для активов */
    for each wrk2 where lookup(string(wrk2.nom),"1,2,4,5,25,26,27,28,29,30,31") > 0 no-lock:
        sum_od = 0. sum_disc = 0. sum_vozn = 0. sum_korr = 0. sum_prov1 = 0. sum_prov2 = 0.

        if wrk2.geo = "" then do:
            for each tgl no-lock:
                if lookup(string(tgl.gl4),wrk2.od-gl) > 0 then sum_od = sum_od + tgl.sum.
                if lookup(string(tgl.gl4),wrk2.vozn-gl) > 0 then sum_vozn = sum_vozn + tgl.sum.
                if lookup(string(tgl.gl4),wrk2.disc-gl) > 0 then sum_disc = sum_disc + tgl.sum.
                if lookup(string(tgl.gl4),wrk2.korr-gl) > 0 then sum_korr = sum_korr + tgl.sum.
                if lookup(string(tgl.gl4),wrk2.prov1-gl) > 0 then do:
                    sum_prov1 = sum_prov1 + tgl.sum.
                    sum_prov2 = sum_prov2 + tgl.sum.
                end.
            end.
        end.

        if wrk2.geo <> "" then do:
            for each tgl no-lock:
                if lookup(substr(string(tgl.gl7),1,5),wrk2.od-gl) > 0 then sum_od = sum_od + tgl.sum.
                if lookup(substr(string(tgl.gl7),1,5),wrk2.vozn-gl) > 0 then sum_vozn = sum_vozn + tgl.sum.
                if lookup(substr(string(tgl.gl7),1,5),wrk2.disc-gl) > 0 then sum_disc = sum_disc + tgl.sum.
                if lookup(substr(string(tgl.gl7),1,5),wrk2.korr-gl) > 0 then sum_korr = sum_korr + tgl.sum.
                if lookup(substr(string(tgl.gl7),1,5),wrk2.prov1-gl) > 0 then do:
                    sum_prov1 = sum_prov1 + tgl.sum.
                    sum_prov2 = sum_prov2 + tgl.sum.
                end.
            end.
        end.

        do transaction:
            wrk2.od[1] = sum_od.
            wrk2.vozn[1] = sum_vozn.
            wrk2.disc[1] = sum_disc.
            wrk2.korr[1] = sum_korr.
            wrk2.prov1[1] = sum_prov1.
            wrk2.prov2[1] = sum_prov2.
        end.
    end.

    /* Для займов */
    for each wrk no-lock:
        if wrk.rezprc_msfo = 0 then run calc_value (1). /*Стандартные*/
        if wrk.rezprc_msfo > 0 and wrk.rezprc_msfo <= 5.01 then run calc_value (2). /*Сомнительные 1 категории*/
        if wrk.rezprc_msfo > 5.01 and wrk.rezprc_msfo <= 10.01 then run calc_value (3). /*Сомнительные 2 категории*/
        if wrk.rezprc_msfo > 10.01 and wrk.rezprc_msfo <= 20.01 then run calc_value (4). /*Сомнительные 3 категории*/
        if wrk.rezprc_msfo > 20.01 and wrk.rezprc_msfo <= 25.01 then run calc_value (5). /*Сомнительные 4 категории*/
        if wrk.rezprc_msfo > 25.01 and wrk.rezprc_msfo <= 50.01 then run calc_value (6). /*Сомнительные 5 категории*/
        if wrk.rezprc_msfo > 50.01 then run calc_value (7). /*Безнадежные*/
    end.

    run calc_sum.

    for each wrk2 no-lock:
        wrk2.od[8] = wrk2.od[1] + wrk2.od[2] + wrk2.od[3] + wrk2.od[4] + wrk2.od[5] + wrk2.od[6] + wrk2.od[7] .
        wrk2.vozn[8] = wrk2.vozn[1] + wrk2.vozn[2] + wrk2.vozn[3] + wrk2.vozn[4] + wrk2.vozn[5] + wrk2.vozn[6] + wrk2.vozn[7] .
        wrk2.disc[8] = wrk2.disc[1] + wrk2.disc[2] + wrk2.disc[3] + wrk2.disc[4] + wrk2.disc[5] + wrk2.disc[6] + wrk2.disc[7] .
        wrk2.korr[8] = wrk2.korr[1] + wrk2.korr[2] + wrk2.korr[3] + wrk2.korr[4] + wrk2.korr[5] + wrk2.korr[6] + wrk2.korr[7] .
        wrk2.prov1[8] = wrk2.prov1[2] + wrk2.prov1[3] + wrk2.prov1[4] + wrk2.prov1[5] + wrk2.prov1[6] + wrk2.prov1[7] .
        wrk2.prov2[8] = wrk2.prov2[2] + wrk2.prov2[3] + wrk2.prov2[4] + wrk2.prov2[5] + wrk2.prov2[6] + wrk2.prov2[7] .
        wrk2.discamt[8] = wrk2.od[8] +  wrk2.vozn[8] + wrk2.disc[8] - wrk2.prov1[8] - wrk2.prov2[8].
        wrk2.obespamt[8] = wrk2.obespamt[2] + wrk2.obespamt[3] + wrk2.obespamt[4] + wrk2.obespamt[5] + wrk2.obespamt[6] + wrk2.obespamt[7] .
    end.

    for each wrk2 no-lock:
        put unformatted
        "<TR>"
        "<TD align=""center"">" wrk2.nom "</TD>"
        "<TD align=""center"">" wrk2.name "</TD>"

        "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.od[1], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.disc[1], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.vozn[1], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.korr[1], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">"  "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">"  "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">"  "</TD>"
        "<TD align=""center"" bgcolor=""#CCFFFF"">"  "</TD>".

        do ii = 2 to 7:
            if ii mod 2 = 0 then do:
                 put unformatted
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.od[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.disc[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.vozn[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.korr[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.od[ii] + wrk2.disc[ii] + wrk2.vozn[ii] - wrk2.prov1[ii] - wrk2.prov2[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.obespamt[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.prov1[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.prov2[ii], 2)), ".", ",") "</TD>".
            end.
            else do:
                 put unformatted
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.od[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.disc[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.vozn[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.korr[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.od[ii] + wrk2.disc[ii] + wrk2.vozn[ii] - wrk2.prov1[ii] - wrk2.prov2[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.obespamt[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.prov1[ii], 2)), ".", ",") "</TD>"
                "<TD align=""center"" bgcolor=""#CCFFFF"">" replace(string(round(wrk2.prov2[ii], 2)), ".", ",") "</TD>".
            end.
        end.

        put unformatted
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.od[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.disc[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.vozn[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.korr[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.discamt[2] + wrk2.discamt[3] + wrk2.discamt[4] + wrk2.discamt[5] + wrk2.discamt[6] + wrk2.discamt[7], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.obespamt[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.prov1[8], 2)), ".", ",") "</TD>"
        "<TD align=""center"" bgcolor=""#FFFFCC"">" replace(string(round(wrk2.prov2[8], 2)), ".", ",") "</TD>".

         put unformatted "</TR>".
    end.

    put unformatted
    "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).

end procedure.

procedure calc_value:
    def input parameter p-kat as int.

    def var v-sum as deci extent 6.

    /*строка 6*/
            /* 6; 15 */
            if wrk.zcode = "6" and wrk.tgt_code = "15" then do:
                find first wrk2 where wrk2.nom = 6 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 7*/
            /* 6; 15 */
            if wrk.zcode = "6" and wrk.tgt_code = "15" and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 7 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 8 - пустая*/

    /*строка 9 - сумма по физикам*/
            if wrk.ciftype = "P" then do:
                find first wrk2 where wrk2.nom = 9 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 10 - сумма по физикам резидентам*/
            if wrk.ciftype = "P" and wrk.geo = "21" then do:
                find first wrk2 where wrk2.nom = 10 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 11*/
            /* 9; 11 */
            if wrk.zcode = "9" and wrk.tgt_code = "11" then do:
                find first wrk2 where wrk2.nom = 11 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 12*/
            /* 9; 11 */
            if wrk.zcode = "9" and wrk.tgt_code = "11" and wrk.napr = "автотранспорт" then do:
                find first wrk2 where wrk2.nom = 12 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 13*/
            /* 9; 13 */
            if wrk.zcode = "9" and wrk.tgt_code = "13" and wrk.napr = "ипотечные жилищные займы (недвижимость залог)" then do:
                find first wrk2 where wrk2.nom = 13 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 14*/
            /* 9; 13 */
            if wrk.zcode = "9" and wrk.tgt_code = "13" and wrk.napr = "ипотечные жилищные займы (недвижимость залог)" then do:
                find first wrk2 where wrk2.nom = 14 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 15*/

    /*строка 16*/
            if wrk.ciftype = "P" and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 16 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.


    /*строка 17*/
            /* 9; 11 */
            if wrk.zcode = "9" and wrk.tgt_code = "11" and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 17 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 18*/
            /* 9; 11 */
            if wrk.zcode = "9" and wrk.tgt_code = "11" and wrk.napr = "автотранспорт"  and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 18 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 19*/
            /* 9; 13 */
            if wrk.zcode = "9" and wrk.tgt_code = "13" and wrk.napr = "ипотечные жилищные займы (недвижимость залог)"  and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 19 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 20*/
            /* 9; 13 */
            if wrk.zcode = "9" and wrk.tgt_code = "13" and wrk.napr = "ипотечные жилищные займы (недвижимость залог)"  and wrk.geo = "22" then do:
                find first wrk2 where wrk2.nom = 20 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 21*/
    /*строка 22*/

    /*строка 23*/
            /* 23; 13,15 */
            if wrk.zcode = "23" and (wrk.tgt_code = "13" or wrk.tgt_code = "15") then do:
                find first wrk2 where wrk2.nom = 23 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.

    /*строка 24*/
            /* 24; 13,15 */
            if wrk.zcode = "24" and (wrk.tgt_code = "13" or wrk.tgt_code = "15") then do:
                find first wrk2 where wrk2.nom = 24 no-lock no-error.
                if avail wrk2 then
                do transaction:
                    wrk2.od[p-kat] = wrk2.od[p-kat] + wrk.ostatok_kzt.
                    wrk2.vozn[p-kat] = wrk2.vozn[p-kat] + wrk.nach_prc_kzt.
                    wrk2.disc[p-kat] = wrk2.disc[p-kat] + wrk.zam_dk.
                    wrk2.korr[p-kat] = wrk2.korr[p-kat].
                    wrk2.prov1[p-kat] = wrk2.prov1[p-kat] + wrk.rezsum_od + wrk.rezsum_pen.
                    wrk2.prov2[p-kat] = wrk2.prov2[p-kat] + wrk.rezsum_prc.
                    if p-kat <> 1 then wrk2.discamt[p-kat] = wrk2.discamt[p-kat] + (wrk2.od[p-kat] + wrk2.disc[p-kat] + wrk2.vozn[p-kat] - wrk2.prov1[p-kat] - wrk2.prov2[p-kat]).
                    wrk2.obespamt[p-kat] = wrk2.obespamt[p-kat] + wrk.obesall.
                end.
            end.
end procedure.

procedure calc_sum: /* Суммирующие строки */
    def var i as int.
    def var v-sum as deci extent 8.

    do i = 1 to 7:
        v-sum[1] = 0. v-sum[2] = 0. v-sum[3] = 0. v-sum[4] = 0. v-sum[5] = 0. v-sum[6] = 0. v-sum[7] = 0. v-sum[8] = 0.
        for each wrk2 where lookup(string(wrk2.nom), "23,24") > 0 no-lock:
            v-sum[1] = v-sum[1] + wrk2.od[i].
            v-sum[2] = v-sum[2] + wrk2.vozn[i].
            v-sum[3] = v-sum[3] + wrk2.disc[i].
            v-sum[4] = v-sum[4] + wrk2.korr[i].
            v-sum[5] = v-sum[5] + wrk2.prov1[i].
            v-sum[6] = v-sum[6] + wrk2.prov2[i].
            v-sum[7] = v-sum[7] + (wrk2.od[i] + wrk2.disc[i] + wrk2.vozn[i] - wrk2.prov1[i] - wrk2.prov2[i]).
            v-sum[8] = v-sum[8] + wrk2.obespamt[i].

        end.
        find first wrk2 where wrk2.nom = 22 exclusive-lock no-error.
        if avail wrk2 then
        do transaction:
            wrk2.od[i] = v-sum[1].
            wrk2.vozn[i] = v-sum[2].
            wrk2.disc[i] = v-sum[3].
            wrk2.korr[i] = v-sum[4].
            wrk2.prov1[i] = v-sum[5].
            wrk2.prov2[i] = v-sum[6].
            wrk2.discamt[i] = v-sum[7].
            wrk2.obespamt[i] = v-sum[8].
        end.

        v-sum[1] = 0. v-sum[2] = 0. v-sum[3] = 0. v-sum[4] = 0. v-sum[5] = 0. v-sum[6] = 0. v-sum[7] = 0. v-sum[8] = 0.
        for each wrk2 where lookup(string(wrk2.nom), "11,13,15") > 0 no-lock:
            v-sum[1] = v-sum[1] + wrk2.od[i].
            v-sum[2] = v-sum[2] + wrk2.vozn[i].
            v-sum[3] = v-sum[3] + wrk2.disc[i].
            v-sum[4] = v-sum[4] + wrk2.korr[i].
            v-sum[5] = v-sum[5] + wrk2.prov1[i].
            v-sum[6] = v-sum[6] + wrk2.prov2[i].
            v-sum[7] = v-sum[7] + (wrk2.od[i] + wrk2.disc[i] + wrk2.vozn[i] - wrk2.prov1[i] - wrk2.prov2[i]).
            v-sum[8] = v-sum[8] + wrk2.obespamt[i].
        end.
        find first wrk2 where wrk2.nom = 10 exclusive-lock no-error.
        if avail wrk2 then
        do transaction:
            wrk2.od[i] = v-sum[1].
            wrk2.vozn[i] = v-sum[2].
            wrk2.disc[i] = v-sum[3].
            wrk2.korr[i] = v-sum[4].
            wrk2.prov1[i] = v-sum[5].
            wrk2.prov2[i] = v-sum[6].
            wrk2.discamt[i] = v-sum[7].
            wrk2.obespamt[i] = v-sum[8].
        end.

        v-sum[1] = 0. v-sum[2] = 0. v-sum[3] = 0. v-sum[4] = 0. v-sum[5] = 0. v-sum[6] = 0. v-sum[7] = 0. v-sum[8] = 0.
        for each wrk2 where lookup(string(wrk2.nom), "10,16") > 0 no-lock:
            v-sum[1] = v-sum[1] + wrk2.od[i].
            v-sum[2] = v-sum[2] + wrk2.vozn[i].
            v-sum[3] = v-sum[3] + wrk2.disc[i].
            v-sum[4] = v-sum[4] + wrk2.korr[i].
            v-sum[5] = v-sum[5] + wrk2.prov1[i].
            v-sum[6] = v-sum[6] + wrk2.prov2[i].
            v-sum[7] = v-sum[7] + (wrk2.od[i] + wrk2.disc[i] + wrk2.vozn[i] - wrk2.prov1[i] - wrk2.prov2[i]).
            v-sum[8] = v-sum[8] + wrk2.obespamt[i].
        end.
        find first wrk2 where wrk2.nom = 9 exclusive-lock no-error.
        if avail wrk2 then
        do transaction:
            wrk2.od[i] = v-sum[1].
            wrk2.vozn[i] = v-sum[2].
            wrk2.disc[i] = v-sum[3].
            wrk2.korr[i] = v-sum[4].
            wrk2.prov1[i] = v-sum[5].
            wrk2.prov2[i] = v-sum[6].
            wrk2.discamt[i] = v-sum[7].
            wrk2.obespamt[i] = v-sum[8].
        end.

        v-sum[1] = 0. v-sum[2] = 0. v-sum[3] = 0. v-sum[4] = 0. v-sum[5] = 0. v-sum[6] = 0. v-sum[7] = 0. v-sum[8] = 0.
        for each wrk2 where lookup(string(wrk2.nom), "4,6,9,22") > 0 no-lock:
            v-sum[1] = v-sum[1] + wrk2.od[i].
            v-sum[2] = v-sum[2] + wrk2.vozn[i].
            v-sum[3] = v-sum[3] + wrk2.disc[i].
            v-sum[4] = v-sum[4] + wrk2.korr[i].
            v-sum[5] = v-sum[5] + wrk2.prov1[i].
            v-sum[6] = v-sum[6] + wrk2.prov2[i].
            v-sum[7] = v-sum[7] + (wrk2.od[i] + wrk2.disc[i] + wrk2.vozn[i] - wrk2.prov1[i] - wrk2.prov2[i]).
            v-sum[8] = v-sum[8] + wrk2.obespamt[i].
        end.
        find first wrk2 where wrk2.nom = 3 exclusive-lock no-error.
        if avail wrk2 then
        do transaction:
            wrk2.od[i] = v-sum[1].
            wrk2.vozn[i] = v-sum[2].
            wrk2.disc[i] = v-sum[3].
            wrk2.korr[i] = v-sum[4].
            wrk2.prov1[i] = v-sum[5].
            wrk2.prov2[i] = v-sum[6].
            wrk2.discamt[i] = v-sum[7].
            wrk2.obespamt[i] = v-sum[8].
        end.

        v-sum[1] = 0. v-sum[2] = 0. v-sum[3] = 0. v-sum[4] = 0. v-sum[5] = 0. v-sum[6] = 0. v-sum[7] = 0. v-sum[8] = 0.
        for each wrk2 where lookup(string(wrk2.nom), "1,3,25,28,30") > 0 no-lock:
            v-sum[1] = v-sum[1] + wrk2.od[i].
            v-sum[2] = v-sum[2] + wrk2.vozn[i].
            v-sum[3] = v-sum[3] + wrk2.disc[i].
            v-sum[4] = v-sum[4] + wrk2.korr[i].
            v-sum[5] = v-sum[5] + wrk2.prov1[i].
            v-sum[6] = v-sum[6] + wrk2.prov2[i].
            v-sum[7] = v-sum[7] + (wrk2.od[i] + wrk2.disc[i] + wrk2.vozn[i] - wrk2.prov1[i] - wrk2.prov2[i]).
            v-sum[8] = v-sum[8] + wrk2.obespamt[i].
        end.
        find first wrk2 where wrk2.nom = 32 exclusive-lock no-error.
        if avail wrk2 then
        do transaction:
            wrk2.od[i] = v-sum[1].
            wrk2.vozn[i] = v-sum[2].
            wrk2.disc[i] = v-sum[3].
            wrk2.korr[i] = v-sum[4].
            wrk2.prov1[i] = v-sum[5].
            wrk2.prov2[i] = v-sum[6].
            wrk2.discamt[i] = v-sum[7].
            wrk2.obespamt[i] = v-sum[8].
        end.
    end.
end procedure.

message "Отчет сформирован.". pause 2.