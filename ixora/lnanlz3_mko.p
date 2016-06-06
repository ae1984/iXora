/* lnanlz3_mko.p
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
        01/04/2008 madiyar - скопировал из lnanlz3 с изменениями
 * BASES
        BANK COMM
 * CHANGES
        10/09/2008 madiyar - разбранчевка для МКО
*/  

{mainhead.i}

{pk0.i}

define new shared var krport as deci no-undo extent 4.
define new shared var krportp as deci no-undo extent 4.
define new shared var krprov as deci no-undo extent 4.
define new shared var krprovp as deci no-undo extent 4.
define new shared var dates as date no-undo extent 4.

def var crcusd as deci no-undo.
def var crceur as deci no-undo.
def var crccur as deci no-undo.
/*
def var comm_prov as deci extent 5.
def var share_pr as deci extent 5.
def var fact_prov as deci extent 15.
*/
def var i as integer no-undo.
def var d1 as date no-undo.
def var coun as int no-undo init 1.
def var cnt as decimal no-undo extent 9.
def var v-cif like bank.lon.cif no-undo.
def var sumk as decimal no-undo extent 30.
def new shared var suma as decimal no-undo.
define var dat2 as date no-undo.
define var dat3 as date no-undo.
define var v-dat4 as date no-undo.

def var prc as decimal no-undo extent 5.
def var srk as decimal no-undo extent 30.
def var vsrk as decimal no-undo init 0.

def var svald as decimal no-undo.
def var svalt as decimal no-undo.
def var svale as decimal no-undo.
def var v-rate as decimal no-undo.
def var v-ourbank as char no-undo.
def var komiss as deci no-undo.
def var itogo1 as deci no-undo extent 4.
def var itogo2 as deci no-undo extent 4.

def buffer b-crchis for bank.crchis.

/* текущий вид кредита */
/*
define new shared var s-credtype as char no-undo.
{pk-sysc.i}
*/

prc[1] = 0. prc[2] = 0. prc[5] = 0.

def new shared temp-table wrk no-undo
    field bank   as char
    field datot  like bank.lon.rdt
    field cif    like bank.lon.cif
    field lon    like bank.lon.lon
    field name   like bank.cif.name
    field plan   like bank.lon.plan
    field sts    as   char
    field grp    like bank.lon.grp
    field amoun  as decimal 
    field balans as decimal 
    field balans1 as decimal 
    field balans2 as decimal 
    field balans3 as decimal 
    field crc    as integer
    field prem   as decimal 
    field proc   as decimal 
    field duedt  as date
    field rez    as decimal 
    field rez1   as decimal 
    field rez2   as decimal 
    field srez   as decimal 
    field peni   as decimal 
    field penires  as decimal 
    field daymax as inte
    field zalog  as decimal 
    field srok   as deci
    index main is primary datot desc bank cif lon.

def new shared temp-table wrkrep no-undo
    field m-table as integer
    field m-row as integer
    field m-values as deci extent 4
    index ind is primary m-table m-row.

do i = 1 to 4: create wrkrep. wrkrep.m-table = 1. wrkrep.m-row = i. end.
do i = 1 to 4: create wrkrep. wrkrep.m-table = 2. wrkrep.m-row = i. end.
do i = 1 to 8: create wrkrep. wrkrep.m-table = 3. wrkrep.m-row = i. end.
do i = 1 to 6: create wrkrep. wrkrep.m-table = 4. wrkrep.m-row = i. end.
do i = 1 to 6: create wrkrep. wrkrep.m-table = 5. wrkrep.m-row = i. end.
do i = 1 to 2: create wrkrep. wrkrep.m-table = 6. wrkrep.m-row = i. end.
do i = 1 to 22: create wrkrep. wrkrep.m-table = 7. wrkrep.m-row = i. end.

def buffer b-wrkrep for wrkrep.

d1 = g-today.
update d1 label " Укажите дату" format "99/99/9999"  
                  skip with side-label row 5 centered frame dat .

