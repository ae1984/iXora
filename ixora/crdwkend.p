/* crdwkend.p
 * MODULE
        Касса
 * DESCRIPTION
	Выдача наличных по пласт.карт. в выходные дни 
	КОМИССИЯ ЗА ОБМЕН НЕПЛАТ.ВАЛЮТЫ ЧЕРЕЗ КАССУ В ПУТИ
 * RUN
	nmenu.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
	FindArp100200.p - определение кассы в пути для РКО
 * MENU
	3-1-16
 * AUTHOR
        13.04.2005 u00121
 * BASE`S
	BANK
 * CHANGES
	18.04.2005 u00121 - добавил обработку КАССА В ПУТИ РКО - КОМИССИЯ ЗА ОБМЕН НЕПЛАТ.ВАЛЮТЫ 
*/

/**INCLUDE`S******************************************************************************************************************************************************************************************/
{mainhead.i}
{get-dep.i}
/*****************************************************************************************************************************************************************************************************/

/**BUTTOM`S*******************************************************************************************************************************************************************************************/
def button m-tran label "Транзакция".
def button m-exit label "Выход".
def button m-print label "Печать".
/*****************************************************************************************************************************************************************************************************/


/**TEMP-TABLE`S***************************************************************************************************************************************************************************************/
def temp-table w-cods 
    field number as integer
    field code as logical
    field codfr like trxcdf.codfr.

def temp-table remarks 
    field number as integer
    field remark as logical.

def temp-table w-par 
    field v-d like ujo.docnum
    field v-i as int format "999" label "Nr." 
    field v-des as cha format "x(60)" label " Param " 
    field v-value as cha format "x(10)" label " Value " . 
/*****************************************************************************************************************************************************************************************************/

/**VARIABLE`S*****************************************************************************************************************************************************************************************/
def var m_sub           as character initial "ujo" no-undo. /*Тип создаваемого документа*/
def var rcode           as integer no-undo. /*Код ошибки при создании проводки*/
def var rdes            as character no-undo. /*Описание ошибки*/
def new shared var s-jh like jh.jh. /*Номер созданной транзакции*/
def var templ           as character no-undo. /*Название шаблона*/
def var vparam          as character no-undo. /*Параметры шаблона*/
def var vdel            as character initial "^" no-undo. /*Разделитель между параметрами шаблона*/
def var nxt_doc_nmbr    as integer no-undo. /*Номер документа (ujo) проводки */
def var uni_template    as character format "x(7)" no-undo. /*Еще одно название шаблона*/
def var seq_number      like aaa.aaa no-undo.  /*Еще один номер документа (ujo) проводки*/
def var repl_line       as integer initial 1 no-undo. /*Номер параметра проводки в списке параметров*/
def var trx_header      as integer no-undo.
def var var_rem as char format "x(50)" . /*Примечание к проводке*/

def var v-dep like ppoint.depart no-undo. /*код департамента сотрудника*/
def var combo-crc as char format "x(3)" view-as combo-box no-undo. /*COMBO-BOX для выбора валюты*/
def var st-crc as char init "KZT,USD" no-undo. /*Значения в COMBO-BOX по умолчанию*/
def var v-crc like crc.crc no-undo. /*Код валюты*/
def var v-crcdes like crc.des format "x(60)" no-undo. /*Название шаблона соответсвующего валюте*/
def var v-arp like arp.arp label "Счет кассы в пути:" init "?" no-undo. /*АРП счет кассы в пути*/

def var destination as char format "x(50)" view-as combo-box LIST-ITEM-PAIRS "ВЫПЛАТЫ ПО ПЛАСТИКОВЫМ КАРТОЧКАМ В ВЫХОДНЫЕ",yes,"КОМИССИЯ ЗА ОБМЕН НЕПЛАТЕЖНОЙ ВАЛЮТЫ",no no-undo. /*Выбор действия (назначения)*/
							    /*установка параметра LIST-ITEM-PAIRS позволяет использовать в переменной SELF:SCREEN-VALUE не название выбранного пункта, а необходимое нам значение*/
def var selection as char. /*здесь будем хранить выбранное значение в COMBO-BOX`е "destination"*/

def query q_link for ujolink, w-par scrolling. /*получаем список параметров, которые необходимо ввести пользователю*/

def browse b_link query q_link  display /*Выводим список параметров для заполнения*/
    ujolink.parnum label "N" format "z9"
    w-par.v-des    label "Наименование" format "x(20)"
    ujolink.parval label "Значение" format "x(50)"
    enable ujolink.parval
    with 7 down separators no-hide.
/*****************************************************************************************************************************************************************************************************/

