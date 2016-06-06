/* pkgcvprep.p
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
        26.06.2003 nadejda - изменила расчет среднего: делим просто на 6 месяцев, считая что запрос пришел по отчислениям за полгода
        09.10.2003 marinav - вынесение заявки на кредитный комитет
        16.10.2003 MARINAV - для карточек деление на 6, для Быстрых денег - на количество месяцев.
        03.01.2004 nadejda - новый анализ ответа pkanlgcvp.i
        22.01.2004 nadejda - вывод в отчете отклонений от среднего
        29.01.2004 nadejda - результаты анализа отчислений выделены цветом
        18/10/2004 madiyar - перекомпиляция
        03/11/2004 madiyar - при смене названия организации в итоговых данных выводилось старое название - исправил
        18/11/2004 madiyar - в отчете выдается дата отправки запроса
        03/04/2006 madiyar - для анализа используется только часть платежей, а на печать выводятся все
        24/04/2007 madiyar - веб-анкеты
        25/04/2007 madiyar - не выводился отчет по обычным анкетам, исправил
*/


{global.i}
{pk.i}
{pk-sysc.i}

def input parameter p-gcvptxt as char.
def input parameter p-katjob as char.
/*
def input parameter v-code as char.
def var v-nal as decimal.
*/

/*def var v-gcvptxt as char.
v-gcvptxt = "000000009;AGE65JVA0RV0S00J|АНДРУСЕНКО|МАРИНА|ВЛАДИМИРОВНА|25.06.1975|0;28.11.2002|600300001170|АО "TEXAKABANК"|600900050984|190501914|2|14344;27.12.2002|600300001170|АО "TEXAKABANК"|600900050984|190501914|2|14398;28.01.2003|600300001170|АО "TEXAKABANК"|600900050984|190501914|2|14793.9".
*/

def var coun as inte.
/*
def var v-entry as inte.    / *разделитель ; * /
def var v-entry1 as inte.   / *разделитель | * /
def var i as inte.
def var v-str as char.
*/
def var v-name as char.
def var v-payname as char.
def var v-sum as deci.
def var v-file as char init "gcvp.html".
def var v-month as inte.
def var v-date1 as date.
def var v-date2 as date.
define var v-rnn as char.
define var v-mon as inte.
define var v-monn as inte.
/*DEFINE var l-kred as logi.*/


{pkanlgcvp.i}

find first cmp no-lock no-error.

define stream m-out.
output stream m-out to value(v-file).

put stream m-out unformatted "<!-- ГЦВП-отчет -->" skip.

{html-title.i &stream = "stream m-out" &title = "Результат запроса в ГЦВП" &size-add = "x-"}

put stream m-out unformatted 
  "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
  "<br><br><tr align=""left""><td><h3>" cmp.name "</h3></td></tr><br><br>" skip
  "<tr align=""center""><td><h3>Пенсионные платежи, прошедшие через ГЦВП за последние 6 месяцев по клиенту</h3></td></tr>" skip.

