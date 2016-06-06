/* lnanlz3.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Анализ кредитного портфеля для БЫМТРЫХ ДЕНЕГ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-5-13 
 * AUTHOR
        09.12.2003 marinav,nataly
 * CHANGES
        13.12.2003 marinav поменялось почти все
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        18.12.2003 marinav - при подсчете суммы выданных кредитов последний период 
                             берется месяц , а не с 01.01.год
        23.12.2003 marinav - добавлена доля в портфеле нестандартных кредитов за каждый период 
        03.01.2004 marinav - добавлена комиссия 3 % (покрытие кред рисков)
        06.01.2004 marinav - добавлена комиссия за выдачу кредита.
                             изменены расчеты просрочки, добавлена таблица по клас-ции быстрых денег
                             выделены филиалы   
        04.02.2004 nadejda - добавлены штрафы и рентабельность
        05.04.2004 nadejda - закрытие/открытие потока вывода
                             запрет филиалам видеть чужой отчет
        05/07/2004 madiyar - добавил массив comm_prov для хранения рассчитанных общих провизий на каждую дату
        09/07/2004 madiyar - добавил массив share_pr для хранения доли просроченных кредитов в портфеле
        04/08/2004 madiyar - изменил размерность массива supar в связи с изменениями в lnanlz3.i
        05/08/2004 madiyar - перекомпиляция
        06/08/2004 madiyar - добавил переменную komiss для расчета комиссий
        09/08/2004 madiyar - добавил временную таблицу wrkm для расчета начисл.%, получ.%, пени (по всем кредитам, не только по
                             попавшим в wrk)
        05/07/2004 madiyar - добавил массив fact_prov для хранения фактически начисленных провизий на каждую дату
        12/10/2004 madiyar - перекомпиляция
        09/11/2004 madiyar - полностью переделал отчет
        10/10/2005 madiyar - добавилась комиссия за ведение тек. счета
        01/03/2006 madiyar - no-undo
        12/04/2007 madiyar - убрал лишние комиссии
        16/04/2007 madiyar - поменял "фонд страхования..." на "фонд покрытия..."
        07/02/2008 madiyar - изменения в отчете
        03/03/08 marinav - изменила валюту 11 на валюту 3 ( евро)
        04/05/2008 madiyar - полностью переделал на использование данных из хранилища
        03/06/2008 madiyar - поменял последовательность строк в таблице по доходам
        11/02/2009 galina - изменила формат вывода комиссий за период и итоговых сумм для доходов
        05.05.2009 galina - изменила формат вывода сумм
*/  

{mainhead.i}

function get_value returns deci (pbank as char, pdt as date, pcode as integer).
    find first vals where vals.bank = pbank and vals.code = pcode and vals.dt = pdt no-lock no-error.
    if avail vals then return (vals.deval).
    else return (0). 
end function.

def var v-filials as char no-undo.
def var v-select as integer no-undo.
def var v-bankname as char no-undo.
def var v-bank as char no-undo.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

if s-ourbank = "txb00" then do:
    for each txb where txb.consolid no-lock break by txb.txb:
        if v-filials <> "" then v-filials = v-filials + " | ".
        v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
    end.
    v-filials = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | " + v-filials.
    v-select = 0.
    run sel3 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", v-filials, output v-select).
    if v-select = 0 then return.
end.
else v-select = integer(substring(s-ourbank,4,2)) + 2.

if v-select = 1 then do:
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<br>Консолидированный отчет".
  v-bank = "bank".
end.
else do:
  find txb where txb.consolid and txb.txb = v-select - 2 no-lock no-error.
  v-bankname = txb.name.
  v-bank = txb.bank.
end.

def var i as integer no-undo.
def var d1 as date no-undo.
def var dates as date no-undo extent 5. /* данные выводятся только по 4 датам, 5-ая - для расчета данных за самый старый период в отчете */
def var itogo1 as deci no-undo extent 4.
def var itogo2 as deci no-undo extent 4.

d1 = g-today.
update d1 label " Укажите дату" format "99/99/9999" skip with side-label row 5 centered frame dat.

