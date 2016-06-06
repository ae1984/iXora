/* fungrp.f
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


form fungrp.fungrp format "zz9" label "Группа"
               validate(fungrp.fungrp >= 1," ")
     fungrp.gl format "999999" label "Счет Г/К" 
               validate(can-find(gl where gl.gl = fungrp.gl),"")
     fungrp.des[1] label "Наименование"
  with centered row 3 down frame fungrp.