def var b-dat as date no-undo.
def var vmonth as integer no-undo.
def var vyear as integer no-undo.
b-dat = d1.
dates[1] = d1.
do i = 2 to 4:
  if i = 4 then do:
    if day(b-dat) = 1 and month(b-dat) = 1 then b-dat = date(1,1,year(b-dat) - 1).
    else b-dat = date(1,1,year(b-dat)).
  end.
  else do:
    vmonth = month(b-dat) - 1.
    vyear = year(b-dat).
    if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
    b-dat = date(vmonth, 1, vyear).
  end.
  dates[i] = b-dat.
end.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    if lookup(comm.txb.bank,"txb16,txb01,txb02,txb04,txb06") > 0 then do:
        connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
        run lnanlz4_mko.
    end.
end.
if connected ("txb") then disconnect "txb".


define stream rep.

i = 1.

for each wrk where break by wrk.datot desc.
  
  if first-of(wrk.datot) then do:
    find last crchis where crchis.crc = 2 and crchis.regdt < wrk.datot no-lock no-error.
    crcusd = crchis.rate[1].
    find last crchis where crchis.crc = 3 and crchis.regdt < wrk.datot no-lock no-error.
    crceur = crchis.rate[1].
  end.
  
  if wrk.lon <> "" then do:
    
    if wrk.cif <> v-cif and (wrk.grp = 90 or wrk.grp = 92) then do:
        find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 1.
        wrkrep.m-values[i] = wrkrep.m-values[i] + 1. /* кол-во заемщиков */
    end.
    v-cif = wrk.cif.
    
    find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 2.
    wrkrep.m-values[i] = wrkrep.m-values[i] + 1. /* кол-во кредитов */
    
    if wrk.crc = 1 then crccur = 1.
    if wrk.crc = 2 then crccur = crcusd.
    if wrk.crc = 3 then crccur = crceur.
    
    find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 3.
    wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.balans * crccur. /* портфель в тенге */
    
    if wrk.rez1 = 5 then do:
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 1.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 2.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.srez.
    end.
    if wrk.rez1 = 50 then do:
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 3.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 4.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.srez.
    end.
    if wrk.rez1 = 100 then do:
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 5.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 6.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.srez.
    end.
    
    if wrk.daymax > 0 and wrk.daymax <= 30 then do:
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 1.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 2.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.balans * crccur.
    end.
    if wrk.daymax > 30 and wrk.daymax <= 90 then do:
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 3.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 4.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.balans * crccur.
    end.
    if wrk.daymax > 90 then do:
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 5.
      wrkrep.m-values[i] = wrkrep.m-values[i] + 1.
      find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 6.
      wrkrep.m-values[i] = wrkrep.m-values[i] + wrk.balans * crccur.
    end.
    
  end. /* if wrk.lon <> "" */
  
  if last-of(wrk.datot) then do:
    find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 3.
    find b-wrkrep where b-wrkrep.m-table = 1 and b-wrkrep.m-row = 4.
    b-wrkrep.m-values[i] = wrkrep.m-values[i] / crcusd. /* портфель в USD */
    i = i + 1.
  end.

end. /* for each wrk */


output stream rep to rpt.htm.
put stream rep "<html><head><title>TEXAKABANK</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Анализ программы БЫСТРЫЕ ДЕНЬГИ на " d1 format "99/99/9999" "<BR>" skip
    "Консолидированный</b><BR><BR>" skip
    "ДИНАМИКА РОСТА КРЕДИТНОГО ПОРТФЕЛЯ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td colspan=2></td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" dates[i] format "99/99/9999" "</td>" skip. end.
put stream rep unformatted
    "</tr>" skip
    "<tr>" skip
    "<td rowspan=4>Кредитный портфель</td>" skip
    "<td>Количество заемщиков</td>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 1 no-lock.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<td>Сумма, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<td>Сумма, USD</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted
       "<td rowspan=2>Удельный вес к:</td>" skip
       "<td>общему ссудному портфелю, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / krport[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>портфелю потребительских кредитов, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / krportp[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr></table><BR><BR>" skip.

