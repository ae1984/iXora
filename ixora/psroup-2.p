 /* psroup-2.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Регистрация исход платежей в тенге (P)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        out_P_ps
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        23.09.2003 nadejda  - проверка введенной суммы комиссии с учетом минимальной и максимальной суммы
        26.09.2003 nadejda  - добавлено определение комиссии по умолчанию для внешних валютных платежей и проверка при вводе кода комиссии
        04.12.2003 sasco    - 1) отмена редактирования Кредитовых сумм и валюты;
                              2) нельзя редактировать Г/К комиссии
                              3) ограничение на код валюты в 5.3.1 / 5.3.3 (только валюта / тенге)
                              4) проверка на соотв. CIF клиента отправителя и комиссии
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       19.04.2004 tsoy Добавлен конторль на сумму для ф. лиц где сумма больше 10000 $
       16.09.2004 dpuchkov ограничение на просмотр реквизитов клиентов
       20.09.2004 dpuchkov перекомпиляция
       08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
       10.05.2005 suchkov - закоментировал проставление транспорта 3
       07.06.2005 tsoy    - добавил приоритет
       14.06.2005 tsoy    - приоритет только для теньговых платежей
       05.10.2005 rundoll - если платеж срочный то транспорт 2
       06.05.2006 dpuchkov - добавил параметр для сбора и выгрузки данных в АИС Статистика ТЗ 298.
       26.05.2006 nataly - добавила обработку счета TSF
	30.05.2006 u00121 - формирование проводок по кассе в пути для тех департаментов, которые работают только через кассу в пути
	02.06.2006 u00121 - временно блокировал работу get100200arp
       22/06/2006 nataly  - закомментировала тип 2
       27/11/2006 u00600 - по ТЗ ї 225 - if v-pnp begins '000941' (дебиторы)
        17.11.09 marinav счет as cha format "x(20)"
формат v-pnp
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        09.02.2011 Luiza  -  добавила режим поиска клиента в on help .....
        11/05/2011 madiyar - изменения по ТЗ № 856
        20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
        13/09/2011 dmitriy - при коде комиссии 302, исключил возможность проставления суммы комиссии
*/

{global.i}
def var v-chksts 	as integer no-undo.
def var l-ans    	as logical no-undo.
def var v-val 		as integer no-undo.

/*u00121 10/04/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/

def buffer acrc for crc.
def buffer bcrc for crc.
def buffer ccrc for crc.
def buffer dcrc for crc.
def buffer zcrc for crc.

def shared var s-remtrz like remtrz.remtrz.
def shared var v-ref as cha format "x(10)".
def shared var v-pnp as cha format "x(20)".
def shared frame remtrz.
def shared var v-comgl as inte.
def shared var v-regnom as char format "x(12)".

def var acode 	like crc.code 	no-undo.
def var bcode 	like crc.code 	no-undo.
def var ccode 	like crc.code 	no-undo.
def var s-bank	like bankl.bank no-undo.


def var prilist like sysc.chval no-undo.
def var amt1 	like remtrz.amt no-undo.
def var amt2 	like remtrz.amt no-undo.
def var amt3 	like rem.amt 	no-undo.
def var amtp 	like rem.amt 	no-undo.

def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer d-aaa for aaa.
def buffer d-cif for cif.
def buffer xaaa  for aaa.

def var v-sumkom like remtrz.svca no-undo.
def var bila like aaa.cbal label "ОСТАТОК" 	no-undo.
def var com1 like rem.amt 			no-undo.
def var com2 like rem.amt			no-undo.
def var com3 like rem.amt 			no-undo.
def var br 	as int format "9" 	no-undo.
def var sr 	as int format "9" 	no-undo.
def var ii 	as inte initial 1	no-undo.
def var pakal  	as char 		no-undo.
def var v-uslug	as char format "x(10)" no-undo.
def var ee1 like tarif2.num no-undo.
def var ee2 like tarif2.kod no-undo.
def var v-numurs as char format "x(10)" no-undo.
def shared var v-reg5 as char format "x(12)".
def shared var v-bin5 as char format "x(12)".
def new shared var ee5 as char format "x".
def new shared var s-aaa like aaa.aaa.
def var i6 as int no-undo.
def var tt1 as char format "x(60)" no-undo.
def var tt2 as char format "x(60)" no-undo.
def shared var v-chg as integer.
def var ourbank like bankl.bank no-undo.
def var sender as cha no-undo.
def var v-cashgl like gl.gl no-undo.
def var v-priory as cha format "x(8)" 	no-undo.
def var v-rnn as log no-undo.

def var s-cif as char no-undo.
def var s-rnn as char no-undo.

def var v-kod as char.
/*---------------------------------------------------------------------------------------------------------*/
def var v-grp like debgrp.grp  label "Группа дебитора ".
def var v-ls like debls.ls no-undo.

