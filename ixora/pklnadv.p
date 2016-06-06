/* pklnadv.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Расчет суммы досрочного погашения
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
        27/10/2006 madiyar
 * BASES
        BANK COMM
 * CHANGES
        10/11/2006 madiyar - по кредитам с проставленным признаком lnjur выдается соотв. сообщение
        17/11/2006 madiyar - комиссия за ведение счета берется всегда за месяц вперед, или за три месяца в случае действия моратория
        21/11/2006 madiyar - подправил для филиалов
        13/03/2007 madiyar - исправил расчет комиссии за обслуживание, распространил на 4 схему
        14/04/2007 madiyar - автоматическое досрочное погашение
        04/06/2007 madiyar - подправил расчет процентов по ИП; не создавались записи в истории, исправил
        19/09/2007 madiyar - при нулевой сумме доначисляемых процентов все равно пыталась сделаться проводка, исправил
        19/12/2008 madiyar - появлялись проводки по доначислению %% со статусом 0, исправил
        06.04.2009 galina - исправила для досрочного погашения валютных кредитов
        24.06.2009 galina - погашаем уже оплаченные и списанные за баланс кредиты
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        13/09/2013 galina - ТЗ984 не доначисляем вознаграждение и комиссию за ведение счета за 3 месяца, если со дня выдачи кредита прошло более 1 года
        30/09/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115
*/

{mainhead.i}

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-bal as deci no-undo.
def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-balosd as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-balprc as deci no-undo.
def var v-balprd as deci no-undo.
def var v-balpen as deci no-undo.
def var v-balcom as deci no-undo.
def var v-balcod as deci no-undo.
def var v-sumall as deci no-undo.

def var v-balosd2 as char no-undo.
def var v-balprc2 as char no-undo.
def var v-balprd2 as char no-undo.
def var v-balpen2 as char no-undo.
def var v-balcom2 as char no-undo.
def var v-balcod2 as char no-undo.
def var v-sumall2 as char no-undo.

def var dat_wrk as date no-undo.
def var dat_wrk2 as date no-undo.
find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

def var v-comved as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def var v-srok as integer no-undo.
def var i as integer no-undo.
def var v-ja as logi no-undo format "да/нет" init no.
def var ja-ne as logi no-undo format "да/нет" init no.

def var v-bal4 as deci no-undo.
def var v-bal5 as deci no-undo.
def var v-balnc as deci no-undo.
def var v-bal12 as deci no-undo.
def var v-glrem as char no-undo extent 5.

def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var jparr as char no-undo.

def var vou-count as integer no-undo.
def var v-nxt as integer no-undo.
def var v-rate as decimal no-undo.
def var v-code as char no-undo.
def var v-dep as char no-undo.
def buffer bjl for jl.
def buffer bcrc for crc.
def buffer b-aaa for aaa.
{getdep.i}

form
   skip(1)
   " Основной долг...................." space(0) v-balosd2 format "x(19)" skip
   " Проценты (на уровнях)............" space(0) v-balprc2 format "x(19)" skip
   " Проценты (к доначислению)........" space(0) v-balprd2 format "x(19)" skip
   " Штраф (KZT !!)..................." space(0) v-balpen2 format "x(19)" skip
   " Комиссионный долг................" space(0) v-balcom2 format "x(19)" skip
   " Комиссия к доначислению.........." space(0) v-balcod2 format "x(19)" skip
   " ----------------------------------------------------" skip
   " ИТОГО (для вал.кредитов без пени)" space(0) v-sumall2 format "x(19)" skip
   skip(1)
   " Произвести досрочное погашение? " v-ja skip
   with row 5 centered no-labels overlay title " Сумма досрочного погашения " frame fr.

if lon.grp <> 90 and lon.grp <> 92 then do:
  message " Данный пункт - для расчета досрочки только по экспресс-кредитам " view-as alert-box warning.
  return.
end.

if lon.opnamt <= 0 then do:
  message " Кредит не был выдан " view-as alert-box error.
  return.
end.

find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "lnjur" no-lock no-error.
if avail sub-cod then do:
   if sub-cod.ccode = '01' then do:
     message " Дело по кредиту данного клиента передано в суд. ~n Обратитеcь в Юридический Департамент. " view-as alert-box warning.
     return.
   end.
end.

run lonbal('lon',lon.lon,g-today,"13,14,30",yes,output v-bal).
if v-bal > 0 then do:
  message " Кредит списан. Обратитеcь в ОМК ДПК. " view-as alert-box warning.
  return.
end.

if not(lon.plan = 4 or lon.plan = 5) then do:
  message " Некорректная схема. ~n За расчетом суммы досрочного погашения обратитеcь в ОМК ДПК. " view-as alert-box warning.
  return.
