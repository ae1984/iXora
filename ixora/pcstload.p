/* pcstload.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff, Salary: Первоначальная загрузка данных
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-1
 * AUTHOR
        25/05/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        23/08/2012 id00810 - доработка для Salary, переход на ИИН
        05/09/2012 id00810 - добавлена проверка вида карты
        29/10/2012 id00810 - добавлена проверка РНН,ИИН и ФИО по базе НК (ТЗ 1555)
        20/12/2012 id00810 - исправлена ошибка определения филиала t-bnk для продукта staff
        25/12/2012 id00810 - перкомпиляция
        17.01.2013 Lyubov  - из поля "адрес" выходящих данных убираем символ №, т.к. не читается при создании xml файла
        13.03.2013 damir - Внедрено Т.З. № 1558,1582.
        13.05.2013 Lyubov - ТЗ № 1539, добавлены новые поля для установления КЛ
        10.06.2013 Lyubov - ТЗ № 1787, добавлена проверка наличия записи со статусом отличным от Closed
        03.09.2013 yerganat - tz1951,  добавил проверку  номера мобильного телефона при загрузке salary файла
        30/09/2013 Luiza  - ТЗ 2047 Замена символов  русского шрифтов каз (если не совпадают)
*/

def shared var s-pcprod as char no-undo.
def var v-bank      as char no-undo.
def var v-spf0      as char no-undo.
def var v-spf1      as char no-undo.
def var v-spf2      as char no-undo.
def var v-spf       as char no-undo.
def var v-spfn      as char no-undo.
def var i           as int  no-undo.
def var j           as int  no-undo.
def var m           as int  no-undo.
def var n           as int  no-undo.
def var k           as int  no-undo.
def var v-str       as char no-undo.
def var v-arc       as char no-undo.
def var v-home      as char no-undo.
def var v-exist1    as char no-undo.
def var v-filename  as char no-undo.
def var v-filename1 as char no-undo.
def var v-iinbin    as char no-undo.
def var v-txt1      as char no-undo init 'загружен'.
def var v-txt2      as char no-undo init 'не загружен'.
def var v-txt3      as char no-undo init 'ИИН'.
def var v-txt       as char no-undo init "Добрый день!\n\nФайл ДПК готов к печати.".
def var v-pctype    as char no-undo.
def var v-cif       as char no-undo.
def var v-iin       as char no-undo.
def var v-sname     as char no-undo.
def var v-fname     as char no-undo.
def var v-mname     as char no-undo.
def var v-name      as char no-undo.
def var v-names      as char no-undo.
def var v-namef      as char no-undo.
def var v-namem      as char no-undo.
def var v-nom       as char no-undo init '001'.
def var v-dt        as date no-undo format '99/99/9999'.
def var v-sal       as deci no-undo.
def var v-err       as logi no-undo.
def var v-crccode   as char no-undo.
def var v-crc       as inte no-undo.
def var v-geo       as inte no-undo.
def var v-mandat   as char no-undo.
def var errmobile   as char no-undo.

def stream r-in.
def stream r-out.

def temp-table t-prot no-undo
    field t-bnk   as char
    field t-namef as char
    field t-n     as char
    field t-rnn   as char
    field t-rez   as char
    field t-prim  as char.

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
        outstr = Caps(outstr).
    end.
    return outstr.
end.

