/* vcmsg101.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Прием и раскидывание по контрактам сообщения МТ101 - список фактических ГТД от таможенных органов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-5-1
 * AUTHOR
        11/0/10/2010 aigul - на основе vcmsg101 (переименовала  vcmsg101.p на vcmsg101-f.p).
  * BASES
        BANK COMM TXB

 * CHANGES
        11.01.2011 aigul - поменяла использование таблицы crc на ncrc
        25.01.2011 aigul - расчет к валкон-у через {vc-crosscurs.i}

        К сведению:
        НБРК:
        После тестирования на тестовом сервере, после согласования с Мариной прогружаем новые df для хранения информации
        vcgtdimp.biniin = БИН и ИИН и vcgtdimp.bankbin - БАНКБИН (на тестовом сервере они прогружены) !!!!

        07.04.2011 damir - добавлены v-bankbin,v-bincif,v-iincif,vv-bincif,vv-iincif,vv-bankbin
                           добавлены binbank,bincif,iincif,err1 во временную таблицу wrk-err
                           изменяем проверки на БИН ИИН клиента, и на БИН Банка.
        28.04.2011 damir - поставлены ключи. процедура chbin.i
*/
{mainhead.i}
{vc.i}
{sum2strd.i}
{get-dep.i}
{vc-crosscurs.i}

{chbin.i} /*переход на БИН и ИИН*/

def var v-mtnum as char.
def var v-month as integer.
def var v-year as integer.
def var v-filename as char.
def var v-dirc as char.
def var v-res as char.
def var v-file0 as char init "mt101.uvr".
def var v-file as char init "mt101.txt".
def var v-ipaddr as char.
/*Строки сообщения МТ*/
def var v-str as char.
def var v-ind as integer.
def var v-word as char.
def var v-data as char.
def var v-bankname as char format "x(45)".
def var v-depart as integer.
def var k as int.
def buffer b-vcgtdimp for vcgtdimp.
def var v-status as logic.

def var v-st as char. /*для проверки EXCHANGECONTROLS*/
/*Для сравнения наименования файла*/
def var v-d as char.
def var v-d1 as char.
def var v-d2 AS CHAR.
def var v-d3 AS CHAR.
/*MT*/
def var v-ps AS CHAR. /*Номер ПС*/
def var v-ps-err AS CHAR. /*Номер не найденного ПС*/
def var v-psdt AS char. /*Дата ПС*/
def var v-cif AS CHAR.
def var v-bank AS CHAR.
def var v-bankokpo AS CHAR.
def var v-okpo AS CHAR.
def var v-rnn AS CHAR.
def var vv-okpo AS CHAR.
def var vv-rnn AS CHAR.
def var vv-bincif as char. /*Дамир*/
def var vv-iincif as char. /*Дамир*/
def var vv-bankbin as char. /*Дамир*/
def var v-sign AS CHAR.
def var v-name AS CHAR.
def var v-eisign AS CHAR.
def var v-contract as char.
def var v-cdate AS CHAR.
def var v-order as char.
def var v-statistic as char.
def var v-gtd as char.
def var v-dndate as char.
def var v-sum as char.
def var v-crc as char.
def var v-rate as char.
def var v-bankbin as char. /*Дамир*/
def var v-bincif as char. /*Дамир*/
def var v-iincif as char. /*Дамир*/
def var v-select as char.
def var v-impfile as logical.
def var v-err as char.
def var v-crccrc as int.
DEF VAR v-crccode as char.
def var v-choice as logic.
def var v-choice1 as logic initial no.
def var v-check as logic initial yes.
def var v-check1 as logic initial no.
def var v-check2 as logic initial no.
def var v-check3 as logic initial no.
def var v-check4 as logic initial no.
def var v-check5 as logic initial no.

def var v-temp as logical initial no.
/*Не загруженные ГТР*/
def temp-table wrk-err
    field contract as integer
    field ps as char format "x(12)"
    field psdt as date
    field bankokpo as char
    field cif as char
    field cifname as char
    field cifokpo as char
    field rnn as char
    field gtd as char format "x(19)"
    field dndate as date
    field crccode as char
    field sum as decimal
    field err as char format "x(50)"
    field payret as logi
    field cursdoc-con as decimal
    field rwho as char
    field rdt as date
    field uwho as char
    field udt as date
    field bincif as char
    field iincif as char
    field binbank as char
    field err1 as char format "x(50)".
/*Найденные ГТД*/
def temp-table wrk
    field contract as integer
    field ps as char format "x(12)"
    field psdt as date
    field dnnum as char format "x(19)"
    field dndate as date
    field pcrc as int
    field sum as decimal format ">>>,>>>,>>9.99"
    field cursdoc-con as decimal
    field rdt as date
    field rwho as char.
/*Прогруженные ГТД из МТ в БД*/
def temp-table wrk-ok
    field cif as char
    field cifokpo as char
    field cifname as char
    field ps as char format "x(12)"
    field psdt as date
    field dntype as char
    field dndate as date
    field dnnum as char format "x(19)"
    field bankokpo as char
    field pcrc as int
    field sum as decimal format ">>>,>>>,>>9.99"
    field payret as logic
    field rdt as date
    field rwho as char
    field udt as date
    field uwho as char
    field origin as logi
    field cursdoc-con as decimal
    field reason as char.
/*Вывод ПС с МТ и ПС с бд*/
def temp-table t-qarc /*ГТ из vcdocs*/
    field fps as char
    field fpsdt as date
    field fgtd as char
    field fdate as date
    field cif as char
    field cifokpo as char
    field cifname as char
    field dntype as char
    field bankokpo as char
    field crc as char
    field cursdoc-con as decimal
    field sum as decimal
    field payret as logic
    field rdt as date
    field rwho as char
    field kurs as char.

def temp-table t-qin /*ГТ из МТ*/
    field fps as char
    field fpsdt as date
    field fgtd as char
    field fdate as date
    field cif as char
    field cifokpo as char
    field cifname as char
    field dntype as char
    field bankokpo as char
    field crc as char
    field sum as decimal
    field payret as logic
    field cursdoc-con as decimal
    field rdt as date
    field rwho as char
    field kurs as char
    field loaded as logic.
/*ГТД из vcdocs*/
def temp-table wrk-docs
    field dnnum as char
    field dndate as date
    field dntype as char
    field crc as char
    field sum as decimal
    field payret as logic
    field cursdoc-con as decimal
    field rdt as date
    field rwho as char
    field udt as date
    field uwho as char.

/*ГТД из vcdocs для замены*/
def new shared var f-name as cha.
def var i as int .
def var j as int .
def var method-return as logical.



def var v-tar as cha view-as selection-list
  INNER-CHARS 50 INNER-LINES 12 SORT  .
def frame ftar v-tar with title  f-name  no-label column 10 row 3 .

def frame fhelp "<F1> - Показать ГТД    <Tab> - Переход в другое окно    <Ins> - Добавить, как новое ГТД   "
  with width 90 row 18 column 4 no-box.
def frame fhelp1 "<C> - Вывести отчет    <R> - Заменить ГТД    <O> - Открыть МТ файл  "
  with width 90 row 19 column 4 no-box.

def query qarc for t-qarc.
def query qin  for t-qin.

def browse barc
    query qarc no-lock
    display
        t-qarc.fps  format "x(15)"
        t-qarc.fpsdt  format "99/99/9999"
        t-qarc.fgtd  format "x(19)"
        t-qarc.fdate format "99/99/9999"
    with 14 down width 50 title "Найденные ГТД по ПС" no-labels.

def browse bin
    query qin no-lock
    display
        t-qin.fps  format "x(15)"
        t-qin.fpsdt  format "99/99/9999"
        t-qin.fgtd  format "x(19)"
        t-qin.fdate  format "99/99/9999"
    with 14 down width 49 title "ГТД из МТ" no-labels.

def query qdocs for wrk-docs.
def browse bdocs
    query qdocs no-lock
    display
        wrk-docs.dntype format "x(3)" label "Тип"
        wrk-docs.dnnum format "x(19)" label "Номер"
        wrk-docs.dndate format "99/99/9999" label "Дата"
        wrk-docs.crc format "x(3)" label "Вал"
        wrk-docs.sum format ">>>,>>>,>>9.99" label "Сумма"
        wrk-docs.payret label "Возврат"
        wrk-docs.cursdoc-con label "Курс"
        wrk-docs.rdt format "99/99/9999" label "Дата рег"
        wrk-docs.rwho label "Зарегистр"
        /*wrk-docs.udt format "99/99/9999" label "Дата измен"
        wrk-docs.uwho label "Изменил"*/
    with 5 down no-labels.

def frame farcch
    barc help ""
  with width 50 COLUMN 51 no-label  row 2 NO-BOX.

def frame fin
    bin help ""
  with width 49 COLUMN 1 no-label  row 2 NO-BOX.

def frame fdocs
    bdocs help ""
  with width 99  COLUMN 1 no-label  row 27 NO-BOX.

on tab of barc in frame farcch do:
 disable barc with frame farcch.
 enable bin with frame fin.
end.

on tab of bin in frame fin do:
 disable bin with frame fin.
 enable barc with frame farcch.
end.

