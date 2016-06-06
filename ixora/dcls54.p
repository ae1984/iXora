/* dayclose.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        daily interest accr
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19.10.1994 svl
 * CHANGES
        30.07.2003 nadejda - изменила явно прописанную схему начисления процентов на поиск признака А (автоматически начислять) в настройках схемы
        15.09.2003 marinav - начислять %% отдельно : 1 уровень на 2 уровень
                                                     7 уровень на 9 уровень
                                                     8 уровень исключить
        06.11.2003 marinav - запись в историю %% на 7 уровень
        04.12.2003 nadejda - закомментарила все, что относится к профит-центрам
        20/05/2004 madiyar - ввод схемы 4 для потреб. кредитов: коррекция начисленных процентов
        12/01/2005 madiyar - в связи с определенными косяками изменения в расчете начисленных % по схеме 4
        19.04.2005 nataly добавлено автоматическое проставление кодов расходов/доходов {cods2.i} - модернизирован вариант {cods.i}
        31/05/2005 madiyar - добавил схему 5
        02/09/2005 madiyar - комиссия за вед. тек. счета по БД начисляется здесь
                             по БД - при нулевом остатке на 1ом уровне начисление % прекращается
        05/09/2005 madiyar - комиссия за вед. тек. счета по БД - небольшое исправление
        06/09/2005 madiyar - комиссия за вед. тек. счета по БД - исключения на счет
        03/10/2005 madiyar - комиссия за вед. тек. счета по БД - по филиалам
                             начисление комиссии только в рабочий день
        16/11/2005 madiyar - корректировка процентов по 5-ой схеме для последнего погашения
        15/02/2006 Natalya D. - добавлено начисление процентов за балансом на 4 уровень
        21/03/2006 Natalya D. - исправила начисление % по линиям
        24/03/2006 Natalya D. - убрала добавление записи в trxbal на 11 уровень просроченных кредитов (внебаланс 4 ур).
        10/04/2006 Natalya D. - исправила автом. изменение признака "flagl"
        28/04/2006 Natalya D. - добавила проверку на 0 поля lon.prem(%)
        28/06/2006 madiyar - при начислении комиссии за ведение тек. счета проставляем bxcif.pref = yes (снимать только с этого счета)
        14/02/2007 madiyar - поле lon.sts используем под статус кредита (погашен/не погашен), соотв. изменения
        21/02/2007 madiyar - все лишнее выкинул, разбил на отдельные транзакционные блоки, добавил записи в лог
        23/02/2007 madiyar - подправил начисление комиссии
        27/02/2007 madiyar - исправил ошибку с поиском счета ГК
        05/03/2007 madiyar - обработка схемы 4 (ИП), убрал сбор схем t-plans, теперь цикл просто по непогашенным кредитам
        11/03/2007 madiyar - acr.sts всегда 9
        28/04/2008 madiyar - начисление комиссии вынес из условия со ставками (комиссия должна начисляться и по кредитам со сброшенными %% ставками)
        14/01/2009 madiyar - начисление комиссии теперь происходит в самом начале цикла по кредитам, до next'а по признаку "Не начислять проценты"
        26/06/2009 madiyar - из-за next'а по признаку "не начислять проценты" может быть пропущен последний кредит в группе, соотв. не создается проводка по ГК; исправил
        15/09/2009 madiyar - не начислялись комиссии по кредитам без 1-го уровня, исправил
        16/09/2009 madiyar - исправление от 15/09/2009 оказалось не совсем правильным, еще раз исправил
        26/01/2010 madiyar - после начисления комиссии проверяем остатки, если кредит погашен - статус "C"
        02/02/2010 madiyar - начисление по кредиту 007141925 Фрайзстрой - всегда на внебаланс
        18/08/2010 madiyar - по экспресс-кредитам не начислять проценты после даты окончания по договору
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        24/08/2010 madiyar - комиссия по кредитам бывших сотрудников, начисление начиная с определенной даты
        22/10/2010 madiyar - изменил счет ГК 787000 -> 817000 (уравновешивающий для 717000)
        16/03/2011 madiyar - убрал next'ы
        31/08/2011 kapar - новый алгоритм исчисления 365/366 дней в году для (овердрафт и факторинг)
        28/06/2012 kapar - ASTANA BONUS
        25/07/2012 kapar - исправление по ASTANA BONUS
        16/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{lonlev.i}
{convgl.i "bank"}

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer no-undo.
    def var yy as integer no-undo.
    def var dd as integer no-undo.
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

def buffer bcrc for crc.
def buffer blon for lon.

def var v-intlev2 as int initial 2.
def var v-intlev4 as int initial 4.
def var v-intlev9 as int initial 9.
def var v-ilevNC as int initial 11.

/*ASTANA BONUS*/
def var v-intlev49 as int initial 49.
def var v-intlev53 as int initial 53.
def var v-intlev50 as int initial 50.
def var v-ilevNC51 as int initial 51.

def var v-crcnc like crc.crc initial 1.

find first bcrc where bcrc.crc = v-crcnc no-lock no-error.

def var v-glint2 like gl.gl no-undo.
def var v-glint4 like gl.gl no-undo.
def var v-glint9 like gl.gl no-undo.
def var v-gliNC like gl.gl no-undo.

/*ASTANA BONUS*/
def var v-glint49 like gl.gl no-undo.
def var v-glint53 like gl.gl no-undo.
def var v-glint50 like gl.gl no-undo.
def var v-gliNC51 like gl.gl no-undo.

