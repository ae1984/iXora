  /* h-bank.p
 * MODULE
        Электронный кассир
 * DESCRIPTION
        поиск бика филиалов
 * BASES
         BANK COMM TXB
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

 * CHANGES
            07/02/2012 Luiza - добавила названия баз BANK COMM TXB
*/

{itemlist.i
       &file = "txb"
       &where = "txb.bank begins 'txb'"
       &form = "txb.bank txb.info form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "txb.bank txb.info"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
