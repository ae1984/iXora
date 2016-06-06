/* p_f_kvit1.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Печать квитанции пенсионных и прочих - ТОЛЬКО КВИТАНЦИЯ
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
        11/12/03 sasco
 * CHANGES
        15/07/2004 kanat - печать дубликатов фиксируется в chval[4]
        27/05/2005 kanat - добавил дополнительную информацию в конец дубликата
        20.10.2005 dpuchkov - добавил информацию о менеджере который выдал дубликат
        17.11.2005 dpuchkov - записываем всех без искл кто выдавал дубликатты
        24/04/2006 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
*/
{global.i}
{getfromrnn.i}

define input parameter rid as char.
/*
def var rid as char init '0x00c9f467'.
*/
def var j as decimal init 0.00.

&scoped-define rnn p_f_payment.rnn
&scoped-define tl  "КВИТАНЦИЯ"
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

define variable ckv as int.


def var sumchar as char.
def var mark as int.
def var crlf as char.
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

/* sasco : счетчик квитанций */

if p_f_payment.uid = userid ("bank") then do:
   find first p_f_payment where rowid(p_f_payment) = to-rowid(substring(rid,1,10)) no-error.
   if available p_f_payment then do:
        ckv = ?.
        ckv = integer (p_f_payment.chval[4]) no-error.
        if ckv = ? then ckv = 0.
        ckv = ckv + 1.
        p_f_payment.chval[4] = string (ckv, "zzz9").
/**/
/*create dbl.
       dbl.dt   = p_f_payment.date.
       dbl.rnn  = p_f_payment.rnn.
       dbl.sum  = p_f_payment.amt.
       dbl.dnum = p_f_payment.dnum.
       dbl.who  = g-ofc. */
/**/

   end.
end.

create dbl.
       dbl.dt   = p_f_payment.date.
       dbl.rnn  = p_f_payment.rnn.
       dbl.sum  = p_f_payment.amt.
       dbl.dnum = p_f_payment.dnum.
       dbl.who  = g-ofc.


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

run Sm-vrd.p(p_f_payment.amt, output sumchar).
sumchar = sumchar + ' тенге ' +
string((if (p_f_payment.amt - integer(p_f_payment.amt)) < 0 then
1 + (p_f_payment.amt - integer(p_f_payment.amt)) else
(p_f_payment.amt - integer(p_f_payment.amt))) * 100, "99") + ' тиын'.

if length(sumchar) > 69 then mark = R-INDEX(sumchar, " ", 69).
else mark = length(sumchar).

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
put unformatted {&p-iik} "  |        БИК|" {&p-bik} "|                   |" crlf.
put unformatted "|                 |                          |----------------|     -----------------         ----------|" crlf.

if p_f_payment.cod <> 400 then
put unformatted "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| 19 |                 KБК|" {&k} "||" crlf.
else
put unformatted "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| 19 |                 KБК| " chr(27) + 'x1' + chr(27) + 'E' +  "000000" + chr(27) + 'x0' + chr(27) + 'F' " ||" crlf.

put unformatted "| --------------- |                          ------------------     ------                    ----------|" crlf.
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
put unformatted "|                 |                                                                Пеня  |"  {&fine}   "|" crlf.
put unformatted "|                 |Отправитель денег                                                     |--------------|" crlf.
put unformatted "|                 |                                                                Всего |"  {&sumi}   "|" crlf.
put unformatted "| Кассир          |                                                                      ---------------|" crlf.
put unformatted "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf.
put unformatted "|                 |                "                   {&sum2}                                         "|" crlf.
put unformatted "---------------------------------------------------------------------------------------------------------" crlf.
put unformatted "| Банк не несет ответственность за повторное оформление документов по данной квитанции                  |" crlf.
put unformatted "| Подпись: Дубликат                                                                                     |" crlf.
put unformatted "| Фамилия и инициалы отправителя денег: __________________________________________                      |" crlf.
put unformatted "| Подпись: _______________________                 _______________________________________________      |" crlf.
put unformatted "|                                                 |                                               |     |" crlf.
put unformatted "|                                                 |   Место печати                                |     |" crlf.
put unformatted "|                                                 |                                               |     |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------+" crlf.

put unformatted rid crlf.
put unformatted crlf crlf.

end. /* rid */

put unformatted crlf crlf.

put unformatted chr(27) chr(64).
output close.

unix silent un-dos pfkvit.txt pfkvit.dos.
unix silent dos-un pfkvit.dos pfkvit.txt.

unix silent prit pfkvit.txt.
