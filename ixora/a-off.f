/* a-off.f
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


/*****valery 05/01/2004 *****************************************************************/
def var vdep like ppoint.depart.
def new shared var vpoint like ppoint.point.
                    
form vdep label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов' 
	validate(can-find (ppoint where ppoint.depart = vdep no-lock),
	' Ошибочный код департамента - повторите ! ') skip with frame ofc col 1 row 3 2 col width 66.
vpoint = 1.

/*****valery 05/01/2004 *****************************************************************/



update "ДАТА: " dday with no-box no-label row 3 frame opt.


update vdep with frame ofc. /*****valery 05/01/2004 *****************************************************************/