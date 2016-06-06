/* cas100sv.p
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
        11.11.10 marinav     занесем остатки кассы по СП 
        12.01.11 marinav - добавлен счет хранилища
*/

{yes-no.i}
def shared var g-today as date.
def shared var g-ofc as char.

find sysc where sysc.sysc = 'CASVOD' no-error.
if not avail sysc then
do:
   create sysc.
   update sysc.sysc = 'CASVOD'
          sysc.loval = no
          sysc.daval = g-today
          sysc.des = "Признак блокировки свода кассы".
end.


if sysc.daval <> g-today then
do: sysc.daval = g-today.
    sysc.loval = no.
end.


if sysc.loval = yes then
do:
    /* поиск юзера в списке разрешенных */
    if lookup (g-ofc, sysc.chval, ",") > 0 then
       do:
            if yes-no ("Свод кассы уже завершен!",
                       "Снять блокировку со счета 100100?")
                       then update sysc.loval = no.
            return.
       end.
       else do:
          message "Свод кассы уже завершен!" view-as alert-box title "Внимание!".
          return.
       end.
end.


if yes-no ("Завершение свода кассы", "Заблокировать проводки по счету 100100?")
then sysc.loval = yes.


 /* занесем остатки кассы по СП */

def buffer b-caspoint for caspoint.

for each caspoint where caspoint.rdt = g-today.
   delete caspoint.
end.
for each ppoint no-lock.
    for each crc no-lock.
        find last b-caspoint where b-caspoint.depart = ppoint.depart and b-caspoint.rdt < g-today and b-caspoint.crc = crc.crc  and b-caspoint.info[1] = '100100' no-lock no-error.
        create caspoint.
        caspoint.depart = ppoint.depart.
        caspoint.rdt = g-today.
        caspoint.crc = crc.crc.
        caspoint.whn = today.
        caspoint.info[1] = '100100'.
        if avail b-caspoint then caspoint.amount = b-caspoint.amount.
                            else caspoint.amount = 0.


        find last b-caspoint where b-caspoint.depart = ppoint.depart and b-caspoint.rdt < g-today and b-caspoint.crc = crc.crc  and b-caspoint.info[1] = '100110' no-lock no-error.
        create caspoint.
        caspoint.depart = ppoint.depart.
        caspoint.rdt = g-today.
        caspoint.crc = crc.crc.
        caspoint.whn = today.
        caspoint.info[1] = '100110'.
        if avail b-caspoint then caspoint.amount = b-caspoint.amount.
                            else caspoint.amount = 0.
    end.

end.

if sysc.loval = yes then do:
   for each jl where jl.jdt = g-today  and  jl.gl eq 100100 use-index jdt no-lock.

      find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.

      find first caspoint where  caspoint.depart = ofchis.depart and caspoint.rdt = g-today and caspoint.crc = jl.crc and caspoint.info[1] = '100100' no-error.
      if avail caspoint then caspoint.amount = caspoint.amount + jl.dam - jl.cam.
   end.

   for each jl where jl.jdt = g-today  and  jl.gl eq 100110 use-index jdt no-lock.

      find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.

      find first caspoint where  caspoint.depart = ofchis.depart and caspoint.rdt = g-today and caspoint.crc = jl.crc and caspoint.info[1] = '100110' no-error.
      if avail caspoint then caspoint.amount = caspoint.amount + jl.dam - jl.cam.
   end.

end.




