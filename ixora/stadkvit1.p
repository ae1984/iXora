/* stadkvit1.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Квитанция ст. диагностики - ТОЛЬКО КВИТАНЦИЯ
        печать дубликатов квитанций
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
        27/02/04 kanat добавил проверку commonls.visible
        07/06/04 kanat - ФИО клиента берется с commonpl.fioadr, а не с БД РНН
        15/07/2004 kanat печать дубликатов фиксируется в chval[4]
        27/05/2005 kanat - добавил дополнительную информацию в конец дубликата
        20.10.2005 dpuchkov - добавил информацию о менеджере который выдал дубликат
        17.11.2005 dpuchkov - записываем всех без искл кто выдавал дубликатты
        28.04.2006 u00568 Evgeniy - сверка онлайн и офлайн немного причесал код,
                   оказадось что в офлайне соответствующие пункты заблокированы.


*/

{global.i}
{get-dep.i}
{comm-txb.i}

define var seltxb as int.
seltxb = comm-cod().

define input parameter rid as char.

/*def var i_temp_dep as integer.
def var s_depname as char.
def var s_nknmb as char.
def var s_stadr as char.
def var s_rnn as char.
def var s_print as char.*/

&scoped-define rnnbn commonpl.rnnbn  format "x(12)"
&scoped-define rnn   commonpl.rnn    format "x(12)"
&scoped-define tl  "КВИТАНЦИЯ"
&scoped-define sum chr(27) 'x1' chr(27) 'E' commonpl.sum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d   commonpl.date format '99/99/99'
&scoped-define n   commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1 trim(substring(commonls.npl,1,40)) format 'x(44)'
&scoped-define vpl2 trim(substring(commonls.npl,41,40)) format 'x(44)'
&scoped-define fio commonpl.fioadr format 'x(74)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kod  commonls.kod format "x(2)"
&scoped-define kbk  string(commonpl.kb,"999999")
&scoped-define kbe  commonls.kbe format "x(2)"
&scoped-define iik  commonls.iik format "999999999"
&scoped-define bik  commonls.bik format "999999999"
&scoped-define COLORD if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z) format "x(40)"

def var sumchar as char.
def var mark as int.
def var crlf as char.
def var ltax as logic init false.
def var ckv as int.


crlf = /*chr(13) +*/ chr(10).


output to cmplkvit.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.

do while rid <> "":

     find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.

     if not available commonpl then do:
        rid = substring(rid, 11).
        next.
     end.

     if commonpl.uid = userid ("bank") then do:
        do transaction:
           find current commonpl exclusive-lock no-error.
           ckv = ?.
           ckv = integer (commonpl.chval[4]) no-error.
           if ckv = ? then ckv = 0.
           ckv = ckv + 1.
           commonpl.chval[4] = string (ckv, "zzz9").
        end. /*transaction*/
        find current commonpl no-lock no-error.
     end.

     rid = substring(rid, 11).

do transaction:
create dbl.
       dbl.dt   = commonpl.date.
       dbl.rnn  = commonpl.rnn.
       dbl.sum  = commonpl.sum.
       dbl.dnum = commonpl.dnum.
       dbl.who  = g-ofc.
end. /*transaction */

     if commonpl.kb > 0 then ltax = true.

     find first rnn where rnn.trn = commonpl.rnn USE-INDEX rnn no-lock no-error.

     if not avail rnn then
          find first rnnu where rnnu.trn = commonpl.rnn USE-INDEX rnn no-lock no-error.

     run Sm-vrd(commonpl.sum, output sumchar).

     sumchar = sumchar + ' тенге ' + string((
               if (commonpl.sum - integer(commonpl.sum)) < 0 then 1 + (commonpl.sum - integer(commonpl.sum))
                                                             else (commonpl.sum - integer(commonpl.sum))) * 100,
                                                                    "99") + ' тиын'.

     if length(sumchar) > 69 then mark = R-INDEX(sumchar, " ", 69).
                             else mark = length(sumchar).

     find first commonls where commonls.txb = seltxb and commonls.type = commonpl.type and
                               commonls.grp = commonpl.grp and commonls.visible = yes no-lock no-error.
     find first bankl where bankl.bank = string(commonls.bikbn) USE-INDEX bank no-lock no-error.


put unformatted
 "---------------------------------------------------------------------------------------------------------" crlf
 "|                 |                                                              ------   --------------|" crlf
 "|                 |"        commonls.bn format "x(58)"                       " KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf
 "|    " {&tl} "    |                                                              ------   --------------|" crlf
 "|    No" {&n}  "  |Наименование банка: " bankl.name format "x(50)" "               |" crlf
 "|                 |                          ------------------           -----------                   |" crlf
 "|                 |ИИК бенефициара           |  " {&iik} "     |        БИК|" {&bik} "|                   |" crlf
 "|                 |                          |----------------|     -----------------                   |" crlf
 "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| " {&kod} " |       "

 if ltax then "       КБК: " + {&kbk} + "     |" else "                       |"

 crlf
 "| --------------- |                          ------------------     ------                              |" crlf
 "||АО 'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                                                 "|" crlf
 "||Приходная касса||-------------------------------------------------------------------------------------|" crlf
 "||Кассир No      ||                                            |Недоимка|Платежи|        |              |" crlf
 "||Дата " {&d} "  ||        Вид платежа                         |прошлых |текуще-|  Дата  |    Сумма     |" crlf
 "||Сумма          ||                                            |  лет   |го года|        |              |" crlf
 "||"   {&sum}   " ||--------------------------------------------+--------+-------+--------+--------------|" crlf
 "| --------------- |"        {&vpl1}                           "|        |       |" {&d} "|"   {&sum}   "|" crlf
 "|                 |--------------------------------------------+--------+-------+--------+--------------|" crlf
 "|                 |"        {&vpl2}                           "|        |       |        |              |" crlf
 "|                 |----------------------------------------------------------------------+--------------|" crlf
 "|                 |"        {&COLORD}                         "                        Пеня  |              |" crlf
 "|                 |Отправитель денег                                                     |--------------|" crlf
 "|                 |                                                                Всего |"   {&sum}   "|" crlf
 "| Кассир          |                                                                      ---------------|" crlf
 "|                 |Банк не несет ответственность за повторное оформление документов по данной квитанции |" crlf
 "|                 |Подпись: Дубликат                                                                    |" crlf
 "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
 "|                 |                "                   {&sum2}                                         "|" crlf
 "---------------------------------------------------------------------------------------------------------" crlf
 rid crlf crlf crlf.
 
end. /* rid */

put unformatted chr(27) chr(64).
output close.

unix silent un-dos cmplkvit.txt cmplkvit.dos.
unix silent dos-un cmplkvit.dos cmplkvit.txt.
unix silent prit cmplkvit.txt.
