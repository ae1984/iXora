/* kzrepave-dat2.p
 * MODULE
        7.4.3.7.2 Операции с нал. ин. вал. в разрезе филиалов
 * DESCRIPTION
        Описание
 * RUN
        kzrepave-dat
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        05.12.2011 aigul
 * BASES
        BANK
 * CHANGES
*/
def input parameter p-mi as char.
def input parameter p-ma as char.
def output parameter p-min as decimal.
def output parameter p-max as decimal.
def var a as char.
def var a1 as char.
def var a2 as char.
def var a3 as char.
def var i as int.
def var n as int.
/*buy*/
/*min*/
i = 0.
a = "".
a1 = "".
a2 = "".
a3 = "".
n = num-entries(p-mi).
a3 = entry(1,p-mi).
do i = 1 to n:
    if a <> "" and deci(a3) > deci(a) then a3 = a.
    a1 = entry(i,p-mi).
    if i + 1 > n then i = n.
    a2 = entry(i,p-mi).
    a = min(a1,a2).
end.
p-min = min(deci(a3),deci(a)).
/*max*/
i = 0.
a = "".
a1 = "".
a2 = "".
a3 = "".
n = num-entries(p-ma).
a3 = entry(1,p-ma).
do i = 1 to n:
    if deci(a3) < deci(a) then a3 = a.
    a1 = entry(i,p-ma).
    if i + 1 > n then i = n.
    a2 = entry(i,p-ma).
    a = max(a1,a2).
end.
p-max = max(deci(a3),deci(a)).

