/* setupgen.f
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

/* setupgen.f
*/

form   nxtcif.des no-label nxtcif.prefix colon 40
			   nxtcif.nmbr   colon 40
			   nxtcif.fmt    colon 40
			   nxtcif.sufix  colon 40 skip
       wkday.des no-label wkday.inval format "9" label "NO  "
       wkday.deval format "9" label "UZ" skip
       nxtjh.des no-label nxtjh.inval no-label skip
       dayacr.des no-label dayacr.loval no-label skip
       aicoll.des no-label aicoll.loval no-label skip
       with row 3 centered side-label frame setup.