dates[1] = d1.
if day(d1) <> 1 then dates[2] = date(month(d1),1,year(d1)).
else dates[2] = date(month(d1 - 1),1,year(d1 - 1)).
do i = 3 to 5:
    dates[i] = date(month(dates[i - 1] - 1),1,year(dates[i - 1] - 1)).
end.

def stream rep.
output stream rep to rpt.htm.

put stream rep "<html><head><title>Анализ портфеля экспресс-кредитов</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Анализ портфеля экспресс-кредитов на " d1 format "99/99/9999" "<BR>" skip
    v-bankname "</b><BR><BR>" skip
    "ДИНАМИКА РОСТА КРЕДИТНОГО ПОРТФЕЛЯ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td colspan=2></td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" dates[i] format "99/99/9999" "</td>" skip. end.
put stream rep unformatted
    "</tr>" skip
    "<tr>" skip
    "<td rowspan=4>Кредитный портфель</td>" skip.

put stream rep unformatted "<td>Количество заемщиков</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],13), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],12), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Сумма, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],9), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Сумма, USD</td>" skip.
do i = 1 to 4:
    find last crchis where crchis.crc = 2 and crchis.regdt < dates[i] no-lock no-error.
    put stream rep unformatted "<td>" replace(replace(string(round(get_value(v-bank,dates[i],9) / crchis.rate[1],2), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted
       "<td rowspan=2>Удельный вес к:</td>" skip
       "<td>общему ссудному портфелю, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],9) / get_value(v-bank,dates[i],1) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>портфелю потребительских кредитов, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],9) / get_value(v-bank,dates[i],6) * 100, ">>9.99"),","," "),".",",") "</td>" skip. end.
put stream rep unformatted "</tr></table><BR><BR>" skip.

/**********************************************/

put stream rep unformatted
    "ДИНАМИКА РОСТА ВЫДАННЫХ КРЕДИТОВ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

put stream rep unformatted "<tr><td colspan=2>Количество выданных кредитов на дату</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],24), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Количество выданных кредитов за период</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],24) - get_value(v-bank,dates[i + 1],24), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>".
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Объем выданных кредитов на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],22), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Объем выданных кредитов за период, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],22) - get_value(v-bank,dates[i + 1],22), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
end.
put stream rep unformatted "</tr>" skip.
put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "ДИНАМИКА РОСТА ПОГАШЕННЫХ КРЕДИТОВ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

put stream rep unformatted "<tr><td colspan=2>Количество погашенных кредитов на дату</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],31), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],32), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Количество погашенных кредитов за период</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],31) - get_value(v-bank,dates[i + 1],31), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
/*
кол-во спис.кредитов на начало периода - кол-во спис.кредитов на конец периода + кол-во погашенных за период спис.кредитов
*/
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],32) - get_value(v-bank,dates[i + 1],32) + get_value(v-bank,dates[i],146) - get_value(v-bank,dates[i + 1],146), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Объем погашенных кредитов на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],27), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],28), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Объем погашенных кредитов за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],27) - get_value(v-bank,dates[i + 1],27), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
/*
остаток погаш-спис на начало периода - остаток погаш-спис на конец периода + погашенный за период спис.ОД
*/
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],28) - get_value(v-bank,dates[i + 1],28) + get_value(v-bank,dates[i],142) - get_value(v-bank,dates[i + 1],142), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "СФОРМИРОВАННЫЕ ПРОВИЗИИ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=3>Сомнительные 1 категории (5%)</td>" skip
    "<td>Количество кредитов</td>" skip.

do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],59), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],51), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],51) / get_value(v-bank,dates[i],49) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td rowspan=3>Сомнительные 5 категории (50%)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],63), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],55), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],55) / get_value(v-bank,dates[i],49) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td rowspan=3>Безнадежные (100%)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],64), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],56), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],56) / get_value(v-bank,dates[i],49) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td colspan=2>Итого, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],49), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted
       "<tr>" skip
       "<td rowspan=2>Удельный вес к:</td>" skip
       "<td>провизиям по общему ссудному портфелю, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],49) / get_value(v-bank,dates[i],33) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

