/* q-arp.p
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
        28.06.2013 Lyubov - ТЗ 1859, обработка поля ВКЛЮЧИТЬ В СВОДНЫЕ СПРАВКИ
*/


/* q-arp.p
*/

{mainhead.i ARPORY}  /*  QUERY A/R A/P RECORD  */

def var v-bal as decimal format "zzz,zzz,zzz.99-".

{q-arp.f}
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
  if arp.spby = "" then v-spbyname = "".
  else do:
    find b-arp where b-arp.arp = arp.spby no-lock no-error.
    v-spbyname = b-arp.des.
  end.
  if arp.reason = "" then v-reasonbank = "".
  else do:
    find bankl where bankl.bank = arp.reason no-lock no-error.
    if avail bankl then v-reasonbank = bankl.name.
  end.

  find first codfr where codfr.codfr = 'casvnbal' and codfr.name[1] matches '*' + arp.arp + '*' no-lock no-error.
  if avail codfr then v-sprav = yes.

  display arp.arp
          arp.gl gl.sname
          arp.type
          arp.rdt
          arp.duedt
          arp.des
          arp.dam[1]
          arp.cam[1]
          v-bal
          arp.rem
          arp.cif
          arp.sts
          arp.geo format "x(3)"
          arp.cgr
          arp.zalog
          arp.lonsec
          arp.risk
          arp.penny
          arp.spby
          v-spbyname
          arp.reason
          v-reasonbank
          v-sprav
          with frame arp.

          {q-arpjl.f}

  clear frame jl all no-pause.
  for each jl where jl.gl eq gl.gl and jl.acc eq arp.arp no-lock by jl.jdt:
    display jl.jdt jl.dam jl.cam jl.jh jl.who
      jl.rem[1]
      with frame jl.
    down with frame jl.
  end.
end. /* main */
