/* pcsalload.p
 * MODULE
        Название модуля - Платежные карты.
 * DESCRIPTION
        Описание - Загрузка файлов по ПК из ИБ.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM IB
 * AUTHOR
        29/08/2012 id00810
 * CHANGES
        29/10/2012 id00810 - добавлена проверка РНН,ИИН и ФИО по базе НК (ТЗ 1555)
        20/11/2012 id00810 - добавлены 2 новые переменные (для разборки ошибок и определения почтового адреса)
        25/12/2012 id00810 - перекомпиляция
        17.01.2013 Lyubov  - из по "адрес" выходящих данных убираем символ №, т.к. не читается при создании xml файла
        13.03.2013 damir - Внедрено Т.З. № 1558,1582.
        21/05/2013 zhassulan - ТЗ 1788 (добавление трех доп.полей, создание кредитной анкеты)
        15.08.2013 evseev - тз-1868
        27.08.2013 Lyubov - ТЗ 2053, проверка статуса pcstaff0
        30/09/2013 Luiza  - ТЗ 2047 Замена символов  русского шрифтов каз (если не совпадают)
        03.10.2013 damir - Внедрено Т.З. № 2124. Исправлена техническая ошибка.
*/

{global.i}
{srvcheck.i}
{chk-rekv.i}
{xmlParser.i}

def var ptpsession as handle.
def var consumerH as handle.
def var replyMessage as handle.
def var v-terminate as logi no-undo.

def temp-table t-pcstaff0 no-undo
    field rnn     as char
    field iin     as char
    field sname   as char
    field fname   as char
    field mname   as char
    field birth   as date
    field rez     as logi
    field pctype  as char
    field nomdoc  as char
    field issdt   as date
    field expdt   as date
    field issdoc  as char
    field addr    as char extent 2
    field tel     as char extent 2
    field mail    as char
    field crc     as inte
    field idload  as inte
    field bplace  as char
    field salary  as decimal
    field hdt     as date
index idx1 is primary iin ascending.

def temp-table t-err no-undo
    field t-nom   as inte
    field t-txt   as char
index idx1 t-txt ascending.

function kzru returns char (vbank as char,vcif as char,str as char,str1 as char).
    define var outstr as char.
    def var kz as char .
    def var ru as char .
    def var i as integer.
    def var j as integer.
    def var ns as log init false.
    def var slen as int.
    /*str = caps(str).*/
    slen = length(str).
    find first pcsootv where pcsootv.bank = vbank and pcsootv.cif = vcif no-lock no-error.
    if not available pcsootv or trim(pcsootv.kz) = "" or trim(pcsootv.ru) = "" then outstr = str.
    else do:
        repeat i = 1 to slen:
            repeat j = 1 to num-entries(trim(pcsootv.kz),","):
                if substr(str,i,1) <> substr(str1,i,1) then do:
                    if substr(str,i,1) = entry(j,trim(pcsootv.ru)) then do:
                        outstr = outstr + entry(j,trim(pcsootv.kz)).
                        ns = true.
                    end.
                end.
            end.
            if not ns then outstr = outstr + substr(str,i,1).
            ns = false.
        end.
        outstr = Caps(substring(outstr,1,1)) + substring(outstr,2,length(outstr) - 1).
    end.
    return outstr.
end.

def buffer b-t-err for t-err.

DEFINE NEW GLOBAL SHARED VAR JMS-MAXIMUM-MESSAGES AS INTEGER INIT 500.
run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").

run setUser in ptpsession ("SonicClient").
run setPassword in ptpsession ("SonicClient").
run beginSession in ptpsession no-error.

run createTextMessage in ptpsession (output replyMessage) no-error.
run createMessageConsumer in ptpsession (THIS-PROCEDURE,"requestHandler",output consumerH) no-error.
run receiveFromQueue in ptpsession ("CARD2ABS",?,consumerH) no-error.
run startReceiveMessages in ptpsession.
run waitForMessages in ptpsession ("inWait",THIS-PROCEDURE,?).
message "Процесс корректно завершен".
run stopReceiveMessages in ptpsession no-error.
run deleteConsumer in ptpsession no-error.
run deletesession in ptpsession no-error.

