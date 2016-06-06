/* vcedsysc.f
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

/* vcedsysc.f Валютный контроль 
   Форма редактирования настроек в системной таблице

   21.11.2002 nadejda создан
*/

form
     sysc.sysc label "КОД ПАР"
     sysc.des format "x(30)" label "ПАРАМЕТР"
     sysc.daval label "ДАТА"
     sysc.deval label "ЧИСЛО ВЕЩ."
     sysc.inval label "ЧИСЛО ЦЕЛ."
     sysc.loval label "ЛОГ"
with row 5 centered scroll 1 12 down width 80 frame vced .
