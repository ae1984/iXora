/* x-prnvo.i
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

/* s-prnvo1.i
*/

disp skip(1)
"**" s-jh at 3  vcrc jl.jdt  vdb to 78 skip
				       vcr to 78 skip
      vdes at 2 vcif at 38 vname at 45 skip
 fill("-",79) format "x(79)" skip
 vrem[1] at 2 vamt[1] format "zz,zzz,zzz,zz9.99-"
 to 78 skip
 vrem[2] at 2 vamt[2] format "zz,zzz,zzz,zz9.99-"
 when vamt[2] gt 0 to 78 skip
 vrem[3] at 2 vamt[3] format "zz,zzz,zzz,zz9.99-"
 when vamt[3] gt 0 to 78 skip
 vrem[4] at 2 vamt[4] format "zz,zzz,zzz,zz9.99-"
 when vamt[4] gt 0 to 78 skip
 vrem[5] at 2 vamt[5] format "zz,zzz,zzz,zz9.99-"
 when vamt[5] gt 0 to 78 skip
 vrem[6] at 2 vamt[6] format "zz,zzz,zzz,zz9.99-"
 when vamt[6] gt 0 to 78 skip
 vrem[7] at 2 vamt[7] format "zz,zzz,zzz,zz9.99-"
 when vamt[7] gt 0 to 78 skip
 vext at 2    vtot  to 78 skip
 fill("-",79) format "x(79)" skip
 vcontra[1] at 2 skip
 vcontra[2] at 2 skip
 vcontra[3] at 2 vofc to 78 skip
 vcontra[4] at 2 skip
 vcontra[5] at 2 skip
 fill("=",79) format "x(79)" skip
 with no-box no-label frame prnvo.
