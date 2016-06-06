/* rus2eng.p
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

/* 
 * KOVAL
 * 12.06.02
 * перекодировка в латинский алфавит
 * для подготовки swift сообщения, т.е.
 * замена русских букв на подходящие латинские
 */
	define input-output parameter t as char.

	def var rus as integer extent 33 init [225,226,247,231,228,229,179,246, 250,233,234,235,236,237,238,239,240,242,243,244,245,230,232,  227, 254, 251, 253, 248,249,255,252,224, 241].
	def var eng as char    extent 33 init ["A","B","V","G","D","E","E","ZH","Z","I","I","K","L","M","N","O","P","R","S","T","U","F","KH","TS","CH","SH","SCH","","Y","","E","YU","YA"].

	def var i as integer.
	def var j as integer.
	t = caps(t).
	i=1.
	M1:
	repeat:
	 do j=1 to 33:
	    if asc(substr(t,i,1)) = rus[j] then
	         substring(t,i,1,"CHARACTER") = eng[j].
	 end.
	 i = i + 1.
	 if i > length(t) then leave M1 .
	end.
/*

	def var rus as char extent 32 init ["А","Б","В","Г","Д","Е","Ж", "З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х", "Ц", "Ч", "Ш", "Щ",  "Ь","Ы","Ъ","Э","Ю", "Я"].
	def var eng as char extent 32 init ["A","B","V","G","D","E","ZH","Z","I","I","K","L","M","N","O","P","R","S","T","U","F","KH","TS","CH","SH","SCH","-","Y","-","E","YU","YA"].

*/
