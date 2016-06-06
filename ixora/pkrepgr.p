/* pkrepgr.p
 * MODULE
        ПотребКредиты
 * DESCRIPTION
        Кредиты, по которым наступил срок погашения на указанную дату
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT
        pkrepgrdat.p
 * MENU

 * AUTHOR
        05/03/03 marinav
 * CHANGES
        25.01.2004 nadejda - вынесла сбор данных в отдельную программу для использования в сводном отчете
        30.01.2003 nadejda - добавлены сведения об остатке на тек.счете на дату отчета, на 14-00 и 20-00 даты отчета
        13.02.2004 nadejda - добавлены суммы просрочек и пеня
        24.02.2004 nadejda - добавлена предоплата
        19.04.2004 nadejda - добавлены фактически начисленные проценты
        29.04.2004 nadejda - изменены названия столбцов для ясного понимания смысла данных (остатки на тек.момент!)
        13.05.2004 tsoy    - показываем синим цветом тех кто являются работниками наших клиентов
        12/07/2004 madiyar - закомментировал столбцы "Ссудный счет", "Текущий счет", "Валюта", "Предоплата % (остаток на тек.момент)"
                             добавил столбцы "Дата выдачи кредита" и "Ежемес платеж"
        14.09.2004 saltanat - добавила выделение желтым фоном клиентов с плат. картами
        20.09.2004 saltanat - включила дисконект базы Cards.
        30.09.2004 saltanat - включила проверку на статус карточки
        16/04/2007 madiyar - полностью переделал отчет
        10/01/08 marinav -   if not avail lon then next.
        24/01/2008 madiyar - при наличии, по клиенту подтягиваются обновленные данные
        28.04.2008 alex - добавил в отчет "Дополнительные данные"
        21/10/2008 madiyar - поиск ссудника - по номеру сс. счета и по коду клиента (чтобы не путать с МКОшными)
        29.04.2009 galina - красим в синий цвет код клиента, если достаточно средств для очередного взноса
                            красим в красный цвет код клиента, если есть задолженность
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

{mainhead.i}

def var coun as int no-undo.
def var datums as date no-undo format "99/99/9999".
def var datums2 as date no-undo format "99/99/9999".
def var dat as date no-undo format "99/99/9999".
def var v-balans as decimal  no-undo.
def var v-balans1 as decimal  no-undo.
def var v-note as char.

datums = g-today.
datums2 = g-today.
update datums label "Период с" format "99/99/9999"
       datums2 label "по" format "99/99/9999" skip
       with side-label row 5 centered frame dat.

dat = datums2.
if dat > g-today then dat = g-today.

def temp-table wrk no-undo
    field lon      like lon.lon
    field cif      like lon.cif
    field name     like cif.name
    field rdt      like lon.rdt
    field day      as   integer
    field opnamt   like lon.opnamt
    field pay_od   like lon.opnamt
    field pay_prc  like lon.opnamt
    field pay_com  like lon.opnamt
    field aaaval   like lon.opnamt
    field crc      like crc.code
    field prem     like lon.prem
    field hphone   as char
    field rphone   as char
    field kphone   as char
    field mobphone   as char
    field position as char
    field job      as char
    field note     as char
    index main is primary day name.

message " Формируется отчет...".

{comm-txb.i}
define new shared var s-ourbank as char.
s-ourbank = comm-txb().

for each pkanketa where pkanketa.bank = s-ourbank no-lock:

    if pkanketa.lon = "" then next.
    find first lon where lon.lon = pkanketa.lon and lon.cif = pkanketa.cif no-lock no-error.
    if not avail lon then next.
    if lon.opnamt <= 0 then next.
    if lon.sts = 'C' then next.
    /*
    run lonbalcrc('lon',lon.lon,dat,"1,7",yes,lon.crc,output bilance).
    if bilance = 0 then next.
    */

    v-balans = 0.
    find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= datums and lnsch.stdat <= datums2 no-lock no-error.
    if avail lnsch then v-balans = lnsch.stval.

    v-balans1 = 0.
    find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat >= datums and lnsci.idat <= datums2 no-lock no-error.
    if avail lnsci then v-balans1 = lnsci.iv-sc.

    /* показываем только тех, у кого этот день по графику */
    if v-balans + v-balans1 <= 0 then next.

    find first cif where cif.cif = lon.cif no-lock no-error.
    find first crc where crc.crc = lon.crc no-lock no-error.

    if num-entries(cif.dnb, "|") > 2 then v-note = entry(3, cif.dnb, "|"). else v-note = "".

    create wrk.
    assign wrk.lon = lon.lon
           wrk.cif = lon.cif
           wrk.name = trim(pkanketa.name)
           wrk.rdt = lon.rdt
           wrk.day = lon.day
           wrk.opnamt = lon.opnamt
           wrk.crc = crc.code
           wrk.prem = lon.prem
           wrk.pay_od = v-balans
           wrk.pay_prc = v-balans1
           wrk.note = v-note.

    find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then wrk.pay_com = tarifex2.ost.

    if pkanketa.crc = 1 then find aaa where aaa.aaa = pkanketa.aaa no-lock no-error.
    else find aaa where aaa.aaa = pkanketa.aaaval no-lock no-error.
    if avail aaa then wrk.aaaval = aaa.cr[1] - aaa.dr[1].

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.hphone = trim(pkanketh.value1).
    if trim(cif.tel) <> '' then wrk.hphone = trim(cif.tel).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel2" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.rphone = trim(pkanketh.value1).
    if trim(cif.tlx) <> '' then wrk.rphone = trim(cif.tlx).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel3" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.kphone = trim(pkanketh.value1).
    if trim(cif.btel) <> '' then wrk.kphone = trim(cif.btel).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel4" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.mobphone = trim(pkanketh.value1).
    if trim(cif.fax) <> '' then wrk.mobphone = trim(cif.fax).


    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobsn" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.position = trim(pkanketh.value1).

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.job = trim(pkanketh.value1).
    if trim(cif.ref[8]) <> '' then wrk.job = trim(cif.ref[8]).

