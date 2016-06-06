/* vccrlkbk.p
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
        BANK COMM
 * CHANGES
        02.12.2011 damir - ЛКБК формируется последовательно по каждому филиалу.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        09.10.2013 damir - Т.З. № 1670.
*/
{global.i}

def shared var s-contract like vccontrs.contract.
def shared var s-cif like vccontrs.cif.

def var v-card as char format "x(25)".
def var v-cardprev as char format "x(12)".
def var v-sts as char init "".
def var v-cardreas as char init "".
def var v-numb as inte format "999999999999".
def var v-create as logi format "да/нет" init no.
def var v-bnkbin as char.
def var i as inte init 0.
def var j as inte init 0.
def var v-stst as char no-undo init "".
def var v-reast as char no-undo init "".
def var v-sel as inte no-undo init 0.
def var repname as char init "1.htm".
def var v-month as char no-undo init "".
def var v-year as char no-undo init "".
def var v-cifname as char no-undo init "".
def var v-cifokpo as char no-undo init "".
def var v-rnn as char no-undo init "".
def var v-urfiz as char no-undo init "".
def var v-address as char no-undo init "".
def var v-region as char no-undo init "".
def var v-ps as char no-undo init "".
def var v-psdate as date no-undo init ?.
def var v-okpobnk as char no-undo init "".
def var v-eisign as char no-undo init "".
def var v-ctnum as char no-undo init "".
def var v-ctdate as date no-undo init ?.
def var v-ctsum as deci no-undo init 0 format ">>>>>>>>>>>>>>>9.99".
def var v-ctcrc as char no-undo init "".
def var v-partner as char no-undo init "".
def var v-country as char no-undo init "".
def var v-ctterm as char no-undo init "" format "999.99".
def var v-sumobyz1 as deci no-undo init 0.
def var v-sumobyz2 as deci no-undo init 0.
def var v-primech as char no-undo init "".
def var v-expimp as char no-undo init "".
def var v-cttype as char no-undo init "".
def var v-txb as char no-undo init "".
def var v-sumusd as deci format ">>>>>>>>>>>>>>>>>>>>9.99".
def var v-sumcon as deci format ">>>>>>>>>>>>>>>>>>>>9.99".
def var v-sumgtd as deci decimals 2.
def var v-sumplat as deci decimals 2.
def var v-sumakt as deci decimals 2.
def var v-docsgtd as char.
def var v-docsplat as char.
def var v-docsakt as char.
def var v-sum as deci.
def var v-term as date init ?.
def var v-dolgdays as inte init 0.
def var v-sumdolg as deci init 0.
def var v-sum-all as deci decimals 2.
def var vv-sum-all as deci decimals 2.
def var vv-sum-dt as deci decimals 2.
def var vv-date as date.
def var vv-summa as deci decimals 2.
def var vv-sum as deci decimals 2.
def var vv-summ as deci decimals 2.
def var vv-plus1 as deci decimals 2 init 0.
def var vv-plus2 as deci decimals 2 init 0.
def var vv-term as date.
def var vv-sum-dt1 as deci decimals 2.

def temp-table vcdoc
    field contr  as inte
    field dt     as date
    field sum    as deci
    field docsum as deci
    field sts    as inte.

def temp-table vcdocum
    field contr  as inte
    field dt     as date.

def temp-table t-sts
    field code as inte
    field name as char.

def temp-table t-reason
    field code as inte
    field name as char.

def stream rep.
output stream rep to value(repname).

do j = 1 to 2:
    create t-sts.
    t-sts.code = j.
    if j = 1 then t-sts.name = "<N> - новая".
    if j = 2 then t-sts.name = "<D> - формируется повторно".
end.

do j = 1 to 2:
    create t-reason.
    t-reason.code = j.
    if j = 1 then t-reason.name = "<1> - неисполнение нерезидентом обязательств по контракту в сроки репатриации".
    if j = 2 then t-reason.name = "<3> - принятие к валютному контролю контракта без ПС на сумму свыше эквивалента 50000(пятьдесят тысяч) долларов США со сроком репатриации свыше одного календарного года".
end.

find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bnkbin = sysc.chval.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then v-txb = trim(sysc.chval).

