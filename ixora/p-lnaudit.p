 /* p-lnaudit.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Кредитный портфель для аудита (цикл по всем филиалам) PUSH
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
        13.04.06 marinav переделан из lnaudit
 * CHANGES
        15/09/2006 madiyar - no-undo
        29/09/2006 madiyar - разделил на три отчета - юр, физ и бд
        31/10/2006 madiyar - добавил еще консолидированный
        11/05/2010 galina - добавила столбец "Статус КД"
*/

{global.i}
{push.i}
def var d1 as date no-undo.
def var cntsum as decimal extent 17 no-undo.

def new shared temp-table wrk no-undo
    field bank as char
    field gl like lon.gl
    field name as char
    field cif like lon.cif
    field lon like lon.lon
    field grp like lon.grp
    field bankn as char
    field crc like crc.crc
    field rdt like lon.rdt
    field duedt like lon.duedt
    field dprolong as date
    field prolong as int
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field prosr_od as deci
    field dayc_od as int
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field ind_od_kzt as deci
    field pogashen as logi format "да/нет"
    field prem as deci
    field nach_prc as deci
    field prosr_prc as deci
    field dayc_prc as int
    field ind_prc as deci
    field nach_prc_kzt as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field ind_prc_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field uchastie as logi format "да/нет"
    field obessum_kzt as deci
    field obesdes as char
    field sumgarant as deci
    field sumdepcrd as deci
    field obesall as deci
    field obesall_lev19 as deci
    field neobesp as deci
    field otrasl as char
    field rezprc like lonstat.prc
    field rezsum as deci
    field num_dog like loncon.lcnt  /* номер договора */
    field tgt as char
    field kdstsdes as char
    index ind is primary bank cif.

def temp-table wrkc like wrk.

d1 = vdt .

def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
def new shared var v-reptype as integer no-undo.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.regdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.

define stream m-out.
def var i as integer no-undo.

