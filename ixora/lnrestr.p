/* lnrestr.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Реструктуризация экспресс-кредита
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
        14/09/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        15/09/2009 madiyar - s-jh сделал шаренной
        16/09/2009 madiyar - изменил списание штрафов; подправил отчет для сверки графика; исправил расчет процентов
        30/11/2009 madiyar - пропускаем при нулевой ставке комиссии
        11/12/2009 madiyar - не проставлялись новые ставки, исправил
        30/09/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115
*/

{global.i}
{pk.i}
{getdep.i}

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
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

if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
    message skip " Ссудный счет " + pkanketa.lon + " не найден! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first loncon where loncon.lon = lon.lon no-lock no-error.
if not avail loncon then do:
    message skip " Не найдена запись loncon по ссудному счету " + pkanketa.lon + "! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then do:
    message " Не найдена клиентская запись! " view-as alert-box error.
    return.
end.

/* найдем текущий счет (только для upd-dep.i) */
find first aaa where aaa.aaa = lon.aaa no-lock no-error.
if not avail aaa then do:
    message skip " Текущий счет " + lon.aaa + " не найден! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

if lon.plan = 4 then do:
    message " Кредит со схемой 4, реструктуризация невозможна! " view-as alert-box error.
    return.
end.

find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "flagl" and sub-cod.ccode = '01' use-index dcod no-lock no-error.
if avail sub-cod then do:
    message " Начисление процентов выключено! Обратитесь в Кредитное Администрирование. " view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "lnpen" and sub-cod.ccode = '01' use-index dcod no-lock no-error.
if avail sub-cod then do:
    message " Начисление штрафов выключено! Обратитесь в Кредитное Администрирование. " view-as alert-box error.
    return.
end.

/*
if lon.prem = 0 then do:
    message " Процентная ставка = 0! Обратитесь в Кредитное Администрирование. " view-as alert-box error.
    return.
end.
*/

def var v-till as integer no-undo.
v-till = 4.

def new shared temp-table t-lnsch no-undo
  field stdat as date
  field stval as deci
  field pcom as deci
  field odleft as deci
  index idx is primary stdat.

def new shared temp-table t-lnsci no-undo
  field idat as date
  field iv-sc as deci
  index idx is primary idat.

def buffer b-tlnsch for t-lnsch.

def var choice as logi no-undo.
def var ch as logi no-undo.

def var v-dtpog as date no-undo.
def var v-dtpog2 as date no-undo.
def var v-dtpogold as date no-undo.
def new shared var v-perrate1 as deci no-undo.
def new shared var v-perrate2 as deci no-undo.
def var v-com as deci no-undo.
def new shared var v-comrate1 as deci no-undo.
def new shared var v-comrate2 as deci no-undo.

def var v-sumcom1 as deci no-undo.
def var v-sumcom2 as deci no-undo.
def var v-sumcomd as deci no-undo.

def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal4tm as deci no-undo.
def var v-bal5 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal16 as deci no-undo.
def var ost as deci no-undo.
def var stdt as date no-undo.
def var newdt as date no-undo.
def var dat_wrk as date no-undo.
def var mnum as integer no-undo.
def var mnuma as integer no-undo.
def var mnum2 as integer no-undo.
def var mnuma2 as integer no-undo.
def var bil1 as deci no-undo.
def var bil2 as deci no-undo.
def var i as integer no-undo.
def var last_month as integer no-undo.
find last cls where cls.del no-lock no-error.
if avail cls then dat_wrk = cls.whn. else dat_wrk = g-today.

def var dt_lev4 as date no-undo.
def var dt_first as date no-undo.

def var v-rnn as char no-undo.
def var v-name as char no-undo.
v-rnn = cif.jss.
v-name = trim(cif.name).

def var v-rem as char no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def new shared var s-jh as integer.
def var vdel as char no-undo initial "^".
def var rcode as integer no-undo.
def var rdes as char no-undo.
def var v-param as char no-undo.
def var v-code as char no-undo.
def var v-dep as char no-undo.
def buffer bjl for jl.

def var v-pensum as deci no-undo.
def var v-penspis as deci no-undo.

v-dtpog = ?.
find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock no-error.
if avail lnsch then v-dtpog = lnsch.stdat.
else do:
    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > g-today no-lock no-error.
    if avail lnsci then v-dtpog = lnsci.idat.
    else v-dtpog = g-today.
end.
v-dtpogold = v-dtpog.
v-dtpog2 = v-dtpog.

