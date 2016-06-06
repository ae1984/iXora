/* h-bi.p
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


def  var F71choice as char extent 4 format "x(3)" initial
     ["BEN", "OUR", "SHA", "NON"].

/* Field O71 - Details of charges */
do on error undo,retry:
 form F71choice
  with overlay top-only row 15 column 10 1 col no-labels frame x.
 display F71choice with frame x.
 choose field F71choice AUTO-RETURN with frame x.
 FRAME-VALUE = frame-value .
end.