procedure requestHandler:
    def input  parameter requestH as handle.
    def input  parameter msgConsumerH as handle.
    def output parameter replyH as handle.

    def var msgText as char no-undo.
    def var v-pref as char no-undo init 'A,B,C,D,E,F,H,K,L,M,N,O,P,Q,R,S,T'.
    def var v-txb as char no-undo init '00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16'.
    def var v-bfil as char no-undo.
    def var v-nfil as char no-undo.
    def var v-nom as inte no-undo.
    def var v-filename as char no-undo.
    def var v-str as char no-undo.
    def var v-err as logi  no-undo.
    def var v-err1 as logi  no-undo.
    def var v-iinbin as char no-undo.
    def var v-pctype as char no-undo.
    def var v-dt1 as date no-undo format '99/99/9999'.
    def var v-dt2 as date no-undo format '99/99/9999'.
    def var v-dt3 as date no-undo format '99/99/9999'.
    def var v-dt4 as date no-undo format '99/99/9999'.
    def var v-salary as decimal no-undo.
    def var orgBin as char no-undo.
    def var orgName as char no-undo.
    def var orgAddress as char no-undo.
    def var v-bank as char no-undo.
    def var v-arc as char no-undo.
    def var v-ArcStat as char no-undo.
    def var i as int  no-undo.
    def var v-iin as char no-undo.
    def var v-name as char no-undo.
    def var v-latname as char no-undo.
    def var v-mail as char no-undo.
    def var v-crcc as char no-undo.
    def var v-sname as char no-undo.
    def var v-fname as char no-undo.
    def var v-mname as char no-undo.
    def var v-names      as char no-undo.
    def var v-namef      as char no-undo.
    def var v-namem      as char no-undo.
    def var v-txt as char extent 2 no-undo.
    def var v-mailb as char no-undo.
    def var v-crccode as char no-undo.
    def var v-crc as inte no-undo.
    def var err as char init "" no-undo.
    def var p_ATTACHMENT as char init "" no-undo.
    def var v-ID as char init "" no-undo.
    def var v-BANK_ID as char init "" no-undo.
    def var v-NUM_DOC as char init "" no-undo.
    def var v-DATE_DOC as char init "" no-undo.
    def var v-DATE_SIGN as char init "" no-undo.
    def var v-PAYER_NAME as char init "" no-undo.
    def var v-STATUS as char init "" no-undo.
    def var v-EXT_ID as char init "" no-undo.
    def var v-ATTACHMENT as longchar.

    def var Docmemptr as memptr.
    def var v-xmlload as logi.
    def var h-doc as handle.
    def var h-node as handle.

    msgText = DYNAMIC-FUNCTION('getText':U IN requestH).
    if num-entries(msgText,"=") = 2 and entry(1,msgText,"=") = "qcommand" and trim(entry(2,msgText,"=")) <> '' then do:
        run deleteMessage in requestH.
        if trim(entry(2,msgText,"=")) = "terminate" then v-terminate = yes.
    end.
    else do:
        message "Start Process.".
        run savelog("PCLOAD",msgText).

        create x-document h-doc.
        create x-noderef h-node.

        set-size(Docmemptr) = 0.
        set-size(Docmemptr) = 2097152.
        msgText = trim(replace(msgText,"UTF-8","windows-1251")).
        put-string(Docmemptr,1) = msgText.

        v-xmlload = h-doc:load("memptr",Docmemptr,false) no-error.
        if not v-xmlload then do: message "XML-document loaded with errors!!!". return. end.
        h-doc:get-document-element(h-node).

        message "Before run get-node.".

        run get-node(
        h-node, /*1*/
        "ID", /*2*/
        "BANK_ID", /*3*/
        "NUM_DOC", /*4*/
        "DATE_DOC", /*5*/
        "DATE_SIGN", /*6*/
        "PAYER_NAME", /*7*/
        "STATUS", /*8*/
        "EXT_ID", /*9*/
        "ATTACHMENT", /*10*/
        input-output v-ID, /*11*/
        input-output v-BANK_ID, /*12*/
        input-output v-NUM_DOC, /*13*/
        input-output v-DATE_DOC, /*14*/
        input-output v-DATE_SIGN, /*15*/
        input-output v-PAYER_NAME, /*16*/
        input-output v-STATUS, /*17*/
        input-output v-EXT_ID, /*18*/
        input-output v-ATTACHMENT). /*19*/

        v-bfil = substr(v-EXT_ID,1,1).
        if lookup(v-bfil,v-pref) > 0 then v-nfil = entry(lookup(v-bfil,v-pref),v-txb).
        v-nom = 1.
        for each pcstaff0 where pcstaff0.namef begins 'salary' + '_' + v-nfil  + '_' + v-EXT_ID no-lock:
            v-nom = v-nom + 1.
        end.
        find first bookcod where bookcod.bookcod = 'pc' and bookcod.code = "TXB" + v-nfil no-lock no-error.
        if avail bookcod and num-entries(bookcod.name) = 2 then v-mailb = entry(2,bookcod.name) + '@fortebank.com'.

        v-filename = 'salary' + '_' + v-nfil  + '_' + v-EXT_ID + '_kzt_' + string(v-nom,"9999") + '.csv'.
        v-bank = 'TXB' + v-nfil.

        message "*****************************************************".
        message string(today,"99/99/9999").
        message string(time,"HH:MM:SS").
        message string(v-filename).
        message "*****************************************************".
        message "           EXT_ID = " string(v-EXT_ID).
        message "       PAYER_NAME = " string(v-PAYER_NAME).
        message "               ID = " string(v-ID).
        message "*****************************************************".

        /*--------------------------------Сохранение документа----------------------------------*/
        output to value(v-filename).
        do i = 1 to length(v-ATTACHMENT):
            export hex-decode(substr(v-ATTACHMENT,i,15000)).
            i = i + 14999.
        end.
        output close.

        message "After output to value.".

        v-arc = "/data/import/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
        input through value( "find " + v-arc + ";echo $?").
        repeat:
            import unformatted v-str.
        end.
        if v-str <> "0" then do:
            unix silent value ("mkdir " + v-arc).
            unix silent value ("chmod 777 " + v-arc).
        end.
        unix silent value('cp ' + v-filename + ' ' + v-arc).
        /*--------------------------------------------------------------------------------------*/

        find first comm.txb where comm.txb.consolid and comm.txb.txb = inte(v-nfil) no-lock no-error.
        find last comm.netbankdoc where comm.netbankdoc.id = v-ID exclusive-lock no-error.
        if not avail comm.netbankdoc then do:
            create comm.netbankdoc.
            comm.netbankdoc.id = v-ID.
            comm.netbankdoc.sts = "4".
            comm.netbankdoc.rem[1] = "На обработке".
            comm.netbankdoc.rem[4] = string(g-today,"99/99/9999").
            comm.netbankdoc.docnum = v-filename.
            if avail comm.txb then comm.netbankdoc.txb = trim(comm.txb.bank).
            comm.netbankdoc.cif = v-EXT_ID.
        end.

        empty temp-table t-err.
        empty temp-table t-pcstaff0.

        message "Before input from value.".

        input from value(v-filename) no-echo.
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            if v-str ne "" and num-entries(v-str,';') = 21 then do:
                if trim(entry(9,v-str,';')) ne '' then do:
                    v-crccode = trim(entry(9,v-str,';')).
                    find first crc where crc.code = trim(v-crccode) no-lock no-error.
                    if not avail crc then next.
                end.
                else next.

                v-iinbin = trim(entry(2,v-str,';')).
                if length(v-iinbin) < 12 then do:
                    v-err = yes.
                    create t-err.
                    assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверная длина ИИН'.
                    next.
                end.
                find first rnn where rnn.bin = trim(v-iinbin) no-lock no-error.
                if not avail rnn then do:
                    v-err = yes.
                    create t-err.
                    assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'ИИН отсут-т в базе НК МФ'.
                    next.
                end.
                else do:
                    v-iin = trim(rnn.bin).
                    v-sname = trim(rnn.lname).
                    v-fname = trim(rnn.fname).
                    v-mname = trim(rnn.mname).
                end.
                find first pcstaff0 where pcstaff0.iin = trim(v-iinbin) and pcstaff0.sts <> 'Closed' no-lock no-error.
                if avail pcstaff0 then do:
                    v-err = yes.
                    create t-err.
                    assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'ИИН был загружен ранее'.
                    next.
                end.
                v-name = trim(entry(3,v-str,';')).
                if v-name ne v-sname then do:
                    v-names = kzru(v-bank,v-EXT_ID,v-name,v-sname).
                    if v-names <> v-sname then do:
                        run savelog("pcsalload", "ошибка фамилии "  + v-bank + " " + v-EXT_ID + " в файле: " + v-name + " в базе РНН" + v-sname + " после конвертации" + v-names).
                        v-err1 = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-sname) then v-err1 = no.
                        if v-err1 then do:
                            create t-err.
                            assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Несоот-е фамилии по базе НК МФ'.
                            v-err = yes.
                            next.
                        end.
                    end.
                    else v-sname = v-names.
                end.
                v-name = trim(entry(4,v-str,';')).
                if v-name ne v-fname then do:
                    v-namef = kzru(v-bank,v-EXT_ID,v-name,v-fname).
                    if v-namef <> v-fname then do:
                        run savelog("pcsalload", "ошибка имени "  + v-bank + " " + v-EXT_ID + " в файле: " + v-name + " в базе РНН" + v-fname + " после конвертации" + v-namef).
                        v-err1 = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-fname) then v-err1 = no.
                        if v-err1 then do:
                            create t-err.
                            assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Несоот-е имени по базе НК МФ'.
                            v-err = yes.
                            next.
                        end.
                    end.
                    else v-fname = v-namef.
                end.
                v-name = trim(entry(5,v-str,';')).
                if v-name ne v-mname then do:
                    v-namem = kzru(v-bank,v-EXT_ID,v-name,v-mname).
                    if v-namem <> v-mname then do:
                        run savelog("pcsalload", "ошибка отчества "  + v-bank + " " + v-EXT_ID + " в файле: " + v-name + " в базе РНН" + v-mname + " после конвертации" + v-namem).
                        v-err1 = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-mname) then v-err1 = no.
                        if v-err1 then do:
                            create t-err.
                            assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Несоот-е отчества по базе НК МФ'.
                            v-err = yes.
                            next.
                        end.
                    end.
                    else v-mname = v-namem.
                end.
                if trim(entry(6,v-str,';')) ne '' then do:
                    v-dt1 = date(trim(entry(6,v-str,';'))) no-error.
                    if error-status:error or length(trim(entry(6,v-str,';'))) > 10 then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 6'.
                        next.
                    end.
                end.
                find first codfr where codfr.codfr = 'pctype' and codfr.code = trim(entry(8,v-str,';')) no-lock no-error.
                if avail codfr then v-pctype = trim(codfr.code).
                else do:
                    if trim(entry(8,v-str,';')) = 'Е' then v-pctype = 'E'.
                    else if trim(entry(8,v-str,';')) = 'С' then v-pctype = 'C'.
                    else do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 8'.
                        next.
                    end.
                end.
                if trim(entry(9,v-str,';')) ne '' then do:
                    v-crccode = trim(entry(9,v-str,';')).
                    find first crc where crc.code = trim(v-crccode) no-lock no-error.
                    if not avail crc then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 9'.
                        next.
                    end.
                    else v-crc = crc.crc.
                end.
                else do:
                    v-err = yes.
                    create t-err.
                    assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Столбец 9 пустой'.
                    next.
                end.
                if trim(entry(11,v-str,';')) ne '' then do:
                    v-dt2 = date(trim(entry(11,v-str,';'))) no-error.
                    if error-status:error or length(trim(entry(11,v-str,';'))) > 10 then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 11'.
                        next.
                    end.
                end.
                if trim(entry(12,v-str,';')) ne '' then do:
                    v-dt3 = date(trim(entry(12,v-str,';'))) no-error.
                    if error-status:error or length(trim(entry(12,v-str,';'))) > 10 then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 12'.
                        next.
                    end.
                end.
                if trim(entry(20,v-str,';')) ne '' then do:
                    v-salary = deci(trim(entry(20,v-str,';'))) no-error.
                    if error-status:error then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 20'.
                        next.
                    end.
                end.
                if trim(entry(21,v-str,';')) ne '' then do:
                    v-dt4 = date(trim(entry(21,v-str,';'))) no-error.
                    if error-status:error or length(trim(entry(21,v-str,';'))) > 10 then do:
                        v-err = yes.
                        create t-err.
                        assign t-err.t-nom = inte(trim(entry(1,v-str,';'))) + 2 t-err.t-txt = 'Неверное знач. в столбце 21'.
                        next.
                    end.
                end.

                find first t-pcstaff0 where t-pcstaff0.iin = trim(v-iinbin) no-lock no-error.
                if not avail t-pcstaff0 then do:
                    create  t-pcstaff0.
                    t-pcstaff0.iin = v-iinbin. /*2*/ /*ИИН*/
                    t-pcstaff0.sname = v-sname. /*3*/ /*Фамилия*/
                    t-pcstaff0.fname = v-fname. /*4*/ /*Имя*/
                    t-pcstaff0.mname = v-mname. /*5*/ /*Отчество*/
                    if trim(entry(6,v-str,';')) ne '' then t-pcstaff0.birth = v-dt1. /*6*/ /*Дата рождения*/
                    if trim(entry(7,v-str,';')) = 'да' then t-pcstaff0.rez = yes. /*7*/ /*Резидент(да/нет)*/
                    t-pcstaff0.pctype = v-pctype. /*8*/ /*Вид карты :E – Electron,C – Classic,G – Gold*/
                    t-pcstaff0.crc = v-crc. /*9*/ /*Валюта*/
                    t-pcstaff0.nomdoc = trim(entry(10,v-str,';')). /*10*/ /*№ удостоверения*/
                    if trim(entry(11,v-str,';')) ne '' then t-pcstaff0.issdt = v-dt2. /*11*/ /*Дата выдачи удост.*/
                    if trim(entry(12,v-str,';')) ne '' then t-pcstaff0.expdt = v-dt3. /*12*/ /*Срок действия удост.*/
                    t-pcstaff0.issdoc = trim(entry(13,v-str,';')). /*13*/ /*Кем выдано удост.*/
                    t-pcstaff0.addr[1] = trim(entry(14,replace(v-str,'№',''),';')). /*14*/ /*Адрес прописки*/
                    t-pcstaff0.addr[2] = trim(entry(15,replace(v-str,'№',''),';')). /*15*/ /*Адрес проживания*/
                    t-pcstaff0.tel[1] = trim(entry(16,v-str,';')). /*16*/ /*Домашний телефон*/
                    t-pcstaff0.tel[2] = trim(entry(17,v-str,';')). /*17*/ /*Мобильный телефон*/
                    t-pcstaff0.mail = trim(entry(18,v-str,';')). /*18*/ /*E-mail*/
                    t-pcstaff0.bplace = trim(entry(19,v-str,';')). /*19*/ /*Место рождения*/
                    if trim(entry(20,v-str,';')) ne '' then t-pcstaff0.salary = v-salary. /*20*/ /*Зарплата-нетто*/
                    if trim(entry(21,v-str,';')) ne '' then t-pcstaff0.hdt = v-dt4. /*21*/ /*Дата приема на работу*/

                    t-pcstaff0.idload = inte(v-ID) no-error.
                    t-pcstaff0.tel[1] = replace(t-pcstaff0.tel[1],'-','').
                    t-pcstaff0.tel[1] = replace(t-pcstaff0.tel[1],' ','').
                    t-pcstaff0.tel[2] = replace(t-pcstaff0.tel[2],'-','').
                    t-pcstaff0.tel[2] = replace(t-pcstaff0.tel[2],' ','').
                end.
            end.
        end.
        input close.

        message "After input from value.".

        find first t-pcstaff0 no-lock no-error.
        if not avail t-pcstaff0 or v-err then do:
            v-txt[2] = "".
            if v-err then do:
                for each t-err no-lock break by t-err.t-txt:
                    if first-of(t-err.t-txt) then do:
                        v-txt[1] = "".
                        v-txt[2] = t-err.t-txt.
                        for each b-t-err where b-t-err.t-txt = t-err.t-txt no-lock:
                            if v-txt[1] ne "" then v-txt[1] = v-txt[1] + "," + string(b-t-err.t-nom).
                            else v-txt[1] = string(b-t-err.t-nom).
                        end.
                        v-txt[2] = v-txt[2] + ":" + v-txt[1] + ";".
                    end.
                end.
                message " error: Файл не принят. Обнаружены ошибки в строках".
            end.
            else do:
                v-txt[2] = v-txt[2] + 'Невозможно обработать файл!'.
                message " error: Невозможно обработать файл".
            end.

            /*-----------------------------------Статус документа-----------------------------------------*/
            comm.netbankdoc.sts = "6".
            comm.netbankdoc.rem[1] = "Отвергнут".
            comm.netbankdoc.rem[2] = v-txt[2].

            run createXMLMessage in ptpsession(output requestH).
            run setText in requestH("<?xml version=""1.0"" encoding=""UTF-8""?>").
            run appendText in requestH("<DOC>").
            run appendText in requestH("<CARD>").
            run appendText in requestH("<ID>" + v-ID + "</ID>").
            run appendText in requestH("<STATUS>6</STATUS>").
            run appendText in requestH("<DESCRIPTION>" + trim(substr(v-txt[2],1,100)) + "</DESCRIPTION>").
            run appendText in requestH("</CARD>").
            run appendText in requestH("</DOC>").
            run sendToQueue in ptpsession("SYNC2NETBANK",requestH,?,?,?).
            run deleteMessage in requestH.
            /*--------------------------------------------------------------------------------------------*/

            for each gate where gate.txb = v-bank and gate.name <> "" no-lock:
                 run mail(gate.email, "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2] , "1", "",v-filename).
            end.
            if v-mailb ne '' then run mail(v-mailb, "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2] , "1", "",v-filename).
            run mail("id00892@fortebank.com", "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2] , "1", "",v-filename).

            unix silent value('rm  -f ' + v-filename).
            return.
        end.

        message 'createStart'.

        find first comm.txb where comm.txb.bank = v-bank and comm.txb.consolid = true no-lock no-error.
        if avail comm.txb then do:
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        end.
        run orgInfo(input v-EXT_ID, output orgBin, output orgName, output orgAddress).
        if connected ("txb") then disconnect "txb".

        for each t-pcstaff0 no-lock:

            /* Создание кредитной анкеты если */
            if t-pcstaff0.bplace <> '' and t-pcstaff0.salary <> 0 and t-pcstaff0.hdt <> ? then do:
                    create pkanketa.
                    assign
                    pkanketa.bank     = v-bank
                    pkanketa.credtype = '4'
                    pkanketa.ln       = next-value(anknom)
                    pkanketa.rnn      = t-pcstaff0.iin
                    pkanketa.docnum   = t-pcstaff0.nomdoc
                    pkanketa.name     = caps(t-pcstaff0.sname) + ' ' + caps(t-pcstaff0.fname) + ' ' + caps(t-pcstaff0.mname)
                    pkanketa.rdt      = g-today
                    pkanketa.rwho     = g-ofc
                    pkanketa.crc      = 1
                    pkanketa.addr1    = t-pcstaff0.addr[1]
                    pkanketa.addr2    = t-pcstaff0.addr[2]
                    pkanketa.sts      = '01'.
                    pkanketa.jobrnn   = orgBin.
                    pkanketa.jobname  = orgName.
                    pkanketa.jobaddr  = orgAddress.
            end.
            /*создание закончено */

            find first comm.pcstaff0 where comm.pcstaff0.iin = trim(t-pcstaff0.iin) no-lock no-error.
            if not avail comm.pcstaff0 then create comm.pcstaff0.
            else find current comm.pcstaff0 exclusive-lock.

            buffer-copy t-pcstaff0 to pcstaff0 no-error.

            comm.pcstaff0.namef = v-filename.
            comm.pcstaff0.ldt = g-today.
            comm.pcstaff0.bank = v-bank.
            comm.pcstaff0.cifb = v-EXT_ID.
            comm.pcstaff0.pcprod = 'salary'.
            comm.pcstaff0.crc = t-pcstaff0.crc.
            if comm.pcstaff0.rez then comm.pcstaff0.country = 'KAZ'.
            comm.pcstaff0.sts = 'new'.
            find current comm.pcstaff0 no-lock no-error.

        end.

        message 'createEnd'.

        unix silent value("rm -f " + v-filename).

        v-txt[2] = 'Клиент ' + v-EXT_ID + '\n' + 'Файл принят'.
        for each gate where gate.txb = v-bank and gate.name <> "" no-lock:
            run mail(gate.email, "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2], "1","","").
        end.
        if v-mailb ne '' then run mail(v-mailb, "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2],"1","","").
        run mail("id00892@fortebank.com", "КЛИЕНТ ИНТЕРНЕТ-БАНКИНГА <netbank@fortebank.com>",  "Загрузка файла на выпуск ПК",v-txt[2],"1","","").

        /*-----------------------------------Статус документа-----------------------------------------*/
        comm.netbankdoc.sts = "5".
        comm.netbankdoc.rem[1] = "Исполнен".

        run createXMLMessage in ptpsession(output requestH).
        run setText in requestH("<?xml version=""1.0"" encoding=""UTF-8""?>").
        run appendText in requestH("<DOC>").
        run appendText in requestH("<CARD>").
        run appendText in requestH("<ID>" + v-ID + "</ID>").
        run appendText in requestH("<STATUS>5</STATUS>").
        run appendText in requestH("<DESCRIPTION>Исполнен</DESCRIPTION>").
        run appendText in requestH("</CARD>").
        run appendText in requestH("</DOC>").
        run sendToQueue in ptpsession("SYNC2NETBANK",requestH,?,?,?).
        run deleteMessage in requestH.
        /*--------------------------------------------------------------------------------------------*/

        find current comm.netbankdoc no-lock no-error.

        message "End Process.".
    end.
end.

procedure get-node:
    def input parameter p-h-node as handle. /*1*/
    def input parameter p-ID as char. /*2*/
    def input parameter p-BANK_ID as char. /*3*/
    def input parameter p-NUM_DOC as char. /*4*/
    def input parameter p-DATE_DOC as char. /*5*/
    def input parameter p-DATE_SIGN as char. /*6*/
    def input parameter p-PAYER_NAME as char. /*7*/
    def input parameter p-STATUS as char. /*8*/
    def input parameter p-EXT_ID as char. /*9*/
    def input parameter p-ATTACHMENT as char. /*10*/
    def input-output parameter p-ID_OUT as char.  /*11*/
    def input-output parameter p-BANK_ID_OUT as char. /*12*/
    def input-output parameter p-NUM_DOC_OUT as char. /*13*/
    def input-output parameter p-DATE_DOC_OUT as char. /*14*/
    def input-output parameter p-DATE_SIGN_OUT as char. /*15*/
    def input-output parameter p-PAYER_NAME_OUT as char. /*16*/
    def input-output parameter p-STATUS_OUT as char. /*17*/
    def input-output parameter p-EXT_ID_OUT as char. /*18*/
    def input-output parameter p-ATTACHMENT_OUT as longchar. /*19*/

    def var j as inte.
    def var v-LogChild as logi.

    def var h-noderef as handle.
    def var h-child-node as handle.

    create x-noderef h-noderef no-error.
    create x-noderef h-child-node no-error.

    v-LogChild = false.
    v-LogChild = p-h-node:get-child(h-noderef,1) no-error.
    if not v-LogChild then leave.

    if p-h-node:name = p-ID then p-ID_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-BANK_ID then p-BANK_ID_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-NUM_DOC then p-NUM_DOC_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-DATE_DOC then p-DATE_DOC_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-DATE_SIGN then p-DATE_SIGN_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-PAYER_NAME then p-PAYER_NAME_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-STATUS then p-STATUS_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-EXT_ID then p-EXT_ID_OUT = cp-convert(h-noderef:node-value).
    if p-h-node:name = p-ATTACHMENT then h-noderef:node-value-to-longchar(p-ATTACHMENT_OUT).

    if p-h-node:num-children > 1 then do:
        do j = 1 to p-h-node:num-children:
            v-LogChild = false.
            v-LogChild = p-h-node:get-child(h-child-node,j).
            if not v-LogChild then next.

            run get-node(
            h-child-node, /*1*/
            p-ID, /*2*/
            p-BANK_ID, /*3*/
            p-NUM_DOC, /*4*/
            p-DATE_DOC, /*5*/
            p-DATE_SIGN, /*6*/
            p-PAYER_NAME, /*7*/
            p-STATUS, /*8*/
            p-EXT_ID, /*9*/
            p-ATTACHMENT, /*10*/
            input-output p-ID_OUT, /*11*/
            input-output p-BANK_ID_OUT, /*12*/
            input-output p-NUM_DOC_OUT, /*13*/
            input-output p-DATE_DOC_OUT, /*14*/
            input-output p-DATE_SIGN_OUT, /*15*/
            input-output p-PAYER_NAME_OUT, /*16*/
            input-output p-STATUS_OUT, /*17*/
            input-output p-EXT_ID_OUT, /*18*/
            input-output p-ATTACHMENT_OUT). /*19*/
        end.
    end.
end procedure.

function inWait returns logical.
    return not(v-terminate).
end.




