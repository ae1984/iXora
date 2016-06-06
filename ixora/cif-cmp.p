/* cif-cmp.p
 * MODULE
        КЛИЕНТЫ И ИХ СЧЕТА
 * DESCRIPTION
	Формирование списка доверенных лиц клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        18/06/04 dpuchkov-изменил проверку даты регистрации
        10.09.2004 saltanat - Полностью изменила по новому требованию о внесении нескольких упол.лиц.
        17.09.2004 saltanat - Внесла сохранение логина и даты редактировавшего запись.
        04.07.2005 saltanat - Добавила проверку на наличие акцепта клиента. Если есть акцепт, то изменение данных невозможно.
	    19.09.2005 u00121   - Создан архив доверенностей, изменен принцип формирования доверенных лиц
	    26/09/2008 galina - 20-тизначный номер счета
	    30/09/2008 galina - явно указала ширину фреймa fr1
        05/05/2010 galina - добавила дополнительную информацию по доверенному лицу созласно ТЗ 639 от 17/03/2010
        06/05/2010 galina - явно указала ширину фрейма fr
        16/01/2012 evseev - ТЗ-1245. Добавил РНН
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{global.i}
{yes-no.i}
{adres.f}
{chk12_innbin.i}
def var yn as log initial false format "да/нет".
def shared var s-cif like cif.cif.
def var v-aaa like aaa.aaa.
def var v-badd1 as char.
def var v-badd2 as char.
def var v-badd3 as char.
def var id as inte.
def buffer buff_upl for uplcif.

def temp-table waaa
    field aaa as char
    field lgr as char
    field midd as char
index main is primary unique lgr midd aaa.

def temp-table wupl
    field id    as   inte
    field upl   as   inte
    field badd1 as   char
    field badd2 as   char
    field badd3 as   char
	index main is primary unique upl.

/*Проверка признака биометрического контроля, выдает в заголовке надпись
напоминающую менеджеру, что необходимо снять отпечатки пальцев с нового
доверенного лица*******************************************************************/
def var v-biom as char init ''.
find last cif where cif.cif = s-cif no-lock no-error.
if avail cif and cif.biom then
	v-biom = "<<ВНИМАНИЕ!!! БИОМЕТРИЯ>>".
/**********************************************************************************/

/**********************************************************************************/
DEFINE QUERY q1 FOR uplcif.

def browse b1
	query q1
	displ
    		uplcif.dop     label 'Счет' format 'x(20)'
    		uplcif.coregdt label 'Дата рег.' format '99/99/99'
    		uplcif.finday  label 'Дата окон.' format '99/99/99'
    		uplcif.badd[1] label 'ФИО' format 'x(20)'
    		uplcif.badd[2] label 'Пасп/удов N' format 'x(15)'
	with 12 down title ' Доверенное лицо ' + v-biom.
/**********************************************************************************/

/**********************************************************************************/
DEFINE QUERY q2 FOR uplcif. /*запрос архива*/

def browse b2
	query q2
	displ
    		uplcif.dop     label 'Счет' format 'x(20)'
    		uplcif.coregdt label 'Дата рег.' format '99/99/99'
    		uplcif.finday  label 'Дата окон.' format '99/99/99'
    		uplcif.badd[1] label 'ФИО' format 'x(20)'
    		uplcif.badd[2] label 'Пасп/удов N' format 'x(15)'
	with 12 down title 'Архив доверенностей '.
/**********************************************************************************/

DEFINE BUTTON bloo LABEL "LOOK".
DEFINE BUTTON bedt LABEL "Ред.".
DEFINE BUTTON badd LABEL "Добавить".
DEFINE BUTTON barch LABEL "Архив".

DEFINE BUTTON bext LABEL "Выход".
DEFINE BUTTON bext2 LABEL "Выход из архива".

def var v-docnum as char.
def var v-reg as char.
def var v-docdt as date.
def var v-bdt as date.
def var v-bplace as char.
def var v-oldinf as char.
def var v-oldbadd2 as char.
def var v-oldbadd3 as char.