{global.i}
{chbin.i}
{chk-rekv.i}
{chk-mobile.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.
input through value("ssh Administrator@`askhost` -q dir /b ' " + "C:\\PC\\in\\" + s-pcprod + "*.csv'") no-echo.
repeat:
    import  unformatted v-str.
    if v-str begins 'the system' or v-str = 'file not found' then do:
         message "Проверьте каталог C:\\PC\\in - нет файлов " + s-pcprod + "*.csv на подгрузку."
         view-as alert-box information buttons ok title " Внимание" .
         undo, return.
    end.
    v-spf0 = v-spf0 + v-str + '|'.
end.
v-spf0 = right-trim(v-spf0,'|').
do i = 1 to num-entries(v-spf0,"|"):
    if s-pcprod = 'staff' then do:
        find first pcstaff0 where pcstaff0.namef = entry(i,v-spf0,"|") no-lock no-error.
        if avail pcstaff0 then v-spf1 = v-spf1 + entry(i,v-spf0,"|") + "|".
        else do:
            if num-entries(entry(i,v-spf0,"|"),'_') <> 5
            then do:
                v-spf2 = v-spf2 + entry(i,v-spf0,"|") + "|".
                next.
            end.
            find first crc where crc.code = entry(4,entry(i,v-spf0,"|"),'_') no-lock no-error.
            if not avail crc then do:
                v-spf2 = v-spf2 + entry(i,v-spf0,"|") + "|".
                next.
            end.
        end.
    end.
    else do:
        if num-entries(entry(i,v-spf0,"|"),'_') < 2
        then do:
            v-spf2 = v-spf2 + entry(i,v-spf0,"|") + "|".
            next.
        end.
        v-cif = entry(2,entry(i,v-spf0,"|"),'_').
        if num-entries(v-cif,'.') = 2 then  v-cif = entry(1,v-cif,'.').
        find first cif where cif.cif = v-cif no-lock no-error.
        if not avail cif then do:
            v-spf2 = v-spf2 + entry(i,v-spf0,"|") + "|".
            next.
        end.
    end.
    v-spf = v-spf + entry(i,v-spf0,"|") + "|".
end.

if v-spf1 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf1,'|') + " были загружены ранее."
    view-as alert-box information buttons ok title " Внимание " .
end.
if v-spf2 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf2,'|') + " имеют некорректное название!"
    view-as alert-box information buttons ok title " Внимание " .
end.
if v-spf = '' then do:
    message "Нет новых файлов на подгрузку!"
    view-as alert-box information buttons ok title " Внимание " .
    return.
end.

input through value("ssh Administrator@`askhost` -q dir /b ' " + "C:\\PC\\arc\\';echo $?").
repeat:
    import  unformatted v-str.
end.
if v-str <> "0" then do:
    input through value("ssh Administrator@`askhost` -q md ' " + "C:\\PC\\arc\\';echo $?").
    repeat:
        import  unformatted v-str.
    end.
end.

v-arc = "/data/import/pc/".
input through value( "find " + v-arc + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-arc).
    unix silent value ("chmod 777 " + v-arc).
end.

v-arc = "/data/import/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-arc + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-arc).
    unix silent value ("chmod 777 " + v-arc).
end.

v-home = "./pc/" .
input through value( "find " + v-home + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-home).
end.

v-spf = right-trim(v-spf,'|').
do i = 1 to num-entries(v-spf, "|"):
    v-str = ''.
    v-filename = entry(i, v-spf, "|").
    if s-pcprod = 'salary' then do:
        find last pcstaff0 where pcstaff0.namef begins 'salary' + '_' + substr(v-bank,4,2) + '_' + entry(2,v-filename,'_') no-lock  no-error.
        if avail pcstaff0 then v-nom = string(int(substr(pcstaff0.namef,22,3)) + 1,'999').
        v-filename = 'salary' + '_' + substr(v-bank,4,2) + '_' + entry(1,entry(2,v-filename,'_'),'.') + '_' + v-nom + '.csv'.
    end.
    input through value("scp -q Administrator@`askhost`:" + "C:\\\\PC\\\\in\\\\" + entry(i, v-spf, "|") + " " + v-home + v-filename + ";echo $?").
    import unformatted v-str.

    if v-str <> "0" then do:
        message "Ошибка копирования файла " + entry(i, v-spf, "|") + "!~nДальнейшая работа невозможна!~Обратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание " .
        return.
    end.
    v-spfn = v-spfn + v-filename + "|".
end.
v-spfn = right-trim(v-spfn,'|').
unix silent value('cp ' + v-home + '*.* ' + v-arc).

