/* rus-eng.p
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
        05.05.2010 k.gitalov переделал rus2eng - два параметра + измененный алгоритм
 * CHANGES
*/


define input  parameter str as char.
define output parameter outstr as char.

def var rus as char extent 32 init 
["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц", "Ч", "Ш", "Щ",  "Ъ","Ы", "Ь", "Э", "Ю", "Я"].
def var eng as char    extent 32 init
["A","B","V","G","D","E","ZH","Z","I","I","K","L","M","N","O","P","R","S","T","U","F","KH","C","CH","SH","SHH","\"","Y","\'","EH","YU","YA"].

	def var i as integer.
	def var j as integer.
	def var ns as log init false.
	def var slen as int.
	str = caps(str).
	slen = length(str).
		
	repeat i=1 to slen:
	 repeat j=1 to 32:
	   if substr(str,i,1) = rus[j] then
	   do:
	      outstr = outstr + eng[j].
	      ns = true.
	   end.      
	 end.
	 if not ns then outstr = outstr + substr(str,i,1).
	 ns = false.
	end.

	