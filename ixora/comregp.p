/* comregp.p
 * MODULE
        Пенсионные платежи (соц. отчисления)
 * DESCRIPTION
        Реестр пенсионных платежей (соц. отчисления) за дату
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
        17/01/05 kanat
 * CHANGES
        19/01/05 kanat - вывел подитоги и количество
        25/01/05 kanat - переделал Excel отчет в дубовый - по просьбе юзеров
        14/02/05 kanat - добавил обработку количество вкладчиков
        15/02/05 kanat - добавил группировку по типам платежей
        15/02/05 kanat - txb = 0 заменил на txb = seltxb
        29/03/05 kanat - добавил номера телефонов клиентов
        14/04/05 kanat - добавил возможность задавать период выборки
        04/07/06 u00568 Evgeniy - по тз 369 пенсионные платежи отправляем в ГЦВП - добавил выбор и фильтр
        06/07/06 u00568 Evgeniy - добавил обработку введенных до 30/05/2006 и оптимизил
*/

{comm-txb.i}
{global.i}
{get-dep.i}
{deparp_pmp.i}
{functions-def.i}

def var seltxb as int.
seltxb = comm-cod().

define temp-table tcommonpl like commonpl
       field dep as integer
       field account as char.

def stream m-out.
def var v-dat as date.
def var v-dat2 as date.

def var uu as char format "x(8)".
def var name as char format "x(30)".
def var v-mname as char.

def var v-ben-rnn as char format "x(12)".
def var v-ben-knp as char.

def var v-count1 as integer.
def var vs-name as char.

def var is_it_pens as integer init 0.  /*0 - платежи в ГЦВП*/ /*1 - платежи в пенсионный фонд*/
def var lis_it_pens as logical.


v-dat = g-today.
v-dat2 = v-dat.

if not g-batch then do:
    update v-dat label ' Введите период с ' format '99/99/9999'
    v-dat2 label " по " format "99/99/9999" skip
    is_it_pens label " 0 - социальные / 1 - пенсионные " format "9" skip
    with side-label row 5 centered frame dataa .
    end.


lis_it_pens  = is_it_pens = 1.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then
v-mname = ofc.name.
else do:
message "Неверный логин менеджера" view-as alert-box title "Внимание".
return.
end.

for each commonpl where commonpl.txb = seltxb and commonpl.grp = 15 and commonpl.date >= v-dat and
                        commonpl.date <= v-dat2 and commonpl.deluid = ? and (commonpl.abk = integer(lis_it_pens) or (commonpl.abk = ? and not lis_it_pens)) no-lock.
    create tcommonpl.
    buffer-copy commonpl to tcommonpl.
    assign tcommonpl.dep = get-dep(commonpl.uid, commonpl.date)
           tcommonpl.account = deparp_pmp(tcommonpl.dep).
end.

output to comrgp.txt.
if lis_it_pens then
  put unformatted  "РЕЕСТР ПО ПРИЕМУ ПЛАТЕЖЕЙ ПЕНС. ОТЧИСЛЕНИЙ c " string(v-dat) " по " string(v-dat2) skip.
else
  put unformatted  "РЕЕСТР ПО ПРИЕМУ ПЛАТЕЖЕЙ СОЦ. ОТЧИСЛЕНИЙ c " string(v-dat) " по " string(v-dat2) skip.

put unformatted  "Исполнитель: " v-mname "." skip
                 "Дата: " string(g-today) "." skip
                 "Время: " string(time,"HH:MM:SS") "." skip(2).

put unformatted "Номер квит. РНН отправителя Номер телефона       Ф.И.О.                            Кол-во Сумма        Комиссия     Всего       " skip.

for each tcommonpl no-lock break by tcommonpl.dep by tcommonpl.type:

if first-of (tcommonpl.dep) then do:
find first ppoint where ppoint.depart = tcommonpl.dep and ppoint.point = 1  no-lock no-error.
put unformatted " " skip.
put unformatted fill("-", 148) format "x(148)" skip.
put unformatted  ppoint.name ". АРП: " tcommonpl.account skip.
end.

/*
if first-of (tcommonpl.type) then do:
find first commonls where commonls.txb = seltxb and commonls.grp = 15 and visible = no and commonls.type = tcommonpl.type no-lock no-error.
if avail commonls then do:
put unformatted caps(commonls.npl) ". КНП: " commonls.knp skip.
v-ben-rnn = commonls.rnn.
end.
end.
*/
 
