/* sim-obm.p
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
        22/06/2011 madiyar - добавил по кассе счет 100500
        02.02.2012 lyubov - изменила симв.касспл.: 90 на 30, 390 на 230
*/

/*
 sim-obm.p
   символ кассового плана для обменных операций
   08.11.2000 */


def input parameter p-pjh  like jh.jh.
def var             c-gl   like  gl.gl.

find sysc where sysc.sysc = "CASHGL" no-lock.
c-gl = sysc.inval.

do on error undo ,retry :
   find first jl where jl.jh = p-pjh no-lock no-error.
   if not available jl then do.
      message "Транзакция не найдена!".
      bell. bell.
      pause.
      next.
   end.

   find jh where jh.jh = p-pjh.
   if jh.sts ne 5 then do:
      message "1111 Статус транзакции не 5!".
      bell. bell.
      pause.
      next.
   end.

   find jl of jh where (jl.gl = c-gl or jl.gl = 100500) and jl.crc = 1 no-lock no-error.
   if avail jl then do:
      for each jlsach where jlsach.jh = p-pjh exclusive-lock .
          delete jlsach .
      end .

      create jlsach .
      jlsach.jh   = p-pjh .
      jlsach.amt  = if jl.dam <> 0 then jl.dam else jl.cam .
      jlsach.ln   = jl.ln .
      jlsach.lnln = 1.
      jlsach.sim  = if jl.dam <> 0 then 030 else 230 .

   end.
end.
