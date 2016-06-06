/* pkklass.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Автоматический расчет классификации по экспресс-кредитам
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
        22/07/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        05/09/2008 madiyar - расчет прогнозного ОД
        26/05/2009 madiyar - классификация валютных кредитов
        30/09/2009 madiyar - добавились поля
        31/10/2009 madiyar - прогноз провизий в тенге
        26/01/2010 madiyar - добавил 4 столбца с данными по наличию средств на счету и суммами к оплате
        28/01/2010 madiyar - подправил форматы вывода
        31/08/2010 madiyar - перекомпиляция
        12/10/2010 madiyar - изменения по расчету фин. состояния; убрал три ненужных критерия
        03/01/2011 madiyar - по экспресс-кредитам провизии начисляем и на начисл. и просроч. проценты
        28/02/2011 madiyar - однородные кредиты
*/

{mainhead.i}

def new shared temp-table wrk no-undo
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

def temp-table wrk1 no-undo
    field bank as char
    field ltype as char
    field lcount as integer
    field od as deci
    field prc as deci
    field pen as deci
    field od_prosr as deci
    field prc_prosr as deci
    field rezprc as deci
    field prov_od as deci
    field prov_prc as deci
    field prov_pen as deci
    field prov as deci
    index bank is primary ltype bank.

def var i as integer no-undo.
def var j as integer no-undo.
def var v-bank as char no-undo.
def var v-port as char no-undo.
def buffer b-wrk1 for wrk1.

def new shared var s-rates as deci no-undo extent 3.
for each crc no-lock:
    if crc.crc >= 1 and crc.crc <= 3 then s-rates[crc.crc] = crc.rate[1].
end.

{r-brfilial.i &proc = "pkklass2"}

for each wrk no-lock break by wrk.bank by wrk.port:

    if first-of(wrk.port) then do:
        v-bank = wrk.bank.
        if v-bank = "txb16" then v-bank = "txb00".
        v-port = wrk.port.
        if v-port = '' then v-port = "2. Индивидуальные Метрокредит".
        find first wrk1 where wrk1.bank = v-bank and wrk1.ltype = v-port no-error.
        if not avail wrk1 then do:
            create wrk1.
            wrk1.bank = v-bank.
            wrk1.ltype = v-port.
        end.
    end.
    
    find first b-wrk1 where b-wrk1.bank = v-bank and b-wrk1.ltype = "Всего по портфелям однородных кредитов + Индивидуальные Метрокредит" no-error.
    if not avail b-wrk1 then do:
        create b-wrk1.
        b-wrk1.bank = v-bank.
        b-wrk1.ltype = "Всего по портфелям однородных кредитов + Индивидуальные Метрокредит".
    end.
    b-wrk1.lcount = b-wrk1.lcount + 1.
    b-wrk1.od = b-wrk1.od + wrk.od * s-rates[wrk.crc].
    b-wrk1.prc = b-wrk1.prc + (wrk.prc2 + wrk.prc9) * s-rates[wrk.crc].
    b-wrk1.pen = b-wrk1.pen + wrk.pen.
    b-wrk1.prov_od = b-wrk1.prov_od + wrk.progprov_od.
    b-wrk1.prov_prc = b-wrk1.prov_prc + wrk.progprov_prc.
    b-wrk1.prov_pen = b-wrk1.prov_pen + wrk.progprov_pen.
    b-wrk1.prov = b-wrk1.prov + wrk.progprov_od + wrk.progprov_prc + wrk.progprov_pen.


    wrk1.lcount = wrk1.lcount + 1.
    wrk1.od = wrk1.od + wrk.od * s-rates[wrk.crc].
    wrk1.prc = wrk1.prc + (wrk.prc2 + wrk.prc9) * s-rates[wrk.crc].
    wrk1.pen = wrk1.pen + wrk.pen.
    
    if wrk.days > 14 then assign wrk1.od_prosr = wrk1.od_prosr + wrk.od * s-rates[wrk.crc]
                                 wrk1.prc_prosr = wrk1.prc_prosr + (wrk.prc2 + wrk.prc9) * s-rates[wrk.crc].

    if wrk1.rezprc = 0 then wrk1.rezprc = wrk.class_prc.

    wrk1.prov_od = wrk1.prov_od + wrk.progprov_od.
    wrk1.prov_prc = wrk1.prov_prc + wrk.progprov_prc.
    wrk1.prov_pen = wrk1.prov_pen + wrk.progprov_pen.
    wrk1.prov = wrk1.prov + wrk.progprov_od + wrk.progprov_prc + wrk.progprov_pen.

end.


def stream rep.
def var v-coun as integer no-undo.
def var v-sum as deci no-undo extent 9.

output stream rep to rpt1.htm.
put stream rep "<html><head><title>Классификация портфеля экспресс-кредитов (сводные данные)</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Классификация портфеля экспресс-кредитов (сводные данные), " g-today format "99/99/9999" " " string(time,"hh:mm:ss") "<BR>" skip
    v-bankname "</b><BR><BR>" skip.

