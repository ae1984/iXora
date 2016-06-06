/* vcedpar.f
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

/* vcedpar.f Валютный контроль 
   Форма редактирования настроек

   18.10.2002 nadejda создан
*/

form
     vcparams.parcode
     vcparams.name format "x(32)"
     vcparams.partype format "x" 
     vcparams.vallogi label "ЛОГ"
     vcparams.valinte format ">>>>>>>9" label "ЦЕЛОЕ"
     vcparams.valdeci format "->>,>>>,>>>,>>9.99" label "ВЕЩЕСТВ"
     with row 5 centered scroll 1 12 down width 80
     frame vced .
