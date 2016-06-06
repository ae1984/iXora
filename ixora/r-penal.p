/* dcls55.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет о просроченных суммах и штрафах (по 7, 9 и 16 уровням)
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
        18.09.03 marinav
 * BASES
        BANK COMM
 * CHANGES
        11.11.2003 marinav Остатки по просрочке берутся из hislon
        08.01.2003 marinav  Остатки по 7 и 9 уровням считаются из trxbal, штрафы из hislon
        20.01.2004 marinav  Остаток на 9 ур считается из hislon
        20.04.2004 nadejda  добавила вывод дней просрочки - но для юрлиц там не точно, поскольку графики кривые
                            остаток по 7 уровню берется из histrxbal
        08/06/2004 madiyar - Добавил вывод статуса кредита и фактически сформированных провизий
        14/07/2004 madiyar - Добавил разбивку на юр/физ лица
        04/11/2004 madiyar - Добавил поля rdt и duedt в wrk
        05/11/2004 madiyar - Разбивка на юр/физ лица теперь делается по группе кредита
        04/11/2004 madiyar - Добавил поле grp в wrk
        30/05/2005 madiyar - Разбранчевка, второй (компактный) отчет
        31/05/2005 madiyar - исправил мелкую ошибку
        20/06/2005 madiyar - небольшие изменения
        11/08/2005 madiyar - выводилось поле cmp.name без поиска записи cmp
        01/09/2005 madiyar - подправил итоги
        04/01/2006 madiyar - подправил заголовок
        15/02/2006 Natalya D. - добавлены 2 поля: Начисленные % за балансом и Начисленные штрафы за балансом
        04/08/2009 madiyar - учел валюту кредита
        13/09/2010 aigul - добавила сектор экономики и код займа по виду залога
        31/05/2011 kapar - «Сумма (KZT)»  учитывает начисленные % за балансом
        10/08/2011 dmitriy - добавил столбец "Комиссия за обслуживание кредита" и поле kommis в wrk
        25.10.2011 damir - добавил входные параметры.
        26.10.2011 damir - устранил мелкие ошибки.
        02.11.2011 damir - «Быстрые деньги» заменил на «Метрокредит»
        03.11.2011 kapar - исправил "МЕТРОКРЕДИТ одобренная, остаток ссуд. задол-ти (KZT)"
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        09.08.2013 damir - Внедрено Т.З. № 2014.
        15.08.2013 damir - Внедрено Т.З. № 2024.
*/

{mainhead.i}

def input  parameter       p-option as char.
def input  parameter       p-date   as date.
def output parameter       p-fname  as char init "rep.xls".
def input-output parameter p-res    as logi.

def var coun as integer.
def var i as integer.
def var d1 as date.
def var v-sel as char init '0'.
define stream m-out.

def var s-bal16 like jl.dam init 0.
def var s-bal9 like jl.dam init 0.
def var s-bal7 like jl.dam init 0.
def var s-bal4 like jl.dam init 0.
def var s-bal5 like jl.dam init 0.
def var s-prov as deci init 0.

def var v-sum1 as deci no-undo.
def var v-sum2 as deci no-undo.

def new shared temp-table wrk
  field bank as char
  field urfiz as char
  field name as char
  field cif /***like cif.cif***/ as char
  field lon like lon.lon
  field grp like lon.grp
  field crc like crc.crc
  field opnamt as decimal
  field rdt as date
  field duedt as date
  field balance as decimal
  field od_prosr as decimal
  field od_days as integer
  field proc_prosr as decimal
  field proc_days as integer
  field proc_zabal as decimal
  field shtraf as decimal
  field shtraf_zabal as decimal
  field crstatus as decimal
  field prov as decimal
  field sec_econ as char
  field ob_cred as char
  field kommis as deci
  index idx1 bank urfiz crc cif
  index idx2 urfiz crc bank cif.

