/* lonextdt.f
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

/*lonextdt.f
*/

form "KredЁts :" lon.lon skip
     "Bil.knts:" lon.gl gl.sname "(" lon.grp ")" skip
     "Klients :" lon.cif cif.name skip
     "Kr.vёst.:" lon.lcr skip
     "Reg.dat.:" lon.rdt skip
     "Termi‡Ѕ :" lon.duedt skip
     "% likme :" lon.base lon.prem skip
     "Atlikums:" vbal skip
     with centered row 7 no-label frame lon
	  title " KRED§TI ".
