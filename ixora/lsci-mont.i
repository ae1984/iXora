/* lsci-mont.i
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

def var vdat like lnsci.idat.
def var vdat0 like lnsci.idat.
def var vdat1 like lnsci.idat.
def var vyear as inte.
def var vmonth as inte.
def var vday as inte.
def var vvday as inte.
def var mdays as inte.

/*Monthly*/
find first lnsci where {&where} no-error. 
vdat0 = lnsci.idat.
find last lnsci where {&where} no-error. 
vdat = lnsci.idat.

if vdat = vdat0 then vdat = vduedt. 

for each lnsci where {&where}:
    delete lnsci.
end.
vyear = year(vdat0). 
vmonth = month(vdat0). 
vday = day(vdat0).
/*month*/
mon: 
repeat:
    if vmonth = 13 then do: 
        vmonth = 1. vyear = vyear + 1. 
    end.
    vvday = vday.
    run mondays(vmonth,vyear,output mdays).
    if vday > mdays then vvday = mdays.
    vdat1 = date(vmonth,vvday,vyear).
    if vdat1 < vdat0 then do: 
        vmonth = vmonth + 1. 
        next mon. 
    end.
    if vdat1 > vdat then do:
        find first lnsci where {&where} no-error.
        if not available lnsci then do: 
            create lnsci.
            lnsci.lni = s-lon. 
            lnsci.idat = vdat. 
            leave mon.
        end.
        else 
        if available lnsci then do: 
            leave mon. 
        end.
    end.
    create lnsci. 
    lnsci.lni = s-lon. 
    lnsci.idat = vdat1.
    vmonth = vmonth + 1.
/*month*/
end.
/*End Monthly*/

/*duedt comtrol*/
find first lnsci where {&where} and lnsci.idat = vduedt no-error. 
if not available lnsci then do:
    create lnsci. 
    lni = s-lon. 
    lnsci.idat = vduedt.
end. 
release lnsci.


