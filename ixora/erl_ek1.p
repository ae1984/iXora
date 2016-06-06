/* erl_ek1.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Расчет эффективной ставки, формирование графика погашения
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def stream m-out.

def input parameter v-sum    as deci no-undo.
def input parameter v-srok   as inte no-undo.
def input parameter v-rate   as deci no-undo.
def input parameter v-gr     as inte no-undo.
def input parameter v-rdt    as date no-undo.
def input parameter v-pdt    as date no-undo.
def input parameter v-pdtprc as date no-undo.
def input parameter v-pdtod  as date no-undo.
def input parameter v-kom1   as deci no-undo.
def input parameter v-komy   as deci no-undo.
def input parameter v-komob  as deci no-undo.
def input parameter v-sumd   as deci no-undo.
def input parameter v-rated  as deci no-undo.
def input parameter v-var    as logi no-undo.

def output parameter v-er    as deci no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

def var v-dt  as date no-undo.
def var v-dt0 as date no-undo.
def var v-dt1 as date no-undo.
def var v-dt0_prc as date no-undo.
def var v-prc as deci no-undo.
def var i     as integer no-undo.
def var coun  as integer no-undo.
def var v-ok  as logical no-undo.

def var v-mpayment    as deci no-undo.
def var v-mpayment_od as deci no-undo.
def var v-cpayment_od as deci no-undo.
def var v-sum0        as deci no-undo.

def var sumod  as deci no-undo.
def var sum%   as deci no-undo.
def var platej as deci no-undo.

def temp-table tmp
field t-day  as date
field credb  as deci
field platej as deci format '>>>,>>>,>>9.99'
field sum%   as deci format '>>>,>>>,>>9.99'
field sumod  as deci format '>>>,>>>,>>9.99'
field crede  as deci format '>>>,>>>,>>9.99'.

{er.i}
/* учет праздников и выходных */
function chk-hol returns date (input pr1 as date).
    def var res as date.
    res = pr1.
    repeat:
        find first holiday where holiday.hday = day(res) and holiday.hmonth = month(res) no-lock no-error.
        if available holiday then res = res + 1.
        else do:
            if weekday(res) = 1 or weekday(res) = 7 then do:
                if weekday(res) = 1 then res = res + 1.
                else if weekday(res) = 7 then res = res + 2.
            end.
            else leave.
        end.
    end.
    return res.
end function.

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else if v-num = 0 then v-datres = v-date.
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

empty temp-table b2cl.
empty temp-table cl2b.

/* расчет */

v-dt0 = v-rdt.
coun = 0.

do i = 1 to v-srok:
    if i = 1 then v-dt = v-pdt.
    else if i = v-srok then v-dt = get-date(v-rdt,v-srok).
    else v-dt = get-date(v-dt0,1).
    if v-dt >= v-pdtod then coun = coun + 1.
    v-dt0 = v-dt.
end.

v-dt0 = v-rdt.
v-sum0 = v-sum.
v-cpayment_od = 0.
v-dt0_prc = v-rdt.

if v-gr = 2 then do: /* равномерная */
    v-mpayment_od = round(v-sum / coun, 2).
    do i = 1 to v-srok:
        if i = 1 then v-dt = v-pdt.
        else if i = v-srok then v-dt = get-date(v-rdt,v-srok).
        else v-dt = get-date(v-dt0,1).

        v-dt1 = chk-hol(v-dt).
        v-prc = 0.
        if v-dt >= v-pdtprc then do:
            run day-360(v-dt0_prc,v-dt1 - 1,360,output dn1,output dn2).
            /*if v-gr = 2 then*/ v-prc = round(dn1 * v-sum0 * v-rate / 100 / 360,2).
            /*else v-prc = round(dn1 * v-sum * v-rate / 100 / 360,2).*/
            v-dt0_prc = v-dt1.
        end.

        v-cpayment_od = 0.
        if v-dt >= v-pdtod then do:
            if i = v-srok then v-cpayment_od = v-sum0.
            else v-cpayment_od = v-mpayment_od.
            v-sum0 = v-sum0 - v-cpayment_od.
        end.

        create cl2b.
        cl2b.dt = v-dt1.
        cl2b.days = v-dt1 - v-rdt.
        cl2b.sum = v-cpayment_od + v-prc + v-komob.

        create tmp.
        assign tmp.t-day  = v-dt1
               tmp.platej = v-cpayment_od + v-prc + v-komob
               tmp.sum%   = v-prc + v-komob
               tmp.sumod  = v-cpayment_od
               tmp.crede  = v-sum0.
        v-dt0 = v-dt.
    end.
