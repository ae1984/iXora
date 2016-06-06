/* CifAddCRMProc.p
 * MODULE
        ЭКЗ
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
        --/--/2011 murat
 * BASES
        COMM TXB
 * CHANGES
        08/05/2012 madiyar - в одном месте не была указана база txb у таблицы founder
        22/05/2012 k.gitalov - добавил txb для счетчика uplseq
	24/10/2012 anuar - сделал проверку на юрика. строка 153
*/



DEF SHARED VAR vIsCifExist AS LOGICAL NO-UNDO.
DEF SHARED VAR vCif AS CHAR NO-UNDO.
DEF  SHARED VAR vBin AS CHAR NO-UNDO.
DEF  SHARED VAR vRegdt AS DATE NO-UNDO.
DEF  SHARED VAR vLnopf AS CHAR NO-UNDO.
DEF  SHARED VAR vSname AS CHAR NO-UNDO.
DEF  SHARED VAR vName AS CHAR NO-UNDO.
DEF  SHARED VAR vRegCert AS CHAR NO-UNDO.
DEF  SHARED VAR vBdt AS DATE NO-UNDO.
DEF  SHARED VAR vRnnsp AS CHAR NO-UNDO.
DEF  SHARED VAR vBplace AS CHAR NO-UNDO.
DEF  SHARED VAR vAddr AS CHAR NO-UNDO.
DEF  SHARED VAR vPss AS CHAR NO-UNDO.
DEF  SHARED VAR vTel AS CHAR NO-UNDO.
DEF  SHARED VAR vTlx AS CHAR NO-UNDO.
DEF  SHARED VAR vFax AS CHAR NO-UNDO.
DEF  SHARED VAR vStaffQty AS INTEGER NO-UNDO.
DEF  SHARED VAR vStatusCif AS CHAR NO-UNDO.
DEF  SHARED VAR vGeo AS CHAR NO-UNDO.
DEF  SHARED VAR vEcdivis AS CHAR NO-UNDO. /*сектор экономики*/
DEF  SHARED VAR vTypeD AS CHAR NO-UNDO. /*тип деятельности*/
DEF  SHARED VAR vYear_ AS DECIMAL NO-UNDO.
DEF  SHARED VAR vBank AS CHAR NO-UNDO.
DEF  SHARED VAR vWeekQty AS INTEGER NO-UNDO.
DEF  SHARED VAR vGroup1 AS CHAR NO-UNDO.
DEF  SHARED VAR vGroup2 AS CHAR NO-UNDO.
DEF  SHARED VAR vRating AS CHAR NO-UNDO.
DEF  SHARED VAR vSecek AS CHAR NO-UNDO.
DEF  SHARED VAR  vRegionKz AS CHAR NO-UNDO.
DEF  SHARED VAR vStaffId1 AS CHAR NO-UNDO.
DEF  SHARED VAR  vStaffId2 AS CHAR NO-UNDO.
DEF  SHARED VAR vCgr AS INTEGER NO-UNDO.
DEF  SHARED VAR vBranch AS CHAR NO-UNDO.
DEF  SHARED VAR vMname AS CHAR NO-UNDO. /*новая категория клиента*/
DEF  SHARED VAR vClnchf AS CHAR NO-UNDO.
DEF  SHARED VAR  vClnchfdnum AS CHAR NO-UNDO.
DEF  SHARED VAR vClnchfddt AS DATE NO-UNDO.
DEF  SHARED VAR vClnchfrnn AS CHAR NO-UNDO.

/*доп поля*/
DEF  SHARED VAR vAddr2 AS CHAR NO-UNDO.
DEF  SHARED VAR vOwner AS CHAR NO-UNDO.
DEF  SHARED VAR vJss AS CHAR NO-UNDO. /*РНН*/


DEF  SHARED VAR vClnchfd1 AS CHAR NO-UNDO.
DEF  SHARED VAR vClnchfddte AS DATE NO-UNDO.
DEF  SHARED VAR vClnsegm AS CHAR NO-UNDO.
DEF  SHARED VAR vClnsex AS CHAR NO-UNDO.
DEF  SHARED VAR vClnsts AS CHAR NO-UNDO.
DEF  SHARED VAR vPublicf AS CHAR NO-UNDO.

