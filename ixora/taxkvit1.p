/* taxkvit1.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Печать налоговых квитанций - ТОЛЬКО КВИТАНЦИЙ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        11/12/03 sasco
 * CHANGES
        07/06/04 kanat - ФИО клиента берется с tax.chval[1], а не с БД РНН 
        15/07/2004 kanat печать дубликатов фиксируется в chval[4]
        28/01/2005 kanat переделал вывод КБК - 
        09/02/05 kanat Изменил обработку резидентства - раньше не работало
        27/05/2005 kanat - добавил дополнительную информацию в конец дубликата
        18/08/2005 kanat - добавил условие на удаленные квитанции
        20.10.2005 dpuchkov - добавил информацию о менеджере который выдал дубликат
        17.11.2005 dpuchkov - добавил дубликаты в отчет(попадали не все)
        17.11.2005 dpuchkov - записываем всех без искл кто выдавал дубликатты
*/

{global.i}
{get-dep.i}

define input parameter rid as char.

define buffer btax for comm.tax.
define var num as int.
define var totsum as decimal.

def var i_temp_dep as integer.
def var s_depname as char.
def var s_nknmb as char.
def var s_stadr as char.
def var s_rnn as char.
def var d_comsum as decimal.
def var d_txsum as decimal.
def var i_docnum as integer.
def var i_kbknum as integer.
def var i_comtxb as integer.
def var s_budget as character.
def var s_print as character.

&scoped-define rnk comm.tax.rnn_nk format 'x(15)'
&scoped-define rnn comm.tax.rnn 
&scoped-define tl  "КВИТАНЦИЯ" 
&scoped-define tsum chr(27) 'x1' chr(27) 'E' totsum format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define sum chr(27) 'x1' chr(27) 'E' comm.tax.sum format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define oldsum comm.tax.decval[1] format '>>>>>>9.99' 
&scoped-define cursum comm.tax.decval[2] format '>>>>>>9.99'
&scoped-define fine1 comm.tax.decval[3]  format '>>>>>>9.99'
&scoped-define fine2 comm.tax.decval[4]  format '>>>>>>9.99'
&scoped-define d   comm.tax.date format '99/99/99' 
&scoped-define n   comm.tax.dnum format '>>>>>9' '   '
&scoped-define k   comm.tax.kb   format '999999' 
/*
&scoped-define vpl budcodes.name1 format 'x(33)'
*/

/*
&scoped-define fio if comm.tax.rnn = "000000000000" then comm.tax.chval[1] else if avail comm.rnn then trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname ) + ", " + comm.rnn.street1 + ", " + comm.rnn.housen1 + "/" + comm.rnn.apartn1 else if avail comm.rnnu then trim( comm.rnnu.busname ) + ", " + comm.rnnu.street1 + ", " + comm.rnnu.housen1 + "/" + comm.rnnu.apartn1 else '' format 'x(85)'
*/

&scoped-define fio comm.tax.chval[1] format 'x(85)'

&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kazna trim(bankl.name) format "x(60)"
&scoped-define iik comm.taxnk.iik format "999999999"
&scoped-define bik comm.taxnk.bik format "999999999"
&scoped-define kod comm.taxnk.kod format "99"
&scoped-define kbe comm.taxnk.kbe format "99"
&scoped-define info comm.tax.info format 'x(96)'
&scoped-define COLORD if comm.tax.colord = 1 then " " else "Платежей - " + string(comm.tax.colord) format "x(43)"
&scoped-define res if comm.tax.resid = true then ' X ' else '   ' format 'x(3)' 
&scoped-define nres if comm.tax.resid = false then ' X ' else '   ' format 'x(3)' 

def var sumchar as char.
def var mark as int.
def var crlf as char.

def var vpl as char format "x(33)".

crlf = /*chr(13) +*/ chr(10).

output to taxkvit.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.
/*
put unformatted chr(27) '(s16.6H' chr(27) '&l8D' crlf.
*/

define variable ckv as int.

do while rid <> "":

find first btax where rowid(btax) = to-rowid(substring(rid,1,10)) no-lock no-error.

if btax.uid = userid ("bank") then do:
   for each comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
            comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and 
            comm.tax.created = btax.created and comm.tax.dnum = btax.dnum and 
            comm.tax.duid = ?:
       ckv = ?.
       ckv = integer (tax.chval[4]) no-error.
       if ckv = ? then ckv = 0.
       ckv = ckv + 1.
       tax.chval[4] = string (ckv, "zzz9").
/*create dbl.
       dbl.dt   = tax.date.
       dbl.rnn  = tax.rnn.
       dbl.sum  = tax.sum.
       dbl.dnum = tax.dnum.
       dbl.who  = g-ofc. */
   end.
end.



find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
           comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and 
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum and comm.tax.duid = ? no-lock no-error.

create dbl.
       dbl.dt   = tax.date.
       dbl.rnn  = tax.rnn.
       dbl.sum  = tax.sum.
       dbl.dnum = tax.dnum.
       dbl.who  = g-ofc. 



find first btax where rowid(btax) = rowid(comm.tax) no-lock no-error.

find first comm.rnn where comm.rnn.trn = comm.tax.rnn USE-INDEX rnn no-lock no-error.
if not avail comm.rnn then
find first comm.rnnu  where comm.rnnu.trn = comm.tax.rnn USE-INDEX rnn no-lock no-error.
find first comm.taxnk where comm.taxnk.rnn = comm.tax.rnn_nk no-lock no-error.

find first bankl where bankl.bank = string(taxnk.bik,"999999999") no-lock no-error. 

