/* msfosk2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет 5% СК
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
        27/03/2012 madiyar - добавил счет 330000
        21/11/2013 Sayat(id01143) - ТЗ 2212 от 15/11/2013 "Изменения в расчет СК для провизий МСФО" теперь берем только остаток на 399990
*/

def shared var v-dt as date no-undo.
def var v-dt1 as date no-undo.

v-dt1 = date(month(v-dt - 1), 1, year(v-dt - 1)).

def shared var v-sum_msb as deci no-undo.
/*
find last txb.glday where txb.glday.gl = 300000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt1 no-lock no-error.
if avail txb.glday then v-sum_msb = v-sum_msb + txb.glday.bal.

find last txb.glday where txb.glday.gl = 330000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt1 no-lock no-error.
if avail txb.glday then v-sum_msb = v-sum_msb + txb.glday.bal.

find last txb.glday where txb.glday.gl = 350000 and txb.glday.crc = 1 and txb.glday.gdt < v-dt1 no-lock no-error.
if avail txb.glday then v-sum_msb = v-sum_msb + txb.glday.bal.
*/
find last txb.glday where txb.glday.gl = 399990 and txb.glday.crc = 1 and txb.glday.gdt < v-dt1 no-lock no-error.
if avail txb.glday then v-sum_msb = v-sum_msb + txb.glday.bal.
