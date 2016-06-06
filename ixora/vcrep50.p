 /* vcrep50.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по физ. лицам для НБ РК
 * RUN

 * CALLER
        vcrepp50.p
 * SCRIPT

 * INHERIT

 * MENU
        10.4.1.10
 * AUTHOR
        17.01.2006 u00600 - переделала в консолидированный отчет
 * BASES
        BANK COMM
 * CHANGES
        28.02.2006 u00600 - добавила поле наименование отправителя получателя
        05.04.2006 u00600 - изменения соглано ТЗ ї297 от 30.03.06 (Нац.Банк)
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        05.05.2008 galina - изменения в согласно Правил ОВК от 11.12.2006 на состояние 25.06.2007
        удален конект к филиалам, т.к. все платежи за пределы банка проходят через ЦО
        02/11/2009 galina -  добавила ИИН
        27/05/2010 galina - выводим кнп в файл для статистики
        02.06.2011 aigul  - вывод отчета консолидированным
        26.04.2012 aigul  - исправила вывод данных в отчет
        15.09.2012 damir  - добавил v-txbbank Т.З. №1385.

*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank   as char.
def input parameter p-depart as inte.

def new shared var s-vcourbank  as char.
def new shared var v-god        as inte format "9999".
def new shared var v-month      as inte format "99".
def new shared var v-dtb        as date format "99/99/9999".
def new shared var v-dte        as date format "99/99/9999".
def new shared var v-pay        as inte init 3.
def new shared var v-amtusd     as deci.
def new shared var v-sum        as deci.
def new shared var v-sum1       as deci.
def new shared var v-rnn        as char.
def new shared var v-fio        as char.
def new shared var v-bank       as char.

def var i           as inte.
def var v-name      as char no-undo.
def var v-txbbank   as char.

def new shared temp-table wrk-ish
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field crgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

def new shared temp-table wrk-vh
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field drgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

s-vcourbank = comm-txb().


v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

form
    skip
    " ПЕРИОД ОТЧЕТА: " skip
    v-month label "     Месяц " skip
    v-god label   "       Год " skip
    " ТИП ПЛАТЕЖА: " skip
    v-pay label "1)Исходящие 2)Входящие 3)Все" format "9"
    validate(index("123", v-pay) > 0, "Неверный тип платежа !") skip
with side-label centered row 5 title " ВВЕДИТЕ ПАРАМЕТРЫ ОТЧЕТА : " frame fparam.

update v-month v-god v-pay with frame fparam.

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
    when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then i = 31.
    when 4 or when 6 or when 9 or when 11 then i = 30.
    when 2 then do:
        if v-god mod 4 = 0 then i = 29.
        else i = 28.
    end.
end case.

v-dte = date(v-month, i, v-god).

v-name = "".

find txb where txb.consolid = true and bank = s-vcourbank no-lock no-error.

/*{r-brfilial.i &proc = "vcreppr2dat"}*/
/*run vcrep50dat1.*/

{r-brfilial.i &proc = "vcrep50-txb"}

if p-bank <> "all" then v-name = txb.name.

if avail comm.txb then v-txbbank = comm.txb.bank.
else v-txbbank = "".

hide message no-pause.

def var v-reptype as integer init 1.

if p-bank = "all" then do:
    DEF BUTTON but-htm LABEL "    Просмотр отчета    ".
    DEF BUTTON but-msg LABEL "  Файл для статистики  ".

    def frame butframe
    skip(1)
    but-htm skip
    but-msg skip(1)
    with centered row 6 title "ВЫБЕРИТЕ ВАРИАНТ ОТЧЕТА:".

    ON CHOOSE OF but-htm, but-msg do:
        case self:label :
            when "Просмотр отчета" then v-reptype = 1.
            when "Файл для статистики" then v-reptype = 2.
        end case.
    END.
    enable all with frame butframe.

    WAIT-FOR CHOOSE OF but-htm, but-msg.
    hide frame butframe no-pause.
end.

if v-reptype = 1 then
    run vcrep50out ("vcrep50.htm", (p-bank <> "all"), v-name, /*(p-depart <> 0), v-depname,*/ true,v-txbbank).
else
    run vcrep50out ("vcrep50.htm", false, "", /*false, "",*/ false,v-txbbank).

pause 0.