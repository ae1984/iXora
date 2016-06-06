/* lnaud_rep.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Графики погашения по кредитному портфелю
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12-26
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def var d1 as date no-undo.
def var d0 as date no-undo.
def var d2 as date no-undo.
def var i  as inte no-undo.
def var n  as inte no-undo.
def var k  as inte no-undo.
def var v-mon  as inte.
def var v-year as inte.
def var ndate  as date.
def var cntsum as decimal no-undo extent 19.
def new shared var v-reptype as integer no-undo.
v-reptype = 1.

def new shared temp-table wrk no-undo
    field bank as char
    field gl like lon.gl
    field name as char
    field schet_gk as char
    field cif like lon.cif
    field lon like lon.lon
    field grp like lon.grp
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
    field rezprc_afn as deci
    field rezsum_afn as deci
    field rezsum_od as deci
    field rezsum_prc as deci
    field rezsum_pen as deci
    field rezsum_msfo as deci
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
    field amtmes as deci extent 250 /*162*/ /*165*/ /*180*/
    field amtmes% as deci extent 250 /*162*/ /*165*/ /*180*/
    index ind is primary bank cif.


d0 = date(month(g-today),1,year(g-today)).
d2 = date(month(g-today),1,year(g-today) + 15).
d1 = g-today.
update d1 label ' С ' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") d2 label ' По ' format '99/99/9999' skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - МСБ, 5 - все"
       skip with side-label row 5 centered frame dat.

n = trunc((d2 - d1) / 30,0).

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

def new shared var v-pool as char no-undo extent 9.
def new shared var v-poolName as char no-undo extent 9.
def new shared var v-poolId as char no-undo extent 9.

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
v-pool[7] = "10,14,15,24,25,50,54,55,64,65".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-pool[8] = "10,14,15,24,25,50,54,55,64,65".
v-poolName[8] = "Инидивид. МСБ".
v-poolId[8] = "individ-msb".
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk2.
end.
if connected ("txb") then disconnect "txb".

v-sum_msb = round(v-sum_msb / 20,2).
{r-brfilial.i &proc = "lnaud_rep1(d1)"}

