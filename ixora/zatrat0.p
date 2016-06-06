/* zatrat0.p
 * MODULE
        справочник департаментов модуля ЗАРПЛАТЫ
 * DESCRIPTION
        справочник департаментов модуля ЗАРПЛАТЫ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        profcned.p, r-zatrat.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        zatrat01.p
 * MENU
        
 * AUTHOR
        14.06.05 nataly создан
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

if not connected ("alga") then do:

  find txb where txb.txb = 0 and txb.city = 998 no-lock no-error.
  if not avail txb then do:
     message "Не найдены настройки БД Alga~nв таблице COMM.TXB"
     view-as alert-box title "ОШИБКА". pause 300.
     return "0".
  end.
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld alga ").
end.
  run zatrat01.

disconnect "alga".
