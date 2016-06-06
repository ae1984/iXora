/* r-ppmrr.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет "Расчет для ППМРР"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.22
 * AUTHOR
        29/02/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def input parameter t-auto as logical.

def new shared var dat1 as date format '99/99/9999'.
def new shared var v-grpname as char extent 8.
    v-grpname[1] = "Активы, приносящие доход (АД)".
    v-grpname[2] = "Доходы, связанные с получением вознаграждения".
    v-grpname[3] = "Доходы, не связанные с получением вознаграждения".
    v-grpname[4] = "Прочие доходы".
    v-grpname[5] = "Обязательства, влекущие расходы (ОР)".
    v-grpname[6] = "Расходы, связанные с выплатой вознаграждения по обязательствам".
    v-grpname[7] = "Операционные расходы (ОПР)".
    v-grpname[8] = "Прочие расходы".

def new shared temp-table wrk
    field gl as int
    field grp as int
    field bal as deci
    field plus as char
    index idx gl.

def new shared temp-table wrk-gl
    field gl like gl.gl
    field grp as int
    field plus as char
    index gl gl.

def var v-ostgl as deci extent 8 init [0,0,0,0,0,0,0,0].
def var i as integer.

/*группа 1*/
for each gl where
        gl.gl = 110000 or
        gl.gl = 125000 or
        gl.gl = 130000 or
        gl.gl = 131000 or
        gl.gl = 132000 or
        gl.gl = 140000 or
        gl.gl = 141000 or
        gl.gl = 142000 or
        gl.gl = 143000 or
        gl.gl = 120000 or
        gl.gl = 145000 or
        gl.gl = 146000 or
        gl.gl = 147000 or
        gl.gl = 148000 or
        gl.gl = 149000 or

        gl.gl = 125900 or
        gl.gl = 131900 or
        gl.gl = 132900 or
        gl.gl = 142800 or
        gl.gl = 120400 or
        gl.gl = 143400
no-lock:
    if  gl.gl = 125900 or
        gl.gl = 131900 or
        gl.gl = 132900 or
        gl.gl = 142800 or
        gl.gl = 143400 or
        gl.gl = 120400 or
        gl.gl = 143400 then do:
            create wrk-gl.
            wrk-gl.gl = gl.gl.
            wrk-gl.grp = 1.
            wrk-gl.plus = "-".
        end.
    else do:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 1.
        wrk-gl.plus = "+".
    end.
end.

/*группа 2*/
for each gl where
        gl.gl = 410000 or
        gl.gl = 425000 or
        gl.gl = 430000 or
        gl.gl = 431000 or
        gl.gl = 432000 or
        gl.gl = 440000 or
        gl.gl = 441000 or
        gl.gl = 442000 or
        gl.gl = 443000 or
        gl.gl = 420000 or
        gl.gl = 445000 or
        gl.gl = 446000 or
        gl.gl = 446500 or
        gl.gl = 447000 or
        gl.gl = 448000 or
        gl.gl = 449000
no-lock:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 2.
        wrk-gl.plus = "+".
end.

/*группа 3*/
for each gl where
        gl.gl = 450000 or
        gl.gl = 460000 or
        gl.gl = 489000 or
        gl.gl = 492000 or
        gl.gl = 470900 or
        gl.gl = 473300 or
        gl.gl = 485000 or
        gl.gl = 490000 or
        gl.gl = 405000
no-lock:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 3.
        wrk-gl.plus = "+".
end.

/*группа 4*/
for each gl where
        gl.gl = 470300 or
        gl.gl = 495000
no-lock:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 4.
        wrk-gl.plus = "+".
end.

/*группа 5*/
for each gl where
        gl.gl = 220000 or
        gl.gl = 203000 or
        gl.gl = 204000 or
        gl.gl = 202000 or
        gl.gl = 205000 or
        gl.gl = 206000 or
        gl.gl = 225000 or
        gl.gl = 240000 or
        gl.gl = 230000 or

        gl.gl = 220300 or
        gl.gl = 220400 or
        gl.gl = 220500 or
        gl.gl = 223700
no-lock:
     if gl.gl = 220300 or
        gl.gl = 220400 or
        gl.gl = 220500 or
        gl.gl = 223700 then do:
            create wrk-gl.
            wrk-gl.gl = gl.gl.
            wrk-gl.grp = 5.
            wrk-gl.plus = "-".
        end.
        else do:
            create wrk-gl.
            wrk-gl.gl = gl.gl.
            wrk-gl.grp = 5.
            wrk-gl.plus = "+".
        end.
end.

/*группа 6*/
for each gl where
        gl.gl = 520000 or
        gl.gl = 521000 or
        gl.gl = 522000 or
        gl.gl = 503000 or
        gl.gl = 504000 or
        gl.gl = 502000 or
        gl.gl = 505000 or
        gl.gl = 509000 or
        gl.gl = 506000 or
        gl.gl = 525000 or
        gl.gl = 512000 or
        gl.gl = 540000 or
        gl.gl = 530000
no-lock:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 6.
        wrk-gl.plus = "+".
end.

/*группа 7*/
for each gl where
        gl.gl = 572000 or
        gl.gl = 574000 or
        gl.gl = 576000 or
        gl.gl = 578000 or
        gl.gl = 585299 or
        gl.gl = 585400 or
        gl.gl = 585600 or
        gl.gl = 590099 or
        gl.gl = 592399 or

        gl.gl = 575400
no-lock:
        if gl.gl = 575400 then do:
            create wrk-gl.
            wrk-gl.gl = gl.gl.
            wrk-gl.grp = 7.
            wrk-gl.plus = "-".
        end.
        else do:
            create wrk-gl.
            wrk-gl.gl = gl.gl.
            wrk-gl.grp = 7.
            wrk-gl.plus = "+".
        end.
end.

/*группа 8*/
for each gl where
        gl.gl = 545000 or
        gl.gl = 550000 or
        gl.gl = 560000 or
        gl.gl = 570000 or
        gl.gl = 575400 or
        gl.gl = 589000 or
        gl.gl = 592199 or
        gl.gl = 592299 or
        gl.gl = 592600
no-lock:
        create wrk-gl.
        wrk-gl.gl = gl.gl.
        wrk-gl.grp = 8.
        wrk-gl.plus = "+".
end.

if t-auto = no then update dat1 label 'Введите дату ' format '99/99/9999' with side-label row 5 centered frame dat.
else dat1 = date(month(today),1,year(today)).

{r-branch.i &proc = "r-ppmrr1"}

define stream m-out.
output stream m-out to ppmrr.html.

put stream m-out
        "<html><head><title>METROCOMBANK</title>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out
        "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"" >" skip.

put stream m-out  unformatted
        "<tr align=""center""><td bgcolor=""#CCCCCC"" colspan=""2"">Расчеты для ППМРР" "<br>"
        "по состоянию на " dat1 format "99.99.9999" "</td></tr>" skip.


do i = 1 to 8:
    for each wrk where wrk.grp = i use-index idx no-lock:
        if wrk.plus = "+" then v-ostgl[i] = v-ostgl[i] + wrk.bal.
        else v-ostgl[i] = v-ostgl[i] - wrk.bal.

    end.

    put stream m-out unformatted
        "<tr>
        <td align=""center"">" v-grpname[i] "</td>
        <td>" replace(string(v-ostgl[i] / 1000),".",",") "</td>
        </tr>" skip.
end.

put stream m-out "</body></html>" skip.
output stream m-out close.
unix silent cptwin ppmrr.html excel.exe.
unix silent rm ppmrr.html.
