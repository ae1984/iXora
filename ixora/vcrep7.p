/* vcrep7.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложения 7,Отчет о задолжниках по контрактам с ПС, по услугам и фин.займам, MT-105
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        13.05.2008 galina
 * CHANGES
        20.05.2008 galina - изменения для формирования карточки клента
        21.05.2008 galina - проверка по справочнику основания оформления лиц.к.
        22.05.2008 galina - вывод справочника основание офорления лиц.к. по F2
        28.11.2008 galina - присвоение переменной v-cardreason значения из справочника основание офорления лиц.к.
        28/07/2009 galina - ищем контракт по номеру контракта
        29/07/2009 galina - перекомпеляция
        14.08.2009 galina - добавила ввод коментария для ЛКБК
        19.08.2009 galina- выделила в транзакционные блоки изменения в vccontrs
        21/10/2009 galina - поправила поиск контракта
        29/10/2009 galina - не пропускаем ЛКБК с причиной 1, если сумма нарушения меньше 50 тысяч

        15.02.2011 damir  - отображение при формировании МТ-105 в поле примечание = Ф.И.О. руководителя chief
        16.20.2011 damir  - отображение при формировании МТ-105 в поле примечание = телефон 1, телефон 2 из формы клиенты и контракты
                            добавил переменную v-mttel.
        04.04.2011 damir  - bnkbin,iin,bin во временную таблицу.
                            v-crc,v-bankokpo,v-region,v-prefix,v-address добавил.
                            значение записывается по другому v-cardnum
        28.04.2011 damir  - поставлены ключи. процедура chbin.i
        31.05.2011 aigul - исправила поиск контракта
        06.12.2011 damir - убрал chbin.i, поставил vcmtform.i.
        09.10.2013 damir - Т.З. № 1670.
*/


{vc.i}
{global.i}
{comm-txb.i}

{vcmtform.i} /*переход на БИН и ИИН*/

def input parameter p-bank   as char.
def input parameter p-depart as integer.
def input parameter p-option as char.

def var v-name      as char no-undo.
def var v-depname   as char no-undo.
def var v-ncrccod   like ncrc.code no-undo.
def var v-sum       like vcdocs.sum no-undo.
def var vi          as integer no-undo.
def var v-reason    as char no-undo.
def var v-sel       as integer no-undo.

def var v-rem as char no-undo.

def new shared var s-vcourbank as char.
def new shared var v-god as inte format "9999".
def new shared var v-month as inte format "99".
def new shared var v-dte as date.
def new shared var v-dtb as date.
def new shared var v-oper as char.
def new shared var s-cif like cif.cif.
def new shared var s-contract like vccontrs.contract.
def new shared var s-contrstat as char initial 'all'.

def new shared temp-table t-docs
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

def new shared temp-table t-cif
    field clcif       like cif.cif
    field clname      like cif.name
    field okpo        as char format "999999999999"
    field rnn         as char format "999999999999"
    field clntype     as char
    field address     as char
    field region      as char
    field psnum       as char
    field psdate      as date
    field bankokpo    as char
    field ctexpimp    as char
    field ctnum       as char
    field ctdate      as date
    field ctsum       as char
    field ctncrc      as char
    field partner     like vcpartners.name
    field countryben  as char
    field ctterm      as char
    field cardsend    like vccontrs.cardsend
    field prefix      as char
    field bnkbin      as char
    field bin         as char
    field iin         as char
    index main is primary clcif ctdate ctsum.

def var v-cardreas_old  as char.
def var v-cardmy_old    as char.
def var v-mttel         as char.

function check-cardreas returns char (p-cardreas as char).
    def var i as integer.
    def var s as char.
    def var l as logical.

    p-cardreas = trim(p-cardreas).
    if p-cardreas = ""   then s = "*".
    else do:
        if substring(p-cardreas, length(p-cardreas), 1) = "," then
        p-cardreas = substring(p-cardreas, length(p-cardreas) - 1).
        l = true.
        do i = 1 to num-entries(p-cardreas) :
            s = entry(i, p-cardreas).
            if s = "" or not (can-find(codfr where codfr.codfr = 'vccard' and codfr.code = s no-lock)) then do:
                l = false.
                if s = "" then s = "*".
                leave.
            end.
        end.
        if l then s = "".
    end.
    return s.
end.

s-vcourbank = comm-txb().

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
    v-month = 12.
    v-god = v-god - 1.
end.
else v-month = v-month - 1.

if p-option = 'rep' then do:

    update skip(1)
    v-month label "     Месяц " skip
    v-god label   "       Год " skip(1)
    with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".
    message "  Формируется отчет...".
end.

