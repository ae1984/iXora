/* atvkon.p
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
        31/12/99 pragma
 * CHANGES
        28.01.05 dpuchkov добавил "Отчет по открытым депозитам Ф/Л"
        03.03.05 u00121 добавил "Отчет по депозитам открытым депозитам ФЛ"
        04/05/2010 madiyar - перекомпиляция
*/

/*atvkon.p*/
/*mainhead.i}*/
/*Физические лица - отчет формируется по счетам главной книги*/
/*Отчет по открытым депозитам Ф/Л - формируется по счетам клиентов */

def var menu1 as char extent 4 format "x(50)"
    initial ["Юридические лица","Физические лица","Отчет по открытым депозитам Ф/Л","Отчет по действующим депозитам Ф/Л"].
def var val as character.

disp menu1 with no-label 1 columns centered frame ma.
message "Выберите вид отчета".

choose field menu1 auto-return with frame ma.
hide frame ma.

if frame-value = "Юридические лица" then do:
    run atjur.
end.
if frame-value = "Физические лица" then do:
    run atfiz.
end.


if frame-value = "Отчет по открытым депозитам Ф/Л" then do:
    run xzdep.
end.

if frame-value = "Отчет по действующим депозитам Ф/Л" then do:
    run xzdep2.
end.


