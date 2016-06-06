/* debsrok.f
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату (с незакрытыми приходами по срокам)
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
        01/11/04 tsoy
 * CHANGES
        16/08/2005 marinav добавлен фактический срок

*/

form
      wrk.date   format "99.99.99" label "ДАТА"
      wrk.name   format "x(15)"    label "НАИМЕНОВАНИЕ"   
      wrk.ost    format "->>,>>>,>>9.99"    label "ОСТАТОК"
      wrk.period format "x(13)"    label "СРОК"
      wrk.fsrok  format "x(14)" label "ФАКТ.СРОК"
      wrk.attn       label "ДЕПАРТ"
  with row 5 overlay centered scroll 5 down title " ОСТАТКИ ПО ДЕБИТОРАМ " frame f-dat.

