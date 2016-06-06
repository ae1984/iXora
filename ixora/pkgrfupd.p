/* pkgrfupd.p
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
 * CHANGES
        24.09.2003 marinav - При пресчете графика изменить lon.day
        08.04.2004 suchkov - изменили алгоритм пересчета графика для 3 схемы
        09.04.2004 nadejda - изменила алгоритм пересчета графика для 3 схемы - последняя дата не больше даты окончания кредита
        30.04.2004 nadejda - если последняя дата графика меньше даты окончания кредита - ставим ее равной дате окончания кредита
        20/05/2004 madiyar - добавил схему 4 (пересчет такой же, как в 3-ей схеме)
        30/09/2004 madiyar - желаемый день погашения может быть только с 1 по 24
        24/01/2005 madiyar - 4 схема: если кредитный месяц меньше или больше 30 дней - изменяем сумму процентов в графике
        26/01/2005 madiyar - 4 схема: забыл no-error
        11.04.05 saltanat - Добавила сохранение истории при изменении графика.
        31/05/2005 madiyar - схема 5
        13/09/2007 madiyar - ограничение на день погашения (до 20 числа)
        17/06/2008 madiyar - по коммерсантам c 4ой схемой пересчет графика невозможен
        25/11/2008 galina - схема 1 и 0 в этой программе не обрабатывается
                            проверка корректности введенной даты выделила в функцию
                            изменила внешний вид фрейма dat
        28/11/2008 galina - явно указала тразакционные блоки для критичных изменений в графике
        11/02/2009 galina - если перенос графика идет с первого платежа, проценты для первого платежа вычисляем с даты выдачи кредита
        29/10/2009 madiyar - добавил поле com в шаренную таблицу
*/

{global.i}
{pk.i}

def var i as inte.
def var j as inte.
define variable v-dtend as date.
define variable v-dt     as date format "99/99/9999".
define var v-summa as deci.
def var dt as date.
def var v-dt1 as date no-undo.
def var v-dt0 as date no-undo.
def var v-dt00 as date no-undo.
def var v-dt2 as date no-undo.
def var v-payod as decimal no-undo.
def var v-payprc as decimal no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.

def var v-msg as char.

function chk-date returns char (input p-dt as date, input p-lon as char, input p-dtend as date).
  find lon where lon.lon = p-lon no-lock.
  if p-dt > g-today and p-dt < p-dtend and day(p-dt) < 20 then v-msg = "".
  if p-dt <= g-today then v-msg = "Дата должна быть > текущей!".
  if p-dt >= p-dtend then do:
    if day(p-dtend) = day(lon.duedt) then v-msg = "Дата должна быть < следующей даты графика. День должен быть < дня окончания срока действия кредита!".
    else v-msg = "Дата должна быть < следующей даты графика!".
  end.
  if day(p-dt) >= 20 then v-msg = "Выберите день с 1 по 19!".
  return v-msg.
end.

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
/**********************/

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
         pkanketa.ln = s-pkankln no-lock no-error.

find lon where lon.lon = pkanketa.lon no-lock.
if not avail lon then do:
    message "Пересчет графика невозможен!" view-as alert-box error.
    return.
end.

if lon.plan = 4 then do:
    message "По коммерсантам c 4ой схемой пересчет графика невозможен!" view-as alert-box error.
    return.
end.

run atl-dat(lon.lon,g-today,output v-summa).
if v-summa = 0 then do:
   message skip " Сумма на счете равна 0 !" skip(1)
     view-as alert-box buttons ok .
   return.
end.
/*19/11/2008 galina дата последнего платежа*/
find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
if avail lnsch then v-dt0 = lnsch.stdat.
else do:
    message "Некорректный график!" view-as alert-box error.
    return.
end.

/*19/11/2008 galina дата предпоследнего платежа*/
find prev lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
if avail lnsch then v-dt00 = lnsch.stdat.
else do:
    message "Некорректный график!" view-as alert-box error.
    return.
end.

find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock no-error.