DEF  SHARED VAR vSufix AS CHAR NO-UNDO.
DEF  SHARED VAR vCoregdt AS DATE NO-UNDO.
DEF  SHARED VAR vAttn AS CHAR NO-UNDO.


DEF  SHARED VAR vClnbk AS CHAR NO-UNDO. /*фио гл.бух*/
DEF  SHARED VAR vClnbkdt AS DATE NO-UNDO. /*дата выдачи уд.л гл.бух*/
DEF  SHARED VAR vClnbkdtex AS DATE NO-UNDO. /*срок действия уд.л гл.бух*/
DEF  SHARED VAR vClnbknum AS CHAR NO-UNDO. /*номер уд.л гл.бух*/
DEF  SHARED VAR vClnbkpl AS CHAR NO-UNDO. /*кем выдан*/

DEF SHARED VAR vClnokpo AS CHAR NO-UNDO. /* Anuar 27.12.2011 ОКПО */
DEF SHARED VAR vClnokpodate AS CHAR NO-UNDO. /* Anuar 27.12.2011 дата ОКПО */

DEF SHARED VAR vUpldop AS CHAR NO-UNDO. /* Anuar 28.12.2011 доверенное лицо счет*/
DEF SHARED VAR vUplcoregdt AS DATE NO-UNDO. /* Anuar 28.12.2011 доверенное лицо дата выдачи */
DEF SHARED VAR vUplfinday AS DATE NO-UNDO. /* Anuar 28.12.2011 доверенное лицо дата окончания */
DEF SHARED VAR vUplfio AS CHAR NO-UNDO. /* Anuar 28.12.2011 доверенное лицо ФИО */
DEF SHARED VAR vUplpass AS CHAR NO-UNDO. /* Anuar 28.12.2011 доверенное лицо паспорт */

DEF SHARED VAR vUplid AS INTEGER NO-UNDO.

DEF SHARED VAR vUplbdt AS DATE NO-UNDO. /* Anuar 04.01.2012 доверенное лицо дата рождения */
DEF SHARED VAR vUplbplace AS CHAR NO-UNDO. /* Anuar 04.01.2012 доверенное лицо место рождения */
DEF SHARED VAR vUpluradr AS CHAR NO-UNDO. /* Anuar 04.01.2012 доверенное лицо юр адрес  */
DEF SHARED VAR vUplpasswho AS CHAR NO-UNDO.

/* Anuar 04.01.2012 uchreditel urik */
DEF SHARED VAR vUchrurname AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurres AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurcountry AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurorgreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurnumreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurdtreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurbin AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurrnn AS CHAR NO-UNDO.
DEF SHARED VAR vUchruradress AS CHAR NO-UNDO.
DEF SHARED VAR vUchrurtim AS CHAR NO-UNDO.

DEF SHARED VAR vUchrsts AS CHAR NO-UNDO.

DEF SHARED VAR vBnkrel AS CHAR NO-UNDO.

/* Anuar 06.01.2012 uchreditel fizik */

DEF SHARED VAR vUchrfizsname AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizfname AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizmname AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizres AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizcntr AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizdtbth AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfiznumreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizpserial AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizorgreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizdtreg AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizdtsrokul AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizbin AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizrnn AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfizadress AS CHAR NO-UNDO.
DEF SHARED VAR vUchrfiztim AS CHAR NO-UNDO.

/* Anuar 08.02.2012 */
DEF SHARED VAR vIPpassend AS DATE NO-UNDO.



/*-------------------*/


DEF SHARED VAR vErrorsProgress AS CHAR NO-UNDO.

