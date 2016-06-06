/* prilozh4.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        06.10.2011 damir - добавил алгоритм для других документов.
        20.10.2011 damir - небольшие корректировки.
        02.05.2012 damir - небольшие корректировки..,извещение - если сектор экон. 7 признак 1, если 9 то признак 2.
        10.05.2012 damir - небольшие корректировки..,извещение - если сектор экон. 7 признак 1, если 9 то признак 2.(Для Других Документов)
        16.07.2012 damir - добавил в приложение 4 тип докум. 07, если тип док. 17, то код способа расчетов 29; если 07, то 20.
        03.10.2012 damir - корректировка признака ЮЛ и ФЛ.
 */
release t-docscorr.

/*Формирует платежные документы, выводит их в первоначальном состоянии, и если корректировка совершена до 10 числа следующего месяца, выводит
в измененном состоянии*/
for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = '1' no-lock:
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do: /*----> aigul*/
        if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then v-clntype = 1.
        if (txb.cif.type = 'B' and txb.cif.cgr = 403) then v-clntype = 2.
        /*if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
        v-corrinfo = "".
        for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
        vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock:
                if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
                else v-partner = vcdocs.info[4].
                find vcpartner where vcpartner.partner = v-partner no-lock no-error.
                if avail vcpartner then do:
                    find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
                    find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
                    if avail vcps then do: /*----> aigul*/
                        if vcps.dndate > vcdocs.dndate then next. /*----> aigul*/
                        /*платежи*/
                        /*если извещение, то отправитель - бенефициар, получатель - наш*/

                        v-binben = "". v-iinben = "". v-bincif = "". v-iincif = "".

                        if vcdocs.dntype = "02" then do:
                            v-inout = "2".
                            v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                            v-country = vcpartner.country.
                            v-rnn = "".
                            v-okpo = "".
                            v-region = "".

                            if vcpartner.country = "KZ" then v-locat = "1".
                            else v-locat = "2".
                            if v-locat = "1" then do:
                                if trim(vcpartner.formasob) = 'ИП' then v-clntyperep = "2".
                                else v-clntyperep = "1".
                            end.
                            else do:
                                if vcpartner.info[2] = "9" then v-clntyperep = "2".
                                else v-clntyperep = "1".
                            end.

                            v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                            v-locatben = substr (txb.cif.geo, 3, 1).
                            v-countryben = "KZ".

                            if v-clntype = 1 then do:
                                v-rnnben = "".
                                v-okpoben = txb.cif.ssn.
                                if v-bin = yes then v-binben = txb.cif.bin.
                            end.
                            else if v-clntype = 2 then do:
                                v-rnnben = txb.cif.jss.
                                v-okpoben = "".
                                if v-bin = yes then v-iinben = txb.cif.bin.
                            end.

                            if v-locatben = "1" then do:
                                v-typeben = string(v-clntype).
                                v-regionben = txb.sub-cod.ccode.
                            end.
                        end.
                        /*если поручение, то отправитель - наш, получатель - бенефициар*/
                        if vcdocs.dntype = "03" then do:
                            v-inout = "1".
                            v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                            v-country = "KZ" .
                            v-locat = substr (txb.cif.geo, 3, 1).
                            if v-locat = "1" then do:
                                v-region = txb.sub-cod.ccode.
                                v-clntyperep = string(v-clntype).
                            end.

                            if v-clntype = 1 then do:
                                v-rnn = "".
                                v-okpo = txb.cif.ssn.
                                if v-bin = yes then v-bincif = txb.cif.bin.
                            end.
                            else if v-clntype = 2 then do:
                                v-rnn = txb.cif.jss.
                                v-okpo = "".
                                if v-bin = yes then v-iincif = txb.cif.bin.
                            end.

                            v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                            v-countryben = vcpartner.country.
                            v-rnnben = "".
                            v-okpoben = "".

                            if vcpartner.country = "KZ" then v-locatben = "1".
                            else v-locatben = "2".
                            if v-locatben = "1" then do:
                                if trim(vcpartner.formasob) = 'ИП' then v-typeben = "2".
                                else v-typeben = "1".
                            end.
                            else do:
                                if vcpartner.info[2] = "9" then v-typeben = "2".
                                else v-typeben = "1".
                            end.
                        end.
                    end.
                    else do:
                        v-partnername = "".
                        v-rnnben = "".
                        v-locatben = "".
                        v-countryben = "".
                        v-typeben = "".
                        v-regionben = "".
                    end.
                    create t-docs.
                    assign
                    t-docs.psdate = vcps.dndate
                    t-docs.psnum = vcps.dnnum + string(vcps.num)
                    t-docs.name = v-name
                    t-docs.rnn = v-rnn
                    t-docs.okpo = v-okpo
                    t-docs.clntype = v-clntyperep
                    t-docs.country = v-country
                    t-docs.region = v-region
                    t-docs.locat = v-locat
                    t-docs.partner = v-partnername
                    t-docs.rnnben  = v-rnnben
                    t-docs.okpoben = v-okpoben
                    t-docs.typeben = v-typeben
                    t-docs.countryben = v-countryben
                    t-docs.regionben = v-regionben
                    t-docs.locatben = v-locatben
                    t-docs.dnnum = vcdocs.dnnum
                    t-docs.dndate = vcdocs.dndate
                    t-docs.docs = vcdocs.docs
                    t-docs.sum = vcdocs.sum / 1000
                    t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
                    find first txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
                    if avail txb.ncrc then t-docs.codval = txb.ncrc.code.
                    assign
                    t-docs.inout     = v-inout
                    t-docs.note      = vcdocs.info[1]
                    t-docs.rdt       = vcdocs.rdt
                    t-docs.ctformrs  = vcdocs.kod14
                    t-docs.numdc     = vcdocs.numdc
                    t-docs.datedc    = vcdocs.datedc
                    t-docs.numnewps  = vcdocs.numnewps
                    t-docs.datenewps = vcdocs.datenewps.
                    if v-bin = yes then do:
                       t-docs.bin    = v-bincif.
                       t-docs.iin    = v-iincif.
                       t-docs.binben = v-binben.
                       t-docs.iinben = v-iinben.
                       t-docs.bnkbin = "070940006465".
                    end.
                end. /*If avail vcpartner*/
        end. /*For each vcdocs*/
    end. /*If avail txb.cif*/
