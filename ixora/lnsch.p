/* lnsch.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Формироваание календарей погашения кредитов
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
        04.09.2003 marinav  Добавлена обработка аннуитетной схемы lon.plan = 2
        05.10.2003 tsoy     если изменили график делаем кредит не подписанным
        04/05/06 marinav Увеличить размерность поля суммы
        28/06/2008 madiyar - 5ая схема обрабатывается другой прогой
        31/03/2009 madiyar - 4ая схема тоже
        17/07/2010 madiyar - 6ая схема тоже
        11/10/2010 madiyar - перенос платежей с выходных дней
        12/10/2010 madiyar - перекомпиляция
        21/01/2011 madiyar - спрашиваем, двигать графики с выходных дней или нет
        21.04.2011 aigul - передача параметров lnscd('',0).
        30/09/2013 galina - ТЗ1337 пересчет комиссии для бывших сотрудников
*/

def shared var s-lon like lnsch.lnn.
find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "lon не найден!" view-as alert-box error.
    return.
end.

if lon.plan = 4 or lon.plan = 5 or lon.plan = 6 then do:
    run lnsch_s5.
    run lncomupda.
    return.
end.

def var vduedt like lon.duedt.
def var vregdt like lon.rdt.
def var vopnamt like lon.opnamt.
def var vprem like lon.prem.
def var vbasedy like lon.basedy.
def var flag as inte initial 21.
def shared var st as inte initial 0.
def new shared var s-vint like lnsci.iv.
def new shared frame lonscp.
def new shared frame lonsci.
def new shared frame lonscg.
def new shared var svopnamt as char format "x(21)".
def new shared var svint as char format "x(21)".
def new shared var svduedt as char format "x(10)".
def new shared var svregdt as char format "x(10)".
def new shared var vshift as inte initial 30.
def var vf0 like ln%his.f0.
def var vint like lnsci.iv.
def var viss like lnscg.stval initial 0.
def var trecp as recid.
def var trecg as recid.
def var treci as recid.
def var clinp as inte.
def var cling as inte.
def var clini as inte.

def var v-ja as logi no-undo.

def temp-table t-ci-before like lnsci
    field id as integer.

def temp-table t-ch-before like lnsch
    field id as integer.

def temp-table t-ci-after like lnsci
    field id as integer.

def temp-table t-ch-after like lnsch
    field id as integer.

def var v-edit as logical.

def var i1 as integer .
def var j1 as integer .
def var i2 as integer .
def var j2 as integer .

def var v-diff as logical.

{global.i}
{lonscg.f}
{lonscp.f}
{lonsci.f}

/* tsoy сохраняем */
i1 = 1.
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                       and lnsci.f0 > -1 no-lock.
    buffer-copy lnsci to t-ci-before.
    t-ci-before.id = i1.
    i1 = i1 + 1.
end.

j1 = 1.
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
          and lnsch.f0 > -1 no-lock.
    buffer-copy lnsch to t-ch-before.
    t-ch-before.id = j1.
    j1 = j1 + 1.
end.

find lon where lon.lon = s-lon.
/*аннуитет*/
if lon.plan = 2 then do:
   run lngrf-2.
   return.
end.

if lon.plan > 1 then return.

/*vopnamt = maximum(lon.opnamt - lon.cam[1],lon.dam[1] - lon.cam[1]).*/
vopnamt = lon.opnamt.

if lon.gua = "OD"
then do:
     find aaa where aaa.aaa = lon.lcr no-lock.
     vopnamt = aaa.opnamt.
end.
if lon.gua = "LK"
then do:
     find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock.
     vopnamt = lon.opnamt - lonhar.rez-dec[2] -
               lonhar.rez-dec[3] * lon.opnamt / 100.
end.
vduedt = lon.duedt. vregdt = lon.rdt.
vbasedy = lon.basedy. vprem = lon.prem.
/**************/
   if lon.ddt[5] <> ? then vduedt = lon.ddt[5].
   if lon.cdt[5] <> ? then vduedt = lon.cdt[5].
/**************/
{lsch-ini.i}
start: repeat:
  if flag = 11 then do:
   run lscg(vduedt, vregdt, vopnamt, output flag
           , input-output trecg, input-output cling).

     next start.
  end.
  if flag = 21 or flag = 14 then do:
       run lscp(vduedt, vregdt, vopnamt, input-output flag
               , input-output trecp, input-output clinp).
     next start.
  end.
  else if flag = 31 or flag = 32 then do:
     run lsci(vprem, vbasedy, vopnamt, vduedt, vregdt, input-output flag
             , input-output treci, input-output clini).
     next start.
  end.
     hide frame lonscp. hide frame lonsci. leave start.
end.
if lon.dam[1] > 0 then do:
 release lnsci. release lnsch. release lnscg.
 run lnreal-iclc(s-lon).
 run lnscg-upd(s-lon).
 run lnsch-upd(s-lon).
 run lnsci-upd(s-lon).
end.

/* Если произошли изменения то v-edit = true */

i2 = 1.
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                       and lnsci.f0 > -1 no-lock.
    buffer-copy lnsci to t-ci-after.
    t-ci-after.id = i2.
    i2 = i2 + 1.
end.

j2 = 1.
for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
          and lnsch.f0 > -1 no-lock.
    buffer-copy lnsch to t-ch-after.
    t-ch-after.id = j2.
    j2 = j2 + 1.
end.

v-edit = false.


if i1 <> i2 then do:
   v-edit = true.
end.

if j1 <> j2 then do:
   v-edit = true.
end.

for each t-ci-before.
    find t-ci-after where t-ci-after.id = t-ci-before.id no-error.

    if avail t-ch-after then do:
        buffer-compare t-ci-before
        using
            schn
            idat
            iv-sc
        to t-ci-after save v-diff.
        if not v-diff then do:
           v-edit = true.
        end.
    end.
end.

for each t-ch-before.
    find t-ch-after where t-ch-after.id =  t-ch-before.id no-error.

    if avail t-ch-after then do:
        buffer-compare
            t-ch-before
        using
            schn
            stdat
            stval
            comment
        to t-ch-after save v-diff.

        if not v-diff then do:
           v-edit = true.
        end.
    end.
end.

v-ja = no.
message "Произвести сдвиг платежей с выходных дней?" view-as alert-box question buttons yes-no update v-ja.
if v-ja then run lnscd('',0).
run lncomupda.

find loncon where loncon.lon = s-lon.
if index(loncon.rez-char[10],'&') > 0 and v-edit then do:
     loncon.rez-char[10] = substring(loncon.rez-char[10],1,index(loncon.rez-char[10],'&')) + 'no'.
     message 'Внимание документу установлен статус "Не подписан"' skip  'Обратитесь в департамент авторизации' view-as alert-box.
end.
