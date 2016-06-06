/* msfosk1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет 5% СК за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29/07/2011 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        25/10/2011 madiyar - фиксируем даты начала истории
        27/03/2012 madiyar - добавил счет 330000
        21/11/2013 Sayat(id01143) - ТЗ 2212 от 15/11/2013 "Изменения в расчет СК для провизий МСФО" теперь берем только остаток на 399990
*/

def var v-dtst as date no-undo.
v-dtst = 06/01/2010.

def shared var dt0rep as date no-undo.

def shared temp-table wrksk no-undo
    field dtrep as date
    field dt as date
    field sk as deci
    field sk5 as deci
    index idx is primary dtrep.

def var v-dtrep as date no-undo.
def var v-dt as date no-undo.
def var v-sk as deci no-undo.
def var i as integer no-undo.

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

v-dtrep = get-date(v-dtst, 1).
v-dt = v-dtst.

repeat:

    v-sk = 0.
    /*
    find last txb.glday where txb.glday.gl = 300000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt no-lock no-error.
    if avail txb.glday then v-sk = txb.glday.bal.

    find last txb.glday where txb.glday.gl = 330000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt no-lock no-error.
    if avail txb.glday then v-sk = v-sk + txb.glday.bal.

    find last txb.glday where txb.glday.gl = 350000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt no-lock no-error.
    if avail txb.glday then v-sk = v-sk + txb.glday.bal.
    */
    find last txb.glday where txb.glday.gl = 399990 and txb.glday.crc = 1 and txb.glday.gdt < v-dt no-lock no-error.
    if avail txb.glday then v-sk = txb.glday.bal.

    find first wrksk where wrksk.dtrep = v-dtrep no-error.
    if not avail wrksk then do:
        create wrksk.
        wrksk.dtrep = v-dtrep.
        wrksk.dt = v-dt.
    end.
    wrksk.sk = wrksk.sk + v-sk.

    v-dt = v-dtrep.
    v-dtrep = get-date(v-dtrep, 1).
    if v-dtrep > dt0rep then leave.

end.