if lon.prem > 0 then v-perrate1 = lon.prem.
else do:
    if lon.prem1 > 0 then do:
        choice = no.
        message "По данному кредиту начисление %% производится внесистемно.~nПосле реструктуризации начисление %% будет производиться в баланс.~nПродолжить?" view-as alert-box question buttons yes-no title "" update choice.
        if choice then v-perrate1 = lon.prem1.
        else return.
    end.
    else do:
        message "Процентные ставки по балансовым и внесистемным процентам = 0!~nОбратитесь в Деп-т Кредитного Администрирования." view-as alert-box error.
        return.
    end.
end.

if loncon.sods1 = 0 and loncon.sods2 = 0 then do:
    message "Ставки по балансовым и внесистемным штрафам = 0!~nОбратитесь в Деп-т Кредитного Администрирования." view-as alert-box error.
    return.
end.

/*v-perrate1 = pkanketa.rateq.*/
v-perrate2 = v-perrate1.

v-com = 0. v-comrate1 = 0. v-comrate2 = 0.
find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-com = tarifex2.ost.

if v-com > 0 then v-comrate1 = round(v-com / lon.opnamt * 100,2).
else do:
  v-comrate1 = 0.
  /*  message " Ошибка определения ставки по комиссии! " view-as alert-box error.
    return.*/
end.

v-comrate2 = v-comrate1.

update v-dtpog format "99/99/9999" label " Дата погашения ОД" validate(can-find(lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-dtpog no-lock),'Нет записи в графике погашения ОД с такой датой!') skip
       v-dtpog2 format "99/99/9999" label " Дата погашения %%" validate(can-find(lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-dtpog2 no-lock),'Нет записи в графике погашения %% с такой датой!') skip
       v-perrate2 format ">9.99" label " Ставка по вознагр. (%)" validate(v-perrate2 > 0,'Некорректное значение!') skip
       v-comrate2 format ">9.99" label " Ставка по комиссии (%)" /*validate(v-comrate2 > 0,'Некорректное значение!')*/
       with row 15 centered side-labels frame frdt.

hide frame frdt.

v-sumcom1 = round(lon.opnamt * v-comrate1 / 100,2).
v-sumcom2 = round(lon.opnamt * v-comrate2 / 100,2).

v-sumcomd = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.type = '195' and bxcif.crc = lon.crc no-lock:
    v-sumcomd = v-sumcomd + bxcif.amount.
end.

empty temp-table t-lnsch.
empty temp-table t-lnsci.
/* копия графика ОД */
for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
    create t-lnsch.
    t-lnsch.stdat = lnsch.stdat.
    t-lnsch.stval = lnsch.stval.
end.

/* добавим в графики суммы по комиссии */
for each t-lnsch no-lock:
    ch = no.
    if day(t-lnsch.stdat) > v-till then ch = yes.
    else do:
        find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
        if (not avail b-tlnsch) or (day(b-tlnsch.stdat) <> day(t-lnsch.stdat)) then ch = yes.
        else do:
            find first b-tlnsch where b-tlnsch.stdat > t-lnsch.stdat no-lock no-error.
            if (not avail b-tlnsch) or (day(b-tlnsch.stdat) <> day(t-lnsch.stdat)) then ch = yes.
        end.
    end.
    if ch then do:
        if t-lnsch.stdat <= dat_wrk then t-lnsch.pcom = v-sumcom1.
        else t-lnsch.pcom = v-sumcom2.
    end.
end.

/* копия графика %% */
for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock:
    create t-lnsci.
    t-lnsci.idat = lnsci.idat.
    t-lnsci.iv-sc = lnsci.iv-sc.
end.

run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).
run lonbalcrc('lon',lon.lon,g-today,"5",yes,1,output v-bal5).
run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).
run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-bal16).

v-bal4tm = 0.
if v-bal4 > 0 then do:
    dt_lev4 = ?.
    find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock no-error.
    if avail lnsci then dt_lev4 = lnsci.idat.
    else dt_lev4 = lon.rdt.
    run day-360(dt_lev4,g-today - 1,lon.basedy,output dn1,output dn2).
    v-bal4tm = round(dn1 * lon.opnamt * v-perrate1 / 100 / 360,2). /* эта сумма уже учтена в следующей записи по графику */

    /*
    run lonbalcrc('lon',lon.lon,dt_lev4,"4",no,lon.crc,output v-bal4tm).
    v-bal4tm = v-bal4 - v-bal4tm. -- непросроченные внебалансовые %% - эта сумма уже учтена в следующей записи по графику --
    */
    if v-bal4tm < 0 then v-bal4tm = 0.
    if v-bal4tm > v-bal4 then v-bal4tm = v-bal4.