def var v-d1 as date no-undo. def var v-d2 as date no-undo.
def var v-Gk as integer format "zzzzz9" no-undo.  def var v-KR as char format "x(8)" no-undo.
def var v-dep as char no-undo. def var v-np as char format "x(45)" no-undo.
def var v-acc like jl.acc no-undo.

def var v-amt as decimal init 0 no-undo.
def var v-period as integer init 0 no-undo.
v-d1 = g-today.  /*date(integer(01),integer(01),year(g-today)).*/

find first debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
if avail debls then do: v-Gk = debls.gl. v-KR = debls.code-R. v-dep = debls.code-dep. v-np = debls.np . end.

define button dbut1 label "OK".
define button dbut2 label "Отмена".
define frame GK
    v-grp label "Группа деб" validate (v-grp ne 0, "Введите группу дебитора! ")
    v-d1 format "99/99/9999" label "Период услуг с "  v-d2 format "99/99/9999" label "по "  validate (v-d2 >= v-d1, " Дата не может быть меньше " + string (v-d1))
    v-Gk label "счет ГК"  validate (can-find (gl where gl.gl = v-GK and gl.gl <> 0), "Не найден счет ГК!")
    v-KR label "код расходов"  /*validate (can-find (cods where cods.code = v-KR and cods.gl = v-gk  and cods.arc = no no-lock) or v-kr = ?, "Не найден код расходов!")*/
    v-dep label "код департамента" v-np label "назнач.платежа"
    skip
    dbut1 dbut2
    with row 6 centered side-labels overlay.

on "return" of v-grp in frame gk do:
    v-grp = integer(v-grp:screen-value).
    run trx-debcheck (input v-grp, output v-ls).
    if v-ls = ? or v-ls = 0 or not (can-find (debls where debls.grp = v-grp and debls.ls = v-ls)) then do:
        message "Ошибка! Не выбран дебитор." view-as alert-box buttons ok.
        undo,retry.
    end.
end.

on help of v-gk in frame gk do:
    {itemlist.i
       &file = "gl"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " gl.gl /*label 'КОД' format 'x(3)'*/
                    gl.des /*t-ln.name label 'НАЗВАНИЕ' format 'x(70)'*/
                    gl.subled
                    gl.level format 'z9'
                   "
       &chkey = "gl"
       &chtype = "integer"
       &index  = "gl"
       &end = "if keyfunction(lastkey) = 'end-error' then return."
    }

    v-gk = gl.gl.
    displ v-gk with frame gk.
end.

on help of v-kr in frame gk do:
    run help-code (v-gk:screen-value,v-acc).
    v-kr:screen-value = return-value.
    v-kr = v-kr:screen-value.
end.

on help of v-dep in frame GK do:
    run help-dep("000").
    v-dep:screen-value = return-value.
    v-dep = return-value.
end.

on help of v-grp in frame gk do:
    run help-debgrp (false).
end.

on choose of dbut1 in frame GK do:
    /*создать таблицу куда занесем все данные для последующего списания*/
    v-d1 = date(v-d1:screen-value). v-d2 = date(v-d2:screen-value). v-Gk = integer(v-Gk:screen-value).
    v-KR = string(v-KR:screen-value).

    v-period = (v-d2 - v-d1) / 30. v-amt = remtrz.amt / v-period.

    find first debujo where debujo.remtrz = remtrz.remtrz no-lock no-error.
    if not avail debujo then do:
        create debujo.
        assign debujo.grp      = v-grp
            debujo.ls       = v-ls
            debujo.remtrz   = remtrz.remtrz
            debujo.amt      = remtrz.amt
            debujo.amt-m    = v-amt
            debujo.crc      = remtrz.fcrc
            debujo.gl       = v-Gk
            debujo.arp      = v-pnp
            debujo.period   = v-period
            debujo.dat1     = v-d1
            debujo.dat2     = v-d2
            debujo.code-R   = v-KR
            debujo.code-dep = v-dep
            debujo.np       = v-np.
        release debujo.
    end. /*if not avail debujo */
    apply "go" to frame gk.
end.

/* отменить и выйти из редактирования */
on choose of dbut2 in frame GK do:
    apply "go" to frame gk.
end.
/*---------------------------------------------------------------------------------------------------------*/

{lgps.i}

/* для использования BIN */
{chk12_innbin.i}
{chbin.i}

{psror-2.f}

{comchk.i}

