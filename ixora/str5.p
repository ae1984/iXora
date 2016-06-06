/* str5.p
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
       12/12/03 nataly внесены изменения в связи с новым ПС
	19/10/06 u00121 добавил no-undo, no-lock  в поиски по таблицам, убрал global.i вместо явно прописал необходимые глобальные переменные.
			и вообще, массовое использование глобальных переменных введет к нецелесообразному использованию памяти, в global.i иx "тучи", здесь используется одна,
			а память выделяется под все. ДОЛОЙ global.i!!!

*/

/*
def var sum$ as dec format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var tsum$ as dec format "->>>,>>>,>>>,>>>,>>9.99" no-undo.
def var tmpsum$ as dec format "->>>,>>>,>>>,>>9.99" no-undo.
*/

def var dat2M as date no-undo.  
def var sum as decimal no-undo. 

def shared temp-table temp no-undo
  field  kod  as char
  field  gl  as integer format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def temp-table temp2 no-undo
   field lon as char
   field lonsec as integer
   field cif as char
   field val as decimal
   field gl as integer
   field rem as char .

def  shared stream st-out.
def  shared var vasof as date no-undo.

/*def var bol1 as logical init true no-undo.*/
def var k as integer no-undo.
def var i as integer no-undo.
def var c-gl as char extent 200 no-undo.
def var d-gl as char extent 200 no-undo.

c-gl[1] = '2215'.
c-gl[2] = '2217'.
c-gl[3] = '2223'.
c-gl[4] = '2224'.
c-gl[5] = '2401'.
c-gl[6] = '2219'.
/*12/12/03 nataly*/
c-gl[7] = '2206'.
c-gl[8] = '2207'.
c-gl[9] = '2208'.

d-gl[1] = '2855'.

dat2M = vasof + 31.
 case  month(dat2M). 
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then 
   dat2M = date(month(dat2M),31,year(dat2M)).
  when 4 or when 6 or when 9 or when 11 then 
   dat2M = date(month(dat2M),30,year(dat2M)).
  otherwise dat2M = date(month(dat2M),28,year(dat2M)).
end case.

do i = 1 to 9:
	do k =  1 to NUM-ENTRIES(c-gl[i]):

		for each ast.gl field (ast.gl.gl) where integer(substr(string(ast.gl.gl),1,4)) = integer(entry(k,c-gl[i])) and ast.gl.totlev  = 1 no-lock:

 			for each ast.aaa field (ast.aaa.aaa ast.aaa.crc ast.aaa.lgr) where ast.aaa.gl  = ast.gl.gl and (ast.aaa.expdt > vasof and ast.aaa.expdt <= dat2M) no-lock:
    				find last ast.aab where ast.aab.aaa = ast.aaa.aaa and  ast.aab.fdt <= vasof no-lock no-error.
    				if available ast.aab and ast.aab.bal <> 0 then 
    				do:
       					find last ast.crchis where ast.crchis.crc = ast.aaa.crc and ast.crchis.regdt <=  vasof no-lock no-error.
          				create temp2.  
       					assign
       						       temp2.lon = ast.aaa.aaa
       						       temp2.val  = ast.aab.bal * ast.crchis.rate[1]
       						       temp2.gl  = ast.gl.gl
       						       temp2.rem = ast.aaa.lgr.
    				end.    /*if available*/
   			end. /*for each aaa*/
  		end. /*for each gl*/
 	end. /*k*/
end. /*i*/

for each temp2 no-lock break by substr(string(temp2.gl),1,4) :
    ACCUMULATE temp2.val (total by  substr(string(temp2.gl),1,4)).

    if last-of(substr(string(temp2.gl),1,4)) then  
       do:
          sum  = ACCUMulate total by (substr(string(temp2.gl),1,4)) temp2.val.
          create temp. 
          assign
	          temp.val = sum /*/ 1000*/ . 
        	  temp.kod =  substr(string(temp2.gl),1,4) .
       end.
end.
