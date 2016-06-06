/* lscg-up.p
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

def shared var s-lon like lnscg.lng.
def input parameter vf0 like lnscg.f0.
def input parameter vregdt like lnscg.stdat.
def input parameter vduedt like lnscg.stdat.
def input parameter vopnamt like lnscg.stval.
def output parameter st as inte initial -1.
def var vnrr like lnscg.f0.
def var vnr1 like lnscg.f0. 
def var vtot like lnscg.stval.
def var vdat like lnscg.stdat.
{global.i}

vnrr = vf0.
  find first lnscg where lng = s-lon and lnscg.f0 = vf0 and lnscg.flp = 0
                                     and lnscg.fpn = 0.
vdat = lnscg.stdat.
  
  for each lnscg where lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
                                                     and lnscg.f0 > -1: 
     vtot = vtot + lnscg.stval.
  end.

    find last lnscg where lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
                                                        and lnscg.f0 > -1.
    if vnrr <> lnscg.f0 then do:
      if (vdat > vduedt or vdat < vregdt) and
	  lnscg.stval <> 0 then do:
           bell.
	   {mesg.i 422}. pause.
	   undo, return.
      end.
       lnscg.stval = lnscg.stval + vopnamt - vtot.
      if lnscg.stval < 0 then do:
           bell.
	   {mesg.i 423}. pause.
	   undo, return.
      end.
      else st = 1.
    end.
    else  if vnrr = lnscg.f0 then do:
      if (vdat > vduedt or vdat < vregdt) and
	  lnscg.stval <> 0 then do:
           bell.
	   {mesg.i 422}. pause.
           undo, return.
          end.
    if lnscg.stval = vopnamt then do:
       st = 1. return.
    end.
    else do:
       create lnscg.
       lnscg.lng = s-lon. lnscg.f0 = 1.
       lnscg.stdat = vduedt. 
       lnscg.stval = vopnamt - vtot.
      if lnscg.stval < 0 then do:
           bell.
	   {mesg.i 423}. pause.
	   undo, return. 
      end.
      else st = 2.
    end.
    end.
  
for each lnscg where lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
                                       and lnscg.stval = 0:
   delete lnscg.
   st = 3.
 end.
release lnscg.
run lnscg-ren(s-lon).
run lnscg-upd(s-lon).

/*If O.K. st > 0.*/   
