/* vcrepk8r.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        16.07.2012 damir - подкинул, добавил wrkTemp..
        05.03.2013 damir - Внедрено Т.З. № 1713.
*/
{global.i}
{vcrepk8var.i "new"}

def input parameter p-option as char.

def var i as int.

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
    v-month = 12.
    v-god = v-god - 1.
end.
else v-month = v-month - 1.

update skip(1)
v-month label "     Месяц " skip
v-god label   "       Год " skip(1)
with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

v-dt1 = date(v-month, 1, v-god).

case v-month:
    when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then i = 31.
    when 4 or when 6 or when 9 or when 11 then i = 30.
    when 2 then do:
        if v-god mod 4 = 0 then i = 29.
        else i = 28.
    end.
end case.

v-dt2 = date(v-month, i, v-god).

find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then s-bnkbin = sysc.chval.
else do: message "Не найден БИН банка!!!" view-as alert-box buttons ok. return. end.

{r-brfilial.i &proc = " vcrepk8dat(input txb.bank) "}

if p-option = "rep" then run vcrepk8out.
else run vcrepk8msg.

hide all no-pause.
pause 0.
