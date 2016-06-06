/* vcrep4dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM TXB
 * AUTHOR
        06.05.2008 galina
 * CHANGES
        12.05.2008 galina - исправлена ошибка в определение типа клиента ИП или Юр.Лицо
        19.05.2008 galina - не выводить в отчет закрытые контракты
        18.08.2008 galina - выбираем форму расчетов, указанную в платежном документе
        10.11.2008 galina - для нерезидента получателя(отправителя) не указываем код региона и признак ИП или Ю.Л.
        02/09/2010 galina - не пропускаем закрытые контракты
        09/09/2010 galina - добавила акты, если инопартнерв тамож.союзе
        14/10/2010 galina - акты, если инопартнерв тамож.союзе, берем по дате регистрации в ixora
        2/12/10 aigul - вывод в отчет всех ГТД, у которых Инопартнер RU или BY
        08.12.2010 aigul - вывод в отчет тех ГТД у которых дата из ПлатДк не меньше чем в ПСДлДс if vcps.dndate > vcdocs.dndate then next.
        14.12.2010 aigul - убрала проверку для поля ВОЗВРАТ
                           если экспорт и 02 - извещ, то Отправитель бенефициар
                           если импорт и 03 - поруч, то Отправитель наш клиент
        22.12.2010 aigul - добавила в таблицу t-docs поле rdt
        06.01.2011 aigul - добавила вывод сумм залогов
        12.01.2011 aigul - сделала вывод всех актов типа 17, и код способа расчета для них вывела 29 типом
        10.04.2011 damir - новые переменные v-bin,v-iin,v-binben,v-iinben
                           bin,iin,binben,iinben во временную таблицу.

        28.04.2011 damir - поставлены ключи. процедура chbin.i
        30.09.2011 damir - добавлены:
                           1) prilozh4.i, добавил алгоритм v-oper = "2" and v-option = 'msg', проверку записи в t-docs.numobyaz
                           после 03/10/2011 присваивает vcdocs.numobyaz, до этого момента vcdocs.dnnum.
        06.12.2011 damir - добавил vcmtform_txb.i
        28.12.2011 damir - небольшие корректировки..
        12.01.2012 damir - перекомпиляция в связи с изменением prilozh4.i.
        14.03.2012 damir - убрал numobyaz.
        02.05.2012 damir - перекомпиляция,извещение - если сектор экон. 7 признак 1, если 9 то признак 2.
        10.05.2012 damir - перекомпиляция,извещение - если сектор экон. 7 признак 1, если 9 то признак 2.(Для Других Документов).
        16.07.2012 damir - добавил в МТ тип докум. 07, если тип док. 17, то код способа расчетов 29; если 07, то 20.
        13.08.2012 damir - корректировка...
        03.10.2012 damir - корректировка признака ЮЛ и ФЛ.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/
{vc.i}
{vcmtform_txb.i}
{comm-txb_txb.i}
{vcshared4.i}

def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-okpo as char no-undo.
def var v-country as char no-undo.
def var v-rnnben as char no-undo.
def var v-okpoben as char no-undo.
def var v-partner as char no-undo.
def var v-partnername as char no-undo.
def var v-countryben as char no-undo.
def var v-locat as char no-undo.
def var v-locatben as char no-undo.
def var v-opertype as char no-undo.
def var v-clntype as inte no-undo.
def var v-clntyperep as char no-undo.
def var v-typeben as char no-undo.
def var v-note as char no-undo.
def var v-region as char no-undo.
def var v-regionben as char no-undo.
def var v-inout as char no-undo.
def var v-bincif as char no-undo.
def var v-iincif as char no-undo.
def var v-binben as char no-undo.
def var v-iinben as char no-undo.
def var v-bnkbin as char no-undo.
def var v-corrinfo as char.
def var v-ourbnk as char.
def var NAME as char.
def var COUNTRY as char.
def var BNAME as char.
def var BCOUNTRY as char.
def var PAYDATE as char.
def var SUMM as char.
def var CURR as char.
def var CODECALC as char.
def var INOUT as char.
def var NOTE as char.

v-ourbnk = comm-txb().

def buffer b-vcdocs for vcdocs.

function BegData returns char(input opt as char,input id as inte,input nm as char,input vv as char):
    def buffer b-vccorrecthis for comm.vccorrecthis.

    def var val as char.
    val = "".
    if opt = "VCCONTRS" then do:
        find first b-vccorrecthis where b-vccorrecthis.contract = id and b-vccorrecthis.correctdt <> ? and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(1,b-vccorrecthis.corrfield,"|").
    end.
    if opt = "VCDOCS" then do:
        find first b-vccorrecthis where b-vccorrecthis.docs = id and b-vccorrecthis.correctdt <> ? and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(1,b-vccorrecthis.corrfield,"|").
    end.
    if val <> "" then return val.
    else return vv.
end function.

m1:
for each vccontrs where vccontrs.bank = v-ourbnk no-lock:
    if not (vccontrs.cttype = '1') then next m1.
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if not avail txb.cif then next m1.
    v-clntype = 0.
    if txb.cif.type = 'B' then do:
        if txb.cif.cgr <> 403 then v-clntype = 1.
        else v-clntype = 2.
    end.
    m2:
    for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
        if not ( (lookup(vcdocs.dntype,"02,03") > 0 and vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte) or
                 (lookup(vcdocs.dntype,"17,07") > 0 and vcdocs.rdt >= v-dtb and vcdocs.rdt <= v-dte) )
        then next m2.

        v-binben = "". v-iinben = "". v-bincif = "". v-iincif = "".
        if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdocs.info[4].
        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if not avail vcpartner then next m2.
        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then do:
            if vcps.dndate > vcdocs.dndate and lookup(vcdocs.dntype,"17,07") = 0 then next m2.
            if vcps.dndate > vcdocs.rdt and lookup(vcdocs.dntype,"17,07") > 0 then next m2.
            /*если извещение, то отправитель - бенефициар, получатель - наш*/
            if vcdocs.dntype = "02" then do:
                v-inout = "2".
                /*v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-country = vcpartner.country.*/

                v-name = BegData("VCDOCS",vcdocs.docs,"NAME",trim(vcpartners.name)) + " " + trim(vcpartner.formasob).
                v-country = BegData("VCDOCS",vcdocs.docs,"COUNTRY",trim(vcpartner.country)).

                v-rnn = "".
                v-okpo = "".
                v-region = "".
                if vcpartner.country = "KZ" then v-locat = "1". else v-locat = "2".
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
                if v-bin then do:
                    if v-clntype = 1 then do:
                        v-rnnben = "".
                        v-okpoben = txb.cif.ssn.
                        v-binben = txb.cif.bin.
                    end.
                    else if v-clntype = 2 then do:
                        v-rnnben = txb.cif.jss.
                        v-okpoben = "".
                        v-iinben = txb.cif.bin.
                    end.
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
                if v-bin then do:
                    if v-clntype = 1 then do:
                        v-rnn = "".
                        v-okpo = txb.cif.ssn.
                        v-bincif = txb.cif.bin.
                    end.
                    else if v-clntype = 2 then do:
                        v-rnn = txb.cif.jss.
                        v-okpo = "".
                        v-iincif = txb.cif.bin.
                    end.
                end.

                /*v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-countryben = vcpartner.country.*/

                v-partnername = BegData("VCDOCS",vcdocs.docs,"BNAME",trim(vcpartners.name)) + " " + trim(vcpartner.formasob).
                v-countryben = BegData("VCDOCS",vcdocs.docs,"BCOUNTRY",trim(vcpartner.country)).

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
            if lookup(vcdocs.dntype,"17,07") > 0 then do:
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
                    if v-bin then do:
                        if v-clntype = 1 then do:
                            v-rnn = "".
                            v-okpo = txb.cif.ssn.
                            v-bincif = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnn = txb.cif.jss.
                            v-okpo = "".
                            v-iincif = txb.cif.bin.
                        end.
                    end.

                    /*v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                    v-countryben = vcpartner.country.*/

                    v-partnername = BegData("VCDOCS",vcdocs.docs,"BNAME",trim(vcpartners.name)) + " " + trim(vcpartner.formasob).
                    v-countryben = BegData("VCDOCS",vcdocs.docs,"BCOUNTRY",trim(vcpartner.country)).

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

                    /*v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                    v-country = vcpartner.country.*/

                    v-name = BegData("VCDOCS",vcdocs.docs,"NAME",trim(vcpartners.name)) + " " + trim(vcpartner.formasob).
                    v-country = BegData("VCDOCS",vcdocs.docs,"COUNTRY",trim(vcpartner.country)).

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
                    if v-bin then do:
                        if v-clntype = 1 then do:
                            v-rnnben = "".
                            v-okpoben = txb.cif.ssn.
                            v-binben = txb.cif.bin.
                        end.
                        else if v-clntype = 2 then do:
                            v-rnnben = txb.cif.jss.
                            v-okpoben = "".
                            v-iinben = txb.cif.bin.
                        end.
                    end.
                    if v-locatben = "1" then do:
                        v-typeben = string(v-clntype).
                        v-regionben = txb.sub-cod.ccode.
                    end.
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
        t-docs.psdate = vcps.dndate.
        t-docs.psnum = vcps.dnnum + string(vcps.num).
        t-docs.rnn = v-rnn.
        t-docs.okpo = v-okpo.
        t-docs.clntype = v-clntyperep.
        t-docs.name = v-name.
        t-docs.country = v-country.
        t-docs.region = v-region.
        t-docs.locat = v-locat.
        t-docs.rnnben  = v-rnnben.
        t-docs.okpoben = v-okpoben.
        t-docs.typeben = v-typeben.
        t-docs.partner = v-partnername.
        t-docs.countryben = v-countryben.
        t-docs.regionben = v-regionben.
        t-docs.locatben = v-locatben.
        t-docs.dnnum = vcdocs.dnnum.
        t-docs.dndate = date(BegData("VCDOCS",vcdocs.docs,"PAYDATE",string(vcdocs.dndate,"99/99/9999"))) no-error.
        t-docs.docs = vcdocs.docs.
        t-docs.sum = deci(BegData("VCDOCS",vcdocs.docs,"SUMM",string(vcdocs.sum,"-zzzzzzzzzzzzzzzzzzzzzzz9.99"))) / 1000 no-error.
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
        t-docs.pcrc = inte(BegData("VCDOCS",vcdocs.docs,"CURR",string(vcdocs.pcrc))) no-error.
        find txb.ncrc where txb.ncrc.crc = t-docs.pcrc no-lock no-error.
        if avail txb.ncrc then t-docs.codval = txb.ncrc.code.
        t-docs.note = BegData("VCDOCS",vcdocs.docs,"NOTE",vcdocs.info[1]).
        t-docs.rdt = vcdocs.rdt.
        if lookup(vcdocs.dntype,"02,03") > 0 then do:
            t-docs.ctformrs = BegData("VCDOCS",vcdocs.docs,"CODECALC",vcdocs.kod14).
            t-docs.inout = BegData("VCDOCS",vcdocs.docs,"INOUT",v-inout).
        end.
        else do:
            if vcdocs.dntype = '17' then t-docs.ctformrs = "29".
            if vcdocs.dntype = '07' then t-docs.ctformrs = "20".
            t-docs.inout = v-inout.
        end.
        if v-bin then do:
           t-docs.bin    = v-bincif.
           t-docs.iin    = v-iincif.
           t-docs.binben = v-binben.
           t-docs.iinben = v-iinben.
           t-docs.bnkbin = "070940006465".
        end.
        t-docs.numdc = vcdocs.numdc.
        t-docs.datedc = vcdocs.datedc.
        t-docs.numnewps = vcdocs.numnewps.
        t-docs.datenewps = vcdocs.datenewps.
        if lookup(vcdocs.dntype,"02,03") > 0 then t-docs.numobyaz = vcdocs.dnnum.
        if lookup(vcdocs.dntype,"17,07") > 0 then t-docs.numobyaz = string(vcdocs.numobyaz).
    end.
    m3:
    for each vcdolgs where vcdolgs.contract = vccontrs.contract no-lock:
        if not ( lookup(vcdolgs.dntype,"26,27") > 0 and vcdolgs.dndate >= v-dtb and vcdolgs.dndate <= v-dte )
        then next m3.

        v-binben = "". v-iinben = "". v-bincif = "". v-iincif = "".
        if vcdolgs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdolgs.info[4].
        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if not avail vcpartner then next m3.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.
        if avail vcps then do:
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
                if v-bin then do:
                    if v-clntype = 1 then do:
                        v-rnnben = "".
                        v-okpoben = txb.cif.ssn.
                        v-binben = txb.cif.bin.
                    end.
                    else if v-clntype = 2 then do:
                        v-rnnben = txb.cif.jss.
                        v-okpoben = "".
                        v-iinben = txb.cif.bin.
                    end.
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
                if v-bin then do:
                    if v-clntype = 1 then do:
                        v-rnn = "".
                        v-okpo = txb.cif.ssn.
                        v-bincif = txb.cif.bin.
                    end.
                    else if v-clntype = 2 then do:
                        v-rnn = txb.cif.jss.
                        v-okpo = "".
                        v-iincif = txb.cif.bin.
                    end.
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
        t-docs.psdate = vcps.dndate.
        t-docs.psnum = vcps.dnnum + string(vcps.num).
        t-docs.name = v-name.
        t-docs.rnn = v-rnn.
        t-docs.okpo = v-okpo.
        t-docs.clntype = v-clntyperep.
        t-docs.country = v-country.
        t-docs.region = v-region.
        t-docs.locat = v-locat.
        t-docs.partner = v-partnername.
        t-docs.rnnben  = v-rnnben.
        t-docs.okpoben = v-okpoben.
        t-docs.typeben = v-typeben.
        t-docs.countryben = v-countryben.
        t-docs.regionben = v-regionben.
        t-docs.locatben = v-locatben.
        t-docs.dnnum = vcdolgs.dnnum.
        t-docs.dndate = vcdolgs.dndate.
        t-docs.docs = vcdolgs.dolgs.
        t-docs.sum = vcdolgs.sum / 1000.
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
        find txb.ncrc where txb.ncrc.crc = vcdolgs.pcrc no-lock no-error.
        if avail txb.ncrc then t-docs.codval = txb.ncrc.code.
        t-docs.inout = v-inout.
        t-docs.note = vcdolgs.info[1].
        t-docs.ctformrs = vcdolgs.kod14.
        t-docs.rdt = vcdolgs.rdt.
        if v-bin then do:
           t-docs.bin = v-bincif.
           t-docs.iin = v-iincif.
           t-docs.binben = v-binben.
           t-docs.iinben = v-iinben.
           t-docs.bnkbin = "070940006465".
        end.
    end.
