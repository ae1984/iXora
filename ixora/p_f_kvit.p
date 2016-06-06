/* p_f_kvit.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Печать квитанции пенсионных и прочих
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09/10/03 sasco Счетчик квитанций
        15/10/03 sasco Не печатаются квитанции по прочим платежам, только по пенсионным
        05/01/04 kanat Добавил вывод дополнительной информации в печать квитанции и извещение
        01/31/04 kanat Переделал формирование квитанций и извещений - добавил отправителя денег и место печати
        29/03/05 kanat Добавил вывод количества плательщиков
        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией
        09.12.2005 u00121 - добавил поля для Акта изъятия денег по юридическим лицам согласно ТЗ ї 137 от 29/08/2005 г.
        12/12/2005 u00121 - если поле p_f_payment.act_withdrawal не заполненно, то не выводить строку "по акту изъятия денег N ...."
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн + no-undo
        02/11/06 u00568 Evgeniy - устарел
*/
message "программа p_f_kvit.p считается устаревшей.~n обратитесь в ДИТ " VIEW-AS ALERT-BOX TITLE "Внимание".
return.

{getfromrnn.i}

define input parameter rid as char.

/*
def var rid as char init '0x00c9f467'.
*/
/*def var j as decimal init 0.00.*/
/*def var aktnk as char .*/


&scoped-define rnn p_f_payment.rnn

&scoped-define act  if length(p_f_payment.act_withdrawal) <> 0 then "по акту изъятия денег N " + p_f_payment.act_withdrawal + " от инспектора НК " + p_f_payment.inspektor_NK + fill(" ",(62 - length("по акту изъятия денег N " + p_f_payment.act_withdrawal + " от инспектора НК " + p_f_payment.inspektor_NK))) else fill(" ",62) /*u00121*/

&scoped-define tl   if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum  if p_f_payment.cod = 200  then '              ' else chr(27) + 'x1' + chr(27) + 'E' + string(p_f_payment.amt,'>>>>>>>>>>9.99') + chr(27) + 'x0' + chr(27) + 'F'
&scoped-define sumi chr(27) 'x1' chr(27) 'E' p_f_payment.amt format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define fine if p_f_payment.cod <> 200 then '              ' else chr(27) + 'x1' + chr(27) + 'E' + string(p_f_payment.amt,'>>>>>>>>>>9.99') + chr(27) + 'x0' + chr(27) + 'F'
&scoped-define d   p_f_payment.date format '99/99/99'
&scoped-define n   p_f_payment.dnum format '>>>>>>9' '   '
&scoped-define k   if p_f_payment.cod = 200 then chr(27) + 'x1' + chr(27) + 'E' + ' 000019 ' + chr(27) + 'x0' + chr(27) + 'F' else if p_f_payment.cod = 300 then chr(27) + 'x1' + chr(27) + 'E' + ' 000013 ' + chr(27) + 'x0' + chr(27) + 'F' else chr(27) + 'x1' + chr(27) + 'E' + ' 000010 ' + chr(27) + 'x0' + chr(27) + 'F'

&scoped-define vpl if avail budcodes then budcodes.name1 else ' ' format 'x(44)'
&scoped-define fio getfioadr() format 'x(74)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define rnk  p_f_payment.distr format 'x(12)'
&scoped-define p-name  p_f_list.name format 'x(58)'
&scoped-define p-iik   p_f_list.acnt format 'x(12)'
&scoped-define p-bik   p_f_list.bic format 'x(9)'
&scoped-define p-b-name if avail bankl then bankl.name else ' ' format 'x(65)'
&scoped-define kbe if p_f_list.rnn = '600700161857' then '11' else '15' format 'x(2)'

&scoped-define s-quant string(p_f_payment.qty) format 'x(10)'

&scoped-define dcomsum chr(27) 'x1' chr(27) 'E'  p_f_payment.comiss format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define dsumall chr(27) 'x1' chr(27) 'E' (p_f_payment.amt + p_f_payment.comiss) format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'


