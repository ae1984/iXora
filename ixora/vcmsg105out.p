/* vcmsg105out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Для Приложения 7 - Отчет о задолжниках по контрактам с ПС, по услугам и фин.займам
 * RUN

 * CALLER
        vcrep7.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        20.05.2008 galina
 * CHANGES
        14.08.2009 galina - добавила запись в историю отправки ЛКБК и вывод коментария в МТ
        04.04.2011 damir  - вывел bnkbin(БИН банка),iin(ИИН ИП),bin(БИН Юридического лица)
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        31.05.2011 aigul - исправила таблицу t-cif
        06.12.2011 damir - убрал chbin.i, поставил vcmtform.i.
        09.10.2013 damir - Т.З. № 1670.
        */

{vc.i}
{srvcheck.i}
{vcmtform.i} /*переход на БИН и ИИН*/

{global.i}

def input parameter p-contract   like vccontrs.contract.
def input parameter p-cardnum    as char.
def input parameter p-cardreason as char.

def var v-dir       as char.
def var v-ipaddr    as char.
def var v-exitcod   as char.
def var v-text      as char.
def var v-filename  as char.
def var v-filename0 as char init "vcmsg.txt".

def shared temp-table t-docs
    field clcif         like cif.cif
    field clname        like cif.name
    field okpo          as char format "999999999999"
    field rnn           as char format "999999999999"
    field clntype       as char
    field address       as char
    field region        as char
    field psnum         as char
    field psdate        as date
    field bankokpo      as char
    field ctexpimp      as char
    field ctnum         as char
    field ctdate        as date
    field ctsum         as char
    field ctncrc        as char
    field partner       like vcpartners.name
    field countryben    as char
    field ctterm        as char
    field dolgsum       as char
    field dolgsum_usd   as char
    field cardsend      like vccontrs.cardsend
    field valterm       as integer
    field prefix        as char
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary clcif ctdate ctsum.

def shared temp-table t-cif
    field clcif         like cif.cif
    field clname        like cif.name
    field okpo          as char format "999999999999"
    field rnn           as char format "999999999999"
    field clntype       as char
    field address       as char
    field region        as char
    field psnum         as char
    field psdate        as date
    field bankokpo      as char
    field ctexpimp      as char
    field ctnum         as char
    field ctdate        as date
    field ctsum         as char
    field ctncrc        as char
    field partner       like vcpartners.name
    field countryben    as char
    field ctterm        as char
    field cardsend      like vccontrs.cardsend
    field prefix        as char
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary clcif ctdate ctsum.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var i as integer no-undo.
def var v-monthname as char init
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

 /* формирование телеграммы */
/* путь к каталогу исходящих телеграмм */

find vcparams where vcparams.parcode = "mtpathou" no-lock no-error.
if not avail vcparams then do:
    message skip " Не найден параметр mtpathou !"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

if isProductionServer() then do:
    v-dir = vcparams.valchar.
    v-ipaddr = "Administrator@fs01.metrobank.kz".
end.
else do:
    v-dir = "C:/VC105/".
    v-ipaddr = "Administrator@`askhost`".
end.

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") + string(day(g-today), "99") + "/".

/* проверка существования каталога за сегодняшнее число */
output to sendtest.
put "Ok".
output close .

input through value("scp -q sendtest " + v-ipaddr + ":" + v-dir + ";echo $?" ).
repeat :
    import v-exitcod.
end.

unix silent rm -f sendtest.

if v-exitcod <> "0" then do :
    message skip " Не найден каталог " + replace(v-dir, "/", "\\")
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

find vccontrs where vccontrs.contract = p-contract no-lock.
if not avail vccontrs then return.

