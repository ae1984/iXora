/* pkstatus.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Автоматическое определение статуса для начисления провизий по программе БЫСТРЫЕ ДЕНЬГИ
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        29.01.2004 marinav
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       20/05/2004 madiyar - выделил расчет просроченных процентов по схемам 3 и 4 в reprasprc.i
       29/07/2004 madiyar - добавил колонки "Провизия", "Разница по провизиям", "Статус за 25 число" и итоговую таблицу по категориям
       28/09/2004 madiyar - изменил расчет просрочки (не прогнозная, а реальная). Теперь если день погашения попадает на день формирования провизий, то
                            даже в случае отсутствия денег на текущем счете у клиента статус ставим 5% (без просрочки)
       30/09/2004 madiyar - новые провизии начислялись на текущий од - теперь на прогнозный
       02/11/2004 madiyar - подправил расчет дней просрочки; убрал условие "balmax >= 100"
       03/02/2005 madiyar - если прогнозный ОД < 0, то приравниваем нулю
                            В нижнюю таблицу собираем прогнозный ОД
       07/02/2005 madiyar - выбор схемы начисления провизий
       29/04/2005 madiyar - 3 схема начисления провизий
       24/08/2005 madiyar - учет 5ой кредитной схемы
       31/10/2006 madiyar - редактирование статусов, no-undo
       29/02/2008 madiyar - к сумме остатка на тек. счету добавляем сегодняшние платежи из lnrkc; разницу в сумме просрочки <= 1 тенге не учитываем
       22/07/2008 madiyar - если lonhar за дату уже существует, новую запись не создаем
*/

{mainhead.i}
{pk.i new}
{pk-sysc.i}

def var coun as int no-undo init 1.
define variable datums  as date no-undo format "99/99/9999" label "На".
def var dat_wrk as date no-undo.
define variable sumbil as decimal no-undo format "->,>>>,>>9.99".
define variable sumprovold as decimal no-undo format "->,>>>,>>9.99".
define variable sumprov as decimal no-undo format "->,>>>,>>9.99".
def var tempgrp as int no-undo.

datums = g-today.
/*update datums label " Укажите дату " format "99/99/9999" 
       validate (datums <= g-today, " Дата должна быть не больше текущей!")
       skip
       with side-label row 5 centered frame dat .
*/

/* последний рабочий день до дня формирования провизий */
find last cls where cls.whn < datums and cls.del no-lock no-error.
dat_wrk = cls.whn.

def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
def var daymax as int no-undo init 0.
/*
def var balmax as deci no-undo init 0.
*/
def var v-aaa as char no-undo.

def temp-table wrk no-undo
    field lon         like lon.lon
    field cif         like lon.cif
    field name        like cif.name
    field bilance     like lon.opnamt
    field bilance_pro like lon.opnamt
    field bal1        like lon.opnamt
    field dt1         as   inte
    field bal2        like lon.opnamt
    field dt2         as   inte 
    field daymax      as   inte
    field aaabal      as   decimal
    field statold     like lonstat.lonstat
    field provold     as   deci
    field stat        like lonstat.lonstat
    field prov        as   deci
    field stat25      like lonstat.lonstat
    index main is primary stat DESC name
    index bal bal1 bal2.

def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0. 
def var v-am3 as decimal no-undo init 0. 

def var bilance   as decimal no-undo format "->,>>>,>>>,>>9.99".
def var bilancepl as decimal no-undo format "->,>>>,>>9.99".
/*
def var bil1 as decimal no-undo format "->,>>>,>>9.99".
def var bil2 as decimal no-undo format "->,>>>,>>9.99".
def var bilpen as decimal no-undo format "->,>>>,>>9.99".
*/
def var vcu like lon.opnamt extent 6 no-undo decimals 2.
def var f-dat1     as date no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var v-ankln as integer no-undo.
def var v-aabbal as decimal no-undo.
def var v-aabbaltim as decimal no-undo.
def var v-aaacon as decimal no-undo.
def var v-prosrochka as decimal no-undo.

def var dat25 as date no-undo.
def var categ as char extent 3 no-undo init ["Без просрочки", "Просрочка до 30 дней", "Просрочка свыше 30 дней"].
def var categprc as char extent 3 no-undo init ["5%", "50%", "100%"].
def var cat_kol as int extent 3 no-undo.
def var cat_prov as deci extent 3 no-undo.
def var cat_od as deci extent 3 no-undo.
def var ii as integer no-undo.

