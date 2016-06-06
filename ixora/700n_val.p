/* 700n_val.p
 * MODULE
        Балансовый отчет 700-Н
 * DESCRIPTION
        Баланс за дату с разбивкой по валютам - консолидированный
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-branch.i 700n_v
 * MENU
        8-12-2-3 
 * AUTHOR
        23.03.2005 marinav
 * CHANGES
        29.03.2005  marinav  Копирование на С: для дальнейшей обработки
        09/01/08 marinav - rcp на scp  , добавлен вывод в Excel
*/

/*{global.i} */
def shared var g-today  as date.
def new shared var v-pass as char.
def var sum1$ as dec format "->>>>>>>>>>>>>>9.99".
def var sum2$ as dec format "->>>>>>>>>>>>>>9.99".
def var sum4$ as dec format "->>>>>>>>>>>>>>9.99".
def var sum11$ as dec format "->>>>>>>>>>>>>>9.99".

def var dirc     as char format 'x(15)'.
dirc = 'C://'.

def new shared var dt$ as date .
def new shared temp-table tgl
field tgl as int format ">>>>"
field tcrc as integer
field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
field tsum2 as dec format "->>>>>>>>>>>>>>9.99".

find last bank.cls.
dt$ = bank.cls.whn.

update dt$ label 'Введите отчетную дату' 
        validate((dt$ < g-today ), 
       'Отчетная дата должна быть меньше даты текущего ОД')  
       with row 8 centered  side-label frame opt.
 hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .

{r-branch.i &proc = "700n_v"}
pause 0.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out skip.
           
put stream m-out "<html><head><title>TEXAKABANK:</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>".
put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""3""
                 style=""border-collapse: collapse"">". 
                 
put stream m-out "<tr align=""center""><td><h3> Баланс 700-Н за " dt$ "<br><br></td></tr>" skip.


  put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ї счета</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""> KZT, тыс. тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""> USD</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""> RUR</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""> EURO</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center""> Итого</td>"
                  "</tr>" skip.

    for each tgl break by tgl.tgl:

            if tgl.tcrc = 1 then sum1$ = sum1$ + tgl.tsum2.
            if tgl.tcrc = 2 then sum2$ = sum2$ + tgl.tsum2.
            if tgl.tcrc = 4 then sum4$ = sum4$ + tgl.tsum2.
            if tgl.tcrc = 3 then sum11$ = sum11$ + tgl.tsum2.
            if last-of(tgl.tgl) then do:
                find first gl where gl.gl = int(string(tgl.tgl) + '00') no-lock no-error.
                put stream m-out unformatted "<tr align=""right"">"
                   "<td> " tgl.tgl "</td> "
                   "<td align=""left""> " gl.des format 'x(40)' "</td> "
                   "<td> " replace(trim(string(deci(sum1$ / 1000), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(deci(sum2$ / 1000), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(deci(sum4$ / 1000), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(deci(sum11$ / 1000), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(deci((sum1$ + sum2$ + sum4$ + sum11$) / 1000), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "</tr>" skip.
                assign sum1$ = 0 sum2$ = 0 sum4$ = 0 sum11$ = 0.
            end.
    end.
 hide frame ww.

put stream m-out "</table>".
put stream m-out "</table></body></html>".
output stream m-out close.

def var v as char.
input through value("cpy -put rpt.html " + dirc + ";echo $?").
    repeat:
        import v.
    end.
    input close.
    
    if v <> '0' then do: message "Файл не скопирован!" . pause 50. end.

unix silent cptwin rpt.html excel.

