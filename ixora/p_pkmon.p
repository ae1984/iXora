/* p_pkmon.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Список задолжников на дату
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
        pkrepmon.i  
 * MENU

 * AUTHOR
        02.04.2004 tsoy
 * CHANGES
        07.04.2004 tsoy поставил no-lock
        13.04.2004 tsoy Доработал интерфейс отчета
        04.05.2004 tsoy Учет выходных дней
        05.05.2004 tsoy Добавил выделение зеленым цветом сумм и кодов клиентов где просрочка ОД < 1
        13.05.2004 tsoy    - показываем синим цветом тех задолжников которые являются работниками наших клиентов
        20.05.2004 tsoy    - исправил установку статуса
        24.05.2004 tsoy    - исправил дату с которой человек задолжник, также добавил дату открытия
        31.05.2004 tsoy    - изменил граничные условия для дат
        14.09.2004 saltanat - добавила выделение желтым фоном клиентов с плат. картами
        20.09.2004 saltanat - включила дисконект базы Cards.
        28/09/2004 madiyar - перекомпиляция
        30.09.2004 saltanat - включила проверку на статус карточки
        17/02/2005 madiyar - закомментировал расчет t-report.expsum - выдавалась ошибка при конвертировании поля deci(pkdebtdat.info[2]), сказали колонка не нужна
        15/03/2005 madiyar - добавил колонки с %%-ой и штрафной ставками
        22/04/2005 madiyar - добавил колонку с фио менеджера, принявшего заявку
        15/08/2005 madiyar - учет комиссии за ведение тек. счета
        02/09/2005 marinav - PUSH отчет из pkmonall.
        08/09/2005 madiyar - мелкие изменения
        01/11/2005 madiyar - добавил внебаланс
        02/11/2005 madiyar - для вывода внебалансовых кредитов убрал отсев кредитов без дней просрочки
        10/02/2006 madiyar - добавилась обработка результата "leg" - передан в Юридический департамент
        25/04/2006 madiyar - добавил 4,5 уровни
        16/05/2006 madiyar - добавил статус "Z" - списанные за баланс
        03/07/2006 u00121  - в условии явно указал таблицу для поля lon, почему-то когда было указано просто поле lon, без указания таблицы, XREF показывал WHOLE-INDEX
                           - добавил индекс (idx1) в таблицу t-report
        02/08/2006 madiyar - небольшая оптимизация
        06/06/2008 madiyar - перенес изменения из pkmonall
        03/07/2008 madiyar - подправил формат отчета
        13/03/2009 madiyar - изменения согласно ТЗ 483 от ОМиВК
        03.04.2009 galina - исправила наименование файла для вывода отчета
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        05/02/2010 galina - добавила движимое и недвижимое имущество, счета в БВУ
        08/02/2010 madiyar - перекомпиляция
*/

{mainhead.i}
{pk.i new}

{pk-sysc.i}

{push.i}

def var coun as int init 1.
define variable datums  as date format "99/99/9999" label "На".
def var tempgrp as int.
def var v-chiefs as char init "elenal,damitov".
def var v-str as char.
def var v-delim as char init "^".
def var v-is-client as logical.
def var rwho_fio as char.

datums = vdt. /* PUSH - параметр */

{pkrepmon.i }
def temp-table t-report no-undo like wrk
  field sts       as    char        /* */
  field balmon    as    decimal     /* ежемесячный платеж */
  field lstdt     as    date        /* */
  field lstact    as    char        /* */
  field lstres    as    char        /* */
  field lstinf    as    char        /* */
  field nxtdt     as    date        /* */
  field lgrfdt    as    date        /* */
  field expsum    as    decimal     /* */
  field mngfio    as    char        /* */
  field posit     as    char        /* */
  field rnn       as    char        /* */
  field aliv      as    char        /* */
  field asign     as    char        /* */
  field is-cl     as    logical.

def new shared temp-table tmpcl no-undo
  field cif as char
  field rnn as char
  field is-cl as logical
  index idx is primary cif.

for each wrk:
    find cif where cif.cif = wrk.cif no-lock no-error.
    if avail cif and cif.item <> "" then do:
        create tmpcl.
        tmpcl.cif =  wrk.cif.
        tmpcl.rnn = entry(1, cif.item, "|").
        tmpcl.is-cl = no.
    end.
end.

{r-branch.i &proc = "chkcl"}