find first comm.txb where comm.txb.bank = v-txb no-lock no-error.
if avail comm.txb then v-okpobnk = entry(2,comm.txb.par,",").

find first cif where cif.cif = s-cif no-lock no-error.
if avail cif then do:
    v-cifname = cif.name + " " + cif.prefix.
    v-cifokpo = cif.ssn.
    find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
    if avail sub-cod then do:
        if trim(sub-cod.ccode) = "9" then v-rnn = cif.jss.
    end.
    if trim(cif.type) = "B" then v-urfiz = "1".
    else if trim(cif.type) = "P" then v-urfiz = "2".
    v-address = cif.addr[1] + ", " + cif.addr[2].
    find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "regionkz" no-lock no-error.
    if avail sub-cod then do:
        v-region = sub-cod.ccode.
    end.
    find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnbk" and sub-cod.ccode = 'mainbk' no-lock no-error.
    if avail sub-cod then do:
        if v-primech <> "" then v-primech = v-primech + ", " + sub-cod.rcode.
        else v-primech = sub-cod.rcode.
    end.
    find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" and sub-cod.ccode = 'chief' no-lock no-error.
    if avail sub-cod then do:
        if v-primech <> "" then v-primech = v-primech + ", " + sub-cod.rcode.
        else v-primech = sub-cod.rcode.
    end.
    if v-primech <> "" then v-primech = v-primech + ", " + cif.tel + ", " + cif.tlx.
    else v-primech = cif.tel + ", " + cif.tlx.
end.

find first vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock no-error.
if avail vcps then do:
    v-ps     = trim(vcps.dnnum) + string(vcps.num).
    v-psdate = vcps.dndate.
end.

find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
if avail vccontrs then do:
    if vccontrs.expimp = "E" then v-eisign = "1".
    else if vccontrs.expimp = "I" then v-eisign = "2".
    v-expimp = trim(vccontrs.expimp).
    v-cttype = trim(vccontrs.cttype).
    v-ctnum = vccontrs.ctnum.
    v-ctdate = vccontrs.ctdate.
    v-ctsum = vccontrs.ctsum / 1000.
    find first crc where crc.crc = vccontrs.ncrc no-lock no-error.
    if avail crc then v-ctcrc = trim(crc.code).
    find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
    if avail vcpartners then do:
        v-partner = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
        v-country = trim(vcpartner.country).
    end.
    v-ctterm = vccontrs.ctterm.
end.

v-card = "". i = 0.
for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "40" and vcdocs.info[1] <> "" no-lock break by vcdocs.rdt:
    i = i + 1.
end.

v-create = false.
if i = 0 then do:
    v-create = yes.
    find nmbr where nmbr.code = "LKBK" no-lock no-error.
    v-numb = nmbr.nmbr.
    v-card = v-bnkbin + "/" + string(v-numb,"999999999999").
end.
else do:
    find last vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "40" and vcdocs.info[1] <> "" no-lock no-error.
    if avail vcdocs then v-card = vcdocs.info[1].
end.

v-sts = "N".

form
    v-card label "Номер ЛКБК" format "x(25)" skip
    v-sts label "Признак лицевой карточки" format "x(1)" validate(v-sts = "N" or v-sts = "D","Недопустимый признак лицевой карточки, выберите <N> или <D>!!!")
    help "Выбор через (F2): N - новая, D - повторно" skip
    v-cardreas label "Основание ЛКБК" format "x(1)" validate(v-cardreas = "1" or v-cardreas = "3", "Выберите тип 1 или 3 !!!")
    help "Выбор через (F2)" skip
with row 20 centered width 50 overlay side-label title "Введите параметры ЛКБК" frame lkbk.

on help of v-sts in frame lkbk do:
    if v-stst = "" then do:
        for each t-sts no-lock:
            if v-stst <> "" then v-stst = v-stst + " |".
            v-stst = v-stst + string(t-sts.code) + " " + t-sts.name.
        end.
    end.
    run sel2 (" Выберите признак лицевой карточки", v-stst, output v-sel).
    if v-sel <> 0 then do:
        if v-sel = 1 then v-sts = "N".
        else if v-sel = 2 then v-sts = "D".
        display v-sts with frame lkbk.
    end.
end.

