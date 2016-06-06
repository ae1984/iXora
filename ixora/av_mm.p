/* av_mm.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет о средних остатках за месяц по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.21
 * AUTHOR
        06.12.2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var s-dat1 as date no-undo format '99/99/9999'.
def new shared var s-dat2 as date no-undo format '99/99/9999'.
def new shared var v-rep2 as logi.

def new shared var v-dt as date.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field acc-ddt as date
    field geo as character
    field dt as date
    index tgl-id1 is primary gl7.

def new shared temp-table wrk
    field br  as int
    field dt  as date
    field gl  as int
    field gl4 as char
    field bal as deci
    field crc as int
    field skv as int
    field tot as logi
    field totlev as int
    field totgl as int
    field des as char
    index gl4 gl4.

def var mm as int.
def var yy as int.
def var ndays as int.
def var nholidays as int.
def var dt as date.
def var i as int.
def var j as int.
def var k as int.
def var v-gl4 as char.
def var v-gl5 as char.
def var rang-sum as int init 1.
def var v-rang as int.
def var v-sum as deci.
def var day-sum as deci extent 31.
def var v-totsum as deci extent 31.
def var v-gl6499 as deci extent 31.
def var v-gl6999 as deci extent 31.
def var sum6499 as deci.
def var sum6999 as deci.
def var month-sum as deci.
def var v-tg as logi.
def var v-holiday as logi init yes.

define stream m-out.
define stream v-out.


def var v-class as char extent 7 init
["Активы", "Обязательства", "Собственный капитал", "Доходы", "Расходы", "Условные и возможные требования и обязательства", "Счета меморандума к балансу"].

def var v-desc as char extent 4 init
["", "в тенге", "в СКВ", "в ДВВ"].

def new shared var v-total as int extent 7 init
[199995, 299990, 399990, 499900, 599990, 699990, 799990].

def frame fr1
    s-dat1     format  "99/99/9999"  label  "Начало периода         " skip
    s-dat2     format  "99/99/9999"  label  "Конец периода          " skip
    v-tg       format  "Да/Нет"      label  "В тыс.тенге/тенге      " skip
    v-rep2     format  "Да/Нет"      label  "Приложение к отчету    " skip
    v-holiday  format  "Да/Нет"      label  "Учитывать выходные дни "
with side-labels centered row 15 title "Отчет о средних остатках за период".

v-dt = s-dat1.

mm = month(today).
yy = year(today).



s-dat1 = date(mm, 1, yy).
s-dat2 = today.

update s-dat1 s-dat2 v-tg v-rep2 v-holiday with frame fr1.

ndays = (s-dat2 - s-dat1) + 1.

nholidays = 0.
if v-holiday = no then do:
    for each cls where cls.whn >= s-dat1 and cls.whn <= s-dat2 and cls.del = yes no-lock:
        nholidays = nholidays + 1.
    end.
    nholidays = ndays - nholidays.
end.


if v-tg = yes then v-rang = 1000.
else v-rang = 1.


{r-brfilial.i &proc = "av_mm2"}

run PrintRep.
if v-rep2 = yes then run PrintShifr.


procedure PrintRep:
    message "Формирование отчета...".
    output stream m-out to avmm.html.

    put stream m-out "<html><head><title>ForteBank</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
    style=""border-collapse: collapse"">"
    skip.

    put stream m-out  unformatted
    "<tr align=""center"">Отчет о средних остатках на балансовых и внебалансовых счетах АО ""ForteBank""</tr>"
    "<tr>" v-bankname "</tr>"
    "<tr> c " s-dat1 format "99.99.9999" " по " s-dat2 format "99.99.9999" "</tr>".

    put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
    style=""border-collapse: collapse" ">" skip
    "<tr style=""font:bold" "" ">"
    "<td bgcolor=""#CCCCCC"" align=""center"">Счет</td>"
    "<td bgcolor=""#CCCCCC"" align=""center"">Наименование</td>".


    dt = s-dat1.
    do i = 1 to ndays:
        put stream m-out  unformatted "<td bgcolor=""#CCCCCC"" align=""center"">" string(dt) "</td>".
        dt = dt + 1.
    end.

    put stream m-out  unformatted
    "<td bgcolor=""#CCCCCC"" align=""center"">Всего</td>"
    "<td bgcolor=""#CCCCCC"" align=""center"">Средний остаток за<br>указанный период</td>"
    "<td bgcolor=""#CCCCCC"" align=""center"">Количество<br>дней</td></tr>".

    v-gl4 = ''.
    do j = 1 to 7:
        for each gl where substr(string(gl.gl), 1,1) = string(j) and  gl.totlev = 1 and gl.totgl <> 0 no-lock use-index gl:
            if v-gl4 = substr(string(gl.gl),1,4) then next.
            else do:
                v-gl4 = substr(string(gl.gl),1,4).

                if v-gl4 <> "6499" and v-gl4 <> "6999" then do:
                    find first wrk where wrk.gl4 = v-gl4 and wrk.bal <> 0 no-lock no-error.
                    if not avail wrk then next.
                end.

                put stream m-out  unformatted
                "<tr>
                 <td align=""center"">" v-gl4  "</td>"
                "<td align=""center"">" gl.des "</td>".

                dt = s-dat1.
                do i = 1 to ndays:
                    for each wrk where wrk.gl4 = v-gl4 and wrk.dt = dt no-lock use-index gl:
                        day-sum[i] = day-sum[i] + wrk.bal.
                    end.

                    if v-holiday = no then do:
                        find first cls where cls.whn = dt and cls.del = yes no-lock no-error.
                        if not avail cls then day-sum[i] = 0.
                    end.

                    put stream m-out  unformatted "<td align=""center"">" replace(string(day-sum[i] / v-rang),".",",")  "</td>".
                    month-sum = month-sum + day-sum[i].
                    v-totsum[i] = v-totsum[i] + day-sum[i].

                    /* сумма условных и возможных требований и обязательств */
                    if j = 6 then do:
                        if gl.gl < 649999 then v-gl6499[i] = v-gl6499[i] + day-sum[i].
                        if gl.gl > 649999 then v-gl6999[i] = v-gl6999[i] + day-sum[i].
                    end.
                    /*------------------------------------------------------*/

                    dt = dt + 1.
                end.
                do i = 1 to ndays:
                    day-sum[i] = 0.
                end.
                put stream m-out  unformatted
                    "<td align=""center"">" replace(string(month-sum / v-rang),".",",")  "</td>"
                    "<td align=""center"">" replace(string(month-sum / (ndays - nholidays) / v-rang),".",",")  "</td>"
                    "<td align=""center"">" string(ndays - nholidays)  "</td></tr>".
                month-sum = 0.

                if v-gl4 = "6499" then do:
                    put stream m-out  unformatted
                    "<tr>
                     <td bgcolor=""#CCCCCC"" align=""center"">649990</td>"
                    "<td bgcolor=""#CCCCCC"" align=""center"">Условные и возможные требования</td>".
                    do i = 1 to ndays:
                        put stream m-out  unformatted "<td bgcolor=""#CCCCCC"" align=""center"">" replace(string(v-gl6499[i] / v-rang),".",",")  "</td>".
                        sum6499 = sum6499 + v-gl6499[i].
                    end.
                    put stream m-out  unformatted
                    "<td bgcolor=""#CCCCCC"" >" replace(string(sum6499 / v-rang),".",",")  "</td>
                    <td bgcolor=""#CCCCCC"" >" replace(string(sum6499 / (ndays - nholidays) / v-rang),".",",")  "</td>
                    <td bgcolor=""#CCCCCC"" >" string(ndays - nholidays)  "</td>
                    </tr>".
                end.

                if v-gl4 = "6999" then do:
                    put stream m-out  unformatted
                    "<tr>
                     <td bgcolor=""#CCCCCC"" align=""center"">699990</td>"
                    "<td bgcolor=""#CCCCCC"" align=""center"">Условные и возможные обязательства</td>".
                    do i = 1 to ndays:
                        put stream m-out  unformatted "<td bgcolor=""#CCCCCC"" align=""center"">" replace(string(v-gl6999[i] / v-rang),".",",")  "</td>".
                        sum6999 = sum6999 + v-gl6999[i].
                    end.
                    put stream m-out  unformatted
                    "<td bgcolor=""#CCCCCC"">" replace(string(sum6999 / v-rang),".",",")  "</td>
                    <td bgcolor=""#CCCCCC"">" replace(string(sum6999 / (ndays - nholidays) / v-rang),".",",")  "</td>
                    <td bgcolor=""#CCCCCC"">" string(ndays - nholidays)  "</td>
                    </tr>".
                end.
            end.
        end.

        put stream m-out  unformatted "<tr><td bgcolor=""#CCCCCC"" >" j "</td><td bgcolor=""#CCCCCC"">" v-class[j] "</td>".
            dt = s-dat1.
            do i = 1 to ndays:
                put stream m-out  unformatted "<td bgcolor=""#CCCCCC"" >" replace(string(v-totsum[i] / v-rang),".",",") "</td>".
                 month-sum = month-sum + v-totsum[i].
                v-totsum[i] = 0.
                dt = dt + 1.
            end.
        put stream m-out  unformatted
            "<td bgcolor=""#CCCCCC"" >" replace(string(month-sum / v-rang),".",",") "</td>
            <td bgcolor=""#CCCCCC"" >" replace(string(month-sum / (ndays - nholidays) / v-rang),".",",") "</td>
            <td bgcolor=""#CCCCCC"" >" string(ndays - nholidays) "</td>
            </tr>".
        month-sum = 0.
    end.

    put stream m-out "</table>" skip.
    put stream m-out "</body></html>" skip.
    output stream m-out close.
    unix silent cptwin avmm.html excel.exe.
    unix silent rm avmm.html.

    message "Формирование отчета выполнено".
    pause 2.