end.

def temp-table t-abbr no-undo
    field nm as char
    field vl as char
index idx1 nm ascending.

create t-abbr.
t-abbr.nm = "NAME". t-abbr.vl = "наименования отправителя".
create t-abbr.
t-abbr.nm = "COUNTRY". t-abbr.vl = "страны отправителя".
create t-abbr.
t-abbr.nm = "BNAME". t-abbr.vl = "наименования получателя".
create t-abbr.
t-abbr.nm = "BCOUNTRY". t-abbr.vl = "страны получателя".
create t-abbr.
t-abbr.nm = "PAYDATE". t-abbr.vl = "даты".
create t-abbr.
t-abbr.nm = "SUMM". t-abbr.vl = "суммы".
create t-abbr.
t-abbr.nm = "CURR". t-abbr.vl = "валюты".
create t-abbr.
t-abbr.nm = "CODECALC". t-abbr.vl = "способа расчетов".
create t-abbr.
t-abbr.nm = "INOUT". t-abbr.vl = "признака".
create t-abbr.
t-abbr.nm = "NOTE". t-abbr.vl = "примечания".

if v-oper = "2" then run Cdata("1","02,03,17,07",v-dtdoc,v-dtdoc,v-dtcor).
if v-option = "rep" then run RepData("02,03,17,07",v-dtb,v-dte).