if not avail lnsch then do:
   message skip " График не подлежит пересчету !" skip(1) view-as alert-box buttons ok .
   return.
end.

v-dt = lnsch.stdat.
dt = lnsch.stdat.

find next lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock no-error .

if not avail lnsch and v-dt >= lon.duedt then do:
   message skip " График не подлежит пересчету !" skip(1) view-as alert-box buttons ok .
   return.
end.

/*19/11/2008 galina*/
if avail lnsch then do:
  run day-360(v-dt00,v-dt0 - 1,360,output dn1,output dn2).
  if dn1 < 30 then v-dtend = v-dt + dn1.
  else v-dtend = lnsch.stdat.
end.

form
  dt label "Пересчет графика платежей начиная с " skip
  v-dt label "Укажите новую дату" format "99/99/9999"
  validate (chk-date(v-dt, lon.lon, v-dtend) = "", v-msg) skip
  with side-label row 5 centered frame dat.

display dt with frame dat.
update v-dt with frame dat.


if lon.plan = 3 or lon.plan = 5 then do:

  /********************************************/
  /*19/11/2008 galina пересчет графика*/
  j = 0.
  do transaction:

      for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today:
        j = j + 1.
        delete lnsch.
      end.


      for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > g-today:
        delete lnsci.
      end.


      find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= g-today no-lock no-error.
      if avail lnsci then v-dt1 = lnsci.idat.
      else do:
        find last lnscg where lnscg.lng = lon.lon and lnscg.flp > 0 no-lock no-error.
        v-dt1 = lnscg.stdat.
      end.

      v-payod = truncate(lon.opnamt / pkanketa.srok, 0).
      v-payprc = round(lon.opnamt * lon.prem / 1200,2).

      do i = 1 to j:
        if i = 1 then v-dt2 = v-dt.
        else if i = j then v-dt2 = lon.duedt.
        else v-dt2 = get-date(v-dt,i - 1).

        create lnsch.
        lnsch.lnn = lon.lon.
        lnsch.stdat = v-dt2.
        lnsch.f0 = 1.
        if i <> j then lnsch.stval = v-payod.
        else lnsch.stval = lon.opnamt - (pkanketa.srok - 1) * v-payod.

        create lnsci.
        lnsci.lni = lon.lon.
        lnsci.idat = v-dt2.
        lnsci.iv-sc = v-payprc.
        lnsci.f0 = 1.
        if i = 1 or i = j then do:
            run day-360(v-dt1,v-dt2 - 1,360,output dn1,output dn2).
            if dn1 <> 30 then lnsci.iv-sc = round(dn1 * lon.opnamt * lon.prem / 36000,2).
        end.
        v-dt1 = v-dt2.
      end.

      run lnsch-ren(lon.lon).
      release lnsch.

      run lnsci-ren(lon.lon).
      release lnsci.
  end. /* transaction */
end.

do transaction:
    find current lon exclusive-lock.
    lon.day = day(v-dt).
    find current lon no-lock.
end.

s-lon = pkanketa.lon.

def new shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    field com    as logi init no
    index idx is primary stdat.

for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock:
    create wrk.
    wrk.stdat = lnsch.stdat.
    wrk.od = lnsch.stval.
    wrk.com = yes.
end.

for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock:
    find first wrk where wrk.stdat = lnsci.idat no-lock no-error.
    if not avail wrk then do:
        create wrk.
        wrk.stdat = lnsci.idat.
    end.
    wrk.proc = lnsci.iv-sc.
end.

i = 1.
for each wrk:
    wrk.nn = i.
    i = i + 1.
end.

run value("pkprtgrf-" + s-credtype).



run pkhis.

procedure pkhis.
    create pkankhis.
    assign pkankhis.bank = s-ourbank
           pkankhis.credtype = s-credtype
           pkankhis.ln = s-pkankln
           pkankhis.type = 'graph'
           pkankhis.chval = 'Изменение графика'
           pkankhis.who = g-ofc
           pkankhis.whn = g-today.
end procedure.
