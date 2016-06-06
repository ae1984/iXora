/* h-i-dt.p
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
        17.06.2004 madiar - в вывод сообщения об ошибке добавил не найденный счет ГК
*/

/* SaistЁbu noformёЅana */
define shared variable s-lon like lon.lon.
define variable jane as logical.
form lonsa.opndt format "99/99/9999"      label "С............."
     lonsa.prem   format ">>9.99"         label "% по обязател."
     with row 19 column 15 title "Обязательства" overlay 2 columns frame saist.
define new shared variable s-longl as integer extent 20.
define variable ok as logical.

find lon where lon.lon = s-lon no-lock.
find lonsa where lonsa.lon = s-lon no-error.
if not available lonsa
then do:
     jane = no.
     message "Ввести запись по обязательствам?" update jane.
     if jane
     then do:
          create lonsa.
          run f-longl(lon.gl,"sa%gl",output ok).
          if not ok
          then do:
               bell.
               message lon.lon " - h-i-dt:" 
                       " Счет ГК " string(lon.gl) " не определен как счет по обязательствам".
               pause.
               return.
          end.
          if s-longl[1] > 0
          then lonsa.gl = s-longl[1].
          else do:
               bell.
               message "Счет % по обязательствам !".
               pause.
               undo, return.
          end.
          lonsa.lon = s-lon.
          lonsa.opndt = lon.rdt.
          lonsa.opnamt = lon.opnamt.
          lonsa.duedt = lon.duedt.
          lonsa.prem = 3.
          lonsa.who = userid("bank").
          lonsa.whn = today.
     end.
     else return.
end.
repeat on endkey undo,leave:
   display lonsa.opndt
           lonsa.prem
           with frame saist.
   update lonsa.opndt
          lonsa.prem
          with frame saist.
   if frame saist lonsa.prem   entered or
      frame saist lonsa.opndt  entered 
   then do:
        lonsa.who = userid("bank").
        lonsa.whn = today.
   end.
end.