on tab of bdocs in frame fdocs do:
 disable bdocs with frame fdocs.
 enable bin with frame fin.
end.

def stream rep-ok.
def stream rep-err.
empty temp-table wrk-err.
empty temp-table wrk-ok.

/*Вывод Мт на дату*/
v-month = month(g-today).
v-year = year(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-year = v-year - 1.
end.
else v-month = v-month - 1.
update v-month label " Месяц" format "99"
       v-year  label "   Год" format "9999"
       with centered row 5 side-label.

find vcparams where vcparams.parcode = "mtext" no-lock no-error.
v-filename = string(v-year, "9999") + string(v-month, "99") + "." + vcparams.valchar.

find vcparams where vcparams.parcode = "mtpth101" no-lock no-error.
v-dirc = vcparams.valchar.
v-ipaddr = "Administrator@fs01".
/*
v-dirc = "C:/VC101/".
v-ipaddr =  " Administrator@`askhost`".
*/
input through value("scp -q " + v-ipaddr + ":" + v-dirc + v-filename + " " + v-file0 + ";echo $?").
   repeat:
      import unformatted v-res.
   end.
if v-res <> "0" then message " Файл " v-dirc + v-filename " не найден!"  view-as alert-box.

/*checking the date and filename*/
/*if v-res = "0" then do:*/
    v-word = "".
    v-data = "".
    input from value(v-file0).
    readdata:
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        if v-str = "-}" then leave.
        if v-str begins ":20:" then v-mtnum = substr(v-str,5,17).
        if v-str matches "*EXCHANGECONTROLS*" then v-st = v-str.
        if (substr(v-str, 1, 1) <> "/") and (v-word <> "NOTE") then next readdata.
        if (substr(v-str, 1, 1) = "/") then do:
        chng:
            repeat:
                v-str = substr(v-str, 2).
                if substr(v-str, 1, 1) <> "/" then leave chng.
            end.
        v-ind = index(v-str, "/").
        v-word = substr(v-str, 1, v-ind - 1).
        v-data = substr(v-str, v-ind + 1).
        end.
        else v-data = v-str.
        if v-word = "REPORTMONTH" then v-d1 = v-data.
    end.
    input close.
    if v-st matches "*101" then v-status = true.
    else do:
        message "Сообщение с ключевым слово 'EXCHANGECONTROLS/101' не найдено!" view-as alert-box.
        v-status = false.
        return.
    end.
    v-d2 = substr(v-d1,1,2).
    v-d3 = substr(v-d1,3,4).
    v-d = v-d3 + v-d2.
    if v-d = substr(v-filename,1,6) then v-status = true.
    else do:
        message skip " Название файла" v-filename "не соответствует периоду сообщения :" skip
        v-d skip(1) view-as alert-box button ok title " ОШИБКА ! ".
        v-status = false.
        return.
    end.
/*end.*/



/*assign a value*/
v-impfile = no.

find first vcgtdimp where vcgtdimp.mtnum = v-mtnum no-lock no-error.
if avail vcgtdimp then do:
    run sel (" Сообщение " + v-filename + " уже было загружено !",
    " 1. Повторить загрузку полностью | 2. ВЫХОД ").
    v-select = return-value.

    if v-select = "2" then return.

    if v-select = "1" then do:
        for each vcgtdimp where vcgtdimp.mtnum = v-mtnum exclusive-lock:
            delete vcgtdimp.
            v-impfile = yes.
        end.
    end.
end.
else v-impfile = yes.

if v-impfile = no then do:
    message " Сообщение: " + v-filename + " со значением 20-го поля: " + v-mtnum + " уже было загружено !" view-as alert-box.
    return.
end.
if v-impfile then do:
    for each vcgtdimp exclusive-lock:
        delete vcgtdimp.
    end.
    for each vcgtdimp no-lock.
    end.
    input from value(v-file0).
    v-word = "".
    v-data = "".
    readdata:
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        if v-str = "-}" then leave.
        if (substr(v-str, 1, 1) <> "/") and (v-word <> "NOTE") then next readdata.
        if (substr(v-str, 1, 1) = "/") then do:
            chng:
            repeat:
                v-str = substr(v-str, 2).
                if substr(v-str, 1, 1) <> "/" then leave chng.
            end.
            v-ind = index(v-str, "/").
            v-word = substr(v-str, 1, v-ind - 1).
            v-data = substr(v-str, v-ind + 1).
        end.
        else v-data = v-str.
        if v-bin = no then do: /*Дамир, пока не перешли на БИН и ИИН*/
            case v-word:
                when "REPORTMONTH" then do: end.
                when "PS" then v-ps = v-data.
                when "PSDATE" then v-psdt = v-data.
                when "BANKOKPO" then v-bankokpo = v-data.
                when "EISIGN" then v-eisign = v-data.
                when "CONTRACT" then v-contract = v-data.
                when "CDATE" then v-cdate = v-data.
                when "OKPO" then v-okpo = v-data.
                when "RNN" then v-rnn = v-data.
                when "NAME" then v-name = v-data.
                when "SIGN" then v-sign = v-data.
                when "GTD" then v-gtd = v-data.
                when "ORDER"  then v-order = v-data.
                when "ISSUEDATE" then v-dndate = v-data.
                when "STATISTIC" then v-statistic = v-data.
                when "INVOICESUMM" then v-sum = v-data.
                when "INVOICECURR" then v-crc = v-data.
                when "RATE" then do:
                    v-rate = v-data.
                    find first vccontrs where vccontrs.ctnum = v-contract
                    and vccontrs.ctdate = date(substr(v-cdate,1,2) + substr(v-cdate,4,2) + substr(v-cdate,7,4)) no-lock no-error.
                    if avail vccontrs then do:
                        find first vcps where vcps.contract = vccontrs.contract and vcps.dnnum = substr(v-ps,1,11) and vcps.num = integer(substr(v-ps,12,2))
                        and vcps.dndate = date(v-psdt) and vcps.dntype = "01" no-lock no-error.
                        if  avail vcps then do:
                            find first txb where txb.bank = vccontrs.bank and txb.params matches "*" + v-bankokpo and txb.consolid no-lock no-error.
                            if avail txb then do:
                                v-bank = txb.bank.
                                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                                run vcmsg101_cif (vccontrs.cif,v-sign, output vv-okpo, output vv-rnn).
                                disconnect txb.
                                if v-sign = "1" then do:
                                    if substr(v-okpo,9,4) = "0000" then do:
                                        if substr(v-okpo,1,8) = vv-okpo then v-status = yes.
                                        else v-status = no.
                                    end.
                                    else do:
                                        if v-okpo = vv-okpo then v-status = yes.
                                        else v-status = no.
                                    end.
                                end.
                                if v-sign = "2" then do:
                                    if v-rnn = vv-rnn then v-status = yes.
                                    else v-status = no.
                                end.
                                create vcgtdimp.
                                assign
                                vcgtdimp.mtnum = v-mtnum.
                                vcgtdimp.mtdte = g-today.
                                vcgtdimp.mtdtb = g-today.
                                vcgtdimp.bank = v-bank.
                                vcgtdimp.cif = vccontrs.cif.
                                vcgtdimp.contract = 1.
                                vcgtdimp.bankokpo = v-bankokpo.
                                vcgtdimp.psnum = v-ps.
                                vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,4,2) + substr(v-psdt,7,4)).
                                if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E".
                                if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I".
                                vcgtdimp.cifname = v-name.
                                vcgtdimp.cifsign = integer(v-sign).
                                vcgtdimp.dnnum = v-gtd.
                                vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                                vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                                vcgtdimp.payret = no.
                                vcgtdimp.crccode = v-crc.
                                vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                vcgtdimp.rdt = g-today.
                                vcgtdimp.rwho = g-ofc.
                                if v-status = no then vcgtdimp.note = "ошибка в данных".
                                if v-status = no then do:
                                    create wrk-err.
                                    assign
                                    wrk-err.bankokpo = v-bankokpo.
                                    wrk-err.cifokpo = v-okpo.
                                    wrk-err.rnn = v-rnn.
                                    find first vcgtdimp where vcgtdimp.cifokpo = wrk-err.cifokpo or vcgtdimp.cifokpo = wrk-err.rnn no-lock no-error.
                                    if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                                    wrk-err.cifname = v-name.
                                    wrk-err.ps = v-ps.
                                    wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                    wrk-err.gtd = v-gtd.
                                    wrk-err.dndate = date(v-dndate).
                                    wrk-err.crccode = v-crc.
                                    wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                    wrk-err.err = "Не совпадение РНН или ОКПО".
                                    wrk-err.cursdoc-con = decimal(v-rate).
                                end.
                            end.
                            else do:
                                create wrk-err.
                                assign
                                wrk-err.bankokpo = v-bankokpo
                                wrk-err.cifokpo = v-okpo
                                wrk-err.rnn = v-rnn.
                                find first vcgtdimp where vcgtdimp.cifokpo = wrk-err.cifokpo or vcgtdimp.cifokpo = wrk-err.rnn no-lock no-error.
                                if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                                wrk-err.cifname = v-name.
                                wrk-err.ps = v-ps.
                                wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                wrk-err.gtd = v-gtd.
                                wrk-err.dndate = date(v-dndate).
                                wrk-err.crccode = v-crc.
                                wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                wrk-err.err = " В ГТД указан ОКПО не нашего банка !!! ".
                                wrk-err.cursdoc-con = decimal(v-rate).
                                create vcgtdimp.
                                assign
                                vcgtdimp.mtnum = v-mtnum.
                                vcgtdimp.mtdte = g-today.
                                vcgtdimp.mtdtb = g-today.
                                vcgtdimp.bank = v-bank.
                                vcgtdimp.cif = vccontrs.cif.
                                vcgtdimp.contract = 1.
                                vcgtdimp.bankokpo = v-bankokpo.
                                vcgtdimp.psnum = v-ps.
                                vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E".
                                if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I".
                                vcgtdimp.cifname = v-name.
                                vcgtdimp.cifsign = integer(v-sign).
                                vcgtdimp.dnnum = v-gtd.
                                vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                                vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                                vcgtdimp.payret = no.
                                vcgtdimp.crccode = v-crc.
                                vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                vcgtdimp.rdt = g-today.
                                vcgtdimp.rwho = g-ofc.
                                vcgtdimp.note = "В ГТД указан ОКПО не нашего банка".
                            end.
                        end.
                        else do:
                            create wrk-err.
                            assign
                            wrk-err.bankokpo = v-bankokpo
                            wrk-err.cifokpo = v-okpo
                            wrk-err.rnn = v-rnn.
                            find first vcgtdimp where vcgtdimp.cifokpo = wrk-err.cifokpo or vcgtdimp.cifokpo = wrk-err.rnn no-lock no-error.
                            if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                            wrk-err.cifname = v-name.
                            wrk-err.ps = v-ps.
                            wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                            wrk-err.gtd = v-gtd.
                            wrk-err.dndate = date(v-dndate).
                            wrk-err.crccode = v-crc.
                            wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                            wrk-err.err = " Не найден ПС !".
                            wrk-err.cursdoc-con = decimal(v-rate).
                            create vcgtdimp.
                            assign
                            vcgtdimp.mtnum = v-mtnum.
                            vcgtdimp.mtdte = g-today.
                            vcgtdimp.mtdtb = g-today.
                            vcgtdimp.bank = v-bank.
                            /*vcgtdimp.cif = vccontrs.cif.*/
                            vcgtdimp.contract = 1.
                            vcgtdimp.bankokpo = v-bankokpo.
                            vcgtdimp.psnum = v-ps.
                            vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                            if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E".
                            if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I".
                            vcgtdimp.cifname = v-name.
                            vcgtdimp.cifsign = integer(v-sign).
                            vcgtdimp.dnnum = v-gtd.
                            vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                            vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                            vcgtdimp.payret = no.
                            vcgtdimp.crccode = v-crc.
                            vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                            vcgtdimp.rdt = g-today.
                            vcgtdimp.rwho = g-ofc.
                            if v-status = no then vcgtdimp.note = "Не найден ПС ".
                        end.
                    end. /*контракт*/
                    else do:
                        create wrk-err.
                        assign
                        wrk-err.bankokpo = v-bankokpo
                        wrk-err.cifokpo = v-okpo
                        wrk-err.rnn = v-rnn.
                        find first vcgtdimp where vcgtdimp.cifokpo = wrk-err.cifokpo or vcgtdimp.cifokpo = wrk-err.rnn no-lock no-error.
                        if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                        wrk-err.cifname = v-name.
                        wrk-err.ps = v-ps.
                        wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                        wrk-err.gtd = v-gtd.
                        wrk-err.dndate = date(v-dndate).
                        wrk-err.crccode = v-crc.
                        wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                        wrk-err.err = " Не найден Контракт !".
                        wrk-err.cursdoc-con = decimal(v-rate).
                        create vcgtdimp.
                        assign
                        vcgtdimp.mtnum = v-mtnum.
                        vcgtdimp.mtdte = g-today.
                        vcgtdimp.mtdtb = g-today.
                        vcgtdimp.bank = v-bank.
                        vcgtdimp.contract = 1.
                        vcgtdimp.bankokpo = v-bankokpo.
                        vcgtdimp.psnum = v-ps.
                        vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                        if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E".
                        if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I".
                        vcgtdimp.cifname = v-name.
                        vcgtdimp.cifsign = integer(v-sign).
                        vcgtdimp.dnnum = v-gtd.
                        vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                        vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                        vcgtdimp.payret = no.
                        vcgtdimp.crccode = v-crc.
                        vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                        vcgtdimp.rdt = g-today.
                        vcgtdimp.rwho = g-ofc.
                        if v-status = no then vcgtdimp.note = " Не найден Контракт ".
                    end.
                end. /*when rate*/
            end. /*case*/
        end. /*БИН и ИИН, переключатель*/
        if v-bin = yes then do: /*Дамир, перешли на БИН и ИИН*/
            case v-word:
                when "REPORTMONTH" then do: end.
                when "PS" then v-ps = v-data.
                when "PSDATE" then v-psdt = v-data.
                when "BANKOKPO" then v-bankokpo = v-data.
                when "BANKBIN" then v-bankbin = v-data.
                when "EISIGN" then v-eisign = v-data.
                when "CONTRACT" then v-contract = v-data.
                when "CDATE" then v-cdate = v-data.
                when "OKPO" then v-okpo = v-data.
                when "RNN" then v-rnn = v-data.
                when "BIN" then v-bincif = v-data.
                when "IIN" then v-iincif = v-data.
                when "NAME" then v-name = v-data.
                when "SIGN" then v-sign = v-data.
                when "GTD" then v-gtd = v-data.
                when "ORDER"  then v-order = v-data.
                when "ISSUEDATE" then v-dndate = v-data.
                when "STATISTIC" then v-statistic = v-data.
                when "INVOICESUMM" then v-sum = v-data.
                when "INVOICECURR" then v-crc = v-data.
                when "RATE" then do:
                    v-rate = v-data.
                    find first vccontrs where vccontrs.ctnum = v-contract
                    and vccontrs.ctdate = date(substr(v-cdate,1,2) + substr(v-cdate,4,2) + substr(v-cdate,7,4)) no-lock no-error.
                    if avail vccontrs then do:
                        find first vcps where vcps.contract = vccontrs.contract and vcps.dnnum = substr(v-ps,1,11) and vcps.num = integer(substr(v-ps,12,2))
                        and vcps.dndate = date(v-psdt) and vcps.dntype = "01" no-lock no-error.
                        if  avail vcps then do:
                            find first txb where txb.bank = vccontrs.bank and txb.params matches "*" + v-bankbin and txb.consolid no-lock no-error.
                            if avail txb then do:
                                v-bank = txb.bank.
                                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                                run vcmsg101_cif (vccontrs.cif,v-sign, output vv-okpo, output vv-rnn, output vv-bincif, output vv-iincif). /*Дамир*/
                                disconnect txb.
                                if v-sign = "1" then do:
                                    if substr(v-okpo,9,4) = "0000" then do:
                                        if substr(v-okpo,1,8) = vv-okpo then v-status = yes.
                                        else v-status = no.
                                    end.
                                    else do:
                                        if v-okpo = vv-okpo then v-status = yes.
                                        else v-status = no.
                                    end.
                                    if v-bincif = vv-bincif then v-status = yes.
                                    else v-status = no. /*Дамир*/
                                end.
                                if v-sign = "2" then do:
                                    if v-rnn = vv-rnn then v-status = yes.
                                    else v-status = no.
                                    if v-iincif = vv-iincif then v-status = yes.
                                    else v-status = no. /*Дамир*/
                                end.
                                create vcgtdimp.
                                assign
                                vcgtdimp.mtnum = v-mtnum.
                                vcgtdimp.mtdte = g-today.
                                vcgtdimp.mtdtb = g-today.
                                vcgtdimp.bank = v-bank.
                                vcgtdimp.cif = vccontrs.cif.
                                vcgtdimp.contract = 1.
                                vcgtdimp.bankokpo = v-bankokpo.
                                vcgtdimp.bankbin = v-bankbin. /*Дамир*/
                                vcgtdimp.psnum = v-ps.
                                vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,4,2) + substr(v-psdt,7,4)).
                                if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E" vcgtdimp.biniin = v-bincif. /*Дамир*/
                                if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I" vcgtdimp.biniin = v-iincif. /*Дамир*/
                                vcgtdimp.cifname = v-name.
                                vcgtdimp.cifsign = integer(v-sign).
                                vcgtdimp.dnnum = v-gtd.
                                vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                                vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                                vcgtdimp.payret = no.
                                vcgtdimp.crccode = v-crc.
                                vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                vcgtdimp.rdt = g-today.
                                vcgtdimp.rwho = g-ofc.
                                if v-status = no then vcgtdimp.note = "ошибка в данных".
                                if v-status = no then do:
                                    create wrk-err.
                                    assign
                                    wrk-err.bankokpo = v-bankokpo.
                                    wrk-err.cifokpo = v-okpo.
                                    wrk-err.rnn = v-rnn.
                                    wrk-err.bincif = v-bincif. /*Дамир*/
                                    wrk-err.iincif = v-iincif. /*Дамир*/
                                    wrk-err.binbank = v-bankbin. /*Дамир*/
                                    find first vcgtdimp where vcgtdimp.biniin = wrk-err.bincif or vcgtdimp.biniin = wrk-err.iincif no-lock no-error. /*Дамир добавил поиск по БИН и ИИН*/
                                    if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                                    wrk-err.cifname = v-name.
                                    wrk-err.ps = v-ps.
                                    wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                    wrk-err.gtd = v-gtd.
                                    wrk-err.dndate = date(v-dndate).
                                    wrk-err.crccode = v-crc.
                                    wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                    wrk-err.err = "Не совпадение БИН или ИИН". /*Дамир*/
                                    wrk-err.cursdoc-con = decimal(v-rate).
                                end.
                            end.
                            else do:
                                create wrk-err.
                                assign
                                wrk-err.bankokpo = v-bankokpo
                                wrk-err.cifokpo = v-okpo
                                wrk-err.rnn = v-rnn
                                wrk-err.bincif = v-bincif /*Дамир*/
                                wrk-err.iincif = v-iincif /*Дамир*/
                                wrk-err.binbank = v-bankbin. /*Дамир*/
                                find first vcgtdimp where vcgtdimp.biniin = wrk-err.bincif or vcgtdimp.biniin = wrk-err.iincif no-lock no-error. /*Дамир добавил поиск по БИН и ИИН*/
                                if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                                wrk-err.cifname = v-name.
                                wrk-err.ps = v-ps.
                                wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                wrk-err.gtd = v-gtd.
                                wrk-err.dndate = date(v-dndate).
                                wrk-err.crccode = v-crc.
                                wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                wrk-err.err = " В ГТД указан БИН не нашего банка !!! ". /*Дамир*/
                                wrk-err.cursdoc-con = decimal(v-rate).
                                create vcgtdimp.
                                assign
                                vcgtdimp.mtnum = v-mtnum.
                                vcgtdimp.mtdte = g-today.
                                vcgtdimp.mtdtb = g-today.
                                vcgtdimp.bank = v-bank.
                                vcgtdimp.cif = vccontrs.cif.
                                vcgtdimp.contract = 1.
                                vcgtdimp.bankokpo = v-bankokpo.
                                vcgtdimp.psnum = v-ps.
                                vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                                if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E" vcgtdimp.biniin = v-bincif. /*Дамир*/
                                if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I" vcgtdimp.biniin = v-iincif. /*Дамир*/
                                vcgtdimp.cifname = v-name.
                                vcgtdimp.cifsign = integer(v-sign).
                                vcgtdimp.dnnum = v-gtd.
                                vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                                vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                                vcgtdimp.payret = no.
                                vcgtdimp.crccode = v-crc.
                                vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                                vcgtdimp.rdt = g-today.
                                vcgtdimp.rwho = g-ofc.
                                vcgtdimp.note = "В ГТД указан БИН не нашего банка". /*Дамир*/
                            end.
                        end.
                        else do:
                            create wrk-err.
                            assign
                            wrk-err.bankokpo = v-bankokpo
                            wrk-err.cifokpo = v-okpo
                            wrk-err.rnn = v-rnn
                            wrk-err.bincif = v-bincif /*Дамир*/
                            wrk-err.iincif = v-iincif /*Дамир*/
                            wrk-err.binbank = v-bankbin. /*Дамир*/
                            find first vcgtdimp where vcgtdimp.biniin = wrk-err.bincif or vcgtdimp.biniin = wrk-err.iincif no-lock no-error. /*Дамир добавил поиск по БИН и ИИН*/
                            if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                            wrk-err.cifname = v-name.
                            wrk-err.ps = v-ps.
                            wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                            wrk-err.gtd = v-gtd.
                            wrk-err.dndate = date(v-dndate).
                            wrk-err.crccode = v-crc.
                            wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                            wrk-err.err = " Не найден ПС !".
                            wrk-err.cursdoc-con = decimal(v-rate).
                            create vcgtdimp.
                            assign
                            vcgtdimp.mtnum = v-mtnum.
                            vcgtdimp.mtdte = g-today.
                            vcgtdimp.mtdtb = g-today.
                            vcgtdimp.bank = v-bank.
                            /*vcgtdimp.cif = vccontrs.cif.*/
                            vcgtdimp.contract = 1.
                            vcgtdimp.bankokpo = v-bankokpo.
                            vcgtdimp.psnum = v-ps.
                            vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                            if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E" vcgtdimp.biniin = v-bincif. /*Дамир*/
                            if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I" vcgtdimp.biniin = v-iincif. /*Дамир*/
                            vcgtdimp.cifname = v-name.
                            vcgtdimp.cifsign = integer(v-sign).
                            vcgtdimp.dnnum = v-gtd.
                            vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                            vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                            vcgtdimp.payret = no.
                            vcgtdimp.crccode = v-crc.
                            vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                            vcgtdimp.rdt = g-today.
                            vcgtdimp.rwho = g-ofc.
                            if v-status = no then vcgtdimp.note = "Не найден ПС ".
                        end.
                    end.
                    else do:
                        create wrk-err.
                        assign
                        wrk-err.bankokpo = v-bankokpo
                        wrk-err.cifokpo = v-okpo
                        wrk-err.rnn = v-rnn
                        wrk-err.bincif = v-bincif /*Дамир*/
                        wrk-err.iincif = v-iincif /*Дамир*/
                        wrk-err.binbank = v-bankbin. /*Дамир*/
                        find first vcgtdimp where vcgtdimp.biniin = wrk-err.bincif or vcgtdimp.biniin = wrk-err.iincif no-lock no-error. /*Дамир добавил поиск по БИН и ИИН*/
                        if avail vcgtdimp then wrk-err.cif = vcgtdimp.cif.
                        wrk-err.cifname = v-name.
                        wrk-err.ps = v-ps.
                        wrk-err.psdt = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                        wrk-err.gtd = v-gtd.
                        wrk-err.dndate = date(v-dndate).
                        wrk-err.crccode = v-crc.
                        wrk-err.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                        wrk-err.err = " Не найден Контракт !".
                        wrk-err.cursdoc-con = decimal(v-rate).
                        create vcgtdimp.
                        assign
                        vcgtdimp.mtnum = v-mtnum.
                        vcgtdimp.mtdte = g-today.
                        vcgtdimp.mtdtb = g-today.
                        vcgtdimp.bank = v-bank.
                        vcgtdimp.contract = 1.
                        vcgtdimp.bankokpo = v-bankokpo.
                        vcgtdimp.psnum = v-ps.
                        vcgtdimp.psdate = date(substr(v-psdt,1,2) + substr(v-psdt,3,2) + substr(v-psdt,5,4)).
                        if v-sign = '1' then assign vcgtdimp.cifokpo = substr(v-okpo,1,8) vcgtdimp.expimp = "E" vcgtdimp.biniin = v-bincif. /*Дамир*/
                        if v-sign = '2' then assign vcgtdimp.cifokpo = v-rnn  vcgtdimp.expimp = "I" vcgtdimp.biniin = v-iincif. /*Дамир*/
                        vcgtdimp.cifname = v-name.
                        vcgtdimp.cifsign = integer(v-sign).
                        vcgtdimp.dnnum = v-gtd.
                        vcgtdimp.dndate = date(substr(v-dndate,1,2) + substr(v-dndate,3,2) + substr(v-dndate,5,4)).
                        vcgtdimp.dnrate = decimal(entry(1, v-rate) + "." + entry(2, v-rate)).
                        vcgtdimp.payret = no.
                        vcgtdimp.crccode = v-crc.
                        vcgtdimp.sum = decimal(entry(1, v-sum) + "." + entry(2, v-sum)).
                        vcgtdimp.rdt = g-today.
                        vcgtdimp.rwho = g-ofc.
                        if v-status = no then vcgtdimp.note = " Не найден Контракт ".
                    end.
                end. /*when rate*/
            end. /*case*/
        end. /*БИН и ИИН переключатель*/
    end. /*repeat*/
    input close.

    for each vcgtdimp where vcgtdimp.mtnum = v-mtnum exclusive-lock:
        find first vcps where vcps.dnnum = substr(vcgtdimp.psnum,1,11) and vcps.num = integer(substr(vcgtdimp.psnum,12,2))
        and vcps.dndate = vcgtdimp.psdate no-lock no-error.
        if  avail vcps then vcgtdimp.contract = vcps.contract.
    end.
    for each  vcgtdimp where vcgtdimp.mtnum = v-mtnum no-lock.
    end.
    for each wrk-err exclusive-lock:
        find first vcps where vcps.dnnum = substr(wrk-err.ps,1,11) and vcps.num = integer(substr(wrk-err.ps,12,2))
        and vcps.dndate = wrk-err.psdt no-lock no-error.
        if  avail vcps then wrk-err.contract = vcps.contract.
    end.
