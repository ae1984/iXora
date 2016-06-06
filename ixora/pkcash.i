/* pkcash.i
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Подборка временной таблицы для списка задолжников по БД и БК
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-16
 * AUTHOR
        05.11.2003 marinav
 * CHANGES
        13.12.2003 nadejda - вынесла формирование временной таблицы в pkcash.i для использования в pkletter.p
        19.12.2003 nadejda - оптимизация поиска pkanketa
        06.01.2004 nadejda - в подсчет дней просрочки поставила условие <= для учета сегодняшнего дня в графике
        23.01.2004 nadejda - округлить все суммы задолженности в сторону ближайшего большего целого значения
        01.02.2004 nadejda - добавлен контактный телефон
                             сумма на тек.счете
        10.02.2004 nadejda - добавлена дата погашения ссудного счета и день расчета
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        07.03.2004 tsoy изменил алгоритм, в wrk попадают все записи (не только с задолж. ОД) потом удаляются у кот задол. нет.
        18/08/2004 madiyar - Добавил поле wrk.sts
        07/09/2004 madiyar - Добавил поле wrk.note
        06/10/2004 madiyar - В отчет выводятся только БД и БК
        13/06/2005 madiyar - три новые колонки (проц. ставка, ставка по штрафам, задолженность по комиссии)
        23/06/2005 madiyar - ежемесячный платеж - берем вторую запись в графике (первая может составлять не полный месяц)
        07/09/2005 madiyar - переделал с использованием таблицы londebt
        01/11/2005 madiyar - Добавил внебаланс
        02/11/2005 madiyar - Внебалансовые кредиты отсеивались, исправил
        03/11/2005 madiyar - Небольшие изменения
        08/02/2006 Natalya D. - добавила поля по начисленным за балансом % и штрафам (bal4 & bal5)
        31/03/2006 madiyar - анкеты kazpost - вид "kp"
        16/05/2006 madiyar - добавил статус "Z" - списанные за баланс
        02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
        05/10/2006 madiyar - добавил 4 и 5 уровни в проверку для отсеивания кредитов
        03/11/2006 madiyar - добавил параметр {&kazpost}
        25/05/2007 madiyar - убрал лишнее (казпочта, поиск анкеты)
        24/02/2009 galina - добавила поля комиссионный долг в тенге, комиссионный долг в валюте кредита, валюта кредита
        15/09/2009 galina - выводим фактические дни просрочки ОД
        08/02/2010 madiyar - перекомпиляция
*/


def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
def var v-aaa as char no-undo.
def var v-days_prc as integer no-undo.

def temp-table wrk no-undo
    field lon    like lon.lon
    field cif    like lon.cif
    field name   like cif.name
    field dt1    as   inte
    field bal1   like lon.opnamt /* пеня 16 ур*/
    field bal2   like lon.opnamt /* %%  9 ур */
    field bal3   like lon.opnamt /* ОД 7 ур */
    field balmon   like lon.opnamt /* размер ежемес платежа */
    field bal13  as deci
    field bal14  as deci
    field bal4  as deci
    field bal30  as deci
    field bal5  as deci
    field aaabal as decimal
    field tel as char
    field type as char
    field stype as char
    field day as integer
    field expdt as date
    field sts as char
    field note as char
    field prem as deci
    field pen_prc as deci
    field com_acc as deci
    field com_acckzt as deci
    field crc like crc.code
    field prkol as integer
    index name is primary name.

def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.
def var m-payment as decimal no-undo init 0.

def var v-bal as decimal no-undo format "->,>>>,>>>,>>9.99" extent 2.
/*
def var bilance   as decimal format "->,>>>,>>>,>>9.99".
def var bilancepl as decimal format "->,>>>,>>9.99".
*/
def var bil1 as decimal no-undo format "->,>>>,>>9.99".
def var bil2 as decimal no-undo format "->,>>>,>>9.99".
def var vcu like lon.opnamt no-undo extent 6 decimals 2.
def var f-dat1 as date no-undo.
def var tempdt as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var v-credtype as char no-undo.

def var v-respr as integer no-undo.
def var v-maxpr as integer no-undo.
def var v-lnlast as integer no-undo.

def var counn as integer no-undo init 0.