find first sysc where sysc.sysc = "PKCHIF" no-lock no-error.
if avail sysc then v-chiefs = trim(sysc.chval).

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to value(vfname).

find last cls where cls.whn < datums and cls.del no-lock no-error.
if avail cls then tempgrp = datums - 1 - cls.whn.

def var v-bank as char no-undo.
v-bank = comm-txb().

for each wrk no-lock:
    create t-report.
    buffer-copy wrk to t-report.

    /* расчет ежемесячного платежа */
    t-report.balmon = 0.
    find first lon where lon.lon = wrk.lon no-lock no-error.
    find first lnsch where lnsch.lnn = wrk.lon and lnsch.f0 > 0 no-lock no-error.
    find next lnsch where lnsch.lnn = wrk.lon and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then do:
        t-report.balmon = t-report.balmon + lnsch.stval.
        find first lnsci where lnsci.lni = wrk.lon and lnsci.f0 > 0 and lnsci.idat = lnsch.stdat no-lock no-error.
        if avail lnsci then t-report.balmon = t-report.balmon + lnsci.iv-sc.
    end.

    find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then t-report.balmon = t-report.balmon + tarifex2.ost.

    if wrk.bal13 + wrk.bal14 + wrk.bal30 > 0 then t-report.sts = "Z".
    else do:
        /* находим последнюю дату по графику */
        find last lnsch where lnsch.stdat < datums and lnsch.lnn = wrk.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
        if avail lnsch then do:
            t-report.lgrfdt = lnsch.stdat.

            find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = wrk.lon and pkdebtdat.rdt >= (datums - wrk.dt1) and pkdebtdat.rdt <= datums use-index lonrdt no-lock no-error.
            if avail pkdebtdat then do:
                t-report.sts = "K".

                find last pkdebtdat where pkdebtdat.bank = s-ourbank
                                          and pkdebtdat.lon = wrk.lon
                                          and pkdebtdat.rdt >= (datums - wrk.dt1)
                                          and pkdebtdat.rdt <= datums
                                          and (pkdebtdat.result = "part" or pkdebtdat.result = "secu" or pkdebtdat.result = "leg") use-index lonrdt no-lock no-error.
                if avail pkdebtdat then do:
                    if pkdebtdat.result = "part" then t-report.sts = "K,P".
                    else if pkdebtdat.result = "secu" then t-report.sts = "K,S".
                    else if pkdebtdat.result = "leg" then t-report.sts = "K,L".
                end.
            end.
            else t-report.sts = "N".
        end.
    end.

    find last pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = wrk.lon and pkdebtdat.rdt <= datums use-index lonrdt no-lock no-error.
    if avail pkdebtdat then do:
        t-report.lstdt = pkdebtdat.rdt.

        find ofc where ofc.ofc = pkdebtdat.rwho no-lock no-error.
        if avail ofc then
            t-report.mngfio = ofc.name.
         else
            t-report.mngfio = pkdebtdat.rwho.

        t-report.nxtdt = pkdebtdat.checkdt.

        find bookcod where bookcod.bookcod = 'pkdbtact' and bookcod.code = pkdebtdat.action no-lock no-error.
        if avail bookcod then
            t-report.lstact  = bookcod.name.

        find bookcod where bookcod.bookcod = 'pkdbtres' and bookcod.code = pkdebtdat.result no-lock no-error.
        if avail bookcod then
            t-report.lstres  = bookcod.name.
        t-report.lstinf  = pkdebtdat.info[1].

    end.

    find first cif where cif.cif = wrk.cif no-lock no-error.
    if avail cif then do:
        t-report.tel     = trim(cif.tel) + "," + trim(cif.tlx) + "," + trim(cif.fax) + "," + trim(cif.btel).
        t-report.job     = cif.ref[8].

        if cif.item <> "" then do:
          t-report.rnn = entry(1, cif.item, "|").
        end.


       if cif.dnb <> "" then do:
         v-str = entry(1, cif.dnb, "|").
         if num-entries(v-str, v-delim) > 1 then t-report.asign =  entry(2, v-str, v-delim).
         if num-entries(v-str, v-delim) > 2 then t-report.asign =  t-report.asign + " д." + entry(3, v-str, v-delim).
         if num-entries(v-str, v-delim) > 3 then t-report.asign =  t-report.asign + " кв."  + entry(4, v-str, v-delim).
         if num-entries(cif.dnb, "|") > 1 then do:
           v-str = entry(2, cif.dnb, "|").
           if num-entries(v-str, v-delim) > 1 then t-report.aliv = entry(2, v-str, v-delim).
           if num-entries(v-str, v-delim) > 2 then t-report.aliv = t-report.aliv + " д." +  entry(3, v-str, v-delim).
           if num-entries(v-str, v-delim) > 3 then t-report.aliv = t-report.aliv + " кв."  + entry(4, v-str, v-delim).
         end.
       end.

       find first tmpcl where tmpcl.cif = wrk.cif no-lock no-error.
       if avail tmpcl then t-report.is-cl = tmpcl.is-cl.

    end.

    find pkanketa where pkanketa.bank = v-bank and pkanketa.lon = wrk.lon no-lock no-error.
    if avail pkanketa then do:
         find first pkanketh where pkanketh.bank           = v-bank
                                   and pkanketh.ln         = pkanketa.ln
                                   and pkanketh.credtype   = pkanketa.credtype
                                   and pkanketh.kritcod    = "jobsn" no-lock no-error.
         if avail pkanketh then
             t-report.posit   = pkanketh.value1.
         else
             t-report.posit   = "".
    end.