if s-pcprod = 'salary' then do:
    find first cif where cif.cif = trim(entry(3,v-filename,'_')) no-lock no-error.
    if avail cif then v-geo = inte(substr(string(inte(cif.geo),"999"),3,1)).
    else do:
        message "Клиент не найден либо некорректное наименование загрузочного файла!!!" view-as alert-box buttons ok.
        return.
    end.
end.

do i = 1 to num-entries(v-spfn,"|"):
    do transaction:
        v-filename = entry(i,v-spfn,"|").
        unix silent value('echo "" >> ' + v-home + v-filename).
        v-str = "". j = 0. m = 0. n = 0.
        input stream r-in from value(v-home + v-filename).
        repeat:
            import stream r-in unformatted v-str.
            v-str = trim(v-str).
            v-str = trim(v-str,"'").
            v-str = trim(v-str,'"').

            if v-str ne "" and num-entries(v-str,';') = 21 then do:
                if entry(9,v-str,';') ne '' then do:
                    v-crccode = trim(entry(9,v-str,';')).
                    find first crc where crc.code = trim(v-crccode) no-lock no-error.
                    if not avail crc then next.
                end.
                else next.

                create t-prot.
                t-prot.t-bnk   = if s-pcprod = 'salary' then v-bank else 'TXB' + entry(2,v-filename,'_').
                t-prot.t-namef = v-filename.
                t-prot.t-n     = entry(1,v-str,';').
                t-prot.t-rnn   = entry(2,v-str,';').

                v-iinbin = trim(entry(2,v-str,';')).
                if length(v-iinbin) < 12 then do:
                    assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Неверная длина ИИН'.
                    n = n + 1.
                    next.
                end.
                find first rnn where rnn.bin = trim(v-iinbin) no-lock no-error.
                if not avail rnn then do:
                    assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'ИИН отсутствует в базе НК МФ'.
                    n = n + 1.
                    next.
                end.
                else do:
                    v-iin = trim(rnn.bin).
                    v-sname = trim(rnn.lname).
                    v-fname = trim(rnn.fname).
                    v-mname = trim(rnn.mname).
                end.
                v-name = trim(entry(3,v-str,';')).
                if v-name ne v-sname then do:
                    v-names = kzru(v-bank,trim(entry(3,v-filename,'_')),v-name,v-sname).
                    if v-names <> v-sname then do:
                        v-err = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-sname) then v-err = no.
                        if v-err then do:
                            assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Несоответствие фамилии по базе НК МФ!'
                            n = n + 1.
                            next.
                        end.
                    end.
                    else v-sname = v-names.
                end.
                v-name = trim(entry(4,v-str,';')).
                if v-name ne v-fname then do:
                    v-namef = kzru(v-bank,trim(entry(3,v-filename,'_')),v-name,v-fname).
                    if v-namef <> v-fname then do:
                        v-err = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-fname) then v-err = no.
                        if v-err then do:
                            assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Несоответствие имени по базе НК МФ!'
                            n = n + 1.
                            next.
                        end.
                    end.
                    else v-fname = v-namef.
                end.
                v-name = trim(entry(5,v-str,';')).
                if v-name ne v-mname then do:
                    v-namem = kzru(v-bank,trim(entry(3,v-filename,'_')),v-name,v-mname).
                    if v-namem <> v-mname then do:
                        v-err = yes.
                        if index(v-name,'?') > 0 then if chk-rekv (v-name,v-mname) then v-err = no.
                        if v-err then do:
                            assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Несоответствие отчества по базе НК МФ!'
                            n = n + 1.
                            next.
                        end.
                    end.
                    else v-mname = v-namem.
                end.
                if entry(6,v-str,';')  ne '' then do:
                    v-dt = date(trim(entry(6,v-str,';'))) no-error.
                    if error-status:error or length(entry(6,v-str,';')) > 10 then do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Некорректное значение ' + entry(6,v-str,';') + ' в поле Дата рождения'.
                        n = n + 1.
                        next.
                    end.
                end.
                find first pcstaff0 where pcstaff0.iin = trim(v-iinbin) and pcstaff0.sts <> 'Closed' no-lock no-error.
                if avail pcstaff0 then do:
                    assign t-prot.t-rez = v-txt2 t-prot.t-prim = v-txt3 + ' был загружен ранее, см.файл ' +  pcstaff0.namef.
                    n = n + 1.
                    next.
                end.
                find first codfr where codfr.codfr = 'pctype' and codfr.code = trim(entry(8,v-str,';')) no-lock no-error.
                if avail codfr then v-pctype = codfr.code.
                else do:
                    if trim(entry(8,v-str,';')) = 'Е' then v-pctype = 'E'.
                    else if trim(entry(8,v-str,';')) = 'С' then v-pctype = 'C'.
                    else do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Некорректное значение ' + entry(8,v-str,';') + ' в поле Вид карты'.
                        n = n + 1.
                        next.
                    end.
                end.
                if entry(9,v-str,';') ne '' then do:
                    v-crccode = trim(entry(9,v-str,';')).
                    find first crc where crc.code = v-crccode no-lock no-error.
                    if not avail crc then do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Некорректное значение ' + entry(9,v-str,';') + ' в поле Валюта'.
                        n = n + 1.
                        next.
                    end.
                    else v-crc = crc.crc.
                end.
                else do:
                    assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Поле Валюта пустое'.
                    n = n + 1.
                    next.
                end.
                if entry(11,v-str,';') ne '' then do:
                    v-dt = date(trim(entry(11,v-str,';'))) no-error.
                    if error-status:error or length(entry(11,v-str,';')) > 10 then do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Некорректное значение ' + entry(11,v-str,';') + ' в поле Дата выдачи документа'.
                        n = n + 1.
                        next.
                    end.
                end.
                if entry(12,v-str,';') ne '' then do:
                    v-dt = date(trim(entry(12,v-str,';'))) no-error.
                    if error-status:error or length(entry(12,v-str,';')) > 10 then do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Некорректное значение ' + entry(12,v-str,';') + ' в поле Срок действия удост.'.
                        n = n + 1.
                        next.
                    end.
                end.

                if v-geo = 1 then do:
                    if lookup("KZT",v-crccode) = 0 and trim(entry(7,v-str,';')) matches "*да*" then do:
                        assign t-prot.t-rez = v-txt2 t-prot.t-prim = 'Организация - резидент. Валютные счета только для сотрудников - нерезидентов'.
                        n = n + 1.
                        next.
                    end.
                end.
                if  s-pcprod = 'salary' and entry(17,v-str,';') ne '' then do:
                    errmobile = chk-mobile(entry(17,v-str,';')).
                    if errmobile <> '' then do:
                        assign t-prot.t-rez = v-txt2
                               t-prot.t-prim = errmobile.
                        n = n + 1.
                        next.
                    end.
                end.
                if entry(20,v-str,';') ne '' then do:
                    v-sal = deci(trim(entry(20,v-str,';'))) no-error.
                    if error-status:error then do:
                        assign t-prot.t-rez = v-txt2
                               t-prot.t-prim = 'Некорректное значение ' + trim(entry(20,v-str,';')) + ' в поле Сумма заработной платы'.
                        n = n + 1.
                        next.
                    end.
                    v-mandat = ''.
                    if entry(19,v-str,';') eq '' then v-mandat = v-mandat + 'Место рожд.,'.
                    if entry(21,v-str,';') eq '' then v-mandat = v-mandat + 'Дата приема на раб.'.
                    if v-mandat ne '' then do:
                        assign t-prot.t-rez = v-txt2
                               t-prot.t-prim = 'Не заполнены обязательные поля: ' + right-trim(v-mandat).
                        n = n + 1.
                        next.
                    end.
                end.
                if entry(21,v-str,';') ne '' then do:
                    v-dt = date(trim(entry(21,v-str,';'))) no-error.
                    if error-status:error or length(trim(entry(21,v-str,';'))) > 10 then do:
                        assign t-prot.t-rez = v-txt2
                               t-prot.t-prim = 'Некорректное значение ' + trim(entry(21,v-str,';')) + ' в поле Дата приема на работу'.
                        n = n + 1.
                        next.
                    end.
                end.

                create pcstaff0.
                pcstaff0.namef = v-filename.
                pcstaff0.ldt = g-today.
                pcstaff0.bank = if s-pcprod = 'staff' then 'TXB' + entry(2,v-filename,'_') else v-bank.
                pcstaff0.cifb = if s-pcprod = 'staff' then 'TXB' + entry(3,v-filename,'_') else entry(3,v-filename,'_').
                pcstaff0.pcprod = s-pcprod.

                pcstaff0.iin = v-iinbin. /*2*/ /*ИИН*/
                pcstaff0.sname = v-sname. /*3*/ /*Фамилия*/
                pcstaff0.fname = v-fname. /*4*/ /*Имя*/
                pcstaff0.mname = v-mname. /*5*/ /*Отчество*/
                if entry(6,v-str,';') ne '' then pcstaff0.birth = date(entry(6,v-str,';')). /*6*/ /*Дата рождения*/
                if trim(entry(7,v-str,';')) = 'Нет' then pcstaff0.rez = no. /*7*/ /*Резидент(да/нет)*/
                pcstaff0.pctype = v-pctype. /*8*/ /*Вид карты :E – Electron,C – Classic,G – Gold*/
                pcstaff0.crc = v-crc. /*9*/ /*Валюта*/
                pcstaff0.nomdoc = trim(entry(10,v-str,';')). /*10*/ /*№ удостоверения*/
                if entry(11,v-str,';') ne '' then pcstaff0.issdt = date(trim(entry(11,v-str,';'))). /*11*/ /*Дата выдачи удост.*/
                if entry(12,v-str,';') ne '' then pcstaff0.expdt = date(trim(entry(12,v-str,';'))). /*12*/ /*Срок действия удост.*/
                pcstaff0.issdoc = trim(entry(13,v-str,';')). /*13*/ /*Кем выдано удост.*/
                pcstaff0.addr[1] = trim(entry(14,replace(v-str,'№',''),';')). /*14*/ /*Адрес прописки*/
                pcstaff0.addr[2] = trim(entry(15,replace(v-str,'№',''),';')). /*15*/ /*Адрес проживания*/
                pcstaff0.tel[1] = trim(entry(16,v-str,';')). /*16*/ /*Домашний телефон*/
                pcstaff0.tel[2] = trim(entry(17,v-str,';')). /*17*/ /*Мобильный телефон*/
                pcstaff0.mail = trim(entry(18,v-str,';')). /*18*/ /*E-mail*/
                pcstaff0.bplace = trim(entry(19,v-str,';')). /*19*/ /*Место рождения*/
                pcstaff0.salary = deci(trim(entry(20,v-str,';'))). /*20*/ /*Сумма зар. платы - нетто*/
                pcstaff0.hdt = date(trim(entry(21,v-str,';'))). /*21*/ /*Дата устройства на работу*/

                pcstaff0.sts = 'new'.
                if pcstaff0.rez then pcstaff0.country = 'KAZ'.

                pcstaff0.tel[1]  = replace(pcstaff0.tel[1],'-','').
                pcstaff0.tel[1]  = replace(pcstaff0.tel[1],' ','').
                pcstaff0.tel[2]  = replace(pcstaff0.tel[2],'-','').
                pcstaff0.tel[2]  = replace(pcstaff0.tel[2],' ','').

                t-prot.t-rez = v-txt1.
                m = m + 1.
                if trim(entry(19,v-str,';')) <> '' and deci(trim(entry(20,v-str,';'))) <> 0 and date(trim(entry(21,v-str,';'))) <> ? then do:
                    create pkanketa.
                    assign
                    pkanketa.bank     = v-bank
                    pkanketa.credtype = '4'
                    pkanketa.ln       = next-value(anknom)
                    pkanketa.rnn      = v-iinbin
                    pkanketa.docnum   = entry(10,v-str,';')
                    pkanketa.name     = caps(v-sname) + ' ' + caps(v-fname) + ' ' + caps(v-mname)
                    pkanketa.rdt      = g-today
                    pkanketa.rwho     = g-ofc
                    pkanketa.crc      = 1
                    pkanketa.addr1    = entry(14,v-str,';')
                    pkanketa.addr2    = entry(15,v-str,';')
                    pkanketa.sts      = '01'.
                    find first cif where cif.cif = entry(3,v-filename,'_') no-lock no-error.
                    pkanketa.jobrnn   = cif.bin.
                    pkanketa.jobname  = cif.prefix + ' ' + cif.name.
                    pkanketa.jobaddr  = cif.addr[1] + cif.addr[2] + cif.addr[3].
                end.
            end.
            else do:
                if v-str matches '*ИИН*' or v-str matches '*1;2;3;4*' or v-str = '' then next.
                create t-prot.
                assign
                t-prot.t-bnk   = 'TXB' + entry(2,v-filename,'_')
                t-prot.t-namef = v-filename
                t-prot.t-n     = entry(1,v-str,';')
                t-prot.t-rnn   = entry(2,v-str,';')
                t-prot.t-rez   = 'не загружен'
                t-prot.t-prim  = 'количество столбцов не равно 21!' .
            end.
        end. /*repeat*/
    end. /*do transaction*/

    input stream r-in close.
    unix silent rm -f value(v-home + v-filename).

    input through value ("ssh Administrator@`askhost`  -q move " + " C:\\\\pc\\\\in\\\\" + entry(i, v-spf, "|") + " C:\\\\pc\\\\arc\\\\" + entry(i, v-spfn, "|") + ";echo $?").
    repeat:
        import unformatted v-exist1.
    end.
   if v-exist1 <> "0" then do:
        message "Ошибка копирования файла " +  entry(i, v-spf, "|") + " в архив C:\\pc\\arc!~Код ошибки " + v-exist1 + ".~nОбратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание " .
    end.