end. /*v-impfile*/

def var v-avail as logic INITIAL YES.
def var v-temp1 as logic INITIAL YES.

/*Поиск ГТД*/
v-crccrc = 0.
empty temp-table wrk.
for each vcgtdimp where vcgtdimp.mtnum = v-mtnum no-lock:
    find first ncrc where ncrc.code = vcgtdimp.crccode no-lock no-error.
    if avail ncrc then v-crccrc = ncrc.crc.
    find first vcps where vcps.dnnum = substr(vcgtdimp.psnum,1,11) and vcps.num = integer(substr(vcgtdimp.psnum,12,2))
    and vcps.dndate = vcgtdimp.psdate no-lock no-error.
    if  avail vcps then do:
        /*прогруженные ПС*/
        find first vcdocs where vcdocs.contract = vcps.contract and
        vcdocs.dnnum = vcgtdimp.dnnum and vcdocs.dndate = vcgtdimp.dndate and vcdocs.pcrc = v-crccrc
        and vcdocs.sum = vcgtdimp.sum and vcdocs.payret = vcgtdimp.payret and vcdocs.dntype = "14"
        /*and vcdocs.cursdoc-con = vcgtdimp.dnrate*/ no-lock no-error.
        if avail vcdocs then do:
                create wrk-err.
                assign
                wrk-err.contract = vcgtdimp.contract.
                wrk-err.bankokpo = vcgtdimp.bankokpo.
                wrk-err.cifokpo = vcgtdimp.cifokpo.
                wrk-err.cif = vcgtdimp.cif.
                wrk-err.cifname = vcgtdimp.cifname.
                wrk-err.ps = vcgtdimp.psnum.
                wrk-err.psdt = vcgtdimp.psdate.
                wrk-err.gtd = vcgtdimp.dnnum.
                wrk-err.dndate = vcgtdimp.dndate.
                wrk-err.crccode = vcgtdimp.crccode.
                wrk-err.sum =vcgtdimp.sum.
                wrk-err.err = " Данная ГТД уже прогруженa в бд !".
                wrk-err.cursdoc-con = vcgtdimp.dnrate.
                wrk-err.payret = vcgtdimp.payret.
        end.
        /*Найденные ПС с неидентичными полями*/
        find first vcdocs where vcdocs.contract = vcps.contract and  vcdocs.dntype = "14"
        and vcdocs.dnnum = vcgtdimp.dnnum and (vcdocs.dndate <> vcgtdimp.dndate or vcdocs.pcrc <> v-crccrc
        or vcdocs.sum <> vcgtdimp.sum or vcdocs.payret <> vcgtdimp.payret /*or vcdocs.cursdoc-con <> vcgtdimp.dnrate*/) no-lock no-error.
        if avail vcdocs then do:
            find first wrk-err where wrk-err.contract = vcdocs.contract no-lock no-error.
            if not avail wrk-err then do:
                create wrk.
                wrk.contract = vcgtdimp.contract.
                wrk.ps = vcgtdimp.psnum.
                wrk.psdt = vcgtdimp.psdate.
                wrk.dnnum = vcgtdimp.dnnum.
                wrk.dndate = vcgtdimp.dndate.
                wrk.pcrc = v-crccrc.
                wrk.sum = vcgtdimp.sum.
                wrk.cursdoc-con = vcgtdimp.dnrate.
                wrk.rdt = vcgtdimp.rdt.
                wrk.rwho = vcgtdimp.rwho.
            end.
        end.
        /*ПС с новым ГТД*/
        find first vcdocs where vcdocs.contract = vcgtdimp.contract and
        vcdocs.dnnum = vcgtdimp.dnnum and (vcdocs.dndate = vcgtdimp.dndate
        or vcdocs.pcrc = v-crccrc or vcdocs.sum = vcgtdimp.sum or vcdocs.payret = vcgtdimp.payret or vcdocs.dntype = "14"
        /*or vcdocs.cursdoc-con = vcgtdimp.dnrate*/) no-lock no-error.
        if not avail vcdocs then do:
            create vcdocs.
            vcdocs.docs = next-value(vc-docs).
            vcdocs.contract = vcgtdimp.contract.
            vcdocs.dntype = "14".
            vcdocs.dnnum = vcgtdimp.dnnum.
            vcdocs.dndate = vcgtdimp.dndate.
            vcdocs.pcrc = v-crccrc.
            vcdocs.sum = vcgtdimp.sum.
            vcdocs.payret = vcgtdimp.payret.
            /*vcdocs.cursdoc-con = vcgtdimp.dnrate.*/
            vcdocs.cursdoc-con = 1.
            vcdocs.origin = no.
            vcdocs.rdt = g-today.
            vcdocs.rwho = g-ofc.
            find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
            if vccontrs.ncrc <> vcdocs.pcrc then
            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
            create wrk-ok.
            wrk-ok.cif = vcgtdimp.cif.
            wrk-ok.cifokpo = vcgtdimp.cifokpo.
            wrk-ok.cifname = vcgtdimp.cifname.
            wrk-ok.ps = vcgtdimp.psnum.
            wrk-ok.psdt = vcgtdimp.psdate.
            wrk-ok.dntype = "14".
            wrk-ok.dnnum = vcgtdimp.dnnum.
            wrk-ok.dndate = vcgtdimp.dndate.
            wrk-ok.pcrc = v-crccrc.
            wrk-ok.sum = vcgtdimp.sum.
            wrk-ok.payret = vcgtdimp.payret.
            wrk-ok.cursdoc-con = vcgtdimp.dnrate.
            wrk-ok.origin = no.
            wrk-ok.rdt = g-today.
            wrk-ok.rwho = g-ofc.
            wrk-ok.reason = "Полный прогруз ГТД".
        end.
    end.