/**********************************************/

put stream rep unformatted
    "ДИНАМИКА РОСТА ВЫДАННЫХ КРЕДИТОВ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 1 no-lock.
put stream rep unformatted "<tr><td colspan=2>Количество выданных кредитов на дату</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<tr><td colspan=2>Количество выданных кредитов за период</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<tr><td colspan=2>Объем выданных кредитов на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 2 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<tr><td colspan=2>Объем выданных кредитов за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.
put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "ДИНАМИКА РОСТА ПОГАШЕННЫХ КРЕДИТОВ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 1 no-lock.
put stream rep unformatted "<tr><td colspan=2>Количество погашенных кредитов на дату</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<tr><td colspan=2>Количество погашенных кредитов за период</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 5 no-lock.
put stream rep unformatted "<tr><td colspan=2>Объем погашенных кредитов на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 6 no-lock.
put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 7 no-lock.
put stream rep unformatted "<tr><td colspan=2>Объем погашенных кредитов за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 3 and wrkrep.m-row = 8 no-lock.
put stream rep unformatted "<tr><td colspan=2>из них учтено на счетах VII класса</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.
put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

def var t-prov as deci no-undo extent 4.
t-prov = 0.
find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 2 no-lock.
do i = 1 to 4: t-prov[i] = t-prov[i] + wrkrep.m-values[i]. end.
find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 4 no-lock.
do i = 1 to 4: t-prov[i] = t-prov[i] + wrkrep.m-values[i]. end.
find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 6 no-lock.
do i = 1 to 4: t-prov[i] = t-prov[i] + wrkrep.m-values[i]. end.

put stream rep unformatted
    "СФОРМИРОВАННЫЕ ПРОВИЗИИ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=3>Сомнительные 1 категории (5%)</td>" skip
    "<td>Количество кредитов</td>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 1 no-lock.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prov[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<td rowspan=3>Сомнительные 5 категории (50%)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prov[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 5 no-lock.
put stream rep unformatted "<td rowspan=3>Безнадежные (100%)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 4 and wrkrep.m-row = 6 no-lock.
put stream rep unformatted "<td>Сумма провизий, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к провизиям, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prov[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td colspan=2>Итого, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prov[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted
       "<td rowspan=2>Удельный вес к:</td>" skip
       "<td>провизиям по общему ссудному портфелю, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prov[i] / krprov[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>провизиям по потребительским кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prov[i] / krprovp[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr></table><BR><BR>" skip.

/*********************************************/

def var t-prosr as deci no-undo extent 4.
t-prosr = 0.
find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 2 no-lock.
do i = 1 to 4: t-prosr[i] = t-prosr[i] + wrkrep.m-values[i]. end.
find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 4 no-lock.
do i = 1 to 4: t-prosr[i] = t-prosr[i] + wrkrep.m-values[i]. end.
find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 6 no-lock.
do i = 1 to 4: t-prosr[i] = t-prosr[i] + wrkrep.m-values[i]. end.

put stream rep unformatted
    "ПРОСРОЧЕННЫЕ КРЕДИТЫ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=3>Просрочка до 30 дней (включ)</td>" skip
    "<td>Количество кредитов</td>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 1 no-lock.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prosr[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<td rowspan=3>Просрочка от 31 до 90 дней (включ)</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prosr[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 5 no-lock.
put stream rep unformatted "<td rowspan=3>Просрочка свыше 90 дней</td>" skip
           "<td>Количество кредитов</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 5 and wrkrep.m-row = 6 no-lock.
