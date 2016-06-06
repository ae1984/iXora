/* lnkoms.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Доначисление-списание комиссии по бывшим сотрудникам, график комиссии
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
        23/08/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        24/08/2010 madiyar - комиссия по кредитам бывших сотрудников, начисление начиная с определенной даты
        25/08/2010 madiyar - подправил построение графика
        02/11/2011 madiyar - подправил перерасчет графика при частичном досрочном погашении
        07/11/2011 madiyar - при перестройке графика не смотрим на уже начисленную сумму, рассчитываем строго по графику
        25/07/2012 dmitriy - перенос пунктов Доначисление и Cписание комиссии из меню "КомСотр" в "ДБО.КомСот"
        30/09/2013 galina - ТЗ1337 редактирование комиссии для бывших сотрудников
*/

{global.i}
{getdep.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

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

function to_string_date returns char (input dt as date).
    def var mm as char no-undo extent 12 init ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'].
    return string(day(dt),"99") + ' ' + mm[month(dt)] + ' ' + string(year(dt),"9999") + ' г.'.
end function.

procedure rec2log.
    def input parameter p-mess as char no-undo.
    output to value("/data/log/bxcif-del.log") append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        s-ourbank " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
end procedure.

def shared var s-lon like lnsch.lnn.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.
def var choice as logical no-undo.

def var v-koms_curr as deci no-undo.
def var v-koms_will as deci no-undo.
def var v-koms_add as deci no-undo.
def var v-koms_spis as deci no-undo.
def var v-bal as deci no-undo.
def var v-s as deci no-undo extent 3.
def var v-ost as deci no-undo.
def var nach_before as deci no-undo.
def var nach as deci no-undo.
def var dt1 as date no-undo.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "lon не найден!" view-as alert-box error.
    return.
end.

if lon.plan = 4 or lon.plan = 5 then do:
    message " Некорректный вид кредита! " view-as alert-box error.
    return.
end.

find first lons where lons.lon = lon.lon no-lock no-error.
if not avail lons then do:
    message " Не кредит бывшего сотрудника! " view-as alert-box error.
    return.
end.

v-koms_curr = lons.amt.
run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal).

form
  v-koms_curr label "Комиссия в данный момент    " format ">>>,>>>,>>>,>>9.99" skip
  v-koms_add label "Комиссия к доначислению     " format ">>>,>>>,>>>,>>9.99" validate(v-koms_add > 0, "Некорректная сумма!") skip
  v-koms_will label "Комиссия после доначисления " format ">>>,>>>,>>>,>>9.99" skip
  choice label "Провести доначисление?      " skip
with frame frd side-labels row 13 centered overlay title "Доначисление комиссии".

form
  v-koms_curr label "Комиссия в данный момент    " format ">>>,>>>,>>>,>>9.99" skip
  v-koms_spis label "Комиссия к списанию         " format ">>>,>>>,>>>,>>9.99" validate(v-koms_spis > 0 and v-koms_spis <= v-koms_curr, "Некорректная сумма!") skip
  v-koms_will label "Комиссия после списания     " format ">>>,>>>,>>>,>>9.99" skip
  choice label "Провести списание?          " skip
with frame frs side-labels row 13 centered overlay title "Списание комиссии".

form
    v-koms_curr label " Начислено на текущий момент ............ " format ">>>,>>>,>>>,>>9.99" skip
    v-s[1] label " Всего по графикам к погашению по сегодня " format ">>>,>>>,>>>,>>9.99" skip
    v-s[2] label " Уже погашено по сегодняшний день ....... " format ">>>,>>>,>>>,>>9.99" skip
    v-s[3] label " Итого к погашению сегодня .............. " format ">>>,>>>,>>>,>>9.99" skip
with frame fri centered overlay side-labels row 13 title "Информация".

def var v-sel as integer no-undo.
run sel2 (" ВЫБЕРИТЕ: ", " 1. График погашения комиссии | 2. Информация | 3. Редактировать график комиссии| 4. Выход ", output v-sel).


if v-sel = 1 then do:
    if lons.prem = 0 then do:
        message " Ставка по комиссии = 0! " view-as alert-box error.
        return.
    end.
    /*
    if lons.rdt < g-today then do:
        message " Дата начала начисления раньше текущей! " view-as alert-box error.
        return.
    end.
    */

    choice = no.
    message "Сформировать график?" view-as alert-box question buttons ok-cancel title "" update choice.

    if choice then do:
        for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat > g-today exclusive-lock:
            delete lnscs.
        end.

        dt1 = lon.rdt.

        v-ost = lon.opnamt.
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= g-today no-lock:
            v-ost = v-ost - lnsch.stval.
            dt1 = lnsch.stdat.
        end.

        /*
        nach_before = v-koms_curr.
        if nach_before < 0 then nach_before = 0.

        if lons.rdt < g-today then dt1 = g-today.
        else dt1 = lons.rdt.
        */

        if dt1 < lons.rdt then dt1 = lons.rdt.

        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock:
            run day-360(dt1,lnsch.stdat - 1,lon.basedy,output dn1,output dn2).
            nach = nach_before + round(dn1 * v-ost * lons.prem / 100 / lon.basedy,2).
            if nach > 0 then do:
                create lnscs.
                assign lnscs.lon = lon.lon
                       lnscs.sch = yes
                       lnscs.stdat = lnsch.stdat
                       lnscs.stval = nach.
            end.
            nach_before = 0.
            if lnsch.stdat >= dt1 then dt1 = lnsch.stdat.
            v-ost = v-ost - lnsch.stval.
        end.
        run calxls.
    end.
end.
else
if v-sel = 2 then do:
    v-s = 0.
    for each lnscs where lnscs.lon = lon.lon and lnscs.sch and lnscs.stdat <= g-today no-lock:
        v-s[1] = v-s[1] + lnscs.stval.
    end.
    for each lnscs where lnscs.lon = lon.lon and lnscs.sch = no and lnscs.stdat <= g-today no-lock:
        v-s[2] = v-s[2] + lnscs.stval.
    end.
    v-s[3] = v-s[1] - v-s[2].
    if v-s[3] < 0 then v-s[3] = 0.
    displ v-koms_curr v-s[1] v-s[2] v-s[3] with frame fri.
    pause.
end.
else if v-sel = 3 then run lncomupdh.
