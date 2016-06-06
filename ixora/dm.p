/* dm.p
 * MODULE
        Монитор дебиторов для Департамента Налогового Планирования и Департамента Внутрибанковских Операций
 * DESCRIPTION
        Запускает разные виды отчетов по дебиторам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        dm1, dm0
 * MENU
        6.10
 * AUTHOR
        10/01/04 suchkov
 * CHANGES

*/

define variable i as integer initial 0.

run sel2 (" ВЫБЕРИТЕ ТИП ОТЧЕТА ", 
   " 1. ПРЕДВАРИТЕЛЬНЫЙ ОТЧЕТ | 2. КНИГА ПОКУПОК | 3. РЕЕСТР СЧЕТОВ-ФАКТУР", output i).

case i: 
    when 1 then run dm1.
    when 2 then run dm0.
    when 3 then run dm2.
end case. 