end.
find first wrk no-lock no-error.
if not avail wrk then v-temp = yes.
if v-temp = yes then do:
    find first wrk no-lock no-error.
    if not avail wrk then do:
        output stream rep-err to errs.htm.
        {html-title.i &stream = "stream rep-err" &size-add = "xx-"}
        put stream rep-err unformatted "<P align=center><B>ОТЧЕТ ОБ ОШИБКАХ ПРИ ЗАГРУЗКЕ СПИСКА ГТД<BR></B></P>" skip
        "<TABLE border=1 valign=top cellpadding=5>" skip
        "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
        "<TD>№ </TD>" skip
        "<TD>ОКПО банка</TD>" skip
        "<TD>Код клиента</TD>" skip
        "<TD>ОКПО клиента</TD>" skip
        "<TD>Наименование клиента</TD>" skip
        "<TD>Номер ПС</TD>" skip
        "<TD>Дата ПС</TD>" skip
        "<TD>Номер ГТД</TD>" skip
        "<TD>Дата ГТД</TD>" skip
        "<TD>Курс</TD>" skip
        "<TD>Возврат?</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Сумма</TD>" skip
        "<TD>Примечание</TD>" skip
        "</TR>" skip.
        k = 0.
        for each wrk-err no-lock:
            k = k + 1.
            put stream rep-err unformatted
            "<TR align=left valign=top>"
            "<TD>" k "</TD>" skip
            "<TD>" wrk-err.bankokpo "</TD>" skip
            "<TD>" wrk-err.cif "</TD>" skip
            "<TD>" wrk-err.cifokpo "</TD>" skip
            "<TD>" wrk-err.cifname "</TD>" skip
            "<TD>" wrk-err.ps "</TD>" skip
            "<TD>" wrk-err.psdt "</TD>" skip
            "<TD>" wrk-err.gtd "</TD>" skip
            "<TD>" wrk-err.dndate "</TD>" skip
            "<TD>" wrk-err.cursdoc-con "</TD>" skip
            "<TD>" wrk-err.payret "</TD>" skip
            "<TD>" wrk-err.crccode "</TD>" skip
            "<TD>" wrk-err.sum "</TD>" skip
            "<TD>" wrk-err.err "</TD>" skip
            "</TR>" skip.
        end.
        put stream rep-err unformatted  "</TABLE>" skip.
        {html-end.i "stream rep-err"}
        output stream rep-err close.


    output stream rep-ok to ok.htm.
    {html-title.i &stream = "stream rep-ok" &size-add = "xx-"}
    put stream rep-ok unformatted "<P align=center><B>ОТЧЕТ ОБ УСПЕШНО ЗАГРУЖЕННЫХ/ПРОВЕРЕННЫХ ГТД ПО СПИСКУ<BR></B></P>" skip
    "<TABLE border=1 valign=top cellpadding=5>" skip
    "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
    "<TD>№ </TD>" skip
    "<TD>Код клиента</TD>" skip
    "<TD>ОКПО клиента</TD>" skip
    "<TD>Наименование клиента</TD>" skip
    "<TD>Номер ПС</TD>" skip
    "<TD>Дата ПС</TD>" skip
    "<TD>Номер ГТД</TD>" skip
    "<TD>Дата ГТД</TD>" skip
    "<TD>Курс</TD>" skip
    "<TD>Возврат?</TD>" skip
    "<TD>Валюта</TD>" skip
    "<TD>Сумма</TD>" skip
    "<TD>Оригинал?</TD>" skip
    "<TD>Загрузил</TD>" skip
    "<TD>Дата загрузки</TD>" skip
    "<TD>Внес документ</TD>" skip
    "<TD>Дата внесения<BR>документа</TD>" skip
    "<TD>Примечание</TD>" skip
    "</TR>" skip.
    k = 0.
    for each wrk-ok no-lock:
        k = k + 1.
        put stream rep-ok unformatted
        "<TR align=left valign=top>"
        "<TD>" k "</TD>" skip
        "<TD>" wrk-ok.cif "</TD>" skip
        "<TD>" wrk-ok.cifokpo "</TD>" skip
        "<TD>" wrk-ok.cifname "</TD>" skip
        "<TD>" wrk-ok.ps "</TD>" skip
        "<TD>" wrk-ok.psdt "</TD>" skip
        "<TD>" wrk-ok.dnnum "</TD>" skip
        "<TD>" wrk-ok.dndate "</TD>" skip
        "<TD>" wrk-ok.cursdoc-con "</TD>" skip
        "<TD>" wrk-ok.payret "</TD>" skip
        "<TD>" wrk-ok.pcrc "</TD>" skip
        "<TD>" wrk-ok.sum "</TD>" skip
        "<TD>" wrk-ok.origin "</TD>" skip
        "<TD>" wrk-ok.rwho "</TD>" skip
        "<TD>" wrk-ok.rdt "</TD>" skip
        "<TD>" wrk-ok.uwho "</TD>" skip
        "<TD>" wrk-ok.udt "</TD>" skip
        "<TD>" wrk-ok.reason "</TD>" skip
        "</TR>" skip.
    end.
    put stream rep-ok unformatted  "</TABLE>" skip.
    {html-end.i "stream rep-ok"}
    output stream rep-ok close.
        unix silent cptwin ok.htm iexplore.
        unix silent cptwin errs.htm iexplore.
        empty temp-table t-qin.
        empty temp-table t-qarc.
        empty temp-table wrk.
        return.
    end.