for each londebt where {&param} no-lock:

     if not (londebt.grp = 90 or londebt.grp = 92) then next.

     find first lon where lon.lon = londebt.lon no-lock no-error.

     find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
     if not avail pkanketa then next.
     v-credtype = pkanketa.credtype.

     run lonbalcrc('lon',lon.lon,datums,"1,7,2,4,9,13,14",yes,lon.crc,output v-bal[1]).
     run lonbalcrc('lon',lon.lon,datums,"5,16,30",yes,1,output v-bal[2]).
     if v-bal[1] + v-bal[2] <= 0 then next.

     find cif where cif.cif = lon.cif no-lock.

     find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
     find first loncon where loncon.lon = lon.lon no-lock no-error.
     create wrk.
     assign wrk.cif = lon.cif
            wrk.lon = lon.lon
            wrk.name = cif.name
            wrk.tel = trim(cif.tel) + "," + trim(cif.tlx) + "," + trim(cif.fax)  + "," + trim(cif.btel)
            /*wrk.dt1 = londebt.days_od*/
            wrk.type = bookcod.name
            wrk.day = lon.day
            wrk.expdt = lon.duedt
            wrk.prem = lon.prem
            wrk.pen_prc = loncon.sods1.

            run lndaysprf(lon.lon,datums, yes, output wrk.dt1, output v-days_prc).

    if pkanketa.id_org = '' then wrk.stype = bookcod.info[1].
    else if pkanketa.id_org = "kazpost" then wrk.stype = "kp".

    run lonbalcrc('lon',lon.lon,datums,"13",yes,lon.crc,output wrk.bal13).
    run lonbalcrc('lon',lon.lon,datums,"14",yes,lon.crc,output wrk.bal14).
    run lonbalcrc('lon',lon.lon,datums,"30",yes,1,output wrk.bal30).
    run lonbalcrc('lon',lon.lon,datums,"4",yes,lon.crc,output wrk.bal4).
    run lonbalcrc('lon',lon.lon,datums,"5",yes,1,output wrk.bal5).

    if num-entries(cif.dnb, "|") > 2 then wrk.note = entry(3, cif.dnb, "|").

    find first lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then do:
      find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
      if avail lnsci then wrk.balmon = lnsci.iv-sc.
      find next lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
      if avail lnsci then wrk.balmon = lnsci.iv-sc.
      wrk.balmon = wrk.balmon + lnsch.stval.
    end.

     wrk.bal1 = londebt.penalty.
     wrk.bal2 = londebt.prc.
     wrk.bal3 = londebt.od.

    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then  wrk.crc = crc.code.
    else message "Не найдена валюта " + string(lon.crc) view-as alert-box.

     run pkdiscount(pkanketa.rnn, -1, no, output v-respr, output wrk.prkol, output v-maxpr, output v-lnlast).

     if pkanketa.crc = 1 then v-aaa = pkanketa.aaa.
                         else v-aaa = pkanketa.aaaval.
     find aaa where aaa.aaa = v-aaa no-lock no-error.
     wrk.aaabal = aaa.cr[1] - aaa.dr[1].

     if pkanketa.rdt >= 05/17/2005 then do:
       for each bxcif where bxcif.cif = cif.cif and bxcif.crc = lon.crc no-lock:
         wrk.com_acc = wrk.com_acc + bxcif.amount.
       end.
       for each bxcif where bxcif.cif = cif.cif and bxcif.crc = 1 no-lock:
         wrk.com_acckzt = wrk.com_acckzt + bxcif.amount.
       end.

     end.

     counn = counn + 1.
     /*
     hide message no-pause.
     message ' ' counn ' '.
     */

end.

/* округлить все суммы задолженности в сторону ближайшего большего целого значения */
for each wrk where wrk.bal1 + wrk.bal2 + wrk.bal3 > 0:
    if (wrk.bal1) > 0 and (wrk.bal1 - truncate (wrk.bal1, 0) > 0) then wrk.bal1 = truncate (wrk.bal1, 0) + 1.
    if (wrk.bal2) > 0 and (wrk.bal2 - truncate (wrk.bal2, 0) > 0) then wrk.bal2 = truncate (wrk.bal2, 0) + 1.
    if (wrk.bal3) > 0 and (wrk.bal3 - truncate (wrk.bal3, 0) > 0) then wrk.bal3 = truncate (wrk.bal3, 0) + 1.
end.

/*
for each wrk where wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.bal13 + wrk.bal14 + wrk.bal30 <= 0:
  delete wrk.
end.
*/
