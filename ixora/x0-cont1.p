/* x0-cont1.p
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
        13.07.2005 dpuchkov перекомпиляция
        27/09/2011 dmitriy - перекомпиляция в связи с изменением x-cash0.f
        10/11/2011 dmitriy - перекомпиляция в связи с изменением x-cash0.f
        28/11/2011 Luiza добавила проставление кассплана для счета 100500
        29/11/2011 dmitriy - перекомпиляция
        01/12/2011 lyubov - добавила chbin.i
        02/20/2012 lyubov - исправила выборку символов касплана
        09/02/2012 dmitriy - перекомпиляция в связи с изменением x-cash0.f


*/


/* x0-cont1.p
   based on x0-cont.p
   changes:
           не требуется ввод номера транзакции
*/



{global.i}
{comm-txb.i}
{chbin.i}

def temp-table tcash field ln like jl.ln
field lnln as int
field code like crc.code
field damcam like jl.dam
field sim like cashpl.sim field des like cashpl.des index qq ln lnln .

def var i as int.
def var ttt as cha format "x(40)".
def var d-amt like aal.amt.
def var c-amt like aal.amt.
def var v-amt like jl.dam.
def var what as cha format "x(15)".
def var icrc as int.
def var nn as int.
def var jl-damcam like jl.dam .
def var p-pjh like jh.jh.
def var okey as log.
def var c-gl like gl.gl.
def var c-gl500 like gl.gl.


def var vcha1 as cha.
def var vcha2 as cha.
def var vcha3 as cha.
def var vcha4 as cha.
def var vcha5 as cha.
def var vcha6 as cha.
def var vcha7 as cha.
def var vcha8 as cha.
def var vcha9 as cha.
def var vcha10 as cha.
def var vcha15 as cha.
def var vcha16 as cha.
def buffer cash for sysc.

define buffer b-tcash for tcash.
define new shared variable s-ln like jl.ln.
define new shared variable s-newrec as logical.
define new shared frame menu.
define variable v-newhead as logical.
define variable v-newline as logical.
define variable v-cnt as integer.
define variable v-down as integer.
define variable v-tmpline as integer.
define variable v-ans as logical.
define variable v-top as int initial -1.
def var jl-rem as cha .
def var jl-delta like jl.dam .
def var o-damcam like tcash.damcam .
def shared var s-jh like jh.jh.
define var l-tenge as logical initial false.

{x-cash0.f}

v-yes = false.

find sysc where sysc.sysc = "CASHGL" no-lock.
c-gl = sysc.inval.

find sysc where sysc.sysc = "CASHGL500" no-lock.
if not available sysc then do:
    message "Не настроен счет 100500 в системной таблице sysc" view-as alert-box.
    return.
end.
c-gl500 = sysc.inval.


find cash where cash.sysc = "CASHPL" no-lock no-error.
if not cash.loval then do:

 display  ' Option "CASHPL" = no !!!! '.
 pause.

 return.
end.

l-tenge = false.
for each jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = c-gl or jl.gl = c-gl500):
    l-tenge = true.
end.

if not l-tenge then return.

repeat:
okey = false.



do on error undo ,retry :
 clear frame cont.
 hide frame cont .
 for each tcash.
  delete tcash.
 end.
/* p-pjh = 84392242 .  */
/*  update p-pjh validate
  (can-find(jh where jh.jh eq p-pjh),"")
  with frame qqq. */
  clear frame cont.

p-pjh = s-jh.
display p-pjh with frame qqq.



do:
find first jl where jl.jh = p-pjh no-error.
if not available jl then next.

i = 0.
find jh where jh.jh = p-pjh.
if jh.sts ne 5 then do:
  message vcha3.
  bell. bell.
  pause.
  next.
 end.

okey = false.
icrc = 0.
for each jl of jh break by jl.crc.
 if jl.gl = c-gl or jl.gl = c-gl500 then okey = true.
 if last-of(jl.crc) then icrc = icrc + 1.
end.
if okey then do:
  ttt = jh.party .
  display ttt with frame qqq.
for each jl of jh use-index jhln where (jl.gl = c-gl or jl.gl = c-gl500) and jl.crc = 1
    break by jl.jh by jl.crc with 8 down centered  frame www:

find first crc where crc.crc = jl.crc.

/* A.Panov 10.05.94 for russian version special */
if cash.loval then do:
i = 0 .
for each jlsach where jlsach.jh = jl.jh and
  jlsach.ln = jl.ln no-lock .
  i = i + 1 .
  create tcash.
  tcash.ln = jlsach.ln.
  tcash.code = crc.code.
  tcash.lnln = jlsach.lnln  .
  find first cashpl where cashpl.sim = jlsach.sim and cashpl.act no-lock no-error.
  if avail cashpl then do:
   tcash.sim = jlsach.sim.
   tcash.des = cashpl.des.
  end.
   tcash.damcam = jlsach.amt.
  end.
