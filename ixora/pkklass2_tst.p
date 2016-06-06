/* pkklass2_tst.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Тест автоматического расчета классификации по экспресс-кредитам
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
        30/09/2009 madiyar - скопировал из pkklass2.p с изменениями
 * BASES
        BANK COMM TXB
 * CHANGES
        29/10/2009 madiyar - увеличиваем дни просрочки до конца месяца
        01/12/2009 madiyar - учитываем замороженные и задержанные средства на счету
        26/01/2010 madiyar - добавил 4 столбца с данными по наличию средств на счету и суммами к оплате
        31/03/2010 madiyar - кредиты в ин. валюте и без просрочки, выданные с 1 сент 2009 классифицируем не выше "сомн. 1 категории"
        31/08/2010 madiyar - кредиты в ин. валюте и без просрочки, выданные с 1 сент 2009 классифицируем не выше "сомн. 2 категории"
        12/10/2010 madiyar - изменения по расчету фин. состояния; убрал три ненужных критерия
        03/01/2011 madiyar - по экспресс-кредитам провизии начисляем и на начисл. и просроч. проценты
        01/03/2011 madiyar - однородные кредиты
        27/07/2011 madiyar - подправил прогноз сумм
*/

def shared var g-today as date.
def shared var g-ofc as char.
def shared var add_pr as integer no-undo.
def shared var s-rates as deci no-undo extent 3.

def shared temp-table wrk no-undo
  field bank as char
  field cif as char
  field lon as char
  field crc as integer
  field od as deci
  field od_pro as deci

  field prc2 as deci
  field prc2_pro as deci
  field prc9 as deci
  field prc9_pro as deci
  field pen as deci
  field pen_pro as deci

  field fio as char

  /*
  field sts as char extent 8
  field sts_des as char extent 8
  field rating as deci extent 8
  */
  field sts as char extent 5
  field sts_des as char extent 5
  field rating as deci extent 5

  field rating_s as deci
  field dtcl as date
  field days as integer
  field fdays as integer
  field days_old as integer
  field restr as char
  field class_old as char
  field class as char
  field class_odn as char
  field class_prc as deci

  field prov as deci
  field progprov as deci
  field progprov_od as deci
  field progprov_prc as deci
  field progprov_pen as deci

  field acc_avail_amt1 as deci
  field acc_avail_amt2 as deci

  field pay_amt1 as deci
  field pay_amt2 as deci

  field acc_left_amt1 as deci
  field acc_left_amt2 as deci

  field dbt_left_amt1 as deci
  field dbt_left_amt2 as deci

  field dayspprc as integer

  field port as char

  index idx is primary bank fio cif
  index idx2 bank port.

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

hide message no-pause.
message "TESTCLASS " + s-ourbank.

def var v-dt as date no-undo.
/*def var kod_list as char no-undo init "finsost1,prosr,obesp1,long,prosr_ob1,ispakt,spisob1,rait1".*/
def var kod_list as char no-undo init "finsost1,prosr,obesp1,ispakt,rait1".

def temp-table t-kdlonkl like kdlonkl.

def var v-prosr as char no-undo.
def var v-rat as deci no-undo.
def var v-coun as int no-undo init 0.

def var v-days_od as int no-undo init 0.
def var v-days_prc as int no-undo init 0.
def var v-maxpr as int no-undo init 0.
def var v-maxpr_old as int no-undo init 0.
def var v-fdays_od as int no-undo init 0.
def var v-fdays_prc as int no-undo init 0.
def var v-fmaxpr as int no-undo init 0.
def var v-err as char no-undo.
def var i as integer no-undo.
def var v-pprc as integer no-undo.

def var v-aaakzt as char no-undo. /* KZT-счет для валютных кредитов */
def var v-aaabal as deci no-undo.
def var v-aaabalkzt as deci no-undo.
def var v-bilance as deci no-undo.
def var v-bilance_pro as deci no-undo.
def var v-prov as deci no-undo.
def var v-prov_kzt as deci no-undo.

def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal2_pro as deci no-undo.
def var v-bal9_pro as deci no-undo.
def var v-bal16_pro as deci no-undo.

def var v-bal16 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal5 as deci no-undo.
def var nach_od as deci no-undo.
def var nach_prc as deci no-undo.
def var paycom as deci no-undo.
def var v-prpog as char no-undo.

def var dat_wrk as date no-undo.
find last txb.cls where txb.cls.whn < g-today and txb.cls.del no-lock no-error.
dat_wrk = txb.cls.whn.

/* однородные - справочники */
def var v-sumodn as deci no-undo.
def var v-class as char no-undo extent 2.
def var v-resprcodn as deci no-undo extent 2.

find first txb.sysc where txb.sysc.sysc = "lnodnorf" no-lock no-error.
if avail txb.sysc and num-entries(txb.sysc.chval,'|') = 2 then do:
    v-resprcodn[1] = deci(entry(1,txb.sysc.chval,'|')) no-error.
    if error-status:error then do:
        message "Некорректная ставка по портфелю однородных кредитов Метрокредит!" view-as alert-box.
        return.
    end.
    v-resprcodn[2] = deci(entry(2,txb.sysc.chval,'|')) no-error.
    if error-status:error then do:
        message "Некорректная ставка по портфелю однородных кредитов сотрудников!" view-as alert-box.
        return.
    end.

    if (v-resprcodn[1] < 0) or (v-resprcodn[1] > 100) then do:
        message "Некорректная ставка по портфелю однородных кредитов Метрокредит!" view-as alert-box.
        return.
    end.
    if (v-resprcodn[2] < 0) or (v-resprcodn[2] > 100) then do:
        message "Некорректная ставка по портфелю однородных кредитов сотрудников!" view-as alert-box.
        return.
    end.
