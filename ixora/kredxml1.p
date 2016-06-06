/* kredxml1.p
 * MODULE
        Формирование файла для загрузки в Кред бюро
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        BANK COMM TXB
 * AUTHOR
        07/09/07 marinav
 * CHANGES
        09/10/07 marinav - изменен формат
        22/11/07 marinav - деление на пакеты по 1000 записей
        13.08.2008 galina - переделала для выгрузки залоговых кредитов
        13.08.2008 galina - выводить колличество просрочек на текущую дату (если просрочка погашена, то выводить ноль)
        18.08.2008 galina - раскоментировала отправку файла
        19.08.2008 galina - убрала проверку группы для физических лиц
                            добавила присвоение кода города Алматы для залоговых кредитов в ЦО
                            присвоение ежемесячной периодичности выплат для кредитов без признака lnpmtper
        21.08.2008 galina - выводим реальный остаток основного долга не из графика
                            проверяем наличие даты выдачи удв.лич., если нет, то присваиваем значение 01/01/2008 и записываем в файл ошибок
        02.09.2008 galina - код цели кредита и код обеспечения проставляется в соотсвествии с справочниками нац.банка
        10.09.2008 galina - проверяем наличие файла перед удалением
        11.09.2008 galina - если нет фактического адреса у юр.лица, то копируем его из юридического
        18.09.2008 galina - гарантии выгружаются как рассроченные кредиты
        17.10.2008 galina - поменяла пароль и логин на новый
        18/03/2009 galina - выгружаем гарантии каждый месяц как кредиты
                            заменила в названии ЮР лица "&" на "&amp;"
        24/03/2009 galina - в гарантиях признак "С" на английском языке
        25/03/2009 galina - добавила Саяна Рахимова (id00027) в рассылку результата выгрузки
        26/03/2009 galina - удаляем сивол "№" из номера Уд.л. и Рег.свидетельства
        10.04.2009 galina - изменения согласно уведомлению № 278 от 01.04.2009
        29.04.2009 galina - для гарантий проверяем наличие даты выдачи удв.лич., если нет, то присваиваем значение 01/01/2008 и записываем в файл ошибок
        28.05.2009 galina - изменения согласно уведомлению № 390 от 22.05.2009
        01.06.2009 galina - исправила коды обеспечения у гарантий
        16.06.2009 galina - изменения согласно уведомлению № 278 от 01.04.2009 для кредитных линий
        18.06.2009 galina - изменила пароль и логин
        08/09/2009 galina - обнуляем сумму долга, если у нас досрочное погашение
                            удаляем сивол "№" из адреса
        27/10/2009 galina - поменяла пароль
        20/12/2009 galina - поменяла пароль и логин
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
        21/05/2010 galina - выгружаем информацию по кредитору для гарантий
        02/07/2010 galina - можно выгружать кредиты без ОКПО
                            ищем номер соответств. 9-го счета для 20-тизначного
                            поправила поиск ФИО у ИП
        22/07/2010 galina - запись в файл ошибок, если нет ФИО у ИП
        04/08/2010 galina - не выводим в файл ошибок, если нет проводок по выдаче гарантии
        02/09/2010 galina - проверяем корректность заполнения дат
        09/09/2010 galina - исключила не выданные кредиты
        20/09/2010 galina - поправила определение статуса кредита
        29/10/2010 galina - не выгружаем отчество, если его нет
                            выводит отчество руководителя
        09/11/2010 galina - перенесла признак lnopf в признаки клиента
        07/12/2010 galina - поправила поиск данных первого руководителя
        18/02/2011 evseev  - закомментировал  t-cred.sbfthname = "Нет". стр.352,361,791
        10/03/2011 evseev  - ссудные счета созданные с 14/03/2011 имеют номер контракта №банка+0+номер ссудного счета
                            созданные до 14/03/2011 №банка+номер ссудного счета (стр.241)
        21/07/2011 madiyar - рассылка результата отработки и лога ошибок только на группу fcb@metrocombank.kz
        11/08/2011 kapar ТЗ947
        12/10/2011 id00810 - аккредитивы и гарантии из модуля ТФ, заполнение реквизита RealPaymentDate для погашенных кредитов
        27/10/2011 id00810 - после первой выгрузки всех аккредитивов и гарантий из модуля ТФ, добавила условие сравнения с датой pksysc.daval
        30/12/2011 kapar по ТЗ947 дополнительный контроль
        26/01/2012 id00810 - в аккредитивах из модуля ТФ изменилось значение реквизита fmt
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        17/05/2012 kapar - изменил пароль
        19/08/2013 Sayat(id01143) - ТЗ 1776 от 27/03/2013 Изменения в отчете «Признак согласия на отправку в Кредитное Бюро»
        02/09/2013 galina - ТЗ1918 перекомпиляция
        20/09/2013 Sayat(id01143) - ТЗ 2093 от 18/09/2013 Отправка данных в ТОО «ПКБ»: Дата регистрации юр. лица
*/
{chbin_txb.i}
{chk12_innbin.i}
define shared var g-today  as date.
define shared stream m-out.
define shared stream m-out1.
define shared var v-paket as int.
define shared var v-paket1 as int.
define shared var v-dogcount as int.
define shared var v-garcount as int.
define shared var v-sendmail as int.

def input parameter v-bank as char.

def var v-count as int .
def var v-amount as deci.
def var v-ovcount as int .
def var v-ovamount as deci.
def var v-com as deci.
def var v-class as char.
def var v-find0 as char.
def var v-find1 as char.

def var v-res as deci.
def var i as integer.
def var k as integer.
def var n as integer.
def var v-dterror as logi.
def var bencount_tex as char no-undo init "036,040,031,008,012,660,024,020,010,028,530,446,032,051,533,004,044,050,052,048,112,084,056,204,060,100,068,070,072,076,086,096,074,854,108,064,548,336,826,348,862,850,092,016,626,704,266,274,328,332,270,288,312,320,254,324,624,280,292,340,308,304,300,268,316,208,262,396,212,214,818,180,894,732,882,716,887,376,356,360,400,368,364,372,352,724,380,132,398,136,116,120,124,634,404,196,296,156,166,170,174,178,408,410,188,384,192,414,417,418,428,426,430,422,434,440,438,442,480,478,450,807,454,458,466,581,462,470,580,504,474,584,484,583,508,498,492,496,500,104,520,516,524,562,566,528,558,570,540,554,578,830,574,784,833,162,654,872,184,488,512,586,585,591,598,600,604,612,616,620,630,638,643,646,642,670,222,674,678,682,748,690,686,659,662,702,760,703,705,090,706,666,736,740,840,694,344,762,158,764,834,796,768,772,776,780,798,788,795,792,800,860,804,876,858,234,242,608,246,238,258,260,250,334,191,140,148,203,152,756,752,744,144,218,226,232,233,231,891,710,388,392".
def var bencount_pkb as char no-undo init "13,14,15,2,3,7,6,5,8,9,152,126,10,11,12,1,16,18,19,17,20,22,21,23,24,33,26,27,28,29,0,32,0,34,35,25,231,95,227,98,233,236,30,4,62,234,79,0,93,94,80,83,88,90,75,91,92,82,84,96,87,86,85,81,89,58,59,0,60,61,64,241,242,238,185,243,239,105,100,101,109,103,102,104,99,200,106,39,110,40,36,37,38,175,111,55,112,44,46,47,48,49,113,114,51,52,54,115,116,117,118,120,121,119,122,124,123,125,137,136,128,127,129,130,132,0,131,133,160,145,135,134,139,140,146,141,142,143,144,147,149,148,150,156,157,151,155,158,153,154,161,24275 и 24272,159,226,24270,45,180,0,50,0,162,163,164,166,167,168,169,171,172,173,174,176,178,179,177,184,65,186,187,188,205,191,189,181,182,193,208,194,195,196,197,183,202,203,228,192,97,210,209,212,211,222,215,216,217,218,223,219,221,220,224,230,225,237,229,71,72,170,73,70,77,78,74,0,53,41,42,56,43,207,206,24277,201,63,66,67,68,69,240,198,107,108".

def temp-table t-cred
    field ctcode        as char
    field fundingtype   as char
    field crpurpose     as char
    field ctphase       as char
    field ctstatus      as char
    field stdate as date
    field edate as date
    field rpdate as date
    field class as char
    field colaterall as char
    field colatcrc as char
    field colatamt as char
    field sbfname as char
    field sbsname as char
    field sbfthname as char
    field name as char
    field abbrev as char
    field legform as char
    field Ownership as char
    field sbgender as char
    field sbclass as char
    field residency as char
    field dtbirth as date
    field sbidnum1 as char
    field sbidnum2 as char
    field sbregdt as date
    field cidnum1 as char
    field cidnum2 as char
    field cregdt2 as date
    field cidnum3 as char
    field cregdt3 as date
    field mfname as char
    field msname as char
    field mmname as char
    field midnum1 as char
    field midnum2 as char
    field mregdt as date
    field addrloc1 as char
    field strname1 as char
    field strname2 as char
    field tel as char
    field tlx as char
    field fax as char
    field pmtper as char
    field tamt as deci
    field crc as char
    field insamt as deci
    field inscount as integer
    field oinscount as integer
    field oinsamt as deci
    field ovinscount as integer
    field ovinsamt as deci
    field intrate as deci
    field gua as char
    field crlimit as deci
    field usedamt as deci
    field benres as integer
    field bentype as integer
    field bennaim as char
    field benfname as char
    field benmname as char
    field benlname as char
    field bencount as char
    field sbidnum3 as char.

def var v-inscount  as integer.
def var v-date      as date.
def var v-res2      as deci.
def var v-isMKO     as logical. /* yes - mko, no-filial */

def var v-gar     as logi no-undo.
def var v-cover   as char no-undo.
def var v-cod     as char no-undo.
def var v-dt1     as date no-undo.
def var v-dt2     as date no-undo.
def var v-dt3     as date no-undo.
def var v-name    as char no-undo.
def var v-per     as int  no-undo.
def var v-str     as char.

def var v-bencountry as char.

function date_str returns char (input v-date as date) .
    return (string(year(v-date)) + "-" + string(month(v-date),'99') + "-" + string(day(v-date),'99')).
end.

function rep2utf returns char (input v-str as char).
    return replace(replace(replace(replace(replace(replace(v-str,'&','&amp;'),'«','"'),'»','"'),'№','N'),'“','"'),'‘','').
end function.

/*процедура определения вида залога по гарантиям, суммы залога, суммы гарантии,*/

def var v-codfr as char.
def var sumzalog as decimal.
def var sumtreb as decimal.
def var vcrc as integer.

Procedure garan.
    DEFINE INPUT PARAMETER v-aaa AS char.
    def var i1 as integer.
    def var i2 as integer.
    def var i3 as integer.
    def var i4 as integer.
    def var i5 as integer.
    def var i6 as integer.
    def var i7 as integer.
    def var i8 as integer.

    for each txb.jl where txb.jl.acc = v-aaa and lookup(txb.jl.trx, 'dcl0010,dcl0016,dcl0017') <> 0 no-lock.
        if string(txb.jl.gl)  begins '6055' then do:
            sumtreb = txb.jl.dam.
            vcrc = txb.jl.crc.
            i2 = index(txb.jl.rem[1], "от").
            i4 = index(txb.jl.rem[2], ":").
            i5 = index(txb.jl.rem[2], "Сумма").
            v-codfr = trim(substr(txb.jl.rem[2],i4 + 2,i5 - i4 - 2)).
            sumzalog = decimal(trim(substr(txb.jl.rem[2],i5 + 6))).
        end.
    end.
end Procedure.
/**/

hide message no-pause.
message "Обрабатывается филиал  - " v-bank .

def var num as char.
find first bank.cmp no-lock no-error.
if bank.cmp.name matches '*МКО*'  then num = 'MKO'.
else num = 'GB'.

find first pksysc where pksysc.sysc = '1cb' exclusive-lock no-error.
/*find first txb.sysc where txb.sysc.sysc = 'kredbr' no-error.*/
if not avail pksysc then return.
/*
find first pksysc where pksysc.sysc = '1cb' no-lock no-error.
v-dogcount = pksysc.deval.
v-paket = pksysc.inval.
*/
empty temp-table t-cred.

/*наименование банка для записи в логфайл*/
find first txb.cmp no-lock no-error.
if txb.cmp.name matches '*МКО*'  then
    v-isMKO = yes.
else
    v-isMKO = no.

