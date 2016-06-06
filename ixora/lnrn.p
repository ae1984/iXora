/* lnrn.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Управленческий отчет по кредитному портфелю
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
        21/07/2009 madiyar - скопировал из lnaudit.p с изменениями
 * BASES
        BANK COMM
 * CHANGES
        31/07/2009 madiyar - консолидированный отчет в разрезе филиалов
        04/08/2009 galina - добавила столбцы по признакам клиента для физ.лиц
        04/09/2009 galina - добавила отчет по признакам клиента для физ лиц.
        16/11/2009 galina - добавила отчет по признакам клиента для физ лиц. для управленческой
        10/12/2009 galina - убрала отчет по фактическим дням просрочкам и фактические дни просрочки ОД и %%
        12/01/2010 madiyar - добавил сегмент и схему; исправил формат отчета
        28/01/2010 galina - добавила движимое и недвижимое имущество, счета в БВУ
        17/02/2010 madiyar - добавил начисл. %, ком. долг и сумму на счете
        02/06/2011 madiyar - дата выдачи, дата договора
        02/08/2011 dmitriy - добавлен столбец "Рейтинг клиента"
*/


{global.i}
def var d1 as date no-undo.
def var cntsum as decimal no-undo extent 10.
def new shared var v-reptype as integer no-undo.
v-reptype = 1.

def var v-sum as deci no-undo extent 10.

def new shared temp-table wrk1 no-undo
  field rep_id as int
  field bank as char
  field bank_name as char
  field id as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field polprc as deci /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  field polpen as deci /* полученные штрафы */
  index idx is primary rep_id bank id.

def new shared temp-table wrk no-undo
    field bank as char
    field gl like lon.gl
    field name as char
    field cif like lon.cif
    field lon like lon.lon
    field grp like lon.grp
    field crtype as char
    field plan as integer
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
    field prosr_od as deci

    field dayc_od as int
    field fdayc_od as int
    field fdayc_od2 as int

    field dayop as int
    field sumop as deci
    field mpayment as deci

    field n_prov as deci
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field prem as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci

    field aaabal as deci
    field ostatok_aaa as deci
    field comdolg as deci

    field dayc_prc as int
    field fdayc_prc as int

    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field penalty_pol as deci

    field rezprc like lonstat.prc
    field rezsum as deci
    field sumdohod as deci
    field finsost as char
    field rate as char
    field sxem_pog as char

    field num_dog like loncon.lcnt  /* номер договора */
          /*galina*/
    field rest as char
    field crpur as char
    field hwoker as char
    field nostn as char
    field indbus as char
    field realp as char
    field movp as char
    field acc as char
    field speni as deci
    field speni_bal as deci
    field openi as deci
    index ind is primary bank cif.

def new shared temp-table wrk2 no-undo
  field rep_id as int
  field priz_id as char
  field bank as char
  field bank_name as char
  field id as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  /*field polprc as deci*/ /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  /*field polpen as deci*/ /* полученные штрафы */
  index idx is primary rep_id priz_id bank id.

def new shared temp-table wrk4 no-undo
  field rep_id as int
  field priz_id as char
  field bank as char
  field bank_name as char
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  index idx is primary rep_id priz_id bank.

def temp-table wrk5 no-undo
  field rep_id as int
  field bank as char
  field bank_name as char
  /*field id as int*/
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  index idx is primary rep_id  bank.

def temp-table wrk3 no-undo
  field rep_id as int
  field bank as char
  field bank_name as char
  field id as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  index idx is primary rep_id  bank id.

def var j as integer no-undo.
def var d as integer no-undo.
def var k as integer no-undo.
def var v-bank as char no-undo.
def buffer b-wrk2 for wrk2.
def buffer b-wrk4 for wrk4.



def var i as integer no-undo.
def buffer b-wrk1 for wrk1.

def var gr as char extent 7 init ['Без просрочки','До 30 дней','31 - 60 дней','61 - 90 дней','91 - 180 дней','181 - 360 дней','> 360 дней'].

