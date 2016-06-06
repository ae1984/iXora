/* swmt-i-f.i
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

/* KOVAL Подсказки для полей в которых менеджер явно не указывает типы A,B,D,K и т.д. */
 case swin.swfield:
           when "33" then assign
			 contentt="Тип"
			 content1="  Валюта Сумма"
			 content2=""
			 content3="".
           when "70" then assign
			 contentt=""
			 content1="     Назначение"
			 content2="        Платежа"
			 content3="".
           when "9f" then assign
			 contentt=""
			 content1="         Страна"
			 content2="     получатель"
			 content3="".
           when "72" then assign
			 contentt=""
			 content1="     Информация"
			 content2="     получателю"
			 content3=" от отправителя".
           when "71" then do:
		         if swin.type="A" then assign contentt="Тип" content1="         Детали" content2="         оплаты" content3="".
           		 if swin.type="F" then assign contentt="Тип" content1="  Валюта Сумма" content2="" content3="".
	   end.
           when "50" then assign
			 contentt=""
			 content1="   Отправитель:"
			 content2="       платежа:"
			 content3="".

           when "59" then assign
			 contentt=""
			 content1="         /Счет:"
			 content2="  Наименование:"
			 content3="".

 end case.    
