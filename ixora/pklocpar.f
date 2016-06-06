/* pklocpar.f
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
        18.04.2008 alex - Расширил фрейм
*/

/* pklocpar.f ПотребКредиты
   Форма редактирования настроек в системной таблице sysc

   18.03.2003 nadejda создан
*/

form
     sysc.sysc format "x(12)" label "КОД ПАР"
     sysc.des format "x(54)" label "ПАРАМЕТР"
     sysc.daval label "ДАТА"
     sysc.deval label "ЧИСЛО ВЕЩ."
     sysc.inval label "ЧИСЛО ЦЕЛ."
     sysc.loval label "ЛОГ"
with row 5 scroll 1 26 down width 110 frame f-ed .