/**FRAME`S********************************************************************************************************************************************************************************************/
def frame f_remark  
    var_rem
    with row 17 col 2 overlay no-label no-box.         

def frame sel-des destination with centered row 10 no-label title "Выбор действия". /*Фрейм для выбора действия (назначения)*/

def frame sel-crc combo-crc with centered row 10 no-label title "Выбор валюты". /*Фрейм для COMBO-BOX`а валюты*/


def frame uni_main
v-crcdes no-label skip
"________________________________________________________________________________" skip
seq_number label "Документ " ujo.jh label "TRX"  ujo.whn label "Дата документа"  skip 
v-arp ppoint.name no-label skip     
b_link skip(1) 
var_rem at 2 no-label skip(2) 
m-tran m-print m-exit 
	with row 2 side-labels no-box no-hide.
/*****************************************************************************************************************************************************************************************************/



/**u00121 18.04.2005 Выбираем необходимое нам действие***********************************************************************************************************************************************/
v-crc = 1. /*по умолчанию код валюты равен KZT*/
selection = "yes".  /*По умолчанию работаем с карточками*/

enable destination with frame sel-des.

on value-changed of destination
do:
	selection = SELF:SCREEN-VALUE.
end.
on return of destination or return of combo-crc
do:
    apply "go".
end.
update destination with frame sel-des.


if selection = "yes" then /*если выбраны карточки */
do:
	/**Пользователь должен выбрать валюту*****************************************************************************************************************************************************************/
	assign combo-crc:LIST-ITEMS in frame sel-crc = st-crc.
	enable combo-crc with frame sel-crc.
	message "F1 - для продолжения".
	on value-changed of combo-crc
	do:
		find last crc where crc.code = SELF:SCREEN-VALUE no-lock no-error.
		if avail crc then
			v-crc = crc.crc.
		else 
		do:
			message "Внимание! Валюта " SELF:SCREEN-VALUE "отсутствует!".
			pause.
			undo, return.
		end.
	end.
	update combo-crc with frame sel-crc.
	/*****************************************************************************************************************************************************************************************************/
	/**Определяем шаблон соответсвующий валюте************************************************************************************************************************************************************/
	if v-crc = 1 then
		uni_template = "OPK0023". /*Выдача нал. тенге пласт-кард. в выходные */
	if v-crc = 2 then 
		uni_template = "OPK0024". /*Выдача нал. USD пласт-кард. в выходные */
	/*****************************************************************************************************************************************************************************************************/
end.
else /*если выбрана комиссия*/
	uni_template = "UNI0175". /*КАССА В ПУТИ РКО - КОМИССИЯ ЗА ОБМЕН НЕПЛАТ.ВАЛЮТЫ*/ 
/*****************************************************************************************************************************************************************************************************/

/**Определение параметров департамента офицера********************************************************************************************************************************************************/
v-dep = get-dep(g-ofc, g-today). /*найдем ID департамента офицера*/
find last ppoint where ppoint.depart = v-dep no-lock no-error. /*найдем название департамента офицера*/
/*****************************************************************************************************************************************************************************************************/

find last ofc where ofc.ofc = g-ofc no-lock no-error. /*найдем карточку офицера*/

run FindArp100200(ofc.titcd, v-crc , output v-arp). /*Находим АРП счет соответсвующий валюте и департаменту офицера*/

if v-arp = "?" then /*Если АРП счет не найден*/
do:
	message "Счет АРП Касса в пути не найден для департамента " ppoint.name.
			pause.
			undo, return.
end.

/**Определяем название шаблона************************************************************************************************************************************************************************/
find first trxhead where trxhead.system = substring (uni_template, 1, 3) and  trxhead.code = integer (substring (uni_template, 4, 4)) no-lock no-error.
if avail trxhead then
	v-crcdes = CAPS(trxhead.des).
/*****************************************************************************************************************************************************************************************************/



/**Помощь по параметрам проводки**********************************************************************************************************************************************************************/
on help of browse b_link anywhere do:
	find first w-cods where w-cods.number = ujolink.parnum no-error.
	if available w-cods and w-cods.code = true then 
	do:
		run uni_help1(w-cods.codfr,'*').
	end. 
	else 
	do:
		message "Помощь не доступна !". pause 3.
		hide message.
	end.
end.
/*****************************************************************************************************************************************************************************************************/

/***Обработка кнопок**********************************************************************************************************************************************************************************/
on choose of m-tran do:
	run Create_transaction.
end.

on choose of m-print do:
        run Print_transaction.
end.

/*****************************************************************************************************************************************************************************************************/