def var bilance_pro as deci no-undo.
def var nach_od as deci no-undo.
def var nach_prc as deci no-undo.
def var v-aabbal2 as decimal no-undo.

define new shared temp-table w-amk
       field    nr   as integer
       field    dt   as date
       field    fdt  as date
       field    amt1 as decimal format "->>>,>>>,>>9.99"
       field    amt2 as decimal format "->>>,>>>,>>9.99".

/*s-credtype = '6'. только для быстрых денег*/

def temp-table t-longrp no-undo 
  field longrp as integer 
  index longrp is primary unique longrp.

def var pr_scheme as integer no-undo format ">9".
pr_scheme = 1.

update pr_scheme label " Схема начисления провизий "
       validate (pr_scheme >= 1 and pr_scheme <= 3, " Некорректное значение! ")
       " " skip(1)
       "                  Схема 1    Схема 2    Схема 3 " skip
       "                  -------    -------    ------- " skip
       " Без просрочки          2          2          2 " skip
       " 1  - 15 дней           6          2          2 " skip
       " 16 - 30 дней           6          2          6 " skip
       " 31 - 60 дней           7          6          7 " skip
       " свыше 60 дней          7          7          7 " skip(1)
       with centered row 7 side-labels frame fr.

/* день для статуса на 25 число */
if day(g-today) = 25 then dat25 = g-today.  /* если сегодня 25-ое - его и берем */
else do:
   if day(g-today) < 25 then do:
       dat25 = g-today - day(g-today).
       dat25 = date(month(dat25),25,year(dat25)). /* если < 25 - берем 25-ое число прошлого месяца */
   end.
   else do:
       dat25 = date(month(g-today),25,year(g-today)). /* 25-ое число текущего месяца */
   end.
end.

for each pksysc where pksysc.credtype = s-credtype and pksysc.sysc begins "longr" no-lock:
  find t-longrp where t-longrp.longrp = pksysc.inval no-error.
  if not avail t-longrp then do:
    create t-longrp.
    t-longrp.longrp = pksysc.inval.
  end.
end.