do i = 1 to 4:

    if i <> 4 then do:
      /*
      i=1 и i=2 - юр и физ собираются в таблице wrkc
      i=3 - БД собирается в wrk и при i=4 все записи из wrkc сливаются с БД в wrk
      */
      for each wrk: delete wrk. end.
      v-reptype = i.
      {r-branch.i &proc = "lnaudit1(d1)"}

      if i = 1 or i = 2 then do:
        for each wrk: create wrkc. buffer-copy wrk to wrkc. end.
      end.

    end.
    else do:
      for each wrkc: create wrk. buffer-copy wrkc to wrk. end.
    end.

    output stream m-out to value(entry(1,vfname,'.') + '-rep' + string(i,"9") + '.' + entry(2,vfname,'.')).
    put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<br><br><h3> TEXAKABANK</h3><br>" skip.
    put stream m-out unformatted "<h3>КРЕДИТНЫЙ ПОРТФЕЛЬ</h3><br>" skip.
    put stream m-out unformatted "<h3>Отчет на " string(d1) "</h3><br><br>" skip.

    put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                            "<tr style=""font:bold"">"
    /*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N бал<BR>счета</td>"
    /*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
    /*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
    /*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
    /*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
    /*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N договора<BR>банк. займа</td>"
    /*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Объект<BR>кредитования</td>"
    /*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>кредита</td>"
    /*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>выдачи</td>"
    /*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок<BR>погашения</td>"
    /*11*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>пролонгации</td>"
    /*12*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во<BR>пролонгаций</td>"
    /*13*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная<BR>сумма (в валюте)</td>"
    /*14*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная<BR>сумма (в тенге)</td>"
    /*15*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в валюте)</td>"
    /*16*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Просроченный<BR>ОД(в валюте)</td>"
    /*17*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней<BR>просрочки</td>"
    /*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в тенге)</td>"
    /*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. ОД(в тенге)</td>"
    /*21*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс. ОД</td>"
    /*22*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Погашен</td>"
    /*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Ставка</td>"
    /*24*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<BR>(в валюте)</td>"
    /*25*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %<BR>(в валюте)</td>"
    /*26*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней<BR>просрочки</td>"
    /*30*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные %<br>за балансом<br>(в валюте)</td>"

    /*28*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<BR>(в тенге)</td>"
    /*29*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %<BR>(в тенге)</td>"
    /*27*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс. %</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные %<br>за балансом<br>(в тенге)</td>"
    /*31*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс. %<BR>(в тенге)</td>"
    /*32*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Последняя дата<BR>уплаты %</td>"
    /*33*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
    /*34*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы начисленные<br>за балансом</td>"
    /*35*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Участие<BR>заинтер. стороны</td>"
    /*36*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма залога<BR>(без гарантий и депозитов), тенге</td>"
    /*37*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид залога</td>"
    /*38*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма гарантий,<BR>тенге</td>"
    /*39*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма депозитов,<BR>тенге</td>"
    /*40*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общее<BR>обеспечение</td>"
    /*41*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общее обесп<BR>Уровень 19</td>"
    /*42*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Необеспеченная<BR>часть, тенге</td>"
    /*43*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Отрасль<BR>экономики</td>"
    /*44*/                  "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва</td>"
    /*45*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма резерва,<BR>тенге</td></tr>" skip.

    cntsum = 0.
    for each wrk no-lock break by wrk.bank by wrk.cif:

      if first-of(wrk.bank) then put stream m-out unformatted "<tr style=""font:bold""><td colspan=40>" wrk.bank "</td></tr>".
      find first crc where crc.crc = wrk.crc no-lock no-error.
      put stream m-out unformatted
                "<tr>" skip
    /*1 */            "<td align=""center"">" substring(string(wrk.gl),1,4) "</td>" skip
    /*2 */            "<td>" wrk.name format "x(60)" "</td>" skip
    /*3 */            "<td>" wrk.cif "</td>" skip
    /*4 */            "<td>" wrk.bankn "</td>" skip
    /*5 */            "<td>" wrk.grp "</td>" skip
    /*6 */            "<td>&nbsp;" wrk.num_dog "</td>" skip
    /*7 */            "<td>" wrk.tgt "</td>" skip
    /*8 */            "<td align=""center"">" crc.code "</td>" skip
    /*9 */            "<td>" wrk.rdt format "99/99/9999" "</td>" skip
    /*10*/            "<td>" wrk.duedt format "99/99/9999" "</td>" skip
    /*11*/            "<td>" wrk.dprolong format "99/99/9999" "</td>" skip
    /*12*/            "<td align=""right"">" wrk.prolong "</td>" skip
    /*13*/            "<td align=""right"">" replace(trim(string(wrk.opnamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*14*/            "<td align=""right"">" replace(trim(string(wrk.opnamt_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*15*/            "<td align=""right"">" replace(trim(string(wrk.ostatok,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*16*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*17*/            "<td align=""right"">" wrk.dayc_od "</td>" skip
    /*19*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*20*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*21*/            "<td align=""right"">" replace(trim(string(wrk.ind_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*22*/            "<td align=""right"">" wrk.pogashen "</td>" skip
    /*23*/            "<td align=""right"">" replace(trim(string(wrk.prem,'>>9.99')),'.',',') "</td>" skip
    /*24*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*25*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*26*/            "<td align=""right"">" wrk.dayc_prc "</td>" skip
    /*30*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_zabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*28*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*29*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*27*/            "<td align=""right"">" replace(trim(string(wrk.ind_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.prosr_prc_zab_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*31*/            "<td align=""right"">" replace(trim(string(wrk.ind_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*32*/            "<td>" wrk.prcdt_last format "99/99/9999" "</td>" skip
    /*33*/            "<td align=""right"">" replace(trim(string(wrk.penalty,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*34*/            "<td align=""right"">" replace(trim(string(wrk.penalty_zabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*35*/            "<td>" wrk.uchastie "</td>" skip
    /*36*/            "<td align=""right"">" replace(trim(string(wrk.obessum_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*37*/            "<td>" wrk.obesdes format "x(40)" "</td>" skip
    /*38*/            "<td align=""right"">" replace(trim(string(wrk.sumgarant,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*39*/            "<td align=""right"">" replace(trim(string(wrk.sumdepcrd,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*40*/            "<td align=""right"">" replace(trim(string(wrk.obesall,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*41*/            "<td align=""right"">" replace(trim(string(wrk.obesall_lev19,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*42*/            "<td align=""right"">" replace(trim(string(wrk.neobesp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*43*/            "<td>" wrk.otrasl format "x(35)" "</td>" skip
    /*44*/            "<td align=""right"">" replace(trim(string(wrk.rezprc,'>>9.99')),'.',',') "</td>" skip
    /*45*/            "<td align=""right"">" replace(trim(string(wrk.rezsum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "</tr>" skip.

      cntsum[1] = cntsum[1] + wrk.opnamt_kzt.
      cntsum[2] = cntsum[2] + wrk.ostatok_kzt.
      cntsum[3] = cntsum[3] + wrk.prosr_od_kzt.
      cntsum[4] = cntsum[4] + wrk.ind_od_kzt.

      cntsum[5] = cntsum[5] + wrk.nach_prc_kzt.
      cntsum[6] = cntsum[6] + wrk.prosr_prc_kzt.
      cntsum[7] = cntsum[7] + wrk.ind_prc_kzt.

      cntsum[8] = cntsum[8] + wrk.obessum_kzt.
      cntsum[9] = cntsum[9] + wrk.sumgarant.
      cntsum[10] = cntsum[10] + wrk.sumdepcrd.
      cntsum[11] = cntsum[11] + wrk.obesall.
      cntsum[12] = cntsum[12] + wrk.obesall_lev19.
      cntsum[13] = cntsum[13] + wrk.neobesp.
      cntsum[14] = cntsum[14] + wrk.rezsum.
      cntsum[15] = cntsum[15] + wrk.prosr_prc_zabal.
      cntsum[17] = cntsum[17] + wrk.penalty_zabal.

    end. /* for each wrk */

    put stream m-out unformatted
              "<tr align=""right"" style=""font:bold""><td colspan=13></td>" skip
              "<td>" replace(trim(string(cntsum[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td colspan=3></td>" skip
              "<td>" replace(trim(string(cntsum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td colspan=6></td>" skip
              "<td>" replace(trim(string(cntsum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td></td>"
              "<td>" replace(trim(string(cntsum[15],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td colspan=2></td>" skip
              "<td>" replace(trim(string(cntsum[17],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td></td>" skip
              "<td>" replace(trim(string(cntsum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td></td>" skip
              "<td>" replace(trim(string(cntsum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[11],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[12],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" replace(trim(string(cntsum[13],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td colspan=2></td>" skip
              "<td>" replace(trim(string(cntsum[14],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "</tr>" skip.

    put stream m-out "</table></body></html>" .
    output stream m-out close.

end. /* do i = 1 to 4 */


vres = yes.

