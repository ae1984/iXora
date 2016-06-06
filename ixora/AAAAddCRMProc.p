/*
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011
 * BASES
        BANK COMM TXB
 * CHANGES
				24/10/2012 anuar - раскомменчен vAaa, раскомменчен else
        17/07/2013 Luiza - ТЗ 1728 проверка клиентов связан-х с банком
				01/08/2013 anuar - ТЗ 1728 доделал
*/

{chkaaa20.i}
{chk12_innbin.i}
DEF SHARED VAR vIsCifExist AS logical NO-UNDO.
DEF SHARED VAR vIsAAAExist AS logical NO-UNDO.
DEF SHARED VAR vCif AS CHAR NO-UNDO.
DEF SHARED VAR vAaa AS CHAR NO-UNDO.
DEF SHARED VAR vCur AS CHAR NO-UNDO.
DEF VAR s-lgr AS CHAR NO-UNDO.
DEF SHARED VAR vStaffId AS CHAR NO-UNDO.
DEF SHARED VAR vAaaList AS CHAR NO-UNDO.
DEF SHARED VAR vRelatedStatus AS CHAR NO-UNDO.
DEF SHARED VAR g-today2 AS date NO-UNDO.
DEF SHARED VAR g-ofc2 AS char NO-UNDO.

DEF SHARED VAR vErrorsProgress AS CHAR NO-UNDO.

/* проверка - связан ли с банком особ отнош 
DEF VAR v-resp AS INT.
DEF VAR v-resh AS CHAR.
v-resp = 0.
run bnkrel-chk2(vCif,output v-resp,output v-resh).
vRelatedStatus = v-resh.
if v-resp <> 1 then return.*/

def var v-bank			as char no-undo.
def var v-bname			as char no-undo.
def var v-maillist	as char no-undo.
def var l-operId		as int no-undo.
def var v-i					as int.

def					temp-table wrk
field bin		as char
field name	as char
field pr		as int.

find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if not avail txb.sysc then do:
	return.
end.
v-bank = txb.sysc.chval.

find first txb.cif where txb.cif.cif = vCif no-lock no-error.
if not avail txb.cif  then do:
		vIsCifExist = false.
		vIsAAAExist = false.
		vAaa = "".
		vRelatedStatus = "1".
end.

create wrk.
wrk.bin = txb.cif.bin.
wrk.name = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
wrk.pr = 1.

/* данные по первому руководителю */
find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and  txb.sub-cod.d-cod = 'clnchf' and txb.sub-cod.ccode = 'chief' no-lock no-error.
if avail txb.sub-cod then do:
    create wrk.
    wrk.name = txb.sub-cod.rcode.
    wrk.pr = 2.
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and  txb.sub-cod.d-cod = 'clnchfrnn' and txb.sub-cod.ccode = 'chfrnn' no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.rcode <> "" then  wrk.bin = txb.sub-cod.rcode.
end.
/* по учредителям */
for each txb.founder where txb.founder.cif = txb.cif.cif no-lock.
    create wrk.
    wrk.bin = txb.founder.bin.
    wrk.name = txb.founder.name.
    wrk.pr = 3.
end.