function RetAbbr returns char(input nm as char,input dntype as char).
    def var v-nm as char.
    if lookup(dntype,"02,03") > 0 then v-nm = "платежа".
    if lookup(dntype,"17,07") > 0 then v-nm = "исполнения обязательств".
    find t-abbr where t-abbr.nm = nm no-lock no-error.
    if avail t-abbr then do:
        return t-abbr.vl + " " + v-nm.
    end.
    else return "".
end function.

procedure RepData:
    def input parameter dntype as char.
    def input parameter dtb as date.
    def input parameter dte as date.

    def buffer b-vccorrecthis for comm.vccorrecthis.
    def buffer b2-vccorrecthis for comm.vccorrecthis.

    for each vccorrecthis where vccorrecthis.bank = v-ourbnk and vccorrecthis.correctdt >= dtb and vccorrecthis.correctdt <= dte no-lock break by vccorrecthis.correctdt:
        if first-of(vccorrecthis.correctdt) then do:
            for each b-vccorrecthis where b-vccorrecthis.bank = v-ourbnk and b-vccorrecthis.correctdt = vccorrecthis.correctdt no-lock break by b-vccorrecthis.docs:
                if first-of(b-vccorrecthis.docs) then do:
                    find vcdocs where vcdocs.docs = b-vccorrecthis.docs no-lock no-error.
                    if not avail vcdocs then next.
                    if not (lookup(vcdocs.dntype,dntype) > 0) then next.
                    run Fdata(vccorrecthis.correctdt).
                    if v-corrinfo <> "" then do:
                        find first vcps where vcps.contract = vcdocs.contract and vcps.dntype = '01' no-lock no-error.
                        create t-dc.
                        t-dc.docs = vcdocs.docs.
                        t-dc.numobyaz = string(vcdocs.numobyaz).
                        t-dc.dndate = vcdocs.dndate.
                        t-dc.pcrc = vcdocs.pcrc.
                        t-dc.sum = vcdocs.sum.
                        if avail vcps then do:
                            t-dc.psnum = vcps.dnnum + string(vcps.num).
                            t-dc.psdate = vcps.dndate.
                        end.
                        t-dc.NAME = NAME.
                        t-dc.COUNTRY = COUNTRY.
                        t-dc.BNAME = BNAME.
                        t-dc.BCOUNTRY = BCOUNTRY.
                        t-dc.PAYDATE = PAYDATE.
                        t-dc.SUMM = string(round(deci(SUMM) / 1000,2),"-zzzzzzzzzzzzzzzzzzzzzzzz9.99") no-error.
                        t-dc.CURR = CURR.
                        t-dc.CODECALC = CODECALC.
                        t-dc.INOUT = INOUT.
                        t-dc.NOTE = NOTE.
                        t-dc.corr = "Корректировка " + v-corrinfo.
                    end.
                end.
            end.
        end.
    end.

