/* pkgcvprep1.p
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
       10/05/07 marinav
 * CHANGES
       13/06/07 marinav - одинаковый расчет делается вpkgcvprep1, pkimgcvp, pkkritlib (pkgcvpsum)
*/


{global.i}
{pk.i}
{pk-sysc.i}

def input parameter v-gcvptxt as char.
def input parameter p-katjob as char.
def var v-dohod as decimal no-undo.
def var v-vichet as decimal no-undo.
/*
def var v-gcvptxt as char.
v-gcvptxt = "000000009;000000009|AGE65JVA0RV0S00J|АНДРУСЕНКО|МАРИНА|ВЛАДИМИРОВНА|25.06.1975|0|6|14344".
*/

def var v-sts as char.
def var v-name as char.
def var v-file as char init "gcvp.html".
def var v-sum as deci.

find first cmp no-lock no-error.

define stream m-out.
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- ГЦВП-отчет -->" skip.

{html-title.i &stream = "stream m-out" &title = "Результат запроса в ГЦВП" &size-add = "x-"}

put stream m-out unformatted 
  "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
  "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip
  "<tr align=""center""><td><h3>Пенсионные платежи, прошедшие через ГЦВП за последние 6 месяцев по клиенту</h3></td></tr>" skip.

  v-name = "".
  v-name = entry(3, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " " + entry(4, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " " + entry(5, (entry(2, v-gcvptxt, ";")), "|").
  v-name = v-name + " , СИК " + entry(2, (entry(2, v-gcvptxt, ";")), "|").

  put stream m-out unformatted 
     "<tr align=""center""><td><h3>" v-name "</h3></td></tr>" skip
     "<tr><td><h4>Запрос N: " entry(1, v-gcvptxt, ";") "</h4></td></tr>" skip
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
  else
     v-sum = decimal(entry(9, (entry(2, v-gcvptxt, ';')), '|')) * 8.1 + 975.2.
/****************************************************************/

  put stream m-out unformatted 
     "<tr><td><h4>Количество отчислений - " entry(8, (entry(2, v-gcvptxt, ';')), '|') "</td></tr>" skip
     "<tr><td><h4>Средняя сумма отчислений - " entry(9, (entry(2, v-gcvptxt, ';')), '|') " тенге </td></tr>" skip
     "<tr><td><h4>Чистый доход             - " v-sum " тенге</td></tr>" skip.

     if decimal(entry(8, (entry(2, v-gcvptxt, ';')), '|')) < 6 then

    put stream m-out unformatted 
     "<tr></tr><tr align=""center"" ><td color=red><h4><br><br> Заявка вынесена на кредитный комитет !</td></tr>" skip.

end.
else do:

        put stream m-out unformatted 
          "<tr align=""center""><td><br><b>БАЗА ГЦВП НЕ СОДЕРЖИТ СВЕДЕНИЙ ОБ ОБЯЗАТЕЛЬНЫХ ПЕНСИОННЫХ ОТЧИСЛЕНИЯХ<br>ЗА ПОСЛЕДНИЕ 6 МЕСЯЦЕВ ПО ЭТОМУ ВКЛАДЧИКУ<br><br>Статус : " skip.

        find first bookcod where bookcod = "pkgcvp" and bookcod.code = v-sts no-lock no-error.
        if avail bookcod then put stream m-out unformatted bookcod.name.
                         else put stream m-out unformatted "Запрос обработан".

        put stream m-out unformatted "</td></tr>" skip.
end.

put stream m-out unformatted "</table>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if avail pkanketa and pkanketa.id_org = "inet" then unix silent value("mv " + v-file + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-file).
else unix silent cptwin value(v-file) iexplore.