def frame fr
    uplcif.dop     label 'Счет' colon 26 format 'x(20)'      skip
    uplcif.coregdt label 'Дата регистр.доверенности' colon 26 format '99/99/9999' skip
    uplcif.finday  label 'Дата оконч.доверенности' colon 26 format '99/99/9999' skip
    '-----------------------------------------------------------------------------------------' at 5 skip
    uplcif.badd[1] label 'ФИО' colon 26 format 'x(40)' skip
    v-bdt label 'Дата рождения' format "99/99/9999" validate (v-bdt <> ?, 'Введите дату рождения') colon 26 skip
    v-bplace label 'Место рождения' format "x(40)" validate(trim(v-bplace) <> '','Введите место рождения') colon 26 skip
    v-adres label 'Юридический адрес' colon 26 format 'x(60)' skip
    '------------------------------------Документ удостоверяющий личность---------------------' at 5  skip
    uplcif.badd[2] label 'Пасп/удов N' colon 26 format 'x(40)' skip
    uplcif.badd[3] label ' Кем/когда выдан' colon 26 format 'x(40)' skip
    uplcif.rnn label ' ИИН' colon 26 format 'x(12)' validate((chk12_innbin(uplcif.rnn)),'Неправильно введён БИН/ИИН') skip

with frame fr row 3 overlay top-only width 100 side-label col 5 title ' Доверенное лицо '.

def frame fpass
    v-oldinf no-label format "x(40)" colon 16 skip
    v-docnum label 'Номер документа' format "x(20)" colon 16 validate(trim(v-docnum) <> '','Введите номер документа') skip
    v-docdt label 'Когда выдан' format "99/99/9999" colon 16 validate(v-docdt <> ?,'Введите дату выдачи документа') skip
    v-reg label 'Кем выдан' format "x(40)" colon 16 validate(trim(v-reg) <> '','Введите кем выдан документ') skip
with frame fpass row 3 overlay top-only side-label col 5 title 'Документ удостоверяющий личность'.

def frame fr2
     b2 skip
     bext2
     with centered width 90 overlay row 1 top-only.

def frame fr1
     b1 skip
     bloo
     bedt
     badd
     barch
     bext with centered width 90 overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.


ON CHOOSE OF bext2 IN FRAME fr2
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b2.
end.

ON CHOOSE OF bloo IN FRAME fr1 do:
    find current  uplcif no-lock.
    find first  upl where upl.uplid =  uplcif.uplid no-lock no-error.
    if avail upl then do:
        v-docdt = upl.docdt.
        v-bdt = upl.bdt.
        v-bplace = upl.bplace.
        v-adres = upl.uradr.

    end.

    displ uplcif.dop uplcif.coregdt  uplcif.finday  uplcif.badd[1] uplcif.badd[2] uplcif.badd[3] uplcif.rnn v-bdt v-bplace v-adres with frame fr.
end.


on help of uplcif.dop in frame fr do:
    run choise_aaa.
    if v-aaa <> '' then
        uplcif.dop = v-aaa.
    displ uplcif.dop with frame fr.
end.

on "end-error" of frame fr2 do:
    open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.

