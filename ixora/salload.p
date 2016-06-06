/* salload.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Проверка и загрузка файла в каталоге C/PC/IN
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.1.4.1.2
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        19.07.2013 damir - Внедрено Т.З. № 1931.
        30.07.2013 damir - Внедрено Т.З. № 1991.
        30/09/2013 Luiza  - ТЗ 2047 Замена символов  русского шрифтов каз (если не совпадают)
        01.10.2013 yerganat -  находить  банк только со статусом 0
        17.10.2013 yergant - TZ1750, swiftchk.i проверка swift файла
*/
{chbin.i}
{global.i}
{get-kod.i}

{chkaaa20.i}
{chk12_innbin.i}
{chkswiftfio.i}


def sub-menu m-f1
    menu-item m-load label "Загрузить".

def sub-menu m-f2
    menu-item m-tr label "Создать".

def sub-menu m-f3
    menu-item m-exit label "ВЫХОД".

def menu m-pc menubar
    sub-menu m-f1 label "ФАЙЛ"
    sub-menu m-f2 label "ТРАНЗАКЦИЯ"
    sub-menu m-f3 label "ВЫХОД".

def stream str01.
def stream str41.

def var v-strs as char no-undo.
def var v-ss as char no-undo.

def var v-str-count as integer no-undo.
def var v-payment-type as char no-undo.

def temp-table ttmps no-undo
    field sstr as char /*содержимое строки файла*/
    field scnt as inte /*порядковый номер строки в файле*/
    index ttmps-idx sstr
    index idx1 is primary scnt ascending
    index idx2 sstr ascending
               scnt ascending
    index idx3 sstr ascending.

def var v-32b as decimal no-undo.
def var v-32a as decimal no-undo.
def var v-32ad as char no-undo.
def var v-32ab as char no-undo.
def var v-tdt as char no-undo.
def var v-strknp as char no-undo.
def var v-errnmb as integer no-undo.
def var v-infile as char no-undo.
def var v-rnn as int no-undo.
def var v-ben as char no-undo.
def var bk as logi no-undo.
def var aaaben as char no-undo.
def var chk as int no-undo.
def var sch like aaa.aaa no-undo.
def var irs as int no-undo.
def var geo as int no-undo.
def var data as int no-undo.
def var v-date as date no-undo.
def var v-32b_crc as inte no-undo.
def var v-32a_crc as inte no-undo.

def var v-errcnt as integer no-undo.
def var ourbank as char no-undo.

def buffer b-ttmps for ttmps.
def buffer b-pcstaff0 for comm.pcstaff0.
def buffer b-aaa for aaa.
def buffer b-cif for cif.
def buffer b-crc for crc.
def buffer b-crcpro for crcpro.
def buffer b-salary_p for comm.salary_p.

def var v-nxt as inte.

def temp-table t-c1 no-undo
    field cif as char
    field cifname as char
    field dacc as char
    field cacc as char
    field sum as deci format ">>>>>>>>>>>>>>>>>>>>>>9.99"
    field crc as inte
    field fname as char
    field jou as char
    field jh1 as inte init ?
    field jh2 as inte init ?
    field rem as char
index idx1 is primary fname ascending.

def temp-table t-c2 no-undo
    field k as inte
    field aaa as char
    field crc as inte
    field sum as deci
    field jh as inte init ?
    field ref as char
    field fname as char
index idx1 is primary fname ascending
                      k ascending
index idx2 fname ascending.

def new shared var s-jh like jh.jh.
def var vdel as char initial "^" .
def var shcode as char.
def var rdes as char.
def var rcode as inte.
def var v-yn as logi.
def var v-kont as inte.
def var v-amt as deci.
def var v-trx as char.
def var vparam as char.
def var v-param as char.
def var v-sumconv as deci.
def var v-ans as logi.
def var v-fname as char.
def var v-assign as char.
def var v-nom as inte.
def var v-jou1 as char.
def var v-jou2 as char.
def var v-names      as char no-undo.
def var v-namef      as char no-undo.
def var v-namem      as char no-undo.
def var v-gaaa       as char.

def query qh for t-c1 scrolling.

def browse b-pc query qh no-lock
    displ t-c1.fname column-label "Наименование файла" FORMAT "X(25)"
with width 30 5 down title "<ENTER>-выбор".

def frame f-pc
    b-pc skip
with centered width 32 row 10 title "СПИСОК ЗАГРУЖАЕМЫХ ФАЙЛОВ".