if p-option = 'msg' or p-option = 'card' then do:
    def var v-cifname as char.
    def var v-contrnum as char.
    def var v-cardreason as char.
    def var v-cardnum as char.

    def frame f-client
    v-month label "МЕСЯЦ " format ">9" colon 18 skip
    v-god label   "ГОД " format "9999" colon 18 skip
    s-cif label "КЛИЕНТ " format "x(6)" colon 18 help " Введите код клиента (F2 - поиск)" validate (can-find(first cif where cif.cif = s-cif no-lock), " Клиент с таким кодом не найден!")
    v-cifname no-label format "x(45)" colon 26
    v-contrnum label "КОНТРАКТ" format "x(50)" colon 18 help " Выберите контракт (F2 - поиск)" validate(can-find(first vccontrs where vccontrs.ctnum = trim(entry(1, v-contrnum, ' ')) and vccontrs.cif = s-cif no-lock), " Контракт не найден!") skip
    v-cardreason label "ОСНОВ.НАПРАВ.ЛК" colon 18 help "Введите основание направления лиц.карточки (F2 - справочник)"
    validate(check-cardreas(v-cardreason) = "", " Введен неверный основание направления лиц.карточки " + replace(check-cardreas(v-cardreason),'*', '') + " !") skip
    v-rem label "ПРИМЕЧАНИЕ" format "x(120)" colon 18  view-as editor MAX-CHARS 300 size 75 by 4 skip(2)
    with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

    on help of v-contrnum in frame f-client do:
        run h-contract.
        if s-contract <> 0 then do:
            find vccontrs where vccontrs.contract = s-contract no-lock no-error.
            v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
            displ v-contrnum with frame f-client.
        end.
    end.

    on help of v-cardreason in frame f-client do:
        if v-reason = "" then do:
            for each codfr where codfr.codfr = 'vccard' and codfr.code <> 'msc' no-lock:
                if v-reason <> "" then v-reason = v-reason + " |".
                v-reason = v-reason + string(codfr.code) + " " + codfr.name[1].
            end.
        end.
        v-sel = 0.
        run sel2 ("ВЫБЕРИТЕ ОСНОВАНИЕ ОФОРМЛЕНИЯ ЛИЦ.К.", v-reason, output v-sel).
        v-cardreason = trim(entry(1,(entry(v-sel,v-reason, '|')),' ')).
        displ v-cardreason with frame f-client.
    end.


    on "return" of v-rem in frame f-client do:
        apply "go" to v-rem in frame f-client.
    end.

    update v-month v-god s-cif with frame f-client.
    displ v-month v-god s-cif with frame f-client.

    find first cif where cif.cif = s-cif no-lock no-error.
    v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
    displ v-cifname with frame f-client.

    update v-contrnum with frame f-client.

    if s-contract = 0 then do:
        find first vccontrs where vccontrs.ctnum = trim(v-contrnum) and vccontrs.cif = s-cif no-lock no-error.
        if avail vccontrs then s-contract = vccontrs.contract.
    end.
    v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
    find vccontrs where vccontrs.contract = s-contract no-lock no-error.
    displ v-contrnum with frame f-client.
    if not avail vccontrs then return.
    v-cardreas_old = vccontrs.cardtype.
    v-cardmy_old = vccontrs.cardformmc.
    if p-option = 'msg' then v-cardreason = vccontrs.cardtype.

    update v-cardreason  with frame f-client.

    v-mttel = cif.tlx.
    find first sub-cod  where sub-cod.acc = s-cif and sub-cod.d-cod = "clnchf"  no-lock no-error.
    if avail sub-cod then do:
        if v-mttel = " " then v-mttel = " 2 телефона нету".
        else v-mttel = cif.tlx.
        v-rem = sub-cod.rcode + ", телефон 1 : " + cif.tel + ", телефон 2 : " + v-mttel + ".".
        displ v-rem  with frame f-client.
    end.

    if vccontrs.cttype <> "1" and vccontrs.cttype <> "3" and vccontrs.cttype <> "6" then do:
        message skip " Лицевые карточки банковского контроля не формируются для этого типа конракта!" skip(1) view-as alert-box button ok.
        return.
    end.
end.

v-dtb = date(v-month, 1, v-god).

case v-month:
    when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
    when 4 or when 6 or when 9 or when 11 then vi = 30.
    when 2 then do:
        if v-god mod 4 = 0 then vi = 29.
        else vi = 28.
    end.
end case.
v-dte = date(v-month, vi, v-god).


if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
    p-depart = get-dep(g-ofc, g-today).
    find ppoint where ppoint.depart = p-depart no-lock no-error.
    v-depname = ppoint.name.
end.
v-name = "".

/* коннект к нужному банку */
if connected ("txb") then disconnect "txb".
for each txb where txb.consolid = true  and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
    if p-option = 'rep' then run vcrep7dat (txb.bank, p-depart, 0).
    else run vcrep7dat (txb.bank, p-depart, s-contract).
    if p-bank <> "all" then v-name = txb.name.
    disconnect "txb".
end.
hide message no-pause.

