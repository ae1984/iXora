/* trxdelun.p
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
 * BASES
        BANK
 * CHANGES
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

define input parameter t-jh like jh.jh .
{global.i}
{lgps.i}
def new shared var s-jh like jh.jh .
def var p1 as log .
def var p2 as log .
def var v-ref as cha format "x(10)".
def var pakal as  cha .
def var v-pnp as cha format "x(10)".
def var v-chg as int  .
def var v-reg5  as cha format "x(13)".
def var v-priory as char.
def var cans as log.
def buffer b-jh for jh.
def buffer b-jl for jl.
def var djh like jh.jh.
def var dvjh like jh.jh.
def var v-jhdel as log.
def buffer tgl for gl.
def var rcode as int.
def var rdes as cha .
def var sts like jh.sts.

djh = ?.
dvjh = ?.

find sysc where sysc.sysc eq "CASHGL" no-lock .

do transaction :
   find jh where jh.jh eq t-jh no-error.
   if not available jh then
    do:
     Message string(t-jh) + " не найдена ." .
     pause .
     return .
    end.
   else
   do:
    p1 = false  . p2 = no .
   for each jl of jh no-lock :
    if jl.gl eq sysc.inval then do: p1 = true .  end .
    if jl.sts eq 6 then do: p2 = true .  end .
   end .
   if p1 and  p2 then  do:
     message "Кассовая проводка и статус = 6 !!! "
      chr(7) chr(7) chr(7).
     pause .
     return.
    end.
  end.


              find jh where jh.jh eq t-jh no-error.
              if jh.post then
              Message "Проводка будет сторнирована ,продолжать ?" update cans.
              else
              Message "Проводка будет удалена, продолжать ? " update cans.
              if not cans then undo.
              if jh.post eq true
              then do:
               djh = ? .
   run trxstor(input t-jh, input 5, output djh, output rcode, output rdes).
        if rcode ne 0 then do:
               message rdes.
               pause .
               undo, return .
              end.
 if djh ne ? then do  :
  s-jh = djh .
  run x-jlvou.
  for each jl where jl.jh = djh exclusive-lock .
   jl.sts = 6.
  end .
  jh.sts = 6 .
 end.
end.
    else do:
            find jh where jh.jh = t-jh no-error.
            sts = jh.sts.

            run trxsts (input t-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                            message rdes.
                            undo, return .
                end.
            run trxdel (input t-jh, input true, output rcode, output rdes).
                if rcode ne 0 then do:
                          message rdes.
                          if rcode = 50 then do:
                                             run trxsts (input t-jh, input sts, output rcode, output rdes).
                                             return.
                                        end.
                          else undo, return.
                end.

      end.
     Message string(t-jh) + " Аннулирование успешно ! " . pause.
 end.
 pause 0 .


