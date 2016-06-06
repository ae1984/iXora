/* 8st-prf11.p
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
        25.05.04 - suchkov - увеличил цикл до 54
        24/03/06 nataly -  перевела на базу BANK
	03/07/06 u00121 - добавил индекс в таблицу wf2, а также no-undo
*/

def shared temp-table temp no-undo
	field  kod  as char
	field  gl  as integer format 'zzzzzz'
	field  val  as decimal format 'z,zzz,zzz,zz9.99-'
	field rem  as char
	index idx1-temp kod
	index idx2-temp gl kod. 

def  shared var v-gl as char extent 200.
def  shared var s-gl as char extent 200.
def  shared var vasof as date.

def  shared var i as int. 
def  shared var k as int. 
def  shared var j as int init 1. 
def var rez as char no-undo.
def var priz as char no-undo.
def var num as integer no-undo.


def new shared temp-table wf1 no-undo
	field wdfb  like txb.dfb.dfb
	field wname like txb.bankl.bank
	field wgeo as char
	field wrez as char
	field wkod as char
	field wcrc  like txb.crc.crc
	field wsumpr  as decimal
	field wsumLs  as decimal
	field wlne like txb.bankl.lne
	index idx1-wf1 wdfb wcrc
	index idx2-wf1 wkod.

def new shared temp-table wf2 no-undo
	field wfun  like txb.fun.fun
	field wname like txb.bankl.bank
	field wgeo as char
	field wgl like txb.fun.gl
	field wrez as char
	field wkod as char
	field wcrc  like txb.crc.crc
	field wsumpr  as decimal format "z,zzz,zzz,zz9.99-"
	field wsumLs  as decimal format "z,zzz,zzz,zz9.99-"
	field wlne like txb.bankl.lne
	index idx1-wf2 wfun wcrc
	index idx2-wf2 wkod.

for each wf1. delete wf1. end.
for each wf2. delete wf2. end.

run r-do1n.
run r-do2n.

do j = 1 to 55:
	do i =  4 to NUM-ENTRIES(s-gl[j]):

		case  entry(1 ,s-gl[j]):
			when '001' then 
			do:
				create temp. 
				assign
					temp.kod =  entry(1 ,s-gl[j]) 
					temp.rem = entry(i ,s-gl[j]).
				if entry(i ,s-gl[j]) = 'd1t' then 
				do:
					for each wf1 where trim(wf1.wkod) matches '*035*' no-lock. 
						temp.val =  temp.val + round(wf1.wsumpr / 1000, 0)  + round(wf1.wsumLs / 1000, 0)  .
					end.
				end.
				if entry(i ,s-gl[j]) = 'd2t' then 
				do:
					for each wf2 where trim(wf2.wkod) matches '*035*' no-lock . 
						temp.val =  temp.val + round(wf2.wsumpr / 1000, 0)  + round(wf2.wsumLs / 1000, 0) .
					end.
				end.
			end. /*001*/
			when '131' then 
			do:
				create temp. 
				assign
					temp.kod =  entry(1 ,s-gl[j])
					temp.rem = entry(i ,s-gl[j]).
				if entry(i ,s-gl[j]) = 'd1t' then 
				do:
					for each wf1 where trim(wf1.wkod) matches '*058*' no-lock . 
						temp.val =  temp.val + round(wf1.wsumpr / 1000, 0)  + round(wf1.wsumLs / 1000, 0)  .
					end.
				end.
				if entry(i ,s-gl[j]) = 'd2t' then 
				do:
					for each wf2 where trim(wf2.wkod) matches '*058*' no-lock. 
						temp.val =  temp.val + round(wf2.wsumpr / 1000, 0)  + round(wf2.wsumLs / 1000, 0) .
					end.
				end.
			end.   /*131*/
			otherwise 
			do:
				create temp. 
				assign
					temp.kod =  entry(1 ,s-gl[j])
					temp.rem = entry(i ,s-gl[j]).
				find  last txb.sthead where rptform = '7pn' and rptfrom = vasof and rptto = vasof no-error. 
				if not available sthead then 
				do: 
					/*message 'Нет данных по отчету  7pn за '  vasof .  */ return. 
				end. 

				rez = entry(2 ,s-gl[j]). priz = entry(3 ,s-gl[j]).

				if rez = '*' then 
				do:
					for each txb.stdata where stdata.referid = sthead.referid and stdata.x1 >= '0000009' and 
								  substr(stdata.fun,1,4) matches entry(i ,s-gl[j]) and   substr(stdata.fun,6,1) eq trim(priz) no-lock.
						num = R-INDEX ( stdata.fun, ',' ) .
						temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
					end.
				end. /*if rez = '*' */
				else 
				do:
					for each txb.stdata where stdata.referid = sthead.referid and stdata.x1 >= '0000009' and substr(stdata.fun,1,4) matches entry(i ,s-gl[j]) and   
								  substr(stdata.fun,6,1) eq trim(priz) and substr(stdata.fun,5,1) eq trim(rez)  no-lock.
						num = R-INDEX ( stdata.fun, ',' ) .
						temp.val = temp.val + decimal(substr(stdata.fun,num + 1)).
					end.
				end. /*if rez <> '*' */
			end. /*otherwise*/
		end case.
	end.  /*i*/
end.   /*j*/  