DEF SHARED VAR g-today2 AS date NO-UNDO.
vErrorsProgress = vErrorsProgress + "Ошибка транзакции,".
find first txb.cif where txb.cif.bin = vBin and txb.cif.type = "B" no-lock no-error.
    if not avail txb.cif then
    do:
        do transaction on error undo, return:
            find txb.nmbr where txb.nmbr.code = "cif" exclusive-lock no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
            vCif = string(txb.nmbr.prefix + string(txb.nmbr.nmbr + 1) + txb.nmbr.sufix).
            txb.nmbr.nmbr = txb.nmbr.nmbr + 1.
            release txb.nmbr.
            vIsCifExist = false.
            create txb.cif no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.

             /*если не АО ТОО КХ то эти поля не добавляем*/
                    if (vOwner = "АО" or vOwner = "ТОО") then
                        do:
                            vCoregdt = ?.
                        end.

            assign  txb.cif.cif = vCif
                    txb.cif.bin = vBin
                    txb.cif.regdt = vRegdt
                    txb.cif.sname = vSname
                    txb.cif.name = vName
                    txb.cif.mname = vMname
                    txb.cif.expdt = vBdt
                    txb.cif.bplace = vBplace
                    txb.cif.addr[1] = vAddr /*адрес из строки с 8 сегментами через запятую*/
                    txb.cif.pss = vPss
                    txb.cif.tel = vTel
                    txb.cif.tlx = vTlx
                    txb.cif.fax = vFax
                    txb.cif.stn = integer(vStatusCif) /*<10, 0 активный, 2 неактивный, 9 на удаление*/
                    txb.cif.geo = vGeo
                    txb.cif.jss = vJss

					/* Anuar 08.02.2012 */
					txb.cif.dtsrokul = vIPpassend

                    txb.cif.ref[8] = vRegCert /*регистрационное свидетельство varchar*/
                    txb.cif.cust-since = vStaffQty /*кол-во сотрудников int*/
                    txb.cif.addr[2] = vAddr2
                    txb.cif.prefix = vOwner
                    txb.cif.sufix = vSufix
                    txb.cif.coregdt = vCoregdt
                    txb.cif.attn = vAttn

					txb.cif.ssn = vClnokpo /* Anuar 27.12.2011 ОКПО */
					txb.cif.jel = vClnokpodate /* Anuar 27.12.2011 дата ОКПО */
                    /*
                    нужно создать таблицу 1:1 к cif для значений:


                    vYear_ годовой оборот - double
                    vBank обслуживающий банк - varchar
                    vWeekQty кол-во сделок в неделю - int
                    vGroup1 классификация 1 - varchar
                    vGroup2 классификация 2 - varchar
                    vRating рейтинг - varchar
                    */
                    txb.cif.cgr = vCgr
                    txb.cif.fname = vStaffId2
                    txb.cif.who = vStaffId1
                    txb.cif.whn = g-today2
                    txb.cif.tim = time
                    txb.cif.ofc = vStaffId1.
                    if (vCgr = 501) then
                        txb.cif.type = "P".
                    else
                        txb.cif.type = "B".
                    /*if (vOwner = "ИП") then
                        txb.cif.dtsrokul = vClnchfddte.*/

			create txb.uplcif no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
				txb.uplcif.upl = next-value(uplseq , txb).

				vUplid = next-value( uplseq , txb ).

				txb.uplcif.uplid = vUplid.
			assign

					txb.uplcif.cif = vCif
					txb.uplcif.dop = vUpldop  /* Anuar 28.12.2011 доверенное лицо счет */
					txb.uplcif.coregdt = vUplcoregdt  /* Anuar 28.12.2011 доверенное лицо дата выдачи */
					txb.uplcif.finday = vUplfinday  /* Anuar 28.12.2011 доверенное лицо дата окончания */
					txb.uplcif.badd[1] = vUplfio  /* Anuar 28.12.2011 доверенное лицо ФИО */
					txb.uplcif.badd[2] = vUplpass /* Anuar 28.12.2011 доверенное лицо паспорт */
					txb.uplcif.badd[3] = vUplpasswho. /* Anuar 28.12.2011 доверенное лицо паспорт кем выдан */

			create txb.upl no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
			assign
					txb.upl.uplid = vUplid
					txb.upl.fio = vUplfio
					txb.upl.bdt = vUplbdt
					txb.upl.bplace = vUplbplace
					txb.upl.uradr = vUpluradr.

			/* Anuar 09.02.2012 */
			DEF buffer b-founder for txb.founder.

			find last b-founder use-index fid no-lock no-error.

			DEF VAR n AS INTEGER NO-UNDO.
			DEF VAR k AS INTEGER NO-UNDO.
			k = NUM-ENTRIES(vUchrsts) - 1. /* разбираю строку статус учредителя, получаю количество слов, отнимаю 1 */
			DO n = 1 to k:
			create txb.founder no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
					if avail b-founder then txb.founder.fid = b-founder.fid + n.
					else txb.founder.fid = 2000.
					txb.founder.cif = vCif.
					txb.founder.ftype = entry(n,vUchrsts). /* получаю последовательно все слова в списке с запятыми  */



					if (entry(n,vUchrsts) = "B") then
						do:
							if (entry(n,vUchrfizres) = "021") then
								do:
									txb.founder.res = 1.
								end.
							if (entry(n,vUchrfizres) = "022") then
								do:
									txb.founder.res = 2.
								end.

							txb.founder.name = entry(n,vUchrurname).
							txb.founder.country = entry(n,vUchrfizcntr).
							txb.founder.orgreg = entry(n,vUchrurorgreg).
							txb.founder.numreg = entry(n,vUchrurnumreg).
							txb.founder.dtreg = date(entry(n,vUchrurdtreg)).
							txb.founder.bin = entry(n,vUchrfizbin).
							txb.founder.rnn = entry(n,vUchrfizrnn).
							txb.founder.adress = entry(n,vUchrfizadress).
							txb.founder.reschar[1] = entry(n,vUchrfiztim).
						end.

					if (entry(n,vUchrsts) = "P") then
						do:
							if (entry(n,vUchrfizres) = "021") then
								do:
									txb.founder.res = 1.
								end.
							if (entry(n,vUchrfizres) = "022") then
								do:
									txb.founder.res = 2.
								end.
							txb.founder.name = entry(n,vUchrfizfname) + " " + entry(n,vUchrfizsname) + " " + entry(n,vUchrfizmname).
							txb.founder.sname = entry(n,vUchrfizfname).
							txb.founder.fname =	entry(n,vUchrfizsname).
							txb.founder.mname = entry(n,vUchrfizmname).
							txb.founder.country = entry(n,vUchrfizcntr).
							txb.founder.dtbth = date(entry(n,vUchrfizdtbth)).
							txb.founder.numreg = entry(n,vUchrfiznumreg).
							txb.founder.pserial = entry(n,vUchrfizpserial).
							txb.founder.orgreg = entry(n,vUchrfizorgreg).
							txb.founder.dtreg = date(entry(n,vUchrfizdtreg)).
							txb.founder.dtsrokul = date(entry(n,vUchrfizdtsrokul)).
							txb.founder.bin = entry(n,vUchrfizbin).
							txb.founder.rnn = entry(n,vUchrfizrnn).
							txb.founder.adress = entry(n,vUchrfizadress).
							txb.founder.reschar[1] = entry(n,vUchrfiztim).

						end.

			END.

            /*vBranch - передается код филиала куда и где его использовать*/
            create txb.crg no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
            txb.crg.crg = string(next-value(crgnum, txb)).
            assign
                 txb.crg.des = vCif
                 txb.crg.who = vStaffId1
                 txb.crg.whn = g-today2
                 txb.crg.stn = 1
                 txb.crg.tim = time
                 txb.crg.regdt = g-today2.
                 txb.cif.crg = string(txb.crg.crg).

            for each txb.sub-dic where txb.sub-dic.sub = "cln" no-lock.
                find first txb.sub-cod where txb.sub-cod.acc = vCif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = txb.sub-dic.d-cod use-index dcod  no-lock no-error.
                if not avail txb.sub-cod then do:
                    create txb.sub-cod no-error.
                IF ERROR-STATUS:ERROR THEN
                do:
                    run WriteError.
                    return.
                end.
                    txb.sub-cod.acc = vCif.
                    txb.sub-cod.sub = "cln".
                    txb.sub-cod.d-cod = txb.sub-dic.d-cod.
                    txb.sub-cod.ccode = "msc".
                end.
            end.

            if vLnopf <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "lnopf" and txb.sub-cod.acc = vCif no-error. /*справочник Организационно-правовая форма хозяйствования */
                if avail txb.sub-cod  then txb.sub-cod.ccode = vLnopf.
            end.

            if vRnnsp <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "rnnsp" and txb.sub-cod.acc = vCif no-error. /*справочник Районы регистрации РНН */
                if avail txb.sub-cod  then
                    do:
                        def var vInt as int.
                        vInt = int(vRnnsp) no-error.
                        IF ERROR-STATUS:ERROR THEN
                            do:
                                txb.sub-cod.rcode = vRnnsp.
                            end.
                        ELSE
                            do:
                                txb.sub-cod.ccode = vRnnsp.
                            end.
                    end.
            end.

            if vEcdivis <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = vCif no-error. /*справочник Перечень шифров отраслей экономики  */
                if avail txb.sub-cod  then txb.sub-cod.ccode = vEcdivis.
            end.

            if vSecek <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = vCif no-error. /*справочник Сектора экономики */
                if avail txb.sub-cod then txb.sub-cod.ccode = vSecek.
            end.

            if vRegionKz <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "regionkz" and txb.sub-cod.acc = vCif no-error. /*справочник Регионы Казахстана */
                if avail txb.sub-cod  then txb.sub-cod.ccode = vRegionKz.
            end.

            if vClnchf <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchf" and txb.sub-cod.acc = vCif no-error. /* свободное поле ФИО руководителя предприятия  */
                if avail txb.sub-cod then
                    do:
                        txb.sub-cod.rcode = vClnchf.
                        txb.sub-cod.ccode = "chief".
                    end.
            end.

            if vClnchfdnum <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfdnum" and txb.sub-cod.acc = vCif no-error. /*своб поле Номер уд.д.первого руководителя */
                if avail txb.sub-cod  then
                    do:
                        txb.sub-cod.rcode = vClnchfdnum.
                        txb.sub-cod.ccode = "chfdocnum".
                    end.
            end.


            if string(vClnchfddt) <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfddt" and txb.sub-cod.acc = vCif no-error. /* св поле Дата выдачи уд.д.первому руководителю */
                if avail txb.sub-cod then
                    do:
                        txb.sub-cod.rcode = string(vClnchfddt).
                        txb.sub-cod.ccode = "chfdocdt".

                    end.
            end.

            if vClnchfrnn <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfrnn" and txb.sub-cod.acc = vCif no-error. /* своб поле РНН первого руководителя */
                if avail txb.sub-cod then
                    do:
                        txb.sub-cod.rcode = vClnchfrnn.
                        txb.sub-cod.ccode = "chfrnn".
                    end.
            end.