find first budcodes where code = comm.tax.kb use-index code no-lock no-error.
if avail budcodes then
vpl = budcodes.name.
else
vpl = "".

put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
put unformatted "|                 |                                                                                                 |" crlf.
put unformatted "|                 |"        trim (comm.taxnk.name) format 'x(51)' "  РНН " {&rnk}         "                         |" crlf.
put unformatted "|    " {&tl} "    |                                                                                                 |" crlf.
put unformatted "|    No" {&n}  "  |Наименование банка: " {&kazna}                                                  "                 |" crlf.
put unformatted "|                 |                                                                                    +---+        |" crlf.
put unformatted "|                 |ИИК бенефициара               " {&iik} "              БИК " {&bik} "      Резидент РК |" {&res} "|        |" crlf.
put unformatted "|                 |                                                                                    +---+        |" crlf.
put unformatted "|                 |РНН Отправителя денег        "   {&rnn} "                             Нерезидент РК |" {&nres} "|        |" crlf.
put unformatted "| --------------- |                                                                                    +---+        |" crlf.
put unformatted "||АО 'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                 " |" crlf.
put unformatted "||Приходная касса||                                                                                                 |" crlf.
put unformatted "||Кассир No      ||Вид налогового режима   -----------                         -----------                 ---------|" crlf.
put unformatted "||Дата " {&d} "  ||                Патент |           | упрощенная декларация |           | Общеуст.режим |         |" crlf.
put unformatted "| --------------- |-------------------------------------------------------------------------------------------------|" crlf.
put unformatted "|                 |                                 |      | Недоимка | Платежи  |          |          |            |" crlf.
put unformatted "|                 |    Наименование платежа         | КБК  | прошлых  | текущего |   Штраф  |   Пеня   |    ИТОГО   |" crlf.
put unformatted "|                 |                                 |      |   лет    |  года    |          |          |            |" crlf.
put unformatted "|                 |---------------------------------+------+----------+----------+----------+----------+------------|" crlf.
put unformatted "|                 |" {&vpl}                      "|" {&k} "|" {&oldsum} "|" {&cursum} "|" {&fine1} "|" {&fine2} "|" {&sum} "|" crlf.

totsum = comm.tax.sum.

do num = 2 to 5:
find next comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
          comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and 
          comm.tax.created = btax.created and comm.tax.dnum = btax.dnum and 
          comm.tax.duid = ? no-lock no-error.
if avail comm.tax then do:
find first budcodes where code = comm.tax.kb use-index code no-lock no-error.

put unformatted "|                 |" {&vpl}                      "|" {&k} "|" {&oldsum} "|" {&cursum} "|" {&fine1} "|" {&fine2} "|" {&sum} "|" crlf.

totsum = totsum + comm.tax.sum.
end.
end.

find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
           comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and 
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum and comm.tax.duid = ? no-lock no-error.

put unformatted "|                 |---------------------------------+------+----------+----------+----------+----------+------------|" crlf.

if trim (comm.tax.info) <> "" or comm.tax.colord > 1 then
do:
if trim (comm.tax.info) <> "" then
put unformatted "|                 |"        {&info}                                                                               " |" crlf.
if comm.tax.colord > 1 then
put unformatted "|                 |"        {&COLORD}                        "                                                      |" crlf.
put unformatted "|                 |-------------------------------------------------------------------------------------------------|" crlf.
end.

run Sm-vrd.p(totsum, output sumchar).
sumchar = sumchar + ' тенге ' +
string((if (totsum - integer(totsum)) < 0 then 
1 + (totsum - integer(totsum)) else
(totsum - integer(totsum))) * 100, "99") + ' тиын'.

if length(sumchar) > 69 then mark = R-INDEX(sumchar, " ", 69).
else mark = length(sumchar).

put unformatted "|                 |                                                                             ВСЕГО  |"   {&tsum} "|" crlf.
put unformatted "|  Кассир         |Отправитель денег                                                                    ------------|" crlf.
put unformatted "|                 |                                                                                                 |" crlf.
put unformatted "|                 |Сумма прописью: "                   {&sum1}                                   "            |" crlf.
put unformatted "|                 |                "                   {&sum2}                                   "            |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.  


put unformatted "| Банк не несет ответственность за повторное оформление документов по данной квитанции                              |" crlf.
put unformatted "| Подпись: Дубликат                                                                                                 |" crlf.
put unformatted "| Подпись отправителя денег: _________________________                                                              |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.

find first rnnu where rnnu.trn = tax.rnn no-lock no-error.
if avail rnnu then do: 
put unformatted "| Фамилия и                                         +-----+   Фамилия и                                             |" crlf.
put unformatted "| инициалы руководителя: ______________________     | М.П.|   инициалы главного бухгалтера: ______________________  |" crlf.
put unformatted "| Подпись: _______________________                  +-----+   Подпись: _______________________                      |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
end.
else do:
put unformatted "| Фамилия и                                                   Фамилия и                                             |" crlf.
put unformatted "| инициалы руководителя: ______________________               инициалы главного бухгалтера: _______________________ |" crlf.
put unformatted "| Подпись: _______________________                            Подпись: _______________________                      |" crlf.
put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
end.

put unformatted rid crlf.
put unformatted crlf crlf.
rid = substring(rid, 11).
end. /* rid */

put unformatted chr(27) chr(64).

 
output close.

unix silent un-dos taxkvit.txt taxkvit.dos.
unix silent dos-un taxkvit.dos taxkvit.txt.

unix silent prit taxkvit.txt.   


/*
unix silent rm taxkvit.dos.
unix silent rm taxkvit.txt.
*/



