/* tcr_hist.p
 * MODULE
        Internet Office
 * DESCRIPTION
        Отсылка распоряжения на отзыв платежа.
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
        BANK COMM IB
 * AUTHOR
        13.04.2004 tsoy
 * CHANGES
*/

TRIGGER PROCEDURE FOR CREATE OF ib.hist.
ASSIGN
  ib.hist.id = next-value(uniqrecid)
  ib.hist.wdate = today 
  ib.hist.wtime = STRING(time, "HH:MM:SS")
  ib.hist.itime = time
  ib.hist.who = userid("ib")
.
  