FOR EACH txb.lon where txb.lon.lon ne 'lon' NO-LOCK :
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    /*****общая информация по контракту****/
    find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lonkb' no-lock no-error.
    if not avail txb.sub-cod then next.
    if txb.sub-cod.ccode ne '01' then next.

    find first txb.lonres where txb.lonres.lon = txb.lon.lon use-index jdt no-lock no-error.
    if not avail txb.lonres then next.

    if txb.lon.sts =  "C" then do:
        find last txb.lonres where txb.lonres.lon = txb.lon.lon and lookup(string(txb.lonres.lev),'1,2,4,5,7,9,13,14,16,30') > 0 use-index jdt no-lock no-error.
        if not avail txb.lonres then next.
        if txb.lonres.jdt < pksysc.daval then next.
    end.

    if lookup(string(txb.lon.grp),'90,92') > 0 then do:
        find first pkanketa where pkanketa.bank = v-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
        if not avail pkanketa then next.
    end.

    create t-cred.

    find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
    if txb.lon.gua = "CL" or substr(txb.loncon.lcnt,1,2) = "CL" then t-cred.fundingtype = "11".
    else t-cred.fundingtype = "2".

    if (v-isMKO = yes) or (lon.rdt < 03/14/2011 and v-isMKO = no) then
        t-cred.ctcode = substring(v-bank,4,2)+ txb.lon.lon.
    else
        if (lon.rdt >= 03/14/2011 and v-isMKO = no) then
            t-cred.ctcode = substring(v-bank,4,2)+ "0" + txb.lon.lon.

    find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
    if avail txb.sub-cod then do:
        /*if txb.sub-cod.ccode = 'msc' then t-cred.crpurpose = "7".
        else do :
            if integer(txb.sub-cod.ccode) > 7 then t-cred.crpurpose = "7".
            else t-cred.crpurpose = txb.sub-cod.ccode.
        end.    */
        case txb.sub-cod.ccode:
            when "10" then t-cred.crpurpose = "1".
            when "11" then t-cred.crpurpose = "2".
            when "14" then t-cred.crpurpose = "3".
            when "15" then t-cred.crpurpose = "6".
            otherwise t-cred.crpurpose = "7".
        end.
    end.
    else do:
        run savelog( "kredbureau", "Отсутствует параметр lntgt ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
        v-sendmail = v-sendmail + 1.
    end.
    /*galina закоментировать 01 июня 2009*/
    /* v-res = 0.
    run lonbal_txb("lon",txb.lon.lon,g-today,'13,14',yes,output v-res).
    if v-res > 0 then t-cred.ctstatus = "5".
    if v-res = 0 then t-cred.ctstatus = "1".*/

    if txb.lon.sts ne "C" then  t-cred.ctphase = "4".
    else do:
        if txb.lonres.jdt >= txb.lon.duedt then t-cred.ctphase = "5".
        if txb.lonres.jdt < txb.lon.duedt  then t-cred.ctphase = "6".
        t-cred.rpdate = txb.lonres.jdt.
    end.

    t-cred.stdate = txb.lon.rdt.
    t-cred.edate = txb.lon.duedt.

    find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonhar then find txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    if avail txb.lonstat then t-cred.class = string(txb.lonstat.lonstat).

    find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock no-error.
    if avail txb.lonsec1 then do:
        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
            if t-cred.colaterall <> "" and txb.lonsec1.lonsec > 0 and txb.lonsec1.lonsec <= 6 then t-cred.colaterall = t-cred.colaterall + ",".
            case txb.lonsec1.lonsec:
                when 1 then t-cred.colaterall = t-cred.colaterall + "6".
                when 2 then t-cred.colaterall = t-cred.colaterall + "2".
                when 3 then t-cred.colaterall = t-cred.colaterall + "10".
                when 4 or when 6 then t-cred.colaterall = t-cred.colaterall + "14".
                when 5 then t-cred.colaterall = t-cred.colaterall + "1".
            end.

            if t-cred.colatamt <> "" then t-cred.colatamt = t-cred.colatamt + ",".
            t-cred.colatamt = t-cred.colatamt + string(txb.lonsec1.secamt).
            find txb.crc where txb.crc.crc = txb.lonsec1.crc no-lock no-error.
            if avail crc then do:
                if t-cred.colatcrc <> "" then t-cred.colatcrc = t-cred.colatcrc + ",".
                t-cred.colatcrc = t-cred.colatcrc + txb.crc.code.
            end.
            else do:
                run savelog( "kredbureau", "Не указана валюта залога! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif  + ", Кредит - " + txb.lon.lon).
                v-sendmail = v-sendmail + 1.
            end.
        end.
    end.
    else do:
        find txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
        if avail txb.crc then t-cred.colatcrc = txb.crc.code.
        assign t-cred.colaterall = "1"
               t-cred.colatamt = "0".
    end.

    if txb.cif.type = 'P' then t-cred.sbclass = "1".
    if txb.cif.type = 'B' and /*txb.cif.cgr = 403*/ lookup(string(txb.cif.cgr),"403,405,605") <> 0 then t-cred.sbclass = "2".

    assign
        t-cred.tel = txb.cif.tel
        t-cred.tlx = txb.cif.tlx
        t-cred.fax = txb.cif.fax.

    if lookup(string(txb.lon.grp),'90,92') > 0 then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "city1" no-lock no-error.
        find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code = pkanketh.value1 no-lock no-error.
        if avail txb.codfr then t-cred.addrloc1 = txb.codfr.name[2].
        else do:
            if (v-bank = "TXB16" or v-bank = "TXB00") then t-cred.addrloc1 = "675".
            else do:
                find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code <> 'msc' no-lock no-error.
                if avail txb.codfr then do:
                    if txb.codfr.name[2] = '0' then do:
                        run savelog( "kredbureau", "Не заполнен справочник - Населенные пункты для Кредитного бюро! Филиал -  " + txb.cmp.addr[1] + ", Населеный пункт - " + txb.codfr.name[1]).
                        v-sendmail = v-sendmail + 1.
                    end.
                    else t-cred.addrloc1 = txb.codfr.name[2].
                end.
            end.
        end.
    end.
    else do:
        if (v-bank = "TXB16" or v-bank = "TXB00") then t-cred.addrloc1 = "675".
        else do:
            find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code <> 'msc' no-lock no-error.
            if avail txb.codfr then do:
                if txb.codfr.name[2] = '0' then do:
                    run savelog( "kredbureau", "Не заполнен справочник - Населенные пункты для Кредитного бюро! Филиал -  " + txb.cmp.addr[1] + ", Населеный пункт - " + txb.codfr.name[1]).
                    v-sendmail = v-sendmail + 1.
                end.
                else t-cred.addrloc1 = txb.codfr.name[2].
            end.
        end.
    end.

    if txb.cif.type = 'P' or (txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0) then do:
        if txb.cif.type = 'B' and /*txb.cif.cgr = 403*/ lookup(string(txb.cif.cgr),"403,405,605") <> 0 then do:
            if txb.cif.coregdt <> ? then t-cred.dtbirth = txb.cif.coregdt.
            else t-cred.dtbirth = txb.cif.expdt.
        end.
        else
            t-cred.dtbirth = txb.cif.expdt.
        if txb.cif.type = 'P' then do:
            assign t-cred.sbfname = entry(2, txb.cif.name, " ")
                   t-cred.sbsname = entry(1, txb.cif.name, " ").
            if num-entries( trim(txb.cif.name), ' ' ) > 2 then
                t-cred.sbfthname = entry(3, txb.cif.name, " ").
            /*else t-cred.sbfthname = "Нет".*/
        end.
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'clnchf' no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then do:
                if trim(txb.sub-cod.rcode) <> '' then do:
                    if num-entries(txb.sub-cod.rcode, " ") > 1 then t-cred.sbfname = entry(2,txb.sub-cod.rcode, " ").
                    t-cred.sbsname = entry(1, txb.sub-cod.rcode, " ").
                    if num-entries( trim(txb.sub-cod.rcode), ' ' ) > 2 then t-cred.sbfthname = entry(3, txb.sub-cod.rcode, " ").
                   /* else t-cred.sbfthname = "Нет".*/
                end.
                else do:
                    run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                    v-sendmail = v-sendmail + 1.
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'clnsex' no-lock no-error.
        if avail txb.sub-cod then do:
            if txb.sub-cod.ccode = '01' then t-cred.sbgender = "M".
            else t-cred.sbgender = "F".
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр clnsex ! Филиал " + txb.cmp.addr[1] + ",  Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if txb.cif.geo = "022" then t-cred.residency = "2".
        if txb.cif.geo = "021" then t-cred.residency = "1".

        if lookup(string(txb.lon.grp),'90,92') > 0 then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
            t-cred.sbregdt = date(pkanketh.value1) no-error.
            if error-status:error then do:
                t-cred.sbregdt = date('01.01.2008').
                run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.
        else do:
            if num-entries(txb.cif.pss,' ') > 1 then do:
                t-cred.sbregdt = date(entry(2,txb.cif.pss,' ')) no-error.
                if error-status:error then do:
                    v-dterror = true.
                    k = 1.
                    repeat:
                        k = k + 1.
                        t-cred.sbregdt = date(entry(k,txb.cif.pss,' ')) no-error.
                        if not (error-status:error) then do: v-dterror = false. leave. end.
                        if k = num-entries(txb.cif.pss,' ')then leave.
                    end.
                end.
                if v-dterror = true then do:
                    t-cred.sbregdt = date('01.01.2008').
                    run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
                    v-sendmail = v-sendmail + 1.
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.

        if trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.

        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.*/
        /*
        if txb.cif.jss = '' and txb.cif.type = "B" and lookup(string(txb.cif.cgr),"403,405,605") = 0 then do:
            run savelog( "kredbureau", "Не заполнен РНН клиента ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        */
        if txb.cif.bin = '' then do:
            run savelog( "kredbureau", "Не заполнен ИИН/БИН клиента ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        assign
            t-cred.sbidnum1 = txb.cif.jss
            t-cred.sbidnum2 = entry(1,txb.cif.pss,' ')
            t-cred.sbidnum3 = txb.cif.bin.
        if txb.cif.type = 'P' then do:
            if trim(txb.cif.addr[1]) = trim(txb.cif.addr[2]) then t-cred.strname1 = trim(txb.cif.addr[1]).
            else t-cred.strname1 = trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]).
            if num-entries(trim(txb.cif.item),'|') > 1 then t-cred.strname2 = entry(2,trim(txb.cif.item),'|').
            else t-cred.strname2 = trim(txb.cif.item).
        end.
        else do:
            t-cred.strname1 = trim(txb.cif.addr[1]).
            if trim(txb.cif.addr[2]) <> '' then t-cred.strname2 = trim(txb.cif.addr[2]).
            else t-cred.strname2 = trim(txb.cif.addr[1]).
        end.

    end.

    if (txb.cif.type = 'B' and /*txb.cif.cgr <> 403*/ lookup(string(txb.cif.cgr),"403,405,605") = 0 ) then do:

        t-cred.name = trim(substr(txb.cif.name,1,60)).
        if txb.cif.sname <> "" then t-cred.abbrev = txb.cif.sname.
        else t-cred.abbrev = trim(substr(txb.cif.name,1,60)).

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnopf' no-lock no-error.
        if not avail txb.sub-cod or txb.sub-cod.ccode = 'msc' then find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'lnopf' no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then t-cred.legform = txb.sub-cod.ccode.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр lnopf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
            v-sendmail = v-sendmail + 1.
        end.
        /*
        if txb.cif.jss = '' and txb.cif.type = "B" and lookup(string(txb.cif.cgr),"403,405,605") = 0 then do:
            run savelog( "kredbureau", "Не заполнен РНН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
            v-sendmail = v-sendmail + 1.
        end.
        */
        if txb.cif.bin = '' then do:
            run savelog( "kredbureau", "Не заполнен ИИН/БИН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
            v-sendmail = v-sendmail + 1.
        end.
        assign
            t-cred.cidnum1 = txb.cif.jss
            t-cred.cidnum2 = txb.cif.ssn
            t-cred.sbidnum3 = txb.cif.bin.

        if entry(1,txb.cif.jel,'&') <> "" then do:
            t-cred.cregdt2 = date(entry(1,txb.cif.jel,'&')) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.cregdt2 = date('01.01.2008').
            end.
        end.
        /*else do:
            run savelog( "kredbureau", "Отсутствует дата выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.*/

        assign
            t-cred.cidnum3 = trim(txb.cif.ref[8])
            t-cred.cregdt3 = txb.cif.expdt.
        if trim(txb.cif.addr[1]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
            v-sendmail = v-sendmail + 1.
        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.*/
        t-cred.strname1 = trim(txb.cif.addr[1]).
        if trim(txb.cif.addr[2]) <> "" then t-cred.strname2 = trim(txb.cif.addr[2]).
        else t-cred.strname2 = trim(txb.cif.addr[1]).

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            if num-entries(trim(txb.sub-cod.rcode),' ') > 0 then t-cred.msname = entry(1,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 1 then t-cred.mfname = entry(2,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 2 then t-cred.mmname = entry(3,trim(txb.sub-cod.rcode),' ').
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfrnn" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum1 = txb.sub-cod.rcode.
        if t-cred.midnum1 <> '' and not chk12_innbin(t-cred.midnum1) then do:
            run savelog( "kredbureau", "ИИН первого руководителя не прошел ключевание, возможно это РНН, замените на ИИН! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfdnum" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum2 = txb.sub-cod.rcode.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfddt" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            t-cred.mregdt = date(txb.sub-cod.rcode) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.mregdt = date('01.01.2008').
            end.
        end.
        /*
        find kdcif where kdcif.bank = v-bank and kdcif.kdcif = txb.lon.cif no-lock no-error.
        if avail kdcif then do:
            if t-cred.msname = '' then do:
                if kdcif.chief[1] <> '' then do:
                    t-cred.msname = trim(entry(1,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 1 then t-cred.mfname = trim(entry(2,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 2 then t-cred.mmname = trim(entry(2,kdcif.chief[1], ' ')).
                end.
            end.
            if t-cred.midnum1 = '' then t-cred.midnum1 = trim(kdcif.rnn_chief[1]).
            if t-cred.midnum2 = '' then t-cred.midnum2 = entry(1,kdcif.docs[1],' ').
            if t-cred.mregdt = ? then do:
                if num-entries(kdcif.docs[1],' ') > 1 then do:
                    t-cred.mregdt = date(entry(2,kdcif.docs[1],' ')) no-error.
                    if error-status:error then do:
                        run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
                        v-sendmail = v-sendmail + 1.
                        t-cred.mregdt = date('01.01.2008').
                    end.
                end.
            end.
        end.
        */
        if t-cred.msname = '' then do:
            run savelog( "kredbureau", "Отсутствует Фамилия первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.mfname = '' then do:
            run savelog( "kredbureau", "Отсутствует Имя первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.midnum1 = '' then do:
            run savelog( "kredbureau", "Отсутствует ИИН первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.midnum2 = '' then do:
            run savelog( "kredbureau", "Отсутствует номер ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.mregdt = ? then do:
            run savelog( "kredbureau", "Отсутствует дата выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*if t-cred.legform = '' then do:
            run savelog( "kredbureau", "Отсутствует Организационно-правовая форма хозяйствования! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.*/
    end.

    t-cred.gua = txb.lon.gua.

    find txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
    if avail txb.crc then t-cred.crc = txb.crc.code.

    if txb.lon.gua = "CL" or txb.lon.gua = "LO" then do:
        find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnpmtper' no-lock no-error.
        if avail txb.sub-cod then do:
            if txb.sub-cod.ccode = "msc" then t-cred.pmtper = "2".
            else t-cred.pmtper = txb.sub-cod.ccode.
        end.
        if not avail txb.sub-cod then t-cred.pmtper = "2".

        /*if lookup(string(txb.lon.grp),'90,92') > 0 then t-cred.pmtper = "2".
        else do:
            run savelog( "kredbureau", "Отсутствует параметр lnpmtper! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.lon.cif + ", Кредит - " + txb.lon.lon).
            v-sendmail = v-sendmail + 1.
        end.
        */

        t-cred.tamt = txb.lon.opnamt.

        v-com = 0.
        find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
        if avail txb.tarifex2 then v-com = txb.tarifex2.ost.

        find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= g-today no-lock no-error.
        if avail txb.lnsch then do:
            find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= g-today no-lock no-error.
            if avail txb.lnsci then  do:
                if txb.lnsch.stdat > txb.lnsci.idat then  t-cred.insamt = txb.lnsci.iv-sc.
                if txb.lnsch.stdat < txb.lnsci.idat then t-cred.insamt = txb.lnsch.stval + v-com.
                if txb.lnsch.stdat = txb.lnsci.idat then t-cred.insamt = txb.lnsci.iv-sc + txb.lnsch.stval + v-com.
            end.
            else put t-cred.insamt = txb.lnsch.stval + v-com.
        end.
        else t-cred.insamt = 0.

        v-count = 0. v-amount = 0. v-inscount = 0.
        for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 no-lock.
            v-inscount = v-inscount + 1.
            if txb.lnsch.stdat >= g-today then do:
                v-count = v-count + 1.
                v-amount = v-amount + txb.lnsch.stval.
            end.
        end.
        /*-----
        find txb.trxbal where txb.trxbal.level = 1 and txb.trxbal.sub = "lon" and txb.trxbal.acc = txb.lon.lon no-lock no-error.
        if avail txb.trxbal then v-amount = txb.trxbal.dam - txb.trxbal.cam.
        */
        v-ovcount = 0. v-ovamount = 0.
        find first txb.londebt where txb.londebt.lon = txb.lon.lon no-lock no-error.
        if avail txb.londebt then do:
            v-amount = v-amount + txb.londebt.od.
            v-ovamount = txb.londebt.od.
            v-date = (g-today - txb.londebt.days_od).
            /*galina раскоментировать 01 июня 2009*/ v-ovcount = txb.londebt.days_od.
            for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and (txb.lnsch.stdat >= v-date and txb.lnsch.stdat <= g-today) no-lock:
                v-count  = v-count + 1.
                /*galina закоментировать 01 июня 2009 v-ovcount = v-ovcount + 1.*/
            end.
        end.
        if t-cred.ctphase  = '4' then t-cred.ovinsamt = v-ovamount.
        if t-cred.ctphase  = '5' or t-cred.ctphase  = '6' then t-cred.ovinsamt = 0.
        assign
            t-cred.inscount = v-inscount
            t-cred.oinscount = v-count
            t-cred.oinsamt = v-amount
            t-cred.ovinscount = v-ovcount
            t-cred.intrate = txb.lon.prem.
        /*galina раскоментировать 01 июня 2009*/
        if v-ovcount = 0 then do:
            v-res = 0.
            run lonbal_txb("lon",txb.lon.lon,g-today,'13,14,30',yes,output v-res).
            if v-res > 0 then t-cred.ctstatus = "5".
            else do:
                v-res = 0.
                run lonbalcrc_txb("lon",txb.lon.lon,g-today,'6',yes,txb.lon.crc,output v-res).
                if v-res > 0 then do:
                    run lonbalcrc_txb("lon",txb.lon.lon,g-today,'1,7',yes,txb.lon.crc,output v-res2).
                    if round(v-res,2) = round(v-res2,2) then t-cred.ctstatus = "4".
                    if v-res2 > 0 and round(v-res,2) < round(v-res2,2) then t-cred.ctstatus = "8".
                end.
                else t-cred.ctstatus = "1".
            end.
        end.
        if v-ovcount < 7 then t-cred.ctstatus = "10".
        if v-ovcount >= 7 and v-ovcount <= 30 then t-cred.ctstatus = "11".
        if v-ovcount >= 31 and v-ovcount <= 60 then t-cred.ctstatus = "12".
        if v-ovcount >= 61 and v-ovcount <= 90 then t-cred.ctstatus = "13".
        if v-ovcount >= 91 and v-ovcount <= 360 then t-cred.ctstatus = "15".
        if v-ovcount > 360 then do:
            v-res = 0.
            run lonbal_txb("lon",txb.lon.lon,g-today,'13,14,30',yes,output v-res).
            if v-res > 0 then t-cred.ctstatus = "5".
            else do:
                v-res = 0.
                run lonbalcrc_txb("lon",txb.lon.lon,g-today,'6',yes,txb.lon.crc,output v-res).
                if v-res > 0 then do:
                    run lonbalcrc_txb("lon",txb.lon.lon,g-today,'1,7',yes,txb.lon.crc,output v-res2).
                    if round(v-res,2) = round(v-res2,2) then t-cred.ctstatus = "4".
                    if v-res2 > 0 and round(v-res,2) < round(v-res2,2) then t-cred.ctstatus = "8".
                end.
                else t-cred.ctstatus = "16".
            end.
        end.
    end. /*lon.gua = "LO"*/

    /*-
    if txb.lon.gua = "CL" then do:
        t-cred.crlimit = txb.lon.opnamt.
        find txb.trxbal where txb.trxbal.sub = "lon" and txb.trxbal.lev = 1 and txb.trxbal.acc = txb.lon.lon no-lock no-error.
        if avail txb.trxbal then t-cred.usedamt = txb.trxbal.dam.

        v-ovcount = 0.
        find first txb.londebt where txb.londebt.lon = txb.lon.lon no-lock no-error.
        if avail txb.londebt then v-ovcount = txb.londebt.days_od.
        if v-ovcount = 0 then t-cred.ctstatus = "1".
        if v-ovcount < 7 then t-cred.ctstatus = "10".
        if v-ovcount >= 7 and v-ovcount <= 30 then t-cred.ctstatus = "11".
        if v-ovcount >= 31 and v-ovcount <= 60 then t-cred.ctstatus = "12".
        if v-ovcount >= 61 and v-ovcount <= 90 then t-cred.ctstatus = "13".
        if v-ovcount > 90 then do:
            v-res = 0.
            run lonbal_txb("lon",txb.lon.lon,g-today,'13',yes,output v-res).
            if v-res > 0 then t-cred.ctstatus = "5".
            if v-res = 0 then t-cred.ctstatus = "4".
        end.
    end.
    */

    /*-*/
    if t-cred.legform = '0' Then t-cred.legform = '16'.
    if t-cred.legform = '15' Then t-cred.legform = '16'.

    if t-cred.legform = '1' or t-cred.legform = '9' Then  t-cred.Ownership = '0'. else t-cred.Ownership = '1'.

    if t-cred.ctstatus = '4' Then t-cred.ctstatus = '5'.
    if t-cred.ctstatus = '8' Then t-cred.ctstatus = '1'.
END.

def var v-sts as char.
def buffer b-aaa for txb.aaa.
/*гарантии*/
FOR EACH txb.aaa where string(txb.aaa.gl) begins "2240" no-lock:
    /*
    if txb.aaa.aaa begins 'KZ' then do:
        find first b-aaa where b-aaa.aaa20 = txb.aaa.aaa no-lock no-error.
        if avail b-aaa then next.
    end.
    */
    v-sts = '4'.
    if txb.aaa.sta = 'C' then do:
        if txb.aaa.aaa <> '' then do:
            find first b-aaa where b-aaa.aaa = txb.aaa.aaa no-lock no-error.
            if avail b-aaa then do:
                if b-aaa.sta = 'C' then do:
                    find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
                    if not avail txb.sub-cod then next.
                    if txb.sub-cod.rdt < date("01122011") /*pksysc.daval*/ then next.
                    v-sts = '5'.
                end.
            end.
            else do:
                find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
                if not avail txb.sub-cod then next.
                if txb.sub-cod.rdt < date("01122011") /*pksysc.daval*/ then next.
                v-sts = '5'.
            end.
        end.
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
            if not avail txb.sub-cod then next.
            if txb.sub-cod.rdt < date("01122011") /*pksysc.daval*/ then next.
            v-sts = '5'.
        end.
        v-dt3 = txb.sub-cod.rdt.
    end.
    /*if txb.aaa.aaa begins 'KZ' then do:
        find first b-aaa where b-aaa.aaa20 = txb.aaa.aaa no-lock no-error.
        if avail b-aaa then v-contract = b-aaa.aaa.
        else v-contract = txb.aaa.aaa.
    end.*/

    find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.aaa.cif no-lock no-error.
    if avail txb.garan and txb.garan.jh  = 0 then /*do:
        run savelog( "kredbureau", "Нет проводки по гарантии! Филиал -  " + txb.cmp.addr[1] + " Номер Д/Г " + txb.aaa.aaa).
        v-sendmail = v-sendmail + 1.*/
        next.
    /*end.*/
    find first txb.jl where txb.jl.acc = txb.aaa.aaa and lookup(txb.jl.trx,'dcl0010,dcl0016,dcl0017') <> 0 no-lock no-error.
    if not avail txb.jl then next.

    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then next.

    create t-cred.
    assign
        t-cred.crpurpose = "7"
        t-cred.fundingtype = "8"
        t-cred.ctstatus = "1"
        t-cred.stdate = txb.aaa.regdt
        t-cred.edate = txb.aaa.expdt
        t-cred.class = "1"
        t-cred.ctphase = v-sts
        t-cred.rpdate = v-dt3
        t-cred.pmtper = "10".

    if txb.aaa.aaa begins 'KZ' then t-cred.ctcode = txb.aaa.aaa.
    else t-cred.ctcode = substring(v-bank,4,2) + txb.aaa.aaa.

    /*if txb.aaa.sta ne "C" then  t-cred.ctphase = "4".
    else t-cred.ctphase = "5".*/


    if txb.cif.type = 'P' then t-cred.sbclass = "1".
    if txb.cif.type = 'B' and /*txb.cif.cgr = 403*/ lookup(string(txb.cif.cgr),"403,405,605") <> 0 then t-cred.sbclass = "2".

    assign
        t-cred.tel = txb.cif.tel
        t-cred.tlx = txb.cif.tlx
        t-cred.fax = txb.cif.fax
        t-cred.cidnum3 = trim(txb.cif.ref[8])
        t-cred.cregdt3 = txb.cif.expdt.

    if (v-bank = "TXB16" or v-bank = "TXB00") then t-cred.addrloc1 = "675".
    else do:
        find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code <> 'msc' no-lock no-error.
        if avail txb.codfr then do:
            if txb.codfr.name[2] = '0' then do:
                run savelog( "kredbureau", "Не заполнен справочник - Населенные пункты для Кредитного бюро! Филиал -  " + txb.cmp.addr[1] + ", Населеный пункт - " + txb.codfr.name[1]).
                v-sendmail = v-sendmail + 1.
            end.
            else t-cred.addrloc1 = txb.codfr.name[2].
        end.
    end.

    if txb.cif.type = 'P' or (txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0) then do:
        if txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0 then do:
            if txb.cif.coregdt <> ? then t-cred.dtbirth = txb.cif.coregdt.
            else t-cred.dtbirth = txb.cif.expdt.
        end.
        else t-cred.dtbirth = txb.cif.expdt.

        if txb.cif.type = 'P' then do:
            assign t-cred.sbfname = entry(2, txb.cif.name, " ")
                   t-cred.sbsname = entry(1, txb.cif.name, " ").
            if num-entries( trim(txb.cif.name), ' ' ) > 2 then t-cred.sbfthname = entry(3, txb.cif.name, " ").
            /*else t-cred.sbfthname = "Нет".*/
        end.
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnchf' no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then do:
                if trim(txb.sub-cod.rcode) <> '' then do:
                    if num-entries(txb.sub-cod.rcode, " ") > 1 then t-cred.sbfname = entry(2,txb.sub-cod.rcode, " ").
                    t-cred.sbsname = entry(1, txb.sub-cod.rcode, " ").
                    if num-entries( trim(txb.sub-cod.rcode), ' ' ) > 2 then t-cred.sbfthname = entry(3, txb.sub-cod.rcode, " ").
                    /*else t-cred.sbfthname = "Нет".*/
                end.
                else do:
                    run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                    v-sendmail = v-sendmail + 1.
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = 'clnsex' no-lock no-error.
        if avail txb.sub-cod then do:
            if txb.sub-cod.ccode = '01' then t-cred.sbgender = "M".
            else t-cred.sbgender = "F".
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр clnsex ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if txb.cif.geo = "022" then t-cred.residency = "2".
        if txb.cif.geo = "021" then t-cred.residency = "1".

        if trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.*/
        else
        /*
        if txb.cif.jss = '' and txb.cif.type = "B" and lookup(string(txb.cif.cgr),"403,405,605") = 0 then do:
            run savelog( "kredbureau", "Не заполнен РНН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.
        */
        if txb.cif.bin = '' then do:
            run savelog( "kredbureau", "Не заполнен ИИН/БИН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.

        assign
            t-cred.sbidnum1 = txb.cif.jss
            t-cred.sbidnum2 = entry(1,txb.cif.pss,' ')
            t-cred.sbidnum3 = txb.cif.bin.
        if txb.cif.type = 'P' then do:
            if trim(txb.cif.addr[1]) = trim(txb.cif.addr[2]) then t-cred.strname1 = trim(txb.cif.addr[1]).
            else t-cred.strname1 = trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]).
            if num-entries(trim(txb.cif.item),'|') > 1 then t-cred.strname2 = entry(2,trim(txb.cif.item),'|').
            else t-cred.strname2 = trim(txb.cif.item).
        end.
        else do:
            t-cred.strname1 = trim(txb.cif.addr[1]).
            if trim(txb.cif.addr[2]) <> '' then t-cred.strname2 = trim(txb.cif.addr[2]).
            else t-cred.strname2 = trim(txb.cif.addr[1]).
        end.


        /*************/
        if num-entries(txb.cif.pss,' ') > 1 then do:
            t-cred.sbregdt = date(entry(2,txb.cif.pss,' ')) no-error.
            if error-status:error then do:
                v-dterror = true.
                k = 1.
                repeat:
                    k = k + 1.
                    t-cred.sbregdt = date(entry(k,txb.cif.pss,' ')) no-error.
                    if not (error-status:error) then do: v-dterror = false. leave. end.
                    if k = num-entries(txb.cif.pss,' ')then leave.
                end.
            end.
            if v-dterror = true then do:
                t-cred.sbregdt = date('01.01.2008').
                run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*************/
    end.

    if (txb.cif.type = 'B' and /*txb.cif.cgr <> 403*/ lookup(string(txb.cif.cgr),"403,405,605") = 0) then do:
        t-cred.name = trim(substr(txb.cif.name,1,60)).
        if txb.cif.sname <> "" then t-cred.abbrev = txb.cif.sname.
        else t-cred.abbrev = trim(substr(txb.cif.name,1,60)).

        if trim(txb.cif.addr[1]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.*/
        assign
            t-cred.cidnum1 = txb.cif.jss
            t-cred.cidnum2 = txb.cif.ssn
            t-cred.sbidnum3 = txb.cif.bin
            t-cred.strname1 = trim(txb.cif.addr[1]).
        if trim(txb.cif.addr[2]) <> "" then t-cred.strname2 = trim(txb.cif.addr[2]).
        else t-cred.strname2 = trim(txb.cif.addr[1]).

        if entry(1,txb.cif.jel,'&') <> "" then do:
            t-cred.cregdt2 = date(entry(1,txb.cif.jel,'&')) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.cregdt2 = date('01.01.2008').
            end.
        end.
        /*else do:
            run savelog( "kredbureau", "Отсутствует дата выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.*/

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            if num-entries(trim(txb.sub-cod.rcode),' ') > 0 then t-cred.msname = entry(1,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 1 then t-cred.mfname = entry(2,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 2 then t-cred.mmname = entry(3,trim(txb.sub-cod.rcode),' ').
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfrnn" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum1 = txb.sub-cod.rcode.

        if t-cred.midnum1 <> '' and not chk12_innbin(t-cred.midnum1) then do:
            run savelog( "kredbureau", "ИИН первого руководителя не прошел ключевание, возможно это РНН, замените на ИИН! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfdnum" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum2 = txb.sub-cod.rcode.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfddt" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            t-cred.mregdt = date(txb.sub-cod.rcode) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.mregdt = date('01.01.2008').
            end.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'lnopf' no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then t-cred.legform = txb.sub-cod.ccode.
        /*
        find kdcif where kdcif.bank = v-bank and kdcif.kdcif = txb.cif.cif no-lock no-error.
        if avail kdcif then do:
            if t-cred.msname = '' then do:
                if kdcif.chief[1] <> '' then do:
                    t-cred.msname = trim(entry(1,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 1 then t-cred.mfname = trim(entry(2,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 2 then t-cred.mmname = trim(entry(2,kdcif.chief[1], ' ')).
                end.
            end.

            if t-cred.midnum1 = '' then t-cred.midnum1 = trim(kdcif.rnn_chief[1]).
            if t-cred.midnum2 = '' then t-cred.midnum2 = entry(1,kdcif.docs[1],' ').
            if t-cred.mregdt = ? then do:
                if num-entries(kdcif.docs[1],' ') > 1 then do:
                    t-cred.mregdt = date(entry(2,kdcif.docs[1],' ')) no-error.
                    if error-status:error then do:
                        run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                        v-sendmail = v-sendmail + 1.
                        t-cred.mregdt = date('01.01.2008').
                    end.
                end.
            end.
            if t-cred.legform = '' then t-cred.legform = kdcif.lnopf.
        end.
        */
        if t-cred.msname = '' then do:
            run savelog( "kredbureau", "Отсутствует Фамилия первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if t-cred.mfname = '' then do:
            run savelog( "kredbureau", "Отсутствует Имя первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if t-cred.midnum1 = '' then do:
            run savelog( "kredbureau", "Отсутствует ИИН первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if t-cred.midnum2 = '' then do:
            run savelog( "kredbureau", "Отсутствует номер ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if t-cred.mregdt = ? then do:
            run savelog( "kredbureau", "Отсутствует дата выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        if t-cred.legform = '' then do:
            run savelog( "kredbureau", "Отсутствует Организационно-правовая форма хозяйствования! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        /*find kdcif where kdcif.bank = v-bank and comm.kdcif.kdcif = txb.aaa.cif no-lock no-error.
        if avail kdcif then do:
            if kdcif.chief[1] <> '' then do:
                t-cred.msname = trim(entry(1,kdcif.chief[1], ' ')).
                if num-entries(kdcif.chief[1], ' ') > 1 then
                    t-cred.mfname = trim(entry(2,kdcif.chief[1], ' ')).
                else do:
                    run savelog( "kredbureau", "Отсутствует имя первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                    v-sendmail = v-sendmail + 1.
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует номер ФИО первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
            end.

            assign
                t-cred.midnum1 = trim(kdcif.rnn_chief[1])
                t-cred.midnum2 = entry(1,kdcif.docs[1],' ').
            if trim(kdcif.rnn_chief[1]) = '' then do:
                run savelog( "kredbureau", "Отсутствует номер РНН первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
            end.
            if trim(kdcif.docs[1]) = '' then do:
                run savelog( "kredbureau", "Отсутствует номер и дата выдачи ПАСПОРТ/УДОС первому руководителю в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(kdcif.docs[1],' ') > 1 then do:
                t-cred.mregdt = date(entry(2,kdcif.docs[1],' ')) no-error.
                if error-status:error then do:
                    run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                    v-sendmail = v-sendmail + 1.
                    t-cred.mregdt = date('01.01.2008').
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует дата выдачи ПАСПОРТ/УДОС первому руководителю в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
                v-sendmail = v-sendmail + 1.
            end.

            t-cred.legform = kdcif.lnopf.
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует кредитное досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
        end.*/
    end.

    t-cred.gua = "GA".
    v-codfr = ''.
    sumzalog = 0.
    sumtreb = 0.

    find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.aaa.cif no-lock no-error.
    if avail txb.garan then do:
        assign t-cred.benres = txb.garan.benres
               t-cred.bentype = txb.garan.bentype
               t-cred.bennaim = txb.garan.naim
               t-cred.benfname = txb.garan.fname
               t-cred.benmname = txb.garan.mname
               t-cred.benlname = txb.garan.lname.
               /*v-bencountry = txb.garan.bencountry.*/
        if v-bencountry = '' and txb.garan.benres = 1 then v-bencountry = '398'.
        n = lookup(v-bencountry,bencount_tex).
        if n > 0 then t-cred.bencount = trim(entry(n,bencount_pkb)).

        find txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
        if avail txb.crc then assign t-cred.crc = txb.crc.code
                                     t-cred.colatcrc = txb.crc.code.
        v-codfr = txb.garan.obesp.
        if substr(v-codfr,1,1) = "0" then v-codfr = substr(v-codfr,2).
        case v-codfr:
            when '1' then v-codfr = '6'.
            when '2' then v-codfr = '2'.
            when '3' then v-codfr = '10'.
            when '5' then v-codfr = '1'.
            when '6' then v-codfr = '12'.
            otherwise v-codfr = '4'.
        end.
        assign t-cred.crlimit = txb.garan.sumtreb
               t-cred.usedamt = txb.garan.sumtreb
               t-cred.colaterall = v-codfr
               t-cred.colatamt = string(txb.garan.sumzalog).
    end.
    else do:
        run garan(txb.aaa.aaa).
        find txb.crc where txb.crc.crc = vcrc no-lock no-error.
        if avail txb.crc then assign t-cred.crc = txb.crc.code
                                     t-cred.colatcrc = txb.crc.code.
        if substr(v-codfr,1,1) = "0" then v-codfr = substr(v-codfr,2).
        case v-codfr:
            when '1' then v-codfr = '6'.
            when '2' then v-codfr = '2'.
            when '3' then v-codfr = '10'.
            when '5' then v-codfr = '1'.
            when '6' then v-codfr = '12'.
            otherwise v-codfr = '4'.
        end.
        assign t-cred.crlimit = sumtreb
               t-cred.usedamt = sumtreb
               t-cred.colaterall = v-codfr
               t-cred.colatamt = string(sumzalog).
    end.

    /*-*/
    if t-cred.legform = '0' Then t-cred.legform = '16'.
    if t-cred.legform = '15' Then t-cred.legform = '16'.

    if t-cred.legform = '1' or t-cred.legform = '9' Then  t-cred.Ownership = '0'. else t-cred.Ownership = '1'.

    if t-cred.ctstatus = '4' Then t-cred.ctstatus = '5'.
    if t-cred.ctstatus = '8' Then t-cred.ctstatus = '1'.
END.

/* аккредитивы и гарантии из модуля ТФ */

FOR each lc where lc.bank = v-bank and lc.lctype = 'i' and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock:
    v-sts = '4'.
    if lc.lcsts <> 'fin' then do:
        find last lcsts where lcsts.lcnum = lc.lc and lcsts.sts = lc.lcsts no-lock no-error.
        if avail lcsts and lcsts.whn < pksysc.daval then next.
        assign v-sts = '5' v-dt3 = date(lcsts.whn).
    end.

    if lc.lc begins 'pg' then v-gar = yes. else v-gar = no.

    if not v-gar then do:
        find first lch where lch.lc = lc.lc and lch.kritcode = 'fmt' no-lock no-error.
        if avail lch and lch.value1 = '720' then next.
    end.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'cover' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Covered/Uncovered! Филиал " + txb.cmp.addr[1] + ", аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    v-cover = lch.value1.

    v-cod = if v-gar then 'Date' else 'DtIs'.
    find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        find first lckrit where lckrit.datacode = v-cod and lckrit.lctype = 'i' no-lock no-error.
        v-name = if avail lckrit then lckrit.dataname else ''.
        run savelog( "kredbureau", "Не найден реквизит " +  v-name  + "! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    v-dt1 = date(lch.value1).

    find first lch where lch.lc = lc.lc and lch.kritcode = 'DtExp' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Date of Expiry! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.

    find last lcamendh where lcamendh.lc = lc.lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
    if avail lcamendh then v-dt2 = date(lcamendh.value1).
    else v-dt2 = date(lch.value1).

    if v-dt2 < v-dt1 then do:
        run savelog( "kredbureau", "Дата закрытия должна быть больше даты открытия! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.


    create t-cred.
    assign t-cred.crpurpose   = "7"
           t-cred.fundingtype = if not v-gar then "7"  else "8"
           t-cred.ctstatus    = "1"
           t-cred.stdate      = v-dt1
           t-cred.edate       = v-dt2
           t-cred.rpdate      = v-dt3
           t-cred.ctphase     = v-sts
           t-cred.ctcode      = lc.lc
           t-cred.gua         = if not v-gar then 'AKKR' else 'GA'
           t-cred.pmtper      = "10".

    find first lch where lch.lc = lc.lc and lch.kritcode = 'Amount' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Amount! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    t-cred.crlimit = deci(lch.value1).

    if v-cover = '2' then do:
        find first lch where lch.lc = lc.lc and lch.kritcode = 'CovAmt' no-lock no-error.
        if avail lch then t-cred.crlimit = t-cred.crlimit - deci(lch.value1).
    end.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
    if avail lch and lch.value1 ne '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then t-cred.crlimit = t-cred.crlimit + (t-cred.crlimit * (v-per / 100)).
    end.

    /* amendment */
    if v-gar then
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if not avail txb.jh then do:
                run savelog( "kredbureau", "Не найдена проводка " + string(lcamendres.jh) + " в таблице jh! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
                v-sendmail = v-sendmail + 1.
            end.
            else do:
                if lcamendres.dacc = '605562' then t-cred.crlimit = t-cred.crlimit + lcamendres.amt.
                else t-cred.crlimit = t-cred.crlimit - lcamendres.amt.
            end.
        end.
    else
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.levD = 23 or  lcamendres.levD = 24 or lcamendres.levC = 23 or  lcamendres.levC = 24) and lcamendres.jh > 0 no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if not avail txb.jh then do:
                run savelog( "kredbureau", "Не найдена проводка " + string(lcamendres.jh) + " в таблице jh! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
                v-sendmail = v-sendmail + 1.
            end.
            else do:
                if lcamendres.levD = 23 or lcamendres.levD = 24 then t-cred.crlimit = t-cred.crlimit + lcamendres.amt.
                else t-cred.crlimit = t-cred.crlimit - lcamendres.amt.
            end.
        end.

    find first lch where lch.lc = lc.lc and lch.kritcode = 'lccrc' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Currency Code! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    find txb.crc where txb.crc.crc = int(lch.value1) no-lock no-error.
    if avail txb.crc then assign t-cred.crc = txb.crc.code.

    find first lch where lch.lc = lc.lc and lch.kritcode = '1CBclas' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Classification (1CB)! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    t-cred.class = lch.value1.

    find first lch where lch.lc = lc.lc and lch.kritcode = '1CBccrc' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Collateral Currency Code (1CB)! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    find txb.crc where txb.crc.crc = int(lch.value1) no-lock no-error.
    if avail txb.crc then assign t-cred.colatcrc = txb.crc.code.

    find first lch where lch.lc = lc.lc and lch.kritcode = '1CBctype' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Collateral Type (1CB)! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    t-cred.colaterall = lch.value1.

    find first lch where lch.lc = lc.lc and lch.kritcode = '1CBcval' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Collateral Value (1CB)! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    t-cred.colatamt = lch.value1.

    /* данные по клиенту */
    v-cod = if v-gar then 'PrCode' else 'ApplCode'.
    find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        find first lckrit where lckrit.datacode = v-cod and lckrit.lctype = 'i' no-lock no-error.
        v-name = if avail lckrit then lckrit.dataname else ''.
        run savelog( "kredbureau", "Не найден реквизит " +  v-name  + "! Филиал " + txb.cmp.addr[1] + ",Аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.

    find txb.cif where txb.cif.cif = lch.value1 no-lock no-error.
    if not avail txb.cif then next.
    if txb.cif.type = 'P' then t-cred.sbclass = "1".
    if txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0 /*txb.cif.cgr = 403*/ then t-cred.sbclass = "2".

    assign t-cred.tel     = txb.cif.tel
           t-cred.tlx     = txb.cif.tlx
           t-cred.fax     = txb.cif.fax
           t-cred.cidnum3 = trim(txb.cif.ref[8])
           t-cred.cregdt3 = txb.cif.expdt.

    if (v-bank = "TXB16" or v-bank = "TXB00") then t-cred.addrloc1 = "675".
    else find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code <> 'msc' no-lock no-error.
    if avail txb.codfr then do:
        if txb.codfr.name[2] = '0' then do:
            run savelog( "kredbureau", "Не заполнен справочник - Населенные пункты для Кредитного бюро! Филиал -  " + txb.cmp.addr[1] + ", Населеный пункт - " + txb.codfr.name[1]).
            v-sendmail = v-sendmail + 1.
        end.
        else t-cred.addrloc1 = txb.codfr.name[2].
    end.

    if txb.cif.type = 'P' or (txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0 ) then do:
        if txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") <> 0 then do:
            if txb.cif.coregdt <> ? then t-cred.dtbirth = txb.cif.coregdt.
            else t-cred.dtbirth = txb.cif.expdt.
        end.
        else t-cred.dtbirth = txb.cif.expdt.

        if txb.cif.type = 'P' then do:
            assign t-cred.sbfname = entry(2, txb.cif.name, " ")
                   t-cred.sbsname = entry(1, txb.cif.name, " ").
            if num-entries( trim(txb.cif.name), ' ' ) > 2 then t-cred.sbfthname = entry(3, txb.cif.name, " ").
        end.
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnchf' no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then do:
                if trim(txb.sub-cod.rcode) <> '' then do:
                    if num-entries(txb.sub-cod.rcode, " ") > 1 then t-cred.sbfname = entry(2,txb.sub-cod.rcode, " ").
                    t-cred.sbsname = entry(1, txb.sub-cod.rcode, " ").
                    if num-entries( trim(txb.sub-cod.rcode), ' ' ) > 2 then t-cred.sbfthname = entry(3, txb.sub-cod.rcode, " ").
                end.
                else do:
                    run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                    v-sendmail = v-sendmail + 1.
                end.
            end.
            else do:
                run savelog( "kredbureau", "Отсутствует параметр clnchf ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
            end.

        end.
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'clnsex' no-lock no-error.
        if avail txb.sub-cod then do:
            if txb.sub-cod.ccode = '01' then t-cred.sbgender = "M".
            else t-cred.sbgender = "F".
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр clnsex ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if txb.cif.geo = "022" then t-cred.residency = "2".
        if txb.cif.geo = "021" then t-cred.residency = "1".
        if trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.*/
        /*
        if txb.cif.jss = '' and txb.cif.type = "B" and lookup(string(txb.cif.cgr),"403,405,605") = 0 then do:
            run savelog( "kredbureau", "Не заполнен РНН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        */
        if txb.cif.bin = '' then do:
            run savelog( "kredbureau", "Не заполнен ИИН/БИН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        assign
            t-cred.sbidnum1 = txb.cif.jss
            t-cred.sbidnum2 = entry(1,txb.cif.pss,' ')
            t-cred.sbidnum3 = txb.cif.bin.
        if txb.cif.type = 'P' then do:
            if trim(txb.cif.addr[1]) = trim(txb.cif.addr[2]) then t-cred.strname1 = trim(txb.cif.addr[1]).
            else t-cred.strname1 = trim(txb.cif.addr[1]) + trim(txb.cif.addr[2]).
            if num-entries(trim(txb.cif.item),'|') > 1 then t-cred.strname2 = entry(2,trim(txb.cif.item),'|').
            else t-cred.strname2 = trim(txb.cif.item).
        end.
        else do:
            t-cred.strname1 = trim(txb.cif.addr[1]).
            if trim(txb.cif.addr[2]) <> '' then t-cred.strname2 = trim(txb.cif.addr[2]).
            else t-cred.strname2 = trim(txb.cif.addr[1]).
        end.

        if num-entries(txb.cif.pss,' ') > 1 then do:
            t-cred.sbregdt = date(entry(2,txb.cif.pss,' ')) no-error.
            if error-status:error then do:
                v-dterror = true.
                k = 1.
                repeat:
                    k = k + 1.
                    t-cred.sbregdt = date(entry(k,txb.cif.pss,' ')) no-error.
                    if not (error-status:error) then do: v-dterror = false. leave. end.
                    if k = num-entries(txb.cif.pss,' ')then leave.
                end.
            end.
            if v-dterror = true then do:
                t-cred.sbregdt = date('01.01.2008').
                run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
            end.
        end.
        else do:
            run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
    end.
    if (txb.cif.type = 'B' and lookup(string(txb.cif.cgr),"403,405,605") = 0) then do:
        t-cred.name = trim(substr(txb.cif.name,1,60)).
        if txb.cif.sname <> "" then t-cred.abbrev = txb.cif.sname.
        else t-cred.abbrev = trim(substr(txb.cif.name,1,60)).
        if trim(txb.cif.addr[1]) = '' then do:
            run savelog( "kredbureau", "Не заполнен адрес клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        /*else do:
            if num-entries(txb.cif.addr[2],',') <> 7 then do:
                run savelog( "kredbureau", "Некорректный фактический(проживания) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[2]).
                v-sendmail = v-sendmail + 1.
            end.
            if num-entries(txb.cif.addr[1],',') <> 7 and trim(txb.cif.addr[1]) <> '' then do:
                run savelog( "kredbureau", "Некорректный юридический(прописки) адрес клиента ! Филиал " + entry(2,txb.cmp.addr[1],',') + ", Клиент - " + txb.lon.cif + ", Адрес - " + txb.cif.addr[1]).
                v-sendmail = v-sendmail + 1.
            end.
        end.
        */
        /*
        if txb.cif.jss = '' and txb.cif.type = "B" and lookup(string(txb.cif.cgr),"403,405,605") = 0 then do:
            run savelog( "kredbureau", "Не заполнен РНН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        */
        if txb.cif.bin = '' then do:
            run savelog( "kredbureau", "Не заполнен ИИН/БИН клиента ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        assign
            t-cred.cidnum1  = txb.cif.jss
            t-cred.cidnum2  = txb.cif.ssn
            t-cred.sbidnum3 = txb.cif.bin
            t-cred.strname1 = trim(txb.cif.addr[1]).
        if trim(txb.cif.addr[2]) <> "" then t-cred.strname2 = trim(txb.cif.addr[2]).
        else t-cred.strname2 = trim(txb.cif.addr[1]).
        if entry(1,txb.cif.jel,'&') <> "" then do:
            t-cred.cregdt2 = date(entry(1,txb.cif.jel,'&')) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.cregdt2 = date('01.01.2008').
            end.
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            if num-entries(trim(txb.sub-cod.rcode),' ') > 0 then t-cred.msname = entry(1,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 1 then t-cred.mfname = entry(2,trim(txb.sub-cod.rcode),' ').
            if num-entries(trim(txb.sub-cod.rcode),' ') > 2 then t-cred.mmname = entry(3,trim(txb.sub-cod.rcode),' ').
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfrnn" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum1 = txb.sub-cod.rcode.

        if t-cred.midnum1 <> '' and not chk12_innbin(t-cred.midnum1) then do:
            run savelog( "kredbureau", "ИИН первого руководителя не прошел ключевание, возможно это РНН, замените на ИИН! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfdnum" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then t-cred.midnum2 = txb.sub-cod.rcode.

        find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnchfddt" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" and trim(txb.sub-cod.rcode) <> '' then do:
            t-cred.mregdt = date(txb.sub-cod.rcode) no-error.
            if error-status:error then do:
                run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                v-sendmail = v-sendmail + 1.
                t-cred.mregdt = date('01.01.2008').
            end.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'lnopf' no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then t-cred.legform = txb.sub-cod.ccode.
        /*
        find kdcif where kdcif.bank = v-bank and kdcif.kdcif = txb.cif.cif no-lock no-error.
        if avail kdcif then do:
            if t-cred.msname = '' then do:
                if kdcif.chief[1] <> '' then do:
                    t-cred.msname = trim(entry(1,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 1 then t-cred.mfname = trim(entry(2,kdcif.chief[1], ' ')).
                    if num-entries(kdcif.chief[1], ' ') > 2 then t-cred.mmname = trim(entry(2,kdcif.chief[1], ' ')).
                end.
            end.
            if t-cred.midnum1 = '' then t-cred.midnum1 = trim(kdcif.rnn_chief[1]).
            if t-cred.midnum2 = '' then t-cred.midnum2 = entry(1,kdcif.docs[1],' ').
            if t-cred.mregdt = ? then do:
                if num-entries(kdcif.docs[1],' ') > 1 then do:
                    t-cred.mregdt = date(entry(2,kdcif.docs[1],' ')) no-error.
                    if error-status:error then do:
                        run savelog( "kredbureau", "Неверный формат даты выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
                        v-sendmail = v-sendmail + 1.
                        t-cred.mregdt = date('01.01.2008').
                    end.
                end.
            end.
            if t-cred.legform = '' then t-cred.legform = kdcif.lnopf.
        end.
        */
        if t-cred.msname = '' then do:
            run savelog( "kredbureau", "Отсутствует Фамилия первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.mfname = '' then do:
            run savelog( "kredbureau", "Отсутствует Имя первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.midnum1 = '' then do:
            run savelog( "kredbureau", "Отсутствует ИИН первого руководителя! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.midnum2 = '' then do:
            run savelog( "kredbureau", "Отсутствует номер ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.mregdt = ? then do:
            run savelog( "kredbureau", "Отсутствует дата выдачи ПАСПОРТ/УДОС первому руководителю! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
        if t-cred.legform = '' then do:
            run savelog( "kredbureau", "Отсутствует Организационно-правовая форма хозяйствования! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.cif.cif).
            v-sendmail = v-sendmail + 1.
        end.
    end.
    /*-*/
    if t-cred.legform = '0' or t-cred.legform = '15' then t-cred.legform = '16'.

    if t-cred.legform = '1' or t-cred.legform = '9' then t-cred.Ownership = '0'.
                                                    else t-cred.Ownership = '1'.
    find first lch where lch.lc = lc.lc and lch.kritcode = 'Benef' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит Baneficiary! Филиал " + txb.cmp.addr[1] + ", аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    else assign t-cred.bennaim = trim(substring(lch.value1,1,35))
                t-cred.bentype = 1.

    find first lch where lch.lc = lc.lc and lch.kritcode = '1CBbcntr' no-lock no-error.
    if not avail lch or lch.value1 = '' then do:
        run savelog( "kredbureau", "Не найден реквизит 1CBbcntr! Филиал " + txb.cmp.addr[1] + ", аккредитив/гарантия - " + lc.lc).
        v-sendmail = v-sendmail + 1.
        next.
    end.
    else do:
        v-bencountry = trim(lch.value1).
        n = lookup(v-bencountry,bencount_tex).
        if n > 0 then t-cred.bencount = trim(entry(n,bencount_pkb)).
    end.

    /*if t-cred.ctstatus = '4' Then t-cred.ctstatus = '5'.
    if t-cred.ctstatus = '8' Then t-cred.ctstatus = '1'.*/
END.

FOR EACH t-cred /*where lookup(t-cred.gua,"CL,LO") = 0*/: /*??????*/
    if trim(t-cred.strname1) = "" then next.
    if replace(t-cred.sbidnum3,'№','') = '' then next.
    if t-cred.sbgender = '' and t-cred.legform = '' then next.

    if lookup(string(t-cred.fundingtype),"8,18") = 0 then do:
        if lookup(t-cred.gua,"CL,LO") <> 0 then
            if (t-cred.oinsamt = 0 and t-cred.ovinsamt = 0) and (t-cred.ctphase <> '5' and t-cred.ctphase <> '6')  then do:
                t-cred.ctphase = '5'.
            end.

        if t-cred.ctphase = '5' or t-cred.ctphase = '6' then do:
            t-cred.oinscount = 0.
            t-cred.oinsamt = 0.
            t-cred.ovinscount = 0.
            t-cred.ovinsamt = 0.
        end.

        if t-cred.gua = "CL" or t-cred.gua = "LO" then do:
            if t-cred.ovinsamt = 0 then do:
                t-cred.ctstatus = '1'.
                t-cred.class = '1'.
            end.
        end.

        if date_str(t-cred.rpdate) = ? Then t-cred.rpdate = g-today.

        if t-cred.stdate >= pksysc.daval then put stream m-out unformatted '<Contract operation = "1">' skip.
                                         else put stream m-out unformatted '<Contract operation = "2">' skip.
        put stream m-out unformatted "<General>" skip.


        put stream m-out unformatted "<ContractCode>" + t-cred.ctcode + "</ContractCode>" skip.
        put stream m-out unformatted "<AgreementNumber>" + t-cred.ctcode + "</AgreementNumber>" skip.

        put stream m-out unformatted '<FundingType id ="' + t-cred.fundingtype + '"/>' skip.
        put stream m-out unformatted '<CreditPurpose id = "' + t-cred.crpurpose + '"/>' skip.
        put stream m-out unformatted  '<ContractPhase id = "' + t-cred.ctphase + '"/>' skip.
        put stream m-out unformatted  '<ContractStatus id = "' + t-cred.ctstatus + '"/>' skip.
        put stream m-out unformatted  "<StartDate>" date_str(t-cred.stdate) "</StartDate>" skip.
        if (t-cred.fundingtype = '8' or t-cred.fundingtype = '18') and t-cred.edate = ? then put stream m-out unformatted  "<EndDate>1900-01-01</EndDate>" skip.
        else put stream m-out unformatted  "<EndDate>" date_str(t-cred.edate) "</EndDate>" skip.

        if t-cred.ctphase >= '5' then put stream m-out unformatted  "<RealPaymentDate>" date_str(t-cred.rpdate) "</RealPaymentDate>" skip.
        put stream m-out unformatted  '<Classification id = "' + t-cred.class + '"/>' skip.

        put stream m-out unformatted  "<Collaterals>" skip.
        do i = 1 to num-entries(t-cred.colaterall):
            put stream m-out unformatted  '<Collateral typeId = "' + entry(i,t-cred.colaterall) + '">' skip.
            put stream m-out unformatted  '<Value currency="' + entry(i,t-cred.colatcrc) + '" typeId = "3">' + entry(i,t-cred.colatamt) + '</Value>' skip.
            put stream m-out unformatted  "</Collateral>" skip.
        end.
        put stream m-out unformatted  "</Collaterals>" skip.

        /************Заемщик************************************************************************************/

        put stream m-out unformatted  "<Subjects>" skip.
        put stream m-out unformatted  '<Subject roleId="1">' skip.
        put stream m-out unformatted  "<Entity>" skip.
        if t-cred.legform = '' then do:
            put stream m-out unformatted  "<Individual>" skip.
            put stream m-out unformatted  "<FirstName>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbfname '</Text>' skip.
            put stream m-out unformatted  "</FirstName>" skip.
            put stream m-out unformatted  "<Surname>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbsname '</Text>' skip.
            put stream m-out unformatted  "</Surname>" skip.
            if t-cred.sbfthname <> '' then do:
                put stream m-out unformatted  "<FathersName>" skip.
                put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbfthname '</Text>' skip.
                put stream m-out unformatted  "</FathersName>" skip.
            end.
            put stream m-out unformatted  '<Gender>' t-cred.sbgender '</Gender>' skip.
            put stream m-out unformatted  '<Classification id = "' + t-cred.sbclass + '"/>' skip.
            put stream m-out unformatted  '<Residency id = "' t-cred.residency '"/>' skip.
            put stream m-out unformatted  "<DateOfBirth>" date_str(t-cred.dtbirth) "</DateOfBirth>" skip.
            put stream m-out unformatted  '<Citizenship id = "110"/>' skip.

            put stream m-out unformatted  "<Identifications>" skip.
            if replace(t-cred.sbidnum1,'№','') <> '' then do:
                put stream m-out unformatted  '<Identification typeId = "1" rank = "2">' skip.
                put stream m-out unformatted  "<Number>" rep2utf(t-cred.sbidnum1) "</Number>" skip.
                put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
                put stream m-out unformatted  "</Identification>" skip.
            end.
            put stream m-out unformatted  '<Identification typeId = "7" rank = "2">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.sbidnum2,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.sbregdt) "</RegistrationDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.
            put stream m-out unformatted  '<Identification typeId = "14" rank = "1">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.sbidnum3,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.
            put stream m-out unformatted  "</Identifications>" skip.

            put stream m-out unformatted  "<Addresses>" skip.
            put stream m-out unformatted  '<Address typeId = "6" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out unformatted  "<StreetName>" skip.
            put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
            put stream m-out unformatted  "</StreetName>" skip.
            put stream m-out unformatted  "</Address>" skip.
            if trim(t-cred.strname2) ne '' then do:
                put stream m-out unformatted  '<Address typeId = "1" locationId = "' t-cred.addrloc1 '">' skip.
                put stream m-out unformatted  "<StreetName>" skip.
                put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname2) '</Text>' skip.
                put stream m-out unformatted  "</StreetName>" skip.
                put stream m-out unformatted  "</Address>" skip.
            end.
            else do:
                put stream m-out unformatted  '<Address typeId = "1" locationId = "' t-cred.addrloc1 '">' skip.
                put stream m-out unformatted  "<StreetName>" skip.
                put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
                put stream m-out unformatted  "</StreetName>" skip.
                put stream m-out unformatted  "</Address>" skip.
            end.

            put stream m-out unformatted  "</Addresses>" skip.

            put stream m-out unformatted "<Communications>" skip.
            if t-cred.tel <> "" then  put stream m-out unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
            if t-cred.tlx <> "" then  put stream m-out unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
            if t-cred.fax <> "" then  put stream m-out unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.
            put stream m-out unformatted "</Communications>" skip.

            put stream m-out unformatted "<Dependants>" skip.
            put stream m-out unformatted '<Dependant count = "0" typeId = "1"/>' skip.
            put stream m-out unformatted "</Dependants>" skip.

            put stream m-out unformatted  "</Individual>" skip.
        end.
        /********************для ЮЛ****************/
        else do:
            put stream m-out unformatted  "<Company>" skip.
            put stream m-out unformatted "<Name>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' rep2utf(t-cred.name) '</Text>' skip.
            put stream m-out unformatted "</Name>" skip.
            put stream m-out unformatted '<Status id = "1"/>' skip.
            put stream m-out unformatted "<TradeName>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' rep2utf(t-cred.name) '</Text>' skip.
            put stream m-out unformatted "</TradeName>" skip.
            put stream m-out unformatted "<Abbrevation>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' rep2utf(t-cred.abbrev) '</Text>' skip.
            put stream m-out unformatted  "</Abbrevation>" skip.
            put stream m-out unformatted '<LegalForm id = "' t-cred.legform '"/>' skip.
            put stream m-out unformatted '<Ownership id = "' t-cred.Ownership '"/>' skip.
            put stream m-out unformatted '<Nationality id = "110"/>' skip.
            put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.cregdt3) "</RegistrationDate>" skip.
            /*-*/
            put stream m-out unformatted '<EconomicActivity id = "19"/>' skip.

            put stream m-out unformatted  "<Addresses>" skip.
            /*адрес госрегитсрации*/
            put stream m-out unformatted  '<Address typeId = "4" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out unformatted  "<StreetName>" skip.
            put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
            put stream m-out unformatted  "</StreetName>" skip.
            put stream m-out unformatted  "</Address>" skip.
            put stream m-out unformatted  '<Address typeId = "5" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out unformatted  "<StreetName>" skip.
            put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname2) '</Text>' skip.
            put stream m-out unformatted  "</StreetName>" skip.
            put stream m-out unformatted  "</Address>" skip.
    	    put stream m-out unformatted  "</Addresses>" skip.

            put stream m-out unformatted  "<Identifications>" skip.
            if trim(t-cred.cidnum1) <> '' then do:
                put stream m-out unformatted  '<Identification typeId = "1" rank = "2">' skip.
                put stream m-out unformatted  "<Number>" replace(t-cred.cidnum1,'№','N') "</Number>" skip.
                put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
                put stream m-out unformatted  "</Identification>" skip.
            end.
            if t-cred.cidnum2 <> '' and t-cred.cregdt2 <> ? then do:
                put stream m-out unformatted  '<Identification typeId = "10" rank = "2">' skip.
                put stream m-out unformatted  "<Number>" replace(t-cred.cidnum2,'№','N') "</Number>" skip.
                put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.cregdt2) "</RegistrationDate>" skip.
                put stream m-out unformatted  "</Identification>" skip.
            end.
            put stream m-out unformatted  '<Identification typeId = "11" rank = "2">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.cidnum3,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.cregdt3) "</RegistrationDate>" skip.
            put stream m-out unformatted  "<IssueDate>" date_str(t-cred.cregdt3) "</IssueDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.
            put stream m-out unformatted  '<Identification typeId = "15" rank = "1">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.sbidnum3,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.
            put stream m-out unformatted  "</Identifications>" skip.

  	        put stream m-out unformatted "<Communications>" skip.
            if t-cred.tel <> "" then  put stream m-out unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
            if t-cred.tlx <> "" then  put stream m-out unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
            if t-cred.fax <> "" then  put stream m-out unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.
            put stream m-out unformatted "</Communications>" skip.

            put stream m-out unformatted "<Management>" skip.
            put stream m-out unformatted "<CEO>" skip.
            put stream m-out unformatted "<FirstName>" skip.
            put stream m-out unformatted  '<Text language="ru-RU">' t-cred.mfname '</Text>' skip.
            put stream m-out unformatted "</FirstName>" skip.
            put stream m-out unformatted "<Surname>" skip.
            put stream m-out unformatted '<Text language="ru-RU">' t-cred.msname '</Text>' skip.
            put stream m-out unformatted "</Surname>" skip.
            if t-cred.mmname <> '' then do:
                put stream m-out unformatted  "<FathersName>" skip.
                put stream m-out unformatted  '<Text language="ru-RU">' t-cred.mmname '</Text>' skip.
                put stream m-out unformatted  "</FathersName>" skip.
            end.

            put stream m-out unformatted  "<Identifications>" skip.
            if not v-bin then
                put stream m-out unformatted  '<Identification typeId = "1" rank = "1">' skip.
            else
                put stream m-out unformatted  '<Identification typeId = "14" rank = "1">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.midnum1,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.

            put stream m-out unformatted  '<Identification typeId = "7" rank = "2">' skip.
            put stream m-out unformatted  "<Number>" replace(t-cred.midnum2,'№','N') "</Number>" skip.
            put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.mregdt) "</RegistrationDate>" skip.
            put stream m-out unformatted  "</Identification>" skip.
            put stream m-out unformatted  "</Identifications>" skip.

            put stream m-out "</CEO>" skip.
            put stream m-out "</Management>" skip.
            put stream m-out "</Company>" skip.
        end.
        /******************/

        put stream m-out unformatted  "</Entity>" skip.
        put stream m-out unformatted  "</Subject>" skip.

        /**************************/

        put stream m-out unformatted  "</Subjects>" skip.
        put stream m-out unformatted "</General>" skip.

        /*********Кредит********************************************************************************************/
        put stream m-out unformatted "<Type>" skip.
    end.
    if lookup(string(t-cred.fundingtype),"8,18") <> 0 then do:
        if t-cred.bencount = '' then next.
        if lookup(t-cred.gua,"CL,LO") <> 0 then
            if (t-cred.oinsamt = 0 and t-cred.ovinsamt = 0) and (t-cred.ctphase <> '5' and t-cred.ctphase <> '6')  then do:
                t-cred.ctphase = '5'.
            end.

        if t-cred.ctphase = '5' or t-cred.ctphase = '6' then do:
            t-cred.oinscount = 0.
            t-cred.oinsamt = 0.
            t-cred.ovinscount = 0.
            t-cred.ovinsamt = 0.
        end.

        if t-cred.gua = "CL" or t-cred.gua = "LO" then do:
            if t-cred.ovinsamt = 0 then do:
                t-cred.ctstatus = '1'.
                t-cred.class = '1'.
            end.
        end.

        if date_str(t-cred.rpdate) = ? Then t-cred.rpdate = g-today.

        if t-cred.stdate >= pksysc.daval then put stream m-out1 unformatted '<Contract operation = "1">' skip.
                                         else put stream m-out1 unformatted '<Contract operation = "2">' skip.
        put stream m-out1 unformatted "<General>" skip.

        put stream m-out1 unformatted "<ContractCode>" + t-cred.ctcode + "</ContractCode>" skip.
        put stream m-out1 unformatted "<AgreementNumber>" + t-cred.ctcode + "</AgreementNumber>" skip.

        if lookup(t-cred.gua,"CL,LO") = 0 then
            put stream m-out1 unformatted "<AgreementNumberGuarantee>" + t-cred.ctcode + "</AgreementNumberGuarantee>" skip.

        put stream m-out1 unformatted '<FundingType id ="' + t-cred.fundingtype + '"/>' skip.
        put stream m-out1 unformatted '<CreditPurpose id = "' + t-cred.crpurpose + '"/>' skip.
        put stream m-out1 unformatted  '<ContractPhase id = "' + t-cred.ctphase + '"/>' skip.
        put stream m-out1 unformatted  '<ContractStatus id = "' + t-cred.ctstatus + '"/>' skip.
        put stream m-out1 unformatted  "<StartDate>" date_str(t-cred.stdate) "</StartDate>" skip.
        if t-cred.gua = "GA" and t-cred.edate = ? then i = 0. /*put stream m-out1 unformatted  "<EndDate>1900-01-01</EndDate>" skip.*/
        else put stream m-out1 unformatted  "<EndDate>" date_str(t-cred.edate) "</EndDate>" skip.

        if t-cred.fundingtype = "8" or t-cred.fundingtype = "18" then
            put stream m-out1 unformatted  "<DateAgreementGuarantee>" date_str(t-cred.stdate) "</DateAgreementGuarantee>" skip.
        if t-cred.ctphase >= '5' then put stream m-out1 unformatted  "<RealPaymentDate>" date_str(t-cred.rpdate) "</RealPaymentDate>" skip.
        if t-cred.gua = "GA" and t-cred.edate = ? then do:
            put stream m-out1 unformatted  "<GuaranteeEvent>" skip.
            if length(t-cred.ctcode) >= 20 then
                put stream m-out1 unformatted '<Text language="ru-RU">Закрытие счета ' + t-cred.ctcode + '</Text>' skip.
            else
                put stream m-out1 unformatted '<Text language="ru-RU">Расторжение договора ' + t-cred.ctcode + '</Text>' skip.
            put stream m-out1 unformatted "</GuaranteeEvent>" skip.
        end.
        put stream m-out1 unformatted  '<Classification id = "' + t-cred.class + '"/>' skip.

        put stream m-out1 unformatted  "<Collaterals>" skip.
        do i = 1 to num-entries(t-cred.colaterall):
            put stream m-out1 unformatted  '<Collateral typeId = "' + entry(i,t-cred.colaterall) + '">' skip.
            put stream m-out1 unformatted  '<Value currency="' + entry(i,t-cred.colatcrc) + '" typeId = "3">' + entry(i,t-cred.colatamt) + '</Value>' skip.
            put stream m-out1 unformatted  "</Collateral>" skip.
        end.
        put stream m-out1 unformatted  "</Collaterals>" skip.
        /************Заемщик************************************************************************************/
        put stream m-out1 unformatted  "<Subjects>" skip.
        put stream m-out1 unformatted  '<Subject roleId="1">' skip.
        put stream m-out1 unformatted  "<Entity>" skip.
        if t-cred.legform = '' then do:
            put stream m-out1 unformatted  "<Individual>" skip.
            put stream m-out1 unformatted  "<FirstName>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' t-cred.sbfname '</Text>' skip.
            put stream m-out1 unformatted  "</FirstName>" skip.
            put stream m-out1 unformatted  "<Surname>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' t-cred.sbsname '</Text>' skip.
            put stream m-out1 unformatted  "</Surname>" skip.
            if t-cred.sbfthname <> '' then do:
                put stream m-out1 unformatted  "<FathersName>" skip.
                put stream m-out1 unformatted  '<Text language="ru-RU">' t-cred.sbfthname '</Text>' skip.
                put stream m-out1 unformatted  "</FathersName>" skip.
            end.
            put stream m-out1 unformatted  '<Gender>' t-cred.sbgender '</Gender>' skip.
            put stream m-out1 unformatted  '<Classification id = "' + t-cred.sbclass + '"/>' skip.

            put stream m-out1 unformatted  '<Residency id = "' t-cred.residency '"/>' skip.
            put stream m-out1 unformatted  "<DateOfBirth>" date_str(t-cred.dtbirth) "</DateOfBirth>" skip.
            put stream m-out1 unformatted  '<Citizenship id = "110"/>' skip.

            put stream m-out1 unformatted  "<Identifications>" skip.
            if replace(t-cred.sbidnum1,'№','') <> '' then do:
                put stream m-out1 unformatted  '<Identification typeId = "1" rank = "2">' skip.
                put stream m-out1 unformatted  "<Number>" replace(t-cred.sbidnum1,'№','N') "</Number>" skip.
                put stream m-out1 unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
                put stream m-out1 unformatted  "</Identification>" skip.
            end.
            put stream m-out1 unformatted  '<Identification typeId = "7" rank = "2">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.sbidnum2,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>" date_str(t-cred.sbregdt) "</RegistrationDate>" skip.
            put stream m-out1 unformatted  "<IssueDate>" date_str(t-cred.sbregdt) "</IssueDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  '<Identification typeId = "14" rank = "1">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.sbidnum3,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  "</Identifications>" skip.

            put stream m-out1 unformatted  "<Addresses>" skip.
            put stream m-out1 unformatted  '<Address typeId = "6" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out1 unformatted  "<StreetName>" skip.
            put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
            put stream m-out1 unformatted  "</StreetName>" skip.
            put stream m-out1 unformatted  "</Address>" skip.
            if trim(t-cred.strname2) ne '' then do:
                put stream m-out1 unformatted  '<Address typeId = "1" locationId = "' t-cred.addrloc1 '">' skip.
                put stream m-out1 unformatted  "<StreetName>" skip.
                put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname2) '</Text>' skip.
                put stream m-out1 unformatted  "</StreetName>" skip.
                put stream m-out1 unformatted  "</Address>" skip.
            end.
            else do:
                put stream m-out unformatted  '<Address typeId = "1" locationId = "' t-cred.addrloc1 '">' skip.
                put stream m-out unformatted  "<StreetName>" skip.
                put stream m-out unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
                put stream m-out unformatted  "</StreetName>" skip.
                put stream m-out unformatted  "</Address>" skip.
            end.
            /*put stream m-out1 unformatted  '<Address typeId = "3" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out1 unformatted  "<StreetName>" skip.
            put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
            put stream m-out1 unformatted  "</StreetName>" skip.
            put stream m-out1 unformatted  "</Address>" skip.
            */
            put stream m-out1 unformatted  "</Addresses>" skip.

            if t-cred.tel <> "" or t-cred.tlx <> "" or t-cred.fax <> "" then do:
                put stream m-out1 unformatted "<Communications>" skip.
                if t-cred.tel <> "" then  put stream m-out1 unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
                if t-cred.tlx <> "" then  put stream m-out1 unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
                if t-cred.fax <> "" then  put stream m-out1 unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.
                put stream m-out1 unformatted "</Communications>" skip.
            end.

            put stream m-out1 unformatted "<Dependants>" skip.
            put stream m-out1 unformatted '<Dependant count = "0" typeId = "1"/>' skip.
            put stream m-out1 unformatted "</Dependants>" skip.

            put stream m-out1 unformatted  "</Individual>" skip.
        end.
        /********************для ЮЛ****************/
        else do:
            put stream m-out1 unformatted  "<Company>" skip.
            put stream m-out1 unformatted "<Name>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' rep2utf(t-cred.name) '</Text>' skip.
            put stream m-out1 unformatted "</Name>" skip.
            put stream m-out1 unformatted '<Status id = "1"/>' skip.
            put stream m-out1 unformatted "<TradeName>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' rep2utf(t-cred.name)  '</Text>' skip.
            put stream m-out1 unformatted "</TradeName>" skip.
            put stream m-out1 unformatted "<Abbrevation>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' rep2utf(t-cred.abbrev) '</Text>' skip.
            put stream m-out1 unformatted  "</Abbrevation>" skip.
            put stream m-out1 unformatted '<LegalForm id = "' t-cred.legform '"/>' skip.
            put stream m-out1 unformatted '<Ownership id = "' t-cred.Ownership '"/>' skip.
            put stream m-out1 unformatted '<Nationality id = "110"/>' skip.
            /*-*/
            put stream m-out1 unformatted  "<RegistrationDate>" date_str(t-cred.cregdt3) "</RegistrationDate>" skip.
            put stream m-out1 unformatted '<EconomicActivity id = "19"/>' skip.

            put stream m-out1 unformatted  "<Addresses>" skip.
            /*адрес госрегитсрации*/
            put stream m-out1 unformatted  '<Address typeId = "4" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out1 unformatted  "<StreetName>" skip.
            put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname1) '</Text>' skip.
            put stream m-out1 unformatted  "</StreetName>" skip.
            put stream m-out1 unformatted  "</Address>" skip.
            put stream m-out1 unformatted  '<Address typeId = "5" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out1 unformatted  "<StreetName>" skip.
            put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.strname2) '</Text>' skip.
            put stream m-out1 unformatted  "</StreetName>" skip.
            put stream m-out1 unformatted  "</Address>" skip.
    	    put stream m-out1 unformatted  "</Addresses>" skip.

            put stream m-out1 unformatted  "<Identifications>" skip.
            if trim(t-cred.cidnum1) <> '' then do:
                put stream m-out1 unformatted  '<Identification typeId = "1" rank = "2">' skip.
                put stream m-out1 unformatted  "<Number>" replace(t-cred.cidnum1,'№','N') "</Number>" skip.
                put stream m-out1 unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
                put stream m-out1 unformatted  "</Identification>" skip.
            end.
            if t-cred.cidnum2 <> '' and t-cred.cregdt2 <> ? then do:
                put stream m-out1 unformatted  '<Identification typeId = "10" rank = "2">' skip.
                put stream m-out1 unformatted  "<Number>" replace(t-cred.cidnum2,'№','N') "</Number>" skip.
                put stream m-out1 unformatted  "<RegistrationDate>" date_str(t-cred.cregdt2) "</RegistrationDate>" skip.
                put stream m-out1 unformatted  "</Identification>" skip.
            end.
            put stream m-out1 unformatted  '<Identification typeId = "11" rank = "2">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.cidnum3,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>" date_str(t-cred.cregdt3) "</RegistrationDate>" skip.
            put stream m-out1 unformatted  "<IssueDate>" date_str(t-cred.cregdt3) "</IssueDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  '<Identification typeId = "15" rank = "1">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.sbidnum3,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  "</Identifications>" skip.

            if t-cred.tel <> "" or t-cred.tlx <> "" or t-cred.fax <> "" then do:
                put stream m-out1 unformatted "<Communications>" skip.
                if t-cred.tel <> "" then  put stream m-out1 unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
                if t-cred.tlx <> "" then  put stream m-out1 unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
                if t-cred.fax <> "" then  put stream m-out1 unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.
                put stream m-out1 unformatted "</Communications>" skip.
            end.

            put stream m-out1 unformatted "<Management>" skip.
            put stream m-out1 unformatted "<CEO>" skip.
            put stream m-out1 unformatted "<FirstName>" skip.
            put stream m-out1 unformatted  '<Text language="ru-RU">' t-cred.mfname '</Text>' skip.
            put stream m-out1 unformatted "</FirstName>" skip.
            put stream m-out1 unformatted "<Surname>" skip.
            put stream m-out1 unformatted '<Text language="ru-RU">' t-cred.msname '</Text>' skip.
            put stream m-out1 unformatted "</Surname>" skip.
            if t-cred.mmname <> '' then do:
                put stream m-out1 unformatted  "<FathersName>" skip.
                put stream m-out1 unformatted  '<Text language="ru-RU">' t-cred.mmname '</Text>' skip.
                put stream m-out1 unformatted  "</FathersName>" skip.
            end.

            put stream m-out1 unformatted  "<Identifications>" skip.
            if not v-bin then
                put stream m-out1 unformatted  '<Identification typeId = "1" rank = "1">' skip.
            else
                put stream m-out1 unformatted  '<Identification typeId = "14" rank = "1">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.midnum1,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  '<Identification typeId = "7" rank = "2">' skip.
            put stream m-out1 unformatted  "<Number>" replace(t-cred.midnum2,'№','N') "</Number>" skip.
            put stream m-out1 unformatted  "<RegistrationDate>" date_str(t-cred.mregdt) "</RegistrationDate>" skip.
            put stream m-out1 unformatted  "<IssueDate>" date_str(t-cred.mregdt) "</IssueDate>" skip.
            put stream m-out1 unformatted  "</Identification>" skip.
            put stream m-out1 unformatted  "</Identifications>" skip.

            put stream m-out1 "</CEO>" skip.
            put stream m-out1 "</Management>" skip.
            put stream m-out1 "</Company>" skip.
        end.
        /******************/

        put stream m-out1 unformatted  "</Entity>" skip.
        put stream m-out1 unformatted  "</Subject>" skip.
        /*************кредитор по гарантиям**************/
        if t-cred.gua = "GA" then do:
            if t-cred.bentype > 0 then do:
                put stream m-out1 unformatted  '<Subject roleId="12">' skip.
                put stream m-out1 unformatted  '<Entity>' skip.
                if t-cred.bentype > 1 then do:
                    put stream m-out1 unformatted '<Individual>' skip.
                    put stream m-out1 unformatted '<FirstName>' skip.
                    put stream m-out1 unformatted '<Text language="ru-RU">' t-cred.benfname '</Text>' skip.
                    put stream m-out1 unformatted '</FirstName>' skip.
                    put stream m-out1 unformatted '<Surname>' skip.
                    put stream m-out1 unformatted '<Text language="ru-RU">' t-cred.benlname '</Text>' skip.
                    put stream m-out1 unformatted '</Surname>' skip.
                    put stream m-out1 unformatted '<FathersName>' skip.
                    put stream m-out1 unformatted '<Text language="ru-RU">' t-cred.benmname '</Text>' skip.
                    put stream m-out1 unformatted '</FathersName>' skip.
                    put stream m-out1 unformatted '<Residency id="' string(t-cred.benres,'9') '" />' skip.
                    put stream m-out1 unformatted '</Individual>' skip.
                end.
                if t-cred.bentype = 1 then do:
                    put stream m-out1 unformatted '<Company>' skip.
                    put stream m-out1 unformatted '<Name>' skip.
                    put stream m-out1 unformatted '<Text language="ru-RU">' rep2utf(t-cred.bennaim) '</Text>' skip.
                    put stream m-out1 unformatted '</Name>' skip.
                    if t-cred.bencount <> '' then put stream m-out1 unformatted '<Nationality id = "' t-cred.bencount '"/>' skip.
                    put stream m-out1 unformatted '</Company>' skip.
                end.
                put stream m-out1 unformatted  '</Entity>' skip.
                put stream m-out1 unformatted  '</Subject>' skip.
            end.
        end.
        /**************************/
        put stream m-out1 unformatted  "</Subjects>" skip.
        put stream m-out1 unformatted "</General>" skip.
        /*********Кредит********************************************************************************************/
        put stream m-out1 unformatted "<Type>" skip.
    end.
    if lookup(string(t-cred.fundingtype),'8,18') = 0 then do:

        put stream m-out unformatted '<Instalment paymentMethodId = "1" paymentPeriodId = "' t-cred.pmtper '">' skip.
        put stream m-out unformatted '<TotalAmount currency = "' t-cred.crc '">' string(t-cred.tamt) '</TotalAmount>' skip.
        put stream m-out unformatted '<InstalmentAmount currency = "' t-cred.crc '">' string(t-cred.insamt) '</InstalmentAmount>' skip.

        put stream m-out unformatted "<InstalmentCount>" string(t-cred.inscount) "</InstalmentCount>" skip.
        put stream m-out unformatted "<Records>" skip.
        put stream m-out unformatted '<Record accountingDate = "' date_str(g-today) '">' skip.

        /*не погашен*/
        put stream m-out unformatted "<OutstandingInstalmentCount>" string(t-cred.oinscount) "</OutstandingInstalmentCount>" skip.
        put stream m-out unformatted '<OutstandingAmount currency = "' t-cred.crc '">' string(t-cred.oinsamt) '</OutstandingAmount>' skip.

        /*просрочка*/
        put stream m-out unformatted "<OverdueInstalmentCount>" string(t-cred.ovinscount) "</OverdueInstalmentCount>" skip.
        /*put stream m-out unformatted "<NumberOfDaysOverdue>" string(t-cred.ovinscount) "</NumberOfDaysOverdue>" skip.*/
        put stream m-out unformatted '<OverdueAmount currency = "' t-cred.crc '">' string(t-cred.ovinsamt) '</OverdueAmount>' skip.
        /*-put stream m-out unformatted "<InterestRate>" string(t-cred.intrate) "</InterestRate>" skip.*/

        put stream m-out unformatted "</Record>" skip.
        put stream m-out unformatted "</Records>" skip.
        put stream m-out unformatted "</Instalment>" skip.

    end.

    if lookup(string(t-cred.fundingtype),'8,18') <> 0 then do:
        put stream m-out1 unformatted '<Instalment paymentMethodId = "1" paymentPeriodId = "10">' skip.
        put stream m-out1 unformatted '<TotalAmount currency = "' t-cred.crc '">' string(t-cred.crlimit) '</TotalAmount>' skip.
        put stream m-out1 unformatted "<Records>" skip.
        put stream m-out1 unformatted '<Record accountingDate = "' date_str(g-today) '">' skip.
        put stream m-out1 unformatted "</Record>" skip.
        put stream m-out1 unformatted "</Records>" skip.
        put stream m-out1 unformatted "</Instalment>" skip.
    end.

    if lookup(string(t-cred.fundingtype),'8,18') = 0 then do:
        put stream m-out unformatted "</Type>" skip.
        put stream m-out unformatted "</Contract>" skip.
        v-dogcount = v-dogcount + 1.
        if v-dogcount = 2000 then do:
            put stream m-out unformatted '</Records>' skip.
            output stream m-out close.
            v-find0 = ''.
            input through value( "find /data/log/kred" + string(v-paket) + ".xml;echo $?").
            repeat:
                import unformatted v-find0.
            end.
            if v-find0 = "0" then unix silent value("rm /data/log/kred" + string(v-paket) + ".xml").
            unix silent cp kred.xml value("/data/log/kred" + string(v-paket) + ".xml").

            unix silent koi2utf kred.xml kredit.xml.
            unix silent value ("cb1pump.pl -zip -login=MBuser56 -password=2W3e4r5t -method=UploadZippedData2 -schid=3 -file2send=kredit.xml > /data/log/res.xml").
            run mail('FCB@fortebank.com', "FORTEBANK <abpk@fortebank.com>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res.xml").
            v-find1 = ''.
            input through value( "find `askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml;echo $?").
            repeat:
                import unformatted v-find1.
            end.
            if v-find1 = "0" then unix silent value("rm `askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml").
            unix silent scp -q kredit.xml value(" Administrator@`askhost`:c:/PKB/kredit" + string(v-paket) + num + ".xml").

            v-paket = v-paket + 1.
            v-dogcount = 0.
            output stream m-out to "kred.xml".
            put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
            put stream m-out unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
            put stream m-out unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
            put stream m-out unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZ_v5.xsd">' skip.
        end.
    end.
    if lookup(string(t-cred.fundingtype),'8,18') <> 0 then do:
        put stream m-out1 unformatted "</Type>" skip.
        put stream m-out1 unformatted "</Contract>" skip.
        v-garcount = v-garcount + 1.
        if v-garcount = 2000 then do:
            put stream m-out1 unformatted '</Records>' skip.
            output stream m-out1 close.
            v-find0 = ''.
            input through value( "find /data/log/gar" + string(v-paket1) + ".xml;echo $?").
            repeat:
                import unformatted v-find0.
            end.
            if v-find0 = "0" then unix silent value("rm /data/log/gar" + string(v-paket1) + ".xml").
            unix silent cp gar.xml value("/data/log/gar" + string(v-paket1) + ".xml").

            unix silent koi2utf gar.xml garan.xml.
            unix silent value ("cb1pump.pl -zip -login=MBuser56 -password=2W3e4r5t -method=UploadZippedData2 -schid=11 -file2send=garan.xml > /data/log/res.xml").
            run mail('FCB@fortebank.com', "FORTEBANK <abpk@fortebank.com>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res.xml").
            v-find1 = ''.
            input through value( "find `askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml;echo $?").
            repeat:
                import unformatted v-find1.
            end.
            if v-find1 = "0" then unix silent value("rm `askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml").
            unix silent scp -q garan.xml value(" Administrator@`askhost`:c:/PKB/garan" + string(v-paket1) + num + ".xml").

            v-paket1 = v-paket1 + 1.
            v-garcount = 0.
            output stream m-out1 to "gar.xml".
            put stream m-out1 unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
            put stream m-out1 unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
            put stream m-out1 unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
            put stream m-out1 unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZ_v5_guar.xsd">' skip.
        end.
    end.
END.

pksysc.inval = v-paket.
/*if pksysc.daval ne g-today then pksysc.daval = g-today.*/
find first pksysc where pksysc.sysc = '1cb' no-lock no-error.