end.


/* вывод отчета */
find first cmp no-lock no-error.
define stream m-out.
output stream m-out to srok.html.

{html-title.i &stream = "stream m-out" &size-add = "x-"}

put stream m-out unformatted "<table border=0><tr><td><h3>" cmp.name "</h3></td></tr><br>" skip.

put stream m-out unformatted "<tr><td align=""center""><h3>Кредиты, по которым наступил срок платежа с " string(datums) " по " string(datums2)
                 "</h3></td></tr><BR>" skip
                 "<TR><TD>&nbsp;</TD></TR>" skip.

put stream m-out unformatted
    "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">"
    "<td>N<br>п/п</td>"
    "<td>Номер</td>"
    "<td>Наименование заемщика</td>"
    "<td>День<br>расчета</td>"
    "<td>Дата<br>выдачи<br>кредита</td>"
    "<td>Выданная<br>сумма<br>кредита</td>"
    "<td>Платеж ОД</td>"
    "<td>Платеж %%</td>"
    "<td>Платеж<br>комиссия</td>"
    "<td>Общая сумма<br>к погашению</td>"
    "<td>Остаток<br>на счете<br>(текущий)</td>"
    "<td>Тел. дом.</td>"
    "<td>Тел. раб.</td>"
    "<td>Тел. конт.</td>"
    "<td>Тел. сот.</td>"
    "<td>Дополнительные данные</td>"
    "<td>Должность</td>"
    "<td>Место<br>работы</td>"
    "<td>Менеджер-контролер</td>"
    "</tr>" skip.

coun = 1.
for each wrk break by wrk.day.
    find first londebt where londebt.lon = wrk.lon no-lock no-error.

    if avail londebt then put stream m-out unformatted "<tr  bgcolor=""red"">" skip.
    else do:
      if wrk.aaaval >= (wrk.pay_od + wrk.pay_prc) then put stream m-out unformatted
       "<tr  bgcolor=""#00CCFF"">" skip.
      else put stream m-out unformatted
       "<tr>" skip.
    end.

          put stream m-out unformatted
          "<td align=""center"">" coun "</td>" skip
          "<td align=""center"">" wrk.cif "</td>" skip
          "<td>" wrk.name "</font></td>" skip
          "<td>" wrk.day "</td>" skip
          "<td>" wrk.rdt format "99/99/9999" "</td>" skip
          "<td>" replace(trim(string(wrk.opnamt, ">>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
          "<td>" replace(trim(string(wrk.pay_od, ">>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
          "<td>" replace(trim(string(wrk.pay_prc, ">>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
          "<td>" replace(trim(string(wrk.pay_com, ">>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
          "<td><b>" replace(trim(string(wrk.pay_od + wrk.pay_prc + wrk.pay_com, ">>>>>>>>>>>>>>>9.99")), ".", ",") "<b></td>"
          "<td>" replace(trim(string(wrk.aaaval, ">>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
          "<td>" wrk.hphone "</td>" skip
          "<td>" wrk.rphone "</td>" skip
          "<td>" wrk.kphone "</td>" skip
          "<td>" wrk.mobphone "</td>" skip
          "<td>" wrk.note "</td>" skip
          "<td>" wrk.position "</td>" skip
          "<td>" wrk.job "</td>" skip
          "<td></td>" skip
        "</tr>" skip.

    coun = coun + 1.

end.

put stream m-out unformatted "</table></td></tr></table>" skip.
{html-end.i "stream m-out"}

output stream m-out close.

hide message no-pause.

unix silent cptwin srok.html excel.