end.
else do: /* аннуитет */
    v-mpayment = round(v-sum * v-rate / 1200 / (1 - 1 / exp(1 + v-rate / 1200,coun)),2).

    do i = 1 to v-srok:
        if i = 1 then v-dt = v-pdt.
        else if i = v-srok then v-dt = get-date(v-rdt,v-srok).
        else v-dt = get-date(v-dt0,1).

        v-dt1 = chk-hol(v-dt).
        v-prc = 0.
        if v-dt1 >= v-pdtprc then do:
            run day-360(v-dt0_prc,v-dt1 - 1,360,output dn1,output dn2).
            v-prc = round(dn1 * v-sum0 * v-rate / 100 / 360,2).
            v-dt0_prc = v-dt1.
        end.

        v-cpayment_od = 0.
        if v-dt1 >= v-pdtod then v-cpayment_od = v-mpayment - v-prc.
        else v-cpayment_od = 0.

        if i = v-srok then v-cpayment_od = v-sum0.
        v-sum0 = v-sum0 - v-cpayment_od.

        create cl2b.
        cl2b.dt = v-dt1.
        cl2b.days = v-dt1 - v-rdt.
        cl2b.sum = v-cpayment_od + v-prc + v-komob.

        create tmp.
        assign tmp.t-day  = v-dt1
               tmp.platej = v-cpayment_od + v-prc + v-komob
               tmp.sum%   = v-prc + v-komob
               tmp.sumod  = v-cpayment_od
               tmp.crede  = v-sum0.
        v-dt0 = v-dt.
    end.
end.

v-er = get_er(v-sum,v-kom1,0.0,0.0).

def shared var v-cifcod   as char no-undo.
def shared var s-credtype as char.
def shared var v-bank     as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var s-lon      as char.

def var v-met  as char.
def var v-method as char.
def var v-metotk as char.
def var v-methodkz as char.
def var v-metotkkz as char.
def var vpoint like point.point.
def var vdep like ppoint.dep.
def var v-otvlico as char.
def var vpropis  as char no-undo.
def var vpropis1 as char no-undo.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
vpoint =  integer(ofc.regno / 1000).
vdep = ofc.regno mod 1000.

find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" then v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1").
else do:
    find first sysc where sysc.sysc = "otvlico" no-lock no-error.
    if avail sysc then v-otvlico = sysc.chval.
    else v-otvlico = "1".
