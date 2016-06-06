/* 8st-prfdek11.p
 * MODULE
        Статистика
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Сбор данных по отчету 7pn
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
	04/04/2006 u00121	- убрал конект к базе stat
*/

def shared temp-table temp
  field  kod  as char
  field  gl  as integer format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def  shared var v-gl as char extent 200.
def  shared var s-gl as char extent 200.
def  shared var vasof as date.

def  shared var i as int. 
def  shared var k as int. 
def  shared var j as int init 1. 
def var rez as char no-undo. 
def var priz as char no-undo.
def var num as integer no-undo.

do j = 1 to 10:
	do i =  4 to NUM-ENTRIES(s-gl[j]):

		create temp. temp.kod =  entry(1 ,s-gl[j]). 
			temp.rem = entry(i ,s-gl[j]).

		find  sthead where rptform = '7pn' and rptfrom = vasof and rptto = vasof no-error. 
		if not available sthead then 
		do: 
			message 'Нет данных по отчету  7pn' 'за '  vasof .  
			return. 
		end. 

		rez = entry(2 ,s-gl[j]). priz = entry(3 ,s-gl[j]).

		if rez = '*' then 
		do:
			for each stdata where stdata.referid = sthead.referid and stdata.x1 >= '0000009' and substr(stdata.fun,1,4) matches entry(i ,s-gl[j]) and   substr(stdata.fun,6,1) eq trim(priz) no-lock.
				num = R-INDEX ( stdata.fun, ',' ) .
				temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
			end.
		end. /*if rez = '*' */
		else 
		do:
			for each stdata where stdata.referid = sthead.referid and stdata.x1 >= '0000009' and substr(stdata.fun,1,4) matches entry(i ,s-gl[j]) 
					and   substr(stdata.fun,6,1) eq trim(priz) and substr(stdata.fun,5,1) eq trim(rez) no-lock .
				num = R-INDEX ( stdata.fun, ',' ) .
				temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
			end.
		end. /*if rez <> '*' */
	end.  /*i*/
end.   /*j*/  

