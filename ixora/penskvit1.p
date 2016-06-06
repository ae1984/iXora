/* penskvit1.p
 * MODULE
        Социальные платежи
 * DESCRIPTION
        Социальны платежи (выдача дубликатов)
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
        28/02/05 kanat
 * CHANGES
        27/05/2005 kanat - добавил дополнительную информацию в конец дубликата
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн + no-undo
*/

{global.i}
{get-dep.i}
{comm-txb.i}
{getfromrnn.i}

define var seltxb as int no-undo.
seltxb = comm-cod().

define input parameter rid as char.

/*def var i_temp_dep as integer.
def var s_depname as char.
def var s_nknmb as char.
def var s_stadr as char.
def var s_rnn as char.
def var s_print as char.*/

def var i as int no-undo.
def var sumchar as char no-undo.
def var mark as int no-undo.
def var crlf as char no-undo.
def var ltax as logic init false no-undo.
def var v-ofcname as char no-undo.
def var ckv as int no-undo.

&scoped-define rnnbn commonpl.rnnbn  format "x(12)"
&scoped-define rnn   commonpl.rnn    format "x(12)"
&scoped-define tl    if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum chr(27) 'x1' chr(27) 'E' commonpl.sum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d   commonpl.date format '99/99/99'
&scoped-define n   commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1 trim(substring(commonls.npl,1,40)) format 'x(44)'
&scoped-define vpl2 (trim(substring(commonls.npl,41,40)) + (" за " + string(commonpl.typegrp,"99") + "." + string(commonpl.counter,"9999") + " г.")) format 'x(44)'

&scoped-define fio if avail rnn or avail rnnu then getfioadr() else str1(commonpl.fioadr) format 'x(74)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'

&scoped-define kod  commonls.kod format "x(2)"
&scoped-define kbe  commonls.kbe format "x(2)"

&scoped-define iik  commonls.iik format "999999999"
&scoped-define bik  commonls.bik format "999999999"

&scoped-define knp  commonls.knp format "x(3)"

&scoped-define COLORD if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z) format "x(40)"

/*
&scoped-define dockts (" За " + string(commonpl.typegrp) + "." + string(commonpl.counter) + " г.")  format "x(85)"
*/

crlf = /*chr(13) +*/ chr(10).

output to value("pmpkvt.txt").
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.



do while rid <> "":


     find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
     /* sasco : счетчик квитанций */
     if commonpl.uid = userid ("bank") then do:
       find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-error.
       if available commonpl then do:
          ckv = ?.
          ckv = integer (commonpl.chval[5]) no-error.
          if ckv = ? then ckv = 0.
          ckv = ckv + 1.
          commonpl.chval[5] = string (ckv, "zzz9").
       end.
     end.

     find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
     rid = substring(rid, 11).

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
                               commonls.grp = commonpl.grp and commonls.visible = no no-lock no-error.
     find first bankl where bankl.bank = string(commonls.bikbn) USE-INDEX bank no-lock no-error.


do i = 1 to 2:
put unformatted
 "---------------------------------------------------------------------------------------------------------" crlf
 "|                 |                                                              ------   --------------|" crlf
 "|                 |"        commonls.bn format "x(58)"                       " KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf
 "|    " {&tl} "    |                                                              ------   --------------|" crlf
 "|    No" {&n}  "  |Наименование банка: " bankl.name format "x(50)" "               |" crlf
 "|                 |                          ------------------           -----------                   |" crlf
 "|                 |ИИК бенефициара           |  " {&iik} "     |        БИК|" {&bik} "|                   |" crlf
 "|                 |                          |----------------|     -----------------                   |" crlf
 "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| " {&kod} " |              КНП: "  {&knp}  "        |" crlf
 "| --------------- |                          ------------------     ------                              |" crlf
 "|| АО'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                                                 "|" crlf
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
 "| Кассир          |                                                                      ---------------|" crlf.

put unformatted
 "|                 |Банк не несет ответственность за повторное оформление документов по данной квитанции |" crlf
 "|                 |Подпись: Дубликат                                                                    |" crlf
 "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
 "|                 |                "                   {&sum2}                                         "|" crlf
 "---------------------------------------------------------------------------------------------------------" crlf
 rid crlf crlf crlf.
end. /* for */
end.
  /* -------------------------------------------------------------------------------------------------------------------------------- */
put unformatted chr(27) chr(64).
output close.

unix silent un-dos pmpkvt.txt pmpkvt.dos.
unix silent dos-un pmpkvt.dos pmpkvt.txt.
unix silent prit pmpkvt.txt.
