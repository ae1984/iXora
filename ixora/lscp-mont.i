/* lscp-mont.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Пересчет всего графика ОД
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
        16.03.2004 marinav - при изменении графика пишется дата и логин польз-ля
*/

def var vdat like lnsch.stdat.
def var vdat0 like lnsch.stdat.
def var vdat1 like lnsch.stdat.
def var vopn like lnsch.stval.
def var vopn0 like lnsch.stval.
def var vopn1 like lnsch.stval.
def var vyear as inte.
def var vmonth as inte.
def var vday as inte.
def var vvday as inte.
def var mdays as inte.

/*Monthly*/
find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 
       and lnsch.fpn = 0 and lnsch.f0 > -1 no-error. 
vdat0 = lnsch.stdat.
vopn0 = lnsch.stval.
vopn = 0.

/*find last lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 
       and lnsch.fpn = 0 and lnsch.f0 > -1 no-error. 
vdat = lnsch.stdat.*/

vdat = vduedt. 

for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 
          and lnsch.fpn = 0 and lnsch.f0 > -1:
    delete lnsch.
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
        find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                       and lnsch.f0 > -1 no-error.
        if not available lnsch then do: 
            create lnsch.
            lnsch.lnn = s-lon. 
            lnsch.stdat = vdat. 
            lnsch.stval = vopnamt.
            lnsch.who = g-ofc. lnsch.whn = g-today.  
            leave mon.
        end.
        else 
        if available lnsch then do: 
            leave mon. 
        end.
    end.
 
    create lnsch. 
    lnsch.lnn = s-lon. 
    lnsch.stdat = vdat1.
    lnsch.f0 = 1.
    lnsch.who = g-ofc. lnsch.whn = g-today.
    if vopnamt - vopn >= vopn0 then do:
       lnsch.stval = vopn0.
       vopn = vopn + vopn0.
    end.
    else do:
       lnsch.stval = vopnamt - vopn.
       vopn = vopnamt.
    end.
    vmonth = vmonth + 1.
    

/*month*/
end.
/*End Monthly*/

/*duedt comtrol*/

find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                       and lnsch.f0 > -1 and lnsch.stdat = vduedt no-error. 
if not available lnsch then do:
    create lnsch. 
    lnn = s-lon. 
    lnsch.stdat = vduedt.
    lnsch.stval = vopnamt - vopn.
    lnsch.f0 = 1.
    lnsch.who = g-ofc. lnsch.whn = g-today.
end. 
else lnsch.stval = vopnamt - vopn + vopn0.

run lnsch-ren(s-lon).
release lnsch.         