define stream m-out.
output stream m-out to lnaudit.htm.
put stream m-out unformatted "<html><head><title>Портфель</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>METROCOMBANK</h3><br>" skip.
put stream m-out unformatted "<h3>КРЕДИТНЫЙ ПОРТФЕЛЬ</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет на " string(d1) "</h3><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N бал. счета</td>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Пул МСФО</td>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N договора<BR>банк. займа</td>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Объект<BR>кредитования</td>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>кредита</td>"
/*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>выдачи</td>"
/*11*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок<BR>погашения</td>"
/*12*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>пролонгации</td>"
/*13*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в тенге)</td>"
/*14*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. ОД(в тенге)</td>"
/*15*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<BR>(в тенге)</td>"
/*16*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %<BR>(в тенге)</td>"
/*16*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дисконт<BR>по займам</td>"
/*17*/                  "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва АФН</td>"
/*18*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Резерв<BR>АФН (KZT)</td>"
/*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО ОД,<BR>(KZT)</td>"
/*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО %%,<BR>(KZT)</td>"
/*21*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО Пеня,<BR>(KZT)</td>"
/*22*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общая сумма резерва МСФО,<BR>(KZT)</td>"
/*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Истор.<br>ставка</td>"
/*24*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Амортизация<BR>дисконта</td>" .

do i = 1 to n:
    v-year = year(d1).
    v-mon = month(d1) + i.
    if v-mon >= 12 then do:
        k = trunc((v-mon - 1)/ 12,0).
        v-year = v-year + k.
    end.
    if v-mon mod 12 <> 0 then v-mon = v-mon - trunc(v-mon / 12 , 0) * 12.
    else v-mon = 12.
    ndate = date(v-mon,1,v-year).
    put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">" string(ndate,'99.99.9999') " OD</td>".
end.

do i = 1 to n:
    v-year = year(d1).
    v-mon = month(d1) + i.
    if v-mon >= 12 then do:
        k = trunc((v-mon - 1)/ 12,0).
        v-year = v-year + k.
    end.
    if v-mon mod 12 <> 0 then v-mon = v-mon - trunc(v-mon / 12 , 0) * 12.
    else v-mon = 12.
    ndate = date(v-mon,1,v-year).
    put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">" string(ndate,'99.99.9999') " %%</td>".
end.

put stream m-out unformatted  "</tr>" skip.

for each wrk no-lock break by wrk.bank by wrk.cif:

  if first-of(wrk.bank) then put stream m-out unformatted "<tr style=""font:bold""><td colspan=40>" wrk.bank "</td></tr>".
  find first crc where crc.crc = wrk.crc no-lock no-error.

  put stream m-out unformatted
            "<tr>" skip
/*1 */            "<td align=""center"">" wrk.schet_gk "</td>" skip
/*2 */            "<td>" wrk.name "</td>" skip
/*3 */            "<td>" wrk.cif "</td>" skip
/*4 */            "<td>" wrk.bankn "</td>" skip
/*5 */            "<td>" wrk.pooln "</td>" skip
/*6 */            "<td>" wrk.grp "</td>" skip
/*7 */            "<td>&nbsp;" wrk.num_dog "</td>" skip
/*8 */            "<td>" wrk.tgt "</td>" skip
/*9 */            "<td align=""center"">" crc.code "</td>" skip
/*10*/            "<td>" wrk.rdt format "99/99/9999" "</td>" skip
/*11*/            "<td>" wrk.duedt format "99/99/9999" "</td>" skip
/*12*/            "<td>" wrk.dprolong format "99/99/9999" "</td>" skip
/*13*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*14*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*15*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*16*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*16*/            "<td align=""right"">" replace(trim(string(wrk.zam_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*17*/            "<td align=""right"">" replace(trim(string(wrk.rezprc_afn,'>>9.99')),'.',',') "</td>" skip
/*18*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_afn,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*19*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*20*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*21*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*22*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_msfo,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*23*/            "<td align=""right"">" replace(trim(string(wrk.prem_his,'>>9.99')),'.',',') "</td>" skip
/*24*/            "<td align=""right"">" replace(trim(string(wrk.amr_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>".

    do i = 1 to n:
        put stream m-out unformatted
        "<td align=""right"">" replace(trim(string(wrk.amtmes[i],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    end.
    do i = 1 to n:
        put stream m-out unformatted
        "<td align=""right"">" replace(trim(string(wrk.amtmes%[1],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    end.

    put stream m-out unformatted "</tr>" skip.

  /*cntsum[1]  = cntsum[1]  + wrk.opnamt_kzt.*/
  cntsum[2]  = cntsum[2]  + wrk.ostatok_kzt.
  cntsum[3]  = cntsum[3]  + wrk.prosr_od_kzt.
  /*cntsum[4]  = cntsum[4]  + wrk.ind_od_kzt.*/
  cntsum[5]  = cntsum[5]  + wrk.nach_prc_kzt.
  /*cntsum[6]  = cntsum[6]  + wrk.prosr_prc_kzt.
  cntsum[7]  = cntsum[7]  + wrk.ind_prc_kzt.
  cntsum[8]  = cntsum[8]  + wrk.obessum_kzt.
  cntsum[9]  = cntsum[9]  + wrk.sumgarant.
  cntsum[10] = cntsum[10] + wrk.sumdepcrd.
  cntsum[11] = cntsum[11] + wrk.obesall.
  cntsum[12] = cntsum[12] + wrk.obesall_lev19.
  cntsum[13] = cntsum[13] + wrk.neobesp.*/
  cntsum[16] = cntsum[16] + wrk.rezsum_afn.
  cntsum[14] = cntsum[14] + wrk.rezsum_msfo.
  /*cntsum[15] = cntsum[15] + wrk.prosr_prc_zabal.
  cntsum[17] = cntsum[17] + wrk.penalty_zabal.
  cntsum[18] = cntsum[18] + wrk.pol_prc_kzt.
  cntsum[19] = cntsum[19] + wrk.penalty_otsr.*/

end. /* for each wrk */

/*put stream m-out unformatted
          "<tr align=""right"" style=""font:bold""><td colspan=14></td>" skip
          "<td>" replace(trim(string(cntsum[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=3></td>" skip
          "<td>" replace(trim(string(cntsum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=6></td>" skip
          "<td>" replace(trim(string(cntsum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>"
          "<td>" replace(trim(string(cntsum[18],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>"
          "<td>" replace(trim(string(cntsum[15],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=2></td>" skip
          "<td>" replace(trim(string(cntsum[17],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[19],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[11],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[12],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[13],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=2></td>" skip
          "<td>" replace(trim(string(cntsum[16],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=3></td>" skip
          "<td>" replace(trim(string(cntsum[14],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td> <td></td> <td></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td>" skip
          "</tr>" skip.*/

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin lnaudit.htm excel.