for each t-longrp, 
    each lon where lon.grp = t-longrp.longrp no-lock:
    
    if lon.opnamt <= 0 then next.
    /*
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
    if not avail pkanketa then next.
    */
    
    run lonbalcrc('lon',lon.lon,datums,'1,7',yes,lon.crc,output bilance). /* остаток  ОД*/
    if bilance <= 0 then next.
    
    find first cif where cif.cif = lon.cif no-lock.
    
    run lonbalcrc('lon',lon.lon,datums,"7",yes,lon.crc,output v-am3). /* просрочка од */
    
    v-am1 = 0.
    v-am2 = 0.
    
    if lon.plan = 0 or lon.plan = 1 or lon.plan = 2 then do:
        run r-lncal(lon.lon, 2).
        for each w-amk where w-amk.fdt <= datums or w-amk.amt2 > 0 by w-amk.nr:
            run atl-prcl(input lon.lon, input w-amk.fdt - 1, output vcu[3], output vcu[4], output vcu[2]).                                   
            w-amk.amt1 = vcu[3].  
        end.
        
        find last w-amk where w-amk.fdt < datums no-lock no-error.
        if avail w-amk then do:
            f-dat1 = w-amk.fdt.
            v-am2 = w-amk.amt1.
        end.
    
        for each w-amk:
            if w-amk.dt >= f-dat1 then  v-am1 = v-am1 + w-amk.amt2.
        end.
    end.
    
    if lon.plan = 3 or lon.plan = 4 or lon.plan = 5 then do:
        run lonbalcrc('lon',lon.lon,datums,"9,10",yes,lon.crc,output v-am2).
    end.
    
    v-aaa = lon.aaa. 
    
    find aaa where aaa.aaa = v-aaa no-lock no-error.
    v-aabbal = aaa.cr[1] - aaa.dr[1].
    
    /* к сумме остатка на тек. счету добавляем сегодняшние платежи */
    for each lnrkc where lnrkc.bank = s-ourbank and lnrkc.bn = 2 and lnrkc.whn = g-today and lnrkc.dtimp = ? and lnrkc.cif = lon.cif no-lock:
        v-aabbal = v-aabbal + lnrkc.amt.
    end.
    
    v-aaacon = v-aabbal.
    run lonbalcrc('lon',lon.lon,g-today,"4,5,7,9,16",yes,lon.crc,output v-prosrochka).
    
    find first trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = 1 and trxbal.lev = 16 no-lock no-error.
    if avail trxbal and v-aabbal > 0 then v-aabbal = v-aabbal - (trxbal.dam - trxbal.cam).
    if v-aabbal < 0 then v-aabbal = 0.
    
    v-aabbal2 = v-aabbal.
    
    dayc1 = 0. dayc2 = 0.
    
    if v-am2 - v-am1 > 0 then do:
        tempdt = dat_wrk.
        tempost = 0.
        repeat:
            find last lnsci where lnsci.lni = lon.lon and lnsci.idat <= tempdt and lnsci.f0 > 0 no-lock no-error.
            if avail lnsci then do:
                tempost = tempost + lnsci.iv-sc.
                if v-am2 - v-am1 <= tempost + 1 then do:
                    dayc2 = datums - lnsci.idat.
                    leave.
                end.
                tempdt = lnsci.idat - 1.
            end.
            else leave.
        end.
    end.
    
    if v-am3 > 0 then do:
        tempdt = dat_wrk.
        tempost = 0.
        repeat:
            find last lnsch where lnsch.lnn = lon.lon and lnsch.stdat <= tempdt and lnsch.f0 > 0 no-lock no-error.
            if avail lnsch then do:
                tempost = tempost + lnsch.stval.
                if v-am3 <= tempost + 1 then do:
                    dayc1 = datums - lnsch.stdat.
                    leave.
                end.
                tempdt =  lnsch.stdat - 1.
            end.
            else leave.
        end.
    end.
    
    /*
    dlong =  lon.duedt.
    if lon.ddt[5] <> ? then dlong = lon.ddt[5].
    if lon.cdt[5] <> ? then dlong = lon.cdt[5].
    
    if v-am3 < 0 then bil1 = 0. else bil1 = v-am3.
    if v-am2 - v-am1 < 0 then bil2 = 0. else bil2 = v-am2 - v-am1. 
    if dlong < datums then do:
        bil1 = bilance.
        if lon.plan = 3 then bil2 = v-am2.
        else do:
            run atl-prcl(input lon.lon, input datums - 1, output vcu[3], output vcu[4], output vcu[2]).                                   
            bil2 = vcu[3].
        end.
    end.
    */
    
    tempgrp = datums - 1 - dat_wrk.
    /* надо учесть выходные - в понедельник для тех, у кого выпало погашение на субботу - dayc=2, на воскресенье - dayc=1 */
    if tempgrp > 0 and (dayc1 <= tempgrp) and (dayc2 <= tempgrp) then assign dayc1 = 0 dayc2 = 0.
    /**/
    
    /*
    balmax = bil1 + bil2.
    if balmax > v-aabbal then assign balmax = balmax - v-aabbal v-aabbal = 0.
                         else assign v-aabbal = v-aabbal - balmax balmax = 0.
    */
    
    /* Прогноз основного долга */
    v-aabbal2 = v-aabbal2 - v-am2.
    if v-aabbal2 < 0 then v-aabbal2 = 0.
    bilance_pro = bilance.
    nach_od = 0. nach_prc = 0.
    find first lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 and
                           lnsch.stdat > dat_wrk and lnsch.stdat <= datums no-lock no-error.
    if avail lnsch then nach_od = lnsch.stval.
    find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 and
                           lnsci.idat > dat_wrk and lnsci.idat <= datums no-lock no-error.
    if avail lnsci then nach_prc = lnsci.iv-sc.
    
    if v-aabbal2 >= v-am3 then do:
        v-aabbal2 = v-aabbal2 - v-am3.
        bilance_pro = bilance_pro - v-am3.
        
        v-aabbal2 = v-aabbal2 - nach_prc.
        if v-aabbal2 < 0 then v-aabbal2 = 0.
        
        if v-aabbal2 >= nach_od then do:
            v-aabbal2 = v-aabbal2 - nach_od.
            bilance_pro = bilance_pro - nach_od.
        end.
        else bilance_pro = bilance_pro - v-aabbal2.
    end.
    else bilance_pro = bilance_pro - v-aabbal2.
    
    if bilance_pro < 0 then bilance_pro = 0.
    /* Прогноз основного долга - end */
    
    create wrk.  
    assign wrk.cif =  cif.cif
           wrk.lon = lon.lon
           wrk.name = trim(trim(cif.prefix) + " " + trim(cif.name))
           wrk.bilance = bilance
           wrk.bilance_pro = bilance_pro
           wrk.bal1 = /*balmax*/ v-prosrochka
           wrk.dt1 = dayc1
           wrk.bal2 = 0
           wrk.dt2 = dayc2
           wrk.aaabal = v-aabbal.
    
    find last lonhar where lonhar.lon = lon.lon and lonhar.fdt <= datums no-lock no-error.
    if avail lonhar then wrk.statold = lonhar.lonstat.
                    else wrk.statold = 1.
    
    find first lonstat where lonstat.lonstat = wrk.statold no-lock no-error.
    wrk.provold = bilance * lonstat.prc / 100.
    
    if dayc1 > dayc2 then daymax = dayc1.
                     else daymax = dayc2.
    
    if pr_scheme = 1 then do:
        wrk.stat = 2.
        if daymax > 0 then wrk.stat = 6.
        if daymax > 30 then wrk.stat = 7.
    end.
    if pr_scheme = 2 then do:
        wrk.stat = 2.
        if daymax > 30 then wrk.stat = 6.
        if daymax > 60 then wrk.stat = 7.
    end.
    if pr_scheme = 3 then do:
        wrk.stat = 2.
        if daymax > 15 then wrk.stat = 6.
        if daymax > 30 then wrk.stat = 7.
    end.
    if v-prosrochka > 0 and (v-aaacon >= v-prosrochka) then wrk.stat = 2.
    
    find first lonstat where lonstat.lonstat = wrk.stat no-lock no-error.
    wrk.prov = bilance_pro * lonstat.prc / 100.
    
    wrk.daymax = daymax.
    
    /* статус за 25-ое число */
    if dat25 = g-today then wrk.stat25 = wrk.stat. /* копируем прогнозный статус */
    else do:
        find last lonhar where lonhar.lon = lon.lon and lonhar.fdt <= dat25  no-lock no-error.
        if avail lonhar then wrk.stat25 = lonhar.lonstat.
    end.