/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE VARIABLE v-cif1 AS char.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.

on help of v-pnp in frame remtrz do:
    if remtrz.outcode = 3 then do:
        hide frame f-help.
        v-cif1 = "".
        run h-cif PERSISTENT SET phand.
        hide frame xf.
        v-cif1 = frame-value.
        if trim(v-cif1) <> "" then do:
            if m_pid = "P" then find first aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = 1  and length(aaa.aaa) >= 20 no-lock no-error.
            if m_pid <> "P" then find first aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc <> 1  and length(aaa.aaa) >= 20 no-lock no-error.
            if available aaa then do:
                if m_pid = "P" then OPEN QUERY  q-help FOR EACH aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock,
                                each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
                if m_pid <> "P" then OPEN QUERY  q-help FOR EACH aaa where aaa.cif = v-cif1 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc <> 1 and length(aaa.aaa) >= 20 no-lock,
                                each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
                ENABLE ALL WITH FRAME f-help.
                wait-for return of frame f-help
                FOCUS b-help IN FRAME f-help.
                v-pnp = aaa.aaa.
                hide frame f-help.
            end.
            else do:
                v-pnp = "".
                message "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            end.
            displ  v-pnp with frame remtrz.
        end.
        DELETE PROCEDURE phand.
    end.
end.
/*  help for cif */


def temp-table vgl no-undo
    field vgl as inte.

def var vgldes as char no-undo.


ee5 = "2" .

find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	display " Запись OURBNK отсутствует в файле sysc !!".
	pause.
	undo.
	return.
end.
ourbank = sysc.chval.

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
if not avail sysc then do:
	message " Запись RMCASH отсутствует в файле sysc. " .
	return.
end.
v-cashgl = sysc.inval .

find last sysc where sysc.sysc = "rmsvco" no-lock.
repeat:
	if entry(ii,sysc.chval) = "" then leave.
	create vgl.
    vgl.vgl = integer(entry(ii,sysc.chval)).
    ii = ii + 1.
end.


find last sysc where sysc.sysc = "REMBUY" no-lock no-error.
br = sysc.inval.
find last sysc where sysc.sysc = "REMSEL" no-lock no-error.
sr = sysc.inval.

find last sysc where sysc.sysc = 'PRI_PS' no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
	display ' Запись PRI_PS отсутствует в файле sysc !! '.
	pause. undo. return.
end.
else prilist = sysc.chval.


do transaction:

	find last remtrz where remtrz.remtrz = s-remtrz exclusive-lock.

	if remtrz.svcaaa ne "" then v-chg = 3.
	else if remtrz.svcgl <> 0 then v-chg = 1.
	display v-chg with frame remtrz. pause 0.
	if remtrz.jh1 <> ? then return.
	display remtrz.remtrz with frame remtrz.
	pause 0.
	find dcrc where dcrc.crc = 1 no-lock.

	if remtrz.rdt = ? then remtrz.rdt = g-today.

	find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error.
	if avail tarif2 then pakal = tarif2.pakalp.
	display pakal with frame remtrz .
	pause 0 .
	do on error undo,retry:
		v-ref = substr(remtrz.sqn,19).
		update v-ref validate (v-ref ne "" ,"Введите номер платежного поручения!") with frame remtrz.
		remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + v-ref.

		/* 07.06.2005 tsoy */

		find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
		if not avail sub-cod then v-priory = 'o'.
		else v-priory = sub-cod.ccode.

		displ v-priory with frame remtrz.

		if m_pid = "P" then do:
			update v-priory with frame remtrz.

			find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" exclusive-lock no-error.
			if not avail sub-cod then do:
				create sub-cod.
				assign
					sub-cod.acc = remtrz.remtrz
					sub-cod.sub = 'rmz'
					sub-cod.d-cod = "urgency"
					sub-cod.ccode = v-priory.
			end.
			else sub-cod.ccode = v-priory.

			release sub-cod.
		end.

		if v-priory = "s" then remtrz.cover = 2.
		else remtrz.cover = 1.
		display remtrz.cover remtrz.rdt with frame remtrz.
	end.