end. /* do */
if s-pcprod = 'salary' then v-txt  = "Добрый день!\n\nФайл Salary готов к печати.".
for each t-prot no-lock break by t-prot.t-bnk.
    if first-of(t-prot.t-bnk) then do:
        find first bookcod where bookcod.bookcod = 'pc'
                             and bookcod.code    = t-prot.t-bnk
                             no-lock no-error.
        if avail bookcod then run mail( entry(1,bookcod.name) + "@fortebank.com",g-ofc + "@metrocombank.kz", "Загрузка файлов",v-txt, "", "","").
        else message "В справочнике <pc> отсутствует код <" + t-prot.t-bnk + "> для рассылки сообщений.~nОбратитесь к администратору АБС!"
        view-as alert-box information buttons ok title " Внимание " .
    end.
end.

output stream r-out to pcstload.htm.
put stream r-out unformatted "<html><head><title></title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
find first cmp no-lock no-error.
put stream r-out unformatted "<br><br>" cmp.name "<br>" skip.
put stream r-out unformatted "<br>" "Протокол загрузки файлов " caps(s-pcprod) " за " string(g-today) "<br>" skip.
for each t-prot no-lock break by t-prot.t-namef :
    if first-of(t-prot.t-namef) then do:
        put stream r-out unformatted "<br>Файл: " + t-prot.t-namef + "<br>" skip.
        put stream r-out unformatted "</tr></table>" skip.
        put stream r-out unformatted "<br>" skip.
        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№ п/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" v-txt3 "</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Результат</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примечание</td>"
                  "</tr>" skip.
    end.
    put stream r-out unformatted
              "<tr>"
              "<td>" t-prot.t-n "</td>"
              "<td>" "'" + t-prot.t-rnn "</td>"
              "<td>" t-prot.t-rez "</td>"
              "<td>" t-prot.t-prim format 'x(70)' "</td>"
              "</tr>" skip.
    if last-of(t-prot.t-namef) then do:
        put stream r-out unformatted "</tr></table>" skip.
        put stream r-out unformatted "<br>" skip.
    end.
end.
output stream r-out close.

unix silent cptwin pcstload.htm excel.
unix silent value("rm -f pcstload.htm").
