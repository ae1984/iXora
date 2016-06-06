/* spbank.p
 * MODULE
	СПРАВОЧНИК
 * DESCRIPTION
	Загрузка справочника банков
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-9-8
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	26.04.2001 ????? добавлена связь с таблицей bankt
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        02.06.2004 nadejda - изменен смысл поля bankt.aut - теперь это признак, что корсчет открыт именно в этом банке, а не просто через него отправлять
        20.10.2004 tsoy    - список файлов теперь не в переменной а во временной таблице
	05.05.2005 u00121  - справочник теперь формируется по формату МТ993 согласно стандарту КЦМР "Система платежей - процедуры обмена и форматы" от 19.01.2005 ТЗ ї20 от 03.05.2005
			     а также справочник теперь синхронизируется с филиалами
	23.06.2005 u00121  - ТЗ ї 47 от 08.06.2005 - введен стату банка 0 - открыт, 1 - открыт, закрыты активные операции, 2 - закрыт
    24/04/2012 evseev  - rebranding.БИК из sysc cleocod
    25/04/2012 evseev  - повтор
    27/04/2012 evseev  - повтор
*/


{lgps.i}
{global.i}

def var filelog as char init "spbank".

def temp-table bb
	field act as char label "Команда"  /*команда: ADD,DEL,UPD*/
	field bank like bankl.bank label "БИК" /*Бик банка*/
	field cbank like bankl.cbank /*БИК головного банка*/
	field name like bankl.name label "Название банка" /*Название банка*/
	field newbank like bankl.bank /*новый Бик банка, только если act = UPD*/
        field mntrm like bankl.mntrm
	field sts like bankl.sts. /*Статус банка Закрыт/открыт*/

def temp-table srp
	field act as char label "Команда" /*команда: ADD,DEL,UPD*/
	field bank like bankl.bank label "БИК" /*Бик банка*/
	field crbank like bankl.crbank /*= clear , если банк учавствует в клиринге*/
	field clrtrm as char /*Код терминала клиринговой организации в которой обслуживается банк, для нашего банка и для наших филиалов ВСЕГДА РАВЕН TXB<номер филиала>*/
	field mntrm as char . /*Код основного терминала банка*/

def var v-field  as cha. /*строка считываемая из файла*/
def var v-name like bb.name. /*Имя банка*/

/**Фреймы**************************************************************************/
def frame f-info bb.act bb.name bb.bank background skip with title "Загрузка файла справочника банков" centered row 5.
def frame f-srp srp.act v-name srp.bank background skip with title "Загрузка файла клиентов СРП" centered row 5.
def frame f-bankl bb.act bb.name bb.bank background skip with title "Формирование справочника" centered row 5.
def frame f-bnksrp  srp.act bankl.bank srp.mntrm bankl.acct with title "Формирование клиентов клиринга" no-labels centered row 5.

/**********************************************************************************/
def var v-lbin as cha . /*путь к загружаемым из КЦМР файлам на ixora01*/
find sysc where sysc.sysc = "LBIN" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message " ERROR !!! Не найден путь к загружаемым файлам! (sysc.sysc = 'LBIN') ".
	pause.
	return .
end.
v-lbin = sysc.chval.

/**********************************************************************************/
def var ourbank as char. /*код головного банка или филиала принятый в IXORA - TXB00, TXB01 и т.п.*/
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message " ERROR !!! Отсутствует код банка в АБПК ПРАГМА (sysc.sysc = 'ourbnk')!" .
	pause .
	return .
end.
ourbank = sysc.chval.

/**********************************************************************************/
def var clearing as char. /*код головного банка IXORA для клиринга - всегда TXB00*/
find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message " ERROR !!! Отсутствует запись CLEARING в таблице SYSC!".
	pause .
	return .
end.
clearing = sysc.chval.

/**********************************************************************************/
def var v-bankbik as cha. /*БИК нашего головного банка FOBAKZKA*/
find sysc where sysc.sysc = "clecod" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
	message " ERROR !!! Отсутствует БИК головного банка! (sysc.sysc = 'clecod')".
	pause .
	return .
end.
	v-bankbik = sysc.chval.

/**********************************************************************************/
def var brnch as logical. /*флаг для определения, головной банк или филиал */
if ourbank = clearing  then
	brnch = false.  /*Сброшен флаг - головной банк*/
else
	brnch = true.  /*Установлен флаг - филиал*/
/**********************************************************************************/

def var filename as char . /*Название файла с данными справочника*/
def stream s-file. /*Поток для поиска файлов справочников*/
def stream s-body. /*Поток для считывания файла по строкам*/

