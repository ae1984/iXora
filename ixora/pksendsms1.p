/* pksendsms1.p
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
        26/08/2009 madiyar - переделал
        07/09/2009 madiyar - вернул номер мобильного телефона из cif
        14/09/2009 madiyar - номер пакета в шаренной переменной
*/

{global.i}
def new shared var v-dt as date no-undo.
def var v-in as logi no-undo.
def var v-bal as deci no-undo.
def var v-sum as deci no-undo.
def var v-ost as deci no-undo.
def var choice as logical init no no-undo.

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

def new shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field cif like cif.cif
  field lon like lon.lon
  field crc as integer
  field name as char
  field sumgr as deci
  field balanst as deci
  field mob as char
  field days as integer
  field credtype as char
  field ln as integer
  field sing as char
  field who as char
  field whn as char
  field sts as integer
  index idx is primary name cif.

def new shared var v-bb as integer no-undo.
v-bb = 0.

v-dt = g-today.
update v-dt label " Введите дату" format "99/99/9999"
                  skip with side-label row 5 centered frame dat .

hide message no-pause.
message "Подождите. Идет формирование списка...".

for each lon where (lon.plan = 4) or (lon.plan = 5) no-lock:
    if lon.opnamt <= 0 then next.
    run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).
    if v-bal <= 0 then next.
    v-in = no. v-sum = 0.
    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-dt no-lock no-error.
    if avail lnsch then do:
        v-in = yes.
        v-sum = lnsch.stval.
        find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
        if avail tarifex2 then v-sum = v-sum + tarifex2.ost.
    end.
    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-dt no-lock no-error.
    if avail lnsci then do:
        v-in = yes.
        v-sum = v-sum + lnsci.iv-sc.
    end.

    if v-in then do:
        run lonbalcrc('cif',lon.aaa,g-today,"1",yes,lon.crc,output v-ost).
        v-ost = - v-ost.
        if v-ost >= v-sum then v-in = no.
    end.

    if v-in then do:
        create wrk.
        assign wrk.bank = s-ourbank
               wrk.bankn = v-bankn
               wrk.cif = lon.cif
               wrk.lon = lon.lon
               wrk.crc = lon.crc
               wrk.sumgr = v-sum
               wrk.balanst = v-ost
               wrk.who = g-ofc
               wrk.whn = (string(time,'hh:mm:ss') + ' ' + string(today)).
        find first cif where cif.cif = lon.cif no-lock no-error.
        if avail cif then do:
            wrk.name = trim(cif.name).
            wrk.mob = cif.fax.
            wrk.mob = replace(wrk.mob,';',',').
            wrk.mob = replace(wrk.mob,' ','').
            wrk.mob = replace(wrk.mob,'-','').
            wrk.mob = entry(1,wrk.mob).
        end.
        /*
        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
        if avail pkanketa then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel3" no-lock no-error.
            if avail pkanketh then wrk.mob = trim(pkanketh.value1).
        end.
        */
    end.
end. /* for each lon */

hide message no-pause.

find first wrk no-lock no-error.
if not avail wrk then do:
    message " Нет клиентов для рассылки! " view-as alert-box information.
    return.
end.

run pksendsms1_1.
hide message no-pause.
message "Вывести отчет?" view-as alert-box question buttons yes-no title " Внимание! " update choice.
if choice then run pksendsms1_2.