end. /*For each vccontrs*/

/*Формирует только платежные документы в которых была совершена корректировка*/
for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = '1' no-lock:
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do: /*----> aigul*/
        if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then v-clntype = 1.
        if (txb.cif.type = 'B' and txb.cif.cgr = 403) then v-clntype = 2.
        /*if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
        v-corrinfo = "".
        for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
        vcdocs.dtcorrect >= v-dtb and vcdocs.dtcorrect <= v-dte no-lock:
            for each vcdocshismt where vcdocshismt.docs = vcdocs.docs and vcdocshismt.stsnewold = "new" and
            vcdocshismt.newdate >= v-dtb and vcdocshismt.newdate <= v-dte no-lock:
                v-corrinfo = "".
                create t-docscorr.
                assign
                t-docscorr.contract = vcdocshismt.contract
                t-docscorr.docs     = vcdocshismt.docs.
                if vcdocshismt.numob <> "" then t-docscorr.numob = vcdocshismt.numob.
                find first vcps where vcps.contract = vcdocshismt.contract no-lock no-error.
                if avail vcps then do:
                    assign
                    t-docscorr.psnum  = vcps.dnnum + string(vcps.num)
                    t-docscorr.psdate = vcps.dndate.
                end.
                if vcdocshismt.dndate <> ? then t-docscorr.dndate  = vcdocshismt.dndate.
                find txb.ncrc where txb.ncrc.crc = vcdocshismt.pcrc no-lock no-error.
                if avail txb.ncrc then t-docscorr.pcrc = txb.ncrc.code.
                else t-docscorr.pcrc = "".
                if vcdocshismt.sum <> 0 then t-docscorr.sum = vcdocshismt.sum / 1000.
                if vcdocshismt.info[4] <> "" then do:
                    find first b-vcdocs where b-vcdocs.docs = vcdocshismt.docs no-lock no-error.
                    if avail b-vcdocs then do:
                        if b-vcdocs.dntype = "02" then do:
                            t-docscorr.countryotp = vcdocshismt.info[4].
                        end.
                        else if b-vcdocs.dntype = "03" then do:
                            t-docscorr.countryben = vcdocshismt.info[4].
                        end.
                    end.
                end.
                if vcdocshismt.kod14 <> ""    then t-docscorr.kod14 = vcdocshismt.kod14.
                if vcdocshismt.dntype <> ""   then do:
                    if vcdocshismt.dntype = "02" then t-docscorr.dntype = "2".
                    else if vcdocshismt.dntype = "03" then t-docscorr.dntype = "1".
                end.
                if vcdocshismt.numdc <> ""    then t-docscorr.numdc = vcdocshismt.numdc.
                if vcdocshismt.datedc <> ?    then t-docscorr.datedc = vcdocshismt.datedc.
                if vcdocshismt.datenewps <> ? then t-docscorr.datenewps = vcdocshismt.datenewps.
                if vcdocshismt.numnewps <> "" then t-docscorr.numnewps = vcdocshismt.numnewps.
                if vcdocshismt.info[1] <> ""  then t-docscorr.info1 = vcdocshismt.info[1].

                if lookup('13', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "даты платежа".
                    else v-corrinfo = v-corrinfo + "даты платежа".
                end.
                if lookup('15', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "валюты платежа".
                    else v-corrinfo = v-corrinfo + "валюты платежа".
                end.
                if lookup('14', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "суммы платежа".
                    else v-corrinfo = v-corrinfo + "суммы платежа".
                end.
                if lookup('11', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "страны отправителя".
                    else v-corrinfo = v-corrinfo + "страны отправителя".
                end.
                if lookup('12', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "страны бенефициара".
                    else v-corrinfo = v-corrinfo + "страны бенефициара".
                end.
                if lookup('16', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "способа расчетов".
                    else v-corrinfo = v-corrinfo + "способа расчетов".
                end.
                if lookup('17', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "признака платежа".
                    else v-corrinfo = v-corrinfo + "признака платежа".
                end.
                if lookup('18', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "номера ДС".
                    else v-corrinfo = v-corrinfo + "номера ДС".
                end.
                if lookup('19', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "даты ДС".
                    else v-corrinfo = v-corrinfo + "даты ДС".
                end.
                if lookup('20', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "даты нового ПС".
                    else v-corrinfo = v-corrinfo + "даты нового ПС".
                end.
                if lookup('21', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "номера нового ПС".
                    else v-corrinfo = v-corrinfo + "номера нового ПС".
                end.
                if lookup('22', vcdocs.info2[1]) > 0 then do:
                    if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + "примечания".
                    else v-corrinfo = v-corrinfo + "примечания".
                end.
                t-docscorr.corr = v-corrinfo.
            end.
        end.
    end.
end.

/*Для Других документов*/
for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = '1' no-lock:
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if avail txb.cif then do: /*----> aigul*/
        if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then v-clntype = 1.
        if (txb.cif.type = 'B' and txb.cif.cgr = 403) then v-clntype = 2.
        /*if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
        v-corrinfo = "".
        for each vcdocs where vcdocs.contract = vccontrs.contract and
        (vcdocs.dntype = "17" or vcdocs.dntype = '07') and vcdocs.rdt >= v-dtb and vcdocs.rdt <= v-dte no-lock:
            find txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
            if avail txb.sysc then v-bnkbin = txb.sysc.chval. /*Дамир*/
            if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
            else v-partner = vcdocs.info[4].
            find vcpartner where vcpartner.partner = v-partner no-lock no-error.
            if avail vcpartner then do:
                find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
                find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
                if avail vcps then do: /*----> aigul*/
                    if vcps.dndate > vcdocs.rdt then next. /*----> aigul*/
                    /*платежи*/
                    /*если извещение, то отправитель - бенефициар, получатель - наш*/

                    v-binben = "". v-iinben = "". v-bincif = "". v-iincif = "".

                    if vccontrs.expimp = "e" then do:
                    /*если экспорт, то отправитель - наш, получатель - бенефициар*/
                        v-inout = "1".
                        v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                        v-country = "KZ" .
                        v-locat = substr (txb.cif.geo, 3, 1).

                        if v-locat = "1" then do:
                            v-region = txb.sub-cod.ccode.
                            v-clntyperep = string(v-clntype).
                        end.

                        if v-clntype = 1 then do:
                            v-rnn = "".
                            v-okpo = txb.cif.ssn.
                            if v-bin = yes then v-bincif = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnn = txb.cif.jss.
                            v-okpo = "".
                            if v-bin = yes then v-iincif = txb.cif.bin.
                        end.

                        v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                        v-countryben = vcpartner.country.
                        v-rnnben = "".
                        v-okpoben = "".

                        if vcpartner.country = "KZ" then v-locatben = "1".
                        else v-locatben = "2".
                        if v-locatben = "1" then do:
                            if trim(vcpartner.formasob) = 'ИП' then v-typeben = "2".
                            else v-typeben = "1".
                        end.
                        else do:
                            if vcpartner.info[2] = "9" then v-typeben = "2".
                            else v-typeben = "1".
                        end.
                    end.
                    if vccontrs.expimp = "i" then do:
                        /*если импорт, то отправитель - бенефициар, получатель - наш*/
                        v-inout = "2".
                        v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                        v-country = vcpartner.country.
                        v-rnn = "".
                        v-okpo = "".
                        v-region = "".
                        if vcpartner.country = "KZ" then v-locat = "1".
                        else v-locat = "2".
                        if v-locat = "1" then do:
                            if trim(vcpartner.formasob) = 'ИП' then v-clntyperep = "2".
                            else v-clntyperep = "1".
                        end.
                        else do:
                            if vcpartner.info[2] = "9" then v-clntyperep = "2".
                            else v-clntyperep = "1".
                        end.
                        v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                        v-locatben = substr (txb.cif.geo, 3, 1).
                        v-countryben = "KZ".

                        if v-clntype = 1 then do:
                            v-rnnben = "".
                            v-okpoben = txb.cif.ssn.
                            if v-bin = yes then v-binben = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnnben = txb.cif.jss.
                            v-okpoben = "".
                            if v-bin = yes then v-iinben = txb.cif.bin.
                        end.

                        if v-locatben = "1" then do:
                            v-typeben = string(v-clntype).
                            v-regionben = txb.sub-cod.ccode.
                        end.
                    end.
                end.
                else do:
                    assign v-partnername = "" v-rnnben = "" v-locatben = "" v-countryben = "" v-typeben = "" v-regionben = "".
                end.
                create t-docs.
                assign
                t-docs.psdate = vcps.dndate
                t-docs.psnum = vcps.dnnum + string(vcps.num)
                t-docs.name = v-name
                t-docs.rnn = v-rnn
                t-docs.okpo = v-okpo
                t-docs.clntype = v-clntyperep
                t-docs.country = v-country
                t-docs.region = v-region
                t-docs.locat = v-locat
                t-docs.partner = v-partnername
                t-docs.rnnben  = v-rnnben
                t-docs.okpoben = v-okpoben
                t-docs.typeben = v-typeben
                t-docs.countryben = v-countryben
                t-docs.regionben = v-regionben
                t-docs.locatben = v-locatben
                t-docs.dnnum = vcdocs.dnnum
                t-docs.dndate = vcdocs.dndate
                t-docs.docs = vcdocs.docs
                t-docs.sum = vcdocs.sum / 1000
                t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
                find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
                if avail txb.ncrc then t-docs.codval = txb.ncrc.code.
                assign
                t-docs.inout = v-inout
                t-docs.note = vcdocs.info[1]
                t-docs.rdt = vcdocs.rdt.
                /*if ((vcpartners.country = 'RU' and vcpartners.country = 'BY') or vcdocs.rdt > 07/01/2010) then t-docs.ctformrs = '20'.
                if ((vcpartners.country <> 'RU' and vcpartners.country <> 'BY') or vcdocs.rdt < 07/01/2010) then t-docs.ctformrs = "29".*/
                if vcdocs.dntype = '17' then t-docs.ctformrs = "29".
                if vcdocs.dntype = '07' then t-docs.ctformrs = "20".
                if v-bin = yes then do:
                   t-docs.bin    = v-bincif.
                   t-docs.iin    = v-iincif.
                   t-docs.binben = v-binben.
                   t-docs.iinben = v-iinben.
                   t-docs.bnkbin = "070940006465".
                end.
                t-docs.numdc     = vcdocs.numdc.
                t-docs.datedc    = vcdocs.datedc.
                t-docs.numnewps  = vcdocs.numnewps.
                t-docs.datenewps = vcdocs.datenewps.
            end. /*If avail vcpartner*/
        end. /*For each vcdocs*/
        for each vcdolgs where vcdolgs.contract = vccontrs.contract and
        ((vcdolgs.dntype = "26" or vcdolgs.dntype = "27")
        and vcdolgs.dndate >= v-dtb and vcdolgs.dndate <= v-dte) no-lock:
            if vcdolgs.info[4] = "" then v-partner = vccontrs.partner.
            else v-partner = vcdolgs.info[4].
            find vcpartner where vcpartner.partner = v-partner no-lock no-error.
            if avail vcpartner then do:
                find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
                find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
                if avail vcps then do:
                    v-binben = "". v-iinben = "". v-bincif = "". v-iincif = "".

                    if vcdolgs.dntype = '27' then do:
                        v-inout = "2".
                        v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                        v-country = vcpartner.country.
                        v-rnn = "".
                        v-okpo = "".
                        v-region = "".

                        if vcpartner.country = "KZ" then v-locat = "1".
                        else v-locat = "2".
                        if v-locat = "1" then do:
                            if trim(vcpartner.formasob) = 'ИП' then v-clntyperep = "2".
                            else v-clntyperep = "1".
                        end.
                        else do:
                            if vcpartner.info[2] = "9" then v-clntyperep = "2".
                            else v-clntyperep = "1".
                        end.

                        v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                        v-locatben = substr (txb.cif.geo, 3, 1).
                        v-countryben = "KZ".

                        if v-clntype = 1 then do:
                            v-rnnben = "".
                            v-okpoben = txb.cif.ssn.
                            if v-bin = yes then v-binben = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnnben = txb.cif.jss.
                            v-okpoben = "".
                            if v-bin = yes then v-iinben = txb.cif.bin.
                        end.

                        if v-locatben = "1" then do:
                            v-typeben = string(v-clntype).
                            v-regionben = txb.sub-cod.ccode.
                        end.
                    end.
                    if vcdolgs.dntype = '26' then do:
                        v-inout = "1".
                        v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                        v-country = "KZ" .
                        v-locat = substr (txb.cif.geo, 3, 1).
                        if v-locat = "1" then do:
                            v-region = txb.sub-cod.ccode.
                            v-clntyperep = string(v-clntype).
                        end.

                        if v-clntype = 1 then do:
                            v-rnn = "".
                            v-okpo = txb.cif.ssn.
                            if v-bin = yes then v-bincif = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnn = txb.cif.jss.
                            v-okpo = "".
                            if v-bin = yes then v-iincif = txb.cif.bin.
                        end.

                        v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                        v-countryben = vcpartner.country.
                        v-rnnben = "".
                        v-okpoben = "".

                        if vcpartner.country = "KZ" then v-locatben = "1".
                        else v-locatben = "2".
                        if v-locatben = "1" then do:
                            if trim(vcpartner.formasob) = 'ИП' then v-typeben = "2".
                            else v-typeben = "1".
                        end.
                        else do:
                            if vcpartner.info[2] = "9" then v-typeben = "2".
                            else v-typeben = "1".
                        end.
                    end.
                end.
                else do: v-partnername = "". v-rnnben = "". v-locatben = "". v-countryben = "". v-typeben = "". v-regionben = "". end.

                create t-docs.
                assign
                t-docs.psdate = vcps.dndate
                t-docs.psnum = vcps.dnnum + string(vcps.num)
                t-docs.name = v-name
                t-docs.rnn = v-rnn
                t-docs.okpo = v-okpo
                t-docs.clntype = v-clntyperep
                t-docs.country = v-country
                t-docs.region = v-region
                t-docs.locat = v-locat
                t-docs.partner = v-partnername
                t-docs.rnnben  = v-rnnben
                t-docs.okpoben = v-okpoben
                t-docs.typeben = v-typeben
                t-docs.countryben = v-countryben
                t-docs.regionben = v-regionben
                t-docs.locatben = v-locatben
                t-docs.dnnum = vcdolgs.dnnum
                t-docs.dndate = vcdolgs.dndate
                t-docs.docs = vcdolgs.dolgs
                t-docs.sum = vcdolgs.sum / 1000
                t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
                find txb.ncrc where txb.ncrc.crc = vcdolgs.pcrc no-lock no-error.
                if avail txb.ncrc then t-docs.codval = txb.ncrc.code.
                assign
                t-docs.inout = v-inout
                t-docs.note = vcdolgs.info[1]
                t-docs.ctformrs = vcdolgs.kod14
                t-docs.rdt = vcdolgs.rdt.
                if v-bin = yes then do:
                   t-docs.bin = v-bincif.
                   t-docs.iin = v-iincif.
                   t-docs.binben = v-binben.
                   t-docs.iinben = v-iinben.
                   t-docs.bnkbin = "070940006465".
                end.
            end. /*If avail vcpartner*/
        end. /*For each vcdolgs*/
    end. /*If avail txb.cif*/
end. /*For each vccontrs*/