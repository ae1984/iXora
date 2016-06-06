/* cfcalcdtl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * BASES
        BANK
* CHANGES

        21.04.2011 damir - новые переменные v-kolduedt, v-date, v-kollong
*/


{global.i}

def input parameter p-cif as char.      /* код клиента */
def var d1 as date no-undo.

def var v-rate as decimal no-undo.

def var v-ost as decimal no-undo.
def var dayc_od as int  no-undo.
def var dayc_prc as int no-undo.
def var v-cur as char no-undo.

def var v-npay as decimal no-undo.
def var v-npay_usd as decimal no-undo.
def var v-nsum as int no-undo.
def var v-mrp as int.

def var v-npay_prc as int no-undo.
def var v-rmrp     as int no-undo.
def var v-rst      as char extent 6.
def var i-rst      as int no-undo.
def var v-crc      as int no-undo.
def var v-kolduedt as int no-undo.
def var v-kollong  as int no-undo.
def var v-long     as int no-undo.
def var v-date     as date no-undo.



v-rst[1] = 'Стабильное'.
v-rst[2] = 'Удовлетворительное'.
v-rst[3] = 'Неудовлетворительное'.
v-rst[4] = 'Нестабильное'.
v-rst[5] = 'Kритическое'.
v-rst[6] = '---------'.

d1 = g-today.

v-npay = 0. v-npay_usd = 0.
dayc_od = 0. dayc_prc = 0.

for each lon where lon.cif = p-cif no-lock:

    /*Остаток ОД(в валюте) */
    run lonbalcrc('lon',lon.lon,d1,"1,7",no,lon.crc,output v-ost).
    If v-ost > 0 then do:

        find last crchis where crchis.crc = lon.crc and crchis.rdt <= d1  use-index crcrdt no-lock.
        if not available crchis then do:
            v-rate =  1.
        end.
        else do:
            v-rate =  crchis.rate[1].
        end.

        /*Дней просрочки*/
        run lndayspr(lon.lon,d1,no,output dayc_od,output dayc_prc).
        /*Валюта*/
        find first crc where crc.crc = lon.crc no-lock no-error.
        if available crc then v-cur = crc.des.

        find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat < d1 no-lock no-error.
        if available lnsch then v-npay = v-npay + lnsch.stval.
        find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat < d1 no-lock no-error.
        if available lnsci then v-npay = v-npay + lnsci.iv-sc.
        find last tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
        if available tarifex2 then  v-npay = v-npay + tarifex2.ost.

        v-crc = lon.crc.
        If v-crc = 1 then do:
            v-npay_usd = v-npay / v-rate.
        end.
        else do:
            v-npay_usd = v-npay.
            v-npay =  v-npay * v-rate.
        end.
        leave.
    end.

    /* Находим первую дату из истории изменений ссудных счетов *//*Дамир*/
    find first ln%his where ln%his.lon = lon.lon no-lock no-error.
    if avail ln%his then v-date = ln%his.duedt.

    v-kolduedt = 0.
    v-kollong  = 0.
    v-long = 0.

    /*Расчет количества пролонгаций по кредиту*//*Дамир*/
    for each ln%his where ln%his.lon = lon.lon no-lock:
        if v-date <> ln%his.duedt then do:
            v-kolduedt = v-kolduedt + 1.
            v-date = ln%his.duedt.
        end.
    end.
    /*message v-kolduedt view-as alert-box.
    message v-kollong  view-as alert-box.*/

    /*Поля пролонгация 1 и пролонгация 2 учитываются*/
    if lon.ddt[5] <> ? then v-kollong = 1.
    if lon.cdt[5] <> ? then v-kollong = 2.

    v-long = v-kolduedt + v-kollong.
end.



/*-----------ВНЕСЕНИЕ ТЕКУЩИХ ДАННЫХ------------------*/
update
v-nsum label 'СУММА ЧИСТОГО ДОХОДА'
help "Введите сумму чистого дохода." skip(1)
with row 8 centered title '[ВНЕСЕНИЕ ТЕКУЩИХ ДАННЫХ]' side-label frame opt.