def temp-table wrk2
  field id as int
  field bank as char
  field opnamt as deci
  field od as deci
  field prosr_od as deci
  field prosr_prc as deci
  field prc_zabal as deci
  field penalty as deci
  field pen_zabal as deci
  index id_idx id.

if p-option = "mail" then do:
    d1 = p-date.
    v-sel = "2".
    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.
    def var vv-path as char no-undo.
    if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
    else vv-path = '/data/b'.
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-penal2(d1).
    end.
    if connected ("txb") then disconnect "txb".
end.
else do:
    run sel2 ("Выбор :", " 1. Полный | 2. Компактный ", output v-sel).
    if v-sel = '0' then return.

    find last cls no-lock no-error.
    d1 = cls.whn.
    update d1 label " Отчет за дату " format "99/99/9999" validate (d1 < g-today, " Дата должна быть меньше текущей!") skip
           with side-label row 5 centered frame dat.

    message " Формируется отчет...".

    {r-brfilial.i &proc = "r-penal2.p (d1)"}
end.

if p-option = "mail" then output stream m-out to value(p-fname).
else output stream m-out to repday.html.

{html-title.i &stream = "stream m-out" &size-add = "x-"}

find first cmp no-lock no-error.

/* полный отчет */

if v-sel = '1' then do:

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format "x(79)" "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<tr align=""center""><td><h3> Просроченная задолженность " skip " за " string(d1) "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).

       put stream m-out unformatted
                  "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Код<br>клиента</td>"
                  "<td>Ссудный счет</td>"
                  "<td>Группа</td>"
                  "<td>Валюта<br>кредита</td>"
                  "<td>Одобренная<br>сумма</td>"
                  "<td>Дата выдачи</td>"
                  "<td>Дата погашения</td>"
                  "<td>Остаток<br>ссуд задол-ти</td>"
                  "<td>Сумма<br>просроч ОД</td>"
                  "<td>Дни<br>проср ОД</td>"
                  "<td>Сумма<br>просроч %</td>"
                  "<td>Дни<br>проср %</td>"
                  "<td>%, начисленные<br>за балансом</td>"
                  "<td>Сумма<br>штрафа</td>"
                  "<td>Штрафы, начислен-<br>ные за балансом</td>"
                  "<td>Статус</td>"
                  "<td>Факт сформ<BR>провизии</td>"
                  "<td>Сектор экономики</td>"
                  "<td>Код займа по виду залога</td>"
                  "</tr>" skip.

