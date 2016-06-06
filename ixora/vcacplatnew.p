/* vcacplatnew.p
 * MODULE
        Вал контроль
 * DESCRIPTION
        Отчет по всем акцептованым платежам
 * RUN
        9-3-20
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.01.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        17.01.2012 aigul - добавила бд COMM
*/

{global.i}



{comm-txb.i}
def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def new shared var v-ourbank as char.
def new shared var s-vcourbank as char.
def new shared var v-bank   as char.
def new shared temp-table t-actplat
   field plnum as char
   field plinout as char
   field pldt as date
   field plsum as deci
   field plcrc as char
   field plrem as char
   field plget as char
   field bank as char
   index dt is primary pldt.


v-ourbank = comm-txb().

def frame fparam
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt1 = g-today.
v-dt2 = g-today.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

/*s-vcourbank = comm-txb().*/
{r-brfilial.i &proc = "vcacplatnew-dat"}


def stream v-out.
output stream v-out to actpayments.xls.
{html-title.i
 &title = "METROCOMBANK" &stream = "stream v-out" &size-add = "x-"}



find first cmp no-lock no-error.
put stream v-out unformatted
    "<p><b>Отчет по всем акцептованым платежам <br>за период с " + string(v-dt1,'99/99/9999') + " года по " + string(v-dt2,'99/99/9999') + " года <br><br>" + cmp.name + "</b></p>"  skip.


put stream v-out unformatted
    "<TABLE border=""1"" cellpadding=""10"" cellspacing=""0"">" skip.
put stream v-out unformatted skip
    "<tr style=""font:bold"" align=""center"">"
    "<td >Филиал</td>"
    "<td >№ платежного<br>поручения или<br>запявления на<br> перевод и № RMZ<br>или № JOU</td>"
    "<td >Исходящий/Входящий</td>"
    "<td >Дата платежа или<br>завления на<br> перевод</td>"
    "<td >Сумма<br>платежа или <br> заявления на <br> перевод</td>"
    "<td >Валюта<br>платежа или <br> заявления на <br> перевод</td>"
    "<td >Назначение<br>платежа</td>"
    "<td >Отправитель/Получатель</td></tr>" skip.

for each t-actplat no-lock break by t-actplat.bank:
 put stream v-out unformatted  "<tr>" skip.
 if first-of(t-actplat.bank) then do:
    put stream v-out unformatted "<td>" t-actplat.bank "</td>" skip.
 end.
 else put stream v-out unformatted "<td>"  "</td>" skip.
 /*put stream v-out unformatted "<td>" t-actplat.bank "</td>" skip.*/
 put stream v-out unformatted
 "<td>" t-actplat.plnum "</td>" skip
 "<td>" t-actplat.plinout "</td>" skip
 "<td>" string(t-actplat.pldt,'99/99/9999') "</td>" skip
 "<td>" replace(trim(string(t-actplat.plsum,'>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
 "<td>" t-actplat.plcrc "</td>" skip
 "<td>" t-actplat.plrem "</td>" skip
 "<td>" t-actplat.plget "</td></tr>" skip.

end.

put stream v-out unformatted "</table>" skip.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then put stream v-out unformatted "<p>Исполнитель: " ofc.name "</p>" skip.
put stream v-out unformatted "</body></html>" skip.
output stream v-out close.
hide message no-pause.
unix silent cptwin actpayments.xls excel.
unix silent rm -f actpayments.xls.