run savelog(filelog, "==============================!Начало загрузки справочника банков!==============================").

for each bankl where bankl.bank begins "19" .
    delete bankl.
end.

/*Найдем файл с данными справочника банков по ключевой фразе :77E:/CTRLLIST/BANKS */

input stream s-file through value("grep -l :77E:/CTRLLIST/BANKS " + v-lbin + "* ") .
repeat:
	import stream s-file filename. /*получаем имя файла справочника */
		input stream s-body from value (filename).
			repeat : /*бежим по строчкам файла*/
				import stream s-body delimiter "`" v-field. /*разделитель установлен таким, т.к. предполагается, что данный символ не встречается в файле,
									      а без него строка считывается из файла до первого пробела (пробел разделить по умолчанию)*/
				if v-field begins "-}" then leave . /*если конец swift`овки, то выход*/

				if v-field begins "\{2:" and (substr(v-field,4,4) ne "O993") then leave . /*если не 993 сообщение, то выход*/

				if v-field begins "/CMD/" then /*что будем делать?*/
				do:
					create bb.
						bb.act = substr(v-field,6). /*может принимать следующие значения: NEW, ADD, DEL, UPD*/
					displ bb.act with frame f-info. pause 0.
				end.
				if v-field begins "//NAME/" then /*Название загружаемого банка*/
				do:
					bb.name = substr(v-field,8).
					displ bb.act bb.name with frame f-info. pause 0.
				end.
				if v-field begins "//BIC/" then /*БИК загружаемого банка*/
				do:
					bb.bank = substr(v-field,7).
					bb.cbank = bb.bank. /*По умолчанию устанавливаем БИК головного банка равным БИК`у этого банка*/
					displ bb.act bb.name bb.bank with frame f-info. pause 0.
				end.
				if v-field begins "//HBIC/" then /*Получаем БИК головного банка, если есть*/
					bb.cbank = if brnch then clearing else substr(v-field,8). /*если не наш филиал то прописываем то что прислал КЦМР*/

				if v-field begins "//NEWBIC/" then /*Новый БИК банка, если есть, актуально только если act = UPD*/
						bb.newbank = substr(v-field,10).

				if v-field begins "//STATUS/" then /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/
						bb.sts = integer(substr(v-field,10)).
                                if v-field begins "//BCODE/" then
                                                bb.mntrm = substr(v-field,9).
			end.
		input stream s-body close.
end.
input stream s-file close.

/**********************************************************************************/
/*Найдем файл с данными справочника клиентов МК (участники клиринга) по ключевой фразе :77E:/CTRLLIST/SRPCLIENTS, */
input stream s-file through value("grep -l :77E:/CTRLLIST/SRPCLIENTS " + v-lbin + "* ") .
repeat:
	import stream s-file filename.  /*получаем имя файла справочника */
		input stream s-body from value (filename).
			repeat : /*бежим по строчкам файла*/
				import stream s-body delimiter "`" v-field.

				if v-field begins "-}" then leave . /*если конец swift`овки, то выход*/

				if v-field begins "\{2:" and (substr(v-field,4,4) ne "O993") then leave . /*если не 993 сообщение, то выход*/

				if v-field begins "/CMD/" then /*что будем делать?*/
				do:
					create srp.
						srp.act = substr(v-field,6).

					displ srp.act with frame f-srp. pause 0.
				end.

				if v-field begins "//BIC/" then /*БИК участника клиринга*/
				do:
					srp.bank = substr(v-field,7). /*сохраняем БИК*/
					srp.crbank = "clear".  /*и сразу прописываем значени 'clear' - так принято в АБПК*/
					find last bankl where bankl.bank = srp.bank no-lock no-error.
					if avail bankl then
						v-name = bankl.name.
					else
						v-name = "Не определено".
					displ srp.act v-name srp.bank with frame f-srp. pause 0.

				end.

				if v-field begins "//CLRTERM/" then /*Код основного терминала организации в которой обслуживается данный банка*/
					srp.clrtrm = substr(v-field,11).
			end.
		input stream s-body close.
end.
input stream s-file close.
/**********************************************************************************/

/*Собственно изменение справочника в БД АБПК***************************************/
/*ПРИМЕЧАНИЕ: параметр NEW обрабатывать не будем по следующим причинам: данный параметр
подразумевает полную замену справочника, т.е. удаление и загрузка с "нуля". Мы этого делать не
будем, т.к. в нашем справочнике хранятся по мимо данных КЦМР, еще и данные других банков не входящих
в КЦМР, например SWIFT. Поэтому довольствуемся обычным "апдейтом" если банк в справочнике есть, и
созданием новой записи если записи нет - параметр ADD*/


