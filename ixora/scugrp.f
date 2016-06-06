/* scugrp.f
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*bcode.f
02-24-93*/


form scugrp.scugrp format "zz9" label "Группа"
               validate(scugrp.scugrp >= 1," ")
     scugrp.gl format "999999" label "Счет Г/К" 
               validate(can-find(gl where gl.gl = scugrp.gl),"")
     scugrp.des[1] label "Наименование"
  with centered row 3 down frame scugrp.