end.

/*ГТД из МТ*/
empty temp-table t-qin.
for each wrk no-lock:
    find first vcgtdimp where vcgtdimp.contract = wrk.contract and vcgtdimp.psnum = wrk.ps and vcgtdimp.psdate = wrk.psdt
    and vcgtdimp.dnnum = wrk.dnnum and vcgtdimp.dndate = wrk.dndate no-lock no-error.
    if avail vcgtdimp then do:
        create t-qin.
        t-qin.fps = wrk.ps.
        t-qin.fpsdt = wrk.psdt.
        t-qin.fgtd = wrk.dnnum.
        t-qin.fdate = wrk.dndate.
        t-qin.cif = vcgtdimp.cif.
        t-qin.cifokpo = vcgtdimp.cifokpo.
        t-qin.cifname = vcgtdimp.cifname.
        t-qin.dntype = "14".
        t-qin.bankokpo = vcgtdimp.bankokpo.
        t-qin.crc = vcgtdimp.crccode.
        t-qin.sum = vcgtdimp.sum.
        t-qin.payret = vcgtdimp.payret.
        t-qin.cursdoc-con = vcgtdimp.dnrate.
        t-qin.rdt = g-today.
        t-qin.rwho = g-ofc.
        t-qin.kurs = string(vcgtdimp.dnrate).
        t-qin.loaded = no.
    end.
