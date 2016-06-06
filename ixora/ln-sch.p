/* ln-sch.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Пересчет графиков после изменений суммы, даты или %%
 * RUN
        без папаметров
 * CALLER
        s-lonrd
        s-lonrdu
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        31/12/99 pragma
 * CHANGES
        16.09.2006 marinav  поправила некоторые косяки ( input-output flag)
        22/12/11 kapar изменил уловие с "<" на "<=" в (dlopnamt <= *.stval) чтобы узбежать бесконечных циклов
*/

def var vduedt like lnscg.stdat.
def var vregdt like lnscg.stdat.
def var vopnamt like lnscg.stval.
def var vprem like lon.prem.
def var vbasedy like lon.basedy.
def var flag as inte.
def shared var s-lon like lnsch.lnn.
def shared var st as inte initial 0.
def new shared var s-vint like lnsci.iv.
def new shared frame lonscp.
def new shared frame lonsci.
def new shared frame lonscg.
def new shared var svopnamt as char format "x(21)".
def new shared var svint as char format "x(21)".
def new shared var svduedt as char format "x(10)".
def new shared var svregdt as char format "x(10)".
def new shared var vshift as inte initial 30.
def var vf0 like ln%his.f0.
def var vint like lnsci.iv.
def var viss like lnscg.stval initial 0.
def var trecp as recid.
def var trecg as recid.
def var treci as recid.
def var clinp as inte.
def var cling as inte.
def var clini as inte.
{global.i}
flag = 21.
{lonscg.f}
{lonscp.f}
{lonsci.f}
find lon where lon.lon = s-lon.
vopnamt = maximum(lon.opnamt - lon.cam[1],lon.dam[1] - lon.cam[1]).
if lon.gua = "CL"
then vopnamt = lon.opnamt.
if lon.gua = "OD"
then do:
     find aaa where aaa.aaa = lon.lcr no-lock.
     vopnamt = aaa.opnamt.
end.
if lon.gua = "LK"
then do:
     find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock.
     vopnamt = lon.opnamt - lonhar.rez-dec[2] -
               lonhar.rez-dec[3] * lon.opnamt / 100.
end.
vduedt = lon.duedt. vregdt = lon.rdt.
vbasedy = lon.basedy. vprem = lon.prem.
{lsch-ini.i}
{lsch.i
 &where-i = "lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.fpn = 0
                               and lnsci.f0 > -1"
 &where-g = "lnscg.lng = s-lon and lnscg.flp = 0 and lnscg.fpn = 0
                               and lnscg.f0 > -1"
 &where-h = "lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.fpn = 0
                               and lnsch.f0 > -1"                  }
start: repeat:
  if flag = 11 then do:
   run lscg(vduedt, vregdt, vopnamt, output flag
           , input-output trecg, input-output cling).
     next start.
  end.
  if flag = 21 then do:
       run lscp(vduedt, vregdt, vopnamt, input-output flag
               , input-output trecp, input-output clinp).
       next start.
  end.
  else if flag = 31 or flag = 32 then do:
     run lsci(vprem, vbasedy, vopnamt, vduedt, vregdt, input-output flag
             , input-output treci, input-output clini).
     next start.
  end.
     hide frame lonscp. hide frame lonsci. leave start.
end.
if lon.dam[1] > 0 then do:
 release lnsci. release lnsch. release lnscg.
 run lnreal-iclc(s-lon).
 run lnscg-upd(s-lon).
 run lnsch-upd(s-lon).
 run lnsci-upd(s-lon).
end.
/* run put-shis("lnsch").
run put-shis("lnsci"). */
/*-----------------------------------------------------------------------------
  #3.
     1.izmai‡a - kalend–ru formё pёc atlikuma,ja kredЁts jau izdots
     2.izmai‡a - formё procentu kalend–ra vёsturi
     3.izmai‡a - atceµ izmai‡as 1 un 2
     4.izmai‡a - kalend–ra atЅ±irЁga formёЅana LO un CL (vopnamt)
------------------------------------------------------------------------------*/