accumulate tcommonpl.sum (total).
accumulate tcommonpl.z (total).
accumulate tcommonpl.comsum (total).
accumulate tcommonpl.sum + tcommonpl.comsum (total).

/*
accumulate tcommonpl.sum (sub-total by tcommonpl.type).
accumulate tcommonpl.z (sub-total by tcommonpl.type).
accumulate tcommonpl.dnum (sub-count by tcommonpl.type).
accumulate tcommonpl.comsum (sub-total by tcommonpl.type).
accumulate (tcommonpl.sum + tcommonpl.comsum) (sub-total by tcommonpl.type).
*/

accumulate tcommonpl.sum (sub-total by tcommonpl.dep).
accumulate tcommonpl.z (sub-total by tcommonpl.dep).
accumulate tcommonpl.dnum (sub-count by tcommonpl.dep).
accumulate tcommonpl.comsum (sub-total by tcommonpl.dep).
accumulate (tcommonpl.sum + tcommonpl.comsum) (sub-total by tcommonpl.dep).

v-count1 = v-count1 + 1.

put unformatted string(tcommonpl.dnum) format "x(11)" " "
                tcommonpl.rnn          format "x(15)" " "
                tcommonpl.chval[4]     format "x(20)" " ".

vs-name = trim(tcommonpl.fio).
if tcommonpl.type = 2 OR tcommonpl.type = 5 then do:
  if length(vs-name) > 26 then
    vs-name = substr(vs-name, 1, 26).
  vs-name = vs-name + " (пеня)".
end.

if tcommonpl.type = 4 then do:
  if length(vs-name) > 26 then
    vs-name = substr(vs-name, 1, 26).
  vs-name = vs-name + " (добров)".
end.

put unformatted vs-name  format "x(33)" " ".

put unformatted string(tcommonpl.z)    format "x(5)" " "
                string(tcommonpl.sum)          format "x(12)" " "
                string(tcommonpl.comsum)       format "x(12)" " "
                string(tcommonpl.sum + tcommonpl.comsum) format "x(12)" skip.

/*
if last-of (tcommonpl.type) then do:
put unformatted fill("-", 148) format "x(148)" skip.
put unformatted "По типу:" format "x(11)" " "
                "" format "x(15)" " "
                "" format "x(15)" " "
                string(accum sub-count by tcommonpl.type tcommonpl.dnum) format "x(33)" " "
                string(accum sub-total by tcommonpl.type tcommonpl.z) format "x(5)"  " "
                string(accum sub-total by tcommonpl.type tcommonpl.sum) format "x(12)"  " "
                string(accum sub-total by tcommonpl.type tcommonpl.comsum) format "x(12)"  " "
                string(accum sub-total by tcommonpl.type (tcommonpl.sum + tcommonpl.comsum)) format "x(12)" skip.
end.
*/

if last-of (tcommonpl.dep) then do:
put unformatted fill("-", 148) format "x(148)" skip.
put unformatted "По СПФ:" format "x(11)" " "
                "" format "x(15)" " "
                "" format "x(20)" " "
                string(accum sub-count by tcommonpl.dep tcommonpl.dnum) format "x(33)"  " "
                string(accum sub-total by tcommonpl.dep tcommonpl.z) format "x(5)"  " "
                string(accum sub-total by tcommonpl.dep tcommonpl.sum) format "x(12)"  " "
                string(accum sub-total by tcommonpl.dep tcommonpl.comsum) format "x(12)"  " "
                string(accum sub-total by tcommonpl.dep (tcommonpl.sum + tcommonpl.comsum)) format "x(12)" skip.
end.
end.



put unformatted fill("-", 148) format "x(148)" skip.
put unformatted "ВСЕГО:" format "x(11)" " "
                "" format "x(15)" " "
                "" format "x(20)" " "
                string(v-count1) format "x(33)" " "
                string(accum total tcommonpl.z) format "x(5)" " "
                string(accum total tcommonpl.sum) format "x(12)" " "
                string(accum total tcommonpl.comsum) format "x(12)" " "
                string(accum total tcommonpl.sum + tcommonpl.comsum) format "x(12)" skip.

output close.
run menu-prt ("comrgp.txt").
