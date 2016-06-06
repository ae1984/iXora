/* copysec3.p
 * MODULE
        Администрирование АБПК
 * DESCRIPTION
        Лишение прав пользователя
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
        28.06.2005 u00121 переделал из copysec3.p для автоматического лишения прав
	15.03.2006 u00121 добавил avail для ofc перед удалением прав, добавил опцию no-undo в локальные переменные
 * BASE
        TXB
*/


{yes-no.i}

def INPUT PARAM ofrom as char init "".
def var v-str as char no-undo.
def var i as integer no-undo.
def var v-propath as char no-undo.

find last txb.cmp no-lock.
find last txb.ofc where txb.ofc.ofc = ofrom no-error.
if avail txb.ofc then
do:
	message "Удаление прав доступа к пакетам..." + trim(ofrom) + " " + txb.cmp.name. pause 1.
	txb.ofc.expr[1] = "".

	v-propath = propath. /*так как нам будут мешаться тригеры ниже используемой таблицы, перенаправим путь к библиотеке в каталог в котором лежат эти тригеры откомпиленые под логическое имя txb*/
	propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.
	message "Удаление прав доступа к пунктам меню..." + trim(ofrom) + " " + txb.cmp.name. pause 1.
	for each txb.sec where txb.sec.ofc = ofrom:
		delete txb.sec.
	end.

	hide message no-pause.
	propath = v-propath no-error.

	message "Удаление прав доступа к шаблонам..." + trim(ofrom) + " " + txb.cmp.name. pause 1.
	for each txb.ujosec where lookup(ofrom, txb.ujosec.officers) > 0 exclusive-lock:
		v-str = "".
		do i = 1 to num-entries(txb.ujosec.officers):
			if entry(i, txb.ujosec.officers) <> "" and entry(i, txb.ujosec.officers) <> ofrom then 
			do:
				v-str = v-str + entry(i, txb.ujosec.officers) + ",".
			end.
		end.
		txb.ujosec.officers = v-str.
	end.
	release txb.ujosec.
	hide message no-pause.

	message "Удаление прав доступа к платежной системе..." + trim(ofrom) + " " + txb.cmp.name. pause 1.
	for each txb.pssec where lookup(ofrom, txb.pssec.ofcs) > 0 exclusive-lock:
		v-str = "".
		do i = 1 to num-entries(txb.pssec.ofcs):
			if entry(i, txb.pssec.ofcs) <> "" and entry(i, txb.pssec.ofcs) <> ofrom then 
			do:
				v-str = v-str + entry(i, txb.pssec.ofcs) + ",".
			end.
		end.
		txb.pssec.ofcs = v-str.
	end.
	release txb.pssec.
	hide message no-pause.

	message "Удаление прав доступа к пунктам верхнего меню..." + trim(ofrom) + " " + txb.cmp.name. pause 1.
	for each txb.optitsec where lookup(ofrom, txb.optitsec.ofcs) > 0 exclusive-lock:
		v-str = "".
		do i = 1 to num-entries(txb.optitsec.ofcs):
			if entry(i, txb.optitsec.ofcs) <> "" and entry(i, txb.optitsec.ofcs) <> ofrom then 
			do:
				v-str = v-str + entry(i, txb.optitsec.ofcs) + ",".
			end.
		end.
		txb.optitsec.ofcs = v-str.
	end.
	release txb.optitsec.
	hide message no-pause.
end.
else
		message  trim(ofrom) + " " + txb.cmp.name + " - не зарегистрирован...". pause 1.

