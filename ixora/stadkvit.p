/* stadkvit.p
 * MODULE
        Коммунальные платежы
 * DESCRIPTION
        Квитанция ст. диагностики
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
        09/10/03 sasco счетчик квитанций
        01/19/04 kanat добавил вывод в печать номеров КТС, ДВС и котнрактов при приеме таможенных платежей
        27/02/04 kanat добавил проверку commonls.visible
        09/03/04 kanat вместо логина печатается ФИО офицера в БКС
        07/04/04 kanat добавил информацию по получателю и отправителю в формирование чека
        07/06/04 kanat ФИО плательщика берется из commonpl.fioadr, а не из БД РНН
        28/06/04 kanat Для Центра недвижимости квитанции и извещения не печатаются.
        01/12/05 kanat переделал АО и ссылки на depaccnt
        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией
        16/01/06 u00568 Evgeniy - теперь БКС печатается отдельно. вызывая BKS.p
        16/01/06 u00568 Evgeniy - заодно со всеми печатками ТЗ 251 + проставил no-undo
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
        08/09/2006 u00568 Evgeniy - извещение = корешок тз 346 ДРР от 24/05/2006 во всех филиалах + удалил закомментаринное
        23/10/2006 u00568 Evgeniy - общая часть всех программ печати квитанций в comm_kvit.i
*/


define input parameter rid as char.

def var commonls_visible like commonls.visible init true no-undo.

&scoped-define rnnbn commonpl.rnnbn  format "x(12)"
&scoped-define rnn   commonpl.rnn    format "x(12)"
&scoped-define tl    if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum chr(27) 'x1' chr(27) 'E' commonpl.sum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d   commonpl.date format '99/99/99'
&scoped-define n   commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1 trim(substring(commonls.npl,1,40)) format 'x(44)'
&scoped-define vpl2 trim(substring(commonls.npl,41,40)) format 'x(44)'
&scoped-define fio str1(commonpl.fioadr) format 'x(74)'
&scoped-define kod  commonls.kod format "x(2)"
&scoped-define kbk  string(commonpl.kb,"999999")
&scoped-define kbe  commonls.kbe format "x(2)"
&scoped-define iik  commonls.iik format "999999999"
&scoped-define bik  commonls.bik format "999999999"
&scoped-define COLORD if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z) format "x(40)"
&scoped-define dockts commonpl.info[2] format 'x(85)'
&scoped-define dcomsum chr(27) 'x1' chr(27) 'E'  commonpl.comsum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define dsumall chr(27) 'x1' chr(27) 'E' (commonpl.sum + commonpl.comsum) format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'


do while rid <> "":
   {comm_kvit.i}
   /*общая часть всех программ печати квитанций*/
   /*там объявляются и вычисляются переменные v-bank-name, ltaxб, i, s_1, s_2, crlf*/

  /*find first bankl where bankl.bank = string(commonls.bikbn) no-lock no-error.*/

  if commonpl.arp <> "250904845" then do:   /*28/06/04*/
    output to cmplkvit.txt.
      put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.
      put unformatted "+----------------------------------------------------------------------------------------------------АО'TEXAKABANK'-+" crlf
                      "| ИЗВЕЩЕНИЕ-Корешок No" {&n}  "  Дата " {&d} "  " if ltax then "По КБК: " + {&kbk} else "              " "                                                      |" crlf
                      "| В "        commonls.bn format "x(58)"                       "  KБе:" {&kbe} " РНН:"  {&rnnbn}  " ИИК:" {&iik} " БИК " {&bik} " |" crlf
                      "| Плательщик: "                 {&fio}                                                 " РНН "   {&rnn} " KОд " {&kod} "    |" crlf
                      "| Вид платежа: "        {&vpl1}                                   {&vpl2}                             if commonpl.z = 1 then "            " else " Чел.-" + string(commonpl.z) format "x(12)" " |" crlf
                      "| Сумма ("   {&sum}   ") + Комиссия (" {&dcomsum} ") = к оплате (" {&dsumall}")                                    |" crlf
                      "+-------------------------------------------------------------------------------------------------------------------+" crlf.

      put unformatted rid crlf crlf crlf.
      put unformatted
      "---------------------------------------------------------------------------------------------------------" crlf
      "|                 |                                                              ------   --------------|" crlf
      "|                 |"        commonls.bn format "x(58)"                       " KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf
      "|    " {&tl} "    |                                                              ------   --------------|" crlf
      "|    No" {&n}  "  |Наименование банка: " v-bank-name format "x(50)" "               |" crlf
      "|                 |                          ------------------           -----------                   |" crlf
      "|                 |ИИК бенефициара           |  " {&iik} "     |        БИК|" {&bik} "|                   |" crlf
      "|                 |                          |----------------|     -----------------                   |" crlf
      "|                 |РНН Отправителя денег     |  "   {&rnn} "  |  KОд| " {&kod} " |       "

      if ltax then "       КБК: " + {&kbk} + "     |" else "                       |"

      crlf
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

      /* условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */
      if commonpl.comsum >= 100 then
        put unformatted
        "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
        "|                 |                "                   {&sum2}                                         "|" crlf.

      else
        put unformatted
        "|                 |                                                             Комиссия |" {&dcomsum} "|" crlf
        "|                 |                                                             Всего    |              |" crlf
        "|                 |                                                             к оплате |" {&dsumall} "|" crlf
        "|                 |                                                                      ---------------|" crlf
        "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf
        "|                 |                "                   {&sum2}                                         "|" crlf.

      put unformatted
       "|                 |"{&dockts}                                                                          "|" crlf
       "---------------------------------------------------------------------------------------------------------" crlf
       rid crlf crlf crlf.

      put unformatted rid crlf crlf crlf.
      put unformatted crlf crlf.
      put unformatted chr(27) chr(64).
      output close.
      unix silent un-dos cmplkvit.txt cmplkvit.dos.
      unix silent dos-un cmplkvit.dos cmplkvit.txt.
      unix silent prit cmplkvit.txt.
      run bks(s_1, s_2). /*Бкс*/
  end.
end.