/*Редактирование доверенного лица****************************************************************************************************/
ON CHOOSE OF bedt IN FRAME fr1
do:
	find cif where cif.cif = s-cif no-lock no-error.
	if not avail cif then
	do:
		message 'Клиент не найден!' view-as alert-box buttons ok.
		return.
	end.

	if cif.crg ne "" then
	do:
   		message 'Клиент акцептован. Для редактирования снимите акцепт!' view-as alert-box buttons ok.
   		return.
	end.

    on help of uplcif.badd[1] in frame fr do:
        message "Нельзя сменить доверенное лицо!" skip "Вы можете изменить только данные текущего доверенного лица." skip "Регистрация новой доверенности через <Добавить>" view-as alert-box.
    end.


	find current uplcif exclusive-lock.
    find first upl where upl.uplid = uplcif.uplid no-lock no-error.
    if avail upl then do:
        v-docdt = upl.docdt.
        v-bdt = upl.bdt.
        v-bplace = upl.bplace.
        v-adres = upl.uradr.
        v-reg = upl.docreg.
        v-docnum = upl.dok1.
    end.

    display v-adres uplcif.badd[2] uplcif.badd[3] with frame fr.
    update uplcif.dop uplcif.coregdt uplcif.finday uplcif.badd[1] v-bdt v-bplace with frame fr.

    v-oldinf = uplcif.badd[2] + ' ' + uplcif.badd[3].

    v-title = "Юридический адрес".
    {adres.i
    &hide = "hide frame fur no-pause."}
    display v-adres with frame fr.
    pause 2.

    display v-oldinf with frame fpass.
    update v-docnum v-docdt v-reg with frame fpass.
    update uplcif.rnn with frame fr.
    uplcif.badd[2] = v-docnum.
    uplcif.badd[3] = v-reg + ' ' + string(v-docdt,'99/99/9999').
    display uplcif.badd[2] uplcif.badd[3] with frame fr.

	find last upl where upl.uplid = uplcif.uplid no-error. /*найдем редактируемое лицо в справочнике доверенных лиц*/
	if avail upl then
	do: /*обновим данные доверенного лица*/
		upl.fio = uplcif.badd[1].
		upl.dok1 = uplcif.badd[2].
		upl.dok2 = uplcif.badd[3].
        upl.docdt = v-docdt.
        upl.bdt = v-bdt.
        upl.bplace = v-bplace.
        upl.uradr = v-adres.
        upl.docreg = v-reg.
        upl.rnn = uplcif.rnn.
	end.
	else
	do: /*если по каким-либо причинам запись о доверенном лице отсутствует, создаем ее*/
		create upl.
			upl.uplid = next-value(uplid).
			upl.fio = uplcif.badd[1].
			upl.dok1 = uplcif.badd[2].
			upl.dok2 = uplcif.badd[3].
			upl.cif = uplcif.cif.
     		uplcif.uplid = upl.uplid.
            upl.docdt = v-docdt.
            upl.bdt = v-bdt.
            upl.bplace = v-bplace.
            upl.uradr = v-adres.
            upl.rnn = uplcif.rnn.
	end.

    	uplcif.who = g-ofc.
    	uplcif.whn = g-today.
    	uplcif.tim = time.

	find current uplcif no-lock.
	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
end.
/************************************************************************************************************************************/


/*Добавление доверенного лица********************************************************************************************************/
ON CHOOSE OF badd IN FRAME fr1
do:
    on help of uplcif.badd[1] in frame fr
	do:
  		id = 0.
  		run choise_upl.
  		if v-badd1 <> '' then uplcif.badd[1] = v-badd1.
		if v-badd2 <> '' then uplcif.badd[2] = v-badd2.
		if v-badd3 <> '' then uplcif.badd[3] = v-badd3.
		displ uplcif.badd[1] uplcif.badd[2] uplcif.badd[3] v-bdt v-bplace v-adres with frame fr.
	end.

	find cif where cif.cif = s-cif no-lock no-error.
	if not avail cif then
	do:
		message 'Клиент не найден!' view-as alert-box buttons ok.
		return.
	end.

	if cif.crg ne "" then
	do:
		message 'Клиент акцептован. Для редактирования снимите акцепт!' view-as alert-box buttons ok.
		return.
	end.

	create uplcif.
	assign uplcif.upl = next-value(uplseq)
	       uplcif.cif = s-cif
	       uplcif.who = g-ofc
	       uplcif.whn = g-today
	       uplcif.tim = time.

    v-adres = ''.
    v-bdt = ?.
    v-bplace = ''.
    v-reg = ''.
    v-docnum = ''.
    display v-adres v-bdt v-bplace uplcif.badd[1] uplcif.badd[2] uplcif.badd[3] with frame fr.

    update uplcif.dop uplcif.coregdt uplcif.finday uplcif.badd[1] v-bdt v-bplace with frame fr.

    v-oldinf = uplcif.badd[2] + ' ' + uplcif.badd[3].
    v-oldbadd2 = uplcif.badd[2].
    v-oldbadd3 = uplcif.badd[3].

    v-title = "Юридический адрес".
    {adres.i
    &hide = "hide frame fur no-pause."}
    display v-adres with frame fr.
    pause 2.

    display v-oldinf with frame fpass.
    update v-docnum v-docdt v-reg with frame fpass.
    update uplcif.rnn with frame fr.
    uplcif.badd[2] = v-docnum.
    uplcif.badd[3] = v-reg + ' ' + string(v-docdt,'99/99/9999').
    display uplcif.badd[2] uplcif.badd[3] with frame fr.

    /*проверим, не новое ли доверенное лицо регистрируется?*/
	find last upl where (upl.fio = uplcif.badd[1]) and (upl.dok1 = v-oldbadd2) and (upl.dok2 = v-oldbadd3) no-error.
	if not avail upl then
	do: /*если ранее доверенное лицо с такими данными зарегистрированно не было, то регистрируем его*/
		create upl.
			upl.uplid = next-value(uplid).
			upl.fio = uplcif.badd[1].
			upl.dok1 = uplcif.badd[2].
			upl.dok2 = uplcif.badd[3].
			upl.cif = uplcif.cif.
            upl.docdt = v-docdt.
            upl.bdt = v-bdt.
            upl.bplace = v-bplace.
            upl.uradr = v-adres.
            upl.docreg = v-reg.
            upl.rnn = uplcif.rnn.
	end.
	uplcif.uplid = upl.uplid.
	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