define variable ckv as int no-undo.

/* kanat - параметры Государственного центра по выплате пенсий */
define variable v-gcvp-rnn as char init "600400073391" no-undo.
define variable v-gcvp-iik as char init "413609816" no-undo.
define variable v-gcvp-bik as char init "190501109" no-undo.

define variable v-resident as char no-undo.


def var i as int no-undo.
def var sumchar as char no-undo.
def var mark as int no-undo.
def var crlf as char no-undo.
crlf = /*chr(13) +*/ chr(10).

output to pfkvit.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.
/*
put unformatted chr(27) '(s16.6H' chr(27) '&l8D' crlf.
*/

do while rid <> "":

find first p_f_payment where rowid(p_f_payment) = to-rowid(substring(rid,1,10)) no-lock no-error.
if not avail p_f_payment then do:
   rid = substring(rid, 11).
   next.
end.


if p_f_payment.cod = 400 then do:
   rid = substring(rid, 11).
   next.
end.


if p_f_payment.intval[1] = 1 then v-resident = "Резидент: Yes".
if p_f_payment.intval[1] = 2 then v-resident = "Резидент: No ".

/* sasco : счетчик квитанций */
if p_f_payment.uid = userid ("bank") then do:
   find first p_f_payment where rowid(p_f_payment) = to-rowid(substring(rid,1,10)) no-error.
   if available p_f_payment then do:
        ckv = ?.
        ckv = integer (p_f_payment.chval[5]) no-error.
        if ckv = ? then ckv = 0.
        ckv = ckv + 1.
        p_f_payment.chval[5] = string (ckv, "zzz9").
   end.
end.

find first p_f_payment where rowid(p_f_payment) = to-rowid(substring(rid,1,10)) no-lock no-error.
rid = substring(rid, 11).

find first rnn where rnn.trn = p_f_payment.rnn USE-INDEX rnn no-lock no-error.
if not avail rnn then
find first rnnu where rnnu.trn = p_f_payment.rnn USE-INDEX rnn no-lock no-error.

if p_f_payment.cod <> 300 then
find first budcodes where code = 10 use-index code no-lock no-error.
else
if p_f_payment.cod <> 400 then
find first budcodes where code = 20 use-index code no-lock no-error.

find first p_f_list where p_f_list.rnn = p_f_payment.distr no-lock no-error.
find first bankl where bankl.bank = p_f_list.bic no-lock no-error.

run Sm-vrd(p_f_payment.amt, output sumchar).
sumchar = sumchar + ' тенге ' +
string((if (p_f_payment.amt - integer(p_f_payment.amt)) < 0 then
1 + (p_f_payment.amt - integer(p_f_payment.amt)) else
(p_f_payment.amt - integer(p_f_payment.amt))) * 100, "99") + ' тиын'.

if length(sumchar) > 69 then mark = R-INDEX(sumchar, " ", 69).
else mark = length(sumchar).

do i = 1 to 2:
put unformatted "---------------------------------------------------------------------------------------------------------" crlf.
put unformatted "|                 |                                                              ------   --------------|" crlf.
put unformatted "|                 |".
put unformatted  {&p-name} .
put unformatted " KБе| " {&kbe} " |РНН|".
put unformatted  {&rnk} "||" crlf.
put unformatted "|    " {&tl} "    |                                                              ------   --------------|" crlf.
put unformatted "|  No" {&n} "   |Наименование банка: " {&p-b-name} "|" crlf.
put unformatted "|                 |                          ------------------           -----------                   |" crlf.
put unformatted "|                 |ИИК бенефициара           |  ".

if p_f_payment.intval[1] = 1 or p_f_payment.intval[1] = 2 then
put unformatted {&p-iik} "  |        БИК|" {&p-bik} "| " v-resident "     |" crlf.
else
put unformatted {&p-iik} "  |        БИК|" {&p-bik} "|                   |" crlf.