end procedure.

procedure RetVal:
    def input parameter opt as char.
    def input parameter id as inte.
    def input parameter dt as date.
    def input parameter nm as char.
    def output parameter val as char.

    def buffer b-vccorrecthis for comm.vccorrecthis.

    if opt = "VCCONTRS" then do:
        find last b-vccorrecthis where b-vccorrecthis.contract = id and b-vccorrecthis.correctdt = dt and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(2,b-vccorrecthis.corrfield,"|").
    end.
    if opt = "VCDOCS" then do:
        find last b-vccorrecthis where b-vccorrecthis.docs = id and b-vccorrecthis.correctdt = dt and b-vccorrecthis.sub = nm no-lock no-error.
        if avail b-vccorrecthis then if index(b-vccorrecthis.corrfield,"|") > 0 then val = entry(2,b-vccorrecthis.corrfield,"|").
    end.
end procedure.

procedure Fdata:
    def input parameter dtcor as date.

    v-corrinfo = "". NAME = "". COUNTRY = "". BNAME = "". BCOUNTRY = "". PAYDATE = "". SUMM = "". CURR = "". CODECALC = "". INOUT = "". NOTE = "".
    if lookup('23', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"NAME",output NAME).
        if NAME <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("NAME",vcdocs.dntype).
            else v-corrinfo = RetAbbr("NAME",vcdocs.dntype).
        end.
    end.
    if lookup('11', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"COUNTRY",output COUNTRY).
        if COUNTRY <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("COUNTRY",vcdocs.dntype).
            else v-corrinfo = RetAbbr("COUNTRY",vcdocs.dntype).
        end.
    end.
    if lookup('24', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"BNAME",output BNAME).
        if BNAME <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("BNAME",vcdocs.dntype).
            else v-corrinfo = RetAbbr("BNAME",vcdocs.dntype).
        end.
    end.
    if lookup('12', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"BCOUNTRY",output BCOUNTRY).
        if BCOUNTRY <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("BCOUNTRY",vcdocs.dntype).
            else v-corrinfo = RetAbbr("BCOUNTRY",vcdocs.dntype).
        end.
    end.
    if lookup('13', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"PAYDATE",output PAYDATE).
        if PAYDATE <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("PAYDATE",vcdocs.dntype).
            else v-corrinfo = RetAbbr("PAYDATE",vcdocs.dntype).
        end.
    end.
    if lookup('14', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"SUMM",output SUMM).
        if SUMM <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("SUMM",vcdocs.dntype).
            else v-corrinfo = RetAbbr("SUMM",vcdocs.dntype).
        end.
    end.
    if lookup('15', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"CURR",output CURR).
        if CURR <> "" then do:
            find txb.ncrc where txb.ncrc.crc = inte(CURR) no-lock no-error.
            if avail txb.ncrc then CURR = txb.ncrc.code.
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CURR",vcdocs.dntype).
            else v-corrinfo = RetAbbr("CURR",vcdocs.dntype).
        end.
    end.
    if lookup('16', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"CODECALC",output CODECALC).
        if CODECALC <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("CODECALC",vcdocs.dntype).
            else v-corrinfo = RetAbbr("CODECALC",vcdocs.dntype).
        end.
    end.
    if lookup('17', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"INOUT",output INOUT).
        if INOUT <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("INOUT",vcdocs.dntype).
            else v-corrinfo = RetAbbr("INOUT",vcdocs.dntype).
        end.
    end.
    if lookup('22', vcdocs.info2[1]) > 0 then do:
        run RetVal("VCDOCS",vcdocs.docs,dtcor,"NOTE",output NOTE).
        if NOTE <> "" then do:
            if v-corrinfo <> "" then v-corrinfo = v-corrinfo + "," + RetAbbr("NOTE",vcdocs.dntype).
            else v-corrinfo = RetAbbr("NOTE",vcdocs.dntype).
        end.
    end.