end.

{html-title.i
        &title = "TEXAKABANK" &stream = "stream m-out" &size-add = "x-"}

put stream m-out unformatted
  "<TABLE border=""1"" cellpadding=""10"" cellspacing=""0""><TR><TD align=""left"">" cmp.name "</TD></TR>" skip.


put stream m-out unformatted
  "<TR><TD align=""center""><h3>Задолженность по ссудным счетам клиентов за " string(datums)
                 "<BR><BR></h3></TD></TR>" skip.

       put stream m-out unformatted "<TR><TD><table border=""1"" cellpadding=""10"" cellspacing=""0"" >" skip
                         "<tr style=""font:bold"" align=""left""><td rowspan=""2"">N</td>"
                         "<td rowspan=""2"">Код<br>клиента</td>"
                         "<td rowspan=""2"">Наименование заемщика</td>"
                         "<td rowspan=""2"">Номер<br>договора</td>"
                         "<td rowspan=""2"">Вид<br>кредита</td>"
                         "<td rowspan=""2"">Статус</td>"
                         "<td rowspan=""2"">День расчета<br>(ежемесячно)</td>"
                         "<td rowspan=""2"">Ставка<br>%%</td>"
                         "<td rowspan=""2"">Ставка<br>по штрафам</td>"
                         "<td rowspan=""2"">Валюта<br>кредита</td>"
                         "<td rowspan=""2"">Сумма<br>кредита</td>"
                         "<td rowspan=""2"">Остаток<br>долга</td>"
                         "<td rowspan=""2"">Ежемесячный<br>платеж</td>"
                         "<td rowspan=""2"">Сумма<br>на текущем счете</td>"
                         "<td rowspan=""2"">Сумма оплаты<br>за время просрочки</td>"
                         "<td rowspan=""2"">Итого задолженность<br>(без штрафов) </td>"

                         "<td rowspan=""2"">Просрочка ОД </td>"
                         "<td rowspan=""2"">Просрочка %</td>"
                         "<td rowspan=""2"">Задол-ть по ком.<BR>за вед. счета</td>"
                         "<td rowspan=""2"">Пеня</td>"
                         "<td rowspan=""2"">Штрафы, опл.<br>в тек. году</td>"
                         "<td rowspan=""2"">Списанная<br>пеня</td>"

                         "<td rowspan=""2"">Дней<br>просрочки %</td>"
                         "<td rowspan=""2"">Дней<br>просрочки ОД</td>"
                         "<td rowspan=""2"">Количество<br>просрочек</td>"

                         "<td rowspan=""2"">Списанные<br>%</td>"
                         "<td rowspan=""2"">Списанный<br>ОД</td>"
                         "<td rowspan=""2"">% (4 ур)</td>"
                         "<td rowspan=""2"">Пеня (5 ур)</td>"

                         "<td rowspan=""2"">Дата открытия<br>кредита</td>"
                         "<td rowspan=""2"">Дата последнего<br> погашения</td>"
                         "<td colspan=""4"">Последний контроль</td>"
                         "<td rowspan=""2"">Дата следующего<br>контроля</td>"
                         "<td rowspan=""2"">Телефоны</td>"
                         "<td rowspan=""2"">Место работы</td>"
                         "<td rowspan=""2"">Должность</td>"
                         "<td rowspan=""2"">РНН организации</td>"
                         "<td rowspan=""2"">Адрес<br>проживания </td>"
                         "<td rowspan=""2"">Адрес<br>прописки</td>"
                         "<td rowspan=""2"">Менеджер-контролер</td>"
                         "<td rowspan=""2"">Менеджер,<br>принявший заявку</td>"
                         "<td rowspan=""2"">Наличие недвижимого имущества</td>"
                         "<td rowspan=""2"">Наличие движимого имущества</td>"
                         "<td rowspan=""2"">Счета в БВУ</td>"
                         "</tr>" skip.

       put stream m-out unformatted "</tr><tr style=""font:bold"" align=""center"" >"
                         "<td align=""center"" >Дата      </td>"
                         "<td align=""center"" >Действие  </td>"
                         "<td align=""center"" >Результат </td>"
                         "<td align=""center"" >Причина   </td>"
                         "</tr>" skip.