/**Изменение полей примечания*************************************************************************************************************************************************************************/
on row-entry of b_link in frame uni_main do:
    
    find first w-cods where w-cods.number = ujolink.parnum no-error.
    if available w-cods and w-cods.code = true then 
       message "F2 - Помощь". 
    else hide message.  
    
    do transaction on error undo, retry:
    find first remarks where remarks.number eq ujolink.parnum no-error.
        if remarks.remark then do:
            var_rem = ujolink.parval.
            update var_rem go-on (down up) with frame f_remark.
		ujolink.parval:screen-value in browse b_link = var_rem.
        end.
        else var_rem = "".
    end.
end.    

/*****************************************************************************************************************************************************************************************************/

/**Создаем ujo - документ*****************************************************************************************************************************************************************************/
DO TRANSACTION on error undo, return:
	
	if keyfunction (lastkey) = "end-error" or uni_template eq "" then do:
        	hide all. 
	        if this-procedure:persistent then delete procedure this-procedure.
        	return.
	end.

	nxt_doc_nmbr = next-value (unijou).  

	create ujo.
		ujo.sys    = substring (uni_template, 1, 3).
		ujo.code   = substring (uni_template, 4, 4).
		ujo.docnum = string (nxt_doc_nmbr). 
		ujo.whn    = g-today.
		ujo.who    = g-ofc.
		ujo.tim    = time.

	seq_number = ujo.docnum.
	
	display  v-crcdes v-arp ppoint.name  ujo.docnum @ seq_number ujo.whn with frame uni_main.

	run Ujo_query.

	open query q_link for each ujolink where ujolink.docnum = ujo.docnum and ujolink.parval <> v-arp, each w-par where w-par.v-d = ujolink.docnum and  w-par.v-i = ujolink.parnum exclusive-lock by w-par.v-d.
	enable b_link m-tran m-print m-exit  with frame uni_main.

end.
WAIT-FOR CHOOSE OF  m-exit.  
/*****************************************************************************************************************************************************************************************************/

/*****************************************************************************************************************************************************************************************************/
Procedure Ujo_line.
	def input parameter refer_number like ujolink.docnum.
	def input parameter param_number like ujolink.parnum.
	def input parameter remark       as logical.
	def input parameter t_des as character.

	do transaction on error undo, retry:
		create ujolink.
			ujolink.docnum = refer_number.
			ujolink.parnum = param_number.
	
		create remarks.
			remarks.number = param_number.
			remarks.remark = remark.

		create w-par.
			w-par.v-d   = refer_number.
			w-par.v-i   = param_number.
			w-par.v-des = t_des.

	end.
end procedure.
/*****************************************************************************************************************************************************************************************************/

