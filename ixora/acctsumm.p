/* acctsumm.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def temp-table acct field name  like aaa.cif
		  field acctm like lgr.des
		  field acct  like aaa.aaa
		  field bal   like aaa.cr[1].


	for each aaa break by aaa.cif by aaa.lgr:
	    find lgr of aaa.
	    create acct .
	    acct.name = aaa.cif.
	    acct.acctm = lgr.des.
	    acct.acct = aaa.aaa.
	    acct.bal =  aaa.cr[1] - aaa.dr[1].
	    end.
