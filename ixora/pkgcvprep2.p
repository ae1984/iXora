/* pkgcvprep21.p
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
 * BASES
        BANK COMM
 * AUTHOR
       13/06/08 marinav
 * CHANGES
       23.12.2010 aigul - убрала вывод суммы и поправила ввод v-gcvptxt с 10 на 9, так как ГЦВП больше не выводит сумму
                          num-entries((entry(2, v-gcvptxt, ";")), "|") = 9
       30.12.2010 aigul - поправила вывод ФИО и СИК-а
	   21.02.2013 id00477 - ТЗ-1645 изменил выборку полей для cоставления отчета
	   27.02.2013 id00477 - ТЗ-1718 изменил значение МРП

*/


{global.i}
{pk.i new}
{pk-sysc.i}

def input parameter v-gcvptxt as char.
def input parameter p-katjob as char.
def var v-dohod as decimal no-undo.
def var v-vichet as decimal no-undo.
/*
v-gcvptxt = "000000009;000000009|AGE65JVA0RV0S00J|АНДРУСЕНКО|МАРИНА|ВЛАДИМИРОВНА|25.06.1975|0|6|14344".
def var v-gcvptxt as char.
def var p-katjob as char.
v-gcvptxt = '00013542;00013542|2|600310421049|JXVVHHJWURVKG00H|БИБИК|МАРИНА|ВЛАДИМИРОВНА|25.06.1975|38736|0;29.06.2007|ТОО "МКО"НАРОДНЫЙ КРЕДИТ"|600900580625|190501719|2925,6;11.07.2007|Микрокредитная Организация  Народный Кредит|600900580625|190501719|,8;15.08.2007|Микрокредитная Организация  Народный Кредит|600900580625|190501719|2925,6'.
p-katjob = '10'.
*/

def var v-sts as char.
def var v-name as char.
def var v-file as char init "gcvp.html".
def var v-sum as deci.
def var n as inte.

find first cmp no-lock no-error.

define stream m-out.
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- ГЦВП-отчет -->" skip.

{html-title.i &stream = "stream m-out" &title = "Результат запроса в ГЦВП" &size-add = "x-"}

put stream m-out unformatted
  "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
  "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip.

  v-name = "".
  v-name = entry(3, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " " + entry(4, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " " + entry(5, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " , ИИН " + entry(2, (entry(2, v-gcvptxt, ";")), "|").

  put stream m-out unformatted
     "<tr align=""center""><td><h3>" v-name "</h3></td></tr>" skip
     "<tr><td><h4>Запрос N: " entry(1, v-gcvptxt, ";") "</h4></td></tr>" skip
     "<tr><td>&nbsp;</td></tr>" skip
     "<tr align=""center""><td><h3>Пенсионные платежи, прошедшие через ГЦВП за последние 6 месяцев по клиенту</h3></td></tr>" skip
     "<tr><td>&nbsp;</td></tr>" skip.

v-sts = entry(7, (entry(2, v-gcvptxt, ";")), "|").
if v-sts = "0" and num-entries((entry(2, v-gcvptxt, ";")), "|") = 9 then do:
/***************************************************************/
/*  Для военнослужащих расчет отдельно */
  if p-katjob = '50' or  p-katjob = '60' then do:
    find first bookcod where bookcod.bookcod = "pkankkat" and bookcod.code = p-katjob no-lock no-error.
      if avail bookcod then do:
        v-dohod = integer (bookcod.info[3]).
        v-vichet = integer (bookcod.info[4]).
        v-sum = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * v-dohod * (100 - v-vichet) / 100.
      end.
  end.
  else do:
	  find first bookcod where bookcod = "MRP" no-lock no-error. 
	  v-sum = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * 8.1 + decimal(bookcod.name).
  end.
/****************************************************************/

  put stream m-out unformatted
  "<tr><td><h4>Средняя сумма отчислений - " entry(9, (entry(2, v-gcvptxt, ';')), '|') " тенге </td></tr>" skip
  "<tr><td><h4>Чистый доход             - " v-sum " тенге</td></tr>" skip.
end.
else do:

        put stream m-out unformatted
          "<tr align=""center""><td><br><b>БАЗА ГЦВП НЕ СОДЕРЖИТ СВЕДЕНИЙ ОБ ОБЯЗАТЕЛЬНЫХ ПЕНСИОННЫХ ОТЧИСЛЕНИЯХ<br>ЗА ПОСЛЕДНИЕ 6 МЕСЯЦЕВ ПО ЭТОМУ ВКЛАДЧИКУ<br><br>Статус : " skip.

        find first bookcod where bookcod = "pkgcvp" and bookcod.code = v-sts no-lock no-error.
        if avail bookcod then put stream m-out unformatted bookcod.name.
                         else put stream m-out unformatted "Запрос обработан".

        put stream m-out unformatted "</td></tr>" skip.

end.

put stream m-out unformatted  "<tr><td>&nbsp;</td></tr>" skip
     "<tr><td>&nbsp;</td></tr>" skip
     "<tr align=""center""><td><h3>Социальные платежи, прошедшие через ГЦВП за последние 12 месяцев </h3></td></tr>" skip
     "<tr><td>&nbsp;</td></tr>" skip.

put stream m-out unformatted "</table>" skip.


if num-entries(v-gcvptxt, ";") > 2 then do:

      put stream m-out unformatted
        "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
        "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"">" skip
                       "<td>Дата</td>"
                       "<td>Отправитель</td>"
                       "<td>РНН<BR>отправителя</td>"
                       "<td>БИК<BR>отправителя</td>"
                       /*"<td>Сумма<br>соц взноса</td>"*/
                       "</tr>" skip.

      do n = 3 to num-entries(v-gcvptxt, ";"):
        /* показать данные ответа */

          put stream m-out unformatted
              '<tr align=""right"">' skip
                   '<td>' entry(1, (entry(n, v-gcvptxt, ';')), '|') '</td>' skip
                   '<td>' entry(2, (entry(n, v-gcvptxt, ';')), '|') '</td>' skip
                   '<td>&nbsp;' entry(3, (entry(n, v-gcvptxt, ';')), '|') '</td>' skip
                   '<td>' entry(4, (entry(n, v-gcvptxt, ';')), '|') '</td>' skip
                   /*'<td align=""right"">' replace(trim(string(entry(5, (entry(n, v-gcvptxt, ';')), '|')), '>>>>9.99'), '.', ',') '</td>' skip*/
                   '</tr>' skip.
       end.

end.
else do:
   put stream m-out unformatted  "<tr align=""center""><td><br><b>БАЗА ГЦВП НЕ СОДЕРЖИТ СВЕДЕНИЙ О СОЦИАЛЬНЫХ ОТЧИСЛЕНИЯХ<br> ПО ЭТОМУ ВКЛАДЧИКУ " skip.
   put stream m-out unformatted "</td></tr>" skip.
end.

put stream m-out unformatted "</table>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if avail pkanketa and pkanketa.id_org = "inet" then unix silent value("mv " + v-file + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-file).
else unix silent cptwin value(v-file) iexplore.

