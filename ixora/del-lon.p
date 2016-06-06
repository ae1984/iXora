/* del-lon.p
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
        28/04/2005 madiar - добавил удаление истории проводок
*/

  define shared variable s-lon like lon.lon.
  find lon where lon.lon = s-lon.
  do transaction:
     delete lon.
  end.
  for each lnscg where lnscg.lng = s-lon transaction:
      delete lnscg.
  end.
  for each lnsch where lnsch.lnn = s-lon transaction:
      delete lnsch.
  end.
  for each lnsci where lnsci.lni = s-lon transaction:
      delete lnsci.
  end.
  for each lonsec1 where lonsec1.lon = s-lon transaction:
      delete lonsec1.
  end.
  for each lonhar where lonhar.lon = s-lon transaction:
      delete lonhar.
  end.
  for each lnshis where lnshis.lon = s-lon transaction:
      delete lnshis.
  end.
  for each lonres where lonres.lon = s-lon transaction:
      delete lonres.
  end.
