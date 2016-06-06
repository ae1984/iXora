/* vceddoc.f
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

/* vceddoc.f Валютный контроль 
   Форма редактирования справочника типов документов

   18.10.2002 nadejda создан
*/

form
     "  " codfr.code label "КОД"
     codfr.name[2] format "x(6)" label "КРАТКОЕ"
     codfr.name[1] format "x(48)" label "ПОЛНОЕ НАИМЕНОВАНИЕ"
     codfr.name[5] format "x(3)" label "ВИД"
     "  "
     with row 5 centered scroll 1 12 down
     frame vced .