end.
 find first tcash where tcash.ln = jl.ln no-lock no-error .
 if not avail tcash then do:
  create tcash.
  tcash.ln = jl.ln.
  tcash.code = crc.code.
  tcash.lnln = 1 .
  tcash.sim = 0 .
  tcash.damcam = jl.dam + jl.cam .
 end.
/* 10.05.94 */

 find crc where crc.crc = jl.crc.

end.

find first tcash no-error.
if available tcash then
do transaction:

{brwppg.i
&first = " form jl-rem format 'x(67)' label ' Примечание'
  with no-label row 19 centered no-box side-label
  overlay frame dop .  form jl-damcam label ' Сумма     '
   jl-delta label 'Остаток' with side-label no-box overlay
  row 18 frame dop1 .    "
&h = "10"
&file = "tcash"
&form = "
      tcash.ln label '#' format 'zzz'  tcash.lnln
      format 'z9' label '##' tcash.code label 'Валюта' tcash.damcam
       validate(tcash.damcam <= o-damcam + jl-delta and tcash.damcam ne 0,
          'Сумма > суммы проводки или = 0 !')  label ' Сумма '
      tcash.sim label 'Код' format '999'
       validate((if jl.cam > 0 then tcash.sim ge 210 else tcash.sim le 140)
         and can-find(first cashpl where cashpl.sim = tcash.sim and cashpl.act no-lock)
         and tcash.sim ne 0,
         if jl.cam > 0 then 'Расходная операция ' else ' Приходная операция ')
      tcash.des label ' Описание        ' format 'x(38)'  "
&addcon = "true"
&updcon = "true"
&where  = " use-index qq "
&delcon = " true"
&retcon = " false"
&enderr = "

 i = 0 .
 for each tcash break by tcash.ln by tcash.lnln  .
   accum tcash.damcam ( total by tcash.ln ) .
   if last-of(tcash.ln) then do:
     find first jl where jl.jh = p-pjh and jl.ln = tcash.ln no-lock .
     if ( accum total by tcash.ln tcash.damcam ) ne jl.cam + jl.dam then
        do: i = tcash.ln . leave . end.
   end.
/*   if tcash.sim = 0 then do:
       i = tcash.ln .
       leave .
   end.  */
 end.
 if i > 0  then do:
       Message  ' Сумма  не равна  сумме  проводки' +
       ' или не введен символ кассплана !   ln = ' i .
       pause .
       leave .
 end.

 for each jlsach where jlsach.jh = p-pjh exclusive-lock .
  delete jlsach .
 end .

 for each tcash where tcash.sim ne 0 .
  create jlsach .
  jlsach.jh = p-pjh .
  jlsach.amt = tcash.damcam .
  jlsach.ln = tcash.ln .
  jlsach.lnln = tcash.lnln.
  jlsach.sim = tcash.sim .
 end.
 "
&start = " "
&frame-phrase = " with centered 7 down "
&predisp = "
    find first jl where jl.jh = p-pjh and jl.ln = tcash.ln no-lock .
    jl-damcam = jl.dam + jl.cam  .
    jl-rem = trim(jl.rem[1]) + ' ' + trim(jl.rem[2]).
    jl-delta = jl.dam + jl.cam  .
    for each b-tcash where b-tcash.ln = jl.ln .
     jl-delta = jl-delta - b-tcash.damcam  .
    end.
    display jl-rem with frame dop   .
    display jl-damcam jl-delta with frame dop1 .
    if tcash.sim ne 0 then do:
     find first cashpl where cashpl.sim = tcash.sim and cashpl.act no-lock.
     tcash.des = cashpl.des.
    end.
    display
 '<Enter> - изменить,<F9> - добавить,<F10> - удалить,<F2>-помощь,<F4>-выход '
     with row 22 centered no-box .
"
&disp = "tcash.ln tcash.lnln tcash.code tcash.damcam tcash.sim tcash.des "
&seldisp =
"tcash.ln tcash.lnln tcash.code tcash.damcam tcash.sim tcash.des "
&preupd = "  o-damcam = tcash.damcam .
             tcash.damcam = tcash.damcam + jl-delta . "

&upd = " tcash.damcam tcash.sim "

&poscreat = " tcash.ln = jl.ln.
             find first crc where crc.crc = jl.crc no-lock .
             tcash.code = crc.code.
             i = 0 .
             for each b-tcash where b-tcash.ln = jl.ln .
                    i = i + 1 .
             end.
             tcash.lnln = i + 1 .
             tcash.damcam = jl-delta .
            "
&postcre = "
          display tcash.ln tcash.code tcash.lnln tcash.damcam
            tcash.sim with frame frm .
            o-damcam = 0 . "
&addupd = " tcash.damcam tcash.sim "
&postadd = " leave. "

&postupd = "
  if tcash.sim ne 0 then do:
   find first cashpl where cashpl.sim = tcash.sim and cashpl.act no-lock.
   tcash.des = cashpl.des.
  end.
"
&posdelete = "   i = 0 .
                for each b-tcash where b-tcash.ln = jl.ln .
                 i = i + 1 .
                 b-tcash.lnln = i .
                end."
}
        end.
      end.
    end.
  end.
end.
