/* lnauditn.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Кредитный портфель для аудита новый (цикл по всем филиалам)
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
        26/11/2009 madiyar - скопировал из lnaudit.p с изменениями
 * BASES
        BANK COMM
 * CHANGES
        01/12/2009 galina - добавила Код клиента и Филиал
        27/01/2010 galina - берем курс из crchis по rdt
*/

{global.i}
def var d1 as date no-undo.
def var cntsum as decimal no-undo extent 18.
def var coun as integer no-undo.
def new shared var v-reptype as integer no-undo.
v-reptype = 1.

def new shared temp-table wrk no-undo
    field bank as char
    field bankn as char
    field cif as char
    field lon as char
    field grp as integer
    field num_dog as char  /* номер договора */
    field name as char
    field tgt as char
    field rdt as date
    field duedt as date
    field gl as integer
    field crc as integer
    field rate_rdt as deci /* new */
    field ostatok as deci
    field ostatok_kzt as deci
    field prem_init as deci /* new */
    field prem as deci /* check */
    field od_paid as deci /* new */
    field od_paid_kzt as deci /* new */
    field prolong as int
    field dprolong as date
    field dtprosr as date /* new */
    field pnlt as deci /* new */
    field prosr_od as deci
    field prosr_od_kzt as deci
    field nach_prc as deci
    field nach_prc_kzt as deci
    field pol_prc as deci
    field pol_prc_kzt as deci
    field prosr_prc as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field sum_prosr as deci /* new */
    field sum_prosr_kzt as deci /* new */
    field obesall_lev19 as deci
    field obesdes as char
    field rezsum as deci
    field rezprc as deci
    field otrasl as char
    field days2end as integer
    field uchastie as logi format "да/нет"
    index ind is primary bank name.


d1 = g-today.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 5, " Тип отчета - 1, 2, 3 или 4") help "1 - Юр, 2 - Физ, 3 - БД, 4 - все"
       skip with side-label row 5 centered frame dat.

def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.

{r-brfilial.i &proc = "lnauditn1(d1)"}

define stream m-out.
output stream m-out to lnaudit.htm.
put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3> TEXAKABANK</h3><br>" skip.
put stream m-out unformatted "<h3>КРЕДИТНЫЙ ПОРТФЕЛЬ</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет на " string(d1) "</h3><br><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                "<td rowspan=""2"">nn</td>"
                "<td rowspan=""2"">N договора</td>"
                "<td rowspan=""2"">Заемщик</td>"
                "<td rowspan=""2"">Код клиента</td>"
                "<td rowspan=""2"">Филиал</td>"
                "<td rowspan=""2"">Цель кредита</td>"
                "<td rowspan=""2"">Дата<br>выдачи</td>"
                "<td rowspan=""2"">Дата<br>погашения</td>"
                "<td rowspan=""2"">N баланс.<br>счета</td>"
                "<td rowspan=""2"">Валюта<br>кредита</td>"
                "<td rowspan=""2"">Вал. курс на<br>дату выдачи</td>"
                "<td colspan=""2"">Сумма ОД</td>"
                "<td rowspan=""2"">% ставка<br>(исходная)</td>"
                "<td rowspan=""2"">% ставка<br>(существ.)</td>"
                "<td rowspan=""2"">Оплач. ОД на<br>отч. дату, KZT</td>"
                "<td rowspan=""2"">Кол-во пролонгаций<br>с момента выдачи</td>"
                "<td colspan=""2"">Период пролонгации</td>"
                "<td rowspan=""2"">% ставка</td>"
                "<td rowspan=""2"">Сумма<br>пролонгации, KZT</td>"
                "<td rowspan=""2"">Дата<br>просрочки</td>"
                "<td rowspan=""2"">% пени</td>"
                "<td rowspan=""2"">Сумма<br>просрочки ОД, KZT</td>"
                "<td rowspan=""2"">Начисл. % за<br>отч. период, KZT</td>"
                "<td rowspan=""2"">Проценты к получ.<br>на отч. дату, KZT</td>"
                "<td rowspan=""2"">Просроч. %<br>на отч. дату, KZT</td>"
                "<td rowspan=""2"">% за<br>балансом, KZT</td>"
                "<td colspan=""2"">Сумма задолж. на отч. дату</td>"
                "<td rowspan=""2"">Сумма<br>залога, KZT</td>"
                "<td rowspan=""2"">Описание / тип<br>залога</td>"
                "<td rowspan=""2"">Счет<br>резерва</td>"
                "<td rowspan=""2"">Сумма резерва на<br>отч. дату, KZT</td>"
                "<td rowspan=""2"">% резерва<br>(Резерв / ОД)</td>"
                "<td rowspan=""2"">Индустриальный<br>сектор</td>"
                "<td rowspan=""2"">Геогр. регион<br>(страна)</td>"
                "<td rowspan=""2"">Кол-во дней до<br>срока погашения</td>"
                "<td rowspan=""2"">Связанная<br>сторона (Да/Нет)</td>"
                "</tr>" skip.

