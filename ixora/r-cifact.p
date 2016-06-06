/* r-cifact.p
 * MODULE
         Клиенты
 * DESCRIPTION
        Активность клиентов
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
        28/11/10 marinav
 * CHANGES
        19.01.2011 marinav - исправлена ошибка в определении второй даты
        26.09.2011 id00477 - отделил код клиента от его наименования
        07/10/2011 dmitriy - добавил столбцы: вид деятельности, обороты за период, адрес
        13/10/2011 madiyar - v-date
        01/11/2011 dmitriy - убрал изменения от 07/10/11 и 13/10/11 (ОД попросили оставить как было)
                           - создал новый файл r-cifact_b, перенес в п.м. 1-4-1-19 (измененный отчет для СП)
        29/05/2012 dmitriy - добавил столбец "Перечень шифров отраслей экономики"
        22/08/2012 dmitriy - добавил столбец "Электронный адрес"
        17/09/2013 galina - ТЗ 1911 добавила столбец "форма собственности"
        25/11/2013 galina - ТЗ2217 добавила столбец "Счета"
*/


{global.i}

def new shared var v-date as date.
def new shared var v-jl as inte.
def new shared var v-type as char.

def new shared var v-dat1 as date.
def new shared var v-dat2 as date.

def var vyear as inte no-undo.
def var vmonth as inte no-undo.

v-date = g-today.
v-jl = 3.

  update v-date validate (v-date <= g-today, " Неверная дата!")                               label " Дата            " format "99/99/9999" skip
         v-type validate (v-type = "P" or v-type = "B", " Неверный тип ! Введите P или B.")   label " Тип клиента     "  skip
         v-jl                                                                                 label " Кол-во проводок "
         with centered row 5 side-label no-box frame ddd.
  hide frame ddd no-pause.

     vmonth = month(v-date) - 1.
     vyear = year(v-date).
     if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
     v-dat1 = date(vmonth,1,vyear).
     v-dat2 = date(month(v-date),1,year(v-date)).

display "   Ждите...  "  with row 5 frame ww centered .


   define new shared stream m-out.

   output stream m-out to rpt.html.
   put stream m-out "<html><head><title></title>" skip
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""></tr>" skip.
      put stream m-out unformatted "<tr align=""center""><td><b>  Отчет по активным клиентам </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-date) " </td></tr>"  skip(1).

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center"">п/п</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Код клиента</td>". /* 26.09.2011 id00477 */
                       if v-type = 'B' then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Форма собственности</td>".
      put stream m-out unformatted
                       "<td bgcolor=""#C0C0C0"" align=""center"">Наименование клиента</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Счета</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Статус</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сегмент</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">ИИН/БИН</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечень шифров отраслей экономики</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Электронный адрес</td>"
                       "</tr>" skip.

   {r-brfilial.i &proc = "r-cifact1" }


  output stream m-out close.
  unix silent cptwin rpt.html excel.
  pause 0.