end.
if v-var then do:
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.credtype = '10' and pkanketa.ln = s-ln no-lock no-error.
    if avail pkanketa then do:

        find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emetam' no-lock no-error.
        if avail pkanketh then do:
            v-met = pkanketh.value1.
            if v-met = 'дифференцированные платежи' then assign v-method = "1. Заемщик от погашения аннуитетным методом отказывается."
                                                                v-metotk = "2. Заемщиком выбран метод дифференцированных платежей  погашения."
                                                                v-methodkz = "1. Ќарыз алушы аннуитетті јдіспен ґтеуден бас тартты."
                                                                v-metotkkz = "2. Ќарыз алушы сараланєан тґлемдер јдісімен ґтеуді таѕдады.".
            if v-met = 'аннуитет' then assign v-method = "1. Заемщик от погашения методом дифференцированных платежей отказывается."
                                              v-metotk = "2. Заемщиком выбран аннуитетный метод погашения."
                                              v-methodkz = "1. Ќарыз алушы сараланєан тґлемдер јдісімен ґтеуден бас тартты."
                                              v-metotkkz = "2. Ќарыз алушы аннуитетті јдіспен ґтеуді таѕдады.".
        end.

        find first cmp no-lock no-error.

        run Sm-vrd(pkanketa.rateq, output vpropis).

        if index(string(pkanketa.rateq),'.') > 0 then do:
            run Sm-vrd(int(substr(string(pkanketa.rateq),index(string(pkanketa.rateq),'.') + 1)), output vpropis1).
            vpropis = vpropis + ' целых ' + lc(vpropis1) + ' десятых процента'.
        end.
        else  vpropis = vpropis + ' процентов'.

        output stream m-out to grafik.htm.
        put stream m-out unformatted "<html><head><title>График</title>"
                        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">Приложение №1</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">График платежей</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">от " string(today,'99.99.9999') "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">к Договору № " pkanketa.rescha[1] " о предоставлении</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">Экспресс кредита</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""right"">от " if pkanketa.resdat[1] <> ? then string(pkanketa.resdat[1],'99.99.9999') else string(g-today,'99.99.9999') "</td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Наименование/имя заемщика (код): " pkanketa.name " (" pkanketa.cif ")</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Ссудный счет: " pkanketa.lon "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Сумма Кредита: " pkanketa.summa "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Валюта Кредита: тенге </td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Ставка вознаграждения (годовых): " vpropis "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""left"">Дата выдачи Кредита: " if pkanketa.resdat[1] <> ? then string(pkanketa.resdat[1],'99.99.9999') else string(g-today,'99.99.9999') "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=6 align = ""center""><b>Тґлемдер кестесі/График платежей</b></td></tr>".

        put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                     "<tr style=""font:bold; font-family:Times New Roman"">"
        /*1 */                       "<td align=""center"">N</TD>"
        /*2 */                       "<td align=""center"">Дата/Кїні</TD>"
        /*3 */                       "<td align=""center"">Ґтелінетін<br>Несие<br>сомасы/<br>Сумма<br>Кредита к<br>погашению</TD>"
        /*4 */                       "<td align=""center"">Ґтелінетін<br>сыйаќы<br>сомасы/<br>Сумма<br>вознаграж-<br>дения к<br>погашению</TD>"
        /*5 */                       "<td align=""center"">Ґтелінетін<br>Несие<br>жјне<br>сыйаќы<br>сомасы/<br>Сумма<br>Кредита и<br>вознаграждения<br>к погашению</TD>"
        /*6 */                       "<td align=""center"">Келесі<br>ґтелінетін<br>Несие<br>сомасыныѕ<br>ќалдыєы/<br>Остаток<br>суммы<br>Кредита<br>на дату<br>следующего<br>погашения</TD>"
                                     "</TR>" skip.
        i = 0.

        sumod  = 0.
        sum%   = 0.
        platej = 0.

        for each tmp no-lock:
            i = i + 1.
            put stream m-out unformatted "<tr style=""font-family:Times New Roman"">" skip
            /*1 */            "<td>" i  "</td>" skip
            /*2 */            "<td align=""center"">" tmp.t-day  "</td>" skip
            /*3 */            "<td align=""center"">" replace(string(tmp.sumod),'.',',')  "</td>" skip
            /*4 */            "<td align=""center"">" replace(string(tmp.sum%),'.',',')   "</td>" skip
            /*5 */            "<td align=""center"">" replace(string(tmp.platej),'.',',') "</td>" skip
            /*6 */            "<td align=""center"">" replace(string(tmp.crede),'.',',')  "</td>" skip
            "</tr>" skip.

            sumod  = sumod  + tmp.sumod.
            sum%   = sum%   + tmp.sum%.
            platej = platej + tmp.platej.

            find first lnsch where lnsch.lnn = pkanketa.lon and lnsch.stdat = tmp.t-day no-lock no-error.
            if not avail lnsch then do:
                create lnsch.
                lnsch.lnn   = pkanketa.lon.
                lnsch.stdat = tmp.t-day.
                lnsch.stval = tmp.sumod.
                lnsch.f0    = 1.
            end.

            find first lnsci where lnsci.lni = pkanketa.lon and lnsci.idat = tmp.t-day no-lock no-error.
            if not avail lnsci then do:
                create lnsci.
                lnsci.lni   = pkanketa.lon.
                lnsci.idat  = tmp.t-day.
                lnsci.iv-sc = tmp.sum%.
                lnsci.f0    = 1.
            end.
        end.
        run lnsch-ren(pkanketa.lon).
        run lnsci-ren(pkanketa.lon).

        put stream m-out unformatted "<tr style=""font:bold; font-family:Times New Roman; vertical-align:middle"">"
        /*1 */                       "<td align=""center""></TD>"
        /*2 */                       "<td align=""center"">Сомалыќ<br>белгісі/<br>Суммарное<br>значение<br>(Теѕге):</TD>"
        /*3 */                       "<td align=""center"">" sumod  format '>>>,>>>,>>9.99' "</TD>"
        /*4 */                       "<td align=""center"">" sum%   format '>>>,>>>,>>9.99' "</TD>"
        /*5 */                       "<td align=""center"">" platej format '>>>,>>>,>>9.99' "</TD>"
                                     "</TR>" skip.

        put stream m-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                                     "<tr></tr>" skip.

        find first codfr where codfr.codfr = "DKFACE" and codfr.code = v-otvlico no-lock no-error.

        put stream m-out unformatted "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">Подписанием настоящего Приложения № 1 к Договору, Заемщик подтверждает, что ознакомлен с<br>предложенными Банком графиками погашения Кредита, рассчитанными различными методами,<br>таким образом, при выборе Заемщиком метода погашения Стороны пришли к следующему:</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">" v-method "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">" v-metotk "</td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">Ќарыз алушы Шартќа осы №1 Ќосымша ќол ќоя отырып, Банкпен тїрлі јдістерімен есептеліп ўсынылєан Несиені ґтеу кестесімен танысќанын <br>растайды, Ќарыз алушымен  ґтеу јдісін таѕдауда  Тараптар келесіге тоќтады:</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">" v-methodkz "</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""left"">" v-metotkkz "</td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""center""><b>Банк/Банк</b></td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=4 align = ""right""><u>" codfr.name[1] "</u></td><td colspan=3 align = ""left"">______________________</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=4 align = ""right""></td><td colspan=3 align = ""left"">м.п.</td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""center""><b>Ќарыз алушы/Заемщик</b></td></tr>"
                                     "<tr></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""center""><u>" pkanketa.name "</u>     ___________________</td></tr>"
                                     "<tr style=""font-family:Times New Roman""><td colspan=7 align = ""center"">толыќ аты-жґні/ Ф.И.О. полностью</td></tr>"skip.

        put stream m-out "</table></body></html>" skip.
        output stream m-out close.
        hide message no-pause.
        unix silent cptwin grafik.htm excel.
    end.
end.