/*новые поля справочника*/

/*
clnchfd1 Должность руководителя предприятия
clnchfddte
clnsegm
clnsex
сlnsts
public
*/
            if vClnchfd1 <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfd1" and txb.sub-cod.acc = vCif no-error. /* своб поле Должность руководителя предприятия  */
                if avail txb.sub-cod  then
                    do:
                        txb.sub-cod.rcode = vClnchfd1.
                        txb.sub-cod.ccode = "clnchfd1".
                    end.
            end.

            if string(vClnchfddte) <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfddtex" and txb.sub-cod.acc = vCif no-error. /* своб поле Срок действия уд.л. директ   */
                if avail txb.sub-cod  then
                    do:
                        txb.sub-cod.rcode = string(vClnchfddte).
                        txb.sub-cod.ccode = "clnchfddtex".
                    end.
            end.

            if vClnsegm <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsegm" and txb.sub-cod.acc = vCif no-error. /* справочник Признак сегментации  */
                if avail txb.sub-cod then txb.sub-cod.ccode = vClnsegm.
            end.

            if vClnsex <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsex" and txb.sub-cod.acc = vCif no-error. /* справочник Пол клиента   */
                if avail txb.sub-cod then txb.sub-cod.ccode = vClnsex.
            end.
            /*displ vClnsts.*/
            if vClnsts <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsts" and txb.sub-cod.acc = vCif no-error. /* справочник Статусы клиентов   */
                if avail txb.sub-cod then txb.sub-cod.ccode = vClnsts.
            end.

            if vPublicf <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "publicf" and txb.sub-cod.acc = vCif no-error. /* справочник Публичное должностное лицо  */
                if avail txb.sub-cod then txb.sub-cod.ccode = vPublicf.
            end.


    def var vIsConn as char.
                    vIsConn = "0".
            find first comm.prisv where comm.prisv.rnn = vJss or comm.prisv.name matches "*" + vName + "*" no-error.
                if avail comm.prisv then
                    vIsConn = "1".
