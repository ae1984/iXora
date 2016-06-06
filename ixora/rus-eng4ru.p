/* rus-eng4ru.p
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
        03.08.2011 aigul
 * CHANGES
*/


define input  parameter str as char.
define output parameter outstr as char.

def var rus as char extent 37 init
["А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я","№","%","&"].
def var eng as char    extent 37 init
["A","B","V","G","D","E","o","J","Z","I","i","K","L","M","N","O","P","R","S","T","U","F","H","C","c","Q","q","x","Y","X","e","u","a","n","p","d"].

	def var i as integer.
	def var j as integer.
	def var ns as log init false.
	def var slen as int.
	str = caps(str).
	slen = length(str).

	repeat i=1 to slen:
	 repeat j=1 to 37:
	   if substr(str,i,1) = rus[j] then
	   do:
          if index(substr(str,i,1),rus[j]) <> 0 then do:
	      outstr = outstr + eng[j].
	      ns = true.
          end.
	   end.
	 end.
	 if not ns then outstr = outstr + substr(str,i,1).

	 ns = false.
	end.

