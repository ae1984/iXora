/* lnscgupd.p
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

def input parameter s-lon like lon.lon.
def var v-paid like lnscg.paid.

for each lnscg where lnscg.lng = s-lon 
    and lnscg.flp gt 0 and lnscg.fpn eq 0 and lnscg.f0 eq 0 :
    v-paid = v-paid + lnscg.paid.
end.

for each lnscg where lnscg.lng = s-lon 
    and lnscg.flp = 0 and lnscg.fpn = 0 and lnscg.f0 > -1:
    if v-paid gt lnscg.stval then do :
        v-paid = v-paid - lnscg.stval.
        lnscg.paid = 0.
    end.
    else do :
        lnscg.paid = lnscg.stval - v-paid.
        v-paid = 0.
    end.    
end.



