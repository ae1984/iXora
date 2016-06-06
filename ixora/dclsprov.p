/* dclsprov.p
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
	    Начисление, списание провизий
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
        30/03/2005 madiyar
 * CHANGES
        05/04/2005 madiyar - исправил расчет провизий по кредитам в валюте
        03.07.2006 u00121 - Убрал message c паузой, по всей видимости отладочный, срабатывает раз в месяц, для закрывающих день ни какой информативности в этом сообщении нет
        31.07.06 marinav - если есть такой признак, то создавать провизии не надо
        29/02/2008 madiyar - переделал списание провизий (начисленные в текущем году, в прошлые года)
        30/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
        02/01/2011 madiyar - по экспресс-кредитам провизии начисляем и на начисл. и просроч. проценты
        31/01/2011 madiyar - по всем кредитам начисляем на ОД, проценты и штрафы; списание делаем по одной схеме
        28/02/2011 madiyar - однородные кредиты
        31/03/2011 madiyar - изменил проводки
        03/07/2011 madiyar - проставление признака однородности
        29/07/2011 madiyar - переход на провизии по МСФО
        30/07/2011 madiyar - добавил валюту в отчет
        01/10/2011 madiyar - сделал ветку для баз МКО, со старым исходником
        30/12/2011 madiyar - с 5% СК сравниваем не остаток по одному кредиту, а сумму всех действующих займов клиента
        31/01/2012 madiyar - записываем в историю привязку займов к пулам
        29/02/2012 madiyar - однородные МСБ по АФН
        24/04/2012 madiyar - текущий курс - из crcpro
        31/07/2012 dmitriy - для займов "ИП Клишин" (Петропавловск) провизии АФН считаются как для пула МСБ
        28/08/2012 kapar - ТЗ N1149 Новые группы
        01/10/2012 dmitriy - Для займа 052151151 ("ИП Клишин"):  статус - стандартный, % = 0
        31.10.2012 dmitriy - Отмена изменений по расчету провизий для займов "ИП Клишин" (ТЗ 1568)
        31/01/2013 sayat(id01143) - ТЗ № 1691 отключение провизий АФН (кроме внебаланса)
        01/03/2013 sayat(id01143) - перекомпиляция из-за устранения замечания по ТЗ № 1691 (не все проводки по 3-му классу отключились)
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
        26/08/2013 Sayat(id01143) - ТЗ 1850 от 17/05/2013 "Изменения в расчет однородных кредитов по АФН"
        29/08/2013 Sayat(id01143) - ТЗ 2067 от 29/08/2013 отключены проводки по провизиям АФН
*/

{global.i}

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " dclsprov - Не найдена запись cmp " view-as alert-box error.
    return.
end.

if bank.cmp.name matches "*МКО*" then do:
    run dclsprov_mko.
    return.
end.

def var s-ourbank as char no-undo.
find first bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
if not avail bank.sysc or bank.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(bank.sysc.chval).

def shared var s-target as date.