end.

if v-bal7 > 0 then do:
    ost = 0.
    for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk no-lock:
        ost = ost + lnsch.stval.
    end.
    if ost < v-bal7 then do:
        message " Нехватка суммы в прошлых платежах по графику ОД для отсрочки просроченного ОД! " view-as alert-box error.
        return.
    end.
end.
if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
    /*message " lev9+4-4tm " view-as alert-box.*/
    ost = 0.
    for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock:
        ost = ost + lnsci.iv-sc.
    end.
    if ost < v-bal9 + v-bal4 - v-bal4tm then do:
        message " Нехватка суммы в прошлых платежах по графику %% для отсрочки просроченных %%! " view-as alert-box error.
        return.
    end.
end.

/* изменение графика ОД */
if v-bal7 > 0 then do:
    /*message " lev7 ... 2 " view-as alert-box.*/
    ost = v-bal7.
    repeat:
        find last t-lnsch where t-lnsch.stdat <= dat_wrk and t-lnsch.stval > 0 no-error.
        /*message "1.... " + string(lnsch.stdat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsch.stval=" + trim(string(lnsch.stval,">>>,>>>,>>9.99")) view-as alert-box.*/
        if t-lnsch.stval > ost then do:
            t-lnsch.stval = t-lnsch.stval - ost.
            ost = 0.
        end.
        else do:
            ost = ost - t-lnsch.stval.
            t-lnsch.stval = 0.
        end.
        if ost = 0 then leave.
    end. /* repeat */
end.

/* изменение графика %% */
if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
    /*message " lev9+4-4tm ... 2 " view-as alert-box.*/
    ost = v-bal9 + v-bal4 - v-bal4tm.
    repeat:
        find last t-lnsci where t-lnsci.idat <= dat_wrk and t-lnsci.iv-sc > 0 no-error.
        /*message "1.... " + string(lnsci.idat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsci.iv-sc=" + trim(string(lnsci.iv-sc,">>>,>>>,>>9.99")) view-as alert-box.*/
        if t-lnsci.iv-sc > ost then do:
            t-lnsci.iv-sc = t-lnsci.iv-sc - ost.
            ost = 0.
        end.
        else do:
            ost = ost - t-lnsci.iv-sc.
            t-lnsci.iv-sc = 0.
        end.
        if ost = 0 then leave.
    end. /* repeat */
end.

last_month = 0.
find last t-lnsch no-lock no-error.
find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
if avail t-lnsch and avail b-tlnsch then last_month = t-lnsch.stdat - b-tlnsch.stdat.

/*message " last_month=" + string(last_month,">>>,>>>,>>9") view-as alert-box.*/

/* запоминаем дату первого платежа по графику */
dt_first = ?.
find first t-lnsch no-lock no-error.
if avail t-lnsch then dt_first = t-lnsch.stdat.

/*message " dt_first=" + string(dt_first,"99/99/9999") view-as alert-box.*/

/* удаляем все следующие графики */
for each t-lnsch where t-lnsch.stdat > dat_wrk:
    delete t-lnsch.
end.
for each t-lnsci where t-lnsci.idat > dat_wrk:
    delete t-lnsci.
end.

/* строим новые графики */
stdt = ?.
if day(v-dtpog) > day(dat_wrk) then stdt = date(month(dat_wrk),day(v-dtpog),year(dat_wrk)).
else do:
    newdt = get-date(dat_wrk,1).
    stdt = date(month(newdt),day(v-dtpog),year(newdt)).
end.

/*message " stdt=" + string(stdt,"99/99/9999") view-as alert-box.*/

mnum = 0.
mnuma = 0.
mnuma2 = 0.
if stdt <> ? then newdt = stdt.
else newdt = dt_first.
repeat:
    if newdt > lon.duedt then newdt = lon.duedt.
    else
    if lon.duedt - stdt <= last_month then newdt = lon.duedt.
    /*
    message " newdt=" + string(newdt,"99/99/9999") + '~n'
            " mnum=" + string(mnum) + '~n'
            " mnuma=" + string(mnuma) + '~n'
            " mnuma2=" + string(mnuma2)
            view-as alert-box.
    */
    create t-lnsch.
    t-lnsch.stdat = newdt.
    t-lnsch.pcom = v-sumcom2.
    create t-lnsci.
    t-lnsci.idat = newdt.
    mnum = mnum + 1.
    if newdt >= v-dtpog then mnuma = mnuma + 1.
    if newdt >= v-dtpog2 then mnuma2 = mnuma2 + 1.
    stdt = newdt.
    if stdt = lon.duedt then leave.
    newdt = get-date(stdt,1).
