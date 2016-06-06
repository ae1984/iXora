/* arpst.p
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
        04/08/05 sasco добавил запрос на показ проводок
        04/08/05 sasco в поиске проводок при просмотре АРП, проводки ищутся descending по индексу jdtaccgl вместо acc
        15/04/2009 galina - изменения для генерации 20-тизначного счета
        16/04/2009 galina - вернула предыдущую версию
        17/04/2009 galina - выбор генерации 20-ти или 9-ти значного счета
        28.06.2013 Lyubov - ТЗ № 1859, добавление или удаление счета из справочника счетов для сводных справок
*/

/* работа с ARP-карточками
{mainhead.i ARPORY}
*/

/* 26/06/03 nataly  при просмотре проводок в процедуре q-arp
    была отключена проверка по ГК
    в связи с переносом счетов ARP  с одного ГК на другой */
/*26/06/03 nataly была уб*/
{global.i}
{yes-no.i}

pause 0.
def var v-bal as decimal format "zzz,zzz,zzz.99-".
def  var s-acc like jl.acc.
def shared var s-val like crc.crc.
def shared  var s-gl  like gl.gl.
def shared var s-secek as char.
def shared var s-length as logical init false format "да/нет".
def  var s-jh like jh.jh.
def  var s-jl like jl.ln.
def var answer as log.
def new shared var s-lgr like lgr.lgr.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

{q-arp.f}
{q-arpjl.f}

  on "close" of this-procedure  do:
    release arp .
    clear frame arp.
    hide all.
  end.

 on pf3 of current-window anywhere do :
 end.

procedure n-arp.
do transaction on error undo, return :
   if s-length then   run acc_gen(input s-gl,s-val,'',s-secek,true, output s-acc).
   else run acng (s-gl, true, output s-acc).
   find arp where arp.arp = s-acc.
   arp.crc = s-val.
   arp.rdt = g-today.
   arp.who = g-ofc.
   arp.gl = s-gl.
   find gl where gl.gl = s-gl no-lock no-error.
   clear  frame arp .
   display arp.arp arp.crc arp.gl gl.sname arp.rdt  arp.duedt with row 2 centered
           frame arp.
 end.
end procedure.

procedure q-arp.
repeat :
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
   v-penny = arp.penny / 100.
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


  display arp.arp arp.crc
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
          v-penny
          /*arp.penny*/
          arp.spby
          v-spbyname
          arp.reason
          v-reasonbank
          v-sprav
          with frame arp.
    pause 0.

    if yes-no ("Просмотр счета", "Показать последние проводки?") then do:
       clear frame jl all no-pause.
       for each jl  no-lock  where /*jl.gl eq gl.gl and*/ jl.acc eq arp.arp
        use-index jdtaccgl
        break by jl.jdt desc:
        display jl.jdt jl.dam jl.cam jl.jh jl.who jl.rem[1] with frame jl.
        down with frame jl.
        if last(jl.jdt) then pause.
       end.
    end.

end.
end procedure .

on help of arp.reason in frame arp do:
  run help-bank.
end.


procedure ed-arp .

if avail arp then do:
v-penny = arp.penny / 100.

  display arp.arp arp.crc
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
          v-penny
          arp.spby
          v-spbyname
          arp.reason
          v-reasonbank
          v-sprav
          with frame arp.

        update arp.type arp.geo arp.cgr arp.zalog arp.duedt arp.des arp.rem arp.cif arp.sts arp.lonsec arp.risk v-penny
        arp.spby when lookup(string(arp.gl), v-debetor) > 0
        arp.reason when lookup(string(arp.gl), v-akkred) > 0
        v-sprav
        with frame arp.

        /*тк arp.penny  - целое, то при выводе на экран делим на 100 */

        arp.penny   = v-penny * 100.
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

        displ v-spbyname v-reasonbank with frame arp.

        for each codfr where codfr.codfr = 'casvnbal' and codfr.code matches '*' + s-ourbank + '*' exclusive-lock:
            if v-sprav = yes then codfr.name[1] = codfr.name[1] + ',' + arp.arp.
            else do:
                codfr.name[1] = replace(codfr.name[1],arp.arp,'').
                codfr.name[1] = replace(codfr.name[1],',,',',').
            end.
        end.
    end.
end procedure.

Procedure subc.
   if avail arp then  do:
    run subcod(arp.arp,"arp").
/*    hide all.
    view frame arp .    */
   end.
end procedure .

Procedure ball.
 if avail arp then  do:
    run amt_level("arp",arp.arp).
    hide all.
    view frame arp.
 end.
end procedure .