end.                       

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

{html-title.i &title = "TEXAKABANK" &stream = "stream m-out" &size-add = "x-"}

put stream m-out unformatted 
    "<TABLE border=""0"" cellpadding=""10"" cellspacing=""0""><TR><TD align=""left"">" cmp.name "</TD></TR>" skip.

put stream m-out unformatted 
    "<TR><TD align=""center""><h3>Классификация кредитов за " string(datums) "<BR><BR></h3></TD></TR>" skip.

put stream m-out unformatted 
    "<TR><TD><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
    "<tr style=""font:bold; bgcolor:#C0C0C0;font-size:xx-small"" align=""center"">"
    "<td>П/п</td>"
    "<td>Номер</td>"
    "<td>Наименование заемщика</td>"
    "<td>Остаток ОД </td>"
    "<td>Просрочка </td>"
    "<td>Дней<BR>просрочки</td>"
    "<td>Сумма на<BR>текущем счете</td>"
    "<td>Текущий<BR>статус</td>"
    "<td>Провизия</td>"
    "<td>Статус<BR>(прогноз)</td>"
    "<td>Остаток ОД<BR>(прогноз)</td>"
    "<td>Провизия<BR>(прогноз)</td>"
    "<td>Разница по<BR>провизиям</td>"
    "<td>Статус за<BR>" dat25 format "99/99/9999" "</td>"
    "</tr>" skip.

