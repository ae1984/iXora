/* q-arpacr.p
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

/* q-arpacr.p
*/


{mainhead.i ARPACR0}  /*  QUERY A/R A/P RECORD  */

def var v-bal as decimal format "z,zzz,zzz,zzz,zz9.99-".
def var acrbal like jl.dam.

{q-arpacr.f}
view frame arp.

main: repeat:
  prompt-for arp.arp with frame arp.
  find arp using arp.arp no-error.
  if not available arp
    then do:
      bell.
      {mesg.i 0230}.
      undo, retry.
    end.
  find gl where gl.gl eq arp.gl no-lock.
  if gl.type eq "A"
    then v-bal = arp.dam[1] - arp.cam[1].
    else v-bal = arp.cam[1] - arp.dam[1].
    acrbal = arp.cam[3] - arp.dam[3].

  display arp.arp
          arp.gl gl.sname
          arp.crc
          arp.type
          arp.geo format "x(3)"
          arp.cgr
          arp.zalog
          arp.rdt
          arp.duedt
          arp.des
          arp.dam[1]
          arp.cam[1]
          v-bal
        /*  arp.rem */
          arp.ncrc[3]
          acrbal
          arp.lonsec
          arp.risk
          arp.penny
          arp.cif
          arp.sts
          with frame arp.

          {q-arpjl3.f}

  clear frame jl all no-pause.
  for each jl where jl.gl eq gl.glacr and jl.acc eq arp.arp no-lock by jl.jdt:
    display jl.jdt jl.dam jl.cam jl.jh jl.who
      jl.rem[1]
      with frame jl.
    down with frame jl.
  end.
end. /* main */
