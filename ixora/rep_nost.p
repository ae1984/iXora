/* rep_nost.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{mainhead.i}
def var ddat as date .
def var  su5 like remtrz.payment.
def var v-gl like gl.gl  .
def var v-acc like dfb.dfb .
def var who1 as char format "x(10)".
def var who2 as char format "x(10)".
def var nbank as inte format "zzz9".
def var ntdfb as inte format "zzz9".
DEF VAR den as int init "10".
def var vappend     as logi initial false format "Добавитть/переписать".
def var vprint      as logi initial true.
def var dest        as char format "x(40)" initial "prit".
def var intv like sysc.inval.
def var s-remtrz like remtrz.remtrz.
def var v-bank like remtrz.rbank.
def temp-table brm 
     field  cracc like  remtrz.cracc
     field payment like remtrz.payment.


find sysc where sysc.sysc =  'pspygl' no-lock no-error.
if avail sysc then intv = sysc.inval.

{image1.f}
  ddat = g-today.
  update vappend with frame image1.
  update vprint with frame image1.
  if vprint = true then
  update dest with frame image1.
  update ddat label "ДАТА : "
      /*   v-gl column-label "СЧ.ГлКн "
         validate(can-find (gl  where gl.gl = v-gl), "Не найден  ")*/
         v-acc label "NOSTRO СЧЕТ "
         validate(can-find (DFB where dfb.dfb = v-acc), "Не найден  ")
         with row 8 centered frame dnk.
if vprint = true then do:
{mesg.i 0702}.
if vappend = true then output to rpt.img page-size 59 append.
else output to rpt.img page-size 59.

{rep111.f}

su5 = 0.
for  each  jl where jl.jdt  eq ddat
 and jl.acc = v-acc  and jl.dam > 0 and not jl.rem[1] begins "rmz"
 no-lock by jl.jh.
      su5 = su5 +  jl.dam.
      put jl.jh jl.dam format "zzz,zzz,zzz,zz9.99-"
      jl.who space(3) jl.point format "99"  space(4) jl.depart format "99"
      space(1) trim(jl.rem[1] + ' ' + jl.rem[2]) format "x(40)"
            skip.
 end.
    PUT 
'------------------------------------------------------------------------------'
 skip.
    put "ДЕБЕТ "   space(2) SU5 format "zzz,zzz,zzz,zzz,zz9.99-" skip(1).

put skip(1).
{rep110.f}
su5 = 0.
for  each  jl where jl.jdt  eq ddat
 and jl.acc = v-acc  and jl.cam > 0 and not jl.rem[1] begins "rmz"
  no-lock by jl.jh.
  su5 = su5 +  jl.cam.
  put jl.jh jl.cam format "zzz,zzz,zzz,zz9.99-"
  jl.who space(3) jl.point format "99"  space(4) jl.depart format "99"
  space(1) trim(jl.rem[1] + ' ' + jl.rem[2]) format "x(40)"
  skip.
  end.
PUT

'-----------------------------------------------------------------------------'
 skip.
 put "КРЕДИТ "   space(2) SU5 format "zzz,zzz,zzz,zzz,zz9.99-" skip(1).

output close.
output to terminal.
unix silent value(trim(dest)) rpt.img. 
pause 0.
end.
