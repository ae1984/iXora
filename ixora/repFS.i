/* repFS.i
 * MODULE
        отчеты
 * DESCRIPTION
        Описание стандартных переменных и параметров для отчетов ФС
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        27/12/2012 sayat (id01143)
 * CHANGES
        24/05/2013 sayat(id01143) - переименована таблица wrk в wrkFS ТЗ 1303 от 01/03/2012 "Автоматизация отчетов «Сведения о займах, по которым имеется просроченная задолженность по основному долгу и (или) начисленному вознаграждению, по отраслям и условные и возможные обязательства, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности» ФС_ПЗО_МСФО
                   «Сведения о займах, выданных субъектам малого и среднего предпринимательства резидентам Республики Казахстан, по которым имеется просроченная задолженность по основному долгу и (или) начисленному вознаграждению, по отраслям и условные и возможные обязательства, а также о размере провизий (резервов) сформированных в соответствии с международными стандартами финансовой отчетности» ФС_ПЗО_СМП_МСФО"
*/



def {1} shared temp-table wrkFS no-undo
    field bank as char
    field gl as int
    field name as char
    field schet_gk as char
    field cif as char
    field lon as char
    field grp as int
    field clnsegm as char
    field pooln as char
    field bankn as char
    field crc as int
    field rdt as date
    field isdt as date
    field duedt as date
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
    field obessum_kzt as deci extent 10
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
    field num_dog as char
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
    field OKEDcif as char
    field OKEDlon as char
    field rezsum_afn41 as deci
    field tgtc as char
    field obescod as char
    field clmain as char
    field ciftype as char
    index ind is primary bank cif.