if v-ansexist then do:
  v-name = "".
  if num-entries(v-header, "|") >= 4 then v-name = entry(4, v-header, "|").
  if num-entries(v-header, "|") >= 5 then v-name = v-name + " " + entry(5, v-header, "|").
  if num-entries(v-header, "|") >= 6 then v-name = v-name + " " + entry(6, v-header, "|").
  if num-entries(v-header, "|") >= 3 then v-name = v-name + " , СИК " + entry(3, v-header, "|").

  put stream m-out unformatted 
     "<tr align=""center""><td><h3>" v-name "</h3></td></tr>" skip
     "<tr><td><h4>Запрос N: " entry(1, p-gcvptxt, ";") "</h4></td></tr>" skip
     "<tr><td><h4>Дата отправки запроса: " v-qdt format "99/99/9999" "</td></tr>" skip
     "<tr><td>&nbsp;</td></tr>" skip.

  if v-ansfull then do:
    if v-anssts = "0" then do:
      
      put stream m-out unformatted 
        "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
        "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"">" skip
                       "<td>N п/п</td>"
                       "<td>Дата</td>"
                       "<td>РНН<BR>плательщика</td>"
                       "<td>Плательщик</td>"
                       "<td>Пенс.<BR>фонд</td>"
                       "<td>Сумма/<br>Итого</td>"
                       "<td>Средняя<BR>сумма</td>"
                       "<td>Чистый<BR>доход</td>" 
                       "<td>% отклонение<BR>от среднего/<BR>по предприятию</td>" 
                       "<td>% среднее<BR>отклонение<BR>по превыш.суммам</td>" 
                       "</tr>" skip.

      find first t-ansgcvp no-lock no-error.
      if avail t-ansgcvp then do:
        /* показать данные ответа */

        for each t-ansgcvp_full use-index num:
          put stream m-out unformatted 
              "<tr align=""right"">" skip
                   "<td " if t-ansgcvp_full.anlz then "style=""font:bold"" " else "" "align=""center"">" t-ansgcvp_full.num "</td>" skip
                   "<td " if t-ansgcvp_full.anlz then "style=""font:bold"" " else "" "align=""left"">" t-ansgcvp_full.paydt "</td>" skip
                   "<td align=""left"">&nbsp;" t-ansgcvp_full.rnn "</td>" skip
                   "<td align=""left"">" t-ansgcvp_full.payname "</td>" skip
                   "<td>" t-ansgcvp_full.fond "</td>" skip
                   "<td>" replace(trim(string(t-ansgcvp_full.sum, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td>&nbsp;</td>" skip
                   "<td>&nbsp;</td>" skip
                   "<td>" if t-ansgcvp_full.delta < 0 then "&nbsp;" else replace(trim(string(t-ansgcvp_full.delta * 100, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td>" if t-ansgcvp_full.delta1 < 0 then "&nbsp;" else replace(trim(string(t-ansgcvp_full.delta1 * 100, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "</tr>" skip.
        end.

        /* показать средние суммы по предприятиям-плательщикам */
        for each t-result use-index main:
          
          v-sum = 0.
          v-payname = "".
          find last t-ansgcvp where t-ansgcvp.rnn = t-result.rnn no-lock no-error.
          if avail t-ansgcvp then do:
            v-payname = t-ansgcvp.payname.
            for each t-ansgcvp where t-ansgcvp.rnn = t-result.rnn no-lock:
              accumulate t-ansgcvp.sum (total).
            end.
            v-sum = accum total t-ansgcvp.sum.
          end.

          put stream m-out unformatted 
              "<tr align=""right"" style=""font:bold"">" skip
                   "<td>&nbsp;</td>" skip
                   "<td align=""center"">ИТОГО</td>" skip
                   "<td align=""left"">&nbsp;" t-result.rnn "</td>" skip
                   "<td align=""left"">" v-payname "</td>" skip
                   "<td>&nbsp;</td>" skip
                   "<td>" replace(trim(string(v-sum, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td>" replace(trim(string(t-result.sumavg, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td>" replace(trim(string(t-result.sumdohod, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td style=""color:" if t-result.delta > v-delta then "red" else "green" """>" replace(trim(string(t-result.delta * 100, ">>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
                   "<td>&nbsp;</td>" skip
                   "</tr>" skip.
        end.

        put stream m-out unformatted "</table></td></tr>" skip.

        if v-kred = 1 then do:
          put stream m-out unformatted 
            "<br><br><tr align=""center""><td><h3> Кредит будет вынесен на кредитный комитет</h3></td></tr>" skip.
        end.
      end.
      else do:
        /* нет данных в ответе */
        put stream m-out unformatted 

          "<tr align=""center""><td><br><b>БАЗА ГЦВП НЕ СОДЕРЖИТ СВЕДЕНИЙ ОБ ОБЯЗАТЕЛЬНЫХ ПЕНСИОННЫХ ОТЧИСЛЕНИЯХ<br>ЗА ПОСЛЕДНИЕ 6 МЕСЯЦЕВ ПО ЭТОМУ ВКЛАДЧИКУ<br><br>Статус : " skip.

        find first bookcod where bookcod = "pkgcvp" and bookcod.code = v-anssts no-lock no-error.
        if avail bookcod then put stream m-out unformatted bookcod.name.
                         else put stream m-out unformatted "Запрос обработан".

        put stream m-out unformatted "</td></tr>" skip.
      end.
    end.
    else do:
      /* ГЦВП вернул какую-то ошибку */
      put stream m-out unformatted "<tr align=""center""><td><h3> ОШИБКА: <h3></td><td>".
       
      find first bookcod where bookcod = "pkgcvp" and bookcod.code = v-anssts no-lock no-error.
      if avail bookcod then put stream m-out unformatted bookcod.name.
                       else put stream m-out unformatted "Неизвестная ошибка".

      put stream m-out unformatted "</td></tr>" skip.
    end.
  end.
  else do:
    /* что-то не то вернул ГЦВП :-( */
    put stream m-out unformatted "<tr align=""center""><td><h3> ОШИБКА: <h3></td><td>Недостаточно данных в заголовке ответа ГЦВП !</td></tr>" skip.
  end.
end.
else do:
  /* а нету ответа! */
  put stream m-out unformatted 
    "<tr align=""center""><td><h3>Не выполнен импорт ответа ГЦВП в ПРАГМУ</h3></td></tr>" skip.
end.


put stream m-out unformatted "</table>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if avail pkanketa and pkanketa.id_org = "inet" then unix silent value("mv " + v-file + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-file).
else unix silent cptwin value(v-file) excel.

