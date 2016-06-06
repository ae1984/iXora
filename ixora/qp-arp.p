/* qp-arp.p
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
        16.04.2009 galina - явно указала ширину фрейма f_arp
        28.06.2013 Lyubov - ТЗ 1859, обработка поля ВКЛЮЧИТЬ В СВОДНЫЕ СПРАВКИ
*/

/* q-arp.p
*/

{global.i}  /*  QUERY A/R A/P RECORD  */

def var v-bal as decimal format "zzz,zzz,zzz.99-".
def var parp like arp.rem.
def var bal like arp.dam[1] label "BALANCE".
define query q_arp for arp.
define browse b_arp query q_arp no-lock
       display arp.arp arp.des arp.cif
               arp.dam[1] - arp.cam[1] @ bal

                   with 14 down centered.
define frame f_arp b_arp with width 100.



{q-arp.f}


on "end-error" of browse b_arp
do:
   hide frame f_arp.
end.

on 'return' of b_arp in frame f_arp do:
  if avail arp then do:
    view frame arp.
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
  end.
end.

Message "Введите примечание " update parp.
parp = '*' + parp + '*' .
open query q_arp for each arp where caps(arp.rem) matches caps(parp).
enable all with frame f_arp.
wait-for window-close of frame f_arp.
hide frame f_arp.