end.

/*сохранить ГТД, как новую*/

on "Ins" of bin in frame fin do:
    do j = bin:NUM-SELECTED-ROWS TO 1 by -1 transaction:
        method-return = bin:FETCH-SELECTED-ROW(j).
        GET CURRENT qin NO-LOCK.
        find current t-qin.
        message "Вы собираетесь добавить в бд ПС" t-qin.fps  "№ГТД" t-qin.fgtd view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice1.
        if v-choice1 then do:
            find first vcgtdimp where vcgtdimp.mtnum = v-mtnum and vcgtdimp.psnum = t-qin.fps and vcgtdimp.psdate = t-qin.fpsdt and
            vcgtdimp.dnnum = t-qin.fgtd and vcgtdimp.dndate = t-qin.fdate and
            vcgtdimp.crccode = t-qin.crc and vcgtdimp.sum = t-qin.sum
            and vcgtdimp.payret = t-qin.payret and vcgtdimp.dnrate = t-qin.cursdoc-con no-lock no-error.
            if avail vcgtdimp then do:

                find first ncrc where ncrc.code = t-qin.crc no-lock no-error.
                if avail ncrc then v-crccrc = ncrc.crc.
                find first vcdocs where vcdocs.dnnum = t-qin.fgtd and vcdocs.dndate = t-qin.fdate
                and vcdocs.dntype = t-qin.dntype and vcdocs.pcrc = v-crccrc and vcdocs.sum = t-qin.sum
                and vcdocs.payret = t-qin.payret /*and vcdocs.cursdoc-con = t-qin.cursdoc-con*/
                no-lock no-error.
                if avail vcdocs then do:
                    message "ГТД уже добавлен!" view-as alert-box.
                    view frame farcch.
                    view frame fin.
                    view frame fhelp.
                    view frame fhelp1.
                    hide frame fdocs.
                end.
                if not avail vcdocs then do:
                    create vcdocs.
                    vcdocs.docs = next-value(vc-docs).
                    vcdocs.contract = vcps.contract.
                    vcdocs.dntype = "14".
                    vcdocs.dnnum = vcgtdimp.dnnum.
                    vcdocs.dndate = vcgtdimp.dndate.
                    vcdocs.pcrc = v-crccrc.
                    vcdocs.sum = vcgtdimp.sum.
                    vcdocs.payret = vcgtdimp.payret.
                    /*vcdocs.cursdoc-con = vcgtdimp.dnrate.*/
                    vcdocs.cursdoc-con = 1.
                    vcdocs.origin = no.
                    vcdocs.rdt = g-today.
                    vcdocs.rwho = g-ofc.
                    create wrk-ok.
                    wrk-ok.cif = vcgtdimp.cif.
                    wrk-ok.cifokpo = vcgtdimp.cifokpo.
                    wrk-ok.cifname = vcgtdimp.cifname.
                    wrk-ok.ps = vcgtdimp.psnum.
                    wrk-ok.psdt = vcgtdimp.psdate.
                    wrk-ok.dntype = "14".
                    wrk-ok.dnnum = vcgtdimp.dnnum.
                    wrk-ok.dndate = vcgtdimp.dndate.
                    wrk-ok.pcrc = v-crccrc.
                    wrk-ok.sum = vcgtdimp.sum.
                    wrk-ok.payret = vcgtdimp.payret.
                    wrk-ok.cursdoc-con = vcgtdimp.dnrate.
                    wrk-ok.origin = no.
                    wrk-ok.rdt = g-today.
                    wrk-ok.rwho = g-ofc.
                    wrk-ok.reason = "Полный прогруз".
                    find first t-qin where t-qin.fgtd = vcdocs.dnnum and t-qin.fdate = vcdocs.dndate
                    and t-qin.dntype = vcdocs.dntype and v-crccrc = vcdocs.pcrc and t-qin.sum = vcdocs.sum
                    and t-qin.payret = vcdocs.payret  /*and t-qin.cursdoc-con = vcdocs.cursdoc-con*/
                    no-lock no-error.
                    if avail t-qin then t-qin.loaded = yes.
                    message "ГТД успешно добавлен!" view-as alert-box.
                end.
            end.
        end.
    end.
end.

/*ГТД из бд*/
v-crccrc = 0.

on "go" of bin in frame fin do:
    DO i = bin:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
        method-return = bin:FETCH-SELECTED-ROW(i).
        GET CURRENT qin NO-LOCK.
        find current t-qin no-lock.
        for each vcgtdimp where vcgtdimp.mtnum = v-mtnum and vcgtdimp.psnum = t-qin.fps no-lock:
        empty temp-table t-qarc.
            find first ncrc where ncrc.code = vcgtdimp.crccode no-lock no-error.
            if avail ncrc then v-crccrc = ncrc.crc.
            find first vcps where vcps.dnnum = substr(vcgtdimp.psnum,1,11) and vcps.num = integer(substr(vcgtdimp.psnum,12,2))
            and vcps.dndate = vcgtdimp.psdate no-lock no-error.
            if  avail vcps then do:
                for each vcdocs where vcdocs.contract = vcps.contract and vcdocs.dntype = "14"
                and (vcdocs.dnnum = vcgtdimp.dnnum or vcdocs.dndate = vcgtdimp.dndate or
                vcdocs.pcrc = v-crccrc or vcdocs.sum = vcgtdimp.sum or vcdocs.payret = vcgtdimp.payret /*or vcdocs.cursdoc-con = vcgtdimp.dnrate*/) no-lock:
                find first ncrc where  ncrc.crc = vcdocs.pcrc no-lock no-error.
                if avail ncrc then v-crccode = ncrc.code.
                    create t-qarc.
                    t-qarc.fps = vcps.dnnum + string(vcps.num).
                    t-qarc.fpsdt = vcps.dndate.
                    t-qarc.fgtd = vcdocs.dnnum.
                    t-qarc.fdate = vcdocs.dndate.
                    t-qarc.cif = vcgtdimp.cif.
                    t-qarc.cifokpo = vcgtdimp.cifokpo.
                    t-qarc.cifname = vcgtdimp.cifname.
                    t-qarc.dntype = "14".
                    t-qarc.bankokpo = vcgtdimp.bankokpo.
                    t-qarc.crc = v-crccode.
                    t-qarc.sum = vcdocs.sum.
                    t-qarc.payret = vcdocs.payret.
                    t-qarc.cursdoc-con = vcgtdimp.dnrate.
                    t-qarc.rdt = vcdocs.rdt.
                    t-qarc.rwho = vcdocs.rwho.
                end.
            end.
        end.
        open query qarc for each t-qarc.
        view frame farcch.
    end.