on help of v-cardreas in frame lkbk do:
    if v-reast = "" then do:
        for each t-reason no-lock:
            if v-reast <> "" then v-reast = v-reast + " |".
            v-reast = v-reast + string(t-reason.code) + " " + t-reason.name.
        end.
    end.
    run sel2 (" Выберите основание ЛКБК", v-reast, output v-sel).
    if v-sel <> 0 then do:
        if v-sel = 1 then v-cardreas = "1".
        else if v-sel = 2 then v-cardreas = "3".
        display v-cardreas with frame lkbk.
    end.
end.

update v-card with frame lkbk.
displ v-card with frame lkbk.
update v-sts with frame lkbk.
displ v-sts with frame lkbk.
update v-cardreas with frame lkbk.
displ v-cardreas with frame lkbk.

if v-sts = "N" and v-create then do:
    do transaction:
        create vcdocs.
        vcdocs.docs = next-value(vc-docs).
        vcdocs.contract = s-contract.
        vcdocs.dntype = "40".
        vcdocs.info[1] = v-card.   /*Номер лицевой карточки*/
        vcdocs.info[3] = string(month(g-today),"99") + "." + string(year(g-today),"9999").  /*Дата создания лицевой карточки*/
        vcdocs.info[2] = v-cardreas. /*Основание направления ЛКБК*/
        vcdocs.numb = v-numb.
        vcdocs.sts = v-sts.
        vcdocs.dndate = g-today.
        vcdocs.rwho = g-ofc.
        vcdocs.rdt = today.

        find nmbr where nmbr.code = "LKBK" exclusive-lock no-error.
        nmbr.nmbr = nmbr.nmbr + 1.
        find current nmbr no-lock no-error.

        find current vccontrs exclusive-lock no-error.
        vccontrs.cardnum = vcdocs.info[1].
        find current vccontrs no-lock no-error.
    end.
end.
else do:
    assign v-cifname = "" v-cifokpo = "" v-rnn = "" v-urfiz = "" v-address = "" v-region = "" v-ps = "" v-psdate = ? v-okpobnk = "" v-eisign = "" v-ctnum = "" v-ctdate = ? v-ctsum = 0
    v-ctcrc = "" v-partner = "" v-country = "" v-ctterm = "".
end.

if month(g-today) - 1 = 1       then v-month = "январь".
else if month(g-today) - 1 = 2  then v-month = "февраль".
else if month(g-today) - 1 = 3  then v-month = "март".
else if month(g-today) - 1 = 4  then v-month = "апрель".
else if month(g-today) - 1 = 5  then v-month = "май".
else if month(g-today) - 1 = 6  then v-month = "июнь".
else if month(g-today) - 1 = 7  then v-month = "июль".
else if month(g-today) - 1 = 8  then v-month = "август".
else if month(g-today) - 1 = 9  then v-month = "сентябрь".
else if month(g-today) - 1 = 10 then v-month = "октябрь".
else if month(g-today) - 1 = 11 then v-month = "ноябрь".
else if month(g-today) - 1 = 12 then v-month = "декабрь".

if month(g-today) - 1 = 0 then v-year = string(year(g-today) - 1,"9999").
else v-year = string(year(g-today),"9999").

/*Проверка попадает ли данный контракт в отчеты по задолжникам*/
/*------------------------------------------------------------*/
function konv2usd returns decimal (p-sum as decimal, p-crc as integer, p-date as date).
    def var vp-sum as decimal.
    def var v-kurs as decimal init 0.
    def var v-cursusd2 as deci.
    if p-crc = 2 then vp-sum = p-sum.
    else do:
        find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-date no-lock no-error.
        if avail ncrchis and ncrchis.rate[1] <> 0 then do:
            v-kurs = ncrchis.rate[1].
        end.
        else do:
            find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-date and ncrchis.rate[1] <> 0 no-lock no-error.
            if avail ncrchis then do:
                v-kurs = ncrchis.rate[1].
            end.
            else do:
                v-kurs = 1.
            end.
        end.
    find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= p-date no-lock no-error.
    if avail ncrchis then v-cursusd2 = ncrchis.rate[1].
    vp-sum = (p-sum * v-kurs) / v-cursusd2.
    end.
return vp-sum.
end.