end.

find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
if not avail lnsch or not avail lnsci then do:
    message " Отсутствуют графики. Обратитеcь в ОМК ДПК. " view-as alert-box error.
    return.
end.

find first aaa where aaa.aaa = lon.aaa no-lock no-error.
if not avail aaa then do:
    message " Отсутствует текущий счет. " view-as alert-box error.
    return.
end.

v-comved = 0.
find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-comved = tarifex2.ost.

if v-comved = 0 then message " Комиссия за обслуживание кредита нулевая! " view-as alert-box warning.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
if not avail pkanketa then do:
    message " Не найдена анкета! " view-as alert-box error.
    return.
end.

v-srok = pkanketa.srok.
/*galina*/
v-rate = 1.
if lon.crc <> 1 then do:
    find first crc where crc.crc = lon.crc no-lock no-error.
    if not avail crc then do:
        message "Не найден текущий курс для валюты " + string(lon.crc) view-as alert-box.
        return.
    end.
    v-rate = crc.rate[1].
    find first b-aaa where b-aaa.aaa = pkanketa.aaaval no-lock no-error.
    if not avail b-aaa then do:
        message " Отсутствует тенговый текущий счет " + pkanketa.aaaval view-as alert-box error.
        return.
    end.
end.


run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
v-balosd = v-bal1 + v-bal7.
run lonbalcrc('lon',lon.lon,g-today,"2,4",yes,lon.crc,output v-bal2).
run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).
v-balprc = v-bal2 + v-bal9.
run lonbalcrc('lon',lon.lon,g-today,"5,16",yes,1,output v-balpen).
/*galina*/
if v-balosd + v-balprc = 0 then do:
  message "Кредит уже погашен или списан за баланс" view-as alert-box title 'ВНИМАНИЕ'.
  return.
end.
/*galina*/
v-balcom = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.crc = lon.crc no-lock:
  v-balcom = v-balcom + bxcif.amount.
end.
if g-today - lon.rdt < 365 then do:
    dat_wrk2 = 01/01/1000.
    v-balprd = 0.
    v-balcod = 0.
    if lon.plan = 5 then do:
        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
        if avail lnsci then dat_wrk2 = lnsci.idat.
        do i = 1 to 2:
            find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
            if avail lnsci then dat_wrk2 = lnsci.idat.
        end.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk2 no-lock:
            v-balprd = v-balprd + lnsci.iv-sc.
            if lnsci.idat > dat_wrk then v-balcod = v-balcod + v-comved.
        end.
    end.
    else
    if lon.plan = 4 then do:
        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
        if avail lnsci then dat_wrk2 = lnsci.idat.
        if dat_wrk2 > 01/01/1000 then do:
            for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk2 no-lock:
                v-balprd = v-balprd + lnsci.iv-sc.
            end.
            v-balcod = 0.
        end.
        else do:
            v-balprd = 0.
            find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > dat_wrk no-lock no-error.
            if avail lnsch then v-balcod = v-balcod + v-comved.
        end.
    end.

    /* вычитаем уже погашенные проценты */
    for each lnsci where lnsci.lni = lon.lon and lnsci.flp > 0 no-lock:
        v-balprd = v-balprd - lnsci.paid.
    end.
    /* вычитаем уже начисленные проценты */
    v-balprd = v-balprd - v-balprc.
    if v-balprd < 0 then v-balprd = 0.
end.