end.

/*НАЙДЕННЫЕ ДОКУМЕНТЫ ИЗ VCDOCS*/
v-crccode = "".

on "go" of barc in frame farcch do:
    DO i = barc:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
        method-return = barc:FETCH-SELECTED-ROW(i).
        GET CURRENT qarc NO-LOCK.
        find current t-qarc no-lock.
        empty temp-table wrk-docs.
        find first vcps where vcps.dnnum = substr( t-qarc.fps,1,11) and vcps.num = integer(substr( t-qarc.fps,12,2))
        and vcps.dndate = t-qarc.fpsdt no-lock no-error.
        If  avail vcps then do:
            for each vcdocs where vcdocs.contract = vcps.contract and vcdocs.dnnum = t-qarc.fgtd and vcdocs.dndate = t-qarc.fdate no-lock:
                find first ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
                if avail ncrc then v-crccode = ncrc.code.
                create wrk-docs.
                wrk-docs.dntype = vcdocs.dntype.
                wrk-docs.dndate = vcdocs.dndate.
                wrk-docs.dnnum = vcdocs.dnnum.
                wrk-docs.crc = v-crccode.
                wrk-docs.sum = vcdocs.sum.
                wrk-docs.payret = vcdocs.payret.
                wrk-docs.cursdoc-con = vcdocs.cursdoc-con.
                wrk-docs.rdt = vcdocs.rdt.
                wrk-docs.rwho = vcdocs.rwho.
                wrk-docs.udt = vcdocs.udt.
                wrk-docs.uwho = vcdocs.uwho.
            end.
            open query qdocs for each wrk-docs.
            VIEW FRAME fdocs.
            enable bdocs with frame fdocs.
        end.
    end.
end.

open query qarc for each t-qarc.
open query qin for each t-qin.
apply "VALUE-CHANGED" to BROWSE barc.
apply "VALUE-CHANGED" to BROWSE bin.


view frame farcch.
view frame fin.
view frame fhelp.
view frame fhelp1.
pause 0 .


enable bin with frame fin.
enable barc with frame farcch.

on any-printable of bin in frame fin do:
    if keylabel(lastkey) = "c" then do:
        run cont.
        return.
    end.
    if keylabel(lastkey) = "o" then do:
        unix value("joe -rdonly  " + v-file0 ) .
    end.
end.


on any-printable of barc in frame farcch do:
    DO i = barc:NUM-SELECTED-ROWS TO 1 by -1 transaction on error undo, retry:
        method-return = barc:FETCH-SELECTED-ROW(i).
        GET CURRENT qarc NO-LOCK.
        find current t-qarc no-lock.
        if keylabel(lastkey) = "c" then do:
            run cont.
            return.
        end.
        /*Заменить данные найденного документа из vcdocs на данные ГТД из МТ*/
        if keylabel(lastkey) = "r" then do:
            find first t-qin where t-qin.fps = t-qarc.fps and t-qin.fpsdt = t-qarc.fpsdt no-lock no-error.
            if avail t-qin then do:
                find first ncrc where  ncrc.code = t-qin.crc no-lock no-error.
                if avail ncrc then v-crccrc = ncrc.crc.
                find first vcdocs where
                vcdocs.dnnum = t-qin.fgtd and vcdocs.dndate = t-qin.fdate and vcdocs.pcrc = v-crccrc
                and vcdocs.sum = t-qin.sum and vcdocs.payret = t-qin.payret and vcdocs.dntype = "14"
                /*and vcdocs.cursdoc-con = t-qin.cursdoc-con*/ no-lock no-error.
                if avail vcdocs then do:
                    message "ГТД уже заменен!" view-as alert-box.
                    view frame farcch.
                    view frame fin.
                    view frame fhelp.
                    view frame fhelp1.
                    hide frame fdocs.
                end.
                find first ncrc where  ncrc.code = t-qarc.crc no-lock no-error.
                if avail ncrc then v-crccrc = ncrc.crc.
                find first vcdocs where vcdocs.dnnum = t-qarc.fgtd and vcdocs.dndate = t-qarc.fdate and vcdocs.pcrc = v-crccrc
                and vcdocs.sum = t-qarc.sum and vcdocs.payret = t-qarc.payret and vcdocs.dntype = "14"
                /*and vcdocs.cursdoc-con = t-qarc.cursdoc-con*/ no-lock no-error.
                if avail vcdocs then do:
                   if t-qin.fgtd <> t-qarc.fgtd then do:
                        message "~n Номер найденного документа  " t-qarc.fgtd
                        "~n~n в обрабатываемой ГТД по данным таможни указан номер  " t-qin.fgtd
                        "~n~n Заменить Номер найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
                        if v-choice then do:
                            find current vcdocs exclusive-lock.
                            vcdocs.dnnum = t-qin.fgtd.
                            vcdocs.udt = g-today.
                            vcdocs.uwho = g-ofc.
                            find current vcdocs no-lock.
                            v-check1 = yes.
                        end.
                        else do:
                           hide frame fdocs.
                        end.
                    end.
                    if t-qin.fdate <> t-qarc.fdate then do:
                        message "~n Дата найденного документа  " t-qarc.fdate
                        "~n~n в обрабатываемой ГТД по данным таможни указана дата  " t-qin.fdate
                        "~n~n Заменить ДАТУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
                        if v-choice then do:
                            find current vcdocs exclusive-lock.
                            vcdocs.dndate = t-qin.fdate.
                            vcdocs.udt = g-today.
                            vcdocs.uwho = g-ofc.
                            find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                            find current vcdocs no-lock.
                            v-check2 = yes.
                        end.
                        else do:
                           hide frame fdocs.
                        end.
                    end.
                    if t-qin.crc <> t-qarc.crc then do:
                        message "~n Валюта найденного документа  " t-qarc.crc
                        "~n~n в обрабатываемой ГТД по данным таможни указана валюта  " t-qin.crc
                        "~n~n Заменить ВАЛЮТУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
                        if v-choice then do:
                            find first ncrc where ncrc.code = t-qin.crc no-lock no-error.
                            if avail ncrc then v-crccrc = ncrc.crc.
                            find current vcdocs exclusive-lock.
                            vcdocs.pcrc = v-crccrc.
                            vcdocs.udt = g-today.
                            vcdocs.uwho = g-ofc.
                            find vccontrs where vccontrs.contract = vcdocs.contract no-lock no-error.
                            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                            find current vcdocs no-lock.
                            v-check3 = yes.
                        end.
                    end.
                    if t-qin.sum <> t-qarc.sum then do:
                        message "~n Сумма найденного документа  " t-qarc.sum
                        "~n~n в обрабатываемой ГТД по данным таможни указана сумма  " t-qin.sum
                        "~n~n Заменить СУММУ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
                        if v-choice then do:
                            find current vcdocs exclusive-lock.
                            vcdocs.sum = t-qin.sum.
                            vcdocs.udt = g-today.
                            vcdocs.uwho = g-ofc.
                            find current vcdocs no-lock.
                            v-check4 = yes.
                        end.
                        else do:
                           hide frame fdocs.
                        end.
                    end.
                    if t-qin.cursdoc-con <> t-qarc.cursdoc-con then do:
                        message "~n В найденном документе указан возврат - " t-qarc.payret
                        "~n~n в обрабатываемой ГТД по данным таможни указан возврат - " t-qin.payret
                        "~n~n Заменить ВОЗВРАТ найденного документа на данные таможни ?~n~n" view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-choice.
                        if v-choice then do:
                            find current vcdocs exclusive-lock.
                            vcdocs.payret = t-qin.payret.
                            vcdocs.udt = g-today.
                            vcdocs.uwho = g-ofc.
                            find current vcdocs no-lock.
                            v-check5 = yes.
                        end.
                        else do:
                           hide frame fdocs.
                        end.
                    end.
                    if v-check1 = yes or v-check2 = yes or v-check3 = yes or v-check4 = yes or v-check5 = yes then do:
                        find current t-qin exclusive-lock.
                        t-qin.loaded = yes.
                        find current t-qin no-lock.
                        create wrk-ok.
                        wrk-ok.cif = t-qin.cif.
                        wrk-ok.cifokpo = t-qin.cifokpo.
                        wrk-ok.cifname = t-qin.cifname.
                        wrk-ok.ps = t-qin.fps.
                        wrk-ok.psdt = t-qin.fpsdt.
                        wrk-ok.dntype = "14".
                        wrk-ok.dnnum = vcdocs.dnnum.
                        wrk-ok.dndate = vcdocs.dndate.
                        wrk-ok.pcrc = vcdocs.pcrc.
                        wrk-ok.sum = vcdocs.sum.
                        wrk-ok.payret = vcdocs.payret.
                        wrk-ok.cursdoc-con = vcdocs.cursdoc-con.
                        wrk-ok.origin = no.
                        wrk-ok.rdt = vcdocs.rdt.
                        wrk-ok.rwho = vcdocs.rwho.
                        wrk-ok.udt = vcdocs.udt.
                        wrk-ok.uwho = vcdocs.uwho.
                        if v-check1 then wrk-ok.reason = "Замена номера документа " + wrk-ok.reason.
                        if v-check2 then wrk-ok.reason = "Замена даты документа " + wrk-ok.reason.
                        if v-check3 then wrk-ok.reason = "Замена валюты документа " + wrk-ok.reason.
                        if v-check4 then wrk-ok.reason = "Замена суммы документа " + wrk-ok.reason.
                        if v-check5 then wrk-ok.reason = "Замена курса " + wrk-ok.reason.
                    end.
                end.
            end.
        end.
    end.