display
v-npay format ">>>>>>>>>>>>>>>9.99" label 'СУММА ЕЖЕМЕСЯЧНОГО ПЛАТЕЖА' skip(1)
v-npay_usd format ">>>>>>>>>>>>>>>9.99" label 'СУММА ЕЖЕМЕСЯЧНОГО ПЛАТЕЖА В USD ' skip(1)
v-cur label 'ВАЛЮТА ' skip(1)
with frame opt.

v-mrp = 1512.
update
v-mrp label 'МРП'
help "Введите МРП."  skip(1)
with frame opt.

/*-----------ИТОГ------------------*/
v-npay_prc = int((v-npay / v-nsum) * 100).
v-rmrp = int(v-nsum / v-mrp).
i-rst = 6.

/*Kритическое*/
if (v-npay_prc > 60) and (v-rmrp <= 40) Then i-rst = 5.
if (v-npay_prc > 70) and (v-rmrp > 40) Then i-rst = 5.

/*Нестабильное*/
if (v-npay_prc <= 60) and (v-rmrp <= 40) Then i-rst = 4.
if (v-npay_prc <= 70) and (v-rmrp > 40) and (v-rmrp <= 65) Then i-rst = 4.
if (v-npay_prc > 70) and (v-rmrp > 65)  Then i-rst = 4.

/* Неудовлетворительное */
if (v-npay_prc <= 50) and (v-rmrp <= 40) Then i-rst = 3.
if (v-npay_prc <= 60) and (v-rmrp > 40) and (v-rmrp <= 65) Then i-rst = 3.
if (v-npay_prc <= 70) and (v-rmrp > 65) and (v-rmrp <= 90) Then i-rst = 3.
if (v-npay_prc > 70) and (v-rmrp > 90)  Then i-rst = 3.

/* Удовлетворительное - по суммам те же условия, пока пропускаем */

/* Стабильное */
if (v-npay_prc <= 40) and (v-rmrp <= 40) Then i-rst = 1.
if (v-npay_prc <= 50) and (v-rmrp > 40) and (v-rmrp <= 65) Then i-rst = 1.
if (v-npay_prc <= 60) and (v-rmrp > 65) and (v-rmrp <= 90) Then i-rst = 1.
if (v-npay_prc <= 70) and (v-rmrp > 90) Then i-rst = 1.

/* При просрочке более 60 дней - критическое */
if dayc_od > 60 Then i-rst = 5.

/* Анализ пролонгаций */
if v-long >= 4 then i-rst = 5.
else
if i-rst < 4 and v-long = 3 then i-rst = 4.
else
if i-rst < 3 and v-long = 2 then i-rst = 3.
else
if i-rst < 2 and v-long = 1 then i-rst = 2.

/* Если по суммам проставился статус неуд, и пролонгаций не более 1, то меняем статус на уд */
if i-rst = 3 and v-long <= 1 then i-rst = 2.

if v-crc <> 1 Then do:
  if i-rst < 5 Then i-rst = i-rst + 1.
end.

/*Запись ведется в таблицу ciffinsost*/
do transaction on error undo, retry:
    find first ciffinsost where ciffinsost.cif = p-cif exclusive-lock no-error.
    if not avail ciffinsost then do:
        create ciffinsost.
        ciffinsost.cif = p-cif.
    end.
    ciffinsost.sumdohod = v-nsum.
    ciffinsost.finsost = v-rst[i-rst].
    ciffinsost.rwho = g-ofc.
    find current ciffinsost no-lock.
end.


display 'ЕЖЕМЕСЯЧНЫЙ ПЛАТЕЖ НЕ ПРЕВЫШАЕТ ' + string(v-npay_prc) + '% ОТ СУММЫ ЧИСТОГО ДОХОДА' format 'x(70)' skip(1)
v-rmrp label 'МРП СОСТАВЛЯЕТ' skip(1)
v-long label 'КОЛИЧЕСТВО ПРОЛОНГАЦИЙ' format ">9" skip(1)
v-rst[i-rst] format 'x(15)' label 'ФИНАНСОВОЕ СОСТОЯНИЕ' skip(1)
dayc_od label 'КОЛИЧЕСТВО ДНЕЙ ПРОСРОЧКИ' skip(1)
with row 20 centered title '[ИТОГ]' side-label frame dtl.


