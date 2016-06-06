/* oterkvit.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Формирование и печать квитанции по прочим платежам для клиента
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
        22/04/04 kanat
 * CHANGES
        27/04/04 kanat - исправил формирование выходного файла для вывода на печать.

        24/01/05 kanat - переделал ссылку на depaccnt
        06/04/06 u00568 Evgeniy - закоментил печать БКС - пусть печатает из единой bks.p (по причине  ТЗ 251 от 21/02/2006 - сделать в БКС более заметной сумму комиссии банка)
                        + проставил no-undo
        26/04/06 u00568 Evgeniy  - убрал то, что раньше закоментировал. потому, что грепится лишнее... мешает
        23/10/2006 u00568 Evgeniy - общая часть всех программ печати квитанций в comm_kvit.i
*/

/*
commonpl.info[2] - счет получателя.
commonpl.info[3] - банк получателя.
commonpl.accnt   - лицевой счет.
commonpl.fioadr  - адрес и ФИО отправителя.
commonpl.info[4] - наименование бенефициара.
*/


define input parameter rid as char no-undo.

def var commonls_visible like commonls.visible init true no-undo.

&scoped-define rnnbn  commonpl.rnnbn  format "x(12)"
&scoped-define rnn    commonpl.rnn    format "x(12)"
&scoped-define tl     if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum    chr(27) 'x1' chr(27) 'E' commonpl.sum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d      commonpl.date format '99/99/99'
&scoped-define n      commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1   trim(substring(commonpl.npl,1,40)) format 'x(61)'
&scoped-define vpl2   trim(substring(commonpl.npl,41,40)) format 'x(61)'
&scoped-define fio    commonpl.fioadr format "x(74)"
&scoped-define sum1   SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2   SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kod    commonls.kod format "x(2)"
&scoped-define kbk    string(commonpl.kb,"999999")
&scoped-define kbe    commonls.kbe format "x(2)"
&scoped-define iik    integer(commonpl.info[2]) format "999999999"
&scoped-define bik    integer(commonpl.info[3]) format "999999999"
&scoped-define COLORD if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z) format "x(44)"
&scoped-define dockts string(commonpl.diskont) format 'x(56)'


do while rid <> "":
   {comm_kvit.i}
   /*общая часть всех программ печати квитанций*/
   /*там объявляются и вычисляются переменные v-bank-name, ltaxб, i, s_1, s_2, crlf*/

  output to value("otrkvt.txt").
  put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.

  find first bankl where bankl.bank = trim(commonpl.info[3]) no-lock no-error.
  if avail bankl then
    v-bank-name = bankl.name.
  else
    v-bank-name = "".


  put unformatted
    "---------------------------------------------------------------------------------------------------------" crlf
    "|                 |                                                              ------   --------------|" crlf
    "|                 |"        substr(trim(commonpl.info[4]),1,58) format "x(58)"                       " KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf
    "|    " {&tl} "    |                                                              ------   --------------|" crlf
    "|    No" {&n}  "  |Наименование банка: " v-bank-name format "x(50)" "               |" crlf
    "|                 |                          ------------------           -----------                   |" crlf
    "|                 |ИИК бенефициара           |  " {&iik} "     |        БИК|" {&bik} "|                   |" crlf
    "|                 |                          |----------------|     -----------------                   |" crlf
    "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| " {&kod} " |       "

    if ltax then "       КБК: " + {&kbk} + "     |" else "                       |"

    crlf
    "| --------------- |                          ------------------     ------                              |" crlf
    "||АО 'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                                                 "|" crlf
    "||Приходная касса||-------------------------------------------------------------------------------------|" crlf
    "||Кассир No      ||                                                             |        |              |" crlf
    "||Дата " {&d} "  ||        Вид платежа                                          |  Дата  |    Сумма     |" crlf
    "||Сумма          ||                                                             |        |              |" crlf
    "||"   {&sum}   " ||-------------------------------------------------------------+--------+--------------|" crlf
    "| --------------- |"        {&vpl1}                                            "|" {&d} "|"   {&sum}   "|" crlf
    "|                 |-------------------------------------------------------------+--------+--------------|" crlf
    "|                 |"        {&vpl2}                                            "|        |              |" crlf
    "|                 |-------------------------------------------------------------------------------------|" crlf
    "|                 |"        {&COLORD}                         "                                         |" crlf
    "|                 |Отправитель денег                                                     +--------------|" crlf
    "|                 |                                                                Всего |"   {&sum}   "|" crlf
    "| Кассир          |                                                                      +--------------|" crlf
    "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
    "|                 |                "                   {&sum2}                                         "|" crlf.
  put unformatted
    "|                 |Лицевой счет/Номер договора: "{&dockts}                                             "|" crlf
    "---------------------------------------------------------------------------------------------------------" crlf
    rid crlf crlf crlf crlf crlf chr(27) chr(64).
  output close.
  unix silent un-dos otrkvt.txt otrkvt.dos.
  unix silent dos-un otrkvt.dos otrkvt.txt.
  unix silent prit otrkvt.txt.
  run bks(s_1, s_2). /*печать БКС*/
end.
