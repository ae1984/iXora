/* kons700n.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        09/01/08 marinav - rcp на scp  , добавлен вывод в Excel
*/


/*{global.i} */
def shared var g-today  as date.
def new shared var v-pass as char.


def new shared var dt$ as date init 10/22/02.
def new shared temp-table tgl
field tgl as int format ">>>>"
field tcrc as integer
field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
field tsum2 as dec format "->>>>>>>>>>>>>>9.99".

def var hostmy   as char format 'x(15)'.
def var dirc     as char format 'x(15)'.
/*def var ipaddr   as char format 'x(15)'.*/
dirc = 'C:/RML/REPORTS/700H'.
def var v as char.

find last bank.cls.
dt$ = bank.cls.whn.

for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

update dt$ label 'Введите отчетную дату' 
        validate((dt$ < g-today ), 
       'Отчетная дата должна быть меньше даты текущего ОД')  
       with row 8 centered  side-label frame opt.
 hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .

/*unix silent rm FS/gl.txt.*/

{r-brfilial.i &proc = "700n-gl"}

output to "gl.xml".
put '<?xml version="1.0"?>' skip.
put '<doc name="G/K" date="' dt$ '">' skip.
put '<head><title>balance</title></head>' skip.
put '<body>' skip.
for each tgl break by tgl.tgl:
    def var sum$ as dec format "->>>>>>>>>>>>>>9.99".
    sum$ = sum$ + tgl.tsum2.
    if last-of(tgl.tgl) then do:
        put '<data name="' tgl.tgl '" value="' sum$ '"/>' skip.
        sum$ = 0.
    end.
end.
 hide frame ww.

put '</body>' skip.
put '</doc>' skip. 
output close.

    input through value("cpy -put gl.xml " + dirc + ";echo $?").
    repeat:
        import v.
    end.
    input close.
    
    if v <> '0' then do: message "Файл не скопирован!" . pause 50. end.
/*
find first cmp.
define stream rep.
output stream rep to bal.htm.

put stream rep unformatted "<html><head><title>АО МЕТРОКОМБАНК</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream rep unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>Баланс за  " string(dt$)  "<BR>".
put stream rep unformatted "<br><br></h3></td></tr><tr></tr>" skip.



       put stream rep unformatted "<br><br></h3></td></tr>" skip.
       put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"                  
                  "<td>Номер <br> счета</td>"
                  "<td>Сумма</td><tr>"
                   skip.
sum$ = 0.
for each tgl break by tgl.tgl:
    sum$ = sum$ + tgl.tsum2.
    if last-of(tgl.tgl) then do:
     put stream rep unformatted "<tr align=""right"">"
               "<td align=""left"">&nbsp;" string(tgl.tgl) "</td>" skip
               "<td>" replace(trim(string(sum$, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>".      
        sum$ = 0.
    end.
end.


put stream rep "</table></body></html>" skip.
output stream rep close.

unix silent cptwin bal.htm excel.
 */