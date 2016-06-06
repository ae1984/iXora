/* v-kuns3.f
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


/* v-kuns3.f    24/10/94 - AGA      */


    disp stream rpt
		crchis.rdt label "Datums"
		crchis.rate[9] label "Daudz." format "zz,zz9"
		crchis.rate[2] label "Pёrk " format "zzz.99999"
		crchis.rate[3] label "P–rd." format "zzz.99999"
		crchis.rate[4] label "Pёrk " format "zzz.99999"
		crchis.rate[5] label "P–rd." format "zzz.99999"
		crchis.rate[1] label "KURSS" format "zzz.99999"
		with down  frame okon with width 80 .
