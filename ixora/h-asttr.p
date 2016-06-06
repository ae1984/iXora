/* h-asttr.p
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

/* h-asttr.p */

{global.i}
{itemlist.i
       &updvar = "def var vasttr like asttr.asttr.
		  {imesg.i 1828} update vasttr."
       &file = "asttr"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "asttr.asttr ge vasttr"
       &flddisp = "asttr.asttr label ""TRX KODS""
		asttr.atdc label ""DB/CR""
		asttr.atdes label ""APRAKSTS"""
       &chkey = "asttr"
       &chtype = "string"
       &index  = "asttr"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