define shared var s-target as date.
define shared var s-bday as log.
define shared var s-intday as int.

define new shared var s-jh  like jh.jh.

def var s-bank as char no-undo.
find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc then s-bank = sysc.chval.

define var v-code as char no-undo.
define var v-dep as char format 'x(3)' no-undo.
def buffer bgl for gl.

define var v-rate like pri.rate no-undo.
define var v-rate4 like pri.rate no-undo.
define var vln as int initial 1.
define var vcnt as int no-undo extent 3.
define var v-decpnt like crc.decpnt no-undo.
def var v-bal like glbal.bal no-undo.
def var v-bal7 like glbal.bal no-undo.
def var v-od as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.
define variable v-amt as decimal no-undo.

define var vm like jl.dam label "ACC INT" no-undo.
define var vmnc like jl.dam label "ACC INT NAT.CRC" no-undo.
define var vm4 like jl.dam label "ACC INT" no-undo.
define var vmnc4 like jl.dam label "ACC INT NAT.CRC" no-undo.
define var vm9 like jl.dam label "ACC INT" no-undo.
define var vmnc9 like jl.dam label "ACC INT NAT.CRC" no-undo.
/*ASTANA BONUS*/
define var vm_ad like jl.dam label "ACC INT" no-undo.
define var vmnc_ad like jl.dam label "ACC INT NAT.CRC" no-undo.
define var vm4_ad like jl.dam label "ACC INT" no-undo.
define var vmnc4_ad like jl.dam label "ACC INT NAT.CRC" no-undo.
define var vm9_ad like jl.dam label "ACC INT" no-undo.
define var vmnc9_ad like jl.dam label "ACC INT NAT.CRC" no-undo.

def var v-accrued like lon.accrued no-undo.
def var v-ncacr like lon.accrnc no-undo.
def var v-acrjl like jl.dam no-undo.
def var v-acrjlnc like jl.dam no-undo.

def var v-accrued4 like lon.accrued no-undo.
def var v-ncacr4 like lon.accrnc no-undo.
def var v-acrjl4 like jl.dam no-undo.
def var v-acrjlnc4 like jl.dam no-undo.
def var v-dayod as int no-undo.
define variable paraksts as logical no-undo.
define variable v-dt as date no-undo.

def var v-sysacr as log no-undo.
def var v-err as log no-undo.

def var v-dn1 as integer no-undo.
def var v-dn2 as decimal no-undo.
def var v-srok3 as integer no-undo.
def var v-dat3 as date no-undo.

def var v-bala as deci no-undo.

def var v-dn1s as integer no-undo.
def var v-dn2s as decimal no-undo.
define var v-rates like pri.rate no-undo.
define var v-dts as date no-undo.
def var v-accrueds like lon.accrued no-undo.
def var v-acrjls like jl.dam no-undo.

def var v_dd      as int.
def var v_basedy  as int.

def var v-prem as deci.
def var v-rprem as deci.
def var v-dprem as deci.

def var v-logfile as char no-undo.
v-logfile = "lonacr" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".txt".

def var v-errfile as char no-undo.
v-errfile = "lonacr" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".err".

procedure rec2log:
   define input parameter v-file as char no-undo.
   define input parameter v-str as char no-undo.
   output to value(v-file) append.
   put unformatted v-str skip.
   output close.
end procedure.

def var dat_wrk as date no-undo.
find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

find first sysc where sysc.sysc = "lonacr" no-lock no-error.
if available sysc then v-sysacr = sysc.loval. else v-sysacr = no.
if v-sysacr then do transaction:
     run x-jhnew.
     pause 0.
     find first jh where jh.jh = s-jh exclusive-lock no-error.
     if avail jh then do:
         jh.crc = 0.
         jh.party = "LON ACCRUED INTEREST TRANSACTION".
         if not s-bday then jh.jdt = s-target.
         vln = 1.
     end.
end. /* transaction */




/* --------------------- Цикл по кредитам -------------------------------- */