for each wrk1 no-lock break by wrk1.ltype by wrk1.bank:
    
    if first-of(wrk1.ltype) then do:
        
        put stream rep unformatted
            wrk1.ltype "<br>" skip
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td>Филиал</td>" skip
            "<td>Кол-во кредитов</td>" skip
            "<td>Остаток ОД (KZT)</td>" skip
            "<td>Начисл. и просроч. %% (KZT)</td>" skip
            "<td>Штрафы (KZT)</td>" skip
            if lookup(wrk1.ltype,"1. Однородные Метрокредит,3. Однородные Сотрудники") > 0 then "<td>Остаток ОД с просрочкой 15+ (KZT)</td><td>%% с просрочкой 15+ (KZT)</td><td>Рассчитанный % резерва</td>" else "" skip
            "<td>Резерв на ОД (KZT)</td>" skip
            "<td>Резерв на %% (KZT)</td>" skip
            "<td>Резерв на штрафы (KZT)</td>" skip
            "<td>Сумма резерва (KZT)</td>" skip
            "</tr>" skip.
        
        v-coun = 0. v-sum = 0.
    end.

    v-bank = ''.
    if wrk1.bank = "txb00" then v-bank = "г.Алматы".
    else do:
        find first txb where txb.bank = wrk1.bank no-lock no-error.
        if avail txb then v-bank = txb.info.
    end.
    put stream rep unformatted
        "<tr>" skip
        "<td>" v-bank "</td>" skip
        "<td>" wrk1.lcount "</td>" skip
        "<td>" replace(trim(string(wrk1.od,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk1.prc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk1.pen,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
    
    if lookup(wrk1.ltype,"1. Однородные Метрокредит,3. Однородные Сотрудники") > 0 then do:
        put stream rep unformatted
            "<td>" replace(trim(string(wrk1.od_prosr,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk1.prc_prosr,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk1.rezprc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
    end.
    
    put stream rep unformatted
        "<td>" replace(trim(string(wrk1.prov_od,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk1.prov_prc,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk1.prov_pen,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk1.prov,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "</tr>" skip.
    
    v-coun = v-coun + wrk1.lcount.
    v-sum[1] = v-sum[1] + wrk1.od.
    v-sum[2] = v-sum[2] + wrk1.prc.
    v-sum[3] = v-sum[3] + wrk1.pen.
    v-sum[4] = v-sum[4] + wrk1.od_prosr.
    v-sum[5] = v-sum[5] + wrk1.prc_prosr.
    v-sum[6] = v-sum[6] + wrk1.prov_od.
    v-sum[7] = v-sum[7] + wrk1.prov_prc.
    v-sum[8] = v-sum[8] + wrk1.prov_pen.
    v-sum[9] = v-sum[9] + wrk1.prov.

    if last-of(wrk1.ltype) then do:
        put stream rep unformatted
            "<tr style=""font:bold"">" skip
            "<td>ИТОГО</td>" skip
            "<td>" v-coun "</td>" skip
            "<td>" replace(trim(string(v-sum[1],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(v-sum[2],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(v-sum[3],">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
        if lookup(wrk1.ltype,"1. Однородные Метрокредит,3. Однородные Сотрудники") > 0 then do:
            put stream rep unformatted
                "<td>" replace(trim(string(v-sum[4],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
                "<td>" replace(trim(string(v-sum[5],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
                "<td></td>" skip.
        end.
        
        put stream rep unformatted
            "<td>" replace(trim(string(v-sum[6],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(v-sum[7],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(v-sum[8],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(v-sum[9],">>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "</tr></table><br><br>" skip.
    end.

end.

put stream rep unformatted "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt1.htm excel.

output stream rep to rpt.htm.

put stream rep "<html><head><title>Классификация портфеля экспресс-кредитов</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Классификация портфеля экспресс-кредитов, " g-today format "99/99/9999" " " string(time,"hh:mm:ss") "<BR>" skip
    v-bankname "</b><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=2>Код кл</td>" skip
    "<td rowspan=2>ФИО</td>" skip
    "<td rowspan=2>Сс. счет</td>" skip
    "<td rowspan=2>Валюта</td>" skip
    "<td rowspan=2>Дата класс.</td>" skip
    "<td colspan=3>1. Фин. состояние</td>" skip
    "<td colspan=3>2. Просрочка</td>" skip
    "<td colspan=3>3. Обеспечение</td>" skip
    "<td colspan=3>4. Пролонгации</td>" skip
    "<td colspan=3>5. Просроч. обязательства</td>" skip
    /*
    "<td colspan=3>6. Нецел. использование активов</td>" skip
    "<td colspan=3>7. Спис. задолженность</td>" skip
    "<td colspan=3>8. Рейтинг заемщика</td>" skip
    */
    "<td rowspan=2>Сумм. балл</td>" skip
    "<td rowspan=2>Дней пр.</td>" skip
    "<td rowspan=2>Дней пр.<br>(ф)</td>" skip
    "<td rowspan=2>Дней пр.<br>(история)</td>" skip
    "<td rowspan=2>Дней c<br>посл. оплаты %%</td>" skip
    "<td rowspan=2>Реструкт.</td>" skip
    "<td rowspan=2>Статус (стар)</td>" skip
    
    "<td rowspan=2>Однородн.</td>" skip
    "<td rowspan=2>Статус по класс.<br>(однородные)</td>" skip

    "<td rowspan=2>Статус по класс.</td>" skip
    "<td rowspan=2>Процент</td>" skip
    "<td rowspan=2>ОД</td>" skip
    "<td rowspan=2>ОД (в тенге)</td>" skip
    "<td rowspan=2>ОД прог</td>" skip
    
    "<td rowspan=2>%% начисл.</td>" skip
    "<td rowspan=2>%% начисл. прог</td>" skip
    "<td rowspan=2>%% просроч.</td>" skip
    "<td rowspan=2>%% просроч. прог</td>" skip
    "<td rowspan=2>Пеня</td>" skip
    "<td rowspan=2>Пеня прог</td>" skip
    
    /*"<td rowspan=2>Прогноз<br>провизий</td>" skip*/
    "<td rowspan=2>Прогноз провизий<br>ОД, KZT</td>" skip
    "<td rowspan=2>Прогноз провизий<br>%%, KZT</td>" skip
    "<td rowspan=2>Прогноз провизий<br>штрафы, KZT</td>" skip
    "<td rowspan=2>Прог пров<br>KZT</td>" skip
    "<td rowspan=2>Провизии тек.<br>KZT</td>" skip
    "<td rowspan=2>Провизии созд/спис<br>KZT</td>" skip
    
    "<td rowspan=2>Доступная сумма 1</td>" skip
    "<td rowspan=2>Доступная сумма 2</td>" skip

    "<td rowspan=2>Сумма к оплате 1</td>" skip
    "<td rowspan=2>Сумма к оплате 2</td>" skip

    "<td rowspan=2>Остаток на счету<br>после погашения 1</td>" skip
    "<td rowspan=2>Остаток на счету<br>после погашения 2</td>" skip

    "<td rowspan=2>Остаток задолж.<br>после погашения 1</td>" skip
    "<td rowspan=2>Остаток задолж.<br>после погашения 2</td>" skip
    
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.

do i = 1 to 5:
    put stream rep unformatted "<td>Код</td><td>Описание</td><td>Балл</td>" skip.
end.

put stream rep unformatted "</tr>" skip.

for each wrk no-lock:
    put stream rep unformatted
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.fio "</td>" skip
        "<td>" wrk.lon "</td>" skip
        "<td>" wrk.crc "</td>" skip
        "<td>" wrk.dtcl format "99/99/9999" "</td>" skip.
    do i = 1 to 5:
        put stream rep unformatted
            "<td>&nbsp;" wrk.sts[i] "</td>" skip
            "<td>" wrk.sts_des[i] "</td>" skip
            "<td>" replace(trim(string(wrk.rating[i],"->>9.99")),'.',',') "</td>" skip.
    end.
    put stream rep unformatted
        "<td>" replace(trim(string(wrk.rating_s,"->>9.99")),'.',',') "</td>" skip
        "<td>" wrk.days "</td>" skip
        "<td>" wrk.fdays "</td>" skip
        "<td>" if wrk.sts[2] = '01' then string(wrk.days_old) else '' "</td>" skip
        "<td>" wrk.dayspprc "</td>" skip
        "<td>&nbsp;" if wrk.sts[2] = '01' then wrk.restr else '' "</td>" skip
        "<td>&nbsp;" wrk.class_old "</td>" skip
        "<td>" wrk.port "</td>" skip
        "<td>&nbsp;" wrk.class_odn "</td>" skip
        "<td>&nbsp;" wrk.class "</td>" skip
        "<td>" replace(trim(string(wrk.class_prc,">>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.od,">>>>>>>>9.99")),'.',',') "</td>" skip
         "<td>" replace(trim(string(wrk.od * s-rates[wrk.crc],">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.od_pro,">>>>>>>>9.99")),'.',',') "</td>" skip

        "<td>" replace(trim(string(wrk.prc2,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prc2_pro,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prc9,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prc9_pro,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.pen,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.pen_pro,">>>>>>>>9.99")),'.',',') "</td>" skip
        
        /*"<td>" replace(trim(string(wrk.progprov,">>>>>>>>9.99")),'.',',') "</td>" skip*/
        "<td>" replace(trim(string(wrk.progprov_od,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.progprov_prc,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.progprov_pen,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.progprov,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prov,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.progprov - wrk.prov,"->>>>>>>>9.99")),'.',',') "</td>" skip

        "<td>" replace(trim(string(wrk.acc_avail_amt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.acc_avail_amt2,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip

        "<td>" replace(trim(string(wrk.pay_amt1,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.pay_amt2,">>>>>>>>9.99")),'.',',') "</td>" skip

        "<td>" replace(trim(string(wrk.acc_left_amt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.acc_left_amt2,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip

        "<td>" replace(trim(string(wrk.dbt_left_amt1,">>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.dbt_left_amt2,">>>>>>>>9.99")),'.',',') "</td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table><BR><BR>" skip.

hide message no-pause.
put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.



