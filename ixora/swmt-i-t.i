/* swmt-i-t.i
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

/* KOVAL Подсказки для типов */

 case swin.type:
           when "A" then if swin.swfield<>"32" then assign
			 contentt="Тип"
			 content1="         /Счет:"
			 content2="     Swift-код:"
			 content3="  Наименование:".
           when "B" then assign
			 contentt="Тип"
			 content1="         /Счет:"
			 content2=" Корреспондент:"
			 content3="".
           when "D" or when "K" then assign
			 contentt="Тип"
			 content1="         /Счет:"
			 content2="         Адрес:"
			 content3="".
           when "N" then assign
			 contentt="Тип"
			 content1=""
			 content2=""
			 content3="".
	   when "F" then  assign
			 contentt=""
			 content1=""
			 content2=""
			 content3="".
	   when "" then  assign
			 contentt=""
			 content1=""
			 content2=""
			 content3="".
 end case.    


