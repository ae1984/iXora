/* h0-sim.p
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
        02.02.2012 lyubov - добавила в выборку сим.касспл. условие "cashpl.act"
        09.02.2012 lyubov - полностью изменила поиск
*/

/* k0-cash.p
*/

/* "CASH кас. план " */
{global.i}

 {itemlist.i
    &defvar  = " "
    &updvar  = " "
    &where = "cashpl.act"
    &frame = "row 5 centered scroll 1 15 down overlay top-only"
    &index = "sim"
    &predisp =" "
    &chkey = "sim"
    &chtype = "integer"
    &file = "cashpl"
    &flddisp = "cashpl.sim cashpl.des"
    &funadd = "if frame-value = "" "" then do:
		       {imesg.i 9205}.
		       pause 1.
		       next.
		       end." }