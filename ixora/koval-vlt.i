/* koval-vlt.i
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

/*** 	KOVAL Валютный контроль Yes or No
        two beer or not two beer :)
        Кто проконтролировал пишется в remtrz.info[7]
***/
 {get-fio.i}
 {get-dep.i}
 {comm-txb.i}
 def var ourcode as integer.
 ourcode = comm-cod().

 if  ( (get-dep(g-ofc, g-today) <> 1 or ourcode <> 0 ) and (m_pid = "G" or m_pid = "3A") and remtrz.tcrc <> 1 )
/*    or ( ourcode <> 0 and (m_pid = "G" or m_pid = "3A") and remtrz.tcrc <> 1 ) */ 
 then do:

	 MESSAGE "Валютный контроль пройден ?~n" + get-fio(g-ofc) + "~nпожалуйста, подтвердите:" 
	 VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " Валютный контроль " 
	 UPDATE valcntrl.
	 case valcntrl:
		when true  then v-text = s-remtrz + " на очереди " + m_pid + " Подтвержден валютный контроль - " + g-ofc.
		when false then do:
				v-text = s-remtrz + " на очереди " + m_pid + " Валютный контроль НЕ ПОДТВЕРЖДЕН ! " + g-ofc.
				message v-text.
			end.	
	 end case.	
	 run lgps .
	 release logfile . 
	 /*** Запишем электронную подпись в табличку ;) ***/
	 if valcntrl then assign remtrz.info[7] = get-fio(g-ofc).
	 	     else undo, leave.
 end.
/*** 	KOVAL Валютный контроль Yes or No 		***/