MM:

	do on error undo,retry:
		if m_pid <> 'P' then update remtrz.fcrc validate(can-find(crc where crc.crc = remtrz.fcrc) and ((remtrz.fcrc = 1 and m_pid = "P") or (remtrz.fcrc <> 1 and m_pid <> "P")), "") with frame remtrz.
        else display remtrz.fcrc with frame remtrz.

		find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0 no-lock no-error.
		if not available acrc  then do:
			message "Статус валюты <> 0 ".
			undo, retry.
		end.

		acode = acrc.code.
		disp acode with frame remtrz.

		update remtrz.amt validate( remtrz.amt > 0 ,"") with frame remtrz.
		remtrz.info[6] = replace(remtrz.info[6],"payment","amt").
		if not remtrz.info[6] matches  "*amt*" then remtrz.info[6] = remtrz.info[6] + " amt".
		remtrz.amt = round ( remtrz.amt , acrc.decpnt ) .
		display remtrz.amt with frame remtrz.
		remtrz.payment = remtrz.amt.
		remtrz.tcrc = remtrz.fcrc.

		displ remtrz.tcrc with frame remtrz.

		find crc where crc.crc = remtrz.tcrc and crc.sts = 0 no-lock no-error.
		disp crc.code with frame remtrz.
		find ccrc where ccrc.crc = remtrz.tcrc no-lock.   /* new */
		remtrz.margb = 0. remtrz.margs = 0.

		find acrc where acrc.crc = remtrz.fcrc no-lock. /* new */
		find ccrc where ccrc.crc = remtrz.tcrc no-lock. /* new */
		find crc where crc.crc = remtrz.tcrc no-lock. /* new */

		if remtrz.fcrc = remtrz.tcrc then remtrz.payment = remtrz.amt.
		else do:
			if acrc.rate[br] = 0 then do:
				message "Банк не покупает " acrc.code.
				undo, retry MM.
			end.
			if ccrc.rate[sr] = 0 then do:
				message "Банк не продает " ccrc.code.
				undo, retry MM.
			end.

			remtrz.margb = round(remtrz.amt * acrc.rate[1] / acrc.rate[9] - remtrz.amt * acrc.rate[br] / acrc.rate[9] ,dcrc.decpnt).

			remtrz.margs = round((remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[1] - remtrz.amt * acrc.rate[br] / acrc.rate[9] / ccrc.rate[sr] ) * ccrc.rate[1] , dcrc.decpnt).

			if remtrz.payment = 0 then remtrz.payment = round( remtrz.amt * acrc.rate[br] / acrc.rate[9] * ccrc.rate[9] / ccrc.rate[sr] , crc.decpnt ).
		end.
		disp remtrz.payment with frame remtrz.
	end. /* do on error undo,retry */

	do on error undo,retry:
		{mesg.i 10000}.
		update remtrz.outcode with frame remtrz.

		if remtrz.outcode < 1 or ( remtrz.outcode > 7 and m_pid = 'O' ) or ( remtrz.outcode > 8 and m_pid = 'P' ) /*or remtrz.outcode = 2*/ then do:
			bell.
			undo, retry.
		end.

		if remtrz.outcode = 1 then do:
			v-yn = false.
			if not v-yn then do: /*если разрешено работать через кассу, то работатем по старому*/
				find sysc where sysc.sysc = "RMCASH" no-lock no-error.
				if not available sysc then do:
					message "Проверьте установку  RMCASH в файле sysc!".
					undo.
				end.
				find gl where gl.gl = sysc.inval no-lock no-error.
				if not available gl then do:
					message "Проверьте установку  RMCASH в файле sysc!".
					undo.
				end.
				remtrz.drgl = gl.gl.
				remtrz.dracc = ''.
				remtrz.sacc = ''.
			end.
			else do:
				remtrz.drgl = 100200.
				remtrz.dracc = v-arp.
				remtrz.sacc = v-arp.
			end.
			v-pnp = ''.
			if remtrz.outcode entered then do:
				v-reg5 = ''. v-bin5 = ''. remtrz.ord = '' .
			end.
			if index(remtrz.ord,"/RNN/") <> 0 then do:
				if v-bin = no then v-reg5 = substr(remtrz.ord,index(remtrz.ord,"/RNN/") + 5).
                else v-bin5 = substr(remtrz.ord,index(remtrz.ord,"/RNN/") + 5).
				remtrz.ord = substr(remtrz.ord,1,index(remtrz.ord,"/RNN/") - 1).
                if remtrz.ord = ? then do:
                  run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 475", "1", "", "").
                end.
			end.

			display v-pnp remtrz.ord /*v-reg5*/ v-bin5 with frame remtrz.
			{updtord-533.i}
			do on error undo,retry :
				update v-bin5 validate((chk12_innbin(v-bin5)) , "Не верный ИИН/БИН !")  with frame remtrz.
			end.

			remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-bin5).
            if remtrz.ord = ? then do:
               run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 491", "1", "", "").
            end.
			{vccheckp.i}.
		end. /* if remtrz.outcode = 1 */

		if remtrz.outcode = 4 then do on error undo, retry:
            update v-pnp with frame remtrz.
            find dfb where dfb.dfb = v-pnp no-lock no-error. /* new */
            if not available dfb then do:
                bell.
                {mesg.i 8916}.
                undo, retry.
            end.
            else
            if dfb.crc <> remtrz.fcrc then do:
                bell.
                {mesg.i 9813}.
                undo,retry.
            end.
            else do:
                remtrz.dracc = v-pnp.
                remtrz.sacc = v-pnp.
                remtrz.drgl = dfb.gl.
                v-reg5 = "".
                v-bin5 = "".
                remtrz.ord = "" .
            end.
            disp remtrz.ord v-bin5 with frame remtrz.
            pause 0.
		end.
		else
        if remtrz.outcode = 3 then do:
            v-pnp = remtrz.dracc.
            if index(remtrz.sacc,"/") <> 0 then v-pnp = substr(remtrz.sacc,1,index(remtrz.sacc,"/") - 1).
            else v-pnp = remtrz.sacc.
            update v-pnp with frame remtrz.

            /******************************/
            find last aaa where aaa.aaa = v-pnp no-lock no-error.
            if avail aaa then do:
                find last cif where cif.cif = aaa.cif no-lock no-error.
                find last cifsec where cifsec.cif = cif.cif no-lock no-error.
                if avail cifsec then do:
                    find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
                    if not avail cifsec then do:
                        create ciflog.
                        assign
                            ciflog.ofc = g-ofc
                            ciflog.jdt = today
                            ciflog.cif = cif.cif
                            ciflog.sectime = time
                            ciflog.menu = "Регистрация исходящих платежей".
                        release ciflog.
                        message "Клиент не Вашего Департамента." view-as alert-box buttons ok.
                        undo,retry.
                    end.
                    else do:
                        create ciflogu.
                        assign
                            ciflogu.ofc = g-ofc
                            ciflogu.jdt = today
                            ciflogu.sectime = time
                            ciflogu.cif = cif.cif
                            ciflogu.menu = "Регистрация исходящих платежей".
                        release ciflogu.
                    end.
                end.
            end.
            /******************************/

            find aaa where aaa.aaa = v-pnp no-lock no-error. /* new */
            if avail aaa then find first lgr where lgr.lgr = aaa.lgr and lgr.led <> "ODA" no-lock no-error.
            if not available aaa then do:
                bell.
                {mesg.i 2203}.
                undo,retry.
            end.
            else
            if avail lgr and lgr.led = "ODA" then do:
                message " Счет типа ODA   ".
                pause.
                undo,retry.
            end.
            else do:
                remtrz.dracc = v-pnp.
                remtrz.sacc = v-pnp.
                remtrz.drgl = aaa.gl.
            end.
            s-aaa = v-pnp.
            run aaa-aas.
            find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
            if available aas then do: pause. undo,retry. end.
            if aaa.crc <> remtrz.fcrc then do:
                bell.
                {mesg.i 9813}.
                undo,retry.
            end.
            if aaa.sta = "C" then do:
                bell.
                {mesg.i 6207}.
                undo,retry.
            end.
            find cif of aaa no-lock no-error.
            tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
            tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
            remtrz.ord = trim(tt1) + ' ' + trim(tt2).
            if remtrz.ord = ? then do:
               run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 597", "1", "", "").
            end.
			/*BIN*/
            if v-bin = no then do:
                v-reg5 = trim(substr(cif.jss,1,13)).
                disp /*v-reg5*/ remtrz.ord  with frame remtrz.
                pause 0.
                form bila
                    tt1 label "ПОЛНОЕ-----"
                    tt2 label "--НАЗВАНИЕ "
                    cif.lname  label "СОКРАЩЕННОЕ" format "x(60)"
                    cif.pss   label "ИДЕНТ.КАРТА"
                    cif.jss   label "РЕГ.НОМЕР "  format "x(13)"
                    with overlay  1 column row 13 column 1 frame ggg.
                if aaa.craccnt <> "" then
                    find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error.
                if available xaaa then do:
                    bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
                        - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
                        - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
                    disp bila tt1 tt2  cif.lname cif.pss cif.jss with frame ggg.
                    pause.
                end.
                else do:
                    bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
                    disp bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
                    pause.
                end.
                {updtord-533.i}
                do on error undo,retry:
                    /*update v-reg5 validate(length(v-reg5) eq 12 , "Введите 12 цифр РНН !") with frame remtrz.*/
                    run rnnchk( input v-reg5,output v-rnn).
                    if v-rnn then do:
                        message "Введите РНН верно!". pause. undo, retry.
                    end.
                end.
                remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
                if remtrz.ord = ? then do:
                  run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 635", "1", "", "").
                end.
            end.
            else do:
                v-bin5 = trim(substr(cif.bin,1,13)).
                disp v-bin5 remtrz.ord with frame remtrz.
                pause 0.
                form bila
                    tt1 label "ПОЛНОЕ-----"
                    tt2 label "--НАЗВАНИЕ "
                    cif.lname  label "СОКРАЩЕННОЕ" format "x(60)"
                    cif.pss   label "ИДЕНТ.КАРТА"
                    cif.bin   label "ИИН/БИН   "  format "x(13)"
                    with overlay  1 column row 13 column 1 frame ggg1.
                if aaa.craccnt <> "" then
                    find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error.
                if available xaaa then do:
                    bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
                        - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
                        - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
                    disp bila tt1 tt2  cif.lname cif.pss cif.bin with frame ggg1.
                    pause.
                end.
                else do:
                    bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal.
                    disp bila tt1 tt2 cif.lname cif.pss cif.bin with frame ggg1.
                    pause .
                end.
                {updtord-533.i}
                do on error undo,retry:
                    update v-bin5 validate((chk12_innbin(v-bin5)),'Неправильно введён БИН/ИИН') with frame remtrz.
                end.
                remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-bin5).
                if remtrz.ord = ? then do:
                  run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 669", "1", "", "").
                end.
            end.

            remtrz.sacc = v-pnp .
            {vccheckp.i}.
        end.
        else
        if remtrz.outcode = 6 then do:
            update v-pnp with frame remtrz.
            find arp where arp.arp = v-pnp no-lock no-error.
            if not available arp then do:
                bell.
                {mesg.i 2203}.
                undo,retry.
            end.
            else do:
                remtrz.dracc = v-pnp.
                remtrz.sacc = v-pnp.
                remtrz.drgl = arp.gl.
            end.
            if arp.crc ne remtrz.fcrc then do:
                bell.
                {mesg.i 9813}.
                undo,retry.
            end.

            /*-------------------------------------------------------------------------------------------------------*/
            enable all with frame GK.
            pause 0.
            hide frame gk no-pause.

            if v-pnp begins '000941' then do:
                update v-grp v-d1 v-d2 v-Gk v-KR v-dep v-np with frame GK
                editing:
                    readkey.
                    apply lastkey.
                    if frame-field = "v-grp" then apply "value-changed" to v-grp in frame gk.
                    if frame-field = "v-d1"  then apply "value-changed" to v-d1  in frame gk.
                    if frame-field = "v-d2"  then apply "value-changed" to v-d2  in frame gk.
                    if frame-field = "v-Gk"  then apply "value-changed" to v-Gk  in frame gk.
                    if frame-field = "v-KR"  then apply "value-changed" to v-KR  in frame gk.
                    if frame-field = "v-dep" then apply "value-changed" to v-dep in frame gk.
                    if frame-field = "v-np"  then apply "value-changed" to v-np  in frame gk.
                end.   /*editing:*/

                apply "go" to frame gk.
                hide frame gk.
            end.  /*if v-pnp begins '000941'*/
            /*---------------------------------------------------------------------------------------------------------*/

            remtrz.ord = arp.des.
            if remtrz.ord = ? then do:
               run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 772", "1", "", "").
            end.
            v-reg5 = "".
            display /*v-reg5*/ v-bin5 with frame remtrz. pause 0.
            {updtord-533.i}
        end.
        find first sysc where sysc.sysc = "GLARPB" no-lock no-error.
        if avail sysc then do:
            if (string(remtrz.drgl) >= entry(1,sysc.chval) and string(remtrz.drgl) <= entry(2,sysc.chval)) or
               (string(remtrz.drgl) >= entry(3,sysc.chval) and string(remtrz.drgl) <= entry(4,sysc.chval)) then do:
                Message " Внебалансовый счет Главной Книги. ". pause.
                undo,retry.
            end.
        end.
	end. /* do on error undo,retry */

	do on error undo,retry:
		remtrz.sbank = ourbank. sender = "o".
		if remtrz.svcrc = ? or remtrz.svcrc = 0 then remtrz.svcrc = 1.
		update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.
		find first zcrc where zcrc.crc = remtrz.svcrc no-lock no-error.
		if not avail zcrc then undo,retry.
		bcode = zcrc.code.
		display bcode with frame remtrz. pause 0.

		/* определение кода комиссии */
		if remtrz.svccgr = 0 and remtrz.fcrc <> 1 then do:
			find bankl where bankl.bank = remtrz.rbank no-lock no-error.
			if not avail bankl or bankl.nu = "n" then do:
				/* если это внешний валютный платеж, то проставить по умолчанию комиссию за счет отправителя */
				{comdef.i &cif = " cif.cif "}
			end.
		end.

		if remtrz.fcrc > 1 then update remtrz.svccgr validate (chkkomcod (remtrz.svccgr), v-msgerr) with frame remtrz.
		if remtrz.svccgr > 0 then do:
			run comiss2 (output v-komissmin, output v-komissmax).
			find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error.
			if avail tarif2 then pakal = tarif2.pakalp.
			display remtrz.svccgl pakal remtrz.svca with frame remtrz.
		end.
		if ((remtrz.svccgr > 0 and remtrz.svca = 0 ) or remtrz.svccgr = 0) and remtrz.fcrc > 1 and remtrz.svccgr <> 302 then	update remtrz.svca validate (chkkomiss(remtrz.svca), v-msgerr) with frame remtrz.

		if remtrz.svca > 0 then do:
			if sender = "o" and remtrz.dracc <> "" and remtrz.svcrc = remtrz.fcrc and remtrz.svcaaa = "" and remtrz.outcode = 3 and
			   (remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl) then remtrz.svcaaa = remtrz.dracc.
			if remtrz.outcode = 3 then v-chg = 3.
			else v-chg = 1.
			update v-chg validate(v-chg = 1 or v-chg = 3 ," 1)Cash  3)Customer-Acct " ) with frame remtrz.
			if v-chg = 1 then do:
				v-yn = false.
				if not v-yn then do:
					remtrz.svcaaa = "".
					remtrz.svcgl = v-cashgl.
				end.
				else do:
					remtrz.svcaaa = v-arp.
					remtrz.svcgl = 100200.
				end.
				display remtrz.svcaaa with frame remtrz. pause 0.
			end.
			else
            do on error undo,retry:
                if remtrz.outcode = 3 then remtrz.svcaaa = v-pnp.

                update remtrz.svcaaa with frame remtrz.
                find first aaa where aaa.aaa = remtrz.svcaaa and aaa.crc = remtrz.svcrc no-lock no-error .

                /* sasco - проверка кода счета клиента комиссии */
                if remtrz.outcode = 3 then do:
                    find b-aaa where b-aaa.aaa = v-pnp no-lock no-error.
                    if not available b-aaa then undo,retry.
                    find b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
                    find b-aaa where b-aaa.aaa = remtrz.svcaaa no-lock no-error.
                    if not available b-aaa then undo,retry.
                    if b-aaa.cif <> b-cif.cif then do:
                        message "Не тот клиент!" view-as alert-box title ''.
                        undo, retry.
                    end.
                end.

                if not avail aaa or remtrz.svcaaa = "" then undo,retry.
                remtrz.svcgl = aaa.gl.
                if aaa.sta = "C" then do:
                    bell.
                    {mesg.i 6207}.
                    undo,retry.
                end.
                s-aaa = remtrz.svcaaa.
                run aaa-aas.
                find first aas where aas.aaa = s-aaa no-lock no-error.
                if avail aas then pause.
                find first aas where aas.aaa = s-aaa and aas.sic = 'SP'no-lock no-error.
                if available aas then do: pause. undo,retry. end.
                find cif of aaa no-lock.
                tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
                tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
                pause 0.
			    /*BIN*/
				if v-bin = no then do:
					form bila
						tt1 label "Наименование"
						tt2 label "------------"
						cif.lname  label "------------" format "x(60)"
						cif.pss   label "Номер уд лич"
						cif.jss   label "РНН         "  format "x(13)"
						with overlay  1 columns column 1 row 13 frame eee.
					if available xaaa then do:
						bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
							- aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
							- aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
						displ bila tt1 tt2  cif.lname cif.pss cif.jss with frame eee.
						pause.
					end.
					else do:
						bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal
							- aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
							- aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
						displ bila tt1 tt2 cif.lname cif.pss cif.jss with frame eee.
						pause.
					end.
                end.
                else do:
					form bila
						tt1 label "Наименование"
						tt2 label "------------"
						cif.lname  label "------------" format "x(60)"
						cif.pss   label "Номер уд лич"
						cif.bin   label "ИНН/БИН     "  format "x(13)"
						with overlay  1 columns column 1 row 13 frame eee1.
					if available xaaa then do:
						bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
							- aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
							- aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
						displ bila tt1 tt2  cif.lname cif.pss cif.bin with frame eee1.
						pause.
					end.
					else do:
						bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal
							- aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
							- aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
						displ bila tt1 tt2 cif.lname cif.pss cif.bin with frame eee1.
						pause.
					end.
                end.

                if remtrz.outcode <> 3 then do:
                    remtrz.ord = trim(trim(cif.prefix) + " " + trim(cif.name)).
                    if remtrz.ord = ? then do:
                      run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 871", "1", "", "").
                    end.
                    if v-bin = no then do:
                        v-reg5 = trim(substr(cif.jss,1,13)).
                        displ /*v-reg5*/ remtrz.ord with frame remtrz.
                        update remtrz.ord  validate(remtrz.ord ne "","Введите наименование") with frame remtrz.
                        do on error undo,retry:
                            /*update v-reg5 validate(length(v-reg5) eq 12 , "Введите 12 цифр РНН !") with frame remtrz.*/
                            run rnnchk(input v-reg5,output v-rnn).
                            if v-rnn then do:
                                message "Введите РНН верно!". pause.
                            end.
                        end.
                        remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-reg5).
                        if remtrz.ord = ? then do:
                          run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 886", "1", "", "").
                        end.
                    end.
                    else do:
                        v-bin5 = trim(substr(cif.bin,1,13)).
                        displ v-bin5 remtrz.ord with frame remtrz.
                        update remtrz.ord  validate(remtrz.ord <> "","Введите наименование") with frame remtrz.
                        do on error undo,retry:
                            update v-bin5 validate((chk12_innbin(v-bin5)),'Неправильно введён БИН/ИИН') with frame remtrz.
                        end.
                        remtrz.ord = trim(remtrz.ord) + ' /RNN/' + trim(v-bin5).
                        if remtrz.ord = ? then do:
                          run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-2.p 898", "1", "", "").
                        end.
                    end.
                end.
            end.
        end.
        else do:
            remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
            remtrz.svccgl = 0.
        end.
        display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.
    end. /* do on error undo,retry */

    repeat:
	    update remtrz.detpay[1] go-on("return") with frame detpay.
        if length(remtrz.detpay[1]) > 412 then message 'Максимальное количество символов 412, необходимо сократить детали платежа!'.
        else leave.
    end.

	find first ptyp where  remtrz.ptype = ptyp.ptype no-lock no-error.
	if not avail ptyp then remtrz.ptype = "N".

	remtrz.valdt1 = g-today.

	remtrz.chg = 7. /* to  outgoing process */

    /********тут будем присваить значения в справочник**********/
    if remtrz.fcrc = 1 then do:
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' no-lock no-error.
        if avail sub-cod and sub-cod.ccode = 'msc' then do:
            find current sub-cod exclusive-lock no-error.
            sub-cod.ccode = '01'.
            find current sub-cod no-lock no-error.
        end.
        else do:
            create sub-cod.
            sub-cod.sub = 'rmz'.
            sub-cod.acc = s-remtrz.
            sub-cod.d-cod = 'pdoctng'.
            sub-cod.ccode = '01'.
        end.
        v-kod = ''.
        if remtrz.outcode = 3 then do:
            find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
            if avail aaa then do:
                find first cif where cif.cif = aaa.cif no-lock no-error.
                if avail cif then do:
                    if cif.geo = '021' then v-kod = '1'.
                    else v-kod = '2'.
                    find first sub-cod where sub-cod.sub   = 'CLN' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
                    if avail sub-cod then v-kod = v-kod + sub-cod.ccode.
                end.
            end.
            find first sub-cod where sub-cod.sub   = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'eknp' no-lock  no-error.
            if avail sub-cod and sub-cod.ccode = 'eknp' then do:
                find current sub-cod exclusive-lock no-error.
                sub-cod.rcode = v-kod + ',,'.
                find current sub-cod no-lock no-error.
            end.
            else do:
                create sub-cod.
                sub-cod.sub   = 'rmz'.
                sub-cod.acc = s-remtrz.
                sub-cod.d-cod = 'eknp'.
                sub-cod.ccode = 'eknp'.
                sub-cod.rcode = v-kod + ',,'.
            end.
        end.
    end.
    /*******************/

	run subcod(s-remtrz,'rmz').
	if keyfunction(lastkey) = "end-error" then
	repeat while lastkey <> -1:
		readkey pause 0.
	end.

	run rmzque .

	run chgsts(input "rmz", remtrz.remtrz, "new").
	if m_pid = "P" then do:
		find ofc where ofc.ofc eq g-ofc no-lock.
		remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
				+ '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
				fill(' ' , 12 - length(trim(remtrz.sbank))) +
				(trim(remtrz.dracc) +
				fill(' ' , 10 - length(trim(remtrz.dracc))))
				+ substring(string(g-today),1,2) + substring(string(g-today),4,2)
				+ substring(string(g-today),7,2).
	end.
end.

