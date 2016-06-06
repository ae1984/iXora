/* tasdstt.p
 * MODULE
        Internet Office
 * DESCRIPTION
        Отсылка распоряжения на отзыв платежа.
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
 * BASES
        BANK COMM IB
 * AUTHOR
        13.04.2004 tsoy
 * CHANGES
*/

TRIGGER PROCEDURE FOR ASSIGN OF doc.state 
	old ost like doc.state.
                CREATE ib.hist.
                ASSIGN
                        ib.hist.type1 = 3
                        ib.hist.type2 = 4
                        ib.hist.procname = "doc.state assign trigger"
                        ib.hist.ip_name = userid("ib")
                        ib.hist.id_doc = doc.id
                        ib.hist.changes = string(ost) + " - " + string(doc.state)
                .
                release ib.hist.
  
  