d1 = g-today.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 5, " Тип отчета - 1, 2, 3 или 4") help "1 - Юр, 2 - Физ, 3 - БД, 4 - все"
       skip with side-label row 5 centered frame dat.

def new shared var d-rates as deci no-undo extent 20.
for each crc no-lock:
    find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
    if avail crchis then d-rates[crc.crc] = crchis.rate[1].
end.

{r-brfilial.i &proc = "lnrn1(d1)"}

define stream m-out.

output stream m-out to lnaudit.htm.
put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>METROCOMBANK</h3><br>" skip.
put stream m-out unformatted "<h3>КРЕДИТНЫЙ ПОРТФЕЛЬ</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет на " string(d1) "</h3><br><br>" skip.

       put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид<br>кредита</td>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Схема</td>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<BR>кредита</td>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>договора</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Дата<BR>выдачи</td>"
/*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок<BR>погашения</td>"
/*14*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная<BR>сумма (в тенге)</td>"
/*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в тенге)</td>"
/*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. ОД(в тенге)</td>"

/*17*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней<BR>просрочки</td>"
                        /*"<td bgcolor=""#C0C0C0"" align=""center"">Факт. дней<BR>просрочки ОД</td>"*/
                        "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во проср.<BR>платежей</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Дней с<br>оплаты</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<BR>оплаты</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Ежемес.<BR>платеж</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Поступления<BR>на счет</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма на тек. счете<BR>(валюта кредита)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Необх<BR>провизии</td>"

/*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Ставка</td>"

/*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<br>(в тенге)</td>"

                        "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %% <BR> (в вал.кредита)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %% (в тенге)</td>"

/*26*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней<BR>просрочки %%</td>"
                        /*"<td bgcolor=""#C0C0C0"" align=""center"">Факт. дней<BR>просрочки %%</td>"*/
/*32*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Последняя дата<BR>уплаты %</td>"

/*33*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
/*34*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы начисленные<br>за балансом</td>"
/*34*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы<br>полученные</td>"

/*34*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Ком. долг<br>(на тек. момент)</td>"

/*44*/                  "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва</td>"
/*45*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма резерва,<BR>тенге</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма чистого,<BR> дохода</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Финансовое состояние <BR> на текущий день</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Рейтинг<br>клиента</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Схема погашения </td>" skip.
                        if v-reptype = 2 or v-reptype = 3 then put stream m-out unformatted
                        "<td bgcolor=""#C0C0C0"" align=""center"">Реструктуризация</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Цель кредита</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Наемный работник</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Нестандартный</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">ИП</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Наличие недвижимого имущества</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Наличие движимого имущества</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Счета в БВУ</td>"

                        "<td bgcolor=""#C0C0C0"" align=""center"">Списанная пеня</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Списанная пеня <BR> за баланс</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Отсроченная пеня</td>".
                        put stream m-out unformatted "</tr>" skip.

for each wrk no-lock break by wrk.bank by wrk.cif:

    if first-of(wrk.bank) then put stream m-out unformatted "<tr style=""font:bold""><td colspan=28>" wrk.bank "</td></tr>".
    find first crc where crc.crc = wrk.crc no-lock no-error.

    find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.crtype no-lock no-error.

    put stream m-out unformatted
            "<tr>" skip
/*2 */            "<td>" wrk.name format "x(60)" "</td>" skip
/*3 */            "<td>" wrk.cif "</td>" skip
/*4 */            "<td>" wrk.bankn "</td>" skip
                  "<td>" if avail codfr then codfr.name[1] else '' "</td>" skip
                  "<td>" wrk.plan "</td>" skip
/*8 */            "<td align=""center"">" crc.code "</td>" skip
/*9 */            "<td>" wrk.rdt format "99/99/9999" "</td>" skip
                  "<td>" wrk.isdt format "99/99/9999" "</td>" skip