/*****************************************************************************************************************************************************************************************************/
Procedure Ujo_query.
	def var i as integer initial 0.
	def var j as integer.

	for each trxhead where trxhead.system = substring (uni_template, 1, 3) and  trxhead.code = integer (substring (uni_template, 4, 4)) no-lock:

		if trxhead.sts-f eq "r" then do:
			i = i + 1.
			run Ujo_line (ujo.docnum, i, false, "Статус проводки").
		end.
		if trxhead.party-f eq "r" then do:
			i = i + 1. 
			run Ujo_line (ujo.docnum, i, false, "Заголовок").
		end.
		if trxhead.point-f eq "r" then do:
			i = i + 1. 
			run Ujo_line (ujo.docnum, i, false, "Пункт").
		end.
		if trxhead.depart-f eq "r" then do:
			i = i + 1. 
			run Ujo_line (ujo.docnum, i, false, "Департамент").
		end.
		if trxhead.mult-f eq "r" then do:
			i = i + 1. 
			run Ujo_line (ujo.docnum, i, false, "Коэфф.повтора").
			repl_line = i.
		end.
		if trxhead.opt-f eq "r" then do:
			i = i + 1. 
			run Ujo_line (ujo.docnum, i, false, "Оптимизация").
		end.

		trx_header = i.

		for each trxtmpl where trxtmpl.code eq trxhead.system + string (trxhead.code, "9999") no-lock:

			if trxtmpl.amt-f eq "r" then do:
				i = i + 1.
				find first trxlabs where trxlabs.code = trxtmpl.code and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "amt-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "DR Amount (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.   
			if trxtmpl.crc-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crc-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "Currency (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.rate-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "rate-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "Rate (Ln=" + string(trxtmpl.ln,"z9") + ")" ).
			end.   
			if trxtmpl.drgl-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "drgl-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false,trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "Debet G/L (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.drsub-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "drsub-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "DR subled type (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.dev-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "dev-f" no-lock no-error. 
				if avail trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "DR subled level (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.dracc-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "dracc-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "DR account (" + trxtmpl.drsub + ") (Ln=" + string(trxtmpl.ln,"z9")  + ")").

				find last ujolink where ujolink.docnum = ujo.docnum no-error.
				if avail ujolink then
					ujolink.parval = v-arp.    
			end.   
			if trxtmpl.crgl-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crgl-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "CR G/L (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.crsub-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crsub-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "CR subled type (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.cev-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "cev-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "CR subled level (Ln=" + string(trxtmpl.ln,"z9") + ")").
			end.
			if trxtmpl.cracc-f eq "r" then do:
				i = i + 1. 
				find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = "cracc-f" no-lock no-error. 
				if available trxlabs then 
					run Ujo_line (ujo.docnum, i, false, trxlabs.des).
				else 
					run Ujo_line (ujo.docnum, i, false, "CR account (" + trxtmpl.crsub + ")" + "(Ln=" + string(trxtmpl.ln,"z9") + ")" ).

				find last ujolink where ujolink.docnum = ujo.docnum no-error.
				if avail ujolink then
					ujolink.parval = v-arp.    
			end.

			repeat j = 1 to 5:
				if trxtmpl.rem-f[j] eq "r" then do:
					i = i + 1. 
					run Ujo_line (ujo.docnum, i, true, "Примечание " + string(j,"9")).
				end.
			end.

			for each trxcdf where trxcdf.trxcode = trxtmpl.code and trxcdf.trxln = trxtmpl.ln:
				if trxcdf.drcod-f eq "r" then do:
					i = i + 1. 
					find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error. 
					if available trxlabs then 
						run Ujo_line (ujo.docnum, i, false, trxlabs.des).
					else 
						run Ujo_line (ujo.docnum, i, false,"DrCode (" + trxcdf.codfr + ")" + "(Ln=" + string(trxtmpl.ln,"z9") + ")" ).
					create w-cods.
						w-cods.number = i.
						w-cods.code = true.
						w-cods.codfr = trxcdf.codfr.

				end.
				if trxcdf.crcode-f eq "r" then do:
					i = i + 1. 
					find first trxlabs where trxlabs.code = uni_template and trxlabs.ln = trxtmpl.ln and trxlabs.fld = trxcdf.codfr + "_Cr" no-lock no-error. 
					if available trxlabs then 
						run Ujo_line (ujo.docnum, i, false, trxlabs.des).
					else 
						run Ujo_line (ujo.docnum, i, false,"CrCode (" + trxcdf.codfr + ")" + "(Ln=" + string(trxtmpl.ln,"z9") + ")" ).
					create w-cods.
						w-cods.number = i.
						w-cods.code = true.
						w-cods.codfr = trxcdf.codfr.
				end.
			end.
		end.
	end. 
end procedure.
/*****************************************************************************************************************************************************************************************************/

/*****************************************************************************************************************************************************************************************************/
Procedure Create_Transaction.
	do transaction on error undo, retry:
		find ujo where ujo.docnum eq seq_number exclusive-lock no-error.
		if not (ujo.jh = 0 or ujo.jh = ?) then 	do:
			message "Транзакция уже проведена.".
			undo, retry.
		end.
		if ujo.who ne g-ofc then do:
			message substitute ("Документ принадлежит &1.", ujo.who).
			undo, return.
		end.

		find first ujolink where ujolink.docnum eq seq_number and ujolink.parnum eq repl_line no-lock.

			vparam = "".
		for each ujolink where ujolink.docnum eq seq_number no-lock:
			vparam = vparam + ujolink.parval + vdel.
		end.

		templ = ujo.sys + ujo.code.
		s-jh = 0.
		run trxgen (templ, vdel, vparam, m_sub, seq_number, output rcode, output rdes, input-output s-jh).

		if rcode ne 0 then do:
			message rdes.
			pause.
			undo, return.
		end.

		ujo.jh = s-jh.
		disp ujo.jh with frame uni_main.
   
		disable b_link with frame uni_main.
	end.
end procedure.
/*****************************************************************************************************************************************************************************************************/

/*****************************************************************************************************************************************************************************************************/
Procedure Print_transaction.
	find ujo where ujo.docnum eq seq_number no-lock no-error.
	if ujo.jh eq ? or ujo.jh eq 0 then do:
		message "Транзакция при документе не обнаружена.".
		undo, retry.
	end.
	s-jh = ujo.jh.

	run uvou_bank ("prit").
	pause 0.
 
	find jh where jh.jh = ujo.jh no-lock no-error.
	if avail jh and jh.sts <> 6 then
	do:
		run trxsts (input s-jh, input 6, output rcode, output rdes).
		if rcode ne 0 then 
		do:
			message rdes.
			undo, return.
		end.
		run chgsts (m_sub, seq_number, "rdy").
	end.

end procedure.
/*****************************************************************************************************************************************************************************************************/