/* ocksp.f
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

/* ocksp.f
*/

  display ock.payee
	  ock.rdt
	  ock.ref
	  ock.cam[1] label "°EKA SUMMA  "
	  ock.cam[1] - ock.dam[1] label "°EKA ATLIKUMS"
	  format "z,zzz,zzz,zzz,zz9.99-"
	  ock.spflag
	  ock.spdt
	  ock.spby
	  ock.reason
	  with frame ock.