end.

/*message "1111.... mnum=" + string(mnum,">>9") + " mnuma=" + string(mnuma,">>9") + " mnuma2=" + string(mnuma2,">>9") view-as alert-box.*/

stdt = dat_wrk.
bil1 = truncate((v-bal1 + v-bal7) / mnuma,0).
run day-360(g-today,lon.duedt - 1,360,output dn1,output dn2).
ost = round(dn1 * lon.opnamt * v-perrate2 / 36000,2).
bil2 = truncate((v-bal2 + v-bal4 + v-bal9 + ost) / mnuma2,0).

/*message "2222.... bil1=" + trim(string(bil1,">>>,>>>,>>9.99")) + " dn1=" + string(dn1,">,>>9") + " ost=" + trim(string(ost,">>>,>>>,>>9.99"))  + " bil2=" + trim(string(bil2,">>>,>>>,>>9.99")) view-as alert-box.*/

do i = 1 to mnum:
    find first t-lnsch where t-lnsch.stdat > stdt no-error.
    if avail t-lnsch then do:
        if t-lnsch.stdat >= v-dtpog then do:
            t-lnsch.stval = bil1.
            if i = mnum then t-lnsch.stval = v-bal1 + v-bal7 - bil1 * (mnuma - 1).
        end.
    end.
    find first t-lnsci where t-lnsci.idat = t-lnsch.stdat no-error.
    if avail t-lnsci then do:
        if t-lnsci.idat >= v-dtpog2 then do:
            t-lnsci.iv-sc = bil2.
            if i = mnum then t-lnsci.iv-sc = v-bal2 + v-bal4 + v-bal9 + ost - bil2 * (mnuma2 - 1).
        end.
    end.
    stdt = t-lnsch.stdat.
end.

/* выведем график для проверки правильности реструктуризации */
def stream rep.
output stream rep to rep.htm.
put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find first crc where crc.crc = lon.crc no-lock no-error.
put stream rep unformatted
    "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
    "Ссудный счет: " lon.lon "<BR>" skip
    "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.

put stream rep unformatted
    "<h2>График погашения основного долга</h2>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td width=30>N</td>" skip
    "<td width=100>Дата</td>" skip
    "<td width=100>Сумма</td>" skip
    "<td width=100>Сумма комиссии</td>" skip
    "</tr>" skip.

i = 1.
for each t-lnsch no-lock:
    put stream rep unformatted
             "<tr>" skip
             "<td align=""center"">" i "</td>" skip
             "<td align=""center"">" t-lnsch.stdat "</td>" skip
             "<td align=""right"">" replace(trim(string(t-lnsch.stval,">>>>>>>>9.99")),'.',',') "</td>" skip
             "<td align=""right"">" replace(trim(string(t-lnsch.pcom,">>>>>>>>9.99")),'.',',') "</td>" skip
             "</tr>" skip.
    i = i + 1.
end.
put stream rep unformatted "</table><BR><BR>" skip.

put stream rep unformatted
    "<h2>График погашения процентов</h2>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td width=30>N</td>" skip
    "<td width=100>Дата</td>" skip
    "<td width=100>Сумма</td>" skip
    "</tr>" skip.

i = 1.
for each t-lnsci no-lock:
    put stream rep unformatted
             "<tr>" skip
             "<td align=""center"">" i "</td>" skip
             "<td align=""center"">" t-lnsci.idat "</td>" skip
             "<td align=""right"">" replace(trim(string(t-lnsci.iv-sc,">>>>>>>>9.99")),'.',',') "</td>" skip
             "</tr>" skip.
    i = i + 1.
end.
put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.

/* дорисуем в график долг по комиссии */
if v-sumcomd > 0 then do:
    find first t-lnsch where t-lnsch.stdat > dat_wrk no-error.
    if avail t-lnsch then t-lnsch.pcom = t-lnsch.pcom + v-sumcomd.
end.

/* дорисуем в графики остаток ОД */
ost = v-bal1 + v-bal7.
for each t-lnsch where t-lnsch.stdat > dat_wrk:
    ost = ost - t-lnsch.stval.
    t-lnsch.odleft = ost.
