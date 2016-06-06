/* pksendsms2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Рассылка СМС-сообщений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-3-12
 * AUTHOR
        09/11/06 Natalya D.
 * CHANGES
        16/11/06 Natalya D. - номер мобильного телефона берется из cif
        17/11/06 Natalya D. - добавлен учет сумм на 4 и 5 уровнях.
        26/08/2009 madiyar - переделал
        07/09/2009 madiyar - вернул номер мобильного телефона из cif
        14/09/2009 madiyar - номер пакета в шаренной переменной
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

{global.i}

def var v-days1 as integer no-undo format "zz9" init 0.
def var v-days2 as integer no-undo format "zz9" init 999.
def var v-limit1 as decimal no-undo init 0.
def var v-limit2 as decimal no-undo init 9999999.
def var v-cifc as char no-undo.
def var v-cifn as char no-undo.
def var choice as logical init no no-undo.
def var v-sum as deci no-undo.
def var v-sum_kzt as deci no-undo.
def var v-bal as deci no-undo.
def var v-com as deci no-undo.

define variable v-checkdt1 as date no-undo.
define variable v-checkdt2 as date no-undo.

define variable v-duedt1 as inte no-undo format "z9" init 0.
define variable v-duedt2 as inte no-undo format "z9" init 31 .

def new shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field cif like cif.cif
  field lon like lon.lon
  field crc as integer
  field name as char
  field sumgr as deci
  field sumgr_kzt as deci
  field mob as char
  field days as integer
  field credtype as char
  field ln as integer
  field sing as char
  field who as char
  field whn as char
  field sts as integer
  index idx is primary name cif
  index idx2 days name.

def new shared var v-bb as integer no-undo.
v-bb = 0.

def frame f-param
    v-limit1 label "Сумма задолженности (без пени): С" format ">,>>>,>>9.99" validate (v-limit1 >= 0, " Неверная сумма!")
    v-limit2 label "ПО" format ">,>>>,>>9.99" validate (v-limit2 >= 0, " Неверная сумма!") " " skip
    v-days1 label "Дни просрочки: С"
    v-days2 label "ПО" skip
    v-cifc label "Код Клиента" format "x(8)" skip
    v-cifn label "Имя Клиента" format "x(32)"
    with centered overlay row 7 side-labels title " ПАРАМЕТРЫ ОТБОРА СПИСКА ДОЛЖНИКОВ ".
hide all no-pause.
update v-limit1 v-limit2 v-days1 v-days2 v-cifc v-cifn with frame f-param.
v-cifc = trim(v-cifc).
v-cifn = trim(v-cifn).

hide message no-pause.
message "Подождите. Идет формирование списка...".

def var s-ourbank as char no-undo.
def var v-bankn as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
find first cmp no-lock no-error.
if avail cmp then v-bankn = trim(entry(1,cmp.addr[1])).

for each londebt where (londebt.grp = 90) or (londebt.grp = 92) no-lock:
    find first lon where lon.lon = londebt.lon no-lock no-error.
    if not avail lon then next.
    if lon.opnamt <= 0 then next.
    run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).
    if v-bal <= 0 then next.

    v-com = 0.
    for each bxcif where bxcif.cif = lon.cif and bxcif.type = '195' and bxcif.crc = lon.crc no-lock:
         v-com = v-com + bxcif.amount.
    end.
    if lon.crc = 1 then v-sum_kzt = londebt.od + londebt.prc + v-com + londebt.penalty.
    else do:
        v-sum = londebt.od + londebt.prc + v-com.
        v-sum_kzt = londebt.penalty.
    end.

    if (v-sum < v-limit1) or (v-sum > v-limit2) then next.

    if londebt.days_od > v-days2 or londebt.days_od < v-days1 then next.

    if v-cifc <> "" and londebt.cif  <> v-cifc then next.

    find first cif where cif.cif = londebt.cif no-lock no-error.
    if not avail cif then next.
    if v-cifn <> "" and not (cif.name matches ("*" + v-cifn + "*")) then next.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.bankn = v-bankn
           wrk.cif = lon.cif
           wrk.lon = lon.lon
           wrk.crc = lon.crc
           wrk.days = londebt.days_od
           wrk.sumgr = v-sum
           wrk.sumgr_kzt = v-sum_kzt
           wrk.name = trim(cif.name)
           wrk.who = g-ofc
           wrk.whn = (string(time,'hh:mm:ss') + ' ' + string(g-today)).
    wrk.mob = cif.fax.
    wrk.mob = replace(wrk.mob,';',',').
    wrk.mob = replace(wrk.mob,' ','').
    wrk.mob = replace(wrk.mob,'-','').
    wrk.mob = entry(1,wrk.mob).
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
    if avail pkanketa then do:
        wrk.credtype = pkanketa.credtype.
        wrk.ln = pkanketa.ln.
        /*
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel3" no-lock no-error.
        if avail pkanketh then wrk.mob = trim(pkanketh.value1).
        */
    end.
end.

hide message no-pause.

find first wrk no-lock no-error.
if not avail wrk then do:
    message " Нет клиентов для рассылки! " view-as alert-box information.
    return.
end.

run pksendsms2_1.
hide message no-pause.
message "Вывести отчет?" view-as alert-box question buttons yes-no title " Внимание! " update choice.
if choice then run pksendsms2_2.
