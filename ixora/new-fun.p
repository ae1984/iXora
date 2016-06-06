/* new-fun.p
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

/* new-fun.p
*/

def shared var s-acc like jl.acc.
def shared var s-gl  like gl.gl.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def shared var rtn as log initial yes.
/*
def new shared var vamtdec as dec.
def new shared var vamtcha as cha.
*/
def var answer as log.
def var v-weekbeg as int.
def var v-weekend as int.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{global.i}

find jh where jh.jh eq s-jh.
find jl where jl.jh eq jh.jh and jl.ln eq s-jl.
find gl where gl.gl eq s-gl.

main:
do transaction on error undo, return:
            create fun.
            fun.fun = s-acc.
            fun.rdt = g-today.
            fun.who = g-ofc.
            fun.gl  = s-gl.
            fun.crc = jl.crc.
            {subadd-pc.i  &sub = "fun"}

            if fun.crc eq 1 then fun.basedy = 365.
            else if fun.crc eq 2 then fun.basedy = 360.
            if gl.grp ne 0
              then do:
                fun.grp = gl.grp.
                display fun.grp with frame fun.
              end.
              else update fun.grp with frame fun.
            update 
                   fun.geo format "x(3)" label "GEO"
                      validate(can-find(geo where geo.geo eq geo)
                      or fun.geo eq "", "")
                       fun.dfb  fun.bank skip
                   fun.amt
                   fun.basedy
                   fun.rdt skip
                   with centered row 7 2 col frame fun
                        title " FUND LEDGER ".
        /* if fun.grp le 10
            then do: */
            update fun.trm with frame fun.
            fun.duedt = fun.rdt + fun.trm.
            repeat:
              find hol where hol.hol eq fun.duedt no-error.
              if not available hol and
   weekday(fun.duedt) ge v-weekbeg and
   weekday(fun.duedt) le v-weekend
                then leave.
                else fun.duedt = fun.duedt + 1.
            end.
            fun.trm = fun.duedt - fun.rdt.
            display fun.trm fun.duedt with frame fun.
            update fun.intrate with frame fun.
            if fun.grp ge 1 and fun.grp le 10
              then do:
                fun.interest = fun.amt * (fun.duedt - fun.rdt)
                              * fun.intrate / fun.basedy / 100.
                display fun.interest with frame fun.
              end.
            update fun.itype fun.iddt fun.rem
              with frame fun.
            
            update
                  fun.zalog  label "ЗАЛОГ ?"
                  fun.lonsec label "ОБЕСП." 
                      validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
                      or fun.lonsec eq 0, "")
                  fun.risk   label "РИСК"
                      validate(can-find(risk where risk.risk eq risk) 
                      or fun.risk eq 0, "")
                  fun.penny  label "ШТРАФ.%" validate(penny <= 100, "") 
            with frame fun.
end.

rtn = no.
