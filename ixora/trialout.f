/* trialout.f
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

	  display jl.gl label "G/G" gl.sname label "    NOSAUKUMS"
		  vglbal label " S…KUMA ATL "
		  dr ( total by jl.crc ) label " DEBETS "
		  cr (total by jl.crc )  label " KRED§TS "
		  vsubbal  label " BEIGU ATL "
		  with no-box width 132 .
