/* rkorash.p
 * MODULE
        Расходы по СПФ за указанный период
 * DESCRIPTION
        Отчет по расходам сберкасс.
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
        07/04/04 madiar
 * CHANGES 
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{global.i}
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

if not connected ("alga") then do:

  find txb where txb.txb = seltxb and txb.city = 998 no-lock no-error.
  if not avail txb then do:
     message "Не найдены настройки БД Alga в таблице COMM.TXB"
     view-as alert-box title "ОШИБКА". pause 300.
     return "0".
  end.
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga ").
end.

run rkorash0.

disconnect "alga".