/* объявления переменных */
    def var s-jh1 like jh.jh.
    def var s-jh2 like jh.jh.
    def var s-jh3 like jh.jh.
    def var s-jh4 like jh.jh.
    def var vparam as char no-undo.
    def var rcode as int no-undo.
    def var rdes as char no-undo.
    def var vdel as char no-undo initial "^".
    def var v-londog as char no-undo.

    def var bilance as deci no-undo.
    def var prc as deci no-undo.
    def var pen as deci no-undo.

    def var v-afn1 as deci no-undo.
    def var v-afn2 as deci no-undo.
    def var v-msfo1 as deci no-undo extent 3.
    def var v-msfo2 as deci no-undo extent 3.
    def var v-corr1 as deci no-undo extent 3.
    def var v-corr2 as deci no-undo extent 3.

    def var v-coeffr_msfo as deci no-undo.
    def var v-coeffr_afn as deci no-undo.

    def var v-prov1 as deci no-undo.
    def var v-prov2 as deci no-undo extent 3.
    def var v-prov3 as deci no-undo extent 3.

    def var v-bal as deci no-undo.
    def var v-bal_all as deci no-undo.
    def var v-sum as deci no-undo.

    def var v-rem as char no-undo.
    def var v-tmpl as char no-undo.
    def var v-gl as integer no-undo.

    def var v-pool as char no-undo extent 10.
    def var v-poolName as char no-undo extent 10.
    def var v-poolId as char no-undo extent 10.
    def var poolIndex as integer no-undo.
    def var j as integer no-undo.
    def var v-grp as integer no-undo.
    def var v-clmain as char.

    def buffer b-lon for lon.
    def buffer c-lon for lon.
    def var v-bal1 as deci.
    def var v-indprov as deci.
    def var v-dayc_od   as int.
    def var v-dayc_prc  as int.
    def var v-daycmax   as int.
    def var v-restr     as int.
    def var v-ind       as int.

    v-pool[1] = "27,67".
    v-poolName[1] = "Ипотечные займы".
    v-poolId[1] = "ipoteka".
    v-pool[2] = "28,68".
    v-poolName[2] = "Автокредиты".
    v-poolId[2] = "auto".
    v-pool[3] = "20,60".
    v-poolName[3] = "Потребительские кредиты Обеспеченные".
    v-poolId[3] = "flobesp".
    v-pool[4] = "90,92".
    v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
    v-poolId[4] = "metro".
    v-pool[5] = "81,82".
    v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
    v-poolId[5] = "sotr".
    v-pool[6] = "16,26,56,66".
    v-poolName[6] = "Метро-экспресс МСБ".
    v-poolId[6] = "express-msb".
    v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
    v-poolName[7] = "Кредиты МСБ".
    v-poolId[7] = "msb".
    v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
    v-poolName[8] = "Инидивид. МСБ".
    v-poolId[8] = "individ-msb".
    v-pool[9] = "11,21,70,80".
    v-poolName[9] = "факторинг, овердрафты".
    v-poolId[9] = "factover".
    v-pool[10] = "95,96".
    v-poolName[10] = "Ипотека «Астана бонус»".
    v-poolId[10] = "astana-bonus".

    def var v-dt as date no-undo. /* 1-ое число следующего месяца */
    def var nm as integer no-undo.
    def var ny as integer no-undo.
    nm = month(g-today) + 1.
    ny = year(g-today).
    if nm = 13 then assign nm = 1 ny = ny + 1.
    v-dt = date(nm,1,ny).
/* объявления переменных - end */

/* rates */
    def var rate as deci no-undo extent 20.
    def var rate_his as deci no-undo extent 20.
    for each crc no-lock:
        if crc.crc >= 1 and crc.crc <= 20 then do:
            find last crcpro where crcpro.crc = crc.crc and crcpro.regdt <= s-target no-lock no-error.
            if avail crcpro then rate[crc.crc] = crcpro.rate[1].
            find last crchis where crchis.crc = crc.crc and crchis.rdt < date(month(g-today),1,year(g-today)) no-lock no-error.
            if avail crchis then rate_his[crc.crc] = crchis.rate[1].
        end.
    end.
/* rates - end */

def stream rep.
output stream rep to value("lonprov" + string(year(g-today)) + string(month(g-today),"99") + s-ourbank + ".txt").

/* МСФО - справочники */
    def var v-sum_msb as deci no-undo.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnmsfo" no-lock no-error.
    if avail pksysc then do:
        v-sum_msb = pksysc.deval.
        put stream rep unformatted "v-sum_msb=" + trim(string(v-sum_msb,">>>,>>>,>>>,>>9.99")) skip.
    end.
    else do:
        put stream rep unformatted "Не определена сумма 5% от СК" skip.
        message "Не определена сумма 5% от СК для провизий МСФО" view-as alert-box.
    end.
/* МСФО - справочники - end */

