/* lnsch+0.p
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

{global.i}
def input parameter vjh like jl.jh.
def input parameter vgl like jl.gl.
def input parameter vacc like jl.acc.
def input parameter vtim like jl.tim.
def input parameter vjdt like jl.jdt.
def input parameter vdam like jl.dam.
def input parameter vcam like jl.cam.
find gl where gl.gl = vgl no-lock.
if gl.subled = "lon" then do:
    find lon where lon.lon = vacc no-lock.
    find gl where gl.gl = lon.gl no-lock.
    if vgl = gl.gl then do:
        if vdam = 0 then do:
            find first lnsch where lnsch.jh = vjh and lnsch.fpn = 0
                                         and lnsch.lnn = vacc no-error.
            if available lnsch then do:
                lnsch.paid = lnsch.paid + vcam.
                find first lnsch where lnsch.lnn = vacc and lnsch.flp = -1
                                                  and lnsch.fpn = 0.
                lnsch.paid = lnsch.paid + vcam.
            end.
            else if not available lnsch then do:
                create lnsch. 
                lnsch.lnn = vacc. 
                lnsch.flp = 1. 
                lnsch.paid = vcam.
                lnsch.stdat = vjdt. 
                lnsch.jh = vjh.
                lnsch.whn = g-today. 
                lnsch.who = g-ofc.
                find first lnsch where lnsch.lnn = vacc and lnsch.flp = -1
                                                and lnsch.fpn = 0 no-error.
                if not available lnsch then do:
                    create lnsch. 
                    lnsch.lnn = vacc. 
                    lnsch.flp = -1. 
                    lnsch.paid = vcam.
                end.
                else if available lnsch then lnsch.paid = lnsch.paid + vcam.
            end.
            release lnsch. 
            run lnsch-ren(vacc). 
            run lnsch-upd(vacc).
            run lnreal-iclc(vacc). 
            run lnsci-upd(vacc).
        end.
        else 
        if vcam = 0 then do:
            find first lnscg where lnscg.jh = vjh and lnscg.fpn = 0
                                        and lnscg.lng = vacc no-error.
            if available lnscg then do:
                lnscg.paid = lnscg.paid + vdam.
                find first lnscg where lnscg.lng = vacc and lnscg.flp = -1
                                 and lnscg.fpn = 0 no-error.
                lnscg.paid = lnscg.paid + vdam.
            end.
            else if not available lnscg then do:
                create lnscg. 
                lnscg.lng = vacc. 
                lnscg.flp = 1. 
                lnscg.paid = vdam.
                lnscg.stdat = vjdt. 
                lnscg.jh = vjh.
                lnscg.whn = g-today. 
                lnscg.who = g-ofc.
                find first lnscg where lnscg.lng = vacc and lnscg.flp = -1
                                        and lnscg.fpn = 0 no-error.
                if not available lnscg then do:
                    create lnscg. 
                    lnscg.lng = vacc. 
                    lnscg.flp = -1. 
                    lnscg.paid = vdam.
                end.
                else if available lnscg then lnscg.paid = lnscg.paid + vdam.
            end.
            release lnscg.
            run lnscg-ren(vacc).
            run lnscg-upd(vacc).
            run lnreal-iclc(vacc).
            run lnsci-upd(vacc).
        end.
    end.
    else if vgl = gl.gl1 then do:
        if vtim = 0 then do:
            find first lnsci where lnsci.lni = vacc and lnsci.fpn = 0
                                              and lnsci.jh = vjh no-error.
            if available lnsci then do:
                lnsci.paid-iv = lnsci.paid-iv + vcam.
                find first lnsci where lnsci.lni = vacc and lnsci.flp = -1
                                               and lnsci.fpn = 0.
                lnsci.paid-iv = lnsci.paid-iv + vcam.
            end.
            else if not available lnsci then do:
                create lnsci. 
                lnsci.lni = vacc. 
                lnsci.flp = 1.
                lnsci.jh = vjh. 
                lnsci.paid-iv = vcam.
                lnsci.idat = vjdt. 
                lnsci.whn = g-today.
                lnsci.who = g-ofc.
                find first lnsci where lnsci.lni = vacc and lnsci.flp = -1
                                                    and lnsci.fpn = 0 no-error.
                if available lnsci then lnsci.paid-iv = lnsci.paid-iv + vcam.
                else if not available lnsci then do:
                    create lnsci. 
                    lnsci.lni = vacc. 
                    lnsci.flp = -1.
                    lnsci.paid-iv = vcam.
                end.
            end.
            release lnsci. 
            run lnsci-ren(vacc). 
            run lnsci-upd(vacc).
        end.
        else if vtim = 1 then do:
            find first lnscg where lnscg.lng = vacc
                             and lnscg.jh = vjh and lnscg.fpn = 1 no-error.
            if available lnscg then lnscg.paid = lnscg.paid + vcam.
            else if not available lnscg then do:
                create lnscg. 
                lnscg.lng = vacc. 
                lnscg.flp = 1. 
                lnscg.fpn = 1.
                lnscg.jh = vjh. 
                lnscg.paid = vcam.
                lnscg.stdat = vjdt. 
                lnscg.whn = g-today.
                lnscg.who = g-ofc.
                release lnscg. 
                run lnscg-ren(vacc).
            end.
        end.
        else if vtim = 2 then do:
            find first lnsch where lnsch.lnn = vacc
                             and lnsch.jh = vjh and lnsch.fpn = 1 no-error.
            if available lnsch then lnsch.paid = lnsch.paid + vcam.
            else if not available lnsch then do:
                create lnsch. 
                lnsch.lnn = vacc. lnsch.flp = 1. lnsch.fpn = 1.
                lnsch.jh = vjh. lnsch.paid = vcam.
                lnsch.stdat = vjdt. lnsch.whn = g-today.
                lnsch.who = g-ofc.
            end.
        end.
        else if vtim = 3 then do:
            find first lnsci where lnsci.lni = vacc
                             and lnsci.jh = vjh and lnsci.fpn = 1 no-error.
            if available lnsci then lnsci.paid-iv = lnsci.paid-iv + vcam.
            else if not available lnsci then do:
                create lnsci. 
                lnsci.lni = vacc. lnsci.flp = 1. lnsci.fpn = 1.
                lnsci.jh = vjh. lnsci.paid-iv = vcam.
                lnsci.idat = vjdt. lnsci.whn = g-today.
                lnsci.who = g-ofc.
            end.
        end.
    end.
end.
/*------------------------------------------------------------------------
  #3.
     1.izmai‡a - visur, kur vajag, ielikts find first ... vienk–rЅ–
       find ... viet–, jo programma str–d–ja ne visai korekti
-------------------------------------------------------------------------*/