if p-option = 'rep' then run vcrep7out.p ("vcrep7.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true).

if p-option = 'msg' or p-option = 'card' then do:
    find first t-docs where t-docs.clcif = s-cif and t-docs.ctnum = v-contrnum no-lock no-error. /*aigul*/
    if avail t-docs then do:
        if deci(t-docs.dolgsum_usd) < 50 and v-cardreason = '1' then do:
            message "Сумма нарушения меньше или равна 50000 долларов!" view-as alert-box title "ВНИМАНИЕ".
            return.
        end.
        else run cardnum.
    end.
    else do:
        run vcrepcif(p-depart, s-contract).
        find first t-cif where t-cif.clcif = s-cif and t-cif.ctnum = v-contrnum no-lock no-error. /*aigul*/
        if avail t-cif then do:
            if v-cardreason = '1' then do:
                message "Сумма нарушения меньше 50000 долларов!" view-as alert-box title "ВНИМАНИЕ".
                return.
            end.
            run cardnum.
        end.
    end.
    if v-cardreason <> v-cardreas_old or v-cardmy_old <> string(v-month,'99') + '.' + string(v-god,'9999') then do transaction:
        find current vccontrs exclusive-lock.
        if v-cardreason <> v-cardreas_old then vccontrs.cardtype = v-cardreason.
        if v-cardmy_old <> string(v-month,'99') + '.' + string(v-god,'9999') then vccontrs.cardformmc = string(v-month,'99') + '.' + string(v-god,'9999').
        find current vccontrs no-lock.
    end.
    if trim(v-rem) <> '' then do transaction:
        find current vccontrs exclusive-lock.
        vccontrs.info[9] = v-rem.
        find current vccontrs no-lock.
    end.
end.
/*не пропускаем ЛКБК с причиной 1, если дата больше ноябрь 2009 и сумма нарушения меньше 50 тысяч*/

if p-option = 'msg' then do:
    if v-bin = yes then do:
        find first vccontrs where vccontrs.contract = s-contract and vccontrs.cif = s-cif no-lock no-error.
        if avail vccontrs then do:
            v-cardnum = "".
            find last vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = "40" and trim(vcdocs.info[2]) = trim(v-cardreason) and vcdocs.info[1] <> "" no-lock no-error.
            if avail vcdocs then v-cardnum = trim(vcdocs.info[1]).
        end.
    end.
    else do:
        v-cardnum = "".
        find first cmp no-lock no-error.
        v-cardnum = substr(cmp.addr[3], 1, 8) + "/" + substr(cmp.addr[3], 9, 4) + fill("0", 4 - length(substr(cmp.addr[3], 9, 4))) + "/".
    end.
    run vcmsg105out(s-contract, v-cardnum, v-cardreason).
end.

if p-option = 'card' then run vccardout("clientcard.doc", v-cardnum, v-cardreason, v-rem).

pause 0.


procedure cardnum.

    def var v-str as char.
    def buffer b-vccontrs for vccontrs.

    find first vccontrs where vccontrs.contract = s-contract no-lock no-error.

    if vccontrs.cardnum = "" then do:
        def frame f-cardnum
            v-str format "x(12)" label "     Номер лицевой карточки " help " Уточните уникальную часть номера лицевой карточки" validate (length(v-str) >= 3 and length(v-str) <= 12, " Номер должен быть не меньше 3 и не больше 12 символов!")
        with centered overlay side-label row 8 title " УНИКАЛЬНАЯ ЧАСТЬ НОМЕРА КАРТОЧКИ ".

        v-str = "".
        find vcparams where vcparams.parcode = "cardnum" no-lock no-error.
        if not avail vcparams then do:
            message skip " Не найден параметр cardnum !"
            skip(1) view-as alert-box button ok title " ОШИБКА ! ".
            return.
        end.
        v-str = trim(string((vcparams.valinte + 1), '>>>>>>>>999')).

        find vcparams where vcparams.parcode = "mt105-rn" no-lock no-error.
        if length(v-str) > vcparam.valinte then v-str = substr(v-str, 1, 12).

        repeat:
            update v-str with frame f-cardnum.

            find first b-vccontrs where b-vccontrs.cardnum = v-cardnum and b-vccontrs.contract <> vccontrs.contract no-lock no-error.
            if avail b-vccontrs then message skip " Такая лицевая карточка банковского контроля уже существует!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
            else leave.
        end.

        find current vccontrs exclusive-lock.
        vccontrs.cardnum = v-cardnum.
        find current vccontrs no-lock.

        find vcparams where vcparams.parcode = "cardnum" exclusive-lock no-error.
        if not avail vcparams then do:
            message skip " Не найден параметр cardnum !"
            skip(1) view-as alert-box button ok title " ОШИБКА ! ".
            return.
        end.

        vcparams.valinte = vcparams.valinte + 1.
        find current vcparams no-lock.

        hide frame f-cardnum.
    end.
    else v-cardnum = vccontrs.cardnum.
end.
