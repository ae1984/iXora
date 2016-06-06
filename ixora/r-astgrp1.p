/* r-astgrp1.p
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


{mainhead.i}

 /*  Atskaites druka*/

{image1.i rpt.img}
{image2.i}
{report1.i 72}
vtitle ="                                      ГРУППЫ ОС            ".

{report2.i 91 

"'     |                               |         |ФИНАН. | СРОК   |КАТЕГ. |НАЛОГОВ. |       |' skip
 'ГРУП-|      НАЗВАНИЕ                 |  СЧЕТ   |АМОРТ. | ИЗНОСА |НАЛОГ. |ИЗНОСА   |       |' skip                 
 ' ПА  |                               |         | КОД   |( ЛЕТ ) |АМОРТ. |СТАВКА(%)|       |' skip 
  fill('=',91) format 'x(91)' skip "}                                                           

    for each fagn break by fagn.fag :
   Put fagn.fag at 2 FORMAT "x(4)" 
      fagn.naim at 7 FORMAT "x(27)" " "
      fagn.gl at 40 FORMAT "zzzzz9" 
      fagn.ser at 49 FORMAT "x(7)" 
      fagn.noy at 57 FORMAT "zz9" 
      fagn.cont at 68 FORMAT "x(1)"
      fagn.ref at 75 FORMAT "x(5)" 
      fagn.pkop at 86 format "x(1)" skip.
end.        

{report3.i}
{image3.i}
