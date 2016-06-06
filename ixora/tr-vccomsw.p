/* tr-vccomsw.p
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

/* tr-vccoms.p Валютный контроль
   Триггер на изменение записи в vcctcoms

   09.01.2002 nadejda
*/

trigger procedure for write of vcctcoms old oldvcctcoms.

{vc.i}

{global.i}
{sum2str.i}

def var v-msg as char.

if vcctcoms.sum <> oldvcctcoms.sum then do:
  /* первый раз пишем */

  assign vcctcoms.rwho = g-ofc
         vcctcoms.rdt = today
         vcctcoms.rtim = time.

  find vcparams where vcparams.parcode = vcctcoms.codcomiss no-lock no-error.
  find crc where crc.crc = vcctcoms.crc no-lock no-error.
  v-msg = vcparams.name + " (" + entry(1, vcparams.valchar) + "), сумма " + 
          sum2str(vcctcoms.sum) + " " + crc.code + " ". 

  if vcctcoms.jh = 0 then
    v-msg = v-msg + "записана в долг ".
  else
    v-msg = v-msg + "снята, TRX " + trim(string(vcctcoms.jh)) + " от ".

  v-msg = v-msg + string(vcctcoms.datecomiss, "99/99/99").
  run vc2hisct(vcctcoms.contract, v-msg).

  if vcctcoms.codcomiss = "com-ps" then do:
    find vcps where vcps.contract = vcctcoms.contract and vcps.dntype = "01" no-lock no-error.
    run vc2hisps (vcps.ps, v-msg).
  end.
end.

else 
if vcctcoms.jh <> oldvcctcoms.jh then do:
  /* удалена транзакция или наоборот - долг сняли */

  assign vcctcoms.rwho = g-ofc
         vcctcoms.rdt = today
         vcctcoms.rtim = time.

  find vcparams where vcparams.parcode = vcctcoms.codcomiss no-lock no-error.
  if vcctcoms.jh = 0 then
    v-msg = "Удалена транзакция по снятию комиссии : ".
  else
    v-msg = "Проведена транзакция по снятию долга : ".

  v-msg = v-msg + vcparams.name + " (" + entry(1, vcparams.valchar) + "), сумма ".

  find crc where crc.crc = vcctcoms.crc no-lock no-error.
  if vcctcoms.jh = 0 then
    v-msg = v-msg + sum2str(vcctcoms.sum) + " " + crc.code + " - TRX " + 
                    trim(string(oldvcctcoms.jh)) + " от " +
                    string(vcctcoms.datecomiss, "99/99/99").
  else do:
    find jl where jl.jh = vcctcoms.jh and jl.acc = vcctcoms.aaa and jl.dc = "d" no-lock no-error.
    assign vcctcoms.datecomiss = jl.jdt
           vcctcoms.sum = jl.dam.
    v-msg = v-msg + sum2str(vcctcoms.sum) + " " + crc.code + " - TRX " + 
                    trim(string(vcctcoms.jh)) + " от " +
                    string(vcctcoms.datecomiss, "99/99/99").
  end.

  run vc2hisct(vcctcoms.contract, v-msg).

  if vcctcoms.codcomiss = "com-ps" then do:
    find vcps where vcps.contract = vcctcoms.contract and vcps.dntype = "01" no-lock no-error.
    run vc2hisps (vcps.ps, v-msg).
  end.
end.