find last cls where cls.whn < datums no-lock no-error.
tempgrp = datums - 1 - cls.whn.
for each t-report break by t-report.crc desc by t-report.stype by t-report.name.

  find crc where crc.crc = t-report.crc no-lock no-error.

        if t-report.rwho <> '' then do:
            find first ofc where ofc.ofc = t-report.rwho no-lock no-error.
            if avail ofc then rwho_fio = ofc.name.
            else rwho_fio = ''.
        end.

        put stream m-out unformatted
          "<tr align=""left"">"
               "<td>" string(coun)   "</td>"
               "<td align=""left""" if t-report.bal1 < 1 then " style=""font:bold;color:green""" else "" "> " t-report.cif "</td>"
               "<td>" if t-report.is-cl then "<font color=""blue"">" else "<font color=""black"">" t-report.name "</font></td>"
               "<td>" t-report.lcnt "</td>"
               "<td>" t-report.stype "</td>"
               "<td>" t-report.sts   "</td>"
               "<td>" string(t-report.day) "</td>"
               "<td>" replace(trim(string(t-report.prem, ">>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.pen_prem, ">>9.99")),".",",") "</td>"
               "<td>" crc.code "</td>"
               "<td>" replace(trim(string(t-report.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.balans - t-report.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.balmon, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.aaabal, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.sum_in, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(t-report.bal1 + t-report.bal2 + t-report.com_acc, "->>>>>>>>>>>9.99")),".",",") "</td>"

               "<td" if t-report.bal1 < 1 then " style=""font:bold;color:green""" else "" ">" replace(trim(string(t-report.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td >" replace(trim(string(t-report.com_acc, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(t-report.balpen, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.pen_paid, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(t-report.bal30, "->>>>>>>>>>>9.99")),".",",") "</td>"

               "<td>" t-report.dt2 format "->>>9" "</td>"
               "<td>" t-report.dt1 format "->>>9" "</td>"
               "<td>" t-report.pr_kol format "->>>9" "</td>"

               "<td style=""font:bold"">" replace(trim(string(t-report.bal14, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(t-report.bal13, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(t-report.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>"

               "<td>" t-report.rdt format "99.99.9999" "</td>"
               "<td>" t-report.duedt format "99.99.9999" "</td>"
               "<td>" if t-report.lstdt = ? then "" else string(t-report.lstdt, "99.99.9999") "</td>" skip
               "<td>" t-report.lstact "</td>" skip
               "<td>" t-report.lstres "</td>" skip
               "<td>" t-report.lstinf "</td>" skip
               "<td>" if t-report.nxtdt = ? then "" else string(t-report.nxtdt, "99.99.9999") "</td>" skip
               "<td>&nbsp;" t-report.tel "</td>" skip
               "<td>" t-report.job             "</td>" skip
               "<td>" t-report.posit           "</td>" skip
               "<td>" "'" string(t-report.rnn, "x(12)")  "</td>" skip
               "<td>" t-report.aliv            "</td>" skip
               "<td>" t-report.asign           "</td>" skip
               "<td>" t-report.mngfio          "</td>" skip
               "<td>" rwho_fio                 "</td>" skip
               "<td>" t-report.realp           "</td>" skip
               "<td>" t-report.movp            "</td>" skip
               "<td>" t-report.acc             "</td>" skip
               "</tr>" skip.
         coun = coun + 1.
end.

put stream m-out "</table></TD></TR></TABLE>" skip.
{html-end.i "stream m-out"}

output stream m-out close.

vres = yes. /* успешное формирование файла */
pause 0.