end procedure.

procedure PrintShifr:

    def buffer b-tgl for tgl.

    def var sum as deci.
    output stream v-out to avmm2.html.

    put stream v-out "<html><head><title>ForteBank</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
    style=""border-collapse: collapse"">"
    skip.

    put stream v-out  unformatted
    "<tr align=""center""><td>Приложение к детализированному плану счетов бухгалтерского учета для составления главной бухгалтерской книги банков второго уровня АО ""ForteBank""
    <br>" v-bankname "</td></tr><br><br>"
    skip(2).
    put stream v-out "<br><br><tr></tr>".


    put stream v-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
    style=""border-collapse: collapse" ">" skip
    "<tr style=""font:bold" "" ">"
    "<td colspan=""4"" bgcolor=""#CCCCCC"" align=""center"">Структура</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Наименование</td>".


    dt = s-dat1.
    do i = 1 to ndays:
        put stream v-out  unformatted "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">" string(dt) "</td>".
        dt = dt + 1.
    end.

    put stream v-out  unformatted
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Всего</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Средний остаток за<br>указанный период</td>"
    "<td rowspan=""2"" bgcolor=""#CCCCCC"" align=""center"">Количество<br>дней</td></tr>"
    "<tr>"
    "<td bgcolor=""#CCCCCC"">'1-4</td>
    <td bgcolor=""#CCCCCC"">5</td>
    <td bgcolor=""#CCCCCC"">6</td>
    <td bgcolor=""#CCCCCC"">7</td>"
    "</tr>".


    for each tgl use-index tgl-id1 break by tgl.gl7:
        if first-of (tgl.gl7) then do:
            find first b-tgl where b-tgl.gl7 = tgl.gl7 and b-tgl.sum <> 0 no-lock no-error.
            if not avail b-tgl then next.

            dt = s-dat1.
            put stream v-out  unformatted
            "<tr>
             <td align=""center"">" tgl.gl4  "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),5,1) "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),6,1) "</td>
             <td bgcolor=""#CCCCCC"">" substr(string(tgl.gl7),7,1) "</td>
             <td align=""center"">" tgl.gl-des "</td>".

            do i = 1 to ndays:
                sum = 0.
                for each b-tgl where b-tgl.gl7 = tgl.gl7 and b-tgl.dt = dt no-lock:
                    sum = sum + b-tgl.sum.
                end.

                if v-holiday = no then do:
                    find first cls where cls.whn = dt and cls.del = yes no-lock no-error.
                    if not avail cls then sum = 0.
                end.

                put stream v-out  unformatted "<td align=""center"">" replace(string(sum / v-rang),".",",")  "</td>".
                month-sum = month-sum + sum.
                dt = dt + 1.
            end.

            put stream v-out  unformatted
                "<td align=""center"">" replace(string(month-sum),".",",")  "</td>"
                "<td align=""center"">" replace(string(month-sum / (ndays - nholidays)),".",",")  "</td>"
                "<td align=""center"">" string(ndays - nholidays)  "</td></tr>".
            month-sum = 0.

        end.
    end.

    put stream v-out "</table>" skip.
    put stream v-out "</body></html>" skip.
    output stream v-out close.
    unix silent cptwin avmm2.html excel.exe.
    unix silent rm avmm2.html.

    message "Формирование приложения к отчету выполнено".
    pause 2.

end procedure.