find first bb no-lock no-error. /*проверим, не пустой ли был файл */

if avail bb then
do. /*если не пустой, то "поехали"...*/
	for each bb no-lock:

		displ bb.act bb.name bb.bank with frame f-bankl. pause 0.
		/*Добавление/изменение данных банка*/
		if bb.act = "ADD" then
		do:
				find first bankl where bankl.bank = bb.bank no-error. /*есть ли запись в справочнике?*/
				if not avail bankl then /*если нет, создаем*/
						create bankl.
				bankl.stn = 011. /*гео-код */
				bankl.bank = bb.bank. /*БИК банка*/
				bankl.name = bb.name. /*Название банка*/
				bankl.cbank = bb.cbank. /*БИК головного банка*/
				bankl.sts = bb.sts. /*Статус банка*/
                                bankl.frbno = 'KZ'.
                                bankl.mntrm = bb.mntrm.
				/*Формирование кор.счетов**********************************************************/
				find bankt where bankt.cbank  =  bankl.cbank and bankt.crc    =  1 no-error.
				if not avail bankt then do.
						create bankt.
						bankt.cbank = bankl.cbank.
						bankt.subl = 'dfb'.
					find sysc where sysc.sysc = 'lbnstr' no-lock no-error.
					if not avail sysc then do.
						message "Не определен ностро-счет(lbnstr) в таблице SYSC ".
						pause 5.
						undo.
						return.
					end.
					find dfb where dfb.dfb = trim(sysc.chval) no-lock no-error.
					if not avail dfb then do.
						message "Не найден счет в таблице DFB ".
						pause 5.
						undo.
						return.
					end.
					bankt.acc = dfb.dfb.
					bankt.crc = dfb.crc.
					bankt.vdate = 0.
					bankt.aut = no.  /* признак "корсчет открыт в этом банке" - всегда NO, поскольку корсчет открыт в НБ РК */
					bankt.who = g-ofc.
					bankt.racc = '1'.
					if bankl.cbank = 'clear' then do.
						find sysc where sysc.sysc = 'lbtime' no-lock no-error.
						if not avail sysc then do.
							message "Не определено время окончания клиринга(lbtime) в таблице SYSC ".
							pause 5.
							undo.
							return.
						end.
						bankt.vtime = integer(sysc.chval).
					end.
					else
						bankt.vtime = 86399.
					bankt.whn = today.
				end.
				/**********************************************************************************/
				run savelog(filelog, "Добавлен банк: (БИК) " + bankl.bank + " (НАИМЕНОВАНИЕ) " + bankl.name + " (БИК ГОЛОВНОГО БАНКА) " + bankl.cbank + " (СТАТУС) " + string(bankl.sts)).
		end.
                /*Обновление записи*/
		if bb.act = "UPD" then
		do:
			find first bankl where bankl.bank = trim(bb.bank) no-error. /*есть ли запись*/
			if avail bankl then
			do: /*если есть обновляем*/
				if bb.newbank <> "" then
				do:
					if bankl.bank = bankl.cbank then /*если БИК банка такойже как и БИК головного банка*/
					do: /*обновим и кор.счета*/
						bankl.cbank = bb.newbank.
						for each bankt where bankt.cbank = bankl.bank.
							bankt.cbank = bb.newbank.
						end.
					end.
					run savelog(filelog,"Изменен БИК банка "  + bankl.name + " c " + bankl.bank + " на " + bb.newbank).
					bankl.bank = bb.newbank.
				end.

				if bankl.name <> bb.name then
				do:
					run savelog(filelog,"Изменен Название банка "  + bankl.name + " c БИК`ом " + bankl.bank + " на " + bb.name).
					bankl.name = bb.name. /*Название банка*/
				end.
				if bankl.cbank <> bb.cbank then
				do:
					run savelog(filelog,"Изменен БИК головного банка у банка "  + bankl.name + " c БИК`ом " + bankl.bank + ":" + bankl.cbank + " -> " + bb.cbank).
					bankl.cbank = bb.cbank. /*БИК головного банка*/
				end.
				if bankl.sts <> bb.sts then /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/
				do:
					run savelog(filelog, "Изменен статус банка " + bankl.name + " (" + bankl.bank + ") с " + string(bankl.sts) + " на " + string(bb.sts)).
					bankl.sts = bb.sts.
				end.
			end.
		end.
		/*Удаление записи о банке*/
		if bb.act = "DEL" then
		do:
				find first bankl where bankl.bank = trim(bb.bank)  no-error.
				if avail bankl then do :
					find first bankt where bankt.cbank  =  bankl.cbank and bankt.crc = 1 no-error.
					if avail bankt then
						delete bankt.
					run savelog(filelog, "Удален банк " + bankl.bank + " " + bankl.name + " " + bankl.cbank).
					delete bankl.
				end.
		end.

	end.
