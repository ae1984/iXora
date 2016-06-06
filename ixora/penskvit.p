/* penskvit.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Пенсионные платежи
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
        13/01/05 kanat
 * CHANGES
        19/01/05 kanat - вывод КНП в квитанции
        24/01/05 kanat - добавил обязательный вывод месяца и года
        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией
        09.12.2005 u00121 - добавил поля для Акта изъятия денег по юридическим лицам согласно ТЗ ї 137 от 29/08/2005 г., сохранено в commonpl.info[2]
        06/04/06 u00568 Evgeniy - закоментил печать БКС - пусть печатает из единой bks.p
                                  (по причине  ТЗ 251 от 21/02/2006 - сделать в БКС более заметной сумму комиссии банка)
                                + проставил no-undo
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
        23/10/2006 u00568 Evgeniy - общая часть всех программ печати квитанций в comm_kvit.i
        26/10/2006 u00568 Evgeniy - немного поправил как в офлайне
*/

define input parameter rid as char.

def var commonls_visible like commonls.visible init false no-undo.

&scoped-define rnnbn commonpl.rnnbn  format "x(12)"
&scoped-define rnn   commonpl.rnn    format "x(12)"
&scoped-define tl    if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum chr(27) 'x1' chr(27) 'E' commonpl.sum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d   commonpl.date format '99/99/99'
&scoped-define n   commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1 trim(substring(commonls.npl,1,40)) format 'x(44)'
&scoped-define vpl2 (trim(substring(commonls.npl,41,40)) + (" за " + string(commonpl.typegrp,"99") + "." + string(commonpl.counter,"9999") + " г.")) format 'x(44)'
&scoped-define fio str1(commonpl.fioadr) format 'x(74)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kod  commonls.kod format "x(2)"
&scoped-define kbe  commonls.kbe format "x(2)"
&scoped-define iik  commonls.iik format "999999999"
&scoped-define bik  commonls.bik format "999999999"
&scoped-define knp  string(commonls.knp,"999")
&scoped-define COLORD if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z) format "x(40)"
&scoped-define aktnk  if length(commonpl.info[2]) < 64 then commonpl.info[2] + fill(" ",(64 - length(string(commonpl.info[2])))) else commonpl.info[2]
&scoped-define dcomsum chr(27) 'x1' chr(27) 'E'  commonpl.comsum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define dsumall chr(27) 'x1' chr(27) 'E' (commonpl.sum + commonpl.comsum) format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'

do while rid <> "":
  {comm_kvit.i}
  /*общая часть всех программ печати квитанций*/
  /*там объявляются и вычисляются переменные v-bank-name, ltaxб, i, s_1, s_2, crlf*/
  /*find first bankl where bankl.bank = string(commonls.bikbn) no-lock no-error.*/

  output to value("pmpkvt.txt").
  put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.

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
     "|                 |"{&aktnk}                                                      "Всего |"   {&sum}   "|" crlf
     "| Кассир          |                                                                      ---------------|" crlf.


    /* 13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */
    if commonpl.comsum >= 100 then
    put unformatted
     "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
     "|                 |                "                   {&sum2}                                         "|" crlf.

    else
    put unformatted
     "|                 |                                                              Комиссия|" {&dcomsum} "|" crlf
     "|                 |                                                              Всего   |              |" crlf
     "|                 |                                                              к оплате|" {&dsumall} "|" crlf
     "|                 |                                                                      ---------------|" crlf
     "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
     "|                 |                "                   {&sum2}                                         "|" crlf.
    /* 13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */


    put unformatted
     "|                 |                                                                                     |" crlf
     "---------------------------------------------------------------------------------------------------------" crlf
     rid crlf crlf crlf.
  end. /* for */
  put unformatted crlf crlf chr(27) chr(64).
  output close.
  unix silent un-dos pmpkvt.txt pmpkvt.dos.
  unix silent dos-un pmpkvt.dos pmpkvt.txt.
  unix silent prit pmpkvt.txt.
  run bks(s_1, s_2). /*БКС*/
end.