end.
wait-for close of this-procedure focus bin.
disable bdocs with frame fdocs.
disable bin with frame fin.
disable barc with frame farcch.
unix silent value("rm -f " + v-file0).
/*Запись данных МТ в БД*/
pause 0.

/* ГТД, которые были пропущены оператором*/
procedure cont:
    hide frame farcch.
    hide frame fin.
    hide frame fhelp.
    hide frame fhelp1.
    hide frame fdocs.

    for each vcgtdimp where vcgtdimp.mtnum = v-mtnum no-lock:
        find first ncrc where ncrc.code = vcgtdimp.crccode no-lock no-error.
        if avail ncrc then v-crccrc = ncrc.crc.
            find first t-qin where t-qin.fgtd = vcgtdimp.dnnum and t-qin.fdate = vcgtdimp.dndate
            and t-qin.crc = vcgtdimp.crccode and t-qin.sum = vcgtdimp.sum
            and t-qin.payret = vcgtdimp.payret  and t-qin.cursdoc-con = vcgtdimp.dnrate AND t-qin.loaded = no
            no-lock no-error.
            if avail t-qin then do:
                find first b-vcgtdimp where rowid(b-vcgtdimp) = rowid(vcgtdimp) exclusive-lock.
                update b-vcgtdimp.note = " Не прогружен оператором " + g-ofc.
                find first b-vcgtdimp where rowid(b-vcgtdimp) = rowid(vcgtdimp) no-lock.
                create wrk-err.
                wrk-err.bankokpo = vcgtdimp.bankokpo.
                wrk-err.cifokpo = vcgtdimp.cifokpo.
                wrk-err.cif = vcgtdimp.cif.
                wrk-err.cifname = vcgtdimp.cifname.
                wrk-err.ps = vcgtdimp.psnum.
                wrk-err.psdt = vcgtdimp.psdate.
                wrk-err.gtd = vcgtdimp.dnnum.
                wrk-err.dndate = vcgtdimp.dndate.
                wrk-err.crccode = vcgtdimp.crccode.
                wrk-err.sum = vcgtdimp.sum.
                wrk-err.err = vcgtdimp.note.
                wrk-err.cursdoc-con = vcgtdimp.dnrate.
                wrk-err.payret = vcgtdimp.payret.
            end.
    end.


    output stream rep-ok to ok.htm.
    {html-title.i &stream = "stream rep-ok" &size-add = "xx-"}
    put stream rep-ok unformatted "<P align=center><B>ОТЧЕТ ОБ УСПЕШНО ЗАГРУЖЕННЫХ/ПРОВЕРЕННЫХ ГТД ПО СПИСКУ<BR></B></P>" skip
    "<TABLE border=1 valign=top cellpadding=5>" skip
    "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
    "<TD>№ </TD>" skip
    "<TD>Код клиента</TD>" skip
    "<TD>ОКПО клиента</TD>" skip
    "<TD>Наименование клиента</TD>" skip
    "<TD>Номер ПС</TD>" skip
    "<TD>Дата ПС</TD>" skip
    "<TD>Номер ГТД</TD>" skip
    "<TD>Дата ГТД</TD>" skip
    "<TD>Курс</TD>" skip
    "<TD>Возврат?</TD>" skip
    "<TD>Валюта</TD>" skip
    "<TD>Сумма</TD>" skip
    "<TD>Оригинал?</TD>" skip
    "<TD>Загрузил</TD>" skip
    "<TD>Дата загрузки</TD>" skip
    "<TD>Внес документ</TD>" skip
    "<TD>Дата внесения<BR>документа</TD>" skip
    "<TD>Примечание</TD>" skip
    "</TR>" skip.
    k = 0.
    for each wrk-ok no-lock:
        k = k + 1.
        put stream rep-ok unformatted
        "<TR align=left valign=top>"
        "<TD>" k "</TD>" skip
        "<TD>" wrk-ok.cif "</TD>" skip
        "<TD>" wrk-ok.cifokpo "</TD>" skip
        "<TD>" wrk-ok.cifname "</TD>" skip
        "<TD>" wrk-ok.ps "</TD>" skip
        "<TD>" wrk-ok.psdt "</TD>" skip
        "<TD>" wrk-ok.dnnum "</TD>" skip
        "<TD>" wrk-ok.dndate "</TD>" skip
        "<TD>" wrk-ok.cursdoc-con "</TD>" skip
        "<TD>" wrk-ok.payret "</TD>" skip
        "<TD>" wrk-ok.pcrc "</TD>" skip
        "<TD>" wrk-ok.sum "</TD>" skip
        "<TD>" wrk-ok.origin "</TD>" skip
        "<TD>" wrk-ok.rwho "</TD>" skip
        "<TD>" wrk-ok.rdt "</TD>" skip
        "<TD>" wrk-ok.uwho "</TD>" skip
        "<TD>" wrk-ok.udt "</TD>" skip
        "<TD>" wrk-ok.reason "</TD>" skip
        "</TR>" skip.
    end.
    put stream rep-ok unformatted  "</TABLE>" skip.
    {html-end.i "stream rep-ok"}
    output stream rep-ok close.


    output to errs.htm.
    {html-title.i &size-add = "xx-"}
    put unformatted "<P align=center><B>ОТЧЕТ ОБ ОШИБКАХ ПРИ ЗАГРУЗКЕ СПИСКА ГТД<BR></B></P>" skip
    "<TABLE border=1 valign=top cellpadding=5>" skip
    "<TR valign=top align=center style=""font:bold;font-size:xx-small"">" skip
    "<TD>№ </TD>" skip
    "<TD>ОКПО банка</TD>" skip
    "<TD>Код клиента</TD>" skip
    "<TD>ОКПО клиента</TD>" skip
    "<TD>Наименование клиента</TD>" skip
    "<TD>Номер ПС</TD>" skip
    "<TD>Дата ПС</TD>" skip
    "<TD>Номер ГТД</TD>" skip
    "<TD>Дата ГТД</TD>" skip
    "<TD>Курс</TD>" skip
    "<TD>Возврат?</TD>" skip
    "<TD>Валюта</TD>" skip
    "<TD>Сумма</TD>" skip
    "<TD>Примечание</TD>" skip
    "</TR>" skip.
    k = 0.
    for each wrk-err no-lock:
        find first vcgtdimp where vcgtdimp.mtnum = v-mtnum and vcgtdimp.psnum = wrk-err.ps and vcgtdimp.psdate = wrk-err.psdt and
        vcgtdimp.dnnum = wrk-err.gtd and vcgtdimp.dndate = wrk-err.dndate no-lock no-error.
        if avail vcgtdimp then do:
            find first vccontrs where vccontrs.bank = vcgtdimp.bank and vccontrs.cif = vcgtdimp.cif no-lock no-error.
            if avail vccontrs then do:
                find first b-vcgtdimp where rowid(b-vcgtdimp) = rowid(vcgtdimp) exclusive-lock.
                update b-vcgtdimp.contract = vccontrs.contract.
                find first b-vcgtdimp where rowid(b-vcgtdimp) = rowid(vcgtdimp) no-lock.
            end.
        end.
        k = k + 1.
        put unformatted
        "<TR align=left valign=top>"
        "<TD>" k "</TD>" skip
        "<TD>" wrk-err.bankokpo "</TD>" skip
        "<TD>" wrk-err.cif "</TD>" skip
        "<TD>" wrk-err.cifokpo "</TD>" skip
        "<TD>" wrk-err.cifname "</TD>" skip
        "<TD>" wrk-err.ps "</TD>" skip
        "<TD>" wrk-err.psdt "</TD>" skip
        "<TD>" wrk-err.gtd "</TD>" skip
        "<TD>" wrk-err.dndate "</TD>" skip
        "<TD>" wrk-err.cursdoc-con "</TD>" skip
        "<TD>" wrk-err.payret "</TD>" skip
        "<TD>" wrk-err.crccode "</TD>" skip
        "<TD>" wrk-err.sum "</TD>" skip
        "<TD>" wrk-err.err "</TD>" skip
        "</TR>" skip.
    end.
    put unformatted "</TABLE>" skip.
    {html-end.i " "}
    output close.

    unix silent cptwin errs.htm iexplore.
    unix silent cptwin ok.htm iexplore.
    empty temp-table t-qin.
    empty temp-table t-qarc.
    empty temp-table wrk.
    pause 0.
end procedure.


