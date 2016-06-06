/* 1P_ps.p
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
        03.07.2013 dmitriy - ТЗ 1924. Добавлил no-wait
*/

  {global.i}
 {lgps.i }
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def buffer our for sysc .
 find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Нет записи PR-DIR в sysc файле " .  run lgps.
  return .
 end.

  find our where our.sysc = "OURBNK" no-lock no-error.
  if not avail our then do:
    v-text = " Нет записи OURBNK в sysc файле " .  run lgps.
    return .
  end.


 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock no-wait .
   /*  Beginning of main program body */


  find first jl where jl.jh = remtrz.jh1 no-lock no-error.
  if not available jl then do :
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "10".
   v-text = "Ошибка ! Нет 1 прводки " + remtrz.remtrz.
   run lgps.
   return.
  end.

 if search ( sysc.chval + "/1TRXprot.log" )
        <> ( sysc.chval + "/1TRXprot.log" )
 then  do:
       output to value( sysc.chval + "/1TRXprot.log" ) .
       put unformatted
        "Дата   " g-today  " Время " string(time,"HH:MM:SS") skip
        "Исполнитель " jl.who skip
        "Протокол 1 проводки " skip
        /*
        "Протокол автоматически обработанных переводов" skip
        */
        fill("-",130) skip
        "Nr.Документа     "
        "Сумма" to 37
        "Вал" to 41
        "Банк " to 52
        "Счет дебета " to 65
        "Платеж   " to 76
        "1Дата валют" to 88
        "Nr.пр" to 96 skip
        fill("-",130) skip.
        output close .
        end .

  find crc where crc.crc = remtrz.fcrc no-lock no-error.

  output to value( sysc.chval + "/1TRXprot.log" ) append.
         put substr(remtrz.sqn,19,10) space(8)
         remtrz.amt space(2)
         crc.code space(5)
         trim(our.chval) space(1)
         remtrz.dracc space(2)
         remtrz.remtrz space(2)
         remtrz.valdt1 space(3)
         remtrz.jh1 skip.
  output close.

   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".

   if remtrz.ptype = "8" and remtrz.source = "I" then
    que.rcod = "1" .
     else
    que.rcod = "0".

   v-text = " Протокол 1 проводки сформирован для remtrz " + remtrz.remtrz.
   run lgps.
  end.
 end.