end procedure.

procedure Cdata:
    def input parameter cttype as char.
    def input parameter dntype as char.
    def input parameter dtb as date.
    def input parameter dte as date.
    def input parameter dtcor as date.

    m1:
    for each vccontrs where vccontrs.bank = v-ourbnk no-lock:
        if lookup(vccontrs.cttype,cttype) = 0 then next m1.
        m2:
        for each vcdocs where vcdocs.contract = vccontrs.contract no-lock:
            if not ( (lookup(vcdocs.dntype,"02,03") > 0 and vcdocs.dndate >= dtb and vcdocs.dndate <= dte) or
                     (lookup(vcdocs.dntype,"17,07") > 0 and vcdocs.rdt >= dtb and vcdocs.rdt <= dte) ) then next m2.

            run Fdata(dtcor).

            if v-corrinfo <> "" then do:
                find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.

                create t-dc.
                t-dc.contract = vccontrs.contract.
                t-dc.docs = vcdocs.docs.
                if lookup(vcdocs.dntype,"02,03") > 0 then t-dc.numobyaz = vcdocs.dnnum.
                if lookup(vcdocs.dntype,"17,07") > 0 then t-dc.numobyaz = string(vcdocs.numobyaz).
                t-dc.dndate = vcdocs.dndate.
                t-dc.pcrc = vcdocs.pcrc.
                t-dc.sum = vcdocs.sum.
                if avail vcps then do:
                    t-dc.psnum = vcps.dnnum + string(vcps.num).
                    t-dc.psdate = vcps.dndate.
                end.
                t-dc.bnkbin = "070940006465".
                t-dc.dtcorrect = vcdocs.dtcorrect.
                t-dc.rdt = vcdocs.rdt.

                t-dc.NAME = NAME.
                t-dc.COUNTRY = COUNTRY.
                t-dc.BNAME = BNAME.
                t-dc.BCOUNTRY = BCOUNTRY.
                t-dc.PAYDATE = PAYDATE.
                t-dc.SUMM = string(round(deci(SUMM) / 1000,2),"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99") no-error.
                t-dc.CURR = CURR.
                t-dc.CODECALC = CODECALC.
                t-dc.INOUT = INOUT.
                t-dc.NOTE = NOTE.
                t-dc.corr = "Корректировка " + v-corrinfo.
            end.
        end.
    end.
end procedure.