/* потреб.провизии = все провизии - провизии по ЮЛ */
put stream rep unformatted "<tr>" skip "<td>провизиям по потребительским кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],49) / (get_value(v-bank,dates[i],33) - get_value(v-bank,dates[i],147)) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "ПРОСРОЧЕННЫЕ КРЕДИТЫ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=3>Просрочка до 30 дней (включ)</td>" skip
    "<td>Количество кредитов</td>" skip.

do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],77), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],73), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],73) / get_value(v-bank,dates[i],137) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td rowspan=3>Просрочка от 31 до 90 дней (включ)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],78), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],74), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],74) / get_value(v-bank,dates[i],137) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td rowspan=3>Просрочка свыше 90 дней</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],79), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],75), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],75) / get_value(v-bank,dates[i],137) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td colspan=2>Итого, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],137), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td colspan=2>Итого доля просроченных кредитов в портфеле БД, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],137) / get_value(v-bank,dates[i],9) * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=2>Кредиты, по к-рым закончен срок действия договора займа</td>" skip
    "<td>Количество кредитов</td>" skip.

do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],80), "->>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr>" skip "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],76), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.
/*********************************************/

put stream rep unformatted
    "ДОХОДЫ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

put stream rep unformatted "<tr><td colspan=2>Комиссия за выдачу кредитов на дату, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],133), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo1[i] = itogo1[i] + get_value(v-bank,dates[i],133).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Начисленные %% на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],105), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Полученные %% на дату, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],114), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo1[i] = itogo1[i] + get_value(v-bank,dates[i],114).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Учтено %% на счетах VII класса на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],95), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Комиссия за обслуживание кредита на дату, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],134), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo1[i] = itogo1[i] + get_value(v-bank,dates[i],134).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Начисленная пеня на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],123), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Полученная пеня на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],132), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + get_value(v-bank,dates[i],132).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr style=""font:bold""><td colspan=2>Итого на дату, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(itogo1[i], "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
end.
put stream rep unformatted "</tr>" skip.


put stream rep unformatted "<tr><td colspan=2>Комиссия за выдачу кредитов за период, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],133) - get_value(v-bank,dates[i + 1],133), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo2[i] = itogo2[i] + get_value(v-bank,dates[i],133) - get_value(v-bank,dates[i + 1],133).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Начисленные %% за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],105) - get_value(v-bank,dates[i + 1],105), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Полученные %% за период, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],114) - get_value(v-bank,dates[i + 1],114), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo2[i] = itogo2[i] + get_value(v-bank,dates[i],114) - get_value(v-bank,dates[i + 1],114).
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Учтено %% на счетах VII класса за период, KZT</td>" skip.
/*
остаток спис. %% на конец периода - остаток спис. %% на начало периода + погашенные спис. %% за период
*/
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],95) - get_value(v-bank,dates[i + 1],95) + get_value(v-bank,dates[i],143) - get_value(v-bank,dates[i + 1],143), ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Комиссия за обслуживание кредита за период, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],134) - get_value(v-bank,dates[i + 1],134), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
    itogo2[i] = itogo2[i] + get_value(v-bank,dates[i],134) - get_value(v-bank,dates[i + 1],134).
end.
put stream rep unformatted "</tr>" skip.

def var bbpena as deci.
put stream rep unformatted "<tr><td colspan=2>Начисленная пеня за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],123) - get_value(v-bank,dates[i + 1],123), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.


put stream rep unformatted "<tr><td colspan=2>Полученная пеня за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(get_value(v-bank,dates[i],132) - get_value(v-bank,dates[i + 1],132), "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + get_value(v-bank,dates[i],132) - get_value(v-bank,dates[i + 1],132).
end.
put stream rep unformatted "</tr>" skip.


put stream rep unformatted "<tr style=""font:bold""><td colspan=2>Итого за период, KZT</td>" skip.
do i = 1 to 4:
    put stream rep unformatted "<td>" replace(replace(string(itogo2[i], "->>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

hide message no-pause.
put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.
