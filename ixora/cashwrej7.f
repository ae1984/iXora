/* cashwrej7.f
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

form "Сумма" m-sumd format "zzz,zzz,zzz,zzz.99-" at 25
m-sumk  format "zzz,zzz,zzz,zzz.99-" skip
      "  Обороты       " m-diff crc.code skip
  header
  fill("-",80) format "x(80)"
  with width 130 frame ba row 19 column 0 1 down no-underline overlay.
