/* vcmsg115.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        MT-115
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        23.05.2008 galina
 * CHANGES
        27.11.2008 galina - номер контракта должен соответствовать клиенту
        07.04.2011 damir- добавлены переменные bnkbin,bin,iin в temp-table t-cif,t-cif115
                          consolid  подключение к базе TXB.
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        03.05.2011.. damir - исправлены ошибки.возникшие при компиляции
        06.12.2011 damir - убрал chbin.i, добавил vcmtform.i

 */


{vc.i}
{global.i}
{comm-txb.i}

{vcmtform.i} /*переход на БИН и ИИН*/

def new shared var s-vcourbank  as char.
def new shared var v-god        as integer format "9999".
def new shared var v-month      as integer format "99".

def var v-reason as char no-undo.
def var v-sel    as integer no-undo.
def var msg-err  as char no-undo.

def new shared temp-table t-cif
    field clcif      like cif.cif
    field clname     like cif.name
    field okpo       as char format "999999999999"
    field rnn        as char format "999999999999"
    field clntype    as char
    field address    as char
    field region     as char
    field psnum      as char
    field psdate     as date
    field bankokpo   as char
    field ctexpimp   as char
    field ctnum      as char
    field ctdate     as date
    field ctsum      as char
    field ctncrc     as char
    field partner    like vcpartners.name
    field countryben as char
    field ctterm     as char
    field cardsend   like vccontrs.cardsend
    field prefix     as char
    field bnkbin     as char
    field bin        as char
    field iin        as char
    index main is primary clcif ctdate ctsum.

def new shared temp-table t-cif115
    field clcif     like cif.cif
    field clname    like cif.name
    field okpo      as char format "999999999999"
    field rnn       as char format "999999999999"
    field clntype   as char
    field address   as char
    field region    as char
    field bankokpo  as char
    field bnkbin    as char
    field bin       as char
    field iin       as char.

function check-cardreas returns logical (p-value as char).
    if p-value = '' then do:
        msg-err = " Выберите основание оформления МТ-115!".
        return false.
    end.
    if not can-find(codfr where codfr.codfr = 'vcmsg115' and codfr.code = p-value no-lock) then do:
        msg-err = "Введено неверное основание оформления МТ-115 " + p-value + " !".
        return false.
    end.
    return true.
end.

s-vcourbank = comm-txb().

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
    v-month = 12.
    v-god = v-god - 1.
end.
else v-month = v-month - 1.

def new shared var s-cif like cif.cif.
def new shared var s-contract like vccontrs.contract.
def new shared var s-contrstat as char initial 'all'.
def var v-cifname as char.
def var v-contrnum as char.
def var v-cardreason as char.
def var v-cardnum as char.

def frame f-client
    v-month label "МЕСЯЦ " format ">9" colon 10 skip
    v-god label   "ГОД " format "9999" colon 10 skip(1)
    s-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = s-cif no-lock), " Клиент с таким кодом не найден!")
    v-cifname no-label format "x(45)" colon 18
    v-contrnum label "КОНТРАКТ" format "x(50)" colon 10 help " Выберите контракт (F2 - поиск)"
    validate(can-find(first vccontrs where vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999") begins v-contrnum and vccontrs.cif = s-cif no-lock), " Контракт не найден!") skip
    v-cardreason label "ОСНОВ.НАПРАВ.ЛК" colon 18 help "Введите основание направления лиц.карточки (F2 - справочник)"
    validate(check-cardreas(v-cardreason), msg-err) skip
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
            for each codfr where codfr.codfr = 'vcmsg115' and codfr.code <> 'msc' no-lock:
                if v-reason <> "" then v-reason = v-reason + " |".
                v-reason = v-reason + string(codfr.code) + " " + codfr.name[1].
            end.
        end.
        v-sel = 0.
        run sel2 ("ВЫБЕРИТЕ ОСНОВАНИЕ ОФОРМЛЕНИЯ MT-115", v-reason, output v-sel).
        v-cardreason = trim(entry(1,(entry(v-sel,v-reason, '|')),' ')).
        /*message v-cardreason view-as alert-box.*/
        displ v-cardreason with frame f-client.
    end.
    update v-month v-god s-cif with frame f-client.

    find first cif where cif.cif = s-cif no-lock no-error.
    v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
    displ v-cifname with frame f-client.
    update v-contrnum with frame f-client.
    update  v-cardreason with frame f-client.

    if s-contract <> 0 then do:
        find vccontrs where vccontrs.contract = s-contract no-lock no-error.
        if avail vccontrs then run vcrepcif(0, s-contract).
    end.
    else run vcrepcif115(0, s-cif).

    find vcparams where vcparams.parcode = "mt115-n" no-lock no-error.

    run vcmsg115out(string(vcparams.valinte + 1), v-cardreason).