end.

/*Изменение участников клиринга****************************************************/
find first srp no-lock no-error. /*были ли изменения*/
if avail srp then
do:
	if srp.act = "NEW" then /*если есть признак NEW, значит полная замена данных*/
	do:
		run savelog(filelog, "Обработка команды NEW - SRPCLIENTS.").
		for each bankl where bankl.crbank = "clear" . /*бежим по всему справочнику и обнуляем соответсвующие поля*/
			Assign 	bankl.crbank = "" /*очищаем признак clear*/.
			if not bankl.acct begins "TXB" then /*если acct начинается с TXB, то мы его не трогаем*/
				bankl.acct = "".
		end.
		run savelog(filelog, "Обработка команды NEW - Завершено.").
	end.
	for each srp where srp.act <> "NEW" no-lock:
		/*Добавление нового участника*/
		if srp.act = "ADD" then
		do:
			find bankl where bankl.bank = srp.bank no-error. /*Ищем его в справочнике*/
			if avail bankl then
			do:

				assign 	bankl.crbank = "clear". /*ставим признак "clear"*/

				if not bankl.acct begins "TXB" then
					bankl.acct = srp.clrtrm. /*Код терминала клиринговой организации, в которой обслуживается данный банк*/
                      		run savelog(filelog, "Добавлен новый SRP - клиент " + bankl.bank + " " + bankl.mntrm + " " + bankl.acct + " " + srp.act).
				displ srp.act bankl.bank bankl.mntrm bankl.acct with frame f-bnksrp. pause 0.

			end.
		end.
		/*удаление участника*/
		if srp.act = "DEL" then
		do:
			find bankl where bankl.bank = srp.bank no-error. /*Ищем запись о банке в справочнике*/
			if avail bankl then
			do: /*обнуляем соответсвующие поля*/
				assign 	bankl.crbank = ""
					bankl.mntrm = "".
				if not bankl.acct begins "TXB" then
					bankl.acct = "".
                      		run savelog(filelog, "Удален SRP - клиент " + bankl.bank + " " + bankl.mntrm + " " + bankl.acct + " " + srp.act).
				displ srp.act bankl.bank bankl.mntrm bankl.acct with frame f-bnksrp. pause 0.
			end.
		end.
	end.
end.
hide all .
/**********************************************************************************/

/*Подготовка к синхронизации с филиалами*******************************************/

def new shared temp-table t-bankl /*таблица для синхронизации справочника банков с филиалами*/
	field bank like bankl.bank
	field acct like bankl.acct
	field name like bankl.name
	field crbank like bankl.crbank
	field addr like bankl.addr
	field mntrm like bankl.mntrm
	field nu like bankl.nu
	field attn like bankl.attn
	field tel like bankl.tel
	field fax like bankl.fax
	field tlx like bankl.tlx
	field bic like bankl.bic
	field fid like bankl.fid
	field stn like bankl.stn
	field frbno like bankl.frbno
	field sts like bankl.sts /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/ .


for each bankl where not bankl.bank begins "TXB" no-lock. /*заполняем таблицу синхронизации*/
		create t-bankl.
			t-bankl.bank   = bankl.bank.
			t-bankl.name   = bankl.name.
			t-bankl.crbank = bankl.crbank.
			t-bankl.mntrm  = bankl.mntrm.
			t-bankl.nu 	 = bankl.nu.
			t-bankl.addr[1] = bankl.addr[1].
			t-bankl.addr[2] = bankl.addr[2].
			t-bankl.addr[3] = bankl.addr[3].
			t-bankl.attn   = bankl.attn.
			t-bankl.tel    = bankl.tel.
			t-bankl.fax    = bankl.fax.
			t-bankl.tlx    = bankl.tlx.
			t-bankl.bic    = bankl.bic.
			t-bankl.stn    = bankl.stn.
			t-bankl.fid    = bankl.fid.
			t-bankl.acct    = bankl.acct.
                        t-bankl.frbno = bankl.frbno.
			t-bankl.sts    = bankl.sts. /*u00121 23.06.2005 ТЗ ї 47 от 08.06.2005*/
end.
/**********************************************************************************/

/*Синхронизация справочника с филиалами********************************************/
{r-branch.i &proc=klinp.p}
/**********************************************************************************/
run savelog(filelog, "==============================Справочник загружен!==============================").
message "Справочник загружен!" view-as alert-box .



