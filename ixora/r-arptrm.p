/* r-arptrm.p
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

/* r-arptrm.p
*/

{mainhead.i ARPTERM}  /* A/R A/P SUMMARY REPORT BY TERM */

def var v-bal as dec format "zz,zzz,zzz,zzz.99-" label "БАЛАНС ".
def var v-cnt as int format "z,zz9" extent 4.
def var v-amt as dec format "zz,zzz,zzz,zzz.99-" extent 4.
def var v-asof as date label "AS-OF".

v-asof = g-today.

{image1.i rpt.img}
{image2.i}

{report1.i 63}
vtitle = "A/R A/P SUMMARY REPORT BY TERM  AS-OF: " + string(v-asof).

for each arp where arp.dam[1] ne arp.cam[1]
  break by arp.gl by arp.type:

  {report2.i 132}

  find gl where gl.gl eq arp.gl no-lock.
  if first-of(arp.gl) then do:
    display gl.gl gl.des with side-label frame gl.
  end.

  if first-of(arp.type) then do:
    v-cnt = 0.
    v-amt = 0.
  end.

  if gl.type eq "A"
    then v-bal = arp.dam[1] - arp.cam[1].
    else v-bal = arp.cam[1] - arp.dam[1].

  if v-asof - arp.rdt lt 180 then do:
    v-cnt[1] = v-cnt[1] + 1.
    v-amt[1] = v-amt[1] + v-bal.
  end.
  else if v-asof - arp.rdt lt 365 then do:
    v-cnt[2] = v-cnt[2] + 1.
    v-amt[2] = v-amt[2] + v-bal.
  end.
  else do:
    v-cnt[1] = v-cnt[1] + 1.
    v-amt[1] = v-amt[1] + v-bal.
  end.

  v-cnt[4] = v-cnt[4] + 1.
  v-amt[4] = v-amt[4] + v-bal.

  if last-of(arp.type) then do:
    find arptype where arptype.arptype eq arp.type no-lock.
    display arp.type format "999" arptype.des
            v-cnt[1] no-label          (total by arp.gl)
            v-amt[1] label "UNDER 180" (total by arp.gl)
            v-cnt[2] no-label          (total by arp.gl)
            v-amt[2] label "180 - 365" (total by arp.gl)
            v-cnt[3] no-label          (total by arp.gl)
            v-amt[3] label "OVER 365"  (total by arp.gl)
            v-cnt[4] no-label          (total by arp.gl)
            v-amt[4] label "TOTAL "    (total by arp.gl)
    with down width 132.
  end.
end.
{report3.i}
{image3.i}
