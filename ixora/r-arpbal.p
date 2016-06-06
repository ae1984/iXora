/* r-arpbal.p
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
        06/09/06 marinav - вывод в winword для уменьшения нагрузки и времени.
*/

/* r-arpbal.p
*/

{mainhead.i ARPBAL}  /* A/R A/P OUTSTANDING REPORT */

def var v-bal as dec format "zz,zzz,zzz,zzz.99-" label "BALANCE ".
def var v-asof as date label "AS-OF".

v-asof = g-today.

define variable vimgfname   as character format "x(12)".

vimgfname = "./rpt.img".
unix silent rm -f value(vimgfname).

{report1.i 63}
vtitle = "ОТЧЕТ ПО СЧЕТАМ !!!! : " + string(v-asof).

for each arp where arp.dam[1] ne arp.cam[1] break by arp.gl:

  find gl where gl.gl eq arp.gl no-lock.
  if first-of(arp.gl) then do:
    display gl.gl gl.des with side-label frame gl.
  end.

  if gl.type eq "A"
    then v-bal = arp.dam[1] - arp.cam[1].
    else v-bal = arp.cam[1] - arp.dam[1].

  display
    arp.arp
    arp.rdt
    arp.type format "999"
    arp.des
    arp.cif
    v-bal (total by arp.gl)
    with down width 132.         
end.
{report3.i}
unix silent value ("cptwin rpt.img winword").

