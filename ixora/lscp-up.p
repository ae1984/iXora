/* lscp-up.p
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
        16.03.2004 marinav - при изменении графика пишется дата и логин польз-ля
*/

def shared var s-lon like lnsch.lnn.
def input parameter vf0 like lnsch.f0.
def input parameter vregdt like lnsch.stdat.
def input parameter vduedt like lnsch.stdat.
def input parameter vopnamt like lnsch.stval.
def output parameter st as inte initial -1.
def var vnrr like lnsch.f0.
def var vnr1 like lnsch.f0. 
def var vtot like lnsch.stval.
def var vdat like lnsch.stdat.
def shared var s-com like lnsch.comment.
def shared var s-fund like lnsch.paid.
{global.i}

vnrr = vf0.
find lon where lon.lon = s-lon no-lock.
if lon.gua = "LK"
then return.
find first lnsch where lnsch.lnn = s-lon and lnsch.f0 = vf0 
                             and lnsch.flp = 0 and lnsch.fpn = 0. 
vdat = lnsch.stdat.

  for each lnsch where lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                                   and lnsch.f0 > -1: 
       vtot = vtot + lnsch.stval.
  end.

    find last lnsch where lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                                      and lnsch.f0 > -1.
    if vnrr <> lnsch.f0 then do:
      if (vdat > vduedt or vdat < vregdt) and
          lnsch.stval <> 0 then do:
           bell.
           {mesg.i 422}. pause.
           undo, return.
      end.
       lnsch.stval = lnsch.stval + vopnamt - vtot.
      if lnsch.stval < 0 then do:
            bell.
           {mesg.i 423}. pause.
           undo, return.
      end.
      else st = 1.
    end.
    else  if vnrr = lnsch.f0 then do:
      if (vdat > vduedt or vdat < vregdt) and
          lnsch.stval <> 0 then do:
           bell.
           {mesg.i 422}. pause.
           undo, return.
      end.
     if lnsch.stval = vopnamt then do:
        st = 1. return.
     end.
     else do:
       create lnsch.
       lnsch.lnn = s-lon. lnsch.f0 = vnrr + 1. lnsch.comment = s-com.
       lnsch.stdat = vduedt. lnsch.schn = string(lnsch.f0,"zzz.") 
                                        + " .  ". 
       lnsch.stval = vopnamt - vtot.
       lnsch.who = g-ofc. lnsch.whn = g-today.

      if lnsch.stval < 0 then do:
           bell.
           {mesg.i 423}. pause.
           undo, return. 
      end.
      else st = 2.
     end.
    end.
  
/*Zero control*/
for each lnsch where lnsch.lnn = s-lon and lnsch.fpn = 0 
                                  and lnsch.flp = 0 and lnsch.stval = 0:
   delete lnsch.
   st = 3.
end.
run lnsch-ren(s-lon).
/*If O.K. st > 0.*/
/*--------------------------------------------------------
  #3.
     1.izmai‡a - palielin–ts ciparu skaits form–tos
----------------------------------------------------------*/   
