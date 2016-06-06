/* v-kuns4.f
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


/* v-kuns4.f    24/10/94 - AGA      */



    put  stream rpt
	       crchis.rdt " "
	       crchis.rate[9]  format "zz,zz9" " "
	       crchis.rate[2]  format "zzz.99999" " "
	       crchis.rate[3]  format "zzz.99999" " "
	       crchis.rate[4]  format "zzz.99999" " "
	       crchis.rate[5]  format "zzz.99999" " "
	       crchis.rate[1]  format "zzz.99999" skip(0).