end.

run lnrdop.

choice = no.
message "Проверьте доп. соглашение.~nПровести реструктуризацию?" view-as alert-box question buttons yes-no title "" update choice.

if choice then do:
    if lon.prem > 0 then do:
        /* если поменяли процентную ставку */
        if v-perrate1 <> v-perrate2 then do transaction:
            find current lon exclusive-lock.
            lon.prem = v-perrate2.
            lon.prem1 = 0.
            find current lon no-lock.
            find last ln%his where ln%his.lon = lon.lon no-lock no-error.
            if avail ln%his then i = ln%his.f0.
            else i = 0.
            create ln%his.
            assign ln%his.lon = lon.lon
                   ln%his.stdat = g-today
                   ln%his.intrate = v-perrate2
                   ln%his.rem = 'изменение % ставки - реструктуризация'
                   ln%his.opnamt = lon.opnamt
                   ln%his.rdt = lon.rdt
                   ln%his.cif = lon.cif
                   ln%his.duedt = lon.duedt
                   ln%his.who = g-ofc
                   ln%his.whn = today
                   ln%his.f0 = i + 1.
        end. /* if v-perrate1 <> v-perrate2 */
    end. /* if lon.prem <= 0 */
    else
    /* если надо - восстанавливаем процентную ставку */
    do transaction:
        find current lon exclusive-lock.
        lon.prem = v-perrate2.
        lon.prem1 = 0.
        find current lon no-lock.
        find last ln%his where ln%his.lon = lon.lon no-lock no-error.
        if avail ln%his then i = ln%his.f0.
        else i = 0.
        create ln%his.
        assign ln%his.lon = lon.lon
               ln%his.stdat = g-today
               ln%his.intrate = v-perrate2
               ln%his.rem = 'восстановление - реструктуризация'
               ln%his.opnamt = lon.opnamt
               ln%his.rdt = lon.rdt
               ln%his.cif = lon.cif
               ln%his.duedt = lon.duedt
               ln%his.who = g-ofc
               ln%his.whn = today
               ln%his.f0 = i + 1.
    end. /* if lon.prem <= 0 */

    /* если надо - восстанавливаем ставку по штрафам */
    if loncon.sods1 <= 0 then do transaction:
        find current loncon exclusive-lock.
        loncon.sods1 = loncon.sods2.
        loncon.sods2 = 0.
        find current loncon no-lock.
        find last ln%his where ln%his.lon = lon.lon no-lock no-error.
        if avail ln%his then i = ln%his.f0.
        else i = 0.
        create ln%his.
        assign ln%his.lon = lon.lon
               ln%his.stdat = g-today
               ln%his.intrate = v-perrate2
               ln%his.pnlt1 = loncon.sods1
               ln%his.rem = 'восстановление - реструктуризация'
               ln%his.opnamt = lon.opnamt
               ln%his.rdt = lon.rdt
               ln%his.cif = lon.cif
               ln%his.duedt = lon.duedt
               ln%his.who = g-ofc
               ln%his.whn = today
               ln%his.f0 = i + 1.
    end. /* if loncon.sods1 <= 0 */

    /* если надо, поменяем сумму комиссии за обслуживание кредита */
    if v-comrate1 <> v-comrate2 then do transaction:
        find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' exclusive-lock no-error.
        if avail tarifex2 then do:
            tarifex2.ost = v-sumcom2.
            find current tarifex2 no-lock.
        end.
    end.

    /* изменяем графики */
    do transaction:
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 exclusive-lock:
            delete lnsch.
        end.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 exclusive-lock:
            delete lnsci.
        end.
        for each t-lnsch no-lock:
            create lnsch.
            assign lnsch.lnn = lon.lon
                   lnsch.stdat = t-lnsch.stdat
                   lnsch.f0 = 1
                   lnsch.stval = t-lnsch.stval.
        end.
        for each t-lnsci no-lock:
            create lnsci.
            assign lnsci.lni = lon.lon
                   lnsci.idat = t-lnsci.idat
                   lnsci.f0 = 1
                   lnsci.iv-sc = t-lnsci.iv-sc.
        end.
    end.
    run lnsch-ren(lon.lon).
    release lnsch.
    run lnsci-ren(lon.lon).
    release lnsci.

    /* переносим проценты с 4-го на второй */
    if v-bal4 > 0 then do:
        v-rem = "Реструкт. Перенос %% из начисленных вне баланса в начисленные, " + v-rnn + " " + v-name.
        /*v-param = string(v-bal4) + vdel + lon.lon + vdel + v-rem + vdel + string(v-bal4).*/
       if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel +
              v-rem + vdel + "0" + vdel + string(v-bal4) + vdel + lon.lon + vdel +
              v-rem + vdel + string(v-bal4).
       else v-param = string(v-bal4) + vdel + lon.lon + vdel +
              v-rem + vdel + string(v-bal4) + vdel + "0" + vdel + lon.lon + vdel +
              v-rem + vdel + "0".
        s-jh = 0.
        run trxgen ("lon0115", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        {upd-dep.i}
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal4 > 0 */

    choice = yes.
    v-pensum = v-bal5 + v-bal16.
    if v-pensum > 0 then do:
        message "Списать штрафы?" view-as alert-box question buttons yes-no title "Списание штрафов" update choice.
        if choice then do:

            displ v-bal5 format ">>>,>>>,>>9.99" label " Внесистемная пеня (уровень 5)" skip
                  v-bal16 format ">>>,>>>,>>9.99" label " Балансовая пеня (уровень 16)" skip
                  v-pensum format ">>>,>>>,>>9.99" label " Списать" validate(v-pensum >= 0,'Некорректное значение!')
            with row 15 centered side-labels frame frpen.

            update v-pensum with frame frpen.
            hide frame frpen.

            if v-pensum > 0 then do:
                /* списываем 5-ый */
                if v-bal5 > 0 then do:
                    if v-pensum > v-bal5 then assign v-penspis = v-bal5 v-pensum = v-pensum - v-bal5.
                    else assign v-penspis = v-pensum v-pensum = 0.
                    v-rem = "Реструкт. Списание внебалансовых штрафов, " + v-rnn + " " + v-name.
                    v-param = string(v-penspis) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
                    s-jh = 0.
                    run trxgen ("lon0116", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                    end.
                    run lonresadd(s-jh).
                    run vou_bank(1).
                end. /* if v-bal5 > 0 */
                if v-pensum > 0 then do:
                    /* списываем 16-ый */
                    if v-bal16 > 0 then do:
                        if v-pensum > v-bal16 then assign v-penspis = v-bal16 v-pensum = v-pensum - v-bal16.
                        else assign v-penspis = v-pensum v-pensum = 0.
                        v-rem = "Реструкт. Списание штрафов, " + v-rnn + " " + v-name.
                        v-param = string(v-penspis) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
                        s-jh = 0.
                        run trxgen ("lon0063", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 1000.
                            next.
                        end.
                        run lonresadd(s-jh).
                        run vou_bank(1).
                    end. /* if v-bal16 > 0 */
                end. /* if v-pensum > 0 */
            end. /* if v-pensum > 0 */
        end.
    end. /* if v-pensum > 0 */

    /* переносим ОД с 7-го на 1-ый */
    if v-bal7 > 0 then do:
        v-rem = "Реструкт. Перенос ОД 7ур.->1ур., " + v-rnn + " " + v-name.
        v-param = string(v-bal7) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel + vdel + "490".
        s-jh = 0.
        run trxgen ("lon0023", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal7 > 0 */

    /* переносим %% с 9-го на 2-ой */
    if v-bal9 > 0 then do:
        /*v-rem = "Реструкт. Перенос %% 9ур.->2ур.".*/
        v-param = string(v-bal9) + vdel + lon.lon.
        s-jh = 0.
        run trxgen ("lon0065", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal9 > 0 */

    /* проставление признака реструктуризации */
    run day-360(v-dtpogold,v-dtpog - 1,360,output dn1,output dn2).

    do transaction:
        find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkrst' use-index dcod exclusive-lock no-error.
        if not avail sub-cod then do:
            create sub-cod.
            assign sub-cod.acc = lon.lon
                   sub-cod.sub = 'LON'
                   sub-cod.d-cod = 'pkrst'
                   sub-cod.ccod = 'msc'.
        end.
        if sub-cod.ccod <> 'msc' then sub-cod.ccod = '04'.
        else do:
            if dn1 / 30 - truncate(dn1 / 30,4) = 0 then sub-cod.ccod = string(dn1 / 30,'99').
            else do:
                find first codfr where codfr.codfr = "pkrst" and codfr.code = string(round(dn1 / 30,0),'99') no-lock no-error.
                if avail codfr then sub-cod.ccod = string(round(dn1 / 30,0),'99').
            end.
        end.
    end.

end.