function chk-bik returns logical (p-bic as char, p-acc as char).
    find last bankl where bankl.mntrm = substr(p-acc,5,3) and bankl.sts = 0 no-lock no-error.
    if avail bankl then do:
       if bankl.bank = p-bic  then return true.
       else return false.
    end. else
   return false.
end.

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

find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
	message	"Отсутсвует настройка OURBNK в справочнике sysc!" skip
    		"Обратитесь в ДИТ с этим сообщением!" view-as alert-box title "Внимание".
	return.
end.
ourbank = trim(sysc.chval).

empty temp-table t-c1.
empty temp-table t-c2.

on end-error of frame f-pc do:
    hide frame f-pc.
end.

on return of b-pc in frame f-pc do:
    get current qh no-lock.
    if avail t-c1 then v-fname = t-c1.fname.
    hide frame f-pc.
end.

ON CHOOSE OF menu-item m-load DO:
    v-errnmb = 0.
    output to swift_report.txt.
    /* проверки файлов платежей */
        input stream str01 through value("ssh Administrator@`askhost` dir /b ' " + "C:\\PC\\IN\\" + "*.*'")  no-echo. /*Читаем содержимое каталога C:\PC\IN*/
        repeat:
            import stream str01 unformatted v-ss. /*получим имя файла*/

            v-infile = ":" + "C:\\\\PC\\\\IN\\\\" + v-ss + " ". /*сформируем полный путь к нему*/
            unix silent value ("scp " + " Administrator@`askhost`" + v-infile + "repfs.t").  /*скопируем на сервер*/
            unix silent dos-un "repfs.t repfs.tt". /*перекодируем*/

            v-str-count = 1. /*количество строк скинем на 1*/

            input stream str41 from "repfs.tt". /*читаем содержимое файла*/
            repeat:
                import stream str41 unformatted v-strs.
                v-strs = trim(v-strs).

                create ttmps.
                assign
                    ttmps.sstr = v-strs
                    ttmps.scnt = v-str-count.

                v-str-count = v-str-count + 1.
            end.
            input stream str41 close.

            put unformatted "==========================================================" skip.
            put unformatted "Файл: " v-ss skip.
            put unformatted "==========================================================" skip(1).

            {swiftchk.i} /*Дополнительные проверки в swift файле*/

            find first ttmps where ttmps.sstr matches "*1:F01K054700000000001000001*" no-lock no-error.
            if not avail ttmps then do:
                put unformatted " ----- Неверное значение в 1 блоке" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
            end.

            find first ttmps where ttmps.sstr matches "*2:I102SGROSS000000U3003*" no-lock no-error.
            if not avail ttmps then do:
                put unformatted " ----- Неверное значение во 2 блоке" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
            end.

            find first ttmps where ttmps.sstr begins ":20:" no-lock no-error.
            if not avail ttmps then do:
                put unformatted " ----- Отсутствует поле :20:" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
            end.

            find first ttmps where ttmps.sstr begins ":50:/D/" no-lock no-error.
            if not avail ttmps then do:
                put unformatted " ----- Отсутствует поле :50:/D/" skip.
                v-errnmb = v-errnmb + 1.
                v-errcnt = v-errcnt + 1.
            end.
            else do:
                find first aaa where aaa.aaa = trim(replace(ttmps.sstr,":50:/D/","")) no-lock no-error.
                if not avail aaa then do:
                    put unformatted " ----- Неверное значение в поле :50:/D/ -> " trim(replace(ttmps.sstr,":50:/D/","")) skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                else sch = aaa.aaa.
            end.

                find first ttmps where ttmps.sstr begins ":52B:" no-lock no-error.
                if avail ttmps then do:
                    if trim(replace(ttmps.sstr,":52B:","")) <> "FOBAKZKA" then do:
                        put unformatted " ----- Неверное значение в поле :52B:" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутсвует поле :52B:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.

                find first ttmps where ttmps.sstr begins ":57B:" no-lock no-error.
                if avail ttmps then do:
                    v-ben = trim(replace(ttmps.sstr,":57B:","")).
                    find last bankl where bankl.bank = v-ben no-lock no-error.
                    if not avail bankl then do:
                        put unformatted " ----- Неверное значение в поле :57B:" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутсвует поле :57B:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.

                find first ttmps where ttmps.sstr begins ":59:" no-lock no-error.
                if avail ttmps then do:
                    aaaben = trim(replace(ttmps.sstr,":59:","")).
                    bk = chk-bik(v-ben,aaaben).
                    if bk = no then do:
                        put unformatted " ----- Неверное значение в поле :59:" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле :59:" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.

                if v-bin then do:
                    for each ttmps where ttmps.sstr begins "/IDN/" no-lock:
                    v-rnn = LENGTH(trim(replace(ttmps.sstr,"/IDN/",""))).
                        if v-rnn <> 12 then do:
                            put unformatted " ----- Неверное значение в поле /IDN/ " skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                    end.

                    find first ttmps where ttmps.sstr begins "/IDN/" and ttmps.scnt >= 5 and ttmps.scnt <= 9 no-lock no-error.
                    if avail ttmps then do:
                        find first aaa where aaa.aaa = sch no-lock no-error.
                        if avail aaa then do:
                            find first cif where cif.cif = aaa.cif no-lock no-error.
                            if not avail cif then do:
                                put unformatted " ----- Клиент не найден " skip.
                                v-errnmb = v-errnmb + 1.
                                v-errcnt = v-errcnt + 1.
                            end.
                            else do:
                                if trim(replace(ttmps.sstr,"/IDN/","")) <> cif.bin then do:
                                    put unformatted " ----- Неверное значение в поле /IDN/ отправителя " skip.
                                     v-errnmb = v-errnmb + 1.
                                    v-errcnt = v-errcnt + 1.
                                end.
                            end.
                        end.
                    end.
                    if not avail ttmps then do:
                        put unformatted " ----- Отсутствует поле /IDN/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.

                    for each ttmps where ttmps.sstr begins "/IDN/" and ttmps.scnt > 20 no-lock:
                    if avail ttmps then do:
                        find first rnn where rnn.bin = trim(replace(ttmps.sstr,"/IDN/","")) no-lock no-error.
                        if not avail rnn then do:
                            find first rnnu where rnnu.bin = trim(replace(ttmps.sstr,"/IDN/","")) no-lock no-error.
                            if not avail rnnu then do:
                                put unformatted " -----  ИИН/БИН - " trim(replace(ttmps.sstr,"/IDN/","")) " в базе НК не найден" skip.
                                v-errnmb = v-errnmb + 1.
                                v-errcnt = v-errcnt + 1.
                            end.
                        end.
                    end.
                    if not avail ttmps then do:
                        put unformatted " ----- Отсутствует поле /RNN/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                    end.
                end.

                find first ttmps where ttmps.sstr matches "*/IRS/*" and ttmps.scnt >= 9 and ttmps.scnt <= 11 no-lock no-error.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /IRS/ отправителя" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                else do:
                    find first aaa where aaa.aaa = sch no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if not avail cif then do:
                            put unformatted " ----- Клиент не найден" skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                        else do:
                            irs = int(trim(replace(ttmps.sstr,"/IRS/",""))).
                            geo = int(substr(cif.geo, 3, 1)).
                            if (irs < 1 or irs > 2) or irs <> geo then do:
                                put unformatted " ----- Неверное значение в поле /IRS/ отправителя" skip.
                                v-errnmb = v-errnmb + 1.
                                v-errcnt = v-errcnt + 1.
                            end.
                        end.
                    end.
                end.

                find first ttmps where ttmps.sstr matches "*/IRS/*" and ttmps.scnt >= 15 and ttmps.scnt <= 19 no-lock no-error.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /IRS/ получателя" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                else do:
                    irs = int(trim(replace(ttmps.sstr,"/IRS/",""))).
                    if irs <> 1 then do:
                        put unformatted " ----- Неверное значение в поле /IRS/ получателя" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.

                find first ttmps where ttmps.sstr matches "*/SECO/*" and ttmps.scnt >= 2 and ttmps.scnt <= 12 no-lock no-error.
                if not avail ttmps then do:
                    put unformatted " ----- Отсутствует поле /SECO/ отправителя" ttmps.sstr skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.
                else do:
                    find first aaa where aaa.aaa = sch no-lock no-error.
                    if avail aaa then do:
                        if int(trim(replace(ttmps.sstr,"/SECO/",""))) <> int(substring(get-kod("", aaa.cif), 2, 1)) then do:
                            put unformatted " ----- Неверное значение в поле /SECO/ отправителя" ttmps.sstr skip.
                            v-errnmb = v-errnmb + 1.
                            v-errcnt = v-errcnt + 1.
                        end.
                    end.
                end.

                find first ttmps where ttmps.sstr begins ":32A" no-lock no-error.
                if avail ttmps then v-32ab = substring(ttmps.sstr, 6, 6).

                v-tdt = substring(string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99"), 3, 6).

                if v-tdt <> v-32ab then do:
                    put unformatted " ----- Неверное значение в поле :32А: - дата валютирования не соотвествует дате проведения платежа " skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.

                for each ttmps where ttmps.sstr begins "/NAME/" no-lock .
                    if length(trim(ttmps.sstr)) > 66 then do:
                        put unformatted " ----- Неверное значение в поле /NAME/ - длина более 60 символов" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                     end.
                end.

                find first ttmps where ttmps.sstr begins "/VO/" no-lock no-error.
                if avail ttmps then do:
                    if integer(trim(replace(ttmps.sstr,"/VO/",""))) <> 1 then do:
                        put unformatted " ----- Неверное значение в поле /VO/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.

                find first ttmps where ttmps.sstr begins "/PSO/" no-lock no-error.
                if avail ttmps then do:
                    if length(trim(replace(ttmps.sstr,"/PSO/",""))) > 2 then do:
                        put unformatted " ----- Неверное значение в поле /PSO/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.

                find first ttmps where ttmps.sstr begins "/PRT/" no-lock no-error.
                if avail ttmps then do:
                    if length(trim(replace(ttmps.sstr,"/PRT/",""))) > 2 then do:
                        put unformatted " ----- Неверное значение в поле /PRT/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.

                find first ttmps where ttmps.sstr begins "/DATE/" no-lock no-error.
                if avail ttmps then do:
                    v-date = date(inte(substr(ttmps.sstr,9,2)),inte(substr(ttmps.sstr,11,2)),inte(substr(ttmps.sstr,7,2))).
                    if today < v-date then do:
                        put unformatted " ----- Неверное значение в поле /DATE/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.

                find first ttmps where ttmps.sstr begins "/KNP/" no-lock no-error.
                if avail ttmps and replace(ttmps.sstr,"/KNP/","") <> ? then do:
                    v-strknp = replace(ttmps.sstr,"/KNP/","").
                    if int(v-strknp) <> 311 then do:
                        put unformatted " ----- Неверное значение в поле /KNP/" skip.
                        v-errnmb = v-errnmb + 1.
                        v-errcnt = v-errcnt + 1.
                    end.
                end.
                else do:
                    put unformatted " ----- Отсутствует поле /KNP/" skip.
                    v-errnmb = v-errnmb + 1.
                    v-errcnt = v-errcnt + 1.
                end.

            find first ttmps where ttmps.sstr begins ":21:" no-lock no-error.
            if avail ttmps then do:
                v-32a = 0.
                find first b-ttmps where b-ttmps.sstr begins ":32A:" no-lock no-error.
                if avail b-ttmps then do:
                    v-32a = v-32a + deci( replace(substr(b-ttmps.sstr,15,length(b-ttmps.sstr)),",",".") ) no-error.
                    if ERROR-STATUS:ERROR then do:
                        put unformatted " ----- Некорректное поле :32A:" skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                    end.
                    find first b-crc where b-crc.code = substr(b-ttmps.sstr,12,3) no-lock no-error.
                    if avail b-crc then v-32a_crc = b-crc.crc.
                    else do:
                        put unformatted " ----- Не найден код валюты в справочнике поля :32A:" skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                    end.
                end.
                else do:
                    put unformatted " ----- Отсутствует поле :32A:" skip.
                    v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                end.

                v-32b = 0.
                for each ttmps where ttmps.sstr begins ":21:" no-lock:
                    find first t-c2 where t-c2.fname = v-ss and t-c2.k = inte(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) exclusive-lock no-error.
                    if not avail t-c2 then do:
                        create t-c2.
                        t-c2.k = inte(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) no-error.
                        t-c2.fname = v-ss.
                    end.
                    find first b-ttmps where b-ttmps.sstr begins ":21:" and b-ttmps.scnt > ttmps.scnt no-lock no-error.
                    if avail b-ttmps then v-nxt = b-ttmps.scnt.
                    else find first b-ttmps where b-ttmps.sstr begins ":32A:" and b-ttmps.scnt > ttmps.scnt no-lock no-error.
                         if avail b-ttmps then v-nxt = b-ttmps.scnt.
                         else do: put unformatted " ----- Отсутствует поле :32A:" skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1. end.

                    find first b-ttmps where b-ttmps.sstr begins "/IDN/" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                    if avail b-ttmps then do:
                        find first b-pcstaff0 where b-pcstaff0.iin = trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/IDN/") + 5,length(b-ttmps.sstr))) no-lock no-error.
                        if avail b-pcstaff0 then do:
                            find first b-ttmps where b-ttmps.sstr begins "/FM/" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                            if avail b-ttmps then do:
                                if b-pcstaff0.sname <> trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/FM/") + 4,length(b-ttmps.sstr))) then do:
                                    v-names = kzru(b-pcstaff0.bank,b-pcstaff0.cifb,trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/FM/") + 4,length(b-ttmps.sstr))),b-pcstaff0.sname).
                                    if b-pcstaff0.sname <> v-names then do:
                                        put unformatted " ----- Несоот-е фамилии ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                                    end.
                                end.
                            end.
                            else do: put unformatted " ----- Отсутствует поле /FM/ для ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1. end.
                            find first b-ttmps where b-ttmps.sstr begins "/NM/" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                            if avail b-ttmps then do:
                                if b-pcstaff0.fname <> trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/NM/") + 4,length(b-ttmps.sstr))) then do:
                                    v-namef = kzru(b-pcstaff0.bank,b-pcstaff0.cifb,trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/NM/") + 4,length(b-ttmps.sstr))),b-pcstaff0.fname).
                                    if b-pcstaff0.fname <> v-namef then do:
                                        put unformatted " ----- Несоот-е имени ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                                    end.
                                end.
                            end.
                            else do: put unformatted " ----- Отсутствует поле /NM/ для ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1. end.
                            find first b-ttmps where b-ttmps.sstr begins "/FT/" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                            if avail b-ttmps then do:
                                if b-pcstaff0.mname <> trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/FT/") + 4,length(b-ttmps.sstr))) then do:
                                    v-namem = kzru(b-pcstaff0.bank,b-pcstaff0.cifb,trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/FT/") + 4,length(b-ttmps.sstr))),b-pcstaff0.mname).
                                    if b-pcstaff0.mname <> v-namem then do:
                                        put unformatted " ----- Несоот-е отчества ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                                    end.
                                end.
                            end.
                            else do: put unformatted " ----- Отсутствует поле /FT/ для ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1. end.

                            find first b-ttmps where b-ttmps.sstr begins "/LA/" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                            if avail b-ttmps then do:
                                if b-pcstaff0.aaa <> trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/LA/") + 4,length(b-ttmps.sstr))) then do:
                                    put unformatted " ----- Несоот-е номера счета ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                                end.
                                t-c2.aaa = trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/LA/") + 4,length(b-ttmps.sstr))).
                            end.
                            else do: put unformatted " ----- Отсутствует поле /LA/ для ИИН - " b-pcstaff0.iin skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1. end.
                        end.
                        else do:
                            put unformatted " ----- Отсутствует pcstaff0 для /IDN/ - " trim(substr(b-ttmps.sstr,index(b-ttmps.sstr,"/IDN/") + 5,length(b-ttmps.sstr))) skip.
                            v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                        end.
                    end.
                    else do:
                        put unformatted " ----- Отсутствует поле /IDN/ для :21: - " trim(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) skip.
                        v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                    end.

                    find first b-ttmps where b-ttmps.sstr begins ":32B:" and b-ttmps.scnt > ttmps.scnt and b-ttmps.scnt < v-nxt no-lock no-error.
                    if avail b-ttmps then do:
                        v-32b = v-32b + deci(replace(substr(b-ttmps.sstr,9,length(b-ttmps.sstr)),",",".")) no-error.
                        if ERROR-STATUS:ERROR then do:
                            put unformatted " ----- Некорректное поле :32B: для :21: - " trim(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) skip.
                            v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                        end.
                        t-c2.sum = deci( replace(substr(b-ttmps.sstr,9,length(b-ttmps.sstr)),",",".") ) no-error.
                        find first b-crc where b-crc.code = substr(b-ttmps.sstr,6,3) no-lock no-error.
                        if avail b-crc then v-32b_crc = b-crc.crc.
                        else do:
                            put unformatted " ----- Не найден код валюты в справочнике поля :32B:" skip. v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                        end.
                        if v-32b_crc <> v-32a_crc then do:
                            put unformatted " ----- Валюта поля :32B: не равна валюте поля :32A: для :21: - " trim(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) skip.
                            v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                        end.
                        t-c2.crc = v-32b_crc.
                    end.
                    else do:
                        put unformatted " ----- Отсутствует поле :32B: для :21: - " trim(substr(ttmps.sstr,index(ttmps.sstr,":21:") + 4,length(ttmps.sstr))) skip.
                        v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                    end.
                end.
                if v-32b <> v-32a then do:
                    put unformatted " ----- Суммы полей :32B: и поля :32A: не равны" skip.
                    v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
                end.
            end.
            else do:
                put unformatted " ----- Отсутствуют поля :21:" skip.
                v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
            end.

            v-assign = "".
            find first ttmps where ttmps.sstr begins "/ASSIGN/" no-lock no-error.
            if avail ttmps then v-assign = trim(substr(ttmps.sstr,index(ttmps.sstr,"/ASSIGN/") + 8,length(ttmps.sstr))).
            else do:
                put unformatted " ----- Отсутствует поле /ASSIGN/" skip.
                v-errnmb = v-errnmb + 1. v-errcnt = v-errcnt + 1.
            end.

            for each ttmps.
                delete ttmps.
            end.

            if v-errcnt <> 0 then
            do:
                unix silent value ("ssh Administrator@`askhost`  mkdir C:\\\\PC\\\\ERROR").
                unix silent value ("ssh Administrator@`askhost`  move /Y " + "C:\\\\PC\\\\IN\\\\" + v-ss + " " +  "C:\\\\PC\\\\ERROR\\\\" + v-ss ).
            end.
            else do:
                find t-c1 where t-c1.fname = v-ss no-lock no-error.
                if not avail t-c1 then do:
                    create t-c1.
                    t-c1.fname = v-ss.
                    t-c1.dacc = sch.
                    t-c1.cacc = aaaben.
                    t-c1.sum = v-32a.
                    find b-aaa where b-aaa.aaa = sch no-lock no-error.
                    if avail b-aaa then do:
                        t-c1.cif = b-aaa.cif.
                        t-c1.crc = b-aaa.crc.
                        find b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
                        if avail b-cif then t-c1.cifname = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
                    end.
                    t-c1.rem = v-assign.
                end.
            end.

            v-errcnt = 0.
        end.
        input stream str01 close. /*Окончание чтения каталога C:\PC\IN, т.е. файлы кончились*/

        put unformatted "==========================================================" skip.
        put unformatted " ----- ВСЕГО ОБНАРУЖЕНО " string(v-errnmb) " ОШИБОК. " skip.
    output close.

    if v-errnmb > 0 then  /*если имели место ошибки*/
        run menu-prt("swift_report.txt"). /*то выведем отчет об ошибках на экран*/
    else
    do:
        def var home as char.
        home = trim(OS-GETENV("HOME")).
        file-info:file-name = home + '/errors.img'.
        pause 0.
        if file-info:file-type <> ? then run menu-prt(home + '/errors.img').
    end.

    open query qh for each t-c1 no-lock.

    enable all with frame f-pc.
    wait-for "return" of frame f-pc focus b-pc.
END.

ON CHOOSE OF menu-item m-tr DO:

    find first t-c1 where t-c1.fname = v-fname exclusive-lock no-error.
    if avail t-c1 then do:
        if t-c1.jh1 = ? and t-c1.jh2 = ? then do:
            DO TRANSACTION on ENDKEY undo,leave:
                v-kont = 0. v-amt = 0.
                run SumTar(t-c1.cif,t-c1.sum,t-c1.crc,"058",input-output v-kont,input-output v-amt).
                find last b-salary_p where b-salary_p.acc = t-c1.dacc and b-salary_p.sum = t-c1.sum and b-salary_p.del = ? and b-salary_p.knp <> "" exclusive-lock no-error.
                if avail b-salary_p then do:
                    find first aas where aas.aaa = b-salary_p.acc and aas.ln = b-salary_p.ln exclusive-lock no-error.
                    if avail aas and aas.chkamt = b-salary_p.sum then do:
                        run aashis.

                        find first aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
                        if avail aaa then aaa.hbal = aaa.hbal - aas.chkamt.
                        release aaa.
                        delete aas.
                        b-salary_p.del = g-today.
                    end.
                    else do: release b-salary_p. undo,leave. end.
                    if b-salary_p.com > 0 then do:
                        find first aas where aas.aaa = b-salary_p.acc and aas.ln = inte(b-salary_p.info[10]) exclusive-lock no-error.
                        if avail aas and aas.chkamt = b-salary_p.com then do:
                            run aashis.

                            find first aaa where aaa.aaa = aas.aaa exclusive-lock.
                            if avail aaa then aaa.hbal = aaa.hbal - aas.chkamt.
                            release aaa.
                            delete aas.
                            b-salary_p.del = g-today.
                        end.
                        else do: release b-salary_p. undo,leave. end.
                    end.
                    v-nom = b-salary_p.nom.
                    release b-salary_p.
                end.
                else do:
                    MESSAGE "Не проведена регистрация з/п платежей Salary в п.м. 15.1.4.1.1" view-as alert-box buttons ok.
                    undo,leave.
                end.

                /*Основная операция*/
                shcode = "PSY0047".
                vparam = "" + vdel + string(t-c1.sum) + vdel + t-c1.dacc + vdel + t-c1.cacc  + vdel + t-c1.rem.
                s-jh = 0.
                run trxgen(shcode,vdel,vparam,"jou","", output rcode,output rdes,input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    message "1 - Проводка не была сделана!" view-as alert-box ERROR.
                    delete t-c1.
                    for each t-c2 where t-c2.fname = t-c1.fname exclusive-lock:
                        delete t-c2.
                    end.
                    undo,leave.
                end.
                else do:
                    message "1 - Проводка сделана!" s-jh view-as alert-box.
                    run trxsts(s-jh, 6, output rcode, output rdes).
                    run jou.
                    v-jou1 = trim(return-value).
                    run chgsts("JOU",v-jou1,"NEW").
                    release cursts.
                    /*-------Копия документа с новым типом-------*/
                    find joudop where joudop.docnum = v-jou1 no-error.
                    if not avail joudop then do:
                        create joudop.
                        joudop.docnum = v-jou1.
                    end.
                    joudop.who = g-ofc.
                    joudop.whn = g-today.
                    joudop.jh = s-jh.
                    joudop.tim = time.
                    joudop.type = "SF1". /*Новый тип документа*/
                    /*------------------------------------------*/
                    find joudoc where joudoc.docnum = v-jou1 exclusive-lock no-error.
                    if avail joudoc then do:
                        joudoc.comamt = v-amt.
                        joudoc.comacctype = "2".
                        joudoc.comacc = t-c1.dacc.
                        joudoc.comcur = t-c1.crc.
                        joudoc.comcode = "058".
                        joudoc.infodoc[1] = string(v-nom,"zzzzzzzzzzzzzzzzzz9"). /*Номер платежного поручения,на бумажном носителе*/
                        find current joudoc no-lock no-error.
                    end.
                    /*Начальники операционного отдела филиалов;Главные бухгалтера филиалов*/
                    run mail("oper.branches@fortebank.com;gl.buh.branches@fortebank.com", "BANK <abpk@metrocombank.kz>", "Необходимо отконтролировать JOU документ " + v-jou1 + " в п.м. 2.4.1.1","" , "1", "","").
                    t-c1.jou = v-jou1.
                    t-c1.jh1 = s-jh.
                end.

                /*Комиссия*/
                if v-kont <> 0 then do:
                    find first pcsootv where pcsootv.bank = ourbank and pcsootv.cif = t-c1.cif no-lock no-error.
                    if available pcsootv and trim(pcsootv.aaa) <> "" then v-gaaa = trim(pcsootv.aaa).
                    else v-gaaa = t-c1.dacc.
                    if t-c1.crc = 1 then do:
                        v-param = string(v-amt) + vdel + v-gaaa /*t-c1.dacc*/ + vdel + string(v-kont) + vdel + 'Комиссия за зачисление по Salary' + vdel + '' + vdel + '840'.
                        v-trx   = 'uni0023'.
                    end.
                    else do:
                        v-sumconv = 0.
                        find last b-crcpro where b-crcpro.crc = t-c1.crc and b-crcpro.regdt <= g-today no-lock no-error.
                        if avail b-crcpro then v-sumconv = v-amt * b-crcpro.rate[1].
                        else do: message "This isn't record crcpro!!!" view-as alert-box buttons ok. next. end.

                        v-param = string(v-amt) + vdel + v-gaaa /*t-c1.dacc*/ + vdel + "Комиссия за зачисление по Salary" + vdel + "1" + vdel + "4" + vdel + "840" + vdel + string(v-sumconv) + vdel +
                        string(v-kont) + vdel + "Комиссия за зачисление по Salary".
                        v-trx   = 'uni0013'.
                    end.
                    s-jh = 0.
                    run trxgen (v-trx, vdel, v-param, "cif", "", output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        message "2 - Проводка по комиссии не была сделана!" view-as alert-box ERROR.
                        delete t-c1.
                        for each t-c2 where t-c2.fname = t-c1.fname exclusive-lock:
                            delete t-c2.
                        end.
                        undo,leave.
                    end.
                    else do:
                        message "2 - Проводка по комиссии сделана!" s-jh view-as alert-box.
                        run trxsts(s-jh, 6, output rcode, output rdes).
                        run jou.
                        v-jou2 = trim(return-value).
                        find joudoc where joudoc.docnum = v-jou2 exclusive-lock no-error.
                        if avail joudoc then do:
                            joudoc.comamt = v-amt.
                            joudoc.comacctype = "2".
                            joudoc.comacc = t-c1.dacc.
                            joudoc.comcur = t-c1.crc.
                            joudoc.comcode = "058".
                            find current joudoc no-lock no-error.
                        end.
                        t-c1.jh2 = s-jh.
                    end.
                end.

                if avail t-c1 and t-c1.jh1 <> ? and t-c1.jh2 <> ? then do:
                    for each t-c2 where t-c2.fname = t-c1.fname no-lock:
                        create pcpay.
                        pcpay.bank = ourbank.
                        pcpay.aaa = t-c2.aaa.
                        pcpay.crc = t-c2.crc.
                        pcpay.amt = t-c2.sum.
                        pcpay.ref = t-c1.jou + '_' + string(t-c2.k).
                        pcpay.jh = t-c1.jh1.
                        pcpay.sts = 'salload'.
                        pcpay.who = g-ofc.
                        pcpay.whn = g-today.
                        pcpay.info[1] = substr(ourbank,4,2).
                    end.
                end.
                release joudoc.
            END.
        end.
        else MESSAGE "Проводки созданы" VIEW-AS alert-box buttons ok.
    end.
    else MESSAGE "Необходимо загрузить файл!" VIEW-AS alert-box buttons ok.

END.

procedure aashis:
    CREATE aas_hist.
    aas_hist.cif = t-c1.cif.
    aas_hist.name = t-c1.cifname.
    aas_hist.aaa = aas.aaa.
    aas_hist.ln = aas.ln.
    aas_hist.sic = aas.sic.
    aas_hist.chkdt = aas.chkdt.
    aas_hist.chkno = aas.chkno.
    aas_hist.chkamt = aas.chkamt.
    aas_hist.payee = aas.payee + ' Платеж проведен.'.
    aas_hist.expdt = aas.expdt.
    aas_hist.regdt = aas.regdt.
    aas_hist.who = g-ofc.
    aas_hist.whn = g-today.
    aas_hist.tim = time.
    aas_hist.del = aas.del.
    aas_hist.chgdat = g-today.
    aas_hist.chgtime = time.
    aas_hist.chgoper = 'D'.
end procedure.

procedure SumTar:
    def input parameter p-cif as char.
    def input parameter p-sum as deci.
    def input parameter p-crc as inte.
    def input parameter p-str5 as char.
    def input-output parameter p-kont as deci.
    def input-output parameter p-amt as deci.

    p-kont = 0.
    find first tarifex where tarifex.cif = p-cif and tarifex.str5 = p-str5 no-lock no-error.
    if not avail tarifex then do:
        find first tarif2 where tarif2.str5 = p-str5 no-lock no-error.
        if avail tarif2 then do:
            if tarif2.proc > 0 then do:
                p-amt = p-sum * (tarif2.proc / 100).
                if tarif2.min1 > 0 and p-amt < tarif2.min1 then p-amt = tarif2.min1.
                if tarif2.max1 > 0 and p-amt > tarif2.max1 then p-amt = tarif2.max1.
            end.
            else p-amt = tarif2.ost.
            p-kont = tarif2.kont.
        end.
        else message "Не найден тариф для снятия комиссии!" view-as alert-box.
    end.
    else do:
        if tarifex.proc > 0 then do:
            p-amt = p-sum * (tarifex.proc / 100).
            if tarifex.min1 > 0 and p-amt < tarifex.min1 then p-amt = tarifex.min1.
            if tarifex.max1 > 0 and p-amt > tarifex.max1 then p-amt = tarifex.max1.
        end.
        else p-amt = tarifex.ost.
        p-kont = tarifex.kont.
    end.
end procedure.

CURRENT-WINDOW:MENUBAR = MENU m-pc:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM m-exit.