put stream m-out unformatted
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                "<td>Валюта</td>"
                "<td>KZT</td>"
                "<td>С даты</td>"
                "<td>По дату</td>"
                "<td>KZT</td>"
                "<td>Валюта</td>"
          "</tr>" skip.

coun = 0.
for each wrk no-lock break by wrk.bank by wrk.cif:

  if first-of(wrk.bank) then put stream m-out unformatted "<tr style=""font:bold""><td colspan=37>" wrk.bank "</td></tr>".
  find first crc where crc.crc = wrk.crc no-lock no-error.

  coun = coun + 1.

  put stream m-out unformatted
            "<tr>" skip
              "<td>" coun "</td>" skip
              "<td>&nbsp;" wrk.num_dog "</td>" skip
              "<td>" wrk.name "</td>" skip
              "<td>" wrk.cif "</td>" skip
              "<td>" wrk.bankn "</td>" skip
              "<td>" wrk.tgt "</td>" skip
              "<td>" wrk.rdt format "99/99/9999" "</td>" skip
              "<td>" wrk.duedt format "99/99/9999" "</td>" skip
              "<td align=""center"">" substring(string(wrk.gl),1,4) "</td>" skip
              "<td align=""center"">" crc.code "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.rate_rdt,'>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.ostatok,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prem_init,'>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prem,'>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.od_paid_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" wrk.prolong "</td>" skip
              "<td></td>" skip
              "<td>" wrk.dprolong format "99/99/9999" "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prem,'>>9.99')),'.',',') "</td>" skip
              "<td></td>" skip
              "<td>" if wrk.dtprosr <> ? then string(wrk.dtprosr,"99/99/9999") else '' "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.pnlt,'>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.pol_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.prosr_prc_zab_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.sum_prosr_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.sum_prosr,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.obesall_lev19,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td>" wrk.obesdes "</td>" skip
              "<td>&nbsp;142800, 142820</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.rezsum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk.rezprc,'>>9.99')),'.',',') "</td>" skip
              "<td>" wrk.otrasl "</td>" skip
              "<td>РК</td>" skip
              "<td>" wrk.days2end "</td>" skip
              "<td>" wrk.uchastie "</td>" skip
            "</tr>" skip.

  cntsum[1] = cntsum[1] + wrk.ostatok_kzt.
  cntsum[2] = cntsum[2] + wrk.od_paid_kzt.
  cntsum[3] = cntsum[3] + wrk.prosr_od_kzt.
  cntsum[4] = cntsum[4] + wrk.nach_prc_kzt.
  cntsum[5] = cntsum[5] + wrk.pol_prc_kzt.
  cntsum[6] = cntsum[6] + wrk.prosr_prc_kzt.
  cntsum[7] = cntsum[7] + wrk.prosr_prc_zab_kzt.
  cntsum[8] = cntsum[8] + wrk.sum_prosr_kzt.
  cntsum[9] = cntsum[9] + wrk.obesall_lev19.
  cntsum[10] = cntsum[10] + wrk.rezsum.

end. /* for each wrk */

put stream m-out unformatted
          "<tr align=""right"" style=""font:bold""><td colspan=10></td>" skip
          "<td>" replace(trim(string(cntsum[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=2></td>" skip
          "<td>" replace(trim(string(cntsum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=7></td>" skip
          "<td>" replace(trim(string(cntsum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=2></td>" skip
          "<td>" replace(trim(string(cntsum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=5></td>" skip
          "</tr>" skip.

put stream m-out "</table></body></html>" .
output stream m-out close.
hide message no-pause.

unix silent cptwin lnaudit.htm excel.