put stream rep unformatted "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>Удельный вес к проср. кредитам, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] / t-prosr[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td colspan=2>Итого, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prosr[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 1 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<td colspan=2>Итого доля просроченных кредитов в портфеле БД, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prosr[i] / wrkrep.m-values[i] * 100, ">>9.99"),","," "),".",",") "</td>". end.
/*put stream rep unformatted "</tr>" skip "<tr>" skip.


put stream rep unformatted
       "<td rowspan=2>Удельный вес к:</td>" skip
       "<td>общей сумме просроченных кредитов, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prosr[i] / ???? * 100, ">>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

put stream rep unformatted "<td>сумме просроченных потребительских кредитов, %</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(t-prosr[i] / ???? * 100, ">>9.99"),","," "),".",",") "</td>". end.*/
put stream rep unformatted "</tr></table><BR><BR>" skip.

/*********************************************/

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<td rowspan=2>Кредиты, по к-рым закончен срок действия договора займа</td>" skip
    "<td>Количество кредитов</td>" skip.

find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 1 no-lock.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip "<tr>" skip.

find wrkrep where wrkrep.m-table = 6 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<td>Сумма долга, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr></table><BR><BR>" skip.

/*********************************************/

itogo1 = 0. itogo2 = 0.

put stream rep unformatted
    "ДОХОДЫ<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.    

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 1 no-lock.
put stream rep unformatted "<tr><td colspan=2>Фонд покрытия кредитных рисков на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 2 no-lock.
put stream rep unformatted "<tr><td colspan=2>Фонд покрытия кредитных рисков за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

/*
find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 3 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за выдачу на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 4 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за выдачу за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 5 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за рассмотрение заявки на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 6 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за рассмотрение заявки за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.
*/


find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 7 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за обслуживание кредита на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 8 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за обслуживание кредита за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

/*
find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 9 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за обналичивание денежных средств с тек. счета на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 10 no-lock.
put stream rep unformatted "<tr><td colspan=2>Комиссия за обналичивание денежных средств с тек. счета за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.
*/

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 11 no-lock.
put stream rep unformatted "<tr><td colspan=2>Начисленные %% на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 12 no-lock.
put stream rep unformatted "<tr><td colspan=2>Начисленные %% за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 13 no-lock.
put stream rep unformatted "<tr><td colspan=2>Полученные %% на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 14 no-lock.
put stream rep unformatted "<tr><td colspan=2>Полученные %% за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 15 no-lock.
put stream rep unformatted "<tr><td colspan=2>Учтено %% на счетах VII класса на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 16 no-lock.
put stream rep unformatted "<tr><td colspan=2>Учтено %% на счетах VII класса за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 17 no-lock.
put stream rep unformatted "<tr><td colspan=2>Начисленная пеня на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

/*find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 18 no-lock.*/
def var bbpena as deci.
put stream rep unformatted "<tr><td colspan=2>Начисленная пеня за период, KZT</td>" skip.
do i = 1 to 4:
  if i <> 4 then put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i] - wrkrep.m-values[i + 1], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  else put stream rep unformatted "<td>&nbsp;-</td>".
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 19 no-lock.
put stream rep unformatted "<tr><td colspan=2>Полученная пеня на дату, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo1[i] = itogo1[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 20 no-lock.
put stream rep unformatted "<tr><td colspan=2>Полученная пеня за период, KZT</td>" skip.
do i = 1 to 4:
  put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>".
  itogo2[i] = itogo2[i] + wrkrep.m-values[i].
end.
put stream rep unformatted "</tr>" skip.

/*
find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 21 no-lock.
put stream rep unformatted "<tr><td colspan=2>Учтено штрафов на счетах VII класса на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

find wrkrep where wrkrep.m-table = 7 and wrkrep.m-row = 22 no-lock.
put stream rep unformatted "<tr><td colspan=2>Учтено штрафов на счетах VII класса за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(wrkrep.m-values[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.
*/

put stream rep unformatted "<tr><td colspan=2>Итого на дату, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(itogo1[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "<tr><td colspan=2>Итого за период, KZT</td>" skip.
do i = 1 to 4: put stream rep unformatted "<td>" replace(replace(string(itogo2[i], ">>>,>>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>". end.
put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table><BR><BR>" skip.

/*********************************************/

hide message no-pause.
put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.



