/* res-prf22.p
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
	19/10/06 u00121 добавил no-undo, no-lock  в поиски по таблицам, убрал global.i вместо явно прописал необходимые глобальные переменные.
			и вообще, массовое использование глобальных переменных введет к нецелесообразному использованию памяти, в global.i иx "тучи", здесь используется одна,
			а память выделяется под все. ДОЛОЙ global.i!!!

*/


def shared var g-today as date.

def shared temp-table temp no-undo
  field  kod  as char
  field  gl  as integer format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def  shared var v-gl as char no-undo.
def  shared var s-gl as char no-undo.
def  shared var vasof as date no-undo.

def  shared var i as int no-undo.  
def  shared var k as int no-undo. 

def var m-begday as date init 01/01/1996 no-undo.
def var m-endday as date no-undo.

m-endday = vasof.

if vasof < g-today then
do:

	do i =  1 to NUM-ENTRIES(v-gl):
		for each ast.gl field (ast.gl.gl) where  integer(substr(string(ast.gl.gl),1,4)) = integer(entry(i,v-gl)) and ast.gl.totlev  = 1 no-lock.
			for each ast.crc field (ast.crc.crc) no-lock.
				find last ast.glday where ast.glday.gl = ast.gl.gl and ast.glday.gdt <= vasof and ast.glday.crc = ast.crc.crc no-lock no-error.
				if available ast.glday then 
				do:
					find last ast.crchis where ast.crchis.crc = ast.glday.crc and ast.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.
					find temp where temp.gl = ast.glday.gl and temp.kod = entry(i,v-gl)  no-error.
					if available temp then    
						temp.val =  temp.val + (ast.glday.bal * ast.crchis.rate[1]) /* / 1000*/ .
					else 
					do:
						create temp.  
						assign
							temp.kod = entry(i,v-gl)
							temp.gl = ast.glday.gl
							temp.val =  (ast.glday.bal * ast.crchis.rate[1]) /*/ 1000*/.
					end.
				end. /*if available glday*/
			end. /*for each crc*/
		end. /*gl*/
	end. /*i*/     

	do i =  1 to NUM-ENTRIES(s-gl):
		for each ast.gl field(ast.gl.gl)  where  integer(substr(string(ast.gl.gl),1,4)) = integer(entry(i,s-gl)) and ast.gl.totlev  = 1 no-lock.
			for each ast.crc field(ast.crc.crc) no-lock where ast.crc.crc =1:
				find last ast.glday where ast.glday.gl = ast.gl.gl and ast.glday.gdt <= vasof and ast.glday.crc = ast.crc.crc no-lock no-error.
				if available ast.glday then 
				do:
					find last ast.crchis where ast.crchis.crc = ast.glday.crc and ast.crchis.rdt <= vasof  use-index crcrdt no-lock no-error.
					find temp where temp.gl = ast.glday.gl and temp.kod = entry(i,s-gl)  no-error.
					if available temp then    
						temp.val =  temp.val + (ast.glday.bal * ast.crchis.rate[1]) /*/ 1000*/ .
					else 
					do:
						create temp.  
						assign 
							temp.kod = entry(i,s-gl)
							temp.gl = ast.glday.gl
							temp.val =  (ast.glday.bal * ast.crchis.rate[1]) /*/ 1000*/ .
					end.
				end. /*if available glday*/
			end. /*for each crc*/
		end. /*gl*/
	end. /*i*/     
end. /* if vasof < g-today then */
else
do:
	for each ast.glbal field(ast.glbal.gl ast.glbal.bal) where (lookup(substr(string(ast.glbal.gl),1,4),s-gl) <> 0) and ast.glbal.crc = 1 no-lock:
		find ast.gl where ast.gl.gl = ast.glbal.gl no-lock.
		if ast.gl.totlev = 1 then
		do:
			find temp where temp.gl = ast.glbal.gl and temp.kod = substr(string(ast.glbal.gl),1,4) no-error.
			if available temp then    
				temp.val =  temp.val + (ast.glbal.bal).
			else 
			do:
				create temp.
				assign
					temp.kod = substr(string(ast.glbal.gl),1,4)
					temp.gl = ast.glbal.gl
					temp.val = ast.glbal.bal.
			end.
			for each ast.jl field(ast.jl.dc ast.jl.dam ast.jl.cam) where ast.jl.crc = 1 and ast.jl.jdt = g-today and ast.jl.gl = ast.gl.gl no-lock:
				if ast.jl.dc = 'd' then 
					temp.val = temp.val + ast.jl.dam.
				else 
					temp.val = temp.val - ast.jl.cam.
			end.
		end.
	end.
end.

