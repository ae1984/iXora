/* atset.p
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

/* atset.p
    Setup кодов транзакций со счетами AST */

{mainhead.i}
{headln-w.i
	    &head = "asttr"
	    &form = "asttr.asttr label ""КОД ОПЕР.""
		asttr.atdc label ""Д /К "" help ""D - Дебет  C - Кредит""
		validate (asttr.atdc eq ""d"" or asttr.atdc eq ""c"",
		""ОШИБКА. ПОВТОРИТЕ."")
		asttr.atdes label ""ОПЕР.ОПИСАНИЕ"" "
	    &frame
		  = "row 3 centered scroll 1 14 down"
	    &flddisp = "asttr.asttr asttr.atdc asttr.atdes"
	    &fldupdt = "asttr.asttr asttr.atdc asttr.atdes"
	    &posupdt = " "
	    }
