/* astjln2.f
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

form astjln.ajdt 
     v-dam format "zzzzzzzzz9.99"
     v-cam format "zzzzzzzzz9.99" 
     astjln.apriz format "x"
     astjln.aqty  format "zz9"
     astjln.arem[1] format "x(32)"
     astjln.atrx format "xx"
  with centered overlay no-label no-hide row 12 7 down title
" Дата          Дебет       Кредит    Кол-во   Oперация                    Oп  "
       frame astjln2.
