/* pkgcvp1.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчет по запросам в ГЦВП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-14-5  
 * AUTHOR
        13.11.2003 marinav
 * CHANGES
        19.02.2004 nadejda - добавлено время запроса и ответа
		21.02.2013 id00477 - ТЗ-1645 добавил в отчет поле ИИН
*/


{mainhead.i}
{pk.i "new"}
{sysc.i}

def var coun as int init 1.
define variable datums  as date format "99/99/9999".
define variable datums1  as date format "99/99/9999".
def var v-tim as char.
def var v-size as integer.

datums = g-today.
datums1 = g-today.

update datums label " Укажите дату с " format "99/99/9999" datums1 label " по " format "99/99/9999" skip
       with side-label row 5 centered frame dat .

define stream m-out.
output stream m-out to gcvp.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 skip. 



put stream m-out "<tr align=""center""><td><h3> Список запросов в ГЦВП, отправленных " skip
                 " с " string(datums) " по " string(datums1)
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out "<tr></tr><tr></tr>"
                 skip(1).

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr bgcolor=""#C0C0C0"" align=""center"" style=""font:bold"">"
                  "<td>П/п</td>"
                  "<td>СИК</td>"
				  "<td>ИИН</td>"
                  "<td>Фамилия</td>"
                  "<td>Имя</td>"
                  "<td>Отчество</td>"
                  "<td>Дата<br>рождения</td>"
                  "<td>Дата<br>запроса</td>"
                  "<td>Менеджер</td>"
                  "<td>Файл</td>"
                  "<td>Время<br>запроса</td>"
                  "<td>Время<br>ответа</td>"
                  "<td>Размер<br>файла</td>"
                  "</tr>" skip.


for each gcvp no-lock where gcvp.rdt >= datums and gcvp.rdt <= datums1.
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""center""> " gcvp.sik "</td>"
			   "<td align=""center""> '" gcvp.iin "</td>"
               "<td align=""left""> " gcvp.lname "</td>"
               "<td align=""left""> " gcvp.fname "</td>"
               "<td align=""left""> " gcvp.mname "</td>"
               "<td align=""left""> " gcvp.dtb "</td>"
               "<td align=""center""> " gcvp.rdt  "</td>"
               "<td align=""center""> " gcvp.ofc  "</td>"
               "<td align=""center"">&nbsp;" gcvp.nfile "</td>" skip.

        FILE-INFO:FILE-NAME = get-sysc-cha ("pkgcvi") + gcvp.nfile.
        IF FILE-INFO:FILE-TYPE = ? THEN v-tim = "".
        else do:
          v-tim = string(FILE-INFO:FILE-MOD-TIME, "HH:MM:SS").
          v-tim = entry(1, v-tim, ":") + ":" + entry(2, v-tim, ":").
        end.

        put stream m-out 
               "<td> " v-tim "</td>" skip.

        FILE-INFO:FILE-NAME = get-sysc-cha ("pkgcvi") + "gcvp" + gcvp.nfile.
        IF FILE-INFO:FILE-TYPE = ? THEN do:
          v-tim = "".
          v-size = 0.
        end.
        else do:
          v-tim = string(FILE-INFO:FILE-MOD-TIME, "HH:MM:SS").
          v-tim = entry(1, v-tim, ":") + ":" + entry(2, v-tim, ":").
          v-size = FILE-INFO:FILE-SIZE.
        end.

        put stream m-out 
               "<td> " v-tim "</td>" skip
               "<td> " v-size format ">>>>>>>>9" "</td>" skip
               "</tr>" skip.
         coun = coun + 1.
end.                       

put stream m-out "</table>" skip.
output stream m-out close.

unix silent cptwin gcvp.html excel. 





