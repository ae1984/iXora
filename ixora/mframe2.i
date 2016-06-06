/* mframe2.i
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
	04/06/04 valery если в codfr.name[2] (по департаменту) указать через запятую код других департаментов, то текущий департамент сможет контролировать только эти департаменты
			если в codfr.name[2] ни чего не указано, то можно контролировать любой другой департамент. Все это дело обрабатывается в "ишке" - mframe2.i

*/

/** mframe.i **/

define {1} variable d_cif   like cif.cif.
define {1} variable c_cif   like cif.cif.
define {1} variable d_avail as character format "x(25)".
define {1} variable c_avail as character format "x(25)".
define {1} variable m_avail as character format "x(25)".
define {1} variable d_atl   as character.
define {1} variable c_atl   as character.
define {1} variable m_atl   as character.
define {1} variable d_lab   as character.
define {1} variable d_izm   as character format "x(25)".
define {1} variable dname_1 as character format "x(38)".
define {1} variable dname_2 as character format "x(38)".
define {1} variable dname_3 as character format "x(38)".
define {1} variable cname_1 as character format "x(38)".
define {1} variable cname_2 as character format "x(38)".
define {1} variable cname_3 as character format "x(38)".

define {1} variable db_com  as character format "x(10)" view-as combo-box.
define {1} variable cr_com  as character format "x(10)" view-as combo-box.
define {1} variable com_com as character format "x(10)" view-as combo-box.

define {1} variable m_sub   as character initial "jou".

/***********04/06/04**valery*****************************************************************************************************************/
def var depwho1 as char init ''. /*кто контролирует*/
def var depwho2 as char init ''. /*кого контролирует*/
def var f3 as logical init true. /*если контролируем, то true, иначе false*/
def var jhdoc like jh.jh.
def var v-who like joudoc.who.

/***********04/06/04**valery*****************************************************************************************************************/

/***********04/06/04**valery*****************************************************************************************************************/
function chk-gosacc returns logical (p-val1 as char).
        /*---------------------------------------------------------------------------------------*/
           find joudoc where joudoc.docnum = p-val1 exclusive-lock no-error no-wait. 
	   if avail joudoc then do:
			jhdoc = joudoc.jh.
			v-who = joudoc.who.
	   end.
           else do:
		find ujo where ujo.docnum = p-val1 exclusive-lock no-error no-wait. 
		if avail ujo then do:
			jhdoc = ujo.jh.		
			v-who = ujo.who.
		end.
		else do:
                  message "ДОКУМЕНТ НЕ НАЙДЕН.".
                    pause 3.
                    return false.
            	end.
           end.

        /*---------------------------------------------------------------------------------------*/

	f3 = true. /*по умолчанию контроль разрешен*/

        /*---------------------------------------------------------------------------------------*/
	find last jl where jl.jh = jhdoc and sub = 'cif' and (dam - cam) < 0 no-lock no-error. /*проверяем, указан ли по кредиту клиентский счет*/
	if not avail jl then return true. /*если не указан, то значит здесь нет нас интересующих ограничений на контроль*/
        /*---------------------------------------------------------------------------------------*/

	/*--если по кредиту указан клиентский счет, то проверяем контролирует ли его конкретный деп-нт или нет--*/
        /*---------------------------------------------------------------------------------------*/
	find ofc where ofc = g-ofc no-lock no-error. /*находим код департамента контролирующего*/
	if avail ofc then depwho1 = ofc.titcd. /*сохраняем код деп. контролирующего*/
        /*---------------------------------------------------------------------------------------*/

        /*---------------------------------------------------------------------------------------*/
	find ofc where ofc = v-who no-lock no-error. /*находи код департамента того, кого контролируем*/
	if avail ofc then depwho2 = ofc.titcd. /*сохраняем код деп. контролируемого*/
	else do: message "Офицер (" joudoc.who ") контролируемого документа не найден в базе данных!". pause 10. undo, retry. end.
        /*---------------------------------------------------------------------------------------*/

        /*---------------------------------------------------------------------------------------*/
 	for each codfr where codfr.codfr = 'sproftcn' and codfr.code <> 'msc' no-lock. 
		if codfr.name[2] <> '' then do: /*ищем все записи, у которых в поле name[2] прописаны подконтрольные департаменты*/
			if lookup(depwho2,codfr.name[2]) > 0  then do: /*контролируемый деп-т входит в их число*/ 
				if codfr.code = depwho1 then /* и является ли текущий деп-т, деп-ом контролируемого?*/
					return true.	/*если условия совпадают то разрешаем контроль*/
				else f3 = false. /*если контролирующий не принадлежит департаменту, которому разрешено контролировать то ругаемся :)*/
			end.
		end.
	end.
        /*---------------------------------------------------------------------------------------*/
                                                                                                   
	if not f3 then do: 
			find codfr where codfr.codfr = 'sproftcn' and codfr.code matches depwho2 and codfr.code <> 'msc' no-lock . 
			message "Вы не можете штамповать документы " codfr.name[1]. pause 10. return false. 
	end.
	else return true.
end.
/***********04/06/04**valery*****************************************************************************************************************/


define {1} frame f_main 
skip(2)
/*"__________________ДЕБЕТ______________________________КРЕДИТ___________________"*/
    v_doc validate(chk-gosacc(v_doc),'')  label "ДОКУМЕНТ " help "SPACE BAR, ENTER - новый документ   " 
/*    joudoc.num label "ДОК.Nr." at 23*/
    vjh label "ТРН" at 23  /*56*/
/*    v-amt lable "Summa" at 40*/
        skip
     with row 4 side-labels no-box.