function check-term returns decimal (p-term as char).
    def var v-repdays as integer.
    def var v-repyears as integer.
    def var v-srokrep as decimal.
    v-repdays = integer(substring(string(p-term,'999.99' ),1,3)).
    v-repyears = integer(substring(string(p-term, '999.99'),5,2)).
    if (v-repdays <= 360 and v-repyears = 0) then do:
        v-srokrep = v-repdays.
        end.
    if (v-repdays <= 360 and v-repyears > 0) then do:
        v-srokrep = v-repdays + v-repyears * 360.
        end.
    return v-srokrep.
end.

v-docsgtd = "".
for each codfr where codfr.codfr = "vcdoc" and index("g", codfr.name[5]) > 0 no-lock:
    v-docsgtd = v-docsgtd + codfr.code + ",".
end.

v-docsplat = "".
for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
    v-docsplat = v-docsplat + codfr.code + ",".
end.

v-docsakt = "".
for each codfr where codfr.codfr = "vcdoc" and index("o", codfr.name[5]) > 0 and codfr.code = "17" no-lock:
    v-docsakt = v-docsakt + codfr.code + ",".
end.

if v-cttype = "1" then do:
    /*1)Задолжники - консигнация (экспорт) на дату*/
    /*2)Задолжники - платежи, не покрытые ГТД (импорт)*/
    if v-expimp = "E" then {vcdolg1.i}.
    if v-expimp = "I" then {vcdolg2.i}.
end.
else if v-cttype = "3" then do:  /*Задолжники - платежи (услуги), не покр.актами*/
    if v-expimp = "E" then {vcdolg3-1.i}.
    if v-expimp = "I" then {vcdolg3-2.i}.
end.
/*------------------------------------------------------------*/

def temp-table t-temp
    field code as inte
    field name as char
    field nums as char
    field des  as char
    index idx is primary code ascending.

do i = 1 to 26:
    create t-temp.
    t-temp.code = i.
    if i = 1 then do:
        t-temp.name = "Основание направления лицевой карточки:".
        t-temp.nums = "10".
        if v-cardreas <> "" then t-temp.des = v-cardreas.
    end.
    if i = 2 then do:
        t-temp.name = "Информация по экспортеру или импортеру:".
        t-temp.nums = "20".
    end.
    if i = 3 then do:
        t-temp.name = "Наименование или фамилия, имя, отчество".
        t-temp.nums = "21".
        if v-cifname <> "" then t-temp.des = v-cifname.
    end.
    if i = 4 then do:
        t-temp.name = "Код ОКПО".
        t-temp.nums = "22".
        if v-cifokpo <> "" then t-temp.des = v-cifokpo.
    end.
    if i = 5 then do:
        t-temp.name = "РНН".
        t-temp.nums = "23".
        if v-rnn <> "" then t-temp.des = v-rnn.
    end.
    if i = 6 then do:
        t-temp.name = "Признак - юридическое лицо или индивидуальный предприниматель".
        t-temp.nums = "24".
        if v-urfiz <> "" then t-temp.des = v-urfiz.
    end.
    if i = 7 then do:
        t-temp.name = "Адрес".
        t-temp.nums = "25".
        if v-address <> "" then t-temp.des = v-address.
    end.
    if i = 8 then do:
        t-temp.name = "Код области".
        t-temp.nums = "26".
        if v-region <> "" then t-temp.des = v-region.
    end.
    if i = 9 then do:
        t-temp.name = "Паспорт сделки:".
        t-temp.nums = "30".
    end.
    if i = 10 then do:
        t-temp.name = "Номер".
        t-temp.nums = "31".
        if v-ps <> "" then t-temp.des = v-ps.
    end.
    if i = 11 then do:
        t-temp.name = "Дата".
        t-temp.nums = "32".
        if v-psdate <> ? then t-temp.des = string(v-psdate,"99.99.9999").
    end.
    if i = 12 then do:
        t-temp.name = "Код ОКПО банка паспорта сделки".
        t-temp.nums = "40".
        if v-okpobnk <> "" then t-temp.des = v-okpobnk.
    end.
    if i = 13 then do:
        t-temp.name = "Информация по контракту:".
        t-temp.nums = "50".
    end.
    if i = 14 then do:
        t-temp.name = "Признак - экспорт или импорт".
        t-temp.nums = "51".
        if v-eisign <> "" then t-temp.des = v-eisign.
    end.
    if i = 15 then do:
        t-temp.name = "Номер".
        t-temp.nums = "52".
        if v-ctnum <> "" then t-temp.des = v-ctnum.
    end.
    if i = 16 then do:
        t-temp.name = "Дата".
        t-temp.nums = "53".
        if v-ctdate <> ? then t-temp.des = string(v-ctdate,"99.99.9999").
    end.
    if i = 17 then do:
        t-temp.name = "Сумма в тысячах единиц".
        t-temp.nums = "54".
        if v-ctsum <> 0 then t-temp.des = string(v-ctsum,">>>>>>>>>>>>>>>9.99").
    end.
    if i = 18 then do:
        t-temp.name = "Валюта контракта".
        t-temp.nums = "55".
        if v-ctcrc <> "" then t-temp.des = v-ctcrc.
    end.
    if i = 19 then do:
        t-temp.name = "Информация по нерезиденту:".
        t-temp.nums = "60".
    end.
    if i = 20 then do:
        t-temp.name = "Наименование или фамилия, имя, отчество".
        t-temp.nums = "61".
        if v-partner <> "" then t-temp.des = v-partner.
    end.
    if i = 21 then do:
        t-temp.name = "Страна".
        t-temp.nums = "62".
        if v-country <> "" then t-temp.des = v-country.
    end.
    if i = 22 then do:
        t-temp.name = "Сроки репатриации:".
        t-temp.nums = "70".
        if v-ctterm <> "" then t-temp.des = string(v-ctterm,"999.99").
    end.
    if i = 23 then do:
        t-temp.name = "Информация о сумме неисполненных обязательств нерезидента по контракту в сроки репатриации перед экспортером или импортером".
        t-temp.nums = "80".
    end.
    if i = 24 then do:
        t-temp.name = "В валюте контракта".
        t-temp.nums = "81".
        if v-sumcon <> 0 then t-temp.des = string(v-sumcon / 1000,">>>>>>>>>>>>>>>>>>>>>>>>>9.99").
    end.
    if i = 25 then do:
        t-temp.name = "В долларах США".
        t-temp.nums = "82".
        if v-sumusd <> 0 then t-temp.des = string(v-sumusd / 1000,">>>>>>>>>>>>>>>>>>>>>>>>>9.99").
    end.
    if i = 26 then do:
        t-temp.name = "Примечание:".
        t-temp.nums = "90".
        if v-primech <> "" then t-temp.des = v-primech.
    end.
