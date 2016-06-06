/* ast_comp.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет по по основным средствам (выч.техника) для выгрузки в excel
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.1.4.7.4
 * AUTHOR
        11.12.2003 igor
 * CHANGES
 	12.01.2004 igor добавил проверку на стоимость ОС
 	23.02.2005 sasco добавил вывод остаточной стоимости
 	09.06.2005 sasco добавил вывод даты окончательного списания
 	10.06.2005 sasco исправил алгоритм поиска даты списания, если О.С. еще не было амортизированно
 	11.09.2005 sasco Добавил дату прихода ОС
*/

{gl-utils.i}

def var vm as int.
def var vy as int.
def var vc as int.
def var ii as int.
def var amort as decimal.
def var perv as decimal.
def var ost as decimal.

 
output to allinv.csv.

put unformatted "Карточка;Группа;Наименование;Примечание;Деп.;Инв.Номер;Местонахождение;Остаточная ст.;Первонач. стоим.;Ежемесячная амортизация;Дата прихода;Месяц списания;Год списания" skip.

for each ast where (ast.dam[1] - ast.cam[1] <> 0) and (
 ast.fag = '310' or ast.fag = '311' or ast.fag = '320' or 
 ast.fag = '340' or ast.fag = '330' or ast.fag = '470' or 
 ast.fag = '511' or ast.fag = '550' or ast.fag = '560' or 
 ast.fag = '561' or ast.fag = '608') :

   perv = ast.amt[3] + ast.salv.
   amort = ast.amt[1].
   ost = ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].

   find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.  
     
   put unformatted ast.ast ';' ast.fag ';' ast.name ';' ast.rem ';' ast.attn.
   put unformatted ';' ast.addr[2] ';' codfr.name[1] ";" 
       XLS-NUMBER (ost) ';' XLS-NUMBER (perv) ';'.
       
   find fagn where fagn.fag = substr (ast.ast, 1, 3) no-lock no-error.
   if not avail fagn then message "Не найдена настройка группы ОС: " substr (ast.ast, 1, 3) view-as alert-box title "".

   if amort = 0 and ost > 0 then amort = perv / (fagn.noy * 12).
   if ost = 0 then amort = 0.

   put unformatted XLS-NUMBER (amort) ';'.

   vm = month (today).
   vy = year (today).

   vc = integer (round(ost / amort, 2)).

   do ii = 1 to vc:
      vm = vm + 1.
      if vm = 13 then assign vm = 1 vy = vy + 1.
   end. /* ii */

   put unformatted ast.rdt ";" vm ";" vy skip.

end. /* each ast */

output close.

run menu-prt('allinv.csv').
