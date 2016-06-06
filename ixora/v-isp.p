/* v-isp.p
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

define var v-cashgl like gl.gl.
def var v-cash  as logi.
def shared var s-remtrz like remtrz.remtrz .

find first remtrz where remtrz.remtrz  = s-remtrz  no-lock .


  run v-rmtrxv.
  
pause 0.        
    find sysc where sysc.sysc eq "CASHGL" no-lock.
    v-cash = no.
    for each jl where jl.jh eq remtrz.jh1 no-lock.
        if jl.gl eq sysc.inval then v-cash = true.
    end.
 
    do transaction :
    for each jl where jl.jh eq remtrz.jh1 exclusive-lock :
        if jl.sts ne 6 then  do:
        if v-cash  then do :
          jl.sts = 5. 
          run chgsts(input "rmz", remtrz.remtrz, "cas").
        end.  
            else do:
            run chgsts(input "rmz", remtrz.remtrz, "rdy").
            jl.sts = 6. jl.teller = g-ofc.
            end.
        end.
    end.

    find jh where jh.jh eq remtrz.jh1 exclusive-lock.
    if jh.sts ne 6 then do:
    if v-cash  then jh.sts = 5.
     else jh.sts = 6.
    end.
  end. 
  pause 0. 
