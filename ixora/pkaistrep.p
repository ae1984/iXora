/* pkaistrep.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Отчет по сверке телефонных номеров с базой АИСТ
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
        26/05/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        24/04/2007 madiyar - веб-анкеты
        25/04/2007 madiyar - не выводился отчет при вводе анкеты, исправил
*/

{global.i}

def input parameter h_phone as char no-undo.
def input parameter h_rem as char no-undo.
def input parameter w_phone as char no-undo.
def input parameter w_rem as char no-undo.
def input parameter c_phone as char no-undo.
def input parameter c_rem as char no-undo.
def input parameter v-credtype as char no-undo.
def input parameter v-ankln as integer no-undo.

def var usrnm as char no-undo.
def var webank as logical no-undo.
def var v-type as char no-undo.
def var v-fio as char no-undo.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

find first bookcod where bookcod.bookcod = "credtype" and bookcod.code = v-credtype no-lock no-error.
if avail bookcod then v-type = trim(bookcod.name).
else v-type = "UNKNOWN".

webank = no.
find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = v-credtype and pkanketa.ln = v-ankln no-lock no-error.
if avail pkanketa and pkanketa.id_org = "inet" then assign webank = yes v-fio = pkanketa.name.

def stream rep.
output stream rep to pkaistrep.htm.

put stream rep unformatted
    "<!-- Отчет по сверке номеров телефонов с базой данных службы АИСТ -->" skip
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " g-ofc + " " + usrnm "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    
    "<b>Вид кредита:</b> " v-type "<BR>" skip.

if v-ankln <> 0 and v-ankln <> ? then
    put stream rep unformatted
        "<b>Номер анкеты:</b> " v-ankln "<BR>" skip
        "<b>ФИО клиента:</b> " v-fio "<BR>" skip.

put stream rep unformatted
    "<BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td colspan=2>Данные анкеты</td>" skip
    "<td colspan=3>Проверочные данные</td>" skip
    "<td rowspan=2>Примечания</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Телефон</td>" skip
    "<td>N телефона</td>" skip
    "<td>N телефона</td>" skip
    "<td>ФИО/Наименование организации</td>" skip
    "<td>Адрес</td>" skip
    "</tr>" skip.

find first phones where phones.number = h_phone no-lock no-error.
put stream rep unformatted
    "<tr>" skip
    "<td>Домашний</td>" skip
    "<td>" h_phone "</td>" skip
    "<td>" if avail phones then phones.number else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.name) else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.adress) else "не найден" "</td>" skip
    "<td>" h_rem "</td>" skip
    "</tr>" skip.

find first phones where phones.number = w_phone no-lock no-error.
put stream rep unformatted
    "<tr>" skip
    "<td>Рабочий</td>" skip
    "<td>" w_phone "</td>" skip
    "<td>" if avail phones then phones.number else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.name) else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.adress) else "не найден" "</td>" skip
    "<td>" w_rem "</td>" skip
    "</tr>" skip.

find first phones where phones.number = c_phone no-lock no-error.
put stream rep unformatted
    "<tr>" skip
    "<td>Контактный</td>" skip
    "<td>" c_phone "</td>" skip
    "<td>" if avail phones then phones.number else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.name) else "не найден" "</td>" skip
    "<td>" if avail phones then trim(phones.adress) else "не найден" "</td>" skip
    "<td>" c_rem "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.

if webank then unix silent value("mv pkaistrep.htm /var/www/html/docs/" + v-credtype + "/" + string(v-ankln) + "; chmod 666 /var/www/html/docs/" + v-credtype + "/" + string(v-ankln) + "/pkaistrep.htm").
else unix silent cptwin pkaistrep.htm excel.