end.

{html-title.i
 &stream = "stream rep"
 &title = " "
 &size-add = "x-"
}

put stream rep unformatted
    "<P align=""right""> Приложение 7 <br> к Правилам осуществления <br> экспортно-импортного <br> валютного контроля в <br>
    Республике Казахстан </P>" skip
    "<P align=""center"" style=""font:bold"">Лицевая карточка банковского контроля № " v-card " <br> отчетный месяц " v-month " год " v-year
    " <br> (по состоянию на конец отчетного месяца) </P>" skip
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.

put stream rep unformatted
   "<TR align=""center"">" skip
   "<TD>№</TD>" skip
   "<TD>Наименование информации по лицевой карточке <br> банковского контроля</TD>" skip
   "<TD>Код <br> строки</TD>" skip
   "<TD>Информация по <br> лицевой карточке банковского <br> контроля</TD>" skip
   "</TR>" skip.

for each t-temp no-lock use-index idx:
    put stream rep unformatted
        "<TR>" skip
        "<TD align=center>" t-temp.code "</TD>" skip.
        if t-temp.code = 1 or t-temp.code = 2 or t-temp.code = 9 or t-temp.code = 12 or t-temp.code = 13 or t-temp.code = 19 or t-temp.code = 22 or
        t-temp.code = 23 or t-temp.code = 26 then do:
            put stream rep unformatted
                "<TD align=center>" t-temp.name "</TD>" skip.
        end.
        else do:
            put stream rep unformatted
                "<TD align=left>" t-temp.name "</TD>" skip.
        end.
        put stream rep unformatted
            "<TD align=center>" t-temp.nums "</TD>" skip
            "<TD align=center>" t-temp.des  "</TD>" skip
            "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

output stream rep close.

unix silent cptwin value(repname) winword.


