/* lsci.p
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

def input parameter vprem like lon.prem.
def input parameter vbasedy like lon.basedy.
def input parameter vopnamt like lnsch.stval.
def input parameter vduedt like lnsch.stdat.
def input parameter vregdt like lnsch.stdat.
def input-output parameter flag as inte.
def input-output parameter treci as recid.
def input-output parameter clini as inte.
def shared var s-lon like lnsch.lnn.
def var vnrr like lnsci.f0.
def var vnr1 like lnsci.f0.
def shared frame lonsci.
def shared var svint as char format "x(21)".
def var vint like lnsch.stval.
def var fufu as inte.
def var vans as log.
{mainhead.i}

if flag = 32 then do:
{lsci-mont.i &where = "lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                       and lnsci.f0 > -1" }
clini = 0.
end. flag = 0.

 run lnsci-ren(s-lon).
 run lsci-calc(vprem, vbasedy, vduedt, vregdt, output vint).
/* svint = string(vint, "z,zzz,zzz,zzz,zz9.99-").*/

upper1:
repeat:

{jjbr.i
&start = "if fufu = 0 then do: fufu = 1. trec = treci. clin = clini. end."
&head = "lnsci"
&headkey = "schn"
&where = "lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
          and lnsci.f0 > -1"
&index = "lni"
&formname = "lonsci"
&framename = "lonsci"
&reframe ="if string(vint, ""z,zzz,zzz,zzz,zz9.99-"") <> svint then do:
           svint = string(vint, ""z,zzz,zzz,zzz,zz9.99-"").
           hide frame lonsci. end."
&display = "lnsci.schn lnsci.idat lnsci.iv-sc lnsci.paid-iv"
&postdisplay ="view frame msgi."
&postadd = "repeat: update lnsci.idat with frame lonsci.
if lastkey = 404  or lastkey = 13 then leave. end.
if lastkey = 404 then delete lnsci.
else if lnsci.idat < vregdt or lnsci.idat > vduedt or lnsci.idat = ? then do:
bell. delete lnsci. {imesg.i 422}. pause. end. else do: run lnsci-ren(s-lon).
run lsci-calc(vprem, vbasedy, vduedt, vregdt, output vint). end."
&postkey = "else if lastkey = 49 then do: flag = 11. leave outer. end.
            else if lastkey = 50 then do: flag = 21. leave outer. end.
            else if lastkey = 51 then do: flag = 32. leave outer. end.
else if lastkey = 13 then do: update lnsci.idat with frame lonsci.
       if lnsci.idat > vduedt or lnsci.idat < vregdt then do:
        {imesg.i 422}. pause. bell. undo, next upper1. end.
       else do:        run lnsci-ren(s-lon).
        run lsci-calc(vprem, vbasedy, vduedt, vregdt, output vint).
        next upper1. end.
end. else if lastkey = 310 then do: vans = false. {imesg.i 882} update vans.
    if vans then do: def var nrec as recid.
      if clin = 1 then do:
           if trec = frec then do:
                find next lnsci where lnsci.lni = s-lon and lnsci.flp = 0
                                and lnsci.fpn = 0 and lnsci.f0 > -1 no-error.
                  if available lnsci then nrec = recid(lnsci).
                  else if not available lnsci then clin = 0.
           end.
           else if trec <> frec then do:
                find prev lnsci where lnsci.lni = s-lon and lnsci.flp = 0
                                         and lnsci.fpn = 0 and lnsci.f0 > -1.
                nrec = recid(lnsci).
           end.
       end.
find first lnsci where recid(lnsci) = crec. delete lnsci. if clin = 1 then trec = nrec. run lnsci-ren(s-lon). 
run lsci-calc(vprem, vbasedy, vduedt, vregdt, output vint). next upper1. clear frame lonsci all.
end.
else do: next inner. end.
end."
&addcon = "true"
&precreate = "vnrr = lnsci.f0."
&postcreate = "lnsci.f0 = vnrr + 1. lnsci.lni = s-lon.
               lnsci.schn = string(lnsci.f0,""zzz."")
                          + string(lnsci.fpn,""z."")
                          + string(lnsci.flp,""zzz"")."
&end = "hide frame msgi. leave upper1."
}
end. /* upper1 */

  /* for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and 
      lnsci.fpn = 0 and lnsci.f0 > 0  and lnsci.iv-sc = 0:
      display lnsci.
     delete lnsci.
  end.  */

treci = trec.
clini = clin.