/*
            find first txb.prisv where txb.prisv.name matches "*" + vName + "*" no-error.
                if avail txb.prisv then
                    vIsConn = "1".
*/
            find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = vCif no-error. /* справочник связанные лица*/
                        if avail txb.sub-cod then
                            do:
                                if vBnkrel = "01" then
								do:
                                    txb.sub-cod.ccode = "01".
									txb.sub-cod.rcode = "Связанное лицо".
								end.
                                else if vBnkrel = "02" then
								do:
                                    txb.sub-cod.ccode = "02".
									txb.sub-cod.rcode = "Несвязанное лицо".
								end.
								else
								do:
									txb.sub-cod.ccode = "msc".
									txb.sub-cod.rcode = "Другое".
								end.
							end.

            find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "sproftcn" and txb.sub-cod.acc = vCif no-error. /* справочник связанные лица*/
                        if avail txb.sub-cod then txb.sub-cod.ccode = "103".

        if (vOwner = "АО" or vOwner = "ТОО" or vOwner = "КХ") then
            do:
            if vClnbk <> "" then
                do:
                    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbk" and txb.sub-cod.acc = vCif no-error.
                    if avail txb.sub-cod then
                        do:
                            txb.sub-cod.rcode = vClnbk.
                            txb.sub-cod.ccode = "mainbk".
                        end.
                end.
            if string(vClnbkdt) <> "" then
                do:
                    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkdt" and txb.sub-cod.acc = vCif no-error.
                    if avail txb.sub-cod then
                        do:
                            txb.sub-cod.rcode = string(vClnbkdt).
                            txb.sub-cod.ccode = "clnbkdt".
                        end.
                end.
            if string(vClnbkdtex) <> "" then
                do:
                    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkdtex" and txb.sub-cod.acc = vCif no-error.
                    if avail txb.sub-cod then
                        do:
                            txb.sub-cod.rcode = string(vClnbkdtex).
                            txb.sub-cod.ccode = "clnbkdtex".
                        end.
                end.
            if vClnbknum <> "" then
                do:
                    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbknum" and txb.sub-cod.acc = vCif no-error.
                    if avail txb.sub-cod then
                        do:
                            txb.sub-cod.rcode = vClnbknum.
                            txb.sub-cod.ccode = "clnbknum".
                        end.
                end.
            if vClnbkpl <> "" then
                do:
                    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkpl" and txb.sub-cod.acc = vCif no-error.
                    if avail txb.sub-cod then
                        do:
                            txb.sub-cod.rcode = vClnbkpl.
                            txb.sub-cod.ccode = "clnbkpl".
                        end.
                end.

				/* Anuar 27.12.2011
			if vClnokpo <> "" then
            do:
                find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "addr[3]" and txb.sub-cod.acc = vCif no-error.
                if avail txb.sub-cod then
                    do:
                        txb.sub-cod.rcode = vClnokpo.
                        txb.sub-cod.ccode = "clnokpo".
                    end.
            end.

			*/
            end.

         vErrorsProgress = "".
        end.
     end.
else
    do:
        vIsCifExist = true.
        vCif = cif.cif.
        vErrorsProgress = "".
    end.
procedure WriteError:
DEF VAR i AS INTEGER NO-UNDO.
IF ERROR-STATUS:ERROR THEN
    DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        vErrorsProgress = vErrorsProgress + string(ERROR-STATUS:GET-MESSAGE(i)) + ",".
    END.
end procedure.