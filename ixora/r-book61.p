/* r-book61.p
 * MODULE
        Выписки по счетам клиентам
 * DESCRIPTION
        Книга регистрации счетов
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
        24.11.2000  pragma
 * CHANGES
        01.02.2002 sasco    - добавлена графа "валюта"
                            - сортировка по номерам счетов (.aaa)
                            - вывод ВСЕХ счетов гл. книги + их даты открытия
                            - запрос на период
        01.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование
        04.11.2003 nataly   - были убраны часть счетов из 61-ой книги
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        11.06.2010 marinav - консолидация
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/

{global.i}
{nbankBik.i}
def new shared var dat1 as date init ?.
def new shared var dat2 as date.

dat2 =  g-today.

define frame datframe
       dat1 label "Начало периода" skip
                  "(Без даты - все счета с начала)" skip
       dat2 label "Конец периода "
       validate(dat2 le g-today, "Неверная дата!")
       with row 2 centered side-labels.

update dat1 dat2 with frame datframe.
hide frame datframe.

define new shared stream m-out.
output stream m-out to "rep.html".
put stream m-out "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"  skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""style=""border-collapse: collapse"">".


{r-brfilial.i &proc = "r-book61f"}



put stream m-out "</table>" skip.
put stream m-out "</body></html>".
output stream m-out close.
unix silent cptwin rep.html excel.