/* однородные - справочники */
    def var v-sumodn as deci no-undo.
    def var v-class as integer no-undo extent 6.
    def var v-resprcodn as deci no-undo extent 6.
    def var i as integer no-undo.

    v-resprcodn[1] = -1.
    v-resprcodn[2] = -1.
    v-resprcodn[3] = -1.
    v-resprcodn[4] = -1.
    v-resprcodn[5] = -1.
    v-resprcodn[6] = -1.

    find first sysc where sysc.sysc = "lnodnorf" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,'|') = 6 then do:
        v-resprcodn[1] = deci(entry(1,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю однородных кредитов Метрокредит!" skip.
            message "(1) Некорректная ставка по портфелю однородных кредитов Метрокредит!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Метрокредит) = " + trim(string(v-resprcodn[1],">>>,>>9.99")) skip.
        v-resprcodn[2] = deci(entry(2,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю однородных кредитов сотрудников!" skip.
            message "(1) Некорректная ставка по портфелю однородных кредитов сотрудников!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Сотрудники) = " + trim(string(v-resprcodn[2],">>>,>>9.99")) skip.
        v-resprcodn[3] = deci(entry(3,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю Ипотечных займов!" skip.
            message "(1) Некорректная ставка по портфелю Ипотечных займов!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Ипотека) = " + trim(string(v-resprcodn[3],">>>,>>9.99")) skip.
        v-resprcodn[4] = deci(entry(4,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю Потребительских обеспеченных займов!" skip.
            message "(1) Некорректная ставка по портфелю Потребительских обеспеченных займов!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Потреб.обесп.) = " + trim(string(v-resprcodn[4],">>>,>>9.99")) skip.
        v-resprcodn[5] = deci(entry(5,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю Факторинг и овердрафт!" skip.
            message "(1) Некорректная ставка по портфелю Факторинг и овердрафт!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Факт.Овер.) = " + trim(string(v-resprcodn[5],">>>,>>9.99")) skip.
        v-resprcodn[6] = deci(entry(6,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю Астана-бонус!" skip.
            message "(1) Некорректная ставка по портфелю Астана-бонус!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (Астана-бонус) = " + trim(string(v-resprcodn[6],">>>,>>9.99")) skip.
        if (v-resprcodn[1] < 0) or (v-resprcodn[1] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю однородных кредитов Метрокредит!" skip.
            message "(2) Некорректная ставка по портфелю однородных кредитов Метрокредит!" view-as alert-box.
        end.
        if (v-resprcodn[2] < 0) or (v-resprcodn[2] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю однородных кредитов сотрудников!" skip.
            message "(2) Некорректная ставка по портфелю однородных кредитов сотрудников!" view-as alert-box.
        end.
        if (v-resprcodn[3] < 0) or (v-resprcodn[3] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю Ипотечных займов!" skip.
            message "(2) Некорректная ставка по портфелю Ипотечных займов!" view-as alert-box.
        end.
        if (v-resprcodn[4] < 0) or (v-resprcodn[4] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю Потребительских обеспеченных займов!" skip.
            message "(2) Некорректная ставка по портфелю Потребительских обеспеченных займов!" view-as alert-box.
        end.
        if (v-resprcodn[5] < 0) or (v-resprcodn[5] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю Факторинг и овердрафт!" skip.
            message "(2) Некорректная ставка по портфелю Факторинг и овердрафт!" view-as alert-box.
        end.
        if (v-resprcodn[6] < 0) or (v-resprcodn[6] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю Астана-бонус!" skip.
            message "(2) Некорректная ставка по портфелю Астана-бонус!" view-as alert-box.
        end.
    end.
    else do:
        put stream rep unformatted "Ставки по портфелям однородных кредитов не проставлены!" skip.
        message "Ставки по портфелям однородных кредитов не проставлены!" view-as alert-box.
    end.

    do i = 1 to 6:
        if v-resprcodn[i] = 0 then v-class[i] = 1. /* стандартный */
        else
        if v-resprcodn[i] <= 5 then v-class[i] = 2. /* сомнительный 1-ой категории */
        else
        if v-resprcodn[i] <= 10 then v-class[i] = 3. /* сомнительный 2-ой категории */
        else
        if v-resprcodn[i] <= 20 then v-class[i] = 4. /* сомнительный 3-ой категории */
        else
        if v-resprcodn[i] <= 25 then v-class[i] = 5. /* сомнительный 4-ой категории */
        else
        if v-resprcodn[i] <= 50 then v-class[i] = 6. /* сомнительный 5-ой категории */
        else v-class[i] = 7. /* безнадежный */
    end.

    v-sumodn = 0.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
    if avail pksysc then v-sumodn = pksysc.deval.
    if avail pksysc then do:
        v-sumodn = pksysc.deval.
        put stream rep unformatted "v-sumodn=" + trim(string(v-sumodn,">>>,>>>,>>>,>>9.99")) skip.
    end.
    else do:
        put stream rep unformatted "Не определена сумма порога по однородным экспрессам и сотрудникам" skip.
        message "Не определена сумма порога по однородным экспрессам и сотрудникам" view-as alert-box.
    end.
/* однородные - справочники - end */

/* однородные МСБ - справочники */
    def var v-sumodn_msb as deci no-undo.
    def var v-class_msb as integer no-undo extent 2.
    def var v-resprcodn_msb as deci no-undo extent 2.

    v-resprcodn_msb[1] = -1.
    v-resprcodn_msb[2] = -1.
    v-sumodn_msb = 0.
    find first sysc where sysc.sysc = "msb%rez" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,'|') = 2 then do:
        v-resprcodn_msb[1] = deci(entry(1,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю однородных МСБ1!" skip.
            message "(1) Некорректная ставка по портфелю однородных МСБ1!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (МСБ1) = " + trim(string(v-resprcodn_msb[1],">>>,>>9.99")) skip.
        v-resprcodn_msb[2] = deci(entry(2,sysc.chval,'|')) no-error.
        if error-status:error then do:
            put stream rep unformatted "(1) Некорректная ставка по портфелю однородных МСБ2!" skip.
            message "(1) Некорректная ставка по портфелю однородных МСБ2!" view-as alert-box.
        end.
        else put stream rep unformatted "resprc (МСБ2) = " + trim(string(v-resprcodn_msb[2],">>>,>>9.99")) skip.
        if (v-resprcodn_msb[1] < 0) or (v-resprcodn_msb[1] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю однородных кредитов МСБ1!" skip.
            message "(2) Некорректная ставка по портфелю однородных кредитов МСБ1!" view-as alert-box.
        end.
        if (v-resprcodn_msb[2] < 0) or (v-resprcodn_msb[2] > 100) then do:
            put stream rep unformatted "(2) Некорректная ставка по портфелю однородных кредитов МСБ2!" skip.
            message "(2) Некорректная ставка по портфелю однородных кредитов МСБ2!" view-as alert-box.
        end.
        v-sumodn_msb = sysc.deval.
        put stream rep unformatted "v-sumodn_msb=" + trim(string(v-sumodn_msb,">>>,>>>,>>>,>>9.99")) skip.
    end.
    else do:
        put stream rep unformatted "Ставки по портфелям однородных кредитов МСБ не проставлены!" skip.
        message "Ставки по портфелям однородных кредитов МСБ не проставлены!" view-as alert-box.
    end.

    do i = 1 to 2:
        if v-resprcodn_msb[i] = 0 then v-class_msb[i] = 1. /* стандартный */
        else
        if v-resprcodn_msb[i] <= 5 then v-class_msb[i] = 2. /* сомнительный 1-ой категории */
        else
        if v-resprcodn_msb[i] <= 10 then v-class_msb[i] = 3. /* сомнительный 2-ой категории */
        else
        if v-resprcodn_msb[i] <= 20 then v-class_msb[i] = 4. /* сомнительный 3-ой категории */
        else
        if v-resprcodn_msb[i] <= 25 then v-class_msb[i] = 5. /* сомнительный 4-ой категории */
        else
        if v-resprcodn_msb[i] <= 50 then v-class_msb[i] = 6. /* сомнительный 5-ой категории */
        else v-class_msb[i] = 7. /* безнадежный */
    end.
/* однородные МСБ - справочники - end */

put stream rep unformatted "cif;lon;crc;afn1;afn2;msfo1_od;msfo1_prc;msfo1_pen;msfo2_od;msfo2_prc;msfo2_pen;prov1;prov2_od;prov2_prc;prov2_pen;prov3_od;prov3_prc;prov3_pen;prov4_od;prov4_prc;trx1;trx2;trx3;trx4;pool;maxday;restr;indiv" skip.

do poolIndex = 1 to 10:

    v-coeffr_msfo = 0.
    /*
    find first msfoc where msfoc.poolId = v-poolId[poolIndex] and msfoc.dt = v-dt no-lock no-error.
    if avail msfoc and msfoc.coeffr <> ? then v-coeffr_msfo = msfoc.coeffr.
    */
    find first ctgprov where ctgprov.poolId = v-poolId[poolIndex] and ctgprov.dt = v-dt and ctgprov.tp = 'prz' no-lock no-error.
    if avail ctgprov and ctgprov.n12 <> ? then v-coeffr_msfo = round(100 * ctgprov.n12,4).

    do j = 1 to num-entries(v-pool[poolIndex]):
        v-grp = integer(entry(j,v-pool[poolIndex])).
        for each lon where lon.grp = v-grp no-lock:

            if lon.opnamt <= 0 then next.

            /* 31.07.06 marinav - если есть такой признак, то создавать провизии не надо */
            find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnprov' and sub-cod.ccode = '1' no-lock no-error.
            if avail sub-cod then next.

            run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output bilance).
            run lonbalcrc('lon',lon.lon,g-today,"2,9,49,50",yes,lon.crc,output prc).
            run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output pen).
            run lonbalcrc('lon',lon.lon,g-today,"6",yes,lon.crc,output v-msfo1[1]).
            v-msfo1[1] = - v-msfo1[1].
            run lonbalcrc('lon',lon.lon,g-today,"36",yes,lon.crc,output v-msfo1[2]).
            v-msfo1[2] = - v-msfo1[2].
            run lonbalcrc('lon',lon.lon,g-today,"37",yes,1,output v-msfo1[3]).
            v-msfo1[3] = - v-msfo1[3].
            run lonbalcrc('lon',lon.lon,g-today,"41",yes,lon.crc,output v-afn1).
            v-afn1 = - v-afn1.

            v-sum = 0.

            if bilance <= 0 and prc <= 0 and pen <= 0 and v-afn1 <= 0 and v-msfo1[1] + v-msfo1[2] + v-msfo1[3] <= 0 then next.

            /* по пулам МСБ проверяем на пороговую сумму */
            if (poolIndex = 7) or (poolIndex = 8) then do:
                v-bal_all = 0. v-clmain = ''.
                /*
                for each b-lon where b-lon.cif = lon.cif no-lock:
                    run lonbalcrc('lon',b-lon.lon,g-today,"1,7",yes,b-lon.crc,output v-bal).
                    if v-bal > 0 then do:
                        if b-lon.crc <> 1 then v-bal = v-bal * rate[lon.crc].
                        v-bal_all = v-bal_all + v-bal.
                    end.
                end.
                */

                for each b-lon where b-lon.cif = lon.cif no-lock:
                    run lonbalcrc('lon',b-lon.lon,g-today,"1,7",yes,b-lon.crc,output v-bal).
                    if v-bal > 0 then do:
                        if b-lon.clmain <> '' then do:
                            if lookup(b-lon.clmain,v-clmain) = 0 then do:
                                v-clmain = v-clmain + string(b-lon.clmain) + ','.
                                find last c-lon where c-lon.lon = b-lon.clmain no-lock no-error.
                                if c-lon.opnamt > 0 then do:
                                    v-bal = c-lon.opnamt.
                                    if c-lon.crc <> 1 then v-bal = v-bal * rate[c-lon.crc].
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                        else do:
                            if b-lon.gua <> 'CL' then do:
                                if b-lon.opnamt > 0 then do:
                                    v-bal = b-lon.opnamt.
                                    if b-lon.crc <> 1 then  v-bal = v-bal * rate[b-lon.crc].
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                    end.
                end.

                if poolIndex = 7 then do:
                    if v-bal_all >= v-sum_msb then next.
                end.
                if poolIndex = 8 then do:
                    if v-bal_all < v-sum_msb then next.
                    /* !!!!!!!!!!!!!!!!!!! ищем в списке исключений, если находим - тоже пропускаем */
                end.
            end.

            do transaction:
                find first lonpool where lonpool.cif = lon.cif and lonpool.lon = lon.lon and lonpool.rdt = s-target exclusive-lock no-error.
                if not avail lonpool then do:
                    create lonpool.
                    assign lonpool.cif = lon.cif
                           lonpool.lon = lon.lon
                           lonpool.rdt = s-target.
                end.
                lonpool.poolId = v-poolId[poolIndex].
                lonpool.who = g-ofc.
                lonpool.whn = g-today.
                find current lonpool no-lock.
            end. /* transaction */

            find first loncon where loncon.lon = lon.lon no-lock no-error.
            if avail loncon then v-londog = loncon.lcnt.
            else v-londog = ''.

            find last lonhar where lonhar.lon = lon.lon use-index lonhar-idx1 no-lock no-error.
            if avail lonhar then do:
                find first lonstat where lonstat.lonstat = lonhar.lonstat no-lock no-error.
                if avail lonstat then do:
                    v-coeffr_afn = lonstat.prc.

                    if (lon.grp = 90) or (lon.grp = 92) then do:
                        if v-resprcodn[1] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'
                                           sub-cod.rdt = g-today.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[1].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[1].
                            end.
                        end.
                    end.
                    else
                    if (lon.grp = 81) or (lon.grp = 82) then do:
                        if v-resprcodn[2] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[2].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[2].
                            end.
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"16,26,56,66") > 0 then do:
                        if v-resprcodn_msb[1] >= 0 then do transaction:
                            find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                            if not avail sub-cod then do:
                                create sub-cod.
                                assign sub-cod.sub = 'lon'
                                       sub-cod.acc = lon.lon
                                       sub-cod.d-cod = 'lnodnor'
                                       sub-cod.ccode = '01'.
                            end.
                            else do:
                                if sub-cod.ccode <> '01' then do:
                                    find current sub-cod exclusive-lock.
                                    sub-cod.ccode = '01'.
                                end.
                            end.
                            find current sub-cod no-lock.
                            find current lonhar exclusive-lock.
                            lonhar.rez-dec[1] = v-coeffr_afn.
                            lonhar.rez-int[1] = lonhar.lonstat.
                            lonhar.lonstat = v-class_msb[1].
                            find current lonhar no-lock.
                            v-coeffr_afn = v-resprcodn_msb[1].
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"10,14,15,24,25,50,54,55,64,65,13,23,53,63") > 0 then do:
                        if v-resprcodn_msb[2] >= 0 then do:
                            v-bal_all = 0.
                            for each b-lon where b-lon.cif = lon.cif no-lock:
                                run lonbalcrc('lon',b-lon.lon,g-today,"1,7",yes,b-lon.crc,output v-bal).
                                if v-bal > 0 then do:
                                    if b-lon.crc <> 1 then v-bal = v-bal * rate[lon.crc].
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                            if v-bal_all <= v-sumodn_msb then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class_msb[2].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn_msb[2].
                            end.
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"67") > 0 then do:
                        if v-resprcodn[3] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'
                                           sub-cod.rdt = g-today.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[3].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[3].
                            end.
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"20,60") > 0 then do:
                        if v-resprcodn[4] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'
                                           sub-cod.rdt = g-today.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[4].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[4].
                            end.
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"11,21,70,80") > 0 then do:
                        if v-resprcodn[5] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'
                                           sub-cod.rdt = g-today.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[5].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[5].
                            end.
                        end.
                    end.
                    else
                    if lookup(string(lon.grp),"95,96") > 0 then do:
                        if v-resprcodn[6] >= 0 then do:
                            if bilance * rate[lon.crc] <= v-sumodn then do transaction:
                                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnodnor' no-lock no-error.
                                if not avail sub-cod then do:
                                    create sub-cod.
                                    assign sub-cod.sub = 'lon'
                                           sub-cod.acc = lon.lon
                                           sub-cod.d-cod = 'lnodnor'
                                           sub-cod.ccode = '01'
                                           sub-cod.rdt = g-today.
                                end.
                                else do:
                                    if sub-cod.ccode <> '01' then do:
                                        find current sub-cod exclusive-lock.
                                        sub-cod.ccode = '01'.
                                    end.
                                end.
                                find current sub-cod no-lock.
                                find current lonhar exclusive-lock.
                                lonhar.rez-dec[1] = v-coeffr_afn.
                                lonhar.rez-int[1] = lonhar.lonstat.
                                lonhar.lonstat = v-class[6].
                                find current lonhar no-lock.
                                v-coeffr_afn = v-resprcodn[6].
                            end.
                        end.
                    end.
                    v-afn2 = round(bilance * v-coeffr_afn / 100, 2).
                end. /* if avail lonstat */
                else v-afn2 = v-afn1.
            end. /* if avail lonhar */
            else v-afn2 = v-afn1.

            v-restr = 0. v-daycmax = 0. v-ind = 0.
            for each b-lon where b-lon.cif = lon.cif no-lock:
                run lonbalcrc('lon',b-lon.lon,g-today,"1,7",yes,b-lon.crc,output v-bal).
                if v-bal > 0 then do:
                    v-dayc_od = 0. v-dayc_prc = 0.
                    run lonbalcrc('lon',b-lon.lon,g-today,"7,9,50",yes,b-lon.crc,output v-bal1).
                    if v-bal1 > 0 then run lndayspr(b-lon.lon,g-today,yes,output v-dayc_od,output v-dayc_prc).
                    if v-daycmax < v-dayc_od then v-daycmax = v-dayc_od.
                    if v-daycmax < v-dayc_prc then v-daycmax = v-dayc_prc.
                    find first sub-cod where sub-cod.acc = b-lon.lon and sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnrestr' no-lock no-error.
                    if avail sub-cod and sub-cod.ccode = '01' then v-restr = 1.
                end.
            end.
            find first indprov where indprov.dt = s-target and indprov.cif = lon.cif and indprov.lon = lon.lon no-lock no-error.
            if avail indprov and indprov.provsum > 0 then v-ind = 1.

            if v-ind = 1 then do:
                find first indprov where indprov.dt = s-target and indprov.cif = lon.cif and indprov.lon = lon.lon no-lock no-error.
                v-bal = bilance * rate[lon.crc] + prc * rate[lon.crc] + pen.
                v-bal1 = indprov.provsum * rate[lon.crc].
                v-msfo2[1] = round(bilance * v-bal1 / v-bal,2).
                v-msfo2[2] = round(prc * v-bal1 / v-bal,2).
                v-msfo2[3] = round(pen * v-bal1 / v-bal,2).
            end.
            else do:
                if v-restr = 1 or v-daycmax > 180 then do:
                    if lookup(v-poolId[poolIndex],'metro,sotr,factover,flobesp') > 0 then do:
                        v-msfo2[1] = round(bilance * 100 / 100,2).
                        v-msfo2[2] = round(prc * 100 / 100,2).
                        v-msfo2[3] = round(pen * 100 / 100,2).
                    end.
                    else do:
                        v-msfo2[1] = round(bilance * v-coeffr_msfo / 100,2).
                        v-msfo2[2] = round(prc * v-coeffr_msfo / 100,2).
                        v-msfo2[3] = round(pen * v-coeffr_msfo / 100,2).
                    end.
                end.
                else do:
                    v-msfo2[1] = round(bilance * v-coeffr_msfo / 100,2).
                    v-msfo2[2] = round(prc * v-coeffr_msfo / 100,2).
                    v-msfo2[3] = round(pen * v-coeffr_msfo / 100,2).
                end.
            end.

            s-jh1 = 0. s-jh2 = 0. s-jh3 = 0. s-jh4 = 0.

            /* 1 */
            /*
            if v-afn2 <> v-afn1 then do:
                v-bal = v-afn2 - v-afn1.
                v-sum = abs(v-bal).
                if v-bal > 0 then do:
                    v-rem = "Формирование провизий по правилам АФН по кредитному договору " + v-londog.
                    v-tmpl = "LON0151".
                    v-gl = 950000.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             string(v-gl) + vdel +
                             '41' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-rem = "Аннулир. провизий по правилам АФН по кредитному договору N " + v-londog.
                    v-tmpl = "LON0150".
                    v-gl = 950000.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             '41' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh1).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.
            */
            /* 2 */
            if v-msfo2[1] <> v-msfo1[1] then do:
                v-bal = v-msfo2[1] - v-msfo1[1].
                v-sum = abs(v-bal).
                v-rem = "Формирование/Аннулир. провизий по МСФО по кредитному договору N " + v-londog.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    if (lon.grp = 70) or (lon.grp = 80) then v-gl = 545510.
                    else v-gl = 545500.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             string(v-gl) + vdel +
                             '6' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    if (lon.grp = 70) or (lon.grp = 80) then v-gl = 495510.
                    else v-gl = 495500.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             '6' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh2).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx2 od " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.

            if v-msfo2[2] <> v-msfo1[2] then do:
                v-bal = v-msfo2[2] - v-msfo1[2].
                v-sum = abs(v-bal).
                v-rem = "Формирование/Аннулир. провизий по МСФО по кредитному договору N " + v-londog.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    v-gl = 545520.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             string(v-gl) + vdel +
                             '36' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    v-gl = 495520.
                    vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                             '36' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh2).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx2 prc " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.

            if v-msfo2[3] <> v-msfo1[3] then do:
                v-bal = v-msfo2[3] - v-msfo1[3].
                v-sum = abs(v-bal).
                v-rem = "Формирование/Аннулир. провизий по МСФО по кредитному договору N " + v-londog.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    v-gl = 545520.
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             string(v-gl) + vdel +
                             '37' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    v-gl = 495520.
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             '37' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh2).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx2 pen " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.

            /* 3 */
            v-corr1[1] = v-afn1 - v-msfo1[1].
            v-corr1[2] =  - v-msfo1[2].
            v-corr1[3] =  - v-msfo1[3].

            v-corr2[1] = v-afn2 - v-msfo2[1].
            v-corr2[2] =  - v-msfo2[2].
            v-corr2[3] =  - v-msfo2[3].
            /*
            if v-corr2[1] <> v-corr1[1] then do:
                v-bal = v-corr2[1] - v-corr1[1].
                v-sum = abs(v-bal).
                if lon.crc <> 1 then v-sum = v-sum * rate[lon.crc].
                v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН по кредитному договору N " + v-londog.
                v-gl = 359913.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             string(v-gl) + vdel +
                             '38' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             '38' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh3).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx3 od " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.

            if v-corr2[2] <> v-corr1[2] then do:
                v-bal = v-corr2[2] - v-corr1[2].
                v-sum = abs(v-bal).
                if lon.crc <> 1 then v-sum = v-sum * rate[lon.crc].
                v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН по кредитному договору N " + v-londog.
                v-gl = 359913.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             string(v-gl) + vdel +
                             '39' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             '39' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh3).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx3 prc " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.

            if v-corr2[3] <> v-corr1[3] then do:
                v-bal = v-corr2[3] - v-corr1[3].
                v-sum = abs(v-bal).
                v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН по кредитному договору N " + v-londog.
                v-gl = 359913.
                if v-bal > 0 then do:
                    v-tmpl = "LON0151".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             string(v-gl) + vdel +
                             '40' + vdel +
                             lon.lon + vdel +
                             v-rem.
                end.
                else do:
                    v-tmpl = "LON0150".
                    vparam = string(v-sum) + vdel + "1" + vdel +
                             '40' + vdel +
                             lon.lon + vdel +
                             string(v-gl) + vdel +
                             v-rem.
                end.
                run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh3).
                if rcode <> 0 then do:
                    run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx3 pen " + rdes + " " + vparam).
                    message "Провизии:" rcode rdes.
                    pause.
                end.
            end.
            */
            /* 4 */
            /*
            if lon.crc <> 1 then do:
                if rate[lon.crc] <> rate_his[lon.crc] then do:

                    v-bal = v-corr1[1] * (rate[lon.crc] - rate_his[lon.crc]).
                    if v-bal <> 0 then do:
                        v-sum = abs(v-bal).
                        v-rem = "Корректировка остатков из-за изменения учетного курса по кредитному договору N " + v-londog.
                        v-gl = 359913.
                        if v-bal > 0 then do:
                            v-tmpl = "LON0151".
                            vparam = string(v-sum) + vdel + "1" + vdel +
                                     string(v-gl) + vdel +
                                     '38' + vdel +
                                     lon.lon + vdel +
                                     v-rem.
                        end.
                        else do:
                            v-tmpl = "LON0150".
                            vparam = string(v-sum) + vdel + "1" + vdel +
                                     '38' + vdel +
                                     lon.lon + vdel +
                                     string(v-gl) + vdel +
                                     v-rem.
                        end.
                        run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh4).
                        if rcode <> 0 then do:
                            run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx4 od " + rdes + " " + vparam).
                            message "Провизии:" rcode rdes.
                            pause.
                        end.
                    end.

                    v-bal = v-corr1[2] * (rate[lon.crc] - rate_his[lon.crc]).
                    if v-bal <> 0 then do:
                        v-sum = abs(v-bal).
                        v-rem = "Корректировка остатков из-за изменения учетного курса по кредитному договору N " + v-londog.
                        v-gl = 359913.
                        if v-bal > 0 then do:
                            v-tmpl = "LON0151".
                            vparam = string(v-sum) + vdel + "1" + vdel +
                                     string(v-gl) + vdel +
                                     '39' + vdel +
                                     lon.lon + vdel +
                                     v-rem.
                        end.
                        else do:
                            v-tmpl = "LON0150".
                            vparam = string(v-sum) + vdel + "1" + vdel +
                                     '39' + vdel +
                                     lon.lon + vdel +
                                     string(v-gl) + vdel +
                                     v-rem.
                        end.
                        run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh4).
                        if rcode <> 0 then do:
                            run savelog("provlogerr", "ERROR " + lon.cif + " " + lon.lon + " trx4 prc " + rdes + " " + vparam).
                            message "Провизии:" rcode rdes.
                            pause.
                        end.
                    end.

                end.
            end. */ /* if lon.crc <> 1 */

            put stream rep unformatted
                lon.cif ";"
                "'" lon.lon ";"
                lon.crc ";"
                replace(trim(string(v-afn1,"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-afn2,"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo1[1],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo1[2],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo1[3],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[1],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[2],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[3],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-afn2 - v-afn1,"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[1] - v-msfo1[1],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[2] - v-msfo1[2],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-msfo2[3] - v-msfo1[3],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-corr2[1] - v-corr1[1],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-corr2[2] - v-corr1[2],"->>>>>>>>>>>9.99")),'.',',') ";"
                replace(trim(string(v-corr2[3] - v-corr1[3],"->>>>>>>>>>>9.99")),'.',',') ";".
            if lon.crc = 1 then put stream rep unformatted "0;0;".
            else do:
                put stream rep unformatted
                    replace(trim(string(v-corr1[1] * (rate[lon.crc] - rate_his[lon.crc]),"->>>>>>>>>>>9.99")),'.',',') ";"
                    replace(trim(string(v-corr1[2] * (rate[lon.crc] - rate_his[lon.crc]),"->>>>>>>>>>>9.99")),'.',',') ";".
            end.
            put stream rep unformatted
                s-jh1 ";"
                s-jh2 ";"
                s-jh3 ";"
                s-jh4 ";"
                v-poolid[poolIndex] ";"
                v-daycmax ";"
                v-restr ";"
                v-ind skip.

            if s-jh1 > 0 then run lonresadd(s-jh1).
            if s-jh2 > 0 then run lonresadd(s-jh2).
            if s-jh3 > 0 then run lonresadd(s-jh3).
            if s-jh4 > 0 then run lonresadd(s-jh4).

        end. /* for each lon */

    end. /* do j = 1 to num-entries(v-pool[poolIndex]) */

end. /* do poolIndex = 1 to 9 */

output stream rep close.