v-balosd2 = replace(string(v-balosd,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.
v-balprc2 = replace(string(v-balprc,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.
v-balprd2 = replace(string(v-balprd,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.
v-balpen2 = replace(string(v-balpen,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.
v-balcom2 = replace(string(v-balcom,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.
v-balcod2 = replace(string(v-balcod,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.

/*galina*/
if lon.crc = 1 then  v-sumall = v-balosd + v-balprc + v-balprd + v-balpen + v-balcom + v-balcod.
else v-sumall = v-balosd + v-balprc + v-balprd + v-balcom + v-balcod.

v-sumall2 = replace(string(v-sumall,"zzz,zzz,zzz,zz9.99"),' ','.') + ' '.

displ v-balosd2 v-balprc2 v-balprd2 v-balpen2 v-balcom2 v-balcod2 v-sumall2 with frame fr.

if v-sumall > 0 then update v-ja with frame fr.

if v-ja then do:
    if aaa.cr[1] - aaa.dr[1] < v-sumall then do:
        message " Нехватка средств на текущем счете для досрочного погашения " view-as alert-box error.
        return.
    end.
    /*galina*/
    if lon.crc <> 1 then do:
      if b-aaa.cr[1] - b-aaa.dr[1] < v-balpen then do:
          message " Нехватка средств на текущем счете (KZT) для погашения пени " view-as alert-box error.
          return.
      end.
    end.
end.

else do:
end.
if v-ja then do:

    do transaction:

        /* доначисление */

        if v-balprd > 0 then do:
            v-glrem[1] = "Доначисление процентов".
            if lon.crc = 1 then do:
              s-jh = 0.
              v-param = string(v-balprd) + vdel +
                        lon.lon + vdel + /* валюта */
                        v-glrem[1] + vdel +
                        "490". /* код назначения платежа */
              run trxgen ("lon0013", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            end.
            /*galina*/
            else do:
              v-param = string(v-balprd) + vdel +
                        lon.lon + vdel  +
                        "1" + vdel +
                        "9" + vdel +
                        "490" + vdel +
                        string(v-balprd * v-rate) + vdel
                        + v-glrem[1]. /* код назначения платежа */
              s-jh = 0.
              run trxgen ("lon0014", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            end.


            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                return.
            end.

            run lonresadd(s-jh).

            find jh where jh.jh = s-jh exclusive-lock no-error.
            if avail jh then do:
                if jh.sts < 6 then jh.sts = 6.
                for each jl of jh exclusive-lock:
                    if jl.sts < 6 then jl.sts = 6.
                end.
                find current jh no-lock.
            end.

        end.

        /* перенос */

        run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).
        run lonbalcrc('lon',lon.lon,g-today,"5",yes,1,output v-bal5).

        if v-bal4 > 0 then do:
            v-glrem[1] = "Перенос процентов в баланс".
            /*v-param = string(v-bal4) + vdel + lon.lon + vdel + v-glrem[1] + vdel + string(v-bal4).*/
           if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel +
                  v-glrem[1] + vdel + "0" + vdel + string(v-bal4) + vdel + lon.lon + vdel +
                  v-glrem[1] + vdel + string(v-bal4).
           else v-param = string(v-bal4) + vdel + lon.lon + vdel +
                  v-glrem[1] + vdel + string(v-bal4) + vdel + "0" + vdel + lon.lon + vdel +
                  v-glrem[1] + vdel + "0".
            s-jh = 0.
            run trxgen ("lon0115", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
            {upd-dep.i}
            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                return.
            end.
            run lonresadd(s-jh).
            find jh where jh.jh = s-jh exclusive-lock no-error.
            if avail jh then do:
                if jh.sts < 6 then jh.sts = 6.
                for each jl of jh exclusive-lock:
                    if jl.sts < 6 then jl.sts = 6.
                end.
                find current jh no-lock.
            end.
        end.

        if v-bal5 > 0 then do:
            v-glrem[1] = "Перенос пени в баланс".
            v-param = string(v-bal5) + vdel + lon.lon + vdel + v-glrem[1] + vdel + string(v-bal5).
            s-jh = 0.
            run trxgen ("lon0119", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
            {upd-dep.i}
            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                return.
            end.
            run lonresadd(s-jh).

        end.

        /* погашение */

        run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
        run lonbalcrc('lon',lon.lon,g-today,"11",yes,1,output v-balnc).
        v-balnc = - v-balnc.
        v-bal12 = round((v-bal2 + v-bal9) * v-rate,2).
        if v-balnc < v-bal12 then v-bal12 = v-balnc.

        v-glrem = ''.
        v-glrem[1] = "Погашение по кредиту " + lon.lon.
        if v-bal1 + v-bal7 > 0 then v-glrem[2] = "Сумма погашаемого ОД " + trim(string(v-bal1 + v-bal7,">>>,>>>,>>>,>>>,>>9.99-")) + if lon.crc = 1 then " KZT" else crc.code.
        if v-bal2 + v-bal9 > 0 then v-glrem[3] = "Сумма погашаемых %% " + trim(string(v-bal2 + v-bal9,">>>,>>>,>>>,>>>,>>9.99-")) + if lon.crc = 1 then " KZT" else crc.code.
        if v-balpen > 0 then v-glrem[4] = "Сумма погашаемых штрафов " + trim(string(v-balpen,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
        v-param = string(v-bal1) + vdel +
                  lon.aaa + vdel +
                  lon.lon + vdel +
                  "423" + vdel + /* код назначения платежа */
                  string(v-bal7) + vdel +
                  '0' + vdel + /* aaa - 8 */
                  string(v-bal2) + vdel +
                  string(v-bal9) + vdel +
                  '0' + vdel + /* aaa - 10 */
                  '0' + vdel + /* 10 - 2 */
                  '0' + vdel + /* 10 - 9 */
                  string(v-bal12) + vdel +
                  v-glrem[1] + vdel +
                  v-glrem[2] + vdel +
                  v-glrem[3] + vdel +
                  v-glrem[4] + vdel +
                  v-glrem[5] + vdel +
                  if lon.crc = 1 then string(v-balpen) else '0'.
        v-param = v-param + vdel +
                  '0' + vdel +
                  '0' + vdel +
                  '0' + vdel +
                  '0'.

        s-jh = 0.
        run trxgen ("lon0079", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            undo, return.
        end.
        {upd-dep.i}
        run lonresadd(s-jh).

        find jh where jh.jh = s-jh exclusive-lock no-error.
        if avail jh then do:
            if jh.sts < 6 then jh.sts = 6.
            for each jl of jh exclusive-lock:
                if jl.sts < 6 then jl.sts = 6.
            end.
            find current jh no-lock.

            if v-bal1 > 0 then do:
                v-nxt = 0.
                for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 no-lock:
                    if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                end.
                create lnsch.
                lnsch.lnn = lon.lon.
                lnsch.f0 = 0.
                lnsch.flp = v-nxt + 1.
                lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
                lnsch.paid = v-bal1.
                lnsch.stdat = jh.jdt.
                lnsch.jh = jh.jh.
                lnsch.whn = today.
                lnsch.who = g-ofc.
            end.

            if v-bal7 > 0 then do:
                v-nxt = 0.
                for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 no-lock:
                    if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                end.
                create lnsch.
                lnsch.lnn = lon.lon.
                lnsch.f0 = 0.
                lnsch.flp = v-nxt + 1.
                lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
                lnsch.paid = v-bal7.
                lnsch.stdat = jh.jdt.
                lnsch.jh = jh.jh.
                lnsch.whn = today.
                lnsch.who = g-ofc.
            end.

            if v-bal2 > 0 then do:
                v-nxt = 0.
                for each lnsci where lnsci.lni = lon.lon and lnsci.flp > 0 no-lock:
                    if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
                end.
                create lnsci.
                lnsci.lni = lon.lon.
                lnsci.f0 = 0.
                lnsci.flp = v-nxt + 1.
                lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
                lnsci.paid-iv = v-bal2.
                lnsci.idat = jh.jdt.
                lnsci.jh = jh.jh.
                lnsci.whn = today.
                lnsci.who = g-ofc.
            end.

            if v-bal9 > 0 then do:
                v-nxt = 0.
                for each lnsci where lnsci.lni = lon.lon and lnsci.flp > 0 no-lock:
                    if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
                end.
                create lnsci.
                lnsci.lni = lon.lon.
                lnsci.f0 = 0.
                lnsci.flp = v-nxt + 1.
                lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
                lnsci.paid-iv = v-bal9.
                lnsci.idat = jh.jdt.
                lnsci.jh = jh.jh.
                lnsci.whn = today.
                lnsci.who = g-ofc.
            end.

        end.
        /*galina*/
        if lon.crc <> 1 and v-balpen > 0 then do:
          v-param = string(v-balpen) + vdel + if lon.crc  = 1 then lon.aaa else pkanketa.aaaval.
          v-param = v-param +  vdel + lon.lon + vdel + "423" + vdel + '0'
                    + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel + "".
          run trxgen ("lon0080", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
          {upd-dep.i}
          if rcode ne 0 then do:
              message rdes.
              pause 1000.
              return.
          end.
          run lonresadd(s-jh).
          find jh where jh.jh = s-jh exclusive-lock no-error.
          if avail jh then do:
            if jh.sts < 6 then jh.sts = 6.
            for each jl of jh exclusive-lock:
                    if jl.sts < 6 then jl.sts = 6.
            end.
            find current jh no-lock.
          end.
        end.

    end. /* transaction */

    /* pechat vauchera */
    ja-ne = no.
    vou-count = 1. /* kolichestvo vaucherov */

    do on endkey undo:
        message "Печатать ваучер?" update ja-ne.
        if ja-ne then do:
            message "Сколько?" update vou-count format "9".
            if vou-count > 0 and vou-count < 10 then do:
                if s-jh > 0 then do:
                    find first jl where jl.jh = s-jh no-lock no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jh.
                        do i = 1 to vou-count:
                            run vou_lon(s-jh,'').
                        end.
                    end.  /* if available jl */
                    else message "Не найдена транзакция " s-jh view-as alert-box.
                end. /* if s-jh > 0 */
            end. /* if vou-count > 0 and vou-count < 10 */
        end. /* if ja-ne */
    end.

end. /* if v-ja */