coun = 1.
for each wrk no-lock break by wrk.bank by wrk.urfiz by wrk.crc by wrk.cif:

  if first-of(wrk.bank) then do:
    put stream m-out unformatted "<tr><td colspan=""14"">" wrk.bank "</td></tr>" skip.
  end.

  if first-of(wrk.urfiz) then do:
    put stream m-out unformatted "<tr><td colspan=""14"">" if wrk.urfiz = '0' then "Юридические лица" else "Физические лица" "</td></tr>" skip.
  end.

  find crc where crc.crc = wrk.crc no-lock no-error.
  if not avail crc then message " Не найдена валюта " wrk.crc view-as alert-box buttons ok.
  put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""center"">&nbsp;" wrk.lon "</td>"
               "<td align=""center"">" wrk.grp "</td>"
               "<td align=""center""> " crc.code "</td>"
               "<td> " replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td align=""center""> " wrk.rdt format "99/99/9999" "</td>"
               "<td align=""center""> " wrk.duedt format "99/99/9999" "</td>"
               "<td> " replace(trim(string(wrk.balance, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.od_prosr, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" wrk.od_days "</td>"
               "<td> " replace(trim(string(wrk.proc_prosr, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" wrk.proc_days "</td>"
               "<td> " replace(trim(string(wrk.proc_zabal, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.shtraf, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.shtraf_zabal, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(wrk.crstatus, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.prov, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " wrk.sec_econ "</td>"
               "<td> " '`' wrk.ob_cred  "</td>"
               "</tr>" skip.
  coun = coun + 1.
  s-bal16 = s-bal16 + wrk.shtraf.
  s-bal9 = s-bal9 + wrk.proc_prosr.
  s-bal7 = s-bal7 + wrk.od_prosr.
  s-prov = s-prov + wrk.prov.
  s-bal4 = s-bal4 + wrk.proc_zabal.
  s-bal5 = s-bal5 + wrk.shtraf_zabal.

end. /* for each wrk */

    put stream m-out unformatted "<tr align=""right"">"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td></td>"
               "<td> " replace(trim(string(s-bal7, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td></td>"
               "<td> " replace(trim(string(s-bal9, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td></td>"
               "<td> " replace(trim(string(s-bal4, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(s-bal16, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td> " replace(trim(string(s-bal5, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td></td>"
               "<td> " replace(trim(string(s-prov, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "</tr>" skip.


put stream m-out unformatted "</table>" skip.

end. /* полный */

/* компактный отчет */

if v-sel = '2' then do:

    put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

    put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format "x(79)" "</h3></td></tr><br><br>" skip(1).

    put stream m-out unformatted "<tr align=""center""><td><h3> Просроченная задолженность " skip " за " string(d1) "</h3></td></tr><br><br>" skip(1).

    put stream m-out unformatted "<tr></tr><tr></tr>" skip(1).

    put stream m-out unformatted
        "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
        "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
        "<td>П/п</td>" /*1*/
        "<td>Наименование заемщика</td>" /*2*/
        "<td>Код<br>клиента</td>" /*3*/
        "<td>Ссудный счет</td>" /*4*/
        "<td>Группа</td>" /*5*/
        "<td>Валюта<br>кредита</td>" /*6*/
        "<td>Одобренная<br>сумма (KZT)</td>" /*7*/
        "<td>Дата выдачи</td>" /*8*/
        "<td>Дата погашения</td>" /*9*/
        "<td>Остаток ссуд.<br>задол-ти (KZT)</td>" /*10*/
        "<td>Сумма<br>просроч ОД (KZT)</td>" /*11*/
        "<td>Дни<br>проср ОД</td>" /*12*/
        "<td>Сумма<br>просроч % (KZT)</td>" /*13*/
        "<td>Дни<br>проср %</td>" /*14*/
        "<td>%, начисленные<br>за балансом</td>" /*15*/
        "<td>Сумма (KZT)</td>" /*16*/
        "<td>Комиссия за<br>обслуживание кредита</td>" /*17*/
        "<td>Сумма<br>штрафа</td>" /*18*/
        "<td>Штрафы, начислен-<br>ные за балансом</td>" /*19*/
        /*"<td>Статус</td>"
        "<td>Факт сформ<BR>провизии</td>" */
        "</tr>" skip.

    def var v-itog1 as deci extent 7.
    def var v-itog2 as deci extent 7.
    def var v-itog_fiz as deci extent 7.
    def var v-itogall as deci extent 7.

    coun = 1. v-itog_fiz = 0.
    for each wrk no-lock break by wrk.urfiz by wrk.crc by wrk.bank by wrk.cif:
        if first-of(wrk.urfiz) then do:
            put stream m-out unformatted "<tr><td colspan=""14"" style=""font:bold"">" if wrk.urfiz = '0' then "Юридические лица" else "Физические лица" "</td></tr>" skip.
            v-itog2 = 0.
        end.
        if first-of(wrk.crc) then do:
            find crc where crc.crc = wrk.crc no-lock no-error.
            if not avail crc then message " Не найдена валюта " wrk.crc view-as alert-box buttons ok.
            v-itog1 = 0.
        end.
        /*if first-of(wrk.bank) then do:
            put stream m-out unformatted "<tr><td colspan=""14"" style=""font:bold"">" wrk.bank "</td></tr>" skip.
        end.*/
        if wrk.crc <> 1 then do:
          find last crchis where crchis.crc = wrk.crc and crchis.rdt <= d1 no-lock no-error.
          v-sum1 = wrk.opnamt * crchis.rate[1].
          v-sum2 = wrk.balance * crchis.rate[1].
        end.
        else do:
          v-sum1 = wrk.opnamt.
          v-sum2 = wrk.balance.
        end.

        if wrk.urfiz = '1' and (wrk.grp = 90 or wrk.grp = 92) then do:
            find first wrk2 where wrk2.bank = wrk.bank no-error.
            if not avail wrk2 then do:
                create wrk2.
                wrk2.bank = wrk.bank.
            end.
            wrk2.opnamt = wrk2.opnamt + wrk.opnamt.
            wrk2.od = wrk2.od + wrk.balance.
            wrk2.prosr_od = wrk2.prosr_od + wrk.od_prosr.
            wrk2.prosr_prc = wrk2.prosr_prc + wrk.proc_prosr.
            wrk2.penalty = wrk2.penalty + wrk.shtraf.
            wrk2.prc_zabal = wrk2.prc_zabal + wrk.proc_zabal.
            wrk2.pen_zabal = wrk2.pen_zabal + wrk.shtraf_zabal.
        end.
        else do:
            def var bgcol as char.
            def var v-max as deci.

            if wrk.od_days > wrk.proc_days then v-max = wrk.od_days.
            else v-max = wrk.proc_days.

            if v-max >= 0 and v-max <= 14 then bgcol = "#00FF00".
            else if v-max >= 15 and v-max <= 30 then bgcol = "#FFFF00".
            else if v-max >= 31 then bgcol = "#FF0000".

            put stream m-out unformatted "<tr align=""right"">"
                "<td align=""center""> " coun "</td>"
                "<td bgcolor='" bgcol "' align=""left""> " wrk.name "</td>"
                "<td align=""center""> " wrk.cif "</td>"
                "<td align=""center"">&nbsp;" wrk.lon "</td>"
                "<td align=""center"">" wrk.grp "</td>"
                "<td align=""center""> " crc.code "</td>"
                "<td>" replace(trim(string(v-sum1, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td align=""center""> " wrk.rdt format "99/99/9999" "</td>"
                "<td align=""center""> " wrk.duedt format "99/99/9999" "</td>"
                "<td>" replace(trim(string(v-sum2, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.od_prosr, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" wrk.od_days "</td>"
                "<td>" replace(trim(string(wrk.proc_prosr, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" wrk.proc_days "</td>"
                "<td>" replace(trim(string(wrk.proc_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.od_prosr + wrk.proc_prosr + wrk.proc_zabal + wrk.kommis + wrk.shtraf + wrk.shtraf_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.kommis, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.shtraf, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.shtraf_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>"
                /* "<td>" replace(trim(string(wrk.crstatus, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "<td>" replace(trim(string(wrk.prov, "->>>>>>>>>>>9.99")),".",",") "</td>" */
                "</tr>" skip.

            coun = coun + 1.
            v-itog1[1] = v-itog1[1] + v-sum1.
            v-itog1[2] = v-itog1[2] + v-sum2.
            v-itog1[3] = v-itog1[3] + wrk.od_prosr.
            v-itog1[4] = v-itog1[4] + wrk.proc_prosr.
            v-itog1[5] = v-itog1[5] + wrk.shtraf.
            v-itog1[6] = v-itog1[6] + wrk.proc_zabal.
            v-itog1[7] = v-itog1[7] + wrk.shtraf_zabal.
        end.

        if last-of(wrk.crc) then do:
            if v-itog1[1] + v-itog1[2] + v-itog1[3] + v-itog1[4] + v-itog1[5] + v-itog1[6] + v-itog1[7] > 0 then do:
                put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                    "<td align=""center""></td>" skip
                    "<td align=""left""> ИТОГО " crc.code "</td>" skip
                    "<td align=""center""></td>" skip
                    "<td align=""center""></td>" skip
                    "<td align=""center""></td>" skip
                    "<td align=""center""></td>" skip
                    "<td>" replace(trim(string(v-itog1[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td align=""center""></td>" skip
                    "<td align=""center""></td>" skip
                    "<td>" replace(trim(string(v-itog1[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td>" replace(trim(string(v-itog1[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td></td>" skip
                    "<td>" replace(trim(string(v-itog1[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td></td>" skip
                    "<td>" replace(trim(string(v-itog1[6], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td>" replace(trim(string(v-itog1[3] + v-itog1[4] + v-itog1[6] + v-itog1[5] + v-itog1[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td></td>" skip
                    "<td>" replace(trim(string(v-itog1[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    "<td>" replace(trim(string(v-itog1[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                    /* "<td>" replace(trim(string(wrk.crstatus, "->>>>>>>>>>>9.99")),".",",") "</td>"
                    "<td>" replace(trim(string(wrk.prov, "->>>>>>>>>>>9.99")),".",",") "</td>" */
                    "</tr>" skip.

                find last crchis where crchis.crc = wrk.crc and crchis.regdt <= d1 no-lock no-error.
                if not avail crchis then do:
                    message " Не найдена запись в истории курсов валют " view-as alert-box buttons ok.
                    return.
                end.
                v-itog2[1] = v-itog2[1] + v-itog1[1] * crchis.rate[1].
                v-itog2[2] = v-itog2[2] + v-itog1[2] * crchis.rate[1].
                v-itog2[3] = v-itog2[3] + v-itog1[3].
                v-itog2[4] = v-itog2[4] + v-itog1[4].
                v-itog2[5] = v-itog2[5] + v-itog1[5].
                v-itog2[6] = v-itog2[6] + v-itog1[6].
                v-itog2[7] = v-itog2[7] + v-itog1[7].
            end.
        end.

        if last-of(wrk.urfiz) then do:
            if v-itog2[1] + v-itog2[2] + v-itog2[3] + v-itog2[4] + v-itog2[5] + v-itog2[6] + v-itog2[7] > 0 then do:
                find last crchis where crchis.crc = 2 and crchis.regdt <= d1 no-lock no-error.
                if not avail crchis then do:
                    message " Не найдена запись в истории курсов валют " view-as alert-box buttons ok.
                    return.
                end.
                if wrk.urfiz = '0' then do:
                    put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                        "<td align=""right"" colspan=10>Итого по юридическим лицам в KZT:</td>" skip
                        "<td>" replace(trim(string(v-itog2[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                        "<td align=""center""></td>" skip
                        "<td>" replace(trim(string(v-itog2[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "</tr>" skip
                        "<tr align=""right"" style=""font:bold"">"
                        "<td align=""right"" colspan=10>Итого по юридическим лицам в USD:</td>" skip
                        "<td>" replace(trim(string(v-itog2[3] / crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                        "<td align=""center""></td>" skip
                        "<td>" replace(trim(string(v-itog2[4] / crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "<td align=""center""></td>" skip
                        "</tr>" skip.
                end.
                else do:
                    do i = 1 to 7: v-itog_fiz[i] = v-itog2[i]. end.
                end.
                do i = 1 to 7: v-itogall[i] = v-itogall[i] + v-itog1[i]. end.
            end.

        end.
    end. /* for each wrk */

    put stream m-out unformatted "<tr><td colspan=""14"" style=""font:bold"">МЕТРОКРЕДИТ</td></tr>" skip.

    coun = 1. v-itog1 = 0.
    for each wrk2 no-lock:
        put stream m-out unformatted
            "<tr align=""right"">" skip
            "<td align=""center"">" coun "</td>" skip
            "<td align=""left"" colspan=5>МЕТРОКРЕДИТ - " + wrk2.bank "</td>" skip
            "<td>" replace(trim(string(wrk2.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td align=""center""></td>" skip
            "<td align=""center""></td>" skip
            "<td>" replace(trim(string(wrk2.od, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td>" replace(trim(string(wrk2.prosr_od, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td align=""center""></td>" skip
            "<td>" replace(trim(string(wrk2.prosr_prc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td align=""center""></td>" skip
            "<td>" replace(trim(string(wrk2.prc_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td>" replace(trim(string(wrk2.prosr_od + wrk2.prosr_prc + wrk2.prc_zabal + wrk2.penalty + wrk2.pen_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td align=""center""></td>" skip
            "<td>" replace(trim(string(wrk2.penalty, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "<td>" replace(trim(string(wrk2.pen_zabal, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
            "</tr>" skip.

        coun = coun + 1.
        v-itog1[1] = v-itog1[1] + wrk2.opnamt.
        v-itog1[2] = v-itog1[2] + wrk2.od.
        v-itog1[3] = v-itog1[3] + wrk2.prosr_od.
        v-itog1[4] = v-itog1[4] + wrk2.prosr_prc.
        v-itog1[5] = v-itog1[5] + wrk2.penalty.
        v-itog1[6] = v-itog1[6] + wrk2.prc_zabal.
        v-itog1[7] = v-itog1[7] + wrk2.pen_zabal.
    end. /* for each wrk */

    put stream m-out unformatted
        "<tr align=""right"" style=""font:bold"">" skip
        "<td align=""center""></td>" skip
        "<td align=""right"" colspan=5>ИТОГО KZT:</td>" skip
        "<td>" replace(trim(string(v-itog1[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string(v-itog1[2], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(v-itog1[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string(v-itog1[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string(v-itog1[6], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(v-itog1[3] + v-itog1[4] + v-itog1[6] + v-itog1[5] + v-itog1[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string(v-itog1[5], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(v-itog1[7], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "</tr>" skip.

    find last crchis where crchis.crc = 2 and crchis.regdt <= d1 no-lock no-error.
    if not avail crchis then do:
        message " Не найдена запись в истории курсов валют " view-as alert-box buttons ok.
        return.
    end.
    put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
        "<td align=""right"" colspan=10>Итого по физическим лицам в KZT:</td>" skip
        "<td>" replace(trim(string(v-itog_fiz[3] + v-itog1[3], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string(v-itog_fiz[4] + v-itog1[4], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "</tr>" skip
        "<tr align=""right"" style=""font:bold"">"
        "<td align=""right"" colspan=10>Итого по физическим лицам в USD:</td>" skip
        "<td>" replace(trim(string((v-itog_fiz[3] + v-itog1[3]) / crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td>" replace(trim(string((v-itog_fiz[4] + v-itog1[4]) / crchis.rate[1], "->>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "</tr>" skip.
end. /* компактный */

put stream m-out unformatted "</table>" skip.

put stream m-out unformatted
    "<br><br><table width='100%' border=""1"" cellpadding=""0"" cellspacing=""0"">" skip
    "<TR align=left style='font-size:12pt;font:bold'>" skip
    "<TD colspan=11>Расшифровка</TD>" skip
    "</TR>" skip
    "<TR style='font-size:12pt'>" skip
    "<TD bgcolor=#00FF00></TD>" skip
    "<TD colspan=10>Наличие просроченной задолженности 0- 14 дней  (включительно).</TD>" skip
    "</TR>" skip
    "<TR style='font-size:12pt'>" skip
    "<TD bgcolor=#FFFF00></TD>" skip
    "<TD colspan=10>Наличие просроченной задолженности 15- 30 дней  (включительно).</TD>" skip
    "</TR>" skip
    "<TR style='font-size:12pt'>" skip
    "<TD bgcolor=#FF0000></TD>" skip
    "<TD colspan=10>Наличие просроченной задолженности от 30 дней  и более.</TD>" skip
    "</TR>" skip
    "</table><br><br>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

if p-option <> "mail" then unix silent cptwin repday.html excel.

p-res = yes.