find first t-docs no-lock no-error.
if avail t-docs then do:
    for each t-docs no-lock:
        {vcmsgparam_new.i &msg = "105"}

        v-text = "/CARDNUMBER/" + substr(trim(p-cardnum), 1, length(p-cardnum)).
        put stream rpt unformatted v-text skip.

        v-text = "/REPORTMONTH/" + string(v-month, '99') + string(v-god, '9999').
        put stream rpt unformatted v-text skip.

        if t-docs.cardsend = no then do:
        v-text = "/OPER/1".
        put stream rpt unformatted v-text skip.
        end.

        if t-docs.cardsend = yes then do:
        v-text = "/OPER/2".
        put stream rpt unformatted v-text skip.
        end.

        do i = 1 to num-entries(p-cardreason):
        v-text = "/REASON/" + entry(i,p-cardreason).
        put stream rpt unformatted v-text skip.
        end.

        v-text = "/NAME/" + t-docs.clname.
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//OKPO/" + t-docs.okpo.
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-docs.rnn.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            if t-docs.bin <> "" then do:
                v-text = "//BIN/" + t-docs.bin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            if t-docs.iin <> "" then do:
                v-text = "//IIN/" + t-docs.iin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/" + t-docs.clntype.
        put stream rpt unformatted v-text skip.

        if length(trim(t-docs.address)) > 100 then do:
            v-text = "//ADDRESS/" + substr(trim(t-docs.address), 1, 100).
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "//ADDRESS/" + t-docs.address.
            put stream rpt unformatted v-text skip.
        end.

        v-text = "//REGION/" + t-docs.region.
        put stream rpt unformatted v-text skip.

        v-text = "//PFORM/" + t-docs.prefix.
        put stream rpt unformatted v-text skip.

        v-text = "/PSNUMBER/" + t-docs.psnum.
        put stream rpt unformatted v-text skip.

        if t-docs.psdate <> ? then
        v-text = "//PSDATE/" + string(day(t-docs.psdate),'99') + string(month(t-docs.psdate),'99') + string(year(t-docs.psdate),'9999').
        else v-text = "//PSDATE/".
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//BANKOKPO/" + t-docs.bankokpo.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//BANKOKPO/".
            put stream rpt unformatted v-text skip.

            if t-docs.bnkbin <> "" then do:
                v-text = "//BANKBIN/" + t-docs.bnkbin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/EISIGN/" + t-docs.ctexpimp.
        put stream rpt unformatted v-text skip.

        v-text = "/CONTRACT/" + t-docs.ctnum.
        put stream rpt unformatted v-text skip.

        v-text = "//CDATE/" +  string(day(t-docs.ctdate),'99') + string(month(t-docs.ctdate),'99') + string(year(t-docs.ctdate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "//CSUMM/" + replace(t-docs.ctsum, '.',',').
        put stream rpt unformatted v-text skip.

        v-text = "//CCURR/" + t-docs.ctncrc.
        put stream rpt unformatted v-text skip.

        v-text = "/NRNAME/" + t-docs.partner.
        put stream rpt unformatted v-text skip.

        v-text = "//NRCOUNTRY/" + t-docs.countryben.
        put stream rpt unformatted v-text skip.

        v-text = "/IDATE/" + string(t-docs.ctterm, '999.99').
        put stream rpt unformatted v-text skip.

        if (index(p-cardreason, '1') > 0 or index(p-cardreason, '5') > 0) then do:
            v-text = "//ICSUMM/" + replace(t-docs.dolgsum, '.', ',').
            put stream rpt unformatted v-text skip.

            v-text = "//IUSDSUMM/" + replace(t-docs.dolgsum_usd, '.', ',').
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "//ICSUMM/".
            put stream rpt unformatted v-text skip.

            v-text = "//IUSDSUMM/".
            put stream rpt unformatted v-text skip.
        end.

        v-text = "/NOTE/".
        if trim(vccontrs.info[10]) <> '' then do:
            if length(vccontrs.info[10]) <= 100 then v-text = v-text + substr(vccontrs.info[10],1,length(vccontrs.info[10])).
            if length(vccontrs.info[10]) > 100 then do:
                v-text = v-text + substr(vccontrs.info[10],1,100).
                if length(vccontrs.info[10]) <= 200 then v-text = v-text + chr(10) + substr(vccontrs.info[10],101,length(vccontrs.info[10])).
                if length(vccontrs.info[10]) > 200 then do:
                    v-text = v-text + chr(10) + substr(vccontrs.info[10],101,100) +  chr(10).
                    v-text = v-text + substr(vccontrs.info[10],201,100).
                end.
            end.
        end.
        put stream rpt unformatted v-text skip.

        {vcmsgend.i &msg = "105"}
    end.
end.

find first t-cif no-lock no-error.
if avail t-cif then do:
    for each t-cif no-lock:
        {vcmsgparam_new.i &msg = "105"}

        v-text = "/CARDNUMBER/" + substr(trim(p-cardnum), 1, length(p-cardnum)).
        put stream rpt unformatted v-text skip.

        v-text = "/REPORTMONTH/" + string(v-month, '99') + string(v-god, '9999').
        put stream rpt unformatted v-text skip.

        if t-cif.cardsend = no then do:
        v-text = "/OPER/1".
        put stream rpt unformatted v-text skip.
        end.

        if t-cif.cardsend = yes then do:
        v-text = "/OPER/2".
        put stream rpt unformatted v-text skip.
        end.

        do i = 1 to num-entries(p-cardreason):
        v-text = "/REASON/" + entry(i,p-cardreason).
        put stream rpt unformatted v-text skip.
        end.

        v-text = "/NAME/" + t-cif.clname.
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//OKPO/" + t-cif.okpo.
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-cif.rnn.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            if t-cif.bin <> "" then do:
                v-text = "//BIN/" + t-cif.bin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            if t-cif.iin <> "" then do:
                v-text = "//IIN/" + t-cif.iin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/" + t-cif.clntype.
        put stream rpt unformatted v-text skip.

        if length(trim(t-cif.address)) > 100 then do:
            v-text = "//ADDRESS/" + substr(trim(t-cif.address), 1, 100).
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "//ADDRESS/" + t-cif.address.
            put stream rpt unformatted v-text skip.
        end.

        v-text = "//REGION/" + t-cif.region.
        put stream rpt unformatted v-text skip.

        v-text = "//PFORM/" + t-cif.prefix.
        put stream rpt unformatted v-text skip.

        v-text = "/PSNUMBER/" + t-cif.psnum.
        put stream rpt unformatted v-text skip.

        if t-cif.psdate <> ? then
        v-text = "//PSDATE/" + string(day(t-cif.psdate),'99') + string(month(t-cif.psdate),'99') + string(year(t-cif.psdate),'9999').
        else v-text = "//PSDATE/".
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//BANKOKPO/" + t-cif.bankokpo.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//BANKOKPO/".
            put stream rpt unformatted v-text skip.

            if t-cif.bnkbin <> "" then do:
                v-text = "//BANKBIN/" + t-cif.bnkbin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/EISIGN/" + t-cif.ctexpimp.
        put stream rpt unformatted v-text skip.

        v-text = "/CONTRACT/" + t-cif.ctnum.
        put stream rpt unformatted v-text skip.

        v-text = "//CDATE/" +  string(day(t-cif.ctdate),'99') + string(month(t-cif.ctdate),'99') + string(year(t-cif.ctdate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "//CSUMM/" + replace(t-cif.ctsum, '.',',').
        put stream rpt unformatted v-text skip.

        v-text = "//CCURR/" + t-cif.ctncrc.
        put stream rpt unformatted v-text skip.

        v-text = "/NRNAME/" + t-cif.partner.
        put stream rpt unformatted v-text skip.

        v-text = "//NRCOUNTRY/" + t-cif.countryben.
        put stream rpt unformatted v-text skip.

        v-text = "/IDATE/" + string(t-cif.ctterm, '999.99').
        put stream rpt unformatted v-text skip.

        v-text = "//ICSUMM/".
        put stream rpt unformatted v-text skip.

        v-text = "//IUSDSUMM/".
        put stream rpt unformatted v-text skip.

        v-text = "/NOTE/".
        if trim(vccontrs.info[10]) <> '' then do:
            if length(vccontrs.info[10]) <= 100 then v-text = v-text + substr(vccontrs.info[10],1,length(vccontrs.info[10])).
            if length(vccontrs.info[10]) > 100 then do:
                v-text = v-text + substr(vccontrs.info[10],1,100).
                if length(vccontrs.info[10]) <= 200 then v-text = v-text + chr(10) + substr(vccontrs.info[10],101,length(vccontrs.info[10])).
                if length(vccontrs.info[10]) > 200 then do:
                    v-text = v-text + chr(10) + substr(vccontrs.info[10],101,100) +  chr(10).
                    v-text = v-text + substr(vccontrs.info[10],201,100).
                end.
            end.
        end.
        put stream rpt unformatted v-text skip.
        {vcmsgend.i &msg = "105"}
    end.
end.

find current vccontrs exclusive-lock.
if not vccontrs.cardsend then do:
    vccontrs.cardsend = yes.
    vccontrs.cardfirstdt = g-today.
    vccontrs.cardfirstmsg = v-filename.
    vccontrs.cardsenddt = g-today.
    vccontrs.cardlastdt = g-today.
end.
else do:
    if vccontrs.cardlastdt <> g-today then do:
        vccontrs.cardsenddt = vccontrs.cardlastdt.
        vccontrs.cardlastdt = g-today.
    end.
end.

vccontrs.cardlastmsg = v-filename.

find current vccontrs no-lock.

find first vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = '40' and vcdocs.info[4] = v-filename no-lock no-error.
if not avail vcdocs then do:
    create vcdocs.
    vcdocs.docs = next-value(vc-docs).
    vcdocs.contract = vccontrs.contract.
    vcdocs.dndate = vccontrs.cardsenddt.
    vcdocs.dntype = '40'.
    vcdocs.info[1] = vccontrs.cardnum.
    vcdocs.info[2] = p-cardreason.
    vcdocs.info[3] = string(v-month,'99') + '.' + string(v-god,'9999').
    vcdocs.info[4] = v-filename.
    vcdocs.info[5] = vccontrs.info[10].
end.

