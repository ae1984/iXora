/* v-kurs4.f
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


/* v-kurs3.f    02/03/94 - AGA      */



    disp stream rpt crc.code label "Nos."
		    crc.crc label "Kods"
		    rate[9] label "Daudz." format "zzz,zz9"
		    rate[2] label "Pёrk " format "zzz.99999"
		    rate[3] label "P–rd." format "zzz.99999"
		    rate[4] label "Pёrk " format "zzz.99999"
		    rate[5] label "P–rd." format "zzz.99999"
		    rate[1] label "LB kurss" format "zzz.99999"
		    with down frame okona with width 80.