/*10*/            "<td>" wrk.duedt format "99/99/9999" "</td>" skip

/*14*/            "<td align=""right"">" replace(trim(string(wrk.opnamt_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*19*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*20*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*17*/            "<td align=""right"">" wrk.dayc_od "</td>" skip
                  /*"<td align=""right"">" wrk.fdayc_od "</td>" skip*/
                  "<td align=""right"">" wrk.fdayc_od2 "</td>" skip
                  "<td align=""right"">" wrk.dayop "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.sumop,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.mpayment,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.aaabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.ostatok_aaa,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.n_prov,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*23*/            "<td align=""right"">" replace(trim(string(wrk.prem,'>>9.99')),'.',',') "</td>" skip

                  "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                  "<td align=""right"">" replace(trim(string(wrk.prosr_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*26*/            "<td align=""right"">" wrk.dayc_prc "</td>" skip
                  /*"<td align=""right"">" wrk.fdayc_prc "</td>" skip*/
/*32*/            "<td>" wrk.prcdt_last format "99/99/9999" "</td>" skip

/*33*/            "<td align=""right"">" replace(trim(string(wrk.penalty,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*34*/            "<td align=""right"">" replace(trim(string(wrk.penalty_zabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.penalty_pol,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                  "<td align=""right"">" replace(trim(string(wrk.comdolg,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*44*/            "<td align=""right"">" replace(trim(string(wrk.rezprc,'>>9.99')),'.',',') "</td>" skip
/*45*/            "<td align=""right"">" replace(trim(string(wrk.rezsum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.sumdohod,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" wrk.finsost "</td>" skip
                  "<td align=""right"">" wrk.rate "</td>" skip
                  "<td align=""right"">" wrk.sxem_pog "</td>" skip.
                  if v-reptype = 2 or v-reptype = 3 then put stream m-out unformatted
                  "<td align=""right"">" wrk.rest "</td>"
                  "<td align=""right"">" wrk.crpur "</td>"
                  "<td align=""right"">" wrk.hwoker "</td>"
                  "<td align=""right"">" wrk.nostn "</td>"
                  "<td align=""right"">" wrk.indbus "</td>"
                  "<td align=""right"">" wrk.realp "</td>"
                  "<td align=""right"">" wrk.movp "</td>"
                  "<td align=""right"">" wrk.acc "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.speni,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.speni_bal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.openi,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
                  put stream m-out unformatted "</tr>" skip.

  cntsum[1] = cntsum[1] + wrk.opnamt_kzt.
  cntsum[2] = cntsum[2] + wrk.ostatok_kzt.
  cntsum[3] = cntsum[3] + wrk.prosr_od_kzt.

  cntsum[4] = cntsum[4] + wrk.n_prov.
  cntsum[5] = cntsum[5] + wrk.penalty.
  cntsum[6] = cntsum[6] + wrk.penalty_zabal.
  cntsum[7] = cntsum[7] + wrk.penalty_pol.
  cntsum[8] = cntsum[8] + wrk.rezsum.

end. /* for each wrk */

put stream m-out unformatted
          "<tr align=""right"" style=""font:bold""><td colspan=9></td>" skip
          "<td>" replace(trim(string(cntsum[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=7></td>" skip
          "<td>" replace(trim(string(cntsum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=6></td>" skip
          "<td>" replace(trim(string(cntsum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td><td></td>" skip
          "<td>" replace(trim(string(cntsum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "</tr>" skip.

put stream m-out "</table></body></html>" .
output stream m-out close.
hide message no-pause.

unix silent cptwin lnaudit.htm excel.

/* подготовка консолидированных данных */

if v-select = 1 then do:
    for each wrk1 where wrk1.bank <> 'txb99' no-lock:
        find first b-wrk1 where b-wrk1.rep_id = wrk1.rep_id and b-wrk1.bank = "txb99" and b-wrk1.id = wrk1.id exclusive-lock no-error.
        if not avail b-wrk1 then do:
            create b-wrk1.
            assign b-wrk1.rep_id = wrk1.rep_id
                   b-wrk1.bank = "txb99"
                   b-wrk1.bank_name = "Консолидированный"
                   b-wrk1.id = wrk1.id.
        end.
        assign b-wrk1.kol = b-wrk1.kol + wrk1.kol
               b-wrk1.od = b-wrk1.od + wrk1.od
               b-wrk1.odp = b-wrk1.odp + wrk1.odp
               b-wrk1.nachprc = b-wrk1.nachprc + wrk1.nachprc
               b-wrk1.polprc = b-wrk1.polprc + wrk1.polprc
               b-wrk1.prosrprc = b-wrk1.prosrprc + wrk1.prosrprc
               b-wrk1.nachprcz = b-wrk1.nachprcz + wrk1.nachprcz
               b-wrk1.pen = b-wrk1.pen + wrk1.pen
               b-wrk1.penz = b-wrk1.penz + wrk1.penz
               b-wrk1.polpen = b-wrk1.polpen + wrk1.polpen.
    end.
end.

/*do i = 1 to 2:*/
i = 2.

    output stream m-out to value("rep" + string(i) + ".htm").
    put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted
          "<br>" v-bankname "<br>" skip
          "Разбивка по ".
    put stream m-out unformatted if i = 1 then "фактическим" else "балансовым".
    put stream m-out unformatted
          " просрочкам на " string(d1,"99/99/9999") "<br>" skip
          "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
          "<tr style=""font:bold"">"
          "<td bgcolor=""#C0C0C0"" align=""center""></td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">ОД</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %%</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Получ. %%</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% вне баланса</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы вне баланса</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"">Получ. штрафы</td>"
          "</tr>" skip.

    v-sum = 0.
    for each wrk1 where wrk1.rep_id = i no-lock break by wrk1.bank:
        if first-of(wrk1.bank) then do:
            put stream m-out unformatted
                "<tr><td colspan=11></td></tr>" skip
                "<tr style=""font:bold"">" skip
                "<td colspan=11>" wrk1.bank_name "</td>" skip
                "</tr>" skip.
            v-sum = 0.
        end.
        put stream m-out unformatted
              "<tr>"
              "<td>" gr[wrk1.id] "</td>" skip
              "<td>" wrk1.kol "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.polprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "<td align=""right"">" replace(trim(string(wrk1.polpen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
              "</tr>" skip.
        v-sum[1] = v-sum[1] + wrk1.kol.
        v-sum[2] = v-sum[2] + wrk1.od.
        v-sum[3] = v-sum[3] + wrk1.odp.
        v-sum[4] = v-sum[4] + wrk1.nachprc.
        v-sum[5] = v-sum[5] + wrk1.polprc.
        v-sum[6] = v-sum[6] + wrk1.prosrprc.
        v-sum[7] = v-sum[7] + wrk1.nachprcz.
        v-sum[8] = v-sum[8] + wrk1.pen.
        v-sum[9] = v-sum[9] + wrk1.penz.
        v-sum[10] = v-sum[10] + wrk1.polpen.

        if last-of(wrk1.bank) then do:
            put stream m-out unformatted
                "<tr style=""font:bold"">"
                "<td>ИТОГО</td>" skip
                "<td>" v-sum[1] "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "<td align=""right"">" replace(trim(string(v-sum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                "</tr>" skip.
        end.
    end.


    put stream m-out "</table></body></html>".
    output stream m-out close.

    unix silent value("cptwin rep" + string(i) + ".htm excel").

/*end.*/ /* do i = 1 to 2 */

/*разбивка по признакам клиента для кредитов физ.лиц*/
if v-select = 1 then do:
    for each wrk2 where wrk2.bank <> 'txb99' no-lock:
        find first b-wrk2 where b-wrk2.rep_id = wrk2.rep_id and b-wrk2.priz_id = wrk2.priz_id and b-wrk2.bank = "txb99" and b-wrk2.id = wrk2.id exclusive-lock no-error.
        if not avail b-wrk2 then do:
            create b-wrk2.
            assign b-wrk2.rep_id = wrk2.rep_id
                   b-wrk2.priz_id = wrk2.priz_id
                   b-wrk2.bank = "txb99"
                   b-wrk2.bank_name = "Консолидированный"
                   b-wrk2.id = wrk2.id.
        end.
        assign b-wrk2.kol = b-wrk2.kol + wrk2.kol
               b-wrk2.od = b-wrk2.od + wrk2.od
               b-wrk2.odp = b-wrk2.odp + wrk2.odp
               b-wrk2.nachprc = b-wrk2.nachprc + wrk2.nachprc
               b-wrk2.prosrprc = b-wrk2.prosrprc + wrk2.prosrprc
               b-wrk2.nachprcz = b-wrk2.nachprcz + wrk2.nachprcz
               b-wrk2.pen = b-wrk2.pen + wrk2.pen
               b-wrk2.penz = b-wrk2.penz + wrk2.penz.

    end.
end.
def var v-kol as integer.
def var v-od as deci.
def var v-odp as deci.
def var v-nachprc as deci.
def var v-prosrprc as deci.
def var v-nachprcz as deci.
def var v-pen as deci.
def var v-penz as deci.

if v-reptype = 2 or v-reptype = 3 then do:
   for each wrk2 where wrk2.bank <> 'txb99' no-lock break by wrk2.bank by wrk2.rep_id by wrk2.priz_id:
     v-kol = v-kol + wrk2.kol.
     v-od = v-od + wrk2.od.
     v-odp = v-odp + wrk2.odp.
     v-nachprc = v-nachprc + wrk2.nachprc.
     v-prosrprc = v-prosrprc + wrk2.prosrprc.
     v-nachprcz = v-nachprcz + wrk2.nachprcz.
     v-pen = v-pen + wrk2.pen.
     v-penz = v-penz + wrk2.penz.
     if last-of(wrk2.priz_id) then do:
      find first wrk4 where wrk4.bank = wrk2.bank and wrk4.rep_id = wrk2.rep_id and wrk4.priz_id = wrk2.priz_id no-lock no-error.
          if not avail wrk4 then do:

          create wrk4.

          assign wrk4.rep_id = wrk2.rep_id
                 wrk4.priz_id = wrk2.priz_id
                 wrk4.bank = wrk2.bank
                 wrk4.bank_name = wrk2.bank_name
                 wrk4.kol = v-kol
                 wrk4.od = v-od
                 wrk4.odp = v-odp
                 wrk4.nachprc = v-nachprc
                 wrk4.prosrprc = v-prosrprc
                 wrk4.nachprcz = v-nachprcz
                 wrk4.pen = v-pen
                 wrk4.penz = v-penz.
          end.
          v-kol = 0.
          v-od = 0.
          v-odp = 0.
          v-nachprc = 0.
          v-prosrprc = 0.
          v-nachprcz = 0.
          v-pen = 0.
          v-penz = 0.
    end.
   end.
end.


if v-select = 1 then do:
    for each wrk4 where wrk4.bank <> 'txb99' no-lock:
        find first b-wrk4 where b-wrk4.rep_id = wrk4.rep_id and b-wrk4.bank = "txb99" and b-wrk4.priz_id = wrk4.priz_id exclusive-lock no-error.
        if not avail b-wrk4 then do:
            create b-wrk4.
            assign b-wrk4.rep_id = wrk4.rep_id
                   b-wrk4.priz_id = wrk4.priz_id
                   b-wrk4.bank = "txb99"
                   b-wrk4.bank_name = "Консолидированный".
        end.
        assign b-wrk4.kol = b-wrk4.kol + wrk4.kol
               b-wrk4.od = b-wrk4.od + wrk4.od
               b-wrk4.odp = b-wrk4.odp + wrk4.odp
               b-wrk4.nachprc = b-wrk4.nachprc + wrk4.nachprc
               b-wrk4.prosrprc = b-wrk4.prosrprc + wrk4.prosrprc
               b-wrk4.nachprcz = b-wrk4.nachprcz + wrk4.nachprcz
               b-wrk4.pen = b-wrk4.pen + wrk4.pen
               b-wrk4.penz = b-wrk4.penz + wrk4.penz.

    end.
end.


if v-reptype = 2 or v-reptype = 3 then do:
    find first wrk2 no-lock no-error.
    if avail wrk2 then do:
        for each wrk2 no-lock:
           find first wrk3 where wrk3.rep_id = wrk2.rep_id  and wrk3.bank = wrk2.bank and wrk3.id = wrk2.id exclusive-lock no-error.
           if not avail wrk3 then do:
                create wrk3.
                assign wrk3.rep_id = wrk2.rep_id
                       wrk3.bank = wrk2.bank
                       wrk3.bank_name = wrk2.bank_name
                       wrk3.id = wrk2.id.
            end.
            assign wrk3.kol = wrk3.kol + wrk2.kol
                   wrk3.od = wrk3.od + wrk2.od
                   wrk3.odp = wrk3.odp + wrk2.odp
                   wrk3.nachprc = wrk3.nachprc + wrk2.nachprc
                   wrk3.prosrprc = wrk3.prosrprc + wrk2.prosrprc
                   wrk3.nachprcz = wrk3.nachprcz + wrk2.nachprcz
                   wrk3.pen = wrk3.pen + wrk2.pen
                   wrk3.penz = wrk3.penz + wrk2.penz.
        end.


        output stream m-out to value("rep6.htm").
        put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream m-out unformatted
                "<br>" v-bankname "<br>" skip
                "Разбивка по статусу заемщика".
        put stream m-out unformatted
                " на " string(d1,"99/99/9999") "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">".
        v-bank = ''.
        for each txb where txb.consolid no-lock:
          if v-bank <> '' then v-bank = v-bank + ','.
          v-bank = v-bank + txb.bank.
        end.
        v-bank = v-bank + ',' + 'txb99'.
        do k = 1 to num-entries(v-bank):
            d = 0.
            do i = 1 to 3:
                for each wrk2 where wrk2.rep_id = i and wrk2.bank = entry(k,v-bank) no-lock break by wrk2.bank by wrk2.priz_id by wrk2.id:
                    if first-of(wrk2.bank) then do:
                        if wrk2.bank = "txb99" and d = 0  then do:
                           put stream m-out unformatted
                           "<tr></tr>" skip
                           "<tr style=""font:bold"">" skip
                           "<td colspan=10>" wrk2.bank_name "</td></tr>" skip.
                            d = d + 1.
                        end.
                        else if d = 0 then do:
                           put stream m-out unformatted
                           "<tr></tr>" skip
                           "<tr style=""font:bold"">" skip
                           "<td colspan=10>Филиал " wrk2.bank_name "</td></tr>" skip.
                           d = d + 1.
                        end.

                        put stream m-out unformatted
                            "<tr style=""font:bold"" align = ""left"">" skip.
                        if i = 1 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>НАЕМНЫЙ РАБОТНИК</td>" skip.
                        if i = 2 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>ИП</td>" skip.
                         if i = 3 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>НЕСТАНДАРТНЫЙ</td>" skip.

                        put stream m-out unformatted "</tr>"
                             "<tr style=""font:bold"">"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Наименование статуса</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% в балансе</td>"

                             "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% за балансом</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы в балансе</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы за балансом</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Итого просроч.долг</td>"
                             "</tr>" skip.

                    end.
                    if first-of(wrk2.priz_id) then do:
                       if i = 1 then find first codfr where codfr.codfr = 'hwoker' and codfr.code = wrk2.priz_id no-lock no-error.
                       if i = 2 then find first codfr where codfr.codfr = 'indbus' and codfr.code = wrk2.priz_id no-lock no-error.
                       if i = 3 then find first codfr where codfr.codfr = 'nonstn' and codfr.code = wrk2.priz_id no-lock no-error.
                       put stream m-out unformatted
                          "<tr style=""font:bold"">" skip
                          "<td>" codfr.name[1] "</td>" skip.
                          do j = 1 to 9:
                            put stream m-out unformatted "<td></td>".
                          end.
                            put stream m-out unformatted "</tr>" skip.
                    end.
                    put stream m-out unformatted
                          "<tr>"
                          "<td>" gr[wrk2.id] "</td>" skip
                          "<td>" wrk2.kol "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                          "<td align=""right"">" replace(trim(string(wrk2.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk2.odp + wrk2.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "</tr>" skip.

                    if last-of(wrk2.bank) then do:
                        put stream m-out unformatted
                            "<tr style=""font:bold"" align = ""left"">" skip.
                        if i = 1 then put stream m-out unformatted
                            "<td colspan=10>НАЕМНЫЙ РАБОТНИК<br>(ИТОГО)</td>" skip.
                        if i = 2 then put stream m-out unformatted
                            "<td colspan=10>ИП (ИТОГО)</td>" skip.
                         if i = 3 then put stream m-out unformatted
                            "<td colspan=10>НЕСТАНДАРТНЫЙ<br>(ИТОГО)</td>" skip.
                         for each wrk3 where wrk3.rep_id = i and wrk3.bank = wrk2.bank no-lock:
                            put stream m-out unformatted
                                  "<tr>"
                                  "<td>" gr[wrk3.id] "</td>" skip
                                  "<td>" wrk3.kol "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                                  "<td align=""right"">" replace(trim(string(wrk3.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk3.odp + wrk3.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "</tr>" skip.
                         end.
                    end.
                end.


            end. /* do i = 1 to 2 */
        end.
        put stream m-out "</table></body></html>".
        output stream m-out close.
        unix silent value("cptwin rep6.htm excel").
    end.
end.


if v-reptype = 2 or v-reptype = 3 then do:
    find first wrk4 no-lock no-error.
    if avail wrk4 then do:
        for each wrk4 no-lock:
           find first wrk5 where wrk5.rep_id = wrk4.rep_id  and wrk5.bank = wrk4.bank exclusive-lock no-error.
           if not avail wrk5 then do:
                create wrk5.
                assign wrk5.rep_id = wrk4.rep_id
                       wrk5.bank = wrk4.bank
                       wrk5.bank_name = wrk4.bank_name.
           end.
            assign wrk5.kol = wrk5.kol + wrk4.kol
                   wrk5.od = wrk5.od + wrk4.od
                   wrk5.odp = wrk5.odp + wrk4.odp
                   wrk5.nachprc = wrk5.nachprc + wrk4.nachprc
                   wrk5.prosrprc = wrk5.prosrprc + wrk4.prosrprc
                   wrk5.nachprcz = wrk5.nachprcz + wrk4.nachprcz
                   wrk5.pen = wrk5.pen + wrk4.pen
                   wrk5.penz = wrk5.penz + wrk4.penz.
        end.


        output stream m-out to value("rep7.htm").
        put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream m-out unformatted
                "<br>" v-bankname "<br>" skip
                "Разбивка по статусу заемщика".
        put stream m-out unformatted
                " на " string(d1,"99/99/9999") "<br>" skip.
        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">".
        v-bank = ''.
        for each txb where txb.consolid no-lock:
          if v-bank <> '' then v-bank = v-bank + ','.
          v-bank = v-bank + txb.bank.
        end.
        v-bank = v-bank + ',' + 'txb99'.
        do k = 1 to num-entries(v-bank):
            d = 0.
            do i = 1 to 3:
                for each wrk4 where wrk4.rep_id = i and wrk4.bank = entry(k,v-bank) no-lock break by wrk4.bank by wrk4.priz_id:
                    if first-of(wrk4.bank) then do:
                        if wrk4.bank = "txb99" and d = 0  then do:
                           put stream m-out unformatted
                           "<tr></tr>" skip
                           "<tr style=""font:bold"">" skip
                           "<td colspan=10>" wrk4.bank_name "</td></tr>" skip.
                            d = d + 1.
                        end.
                        else if d = 0 then do:
                           put stream m-out unformatted
                           "<tr></tr>" skip
                           "<tr style=""font:bold"">" skip
                           "<td colspan=10>Филиал " wrk4.bank_name "</td></tr>" skip.
                           d = d + 1.
                        end.

                        put stream m-out unformatted
                            "<tr style=""font:bold"" align = ""left"">" skip.
                        if i = 1 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>НАЕМНЫЙ РАБОТНИК</td>" skip.
                        if i = 2 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>ИП</td>" skip.
                         if i = 3 then put stream m-out unformatted
                            "<td bgcolor=""#C0C0C0"" colspan=10>НЕСТАНДАРТНЫЙ</td>" skip.

                        put stream m-out unformatted "</tr>"
                             "<tr style=""font:bold"">"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Наименование статуса</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. ОД</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% в балансе</td>"

                             "<td bgcolor=""#C0C0C0"" align=""center"">Просроч. %%</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %% за балансом</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы в балансе</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы за балансом</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Итого просроч.долг</td>"
                             "</tr>" skip.

                    end.
                    if first-of(wrk4.priz_id) then do:
                       if i = 1 then find first codfr where codfr.codfr = 'hwoker' and codfr.code = wrk4.priz_id no-lock no-error.
                       if i = 2 then find first codfr where codfr.codfr = 'indbus' and codfr.code = wrk4.priz_id no-lock no-error.
                       if i = 3 then find first codfr where codfr.codfr = 'nonstn' and codfr.code = wrk4.priz_id no-lock no-error.
                       put stream m-out unformatted
                          "<tr>" skip
                          "<td style=""font:bold"">" codfr.name[1] "</td>" skip.
                         /* do j = 1 to 9:
                            put stream m-out unformatted "<td></td>".
                          end.
                            put stream m-out unformatted "</tr>" skip.*/
                    end.
                    put stream m-out unformatted
                          /*"<tr>"*/
                          /*"<td>" gr[wrk4.id] "</td>" skip*/
                          "<td>" wrk4.kol "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                          "<td align=""right"">" replace(trim(string(wrk4.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "<td align=""right"">" replace(trim(string(wrk4.odp + wrk4.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                          "</tr>" skip.

                    if last-of(wrk4.bank) then do:
                        put stream m-out unformatted
                            "<tr align = ""left"">" skip.
                        if i = 1 then put stream m-out unformatted
                            "<td style=""font:bold"" >НАЕМНЫЙ РАБОТНИК<br>(ИТОГО)</td>" skip.
                        if i = 2 then put stream m-out unformatted
                            "<td style=""font:bold"" >ИП (ИТОГО)</td>" skip.
                         if i = 3 then put stream m-out unformatted
                            "<td style=""font:bold"" >НЕСТАНДАРТНЫЙ<br>(ИТОГО)</td>" skip.
                         for each wrk5 where wrk5.rep_id = i and wrk5.bank = wrk4.bank no-lock:
                            put stream m-out unformatted
                                  /*"<tr>"*/
                                  /*"<td>" gr[wrk5.id] "</td>" skip*/
                                  "<td align=""right"">" wrk5.kol "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.odp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.nachprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

                                  "<td align=""right"">" replace(trim(string(wrk5.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.nachprcz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.penz,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "<td align=""right"">" replace(trim(string(wrk5.odp + wrk5.prosrprc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                                  "</tr>" skip.
                         end.
                    end.
                end.


            end. /* do i = 1 to 2 */
        end.
        put stream m-out "</table></body></html>".
        output stream m-out close.
        unix silent value("cptwin rep7.htm excel").
    end.
end.