end.
else do:
    message "Ставки по портфелям однородных кредитов не проставлены!" view-as alert-box.
    return.
end.

do i = 1 to 2:
    if v-resprcodn[i] = 0 then v-class[i] = '01'. /* стандартный */
    else
    if v-resprcodn[i] <= 5 then v-class[i] = '02'. /* сомнительный 1-ой категории */
    else
    if v-resprcodn[i] <= 10 then v-class[i] = '03'. /* сомнительный 2-ой категории */
    else
    if v-resprcodn[i] <= 20 then v-class[i] = '04'. /* сомнительный 3-ой категории */
    else
    if v-resprcodn[i] <= 25 then v-class[i] = '05'. /* сомнительный 4-ой категории */
    else
    if v-resprcodn[i] <= 50 then v-class[i] = '06'. /* сомнительный 5-ой категории */
    else v-class[i] = '07'. /* безнадежный */
end.

v-sumodn = 0.
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
if avail pksysc then v-sumodn = pksysc.deval.
/* однородные - справочники - end */


for each txb.lon where txb.lon.grp = 90 or txb.lon.grp = 92 no-lock:
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1",yes,txb.lon.crc,output v-bal1).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output v-bal7).
    v-bilance = v-bal1 + v-bal7.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-bal2).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"9",yes,txb.lon.crc,output v-bal9).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"16",yes,1,output v-bal16).

    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"6,36",yes,txb.lon.crc,output v-prov).
    v-prov_kzt = - v-prov * s-rates[txb.lon.crc].
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"37",yes,1,output v-prov).
    v-prov_kzt = v-prov_kzt - v-prov.

    if (v-bilance <= 0) and (v-bal2 <= 0) and (v-bal9 <= 0) and (v-prov_kzt <= 0) and (v-bal16 <= 0) then next.

    empty temp-table t-kdlonkl.

    v-aaakzt = ''.
    if txb.lon.crc <> 1 then do:
        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if avail pkanketa then v-aaakzt = pkanketa.aaa.
    end.

    create wrk.
    assign wrk.bank = s-ourbank
           wrk.cif = txb.lon.cif
           wrk.lon = txb.lon.lon
           wrk.crc = txb.lon.crc
           wrk.od = v-bilance
           wrk.prc2 = v-bal2
           wrk.prc9 = v-bal9
           wrk.pen = v-bal16
           wrk.prov = v-prov_kzt.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if avail txb.cif then wrk.fio = trim(txb.cif.name).

    v-dt = ?.
    find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon use-index bclrdt no-lock no-error.
    if avail kdlonkl then v-dt = kdlonkl.rdt.

    if v-dt < g-today then do:
        for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.rdt = v-dt no-lock:
            create t-kdlonkl.
            buffer-copy kdlonkl to t-kdlonkl.
            assign t-kdlonkl.rdt = g-today
                   t-kdlonkl.who = g-ofc.
        end.
        release t-kdlonkl.
    end.

    /* 2. просрочка */
    v-maxpr = 0.
    run lndayspry_txb(txb.lon.lon,g-today,yes,output v-days_od,output v-days_prc,output v-maxpr_old).
    if v-days_od > 0 then v-days_od = v-days_od + add_pr.
    if v-days_prc > 0 then v-days_prc = v-days_prc + add_pr.
    if v-maxpr_old < v-days_od then v-maxpr_old = v-days_od.
    if v-maxpr_old < v-days_prc then v-maxpr_old = v-days_prc.
    if v-days_od > v-days_prc then v-maxpr = v-days_od. else v-maxpr = v-days_prc.

    v-aaabal = 0.
    find first txb.aaa where txb.aaa.aaa = txb.lon.aaa no-lock no-error.
    if avail txb.aaa then do:
        v-aaabal = txb.aaa.cbal - txb.aaa.hbal.
        if v-aaabal < 0 then v-aaabal = 0.
    end.

    v-aaabalkzt = 0.
    if txb.lon.crc <> 1 then do:
        find first txb.aaa where txb.aaa.aaa = v-aaakzt no-lock no-error.
        if avail txb.aaa then do:
            v-aaabalkzt = txb.aaa.cbal - txb.aaa.hbal.
            if v-aaabalkzt < 0 then v-aaabalkzt = 0.
        end.
    end.

    wrk.acc_avail_amt1 = v-aaabal.
    wrk.acc_avail_amt2 = v-aaabalkzt.

    v-bilance_pro = v-bilance.
    v-bal2_pro = v-bal2.
    v-bal9_pro = v-bal9.
    v-bal16_pro = v-bal16.

    if (v-aaabal > 0) or (v-aaabalkzt > 0) then do:
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"4",yes,txb.lon.crc,output v-bal4).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"5",yes,1,output v-bal5).

        nach_od = 0. nach_prc = 0.
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today no-lock no-error.
        if avail txb.lnsch then do:
            nach_od = txb.lnsch.stval.
            if nach_od > v-bal1 then nach_od = v-bal1.
        end.
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat > dat_wrk and txb.lnsci.idat <= g-today no-lock no-error.
        if avail txb.lnsci then do:
            nach_prc = txb.lnsci.iv-sc.
            if nach_prc > v-bal2 then nach_prc = v-bal2.
        end.

        paycom = 0.
        for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.aaa = txb.lon.aaa and txb.bxcif.type = '195' no-lock:
            paycom = paycom + txb.bxcif.amount.
        end.
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today and txb.lnsch.f0 > 0 no-lock no-error.
        if avail txb.lnsch then do:
            find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
            if avail txb.tarifex2 then paycom = paycom + txb.tarifex2.ost.
        end.

        if txb.lon.crc = 1 then wrk.pay_amt1 = v-bal16 + v-bal5 + v-bal9 + v-bal4 + paycom + v-bal7 + nach_od + nach_prc.
        else do:
            wrk.pay_amt1 = v-bal9 + v-bal4 + paycom + v-bal7 + nach_od + nach_prc.
            wrk.pay_amt2 = v-bal16 + v-bal5.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnpog' no-lock no-error.
        if (not avail sub-cod) or (sub-cod.ccode = 'msc') then v-prpog = 'msc'.
        else v-prpog = sub-cod.ccode.

        wrk.acc_left_amt1 = wrk.acc_avail_amt1 - wrk.pay_amt1.
        wrk.acc_left_amt2 = wrk.acc_avail_amt2 - wrk.pay_amt2.
        if wrk.acc_left_amt1 < 0 then wrk.acc_left_amt1 = 0.
        if wrk.acc_left_amt2 < 0 then wrk.acc_left_amt2 = 0.

        wrk.dbt_left_amt1 = wrk.pay_amt1 - wrk.acc_avail_amt1.
        wrk.dbt_left_amt2 = wrk.pay_amt2 - wrk.acc_avail_amt2.
        if wrk.dbt_left_amt1 < 0 then wrk.dbt_left_amt1 = 0.
        if wrk.dbt_left_amt2 < 0 then wrk.dbt_left_amt2 = 0.

        /* если выходит из просрочки - обнуляем кол-во дней просрочки */
        if wrk.acc_avail_amt1 >= wrk.pay_amt1 then v-maxpr = 0. /* !!!!!!!!!!!!!!!!!!!! */

        /* рассчитаем прогнозный ОД и %% */
        if v-aaabal > 0 then do:
            if v-prpog = '01' then do: /* 7-9-4-com-1-2-16-5 */
                /* просрочка ОД */
                if v-aaabal > 0 and v-bal7 > 0 then do:
                    if v-aaabal > v-bal7 then do:
                        v-aaabal = v-aaabal - v-bal7.
                        v-bilance_pro = v-bilance_pro - v-bal7.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* просроч. %% */
                if v-aaabal > 0 and v-bal9 > 0 then do:
                    if v-aaabal > v-bal9 then do:
                        v-aaabal = v-aaabal - v-bal9.
                        v-bal9_pro = v-bal9_pro - v-bal9.
                    end.
                    else do:
                        v-bal9_pro = v-bal9_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* внебал. %%, комиссия */
                if v-aaabal > 0 and v-bal4 + paycom > 0 then do:
                    v-aaabal = v-aaabal - (v-bal4 + paycom).
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                /* ОД по графику */
                if v-aaabal > 0 and nach_od > 0 then do:
                    if v-aaabal > nach_od then do:
                        v-aaabal = v-aaabal - nach_od.
                        v-bilance_pro = v-bilance_pro - nach_od.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* %% по графику */
                if v-aaabal > 0 and nach_prc > 0 then do:
                    if v-aaabal > nach_prc then do:
                        v-aaabal = v-aaabal - nach_prc.
                        v-bal2_pro = v-bal2_pro - nach_prc.
                    end.
                    else do:
                        v-bal2_pro = v-bal2_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* штрафы */
                if v-bal16 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        if v-aaabal > v-bal16 then do:
                            v-aaabal = v-aaabal - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabal.
                            v-aaabal = 0.
                        end.
                    end.
                    else do:
                        if v-aaabalkzt > v-bal16 then do:
                            v-aaabalkzt = v-aaabalkzt - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabalkzt.
                            v-aaabalkzt = 0.
                        end.
                    end.
                end.
                /* внебал. штрафы не смотрим - для прогноза ОД, %% и пени уже не надо */
            end.
            else
            if v-prpog = '02' then do: /* 16-9-7-2-1-com-4-5 */
                /* штрафы */
                if v-bal16 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        if v-aaabal > v-bal16 then do:
                            v-aaabal = v-aaabal - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabal.
                            v-aaabal = 0.
                        end.
                    end.
                    else do:
                        if v-aaabalkzt > v-bal16 then do:
                            v-aaabalkzt = v-aaabalkzt - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabalkzt.
                            v-aaabalkzt = 0.
                        end.
                    end.
                end.
                /* просроч. %% */
                if v-aaabal > 0 and v-bal9 > 0 then do:
                    if v-aaabal > v-bal9 then do:
                        v-aaabal = v-aaabal - v-bal9.
                        v-bal9_pro = v-bal9_pro - v-bal9.
                    end.
                    else do:
                        v-bal9_pro = v-bal9_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* просрочка ОД */
                if v-aaabal > 0 and v-bal7 > 0 then do:
                    if v-aaabal > v-bal7 then do:
                        v-aaabal = v-aaabal - v-bal7.
                        v-bilance_pro = v-bilance_pro - v-bal7.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* %% по графику */
                if v-aaabal > 0 and nach_prc > 0 then do:
                    if v-aaabal > nach_prc then do:
                        v-aaabal = v-aaabal - nach_prc.
                        v-bal2_pro = v-bal2_pro - nach_prc.
                    end.
                    else do:
                        v-bal2_pro = v-bal2_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* ОД по графику */
                if v-aaabal > 0 and nach_od > 0 then do:
                    if v-aaabal > nach_od then do:
                        v-aaabal = v-aaabal - nach_od.
                        v-bilance_pro = v-bilance_pro - nach_od.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* внебал. %%, комиссия */
                if v-aaabal > 0 and v-bal4 + paycom > 0 then do:
                    v-aaabal = v-aaabal - (v-bal4 + paycom).
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                /* внебалансовые штрафы */
                if v-bal5 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        v-aaabal = v-aaabal - v-bal5.
                        if v-aaabal < 0 then v-aaabal = 0.
                    end.
                    else do:
                        v-aaabalkzt = v-aaabalkzt - v-bal5.
                        if v-aaabalkzt < 0 then v-aaabalkzt = 0.
                    end.
                end.
            end.
            else
            if v-prpog = '03' then do: /* 9-4-7-com-2-1-16-5 */
                /* просроч. %% */
                if v-aaabal > 0 and v-bal9 > 0 then do:
                    if v-aaabal > v-bal9 then do:
                        v-aaabal = v-aaabal - v-bal9.
                        v-bal9_pro = v-bal9_pro - v-bal9.
                    end.
                    else do:
                        v-bal9_pro = v-bal9_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* внебал. %% */
                if v-aaabal > 0 and v-bal4 > 0 then do:
                    v-aaabal = v-aaabal - v-bal4.
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                /* просрочка ОД */
                if v-aaabal > 0 and v-bal7 > 0 then do:
                    if v-aaabal > v-bal7 then do:
                        v-aaabal = v-aaabal - v-bal7.
                        v-bilance_pro = v-bilance_pro - v-bal7.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* комиссия */
                if v-aaabal > 0 and paycom > 0 then do:
                    v-aaabal = v-aaabal - paycom.
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                /* %% по графику */
                if v-aaabal > 0 and nach_prc > 0 then do:
                    if v-aaabal > nach_prc then do:
                        v-aaabal = v-aaabal - nach_prc.
                        v-bal2_pro = v-bal2_pro - nach_prc.
                    end.
                    else do:
                        v-bal2_pro = v-bal2_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* ОД по графику */
                if v-aaabal > 0 and nach_od > 0 then do:
                    if v-aaabal > nach_od then do:
                        v-aaabal = v-aaabal - nach_od.
                        v-bilance_pro = v-bilance_pro - nach_od.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* штрафы */
                if v-bal16 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        if v-aaabal > v-bal16 then do:
                            v-aaabal = v-aaabal - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabal.
                            v-aaabal = 0.
                        end.
                    end.
                    else do:
                        if v-aaabalkzt > v-bal16 then do:
                            v-aaabalkzt = v-aaabalkzt - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabalkzt.
                            v-aaabalkzt = 0.
                        end.
                    end.
                end.
                /* внебалансовые штрафы */
                if v-bal5 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        v-aaabal = v-aaabal - v-bal5.
                        if v-aaabal < 0 then v-aaabal = 0.
                    end.
                    else do:
                        v-aaabalkzt = v-aaabalkzt - v-bal5.
                        if v-aaabalkzt < 0 then v-aaabalkzt = 0.
                    end.
                end.
            end.
            else do: /* v-prpog = 'msc' - 16-5-9-4-com-7-2-1 */
                /* штрафы */
                if v-bal16 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        if v-aaabal > v-bal16 then do:
                            v-aaabal = v-aaabal - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabal.
                            v-aaabal = 0.
                        end.
                    end.
                    else do:
                        if v-aaabalkzt > v-bal16 then do:
                            v-aaabalkzt = v-aaabalkzt - v-bal16.
                            v-bal16_pro = 0.
                        end.
                        else do:
                            v-bal16_pro = v-bal16 - v-aaabalkzt.
                            v-aaabalkzt = 0.
                        end.
                    end.
                end.
                /* внебалансовые штрафы */
                if v-bal16 + v-bal5 > 0 then do:
                    if txb.lon.crc = 1 then do:
                        v-aaabal = v-aaabal - v-bal5.
                        if v-aaabal < 0 then v-aaabal = 0.
                    end.
                    else do:
                        v-aaabalkzt = v-aaabalkzt - v-bal5.
                        if v-aaabalkzt < 0 then v-aaabalkzt = 0.
                    end.
                end.
                /* просроч. %% */
                if v-aaabal > 0 and v-bal9 > 0 then do:
                    if v-aaabal > v-bal9 then do:
                        v-aaabal = v-aaabal - v-bal9.
                        v-bal9_pro = v-bal9_pro - v-bal9.
                    end.
                    else do:
                        v-bal9_pro = v-bal9_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* внебал. %%, комиссия */
                if v-aaabal > 0 and v-bal4 + paycom > 0 then do:
                    v-aaabal = v-aaabal - (v-bal4 + paycom).
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                /* просрочка ОД */
                if v-aaabal > 0 and v-bal7 > 0 then do:
                    if v-aaabal > v-bal7 then do:
                        v-aaabal = v-aaabal - v-bal7.
                        v-bilance_pro = v-bilance_pro - v-bal7.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* %% по графику */
                if v-aaabal > 0 and nach_prc > 0 then do:
                    if v-aaabal > nach_prc then do:
                        v-aaabal = v-aaabal - nach_prc.
                        v-bal2_pro = v-bal2_pro - nach_prc.
                    end.
                    else do:
                        v-bal2_pro = v-bal2_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                /* ОД по графику */
                if v-aaabal > 0 and nach_od > 0 then do:
                    if v-aaabal > nach_od then do:
                        v-aaabal = v-aaabal - nach_od.
                        v-bilance_pro = v-bilance_pro - nach_od.
                    end.
                    else do:
                        v-bilance_pro = v-bilance_pro - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
            end.
        end. /* if v-aaabal > 0 */
    end. /* if (v-aaabal > 0) or (v-aaabalkzt > 0) */
    wrk.od_pro = v-bilance_pro.
    wrk.prc2_pro = v-bal2_pro.
    wrk.prc9_pro = v-bal9_pro.
    wrk.pen_pro = v-bal16_pro.

    find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.flp > 0 no-lock no-error.
    if avail txb.lnsci then v-pprc = g-today - txb.lnsci.idat.
    else v-pprc = g-today - txb.lon.rdt.

    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'prosr' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'prosr'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    if v-maxpr <= 14 then t-kdlonkl.val1 = '01'.
    if v-maxpr > 14 and v-maxpr <= 30 then t-kdlonkl.val1 = '02'.
    if v-maxpr >= 31 and v-maxpr <= 60 then t-kdlonkl.val1 = '03'.
    if v-maxpr >= 61 and v-maxpr <= 90 then t-kdlonkl.val1 = '04'.
    if v-maxpr >= 91 then t-kdlonkl.val1 = '05'.

    find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    if t-kdlonkl.val1 = '01' then do:
        /* если просрочек нет, но кредит реструктурированный - рейтинг по просрочке 0 */
        /*
        find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkrst' use-index dcod no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
            t-kdlonkl.rating = 0.
            wrk.restr = txb.sub-cod.ccod.
        end.
        else wrk.restr = "msc".
        */
        /* если просрочек нет, но кредит раньше был в просрочке более 14 дней - рейтинг по просрочке 0 */
        if v-maxpr_old > 14 then t-kdlonkl.rating = 0.
    end.
    find current t-kdlonkl no-lock.

    /* 4. количество пролонгаций */
    /*
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'long' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'long'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.

    t-kdlonkl.val1 = '0'.
    find first bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
    if avail bookcod then assign t-kdlonkl.valdesc = bookcod.name
                                 t-kdlonkl.rating = decimal(t-kdlonkl.val1) * deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.
    */
    /* 1. финансовое состояние */
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'finsost1' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'finsost1'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    if v-pprc <= 30 then do:
        if txb.lon.crc = 1 then t-kdlonkl.val1 = '01'. /* стабильное */
        else t-kdlonkl.val1 = '02'. /* по валютным кредитам фин. состояние понижаем на 1 пункт */
    end.
    else
    if v-pprc >= 31 and v-pprc <= 90 then t-kdlonkl.val1 = '02'. /* удовл. фин. сост. */
    else
    if v-pprc >= 90 and v-pprc <= 180 then t-kdlonkl.val1 = '03'. /* неуд. фин. сост. */
    else t-kdlonkl.val1 = '05'. /* крит. фин. сост. */

    find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.

    /* 3. качество обеспечения */
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'obesp1' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'obesp1'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.val1 = '05'. /* без обеспечения */
    find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.
    /* 5. Наличие других просроченных обязательств */
    /*
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'prosr_ob1' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'prosr_ob1'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.val1 = '01'. -- нет --
    find bookcod where bookcod.bookcod = 'kdlong1' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.
    */
    /* 6. Доля нецелевого использования активов */
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'ispakt' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'ispakt'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.val1 = '01'. /* до 25 % */
    find bookcod where bookcod.bookcod = 'kdispakt' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.
    /* 7. Наличие списанной задолженности */
    /*
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'spisob1' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'spisob1'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.val1 = '01'. -- отсутствует --
    find bookcod where bookcod.bookcod = 'kdkred' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.
    */
    /* 8. Наличие рейтинга у заемщика */
    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'rait1' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'rait1'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.val1 = '04'. /* Ниже рейтинга РК и без рейтинга */
    find bookcod where bookcod.bookcod = 'kdrait' and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then
        assign t-kdlonkl.valdesc = bookcod.name
               t-kdlonkl.rating = deci(trim(bookcod.info[1])).
    find current t-kdlonkl no-lock.




    v-rat = 0.

    for each t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today no-lock:
        if lookup(t-kdlonkl.kod,kod_list) = 0 then next.
        v-rat = v-rat + t-kdlonkl.rating.
        if t-kdlonkl.kod = 'prosr' then v-prosr = t-kdlonkl.val1.
    end.

    find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = g-today and t-kdlonkl.kod = 'klass' exclusive-lock no-error.
    if not avail t-kdlonkl then do:
        create t-kdlonkl.
        assign t-kdlonkl.bank = s-ourbank
               t-kdlonkl.kdcif = txb.lon.cif
               t-kdlonkl.kdlon = txb.lon.lon
               t-kdlonkl.rdt = g-today
               t-kdlonkl.kod = 'klass'
               t-kdlonkl.who = g-ofc
               t-kdlonkl.whn = g-today.
    end.
    t-kdlonkl.rating = v-rat.

    if v-rat <= 1 then t-kdlonkl.val1 = '01'.
    else
    if v-rat > 1 and v-rat <= 2 and v-prosr = '01' then t-kdlonkl.val1 = '02'.
    else
    if v-rat > 1 and v-rat <= 2 and v-prosr <> '01' then t-kdlonkl.val1 = '03'.
    else
    if v-rat > 2 and v-rat <= 3 and v-prosr = '01' then t-kdlonkl.val1 = '04'.
    else
    if v-rat > 2 and v-rat <= 3 and v-prosr <> '01' then t-kdlonkl.val1 = '05'.
    else
    if v-rat > 3 and v-rat <= 4 then t-kdlonkl.val1 = '06'.
    else
    if v-rat > 4 then t-kdlonkl.val1 = '07'.

    /* c 01/01/2010 - кредиты в ин. валюте и без просрочки, выданные с 1 сент 2009 классифицируем не выше "сомн. 1 категории" */
    /* c 01/07/2010 - кредиты в ин. валюте и без просрочки, выданные с 1 сент 2009 классифицируем не выше "сомн. 2 категории"*/
    if txb.lon.crc <> 1 and txb.lon.rdt >= 09/01/2009 then do:
        if v-rat <= 2 then t-kdlonkl.val1 = '03'.
    end.
    /* при фактической просрочке более 180 дней - провизии 100% */
    /*
    if v-fmaxpr > 180 then do:
        t-kdlonkl.val1 = '07'.
    end.
    */

    find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = t-kdlonkl.val1 no-lock no-error.
    if avail bookcod then t-kdlonkl.valdesc = bookcod.name.
    find current t-kdlonkl no-lock.

    wrk.dtcl = ?.
    find last t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon use-index bclrdt no-lock no-error.
    if avail t-kdlonkl then wrk.dtcl = t-kdlonkl.rdt.

    if wrk.dtcl <> ? then do:
        for each t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = wrk.dtcl no-lock:
            i = lookup(t-kdlonkl.kod,kod_list).
            if i = 0 then next.
            assign wrk.sts[i] = t-kdlonkl.val1
                   wrk.sts_des[i] = t-kdlonkl.valdesc
                   wrk.rating[i] = t-kdlonkl.rating.
        end.
        find first t-kdlonkl where t-kdlonkl.bank = s-ourbank and t-kdlonkl.kdcif = txb.lon.cif and t-kdlonkl.kdlon = txb.lon.lon and t-kdlonkl.rdt = wrk.dtcl and t-kdlonkl.kod = 'klass' no-lock no-error.
        if avail t-kdlonkl then do:
            assign wrk.rating_s = t-kdlonkl.rating
                   wrk.class = t-kdlonkl.val1.

            if v-bilance_pro * s-rates[txb.lon.crc] <= v-sumodn then do:
                wrk.port = "1. Однородные Метрокредит".
                wrk.class_odn = v-class[1].
                wrk.class_prc = v-resprcodn[1].
                wrk.progprov_od = round(v-bilance_pro * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
                wrk.progprov_prc = round((v-bal2_pro + v-bal9_pro) * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
                wrk.progprov_pen = round(v-bal16_pro * wrk.class_prc / 100,2).
                wrk.progprov = wrk.progprov_od + wrk.progprov_prc + wrk.progprov_pen.
            end.
            else do:
                find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = t-kdlonkl.val1 no-lock no-error.
                if avail bookcod then do:
                    wrk.class_prc = deci(bookcod.info[1]).
                    wrk.progprov_od = round(v-bilance_pro * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
                    wrk.progprov_prc = round((v-bal2_pro + v-bal9_pro) * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
                    wrk.progprov_pen = round(v-bal16_pro * wrk.class_prc / 100,2).
                    wrk.progprov = wrk.progprov_od + wrk.progprov_prc + wrk.progprov_pen.
                end.
            end.
        end.
        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < g-today no-lock no-error.
        if avail txb.lonhar then wrk.class_old = string(txb.lonhar.lonstat,"99").
        wrk.days = v-maxpr.
        wrk.days_old = v-maxpr_old.
        wrk.dayspprc = v-pprc.
    end.

end. /* for each txb.lon */

def var v-acc_avail_amt1 as deci no-undo.
def var v-acc_avail_amt2 as deci no-undo.
def var v-pay_amt1 as deci no-undo.
def var v-pay_amt2 as deci no-undo.
def var v-acc_left_amt1 as deci no-undo.
def var v-acc_left_amt2 as deci no-undo.
def var v-dbt_left_amt1 as deci no-undo.
def var v-dbt_left_amt2 as deci no-undo.

for each txb.lon where txb.lon.grp = 81 or txb.lon.grp = 82 no-lock:
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1",yes,txb.lon.crc,output v-bal1).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"7",yes,txb.lon.crc,output v-bal7).
    v-bilance = v-bal1 + v-bal7.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-bal2).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"9",yes,txb.lon.crc,output v-bal9).
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"16",yes,1,output v-bal16).

    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"6",yes,txb.lon.crc,output v-prov).
    v-prov = - v-prov.

    if (v-bilance <= 0) and (v-bal2 <= 0) and (v-bal9 <= 0) and (v-prov <= 0) and (v-bal16 <= 0) then next.

    v-acc_avail_amt1 = 0.
    v-acc_avail_amt2 = 0.
    v-pay_amt1 = 0.
    v-pay_amt2 = 0.
    v-acc_left_amt1 = 0.
    v-acc_left_amt2 = 0.
    v-dbt_left_amt1 = 0.
    v-dbt_left_amt2 = 0.

    v-aaakzt = ''.
    if txb.lon.crc <> 1 then do:
        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if avail pkanketa then v-aaakzt = pkanketa.aaa.
    end.

    v-maxpr = 0.
    run lndayspry_txb(txb.lon.lon,g-today,yes,output v-days_od,output v-days_prc,output v-maxpr_old).
    if v-days_od > 0 then v-days_od = v-days_od + add_pr.
    if v-days_prc > 0 then v-days_prc = v-days_prc + add_pr.
    if v-maxpr_old < v-days_od then v-maxpr_old = v-days_od.
    if v-maxpr_old < v-days_prc then v-maxpr_old = v-days_prc.
    if v-days_od > v-days_prc then v-maxpr = v-days_od. else v-maxpr = v-days_prc.

    v-aaabal = 0.
    for each txb.lgr where txb.lgr.led = "DDA" or txb.lgr.led = "SAV" no-lock, each txb.aaa of txb.lgr where txb.aaa.cif = txb.lon.cif and txb.aaa.sta <> "C" and txb.aaa.crc = txb.lon.crc no-lock:
        v-aaabal = v-aaabal + (txb.aaa.cbal - txb.aaa.hbal).
        if v-aaabal < 0 then v-aaabal = 0.
    end.

    v-aaabalkzt = 0.
    if txb.lon.crc <> 1 then do:
        for each txb.lgr where txb.lgr.led = "DDA" or txb.lgr.led = "SAV" no-lock, each txb.aaa of txb.lgr where txb.aaa.cif = txb.lon.cif and txb.aaa.sta <> "C" and txb.aaa.crc = 1 no-lock:
            v-aaabalkzt = v-aaabalkzt + (txb.aaa.cbal - txb.aaa.hbal).
            if v-aaabalkzt < 0 then v-aaabalkzt = 0.
        end.
    end.

    v-acc_avail_amt1 = v-aaabal.
    v-acc_avail_amt2 = v-aaabalkzt.

    v-bilance_pro = v-bilance.
    v-bal2_pro = v-bal2.
    v-bal9_pro = v-bal9.
    v-bal16_pro = v-bal16.


    if (v-aaabal > 0) or (v-aaabalkzt > 0) then do:
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"4",yes,txb.lon.crc,output v-bal4).
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"5",yes,1,output v-bal5).

        nach_od = 0. nach_prc = 0.
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today no-lock no-error.
        if avail txb.lnsch then do:
            nach_od = txb.lnsch.stval.
            if nach_od > v-bal1 then nach_od = v-bal1.
        end.
        find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat > dat_wrk and txb.lnsci.idat <= g-today no-lock no-error.
        if avail txb.lnsci then do:
            nach_prc = txb.lnsci.iv-sc.
            if nach_prc > v-bal2 then nach_prc = v-bal2.
        end.

        paycom = 0.
        for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.aaa = txb.lon.aaa and txb.bxcif.type = '195' no-lock:
            paycom = paycom + txb.bxcif.amount.
        end.
        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.stdat > dat_wrk and txb.lnsch.stdat <= g-today and txb.lnsch.f0 > 0 no-lock no-error.
        if avail txb.lnsch then do:
            find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
            if avail txb.tarifex2 then paycom = paycom + txb.tarifex2.ost.
        end.

        if txb.lon.crc = 1 then v-pay_amt1 = v-bal16 + v-bal5 + v-bal9 + v-bal4 + paycom + v-bal7 + nach_od + nach_prc.
        else do:
            v-pay_amt1 = v-bal9 + v-bal4 + paycom + v-bal7 + nach_od + nach_prc.
            v-pay_amt2 = v-bal16 + v-bal5.
        end.

        v-acc_left_amt1 = v-acc_avail_amt1 - v-pay_amt1.
        v-acc_left_amt2 = v-acc_avail_amt2 - v-pay_amt2.
        if v-acc_left_amt1 < 0 then v-acc_left_amt1 = 0.
        if v-acc_left_amt2 < 0 then v-acc_left_amt2 = 0.

        v-dbt_left_amt1 = v-pay_amt1 - v-acc_avail_amt1.
        v-dbt_left_amt2 = v-pay_amt2 - v-acc_avail_amt2.
        if v-dbt_left_amt1 < 0 then v-dbt_left_amt1 = 0.
        if v-dbt_left_amt2 < 0 then v-dbt_left_amt2 = 0.

        /* если выходит из просрочки - обнуляем кол-во дней просрочки */
        if v-acc_avail_amt1 >= v-pay_amt1 then v-maxpr = 0. /* !!!!!!!!!!!!!!!!!!!! */

        /* рассчитаем прогнозный ОД и %% */
        if v-aaabal > 0 then do:
            /* штрафы */
            if v-bal16 > 0 then do:
                if txb.lon.crc = 1 then do:
                    if v-aaabal > v-bal16 then do:
                        v-aaabal = v-aaabal - v-bal16.
                        v-bal16_pro = 0.
                    end.
                    else do:
                        v-bal16_pro = v-bal16 - v-aaabal.
                        v-aaabal = 0.
                    end.
                end.
                else do:
                    if v-aaabalkzt > v-bal16 then do:
                        v-aaabalkzt = v-aaabalkzt - v-bal16.
                        v-bal16_pro = 0.
                    end.
                    else do:
                        v-bal16_pro = v-bal16 - v-aaabalkzt.
                        v-aaabalkzt = 0.
                    end.
                end.
            end.
            /* внебалансовые штрафы */
            if v-bal16 + v-bal5 > 0 then do:
                if txb.lon.crc = 1 then do:
                    v-aaabal = v-aaabal - v-bal5.
                    if v-aaabal < 0 then v-aaabal = 0.
                end.
                else do:
                    v-aaabalkzt = v-aaabalkzt - v-bal5.
                    if v-aaabalkzt < 0 then v-aaabalkzt = 0.
                end.
            end.
            /* просроч. %% */
            if v-aaabal > 0 and v-bal9 > 0 then do:
                if v-aaabal > v-bal9 then do:
                    v-aaabal = v-aaabal - v-bal9.
                    v-bal9_pro = v-bal9_pro - v-bal9.
                end.
                else do:
                    v-bal9_pro = v-bal9_pro - v-aaabal.
                    v-aaabal = 0.
                end.
            end.
            /* внебал. %%, комиссия */
            if v-aaabal > 0 and v-bal4 + paycom > 0 then do:
                v-aaabal = v-aaabal - (v-bal4 + paycom).
                if v-aaabal < 0 then v-aaabal = 0.
            end.
            /* просрочка ОД */
            if v-aaabal > 0 and v-bal7 > 0 then do:
                if v-aaabal > v-bal7 then do:
                    v-aaabal = v-aaabal - v-bal7.
                    v-bilance_pro = v-bilance_pro - v-bal7.
                end.
                else do:
                    v-bilance_pro = v-bilance_pro - v-aaabal.
                    v-aaabal = 0.
                end.
            end.
            /* %% по графику */
            if v-aaabal > 0 and nach_prc > 0 then do:
                if v-aaabal > nach_prc then do:
                    v-aaabal = v-aaabal - nach_prc.
                    v-bal2_pro = v-bal2_pro - nach_prc.
                end.
                else do:
                    v-bal2_pro = v-bal2_pro - v-aaabal.
                    v-aaabal = 0.
                end.
            end.
            /* ОД по графику */
            if v-aaabal > 0 and nach_od > 0 then do:
                if v-aaabal > nach_od then do:
                    v-aaabal = v-aaabal - nach_od.
                    v-bilance_pro = v-bilance_pro - nach_od.
                end.
                else do:
                    v-bilance_pro = v-bilance_pro - v-aaabal.
                    v-aaabal = 0.
                end.
            end.
        end. /* if v-aaabal > 0 */
    end. /* if (v-aaabal > 0) or (v-aaabalkzt > 0) */


    if v-bilance_pro * s-rates[txb.lon.crc] <= v-sumodn then do:
        create wrk.
        assign wrk.bank = s-ourbank
               wrk.cif = txb.lon.cif
               wrk.lon = txb.lon.lon
               wrk.crc = txb.lon.crc
               wrk.od = v-bilance
               wrk.prc2 = v-bal2
               wrk.prc9 = v-bal9
               wrk.prov = v-prov
               wrk.acc_avail_amt1 = v-acc_avail_amt1
               wrk.acc_avail_amt2 = v-acc_avail_amt2
               wrk.pay_amt1 = v-pay_amt1
               wrk.pay_amt2 = v-pay_amt2
               wrk.acc_left_amt1 = v-acc_left_amt1
               wrk.acc_left_amt2 = v-acc_left_amt2
               wrk.dbt_left_amt1 = v-dbt_left_amt1
               wrk.dbt_left_amt2 = v-dbt_left_amt2
               wrk.od_pro = v-bilance_pro
               wrk.prc2_pro = v-bal2_pro
               wrk.prc9_pro = v-bal9_pro
               wrk.pen_pro = v-bal16_pro.

        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then wrk.fio = trim(txb.cif.name).

        wrk.port = "3. Однородные Сотрудники".
        wrk.class_odn = v-class[2].
        wrk.class_prc = v-resprcodn[2].
        wrk.progprov_od = round(v-bilance_pro * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
        wrk.progprov_prc = round((v-bal2_pro + v-bal9_pro) * wrk.class_prc / 100,2) * s-rates[txb.lon.crc].
        wrk.progprov_pen = round(v-bal16_pro * wrk.class_prc / 100,2).
        wrk.progprov = wrk.progprov_od + wrk.progprov_prc + wrk.progprov_pen.

        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < g-today no-lock no-error.
        if avail txb.lonhar then wrk.class_old = string(txb.lonhar.lonstat,"99").
    end.

end.
