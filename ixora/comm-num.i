/* comm-num.i
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

/* 
   Функция фозвращает следующий номер документа 
   по группе платежей за дату из таблицы commonpl 

   нужно заранее определить seltxb = comm-cod().
*/

function comm-num returns integer (tgrp as integer, tdate as date ).
 define buffer bcommpl for commonpl.
 def var tdnum as integer.

  find last bcommpl where bcommpl.txb = seltxb and bcommpl.date = tdate and bcommpl.grp = tgrp
                    use-index datenum no-lock no-error.

  if avail  bcommpl then tdnum = bcommpl.dnum + 1.
                    else tdnum = 1.

 return tdnum.
end.