sumbil = 0.
sumprov = 0.
for each wrk break by wrk.stat.
    
    /*find first lonstat where lonstat.lonstat = wrk.stat no-lock no-error.*/
    put stream m-out unformatted 
        "<tr align=""right"" " if wrk.statold ne wrk.stat then " style=""color:red""" else "" "> "
        "<td align=""center""> " coun "</td>"
        "<td align=""left""> " wrk.cif "</td>"
        "<td align=""left""> " wrk.name format "x(60)" "</td>"
        "<td>" replace(trim(string(wrk.bilance, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" replace(trim(string(wrk.bal1 + wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" wrk.daymax format "->>>9" "</td>"
        "<td>" replace(trim(string(wrk.aaabal, "->>>>>>>>>>>9.99")),".",",") "</td>"     
        "<td>" wrk.statold "</td>"
        "<td>" replace(trim(string(wrk.provold, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" wrk.stat "</td>"
        "<td>" replace(trim(string(wrk.bilance_pro, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" replace(trim(string(wrk.prov, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" replace(trim(string(wrk.provold - wrk.prov, "->>>>>>>>>>>9.99")),".",",") "</td>"
        "<td>" if wrk.stat25 <> 0 then string(wrk.stat25) else "" "</td>"
        "</tr>" skip.
    coun = coun + 1.
    sumbil = sumbil + wrk.bilance.
    sumprovold = sumprovold + wrk.provold.
    sumprov = sumprov + wrk.prov.
    
    case wrk.stat:
        when 2 then ii = 1.
        when 6 then ii = 2.
        when 7 then ii = 3.
        otherwise do:
           message wrk.cif wrk.stat view-as alert-box.
        end.
    end.
    cat_kol[ii] = cat_kol[ii] + 1.
    cat_prov[ii] = cat_prov[ii] + wrk.prov.
    cat_od[ii] = cat_od[ii] + wrk.bilance_pro.
end.                       

put stream m-out unformatted 
    "<tr align=""left"">"
    "<td><b> ИТОГО </b></td> <td></td> <td></td>" skip
    "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
    "<td></td><td></td><td></td><td></td>" skip
    "<td align=""right""><b>" replace(trim(string(sumprovold, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
    "<td></td><td></td>" skip
    "<td align=""right""><b>" replace(trim(string(sumprov, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
    "<td align=""right""><b>" replace(trim(string(sumprovold - sumprov, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
    "<td></td>" skip
    "</tr>" skip.

put stream m-out "</table></TD></TR></TABLE>" skip.

if s-credtype = '6' then do:
    put stream m-out unformatted 
                  "<BR><BR><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold; bgcolor:#C0C0C0;font-size:xx-small"" align=""center"">" skip
                  "<td>П/п</td>"
                  "<td colspan=""2"">Классификационные категории</td>"
                  "<td>Размер<BR>провизии</td>"
                  "<td>Количество</td>"
                  "<td>Сумма<BR>провизий</td>"
                  "<td>Остаток ОД</td>"
                  "</tr>" skip.
    do ii = 1 to 3:
       put stream m-out unformatted
                  "<tr>" skip
                  "<td align=""center"">" ii "</td>"
                  "<td colspan=""2"">" categ[ii] "</td>"
                  "<td>" categprc[ii] "</td>"
                  "<td>" cat_kol[ii] "</td>"
                  "<td>" replace(trim(string(cat_prov[ii], "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "<td>" replace(trim(string(cat_od[ii], "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "</tr>" skip.
    end.
    put stream m-out unformatted
                  "<tr>" skip
                  "<td align=""center"">4</td>"
                  "<td colspan=""2"">ВСЕГО</td>"
                  "<td></td>"
                  "<td>" cat_kol[1] + cat_kol[2] + cat_kol[3]"</td>"
                  "<td>" replace(trim(string(cat_prov[1] + cat_prov[2] + cat_prov[3], "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "<td>" replace(trim(string(cat_od[1] + cat_od[2] + cat_od[3], "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "</tr>" skip.
end.

{html-end.i "stream m-out"}

output stream m-out close.

unix silent cptwin rpt.html excel.

pause 0.


/* проставить статусы */
define var ja as logical.
ja = no.
message " Принять классификацию ?" update ja.
if ja then do: 
    output to stat.img.
    for each wrk where wrk.statold ne wrk.stat no-lock:
          find last lonhar where lonhar.lon = wrk.lon and lonhar.fdt = g-today exclusive-lock no-error.
          if not avail lonhar then do:
              create lonhar. 
              assign lonhar.lon = wrk.lon
                     lonhar.ln = 0
                     lonhar.fdt = g-today
                     lonhar.cif = wrk.cif
                     lonhar.akc = no
                     lonhar.who = g-ofc
                     lonhar.whn = g-today. 
          end.
          lonhar.lonstat = wrk.stat.
          find current lonhar no-lock.
          displ wrk.cif ' ' wrk.lon ' ' wrk.stat skip.
    end.
    output close.
end.
