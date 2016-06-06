/* kzrepave-dat1.p
 * MODULE
        7.4.3.7.2 Операции с нал. ин. вал. в разрезе филиалов
 * DESCRIPTION
        Описание
 * RUN
        kzrepave
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
def input parameter b as char.
def input parameter s as char.
def output parameter buymin as decimal.
def output parameter buymax as decimal.
def output parameter sellmin as decimal.
def output parameter sellmax as decimal.

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
n = num-entries(b).
a3 = entry(1,b).
do i = 1 to n:
    if a <> "" and deci(a3) > deci(a) then a3 = a.
    a1 = entry(i,b).
    if i + 1 > n then i = n.
    a2 = entry(i,b).
    a = min(a1,a2).
end.
buymin = min(deci(a3),deci(a)).
/*max*/
i = 0.
a = "".
a1 = "".
a2 = "".
a3 = "".
n = num-entries(b).
a3 = entry(1,b).
do i = 1 to n:
    if deci(a3) < deci(a) then a3 = a.
    a1 = entry(i,b).
    if i + 1 > n then i = n.
    a2 = entry(i,b).
    a = max(a1,a2).
end.
buymax = max(deci(a3),deci(a)).

/*sell*/
/*min*/
i = 0.
a = "".
a1 = "".
a2 = "".
a3 = "".
n = num-entries(s).
a3 = entry(1,s).
do i = 1 to n:
    if a <> "" and deci(a3) > deci(a) then a3 = a.
    a1 = entry(i,s).
    if i + 1 > n then i = n.
    a2 = entry(i,s).
    a = min(a1,a2).
end.
sellmin = min(deci(a3),deci(a)).
/*max*/
i = 0.
a = "".
a1 = "".
a2 = "".
a3 = "".
n = num-entries(s).
a3 = entry(1,s).
do i = 1 to n:
    if deci(a3) < deci(a) then a3 = a.
    a1 = entry(i,s).
    if i + 1 > n then i = n.
    a2 = entry(i,s).
    a = max(a1,a2).
end.
sellmax = max(deci(a3),deci(a)).