end.
/************************************************************************************************************************************/

/*Архив действоваших доверенностей***************************************************************************************************/
ON CHOOSE OF barch IN FRAME fr1
do:

	find cif where cif.cif = s-cif no-lock no-error.
	if not avail cif then
	do:
   		message 'Клиент не найден!' view-as alert-box buttons ok.
   		return.
	end.

	open query q2 for each uplcif where uplcif.cif = s-cif and uplcif.finday < g-today.
	enable all with frame fr2.

	WAIT-FOR choose of bext2.
	open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.
	ENABLE all with frame fr1 centered overlay top-only.
end.
/************************************************************************************************************************************/


open query q1 for each uplcif where uplcif.cif = s-cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today.


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.



hide frame fr1.


/*Выбор действующих счетов клиента***************************************************************************************************/
procedure choise_aaa.
	for each waaa.
		delete waaa.
	end.
	v-aaa = ''.
	for each aaa where aaa.cif = s-cif no-lock break by aaa.aaa:
		find lgr where lgr.lgr = aaa.lgr no-lock.
		if lgr.led = 'ODA' then next.
		if aaa.sta <> "c" then
		do:
			create waaa.
				waaa.aaa = aaa.aaa.
				waaa.lgr = aaa.lgr.
				waaa.midd = substr(aaa.aaa, 4, 3).
		end.
	end.
	find first waaa no-error.
	if not avail waaa then
	do:
		message skip " У клиента нет действующих счетов ! " skip(1) view-as alert-box button ok title "".
   		return.
	end.
   {itemlist.i
    &file = "waaa"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " waaa.aaa format 'x(20)' label 'Счет'
                 waaa.lgr label 'Группа счета'
                 waaa.midd label 'Статус'
               "
    &chkey = "aaa"
    &chtype = "string"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
	v-aaa = waaa.aaa.
end procedure.
/************************************************************************************************************************************/

/************************************************************************************************************************************/
procedure choise_upl.

	v-badd1 = ''. v-badd2 = ''. v-badd3 = ''.

	find first upl where upl.cif = s-cif no-error.
	if not avail upl then
	do:
		   message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as alert-box button ok title "".
		   return.
	end.
   {itemlist.i
    &file = "upl"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = "  upl.cif = s-cif  "
    &flddisp = " upl.uplid    label 'N' format '>>>9'
                 upl.fio label 'Ф.И.О.' format 'x(20)'
                 upl.dok1 label 'Паспорт.данные' format 'x(20)'
                 upl.dok2 label 'Кем/Когда выдан'format 'x(20)'
               "
    &chkey = "uplid"
    &chtype = "integer"
    &index  = "upl-idx"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
	  v-badd1 = upl.fio.
	  v-badd2 = upl.dok1.
	  v-badd3 = upl.dok2.
      v-docdt = upl.docdt.
      v-bdt = upl.bdt.
      v-bplace = upl.bplace.
      v-adres = upl.uradr.
      v-reg = upl.docreg.
      v-docnum = upl.dok1.
end procedure.
/************************************************************************************************************************************/