for each wrk no-lock.
    if chk12_innbin(trim(wrk.bin)) then find first prisv where trim(prisv.rnn) = trim(wrk.bin)  no-lock no-error.
    else find first prisv where trim(prisv.name) = trim(wrk.name) use-index name no-lock no-error. /* если ИИН некорректный или нерезидент */
    if avail prisv then do:
        find first kfmoper where kfmoper.operDoc = vCif and kfmoper.rwhn = g-today2 no-lock no-error.
        if not available kfmoper then do:
            /*подключение comm */
            find txb.sysc where txb.sysc.sysc = 'CMHOST' no-lock no-error.
            if avail txb.sysc then connect value (txb.sysc.chval) no-error.
            /*--------------------------------------------------------*/
            l-operId = next-value(kfmOperId,COMM).
            create kfmoper.
            assign kfmoper.bank = v-bank
                   kfmoper.operId = l-operId
                   kfmoper.operDoc = vCif
                   kfmoper.sts = 0
                   kfmoper.rwho = g-ofc2
                   kfmoper.rwhn = g-today2
                   kfmoper.operType = "br"
                   kfmoper.rem[1] = txb.cif.sname
                   kfmoper.rem[2] = txb.cif.bin.
                   kfmoper.rtim = time.
            find current kfmoper no-lock no-error.
            

            /*отправляем сообщение комплайнс менеджеру*/
            v-bname = ''.
            find first txb where txb.consolid and txb.bank = v-bank no-lock no-error.
            if avail txb then v-bname = txb.info.
            v-maillist = ''.
            find first txb.sysc where txb.sysc.sysc = "kfmmail" no-lock no-error.
            if avail txb.sysc and trim(txb.sysc.chval) <> '' then do:
                do v-i = 1 to num-entries(txb.sysc.chval):
                    if trim(entry(v-i,txb.sysc.chval)) <> '' then do:
                        if v-maillist <> '' then v-maillist = v-maillist + ','.
                        v-maillist = v-maillist + trim(entry(v-i,txb.sysc.chval)) + "@fortebank.com".
                    end.
                end.
                if v-maillist <> '' then do:
                    if wrk.pr = 1 then run mail(v-maillist ,g-ofc2 + "@fortebank.com","Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу","Филиал: " + v-bname + "\n" +
                        " Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу cif-код " +
                        vCif + " ФИО \n " + trim(txb.cif.prefix) + " " + trim(txb.cif.name)  + " ИИН " + txb.cif.bin, "1", "","").

                    else run mail(v-maillist ,g-ofc2 + "@fortebank.com","Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу","Филиал: " + v-bname + "\n" +
                    " Необходимо в п.м. 13.1 проверить операцию открытия счета связанному лицу " + trim(txb.cif.prefix) + " " + trim(txb.cif.name) +
                    " хочет открыть банковский счет, в связи с чем просим вас вынести вопрос на рассмотрение Совета директоров.
                            Признак связанности: Иное лицо, связанное с банком (организацией, осуществляющей отдельные виды банковских операций) особыми отношениями в соответствии с законодательными актами Республики Казахстан
                            Параметр связанности: По первому руководителю или учередителю. " ,"1", "","").

                end.
            end.
						
						vIsCifExist = true.
						vRelatedStatus = "0".
            return.
        end.
        else do:
						vIsCifExist = true.
            vRelatedStatus = string(kfmoper.sts).
						if kfmoper.sts <> 1 then return.
        end.
    end.
		else do:
			vRelatedStatus = "1".
		end.
end.


find first txb.cif where txb.cif.cif = vCif and txb.cif.type = "B" no-lock no-error.
if not avail txb.cif then
    do:
        vIsCifExist = false.
        vIsAAAExist = false.
        vAaa = "".
				vRelatedStatus = "1".
    end.
else
    do:
        vIsCifExist = true.
        find last txb.aaa where txb.aaa.cif = vCif no-lock no-error.
        if avail txb.aaa then
            do:
                vIsAAAExist = true.
                vAaa = txb.aaa.aaa.
                for each txb.aaa where txb.aaa.cif = vCif no-lock.
									vAaaList = vAaaList + txb.aaa.aaa + ",".
                end.
            end.
        else
            do:
                find first txb.crc where txb.crc.crc = 1 no-lock no-error.

				IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

                find first comm.bookcod where comm.bookcod.bookcod = "pkankcrc" and comm.bookcod.code = txb.crc.code /*KZT*/ no-lock no-error.

				IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
								
								/*
								kfmCrc	1	KZT
								kfmCrc	2	USD
								kfmCrc	3	EUR
								kfmCrc	4	RUB
								kfmCrc	6	GBP				
								*/

                def var prefix as char.
                prefix = txb.cif.prefix.

								if vCur = "1" then
                    do:
                        if(prefix = "ТОО" or prefix = "АО" or prefix = "ПК") then
                            s-lgr = "151".
                        else
                        if(prefix = "ИП"  or prefix = "ЧН" or prefix = "ЧП") then
                            s-lgr = "152".
                        else
                        if(prefix = "КХ") then
                            s-lgr = "173".
                        else
                            s-lgr = trim(comm.bookcod.info[1]). /*236*/
                    end.
                else
                if vCur = "2" then
                    do:
                        if(prefix = "ТОО" or prefix = "АО" or prefix = "ПК") then
                            s-lgr = "153".
                        else
                        if(prefix = "ИП"  or prefix = "ЧН" or prefix = "ЧП") then
                            s-lgr = "154".
                        else
                        if(prefix = "КХ") then
                            s-lgr = "175".
                        else
                            s-lgr = trim(comm.bookcod.info[1]). /*236*/
                    end.
                else
                if vCur = "3" then
                    do:
                        if(prefix = "ТОО" or prefix = "АО" or prefix = "ПК") then
                            s-lgr = "171".
                        else
                        if(prefix = "ИП"  or prefix = "ЧН" or prefix = "ЧП") then
                            s-lgr = "172".
                        else
                            s-lgr = trim(comm.bookcod.info[1]). /*236*/
                    end.
                if vCur = "4" then
                    do:
                        if(prefix = "ТОО" or prefix = "АО" or prefix = "ПК") then
                            s-lgr = "157".
                        else
                        if(prefix = "ИП"  or prefix = "ЧН" or prefix = "ЧП") then
                            s-lgr = "158".
                        else
                        if(prefix = "КХ") then
                            s-lgr = "174".

                        else
                            s-lgr = trim(comm.bookcod.info[1]). /*236*/
                    end.
                if vCur = "6" then
                    do:
                        if(prefix = "ТОО" or prefix = "АО" or prefix = "ПК") then
                            s-lgr = "176".
                        else
                        if(prefix = "ИП"  or prefix = "ЧН" or prefix = "ЧП") then
                            s-lgr = "177".
                        else
                            s-lgr = trim(comm.bookcod.info[1]). /*236*/
                    end.

                /*
                displ prefix s-lgr.
                return.
                */

				find first txb.lgr where txb.lgr.lgr eq s-lgr no-lock no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

				find first txb.led where txb.led.led eq txb.lgr.led /*SAV*/ no-lock no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

				find first txb.crc where txb.crc.crc = txb.lgr.crc /*1*/ no-lock no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                /*
                run acc_gen(input txb.lgr.gl, 1, vCif, '', false, output vAaa).


                def input parameter p-gl like gl.gl.
								def input parameter p-crc as integer.
								def input parameter p-cif as char.
								def input parameter p-arpsek as char.
								def input parameter p-viewacc as logi.
								def output parameter p-acc as char.

                */



                def var v-secek as char.
                def var v-acc as char.
                /*def var v-leter as char.*/

				find first txb.gl where txb.gl.gl = txb.lgr.gl /*220520*/ no-lock no-error.
				IF ERROR-STATUS:ERROR THEN
				do:
					vErrorsProgress = vErrorsProgress + "Неверный счет главной книги" + string(txb.lgr.gl) + ",".
					return.
				end.

				case txb.gl.subled /*cif*/:
				  when "CIF" or when "LON" then
				  do:
					find first txb.cif where txb.cif.cif = vCif no-lock no-error.

					IF ERROR-STATUS:ERROR THEN
					do:
						vErrorsProgress = vErrorsProgress + "Неверный код клиента " + string(vCif) + ",".
						return.
					end.

					find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = vCif and txb.sub-cod.d-cod = "secek" no-lock no-error.
					if not avail txb.sub-cod or txb.sub-cod.ccode = "msc" then
					do:
						vErrorsProgress = vErrorsProgress +  "Неверное значение сектора экономики клиента - msc. Нельзя открыть счет".
						return.
					end.

					if txb.sub-cod.ccode = "9" then
					do:
						if txb.cif.type = 'B' and txb.cif.cgr = 403 then v-secek = "0".
						else v-secek = "9".
					end.
					else v-secek = txb.sub-cod.ccode.
					end.

					when "ARP" then
					do:
						v-secek = ''.
					end.
					when "DFB" then
					do:
						v-secek = "4".
					end.

				end. /*case*/

				find txb.nmbr where txb.nmbr.code = "iban-" + txb.gl.subled /*cif*/ no-lock no-error.
				IF ERROR-STATUS:ERROR THEN
				do:
					vErrorsProgress = vErrorsProgress + "Нет параметра iban-" + txb.gl.subled + " в nmbr"  + ",".
					return.
				end.

				do transaction:
				  find current txb.nmbr exclusive-lock.
				  if txb.nmbr.nmbr = 9999 then do:
					 txb.nmbr.nmbr = 1.

					 txb.nmbr.prefix = entry(index(v-leter, txb.nmbr.prefix) + 1, v-leter).
				  end.
				  else txb.nmbr.nmbr = txb.nmbr.nmbr + 1.
				  find current txb.nmbr no-lock.
				end.


				v-acc = "470" + string(txb.crc.crc) + v-secek + substr(string(txb.lgr.gl),1,4) + get_figure(txb.nmbr.prefix) + string(txb.nmbr.nmbr,'9999') + txb.nmbr.sufix + get_figure("KZ") + "00".

				vAaa = "KZ" + string(98 - modulo_97(decimal(v-acc)),'99') + "470" + string(txb.crc.crc) + v-secek + substr(string(txb.lgr.gl),1,4) + txb.nmbr.prefix + string(txb.nmbr.nmbr,'9999') + txb.nmbr.sufix.


				if txb.gl.subled eq "ARP" then do transaction :
				create txb.arp.
				txb.arp.arp = vAaa no-error.
					IF ERROR-STATUS:ERROR THEN
					do:
						vErrorsProgress = vErrorsProgress + "Ошибка ARP,".
						return.
					end.
				end.

				/*if gl.subled eq "DFB" then do transaction :
				   create dfb.
				   dfb.dfb = p-acc no-error.
				   if error-status:error then undo,leave.
				end.*/

				if txb.gl.subled eq "CIF" then do transaction :
				create txb.aaa.
				txb.aaa.aaa = vAaa no-error.
					IF ERROR-STATUS:ERROR THEN
					do:
						vErrorsProgress = vErrorsProgress + "Такой тек. счет уже существует,".
						return.
					end.
				end.

				if txb.gl.subled eq "lon" then do transaction :
				create txb.lon.
				txb.lon.lon = vAaa no-error.
					IF ERROR-STATUS:ERROR THEN
					do:
						vErrorsProgress = vErrorsProgress + "Такой ссудный счет уже существует,".
						return.
					end.
				end.
                /*------------------------*/
				if vAaa = "" then
				do:
					vErrorsProgress = vErrorsProgress + "Ошибка при создании текущего счета".
					return.
				end.

                find first txb.cif where txb.cif.cif = vCif no-lock no-error.

				IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

                vErrorsProgress = vErrorsProgress + "Ошибка транзакции,".
				do transaction on error undo, return:
                    find first txb.aaa where txb.aaa.aaa eq vAaa exclusive-lock.
                    txb.aaa.cif = vCif.
                    txb.aaa.name = trim(txb.cif.name).
                    txb.aaa.gl = txb.lgr.gl.
                    txb.aaa.lgr = s-lgr.
                    find txb.sysc where txb.sysc.sysc = "branch" no-error.
                    if available txb.sysc then txb.aaa.bra = txb.sysc.inval.
                    txb.aaa.regdt = g-today2.
                    txb.aaa.stadt = g-today2.
                    txb.aaa.stmdt = txb.aaa.regdt - 1.
                    txb.aaa.tim = time.
                    txb.aaa.who = vStaffId.
                    txb.aaa.pass = txb.lgr.type.
                    txb.aaa.pri = txb.lgr.pri.
                    txb.aaa.rate = txb.lgr.rate.
                    txb.aaa.complex = txb.lgr.complex.
                    txb.aaa.base = txb.lgr.base.
                    txb.aaa.sta = "N".
                    txb.aaa.minbal[1] = 9999999999999.99.
                    txb.aaa.crc = txb.lgr.crc.
                    txb.aaa.base = txb.lgr.base.
                    txb.aaa.grp = integer(txb.lgr.alt).
                    txb.aaa.sec = false.
                    vErrorsProgress = "".
                    vIsAAAExist = false.
                end.

            end.

    end.


procedure WriteError:
DEF VAR i AS INTEGER NO-UNDO.
IF ERROR-STATUS:ERROR THEN
    DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        vErrorsProgress = vErrorsProgress + string(ERROR-STATUS:GET-MESSAGE(i)) + ",".
    END.
end procedure.