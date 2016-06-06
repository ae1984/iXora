/* lnsch-0.p
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
                                                 and lnsch.lnn = vacc.
        lnsch.paid = lnsch.paid - vcam.
        find first lnsch where lnsch.lnn = vacc and lnsch.flp = -1
                                                and lnsch.fpn = 0.
        lnsch.paid = lnsch.paid - vcam.
        release lnsch. run lnsch-ren(vacc). run lnsch-upd(vacc).
                       run lnreal-iclc(vacc). run lnsci-upd(vacc).
      end.
      else if vcam = 0 then do:
        find first lnscg where lnscg.jh = vjh and lnscg.fpn = 0
                                                and lnscg.lng = vacc.
        lnscg.paid = lnscg.paid - vdam.
        find first lnscg where lnscg.lng = vacc and lnscg.flp = -1
                                                and lnscg.fpn = 0.
        lnscg.paid = lnscg.paid - vdam.
        release lnscg. run lnscg-ren(vacc). run lnscg-upd(vacc).
                       run lnreal-iclc(vacc). run lnsci-upd(vacc).
      end.
    end.
    else if vgl = gl.gl1 then do:
      if vtim = 0 then do:
        if vdam = 0 then do:
          find first lnsci where lnsci.lni = vacc and lnsci.fpn = 0
                                                    and lnsci.jh = vjh.
          lnsci.paid-iv = lnsci.paid-iv - vcam.
          find first lnsci where lnsci.lni = vacc and lnsci.flp = -1
                                                  and lnsci.fpn = 0.
          lnsci.paid-iv = lnsci.paid-iv - vcam.
        end.
        else if vcam = 0 then do:
          find first lnsci where lnsci.lni = vacc and lnsci.fpn = 0
                                            and lnsci.jh = vjh no-error.
          if available lnsci then lnsci.paid-iv = lnsci.paid-iv + vdam.
          else if not available lnsci then do:
            create lnsci. lnsci.lni = vacc. lnsci.flp = 1.
                          lnsci.jh = vjh. lnsci.paid-iv = vdam.
                          lnsci.idat = vjdt. lnsci.whn = g-today.
                          lnsci.who = g-ofc.
          end.
       end.  
       release lnsci. run lnsci-ren(vacc). 
       run lnsci-upd(vacc).
      end.
      else if vtim = 1 then do:
          find first lnscg where lnscg.lng = vacc
                             and lnscg.jh = vjh and lnscg.fpn = 1.
          lnscg.paid = lnscg.paid - vcam.
          release lnscg. run lnscg-ren(vacc). run lnscg-upd(vacc).
      end.
      else if vtim = 2 then do:
          find first lnsch where lnsch.lnn = vacc
                             and lnsch.jh = vjh and lnsch.fpn = 1.
          lnsch.paid = lnsch.paid - vcam.
      end.
      else if vtim = 3 then do:
          find first lnsci where lnsci.lni = vacc
                             and lnsci.jh = vjh and lnsci.fpn = 1.
          lnsci.paid-iv = lnsci.paid-iv - vcam.
      end.
    end.
end.