put unformatted "|                 |                          |----------------|     -----------------         ----------|" crlf.

if p_f_payment.cod <> 400 then
put unformatted "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| 19 |                 KНП|" {&k} "||" crlf.
else
put unformatted "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| 19 |                 KНП| " chr(27) + 'x1' + chr(27) + 'E' +  "000000" + chr(27) + 'x0' + chr(27) + 'F' " ||" crlf.
put unformatted "|                 |                          ------------------     ------                    ----------|" crlf.
put unformatted "|                 |Банк посредник Государственный центр по выплате пенсий РНН: " v-gcvp-rnn format "x(12)" "             |" crlf.
put unformatted "|                 |Главный Алматинский филиал Национального Банка Республики Казахстан БИК: "           v-gcvp-bik format "x(9)"  "   |" crlf.
put unformatted "|                 |ИИК: " v-gcvp-iik "                                                                       |" crlf.
put unformatted "| --------------- |                                                                                     |" crlf.
put unformatted "||АО 'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                                                 "|" crlf.
put unformatted "||Приходная касса||-------------------------------------------------------------------------------------|" crlf.
put unformatted "||Кассир No      ||                                            |Недоимка|Платежи|        |              |" crlf.
put unformatted "||Дата " {&d} "  ||        Вид платежа                         |прошлых |текуще-|  Дата  |    Сумма     |" crlf.
put unformatted "||Сумма          ||                                            |  лет   |го года|        |              |" crlf.
put unformatted "||"   {&sumi}  " ||--------------------------------------------+--------+-------+--------+--------------|" crlf.

if p_f_payment.cod <> 400 then
put unformatted "| --------------- |"        {&vpl}                            "|        |       |" {&d} "|"   {&sum}   "|" crlf.
else
put unformatted "| --------------- | Прочие                                     |        |       |" {&d} "|"   {&sum}   "|" crlf.

put unformatted "|                 |--------------------------------------------+--------+-------+--------+--------------|" crlf.
put unformatted "|                 |                                            |        |       |        |              |" crlf.
put unformatted "|                 |----------------------------------------------------------------------+--------------|" crlf.
put unformatted "|                 |" {&act}                                                     "  Пеня  |"  {&fine}   "|" crlf.
put unformatted "|                 |Отправитель денег                                                     |--------------|" crlf.
put unformatted "|                 |                                                                Всего |"  {&sumi}   "|" crlf.
put unformatted "| Кассир          |Количество плательщиков: " {&s-quant} "                                   ---------------|" crlf.



/*        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */
if p_f_payment.comiss >= 100 then
put unformatted "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
                "|                 |                "                   {&sum2}                                         "|" crlf.

else
put unformatted "|                 |                                                             Комиссия |" {&dcomsum} "|" crlf
                "|                 |                                                             Всего    |              |" crlf
                "|                 |                                                             к оплате |" {&dsumall} "|" crlf
                "|                 |                                                                      ---------------|" crlf
                "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
                "|                 |                "                   {&sum2}                                         "|" crlf.
/*        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */


put unformatted "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf.
put unformatted "|                 |                "                   {&sum2}                                         "|" crlf.
put unformatted "---------------------------------------------------------------------------------------------------------" crlf.
put unformatted "| Фамилия и инициалы отправителя денег: __________________________________________                      |" crlf.
put unformatted "| Подпись: _______________________                 _______________________________________________      |" crlf.
put unformatted "|                                                 |                                               |     |" crlf.
put unformatted "|                                                 |   Место печати                                |     |" crlf.
put unformatted "|                                                 |                                               |     |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------+" crlf.

put unformatted rid crlf.
put unformatted crlf crlf.
end.
put unformatted crlf crlf.
end.

put unformatted chr(27) chr(64).
output close.

unix silent un-dos pfkvit.txt pfkvit.dos.
unix silent dos-un pfkvit.dos pfkvit.txt.

unix silent prit pfkvit.txt.
