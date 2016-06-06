/* pltque3.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
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
 * BASES
        TXB COMM 
 * AUTHOR
       19/05/2010 id00004
 * CHANGES

*/






def input  parameter pRmz  as char .
def output parameter rstatus as char.




  find last txb.remtrz where txb.remtrz.remtrz = pRmz  no-lock no-error.
  if avail txb.remtrz then do:
     if (today - txb.remtrz.valdt1 ) <= 90 then do:
        rstatus = 'yes'.
     end.
  end.
