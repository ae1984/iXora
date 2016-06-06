/* siktest.p
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
*/

/* siktest.p  
Модуль: 
   Потреб. кредиты
Назначение: 
   Процедура проверки СИК по имеющимся фамилии, имени, отчеству и дате рождения
   передается :
   - СИК 
   - фамилия 
   - имя
   - отчество
   - предыдущая фамилия
   - предыдущее имя
   - предыдущее отчество
   - дата рождения
   возвращается 0 - если все нормально, 1 - если ошибка
Вызывается: 
   pkkritlib.p  
Пункты меню: 
   -
Автор: 
   nadejda Лысковская Н.
Дата создания:
   29.01.2003
Протокол изменений:
   04.07.2003 sasco Переделал проверку СИК на скрипт siktst-unix, который вызывает проверку СИК через crric на Юниксе
*/


def input parameter p-sik as char.
def input parameter p-lastname as char.
def input parameter p-firstname as char.
def input parameter p-midname as char.
def input parameter p-plastname as char.
def input parameter p-pfirstname as char.
def input parameter p-pmidname as char.
def input parameter p-birthdt as date.

def var v-result as char.

output to sik.txt.
put unformatted "1|1|" + TRIM(caps(p-sik)) + "|".
if p-plastname = "" then put unformatted TRIM(caps(p-lastname)).
                    else put unformatted TRIM(caps(p-plastname)).
if p-pfirstname = "" then put unformatted TRIM(caps(p-firstname)).
                     else put unformatted TRIM(caps(p-pfirstname)).
if p-pmidname = "" then put unformatted TRIM(caps(p-midname)).
                   else put unformatted TRIM(caps(p-pmidname)).
put unformatted
    string(day(p-birthdt), "99") + 
    string(month(p-birthdt), "99")  + 
    string(year(p-birthdt), "9999") skip.
output close.

input through value("siktst-unix sik.txt;echo $?") no-echo.
set v-result.
input close.

unix silent rm -f sik.txt.
return v-result.
