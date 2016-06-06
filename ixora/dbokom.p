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
        25/07/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        25/07/2012 dmitriy - копия lnkoms: перенос пунктов Доначисление и Cписание комиссии из меню "КомСотр" в "ДБО.КомСот"
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
run sel2 (" ВЫБЕРИТЕ: ", " 1. Доначисление комиссии | 2. Списание комиссии | 3. Выход ", output v-sel).



if v-sel = 1 then do:
    v-koms_add = 0.
    v-koms_will = v-koms_curr.
    choice = no.
    displ v-koms_curr v-koms_add v-koms_will choice with frame frd.
    update v-koms_add with frame frd.
    v-koms_will = v-koms_curr + v-koms_add.
    displ v-koms_will with frame frd.
    update choice with frame frd.
    if choice then do transaction:
        find current lons exclusive-lock.
        lons.amt = v-koms_will.
        create lonsres.
        assign lonsres.lon = lon.lon
               lonsres.restype = "m"
               lonsres.fdt = g-today
               lonsres.tdt = g-today
               lonsres.od = v-bal
               lonsres.prem = lons.prem
               lonsres.amt = v-koms_add
               lonsres.who = g-ofc.
        find current lons no-lock.
        find current lonsres no-lock.
    end.
end.
else
if v-sel = 2 then do:
    v-koms_spis = 0.
    v-koms_will = v-koms_curr.
    choice = no.
    displ v-koms_curr v-koms_spis v-koms_will choice with frame frs.
    update v-koms_spis with frame frs.
    v-koms_will = v-koms_curr - v-koms_spis.
    displ v-koms_will with frame frs.
    update choice with frame frs.
    if choice then do transaction:
        find current lons exclusive-lock.
        lons.amt = v-koms_will.
        create lonsres.
        assign lonsres.lon = lon.lon
               lonsres.restype = "s"
               lonsres.fdt = g-today
               lonsres.tdt = g-today
               lonsres.od = v-bal
               lonsres.prem = lons.prem
               lonsres.amt = v-koms_spis
               lonsres.who = g-ofc.
        find current lons no-lock.
        find current lonsres no-lock.
    end.
end.
else
if v-sel = 4 then do:
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