for each lon where lon.sts <> 'C' no-lock break by lon.crc by lon.gl:

    if first-of(lon.crc) then do:
        find first crc where crc.crc eq lon.crc no-lock no-error.
        if avail crc then v-decpnt = crc.decpnt. else v-decpnt = 2.
    end.

    /*ASTANA BONUS*/
    if (lon.grp = 95 or lon.grp = 96) and (g-today >= lon.rdate) and (g-today <= lon.ddate) then do:
        if lon.prem = 0 then do:
          v-prem = lon.prem1.
          v-rprem = lon.prem1 - lon.dprem1.
          v-dprem = lon.dprem1.
        end.
        else do:
          v-prem = lon.prem.
          v-rprem = lon.prem - lon.dprem.
          v-dprem = lon.dprem.
        end.
    end.
    else do:
        v-prem = 1.
        v-rprem = 1.
        v-dprem = 0.
    end.

    /* ------------ Счета ГК ---------------- */

    if first-of(lon.gl) then do:
        vm = 0.    vm_ad = 0.
        vmnc = 0.  vmnc_ad = 0.
        vm4 = 0.   vm4_ad = 0.
        vmnc4 = 0. vmnc4_ad = 0.
        vm9 = 0.   vm9_ad = 0.
        vmnc9 = 0. vmnc9_ad = 0.
        v-err = no.
        vcnt = 0.
        find first gl where gl.gl = lon.gl no-lock no-error.
        if avail gl then do:

            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev2 no-lock no-error.
            if available trxlevgl then v-glint2 = trxlevgl.glr.
                                  else v-err = yes.
            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev4 no-lock no-error.
            if available trxlevgl then v-glint4 = trxlevgl.glr.
                                  else v-err = yes.

            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev9 no-lock no-error.
            if available trxlevgl then v-glint9 = trxlevgl.glr.
                                  else v-err = yes.

            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-ilevnc no-lock no-error.
            if available trxlevgl then v-gliNC = trxlevgl.glr.
                                  else v-err = yes.

            /*ASTANA BONUS*/
            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev49 no-lock no-error.
            if available trxlevgl then v-glint49 = trxlevgl.glr.
                                  else v-err = yes.
            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev53 no-lock no-error.
            if available trxlevgl then v-glint53 = trxlevgl.glr.
                                  else v-err = yes.

            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-intlev50 no-lock no-error.
            if available trxlevgl then v-glint50 = trxlevgl.glr.
                                  else v-err = yes.

            find first trxlevgl where trxlevgl.gl eq gl.gl and trxlevgl.sub eq gl.subled and trxlevgl.level eq v-ilevNC51 no-lock no-error.
            if available trxlevgl then v-gliNC51 = trxlevgl.glr.
                                  else v-err = yes.

        end. /* if avail gl */
    end. /* if first-of(lon.gl) */


    /* расчет остатка 1-го уровня (ОД) */
    v-bal = 0.
    for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon no-lock:
        if lookup(string(trxbal.level), v-prnfslev, ";") > 0 then v-bal = v-bal + (trxbal.dam - trxbal.cam).
    end.

    /* -------- начисление комиссии за обслуживание кредита ------------- */
    if lon.duedt > dat_wrk then do:
        if lookup(string(lon.plan),"4,5") > 0 and s-bday then do:
            find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat > dat_wrk and lnsch.stdat <= g-today and lnsch.f0 > 0 no-lock no-error.
            if avail lnsch then do:
                find first cif where cif.cif = lon.cif no-lock no-error.
                find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
                if avail tarifex2 then do transaction:
                    create bxcif.
                    assign bxcif.cif = lon.cif
                           bxcif.aaa = lon.aaa
                           bxcif.crc = tarifex2.crc
                           bxcif.tim = time
                           bxcif.type = '195'
                           bxcif.whn = g-today
                           bxcif.who = if avail cif then cif.fname else ''
                           bxcif.amount  = tarifex2.ost
                           bxcif.period = string(year(g-today),"9999") + "/" + string(month(g-today),"99")
                           bxcif.rem = tarifex2.pakal + ". За " + bxcif.period + ". Счет " + lon.aaa
                           bxcif.pref = yes.
                    run rec2log(v-logfile,"<comm>   " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(bxcif.amount, "zzz,zzz,zz9.99")).
                end.
                else run rec2log(v-errfile,"<error!> cif=" + lon.cif + " lon=" + lon.lon + " gl=" + string(lon.gl) + " aaa=" + lon.aaa + " - не найден tarifex2!").
            end. /* if avail lnsch */
        end. /* if lookup(string(lon.plan),"4,5") > 0 and s-bday */
    end. /* if v-bal > 0 */

    run lonbal('lon',lon.lon,g-today,"1,7,2,9,4,16,5",yes,output v-bala).
    if v-bala <= 0 then do:
        do transaction:
            find first blon where blon.lon = lon.lon exclusive-lock.
            blon.sts = 'C'.
            find current blon no-lock.
        end.
    end.
    else do:
        /* Если установлен признак "Не начислять проценты" - пропускаем начисление процентов и переходим к следующему кредиту */
        find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "flagl" and sub-cod.ccode = "01" use-index dcod no-lock no-error.
        if not avail sub-cod then do:

            find last rate where rate.base = lon.base and rate.cdt <= g-today no-lock no-error.
            if available rate then assign v-rate = rate.rate + lon.prem
                                          v-rate4 = rate.rate + lon.prem1.
            else assign v-rate = lon.prem
                        v-rate4 = lon.prem1.

            if ((lon.prnmos = 1) or (lon.prnmos = 3)) and (lon.rdt > date('01/09/2011')) then do:
              dn1 = s-target - g-today.
              run mondays(2,year(s-target),output v_dd).
              if v_dd = 29 then v_basedy = 366. else v_basedy = 365.
            end.
            else do:
              v_basedy = lon.basedy.
              run day-360(g-today,s-target - 1,v_basedy,output dn1,output dn2).
            end.

            /* начисление по кредиту 007141925 Фрайзстрой - всегда на внебаланс */
            if lon.cif = "A11401" and lon.lon = "007141925" then do:
                if v-rate > 0 then do:
                    v-rate4 = v-rate.
                    v-rate = 0.
                end.
            end.

            /* Обработка кредитов ИП с 4-ой схемой начисления процентов */
            if lon.plan = 4 then do:
                /* раньше еще проверялся sub-cod с кодом "flagl" (не начислять проценты), но он проверяется выше, поэтому отсюда убрал) */
                if (lon.prem <> 0) or (lon.prem1 <> 0) then do:
                    run day-360(lon.rdt,lon.duedt - 1,v_basedy,output v-dn1,output v-dn2).
                    v-srok3 = integer (v-dn1 / 30 / 3).
                    v-dat3 = get-date(lon.rdt,v-srok3).
                    if v-dat3 <= g-today then do:
                        do transaction:
                            find first blon where blon.lon = lon.lon exclusive-lock.
                            blon.prem = 0.
                            blon.prem1 = 0.
                            find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "flagl" use-index dcod exclusive-lock no-error.
                            if avail sub-cod then do:
                                sub-cod.ccode = '01'.
                                find current sub-cod no-lock.
                            end.
                            find current blon no-lock.
                        end.
                        run rec2log(v-logfile,"<IP>     " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " - сброс ставки").
                    end. /* transaction */
                    else if v-dat3 < s-target then do:
                        run day-360(g-today,v-dat3 - 1,v_basedy,output dn1,output dn2).
                    end.
                end.
            end.

            if not(lon.plan = 4 and lon.prem = 0 and lon.prem1 = 0) then do:
                /* -------- начисление %% на 7 уровень (просроченный ОД) ----------------- */
                /* 20/05/2004 madiyar - начисление процентов на просроченный ОД отключено для 4-ой и 5-ой схем */

                if lookup(string(lon.plan),"4,5") = 0 then do:

                    v-bal7 = 0.
                    for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon no-lock:
                        if lookup(string(trxbal.level), v-prnodlev, ";") > 0 then v-bal7 = v-bal7 + (trxbal.dam - trxbal.cam).
                    end.

                    /* начисление в баланс */
                    if v-bal7 > 0 and v-rate > 0 then do:

                        v-accrued = dn1 * v-bal7 * lon.prem / 100 / v_basedy.
                        if v-accrued > 0 then do:
                            vcnt[1] = vcnt[1] + 1.
                            v-acrjl = round(v-accrued,v-decpnt).

                            do transaction:
                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev9 and trxbal.crc = lon.crc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-intlev9
                                           trxbal.crc = lon.crc
                                           trxbal.gl = v-glint9.
                                end.
                                trxbal.dam = trxbal.dam + (v-acrjl / v-prem) * v-rprem.
                                find current trxbal no-lock.

                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-ilevNC and trxbal.crc = v-crcnc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-ilevNC
                                           trxbal.crc = v-crcnc
                                           trxbal.gl = v-gliNC.
                                end.
                                if lon.crc = v-crcnc then v-ncacr = v-acrjl.
                                else do:
                                    find first crc where crc.crc = lon.crc no-lock no-error.
                                    v-ncacr = v-acrjl * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                                end.
                                v-acrjlnc = v-ncacr.
                                trxbal.cam = trxbal.cam +  (v-acrjlnc / v-prem) * v-rprem.
                                find current trxbal no-lock.

                                /*ASTANA BONUS*/
                                if v-dprem > 0 then do:
                                    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev50 and trxbal.crc = lon.crc exclusive-lock no-error.
                                    if not available trxbal then do:
                                        create trxbal.
                                        assign trxbal.subled = "LON"
                                               trxbal.acc = lon.lon
                                               trxbal.level = v-intlev50
                                               trxbal.crc = lon.crc
                                               trxbal.gl = v-glint50.
                                    end.
                                    trxbal.dam = trxbal.dam + (v-acrjl / v-prem) * v-dprem.
                                    find current trxbal no-lock.

                                    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-ilevNC51 and trxbal.crc = v-crcnc exclusive-lock no-error.
                                    if not available trxbal then do:
                                        create trxbal.
                                        assign trxbal.subled = "LON"
                                               trxbal.acc = lon.lon
                                               trxbal.level = v-ilevNC51
                                               trxbal.crc = v-crcnc
                                               trxbal.gl = v-gliNC51.
                                    end.
                                    if lon.crc = v-crcnc then v-ncacr = v-acrjl.
                                    else do:
                                        find first crc where crc.crc = lon.crc no-lock no-error.
                                        v-ncacr = v-acrjl * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                                    end.
                                    v-acrjlnc = v-ncacr.
                                    trxbal.cam = trxbal.cam +  (v-acrjlnc / v-prem) * v-dprem.
                                    find current trxbal no-lock.
                                end.

                                find first blon where blon.lon = lon.lon exclusive-lock no-error.
                                blon.accrued = v-accrued - v-acrjl.
                                blon.accrnc = v-ncacr - v-acrjlnc.
                                find current blon no-lock.

                                vmnc9 = vmnc9 + (v-acrjlnc / v-prem) * v-rprem.
                                vm9 = vm9 + (v-acrjl / v-prem) * v-rprem.
                                /*ASTANA BONUS*/
                                if v-dprem > 0 then do:
                                  vmnc9_ad = vmnc9_ad + (v-acrjlnc / v-prem) * v-dprem.
                                  vm9_ad = vm9_ad + (v-acrjl / v-prem) * v-dprem.
                                end.
                            end. /* transaction */

                            run rec2log(v-logfile,"<prc9>   " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(v-acrjl, "zzz,zzz,zz9.99")).

                        end. /* if v-accrued > 0 */

                    end. /* if v-bal7 > 0 and v-rate > 0 */

                    /* начисление на внебаланс */
                    if v-bal7 > 0 and v-rate4 > 0 then do: /* 15/02/2006 - Natalya D.*/

                        v-accrued4 = dn1 * v-bal7 * lon.prem1 / 100 / v_basedy.
                        if v-accrued4 > 0 then do:
                            vcnt[2] = vcnt[2] + 1.
                            v-acrjl4 = round(v-accrued4,v-decpnt).

                            do transaction:
                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev4 and trxbal.crc = lon.crc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-intlev4
                                           trxbal.crc = lon.crc
                                           trxbal.gl = v-glint4.
                                end.
                                trxbal.dam = trxbal.dam + (v-acrjl4 / v-prem) * v-rprem.
                                find current trxbal no-lock.

                                /*ASTANA BONUS*/
                                if v-dprem > 0 then do:
                                    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev53 and trxbal.crc = lon.crc exclusive-lock no-error.
                                    if not available trxbal then do:
                                        create trxbal.
                                        assign trxbal.subled = "LON"
                                               trxbal.acc = lon.lon
                                               trxbal.level = v-intlev53
                                               trxbal.crc = lon.crc
                                               trxbal.gl = v-glint53.
                                    end.
                                    trxbal.dam = trxbal.dam + (v-acrjl4 / v-prem) * v-dprem.
                                    find current trxbal no-lock.
                                end.

                                if lon.crc = v-crcnc then v-ncacr4 = v-acrjl4.
                                else do:
                                    find first crc where crc.crc = lon.crc no-lock no-error.
                                    v-ncacr4 = v-acrjl4 * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                                end.
                                v-acrjlnc4 = v-ncacr4.
                                /*trxbal.cam = trxbal.cam +  v-acrjlnc4.*/

                                find first blon where blon.lon = lon.lon exclusive-lock no-error.
                                blon.accrued = v-accrued4 - v-acrjl4.
                                blon.accrnc = v-ncacr4 - v-acrjlnc4.
                                find current blon no-lock.

                                vmnc4 = vmnc4 + (v-acrjlnc4 / v-prem) * v-rprem.
                                vm4 = vm4 + (v-acrjl4 / v-prem) * v-rprem.
                                /*ASTANA BONUS*/
                                if v-dprem > 0 then do:
                                  vmnc4_ad = vmnc4_ad + (v-acrjlnc4 / v-prem) * v-dprem.
                                  vm4_ad = vm4_ad + (v-acrjl4 / v-prem) * v-dprem.
                                end.
                            end. /* transaction */

                            run rec2log(v-logfile,"<prc9-4> " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(v-acrjl4, "zzz,zzz,zz9.99")).
                        end. /* if v-accrued4 > 0 */
                    end. /* if v-bal7 > 0 and v-rate4 > 0 */
                end. /* lookup(string(lon.plan),"4,5") = 0 */



                /* -------- начисление %% на 1 уровень (ОД) ----------------- * */

                if v-bal > 0 and (v-rate > 0 or v-rate4 > 0) then do:

                    if lookup(string(lon.plan),"4,5") = 0 then do:
                        v-accrued = dn1 * v-bal * v-rate / 100 / v_basedy.
                        v-accrued4 = dn1 * v-bal * v-rate4 / 100 / v_basedy.
                    end.
                    else do:
                        v-accrued = dn1 * lon.opnamt * v-rate / 100 / v_basedy.
                        v-accrued4 = dn1 * lon.opnamt * v-rate4 / 100 / v_basedy.
                    end.

                    /* корректировка процентов по 5-ой схеме для последнего погашения */
                    if lookup(string(lon.plan),"4,5") > 0 then do:
                      if lon.duedt <= g-today then do:
                        v-accrued  = 0.
                        v-accrued4 = 0.
                      end.
                      else
                      if lon.duedt > g-today and lon.duedt < s-target then do:
                        run day-360(g-today,lon.duedt - 1,v_basedy,output dn1,output dn2).
                        v-accrued  = dn1 * lon.opnamt * v-rate / 100 / v_basedy.
                        v-accrued4 = dn1 * lon.opnamt * v-rate4 / 100 / v_basedy.
                      end.
                    end.

                    /* начисление в баланс */
                    if v-accrued > 0 then do:
                        vcnt[3] = vcnt[3] + 1.
                        v-accrued = v-accrued + lon.accrued.
                        v-acrjl = round(v-accrued,v-decpnt).

                        do transaction:
                            find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev2 and trxbal.crc = lon.crc exclusive-lock no-error.
                            if not available trxbal then do:
                                create trxbal.
                                assign trxbal.subled = "LON"
                                       trxbal.acc = lon.lon
                                       trxbal.level = v-intlev2
                                       trxbal.crc = lon.crc
                                       trxbal.gl = v-glint2.
                            end.
                            trxbal.dam = trxbal.dam + (v-acrjl / v-prem) * v-rprem.
                            find current trxbal no-lock.

                            find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-ilevNC and trxbal.crc = v-crcnc exclusive-lock no-error.
                            if not available trxbal then do:
                                create trxbal.
                                assign trxbal.subled = "LON"
                                       trxbal.acc = lon.lon
                                       trxbal.level = v-ilevNC
                                       trxbal.crc = v-crcnc
                                       trxbal.gl = v-gliNC.
                            end.
                            if lon.crc = v-crcnc then v-ncacr = v-acrjl.
                            else do:
                                find first crc where crc.crc = lon.crc no-lock no-error.
                                v-ncacr = v-acrjl * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                            end.
                            v-ncacr = v-ncacr + lon.accrnc.
                            v-acrjlnc = v-ncacr.
                            trxbal.cam = trxbal.cam +  (v-acrjlnc / v-prem) * v-rprem.
                            find current trxbal no-lock.

                            /*ASTANA BONUS*/
                            if v-dprem > 0 then do:
                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev49 and trxbal.crc = lon.crc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-intlev49
                                           trxbal.crc = lon.crc
                                           trxbal.gl = v-glint49.
                                end.
                                trxbal.dam = trxbal.dam + (v-acrjl / v-prem) * v-dprem.
                                find current trxbal no-lock.

                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-ilevNC51 and trxbal.crc = v-crcnc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-ilevNC51
                                           trxbal.crc = v-crcnc
                                           trxbal.gl = v-gliNC51.
                                end.
                                if lon.crc = v-crcnc then v-ncacr = v-acrjl.
                                else do:
                                    find first crc where crc.crc = lon.crc no-lock no-error.
                                    v-ncacr = v-acrjl * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                                end.
                                v-ncacr = v-ncacr + lon.accrnc.
                                v-acrjlnc = v-ncacr.
                                trxbal.cam = trxbal.cam + (v-acrjlnc / v-prem) * v-dprem.
                                find current trxbal no-lock.
                            end.


                            find first blon where blon.lon = lon.lon exclusive-lock no-error.
                            blon.dam[v-intlev2] = blon.dam[v-intlev2] + v-acrjl.
                            blon.accrued = v-accrued - v-acrjl.
                            blon.accrnc = v-ncacr - v-acrjlnc.
                            find current blon no-lock.

                            vmnc = vmnc + (v-acrjlnc / v-prem) * v-rprem.
                            vm = vm + (v-acrjl / v-prem) * v-rprem.
                            /*ASTANA BONUS*/
                            if v-dprem > 0 then do:
                              vmnc_ad = vmnc_ad + (v-acrjlnc / v-prem) * v-dprem.
                              vm_ad = vm_ad + (v-acrjl / v-prem) * v-dprem.
                            end.
                        end. /* transaction */

                        run rec2log(v-logfile,"<prc2>   " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(v-acrjl, "zzz,zzz,zz9.99")).

                    end. /* if v-accrued > 0 */

                    /* начисление на внебаланс */
                    if v-accrued4 > 0 then do:
                        vcnt[2] = vcnt[2] + 1.
                        v-accrued4 = v-accrued4 + lon.accrued.
                        v-acrjl4 = round(v-accrued4,v-decpnt).

                        do transaction:
                            find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev4 and trxbal.crc = lon.crc exclusive-lock no-error.
                            if not available trxbal then do:
                                create trxbal.
                                assign trxbal.subled = "LON"
                                       trxbal.acc = lon.lon
                                       trxbal.level = v-intlev4
                                       trxbal.crc = lon.crc
                                       trxbal.gl = v-glint4.
                            end.
                            trxbal.dam = trxbal.dam + (v-acrjl4 / v-prem) * v-rprem.
                            find current trxbal no-lock.

                            /*ASTANA BONUS*/
                            if v-dprem > 0 then do:
                                find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = v-intlev53 and trxbal.crc = lon.crc exclusive-lock no-error.
                                if not available trxbal then do:
                                    create trxbal.
                                    assign trxbal.subled = "LON"
                                           trxbal.acc = lon.lon
                                           trxbal.level = v-intlev53
                                           trxbal.crc = lon.crc
                                           trxbal.gl = v-glint53.
                                end.
                                trxbal.dam = trxbal.dam + (v-acrjl4 / v-prem) * v-dprem.
                                find current trxbal no-lock.
                            end.

                            if lon.crc = v-crcnc then v-ncacr4 = v-acrjl4.
                            else do:
                                find first crc where crc.crc = lon.crc no-lock no-error.
                                v-ncacr4 = v-acrjl4 * crc.rate[1] / crc.rate[9] * bcrc.rate[9] / bcrc.rate[1].
                            end.
                            v-ncacr4 = v-ncacr4 + lon.accrnc.
                            v-acrjlnc4 = v-ncacr4.
                            /*trxbal.cam = trxbal.cam +  v-acrjlnc4.*/

                            find first blon where blon.lon = lon.lon exclusive-lock no-error.
                            blon.dam[v-intlev4] = blon.dam[v-intlev4] + v-acrjl4.
                            blon.accrued = v-accrued4 - v-acrjl4.
                            blon.accrnc = v-ncacr4 - v-acrjlnc4.
                            find current blon no-lock.

                            vmnc4 = vmnc4 + (v-acrjlnc4 / v-prem) * v-rprem.
                            vm4 = vm4 + (v-acrjl4 / v-prem) * v-rprem.
                            /*ASTANA BONUS*/
                            if v-dprem > 0 then do:
                              vmnc4_ad = vmnc4_ad + (v-acrjlnc4 / v-prem) * v-dprem.
                              vm4_ad = vm4_ad + (v-acrjl4 / v-prem) * v-dprem.
                            end.
                        end. /* transaction */

                        run rec2log(v-logfile,"<prc2-4> " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(v-acrjl4, "zzz,zzz,zz9.99")).

                    end. /* if v-accrued4 > 0 */
                    /* end - начисление на внебаланс */

                end. /* if v-bal > 0 and (v-rate > 0 or v-rate4 > 0) */


                /* -------- начисление комиссии по кредитам бывших сотрудников на 1 уровень (ОД) ----------------- * */
                v-rates = 0.
                find first lons where lons.lon = lon.lon no-lock no-error.
                if avail lons then do:
                    v-rates = lons.prem.
                    v-dts = lons.rdt.
                    if v-bal > 0 and v-rates > 0 and v-dts < s-target then do:
                        if v-dts > g-today then run day-360(v-dts,s-target - 1,v_basedy,output v-dn1s,output v-dn2s).
                        else v-dn1s = dn1.
                        v-accrueds = v-dn1s * v-bal * v-rates / 100 / v_basedy.
                        if v-accrueds > 0 then do:
                            v-accrueds = v-accrueds + lons.accrued.
                            v-acrjls = round(v-accrueds,v-decpnt).

                            do transaction:
                                find current lons exclusive-lock.
                                lons.amt = lons.amt + v-acrjls.
                                lons.accrued = v-accrueds - v-acrjls.
                                find current lons no-lock.
                                find last lonsres where lonsres.lon = lon.lon and lonsres.restype = "a" and lonsres.od = v-bal and lonsres.prem = v-rates use-index lontype exclusive-lock no-error.
                                if not avail lonsres then do:
                                    create lonsres.
                                    assign lonsres.lon = lon.lon
                                           lonsres.restype = "a"
                                           lonsres.od = v-bal
                                           lonsres.prem = v-rates
                                           lonsres.who = g-ofc.
                                    if v-dts > g-today then lonsres.fdt = v-dts. else lonsres.fdt = g-today.
                                end.
                                lonsres.amt = lonsres.amt + v-acrjls.
                                lonsres.tdt = s-target - 1.
                            end.

                            run rec2log(v-logfile,"<prccm> " + lon.cif + " " + lon.lon + " " + string(lon.crc,"zz9") + " " + string(v-acrjls, "zzz,zzz,zz9.99")).

                        end. /* if v-accrueds > 0 */
                    end. /* if v-bal > 0 and v-rates > 0 */
                end. /* if avail lons */



                if v-bal + v-bal7 > 0 then do transaction:
                    find last acr where acr.lon = lon.lon exclusive-lock no-error.
                    if available acr then do:
                        if year(acr.tdt) = year(g-today) and
                            month(acr.tdt) = month(g-today) and
                            acr.rate = v-rate and
                            acr.prn = v-bal + v-bal7 and
                            acr.tdt = g-today - 1
                            then assign acr.tdt = s-target - 1
                                        acr.who = g-ofc
                                        acr.whn = g-today.
                        else do:
                            create acr.
                            assign acr.lon = lon.lon
                                   acr.fdt = g-today
                                   acr.tdt = s-target - 1
                                   acr.prn = v-bal + v-bal7
                                   acr.rate = v-rate
                                   acr.who = g-ofc
                                   acr.whn = g-today
                                   acr.sts = 9.
                        end.
                    end.
                    else do:
                        create acr.
                        assign acr.lon = lon.lon
                               acr.fdt = g-today
                               acr.tdt = s-target - 1
                               acr.prn = v-bal + v-bal7
                               acr.rate = v-rate
                               acr.who = g-ofc
                               acr.whn = g-today
                               acr.sts = 9.
                    end.

                    /* Для расчета процентов по потребительским кредитам выданным в выходные дни*/
                    if lon.extdt > g-today and lon.extdt < s-target then do:
                        run day-360(lon.extdt,s-target - 1,v_basedy,output dn1,output dn2).
                        find last acr where acr.lon = lon.lon no-error.
                        if avail acr then acr.fdt = lon.extdt.
                    end.

                    find current acr no-lock.
                end. /* transaction */ /* if v-bal + v-bal7 > 0 */
            end. /* if not(lon.plan = 4 and lon.prem = 0 and lon.prem1 = 0) */
        end. /* if not avail sub-cod - признак "не начислять проценты" */
    end.

    /* ---------------- рисование проводки ---------------------- */
    if last-of(lon.gl) and v-sysacr then do:
        /* начисление на ОД */
        if vm <> 0 then do transaction:
            find jh where jh.jh = s-jh.
            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = v-crcnc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.cam = vmnc.
            jl.dam = 0.
            jl.dc = "C".
            jl.gl = v-gliNC.
            jl.sub = "LON".
            jl.lev = 11.
            jl.acc = "".
            jl.rem[1] = "TOTAL " + string(vcnt[3]) + " ACCOUNTS".
            {cods2.i}                  /*19.04.2005 nataly*/
            vln = vln + 1.

            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = lon.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.dam = vm.
            jl.cam = 0.
            jl.dc = "D".
            jl.gl = v-glint2.
            jl.sub = "LON".
            jl.lev = 2.
            jl.acc = "".
            jl.rem = "".
            {cods2.i}                        /*19.04.2005 nataly*/
            vln = vln + 1.

            /*ASTANA BONUS*/
            if vm_ad <> 0 then do:
                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = v-crcnc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.cam = vmnc_ad.
                jl.dam = 0.
                jl.dc = "C".
                jl.gl = v-gliNC51.
                jl.sub = "LON".
                jl.lev = 51.
                jl.acc = "".
                jl.rem[1] = "TOTAL " + string(vcnt[3]) + " ACCOUNTS".
                {cods2.i}                  /*19.04.2005 nataly*/
                vln = vln + 1.

                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = lon.crc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.dam = vm_ad.
                jl.cam = 0.
                jl.dc = "D".
                jl.gl = v-glint49.
                jl.sub = "LON".
                jl.lev = 49.
                jl.acc = "".
                jl.rem = "".
                {cods2.i}                        /*19.04.2005 nataly*/
                vln = vln + 1.
            end.

            if lon.crc <> v-crcnc then do:
                /* find jh where jh.jh = s-jh. */
                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = lon.crc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.cam = vm.
                jl.dam = 0.
                jl.dc = "C".
                jl.gl = getConvGL(lon.crc,"C").
                jl.acc = "".
                jl.rem[1] = "TOTAL " + string(vcnt[3]) + " ACCOUNTS".
                {cods2.i}                    /*19.04.2005 nataly*/
                vln = vln + 1.

                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = v-crcnc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.dam = vmnc.
                jl.cam = 0.
                jl.dc = "D".
                jl.gl = getConvGL(v-crcnc,"D").
                jl.acc = "".
                jl.rem = "".
                {cods2.i}                    /*19.04.2005 nataly*/
                vln = vln + 1.
            end. /* if lon.crc <> v-crcnc */
        end. /* transaction */ /* if vm <> 0 */

        /* начисление на просроченный ОД */
        if vm9 <> 0 then do transaction:
            find jh where jh.jh = s-jh.
            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = v-crcnc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.cam = vmnc9.
            jl.dam = 0.
            jl.dc = "C".
            jl.gl = v-gliNC.
            jl.sub = "LON".
            jl.lev = 11.
            jl.acc = "".
            jl.rem[1] = "TOTAL " + string(vcnt[1]) + " ACCOUNTS".
            {cods2.i}                        /*19.04.2005 nataly*/
            vln = vln + 1.

            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = lon.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.dam = vm9.
            jl.cam = 0.
            jl.dc = "D".
            jl.gl = v-glint9.
            jl.sub = "LON".
            jl.lev = 9.
            jl.acc = "".
            jl.rem = "".
            {cods2.i}                        /*19.04.2005 nataly*/
            vln = vln + 1.

            /*ASTANA BONUS*/
            if vm9_ad <> 0 then do:
                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = v-crcnc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.cam = vmnc9_ad.
                jl.dam = 0.
                jl.dc = "C".
                jl.gl = v-gliNC51.
                jl.sub = "LON".
                jl.lev = 51.
                jl.acc = "".
                jl.rem[1] = "TOTAL " + string(vcnt[1]) + " ACCOUNTS".
                {cods2.i}                        /*19.04.2005 nataly*/
                vln = vln + 1.

                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = lon.crc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.dam = vm9_ad.
                jl.cam = 0.
                jl.dc = "D".
                jl.gl = v-glint50.
                jl.sub = "LON".
                jl.lev = 50.
                jl.acc = "".
                jl.rem = "".
                {cods2.i}                        /*19.04.2005 nataly*/
                vln = vln + 1.
            end.

            if lon.crc <> v-crcnc then do:
                /* find jh where jh.jh = s-jh. */
                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = lon.crc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.cam = vm9.
                jl.dam = 0.
                jl.dc = "C".
                jl.gl = getConvGL(lon.crc,"C").
                jl.acc = "".
                jl.rem[1] = "TOTAL " + string(vcnt[1]) + " ACCOUNTS".
                {cods2.i}                    /*19.04.2005 nataly*/
                vln = vln + 1.

                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = v-crcnc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.dam = vmnc9.
                jl.cam = 0.
                jl.dc = "D".
                jl.gl = getConvGL(v-crcnc,"D").
                jl.acc = "".
                jl.rem = "".
                {cods2.i}                    /*19.04.2005 nataly*/
                vln = vln + 1.
            end. /* if lon.crc <> v-crcnc */
        end. /* transaction */ /* if vm9 <> 0 */

        /* начисление на внебаланс */
        if vm4 <> 0 then do transaction:
            find jh where jh.jh = s-jh.
            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = lon.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.dam = vm4.
            jl.cam = 0.
            jl.dc = "D".
            jl.gl = v-glint4.
            jl.sub = "LON".
            jl.lev = 4.
            jl.acc = "".
            jl.rem = "".
            {cods2.i}
            vln = vln + 1.

            /*ASTANA BONUS*/
            if vm4_ad <> 0 then do:
                find jh where jh.jh = s-jh.
                create jl.
                jl.jh = jh.jh.
                jl.ln = vln.
                jl.crc = lon.crc.
                jl.who = jh.who.
                jl.jdt = jh.jdt.
                jl.whn = jh.whn.
                jl.dam = vm4_ad.
                jl.cam = 0.
                jl.dc = "D".
                jl.gl = v-glint53.
                jl.sub = "LON".
                jl.lev = 53.
                jl.acc = "".
                jl.rem = "".
                {cods2.i}
                vln = vln + 1.
            end.

            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = lon.crc.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.cam = vm4.
            jl.dam = 0.
            jl.dc = "C".
            jl.gl = 817000.
            jl.acc = "".
            jl.rem[1] = "TOTAL " + string(vcnt[2]) + " ACCOUNTS".
            {cods2.i}
            vln = vln + 1.
        end. /* transaction */
        /*end - начисление на внебаланс */
    end.  /* if last-of(lon.gl) */

end.  /* for each lon */

/* --------------- конец цикла по кредитам -------------------------- */

run rec2log(v-logfile,"<transaction> " + string(s-jh)).


