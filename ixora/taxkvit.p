/* taxkvit.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Печать налоговых квитанций
 * RUN

 * CALLER
        taxlist
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09.10.03 sasco счетчик квитанций
        13.10.03 sasco чистка временных файлов
        09.12.03 kanat добавил в конец квитанции параметры плательщиков для Фл, ЮЛ, ЧП
        01.05.04 kanat Добавил вывод дополнительной информации в печать квитанции и извещение
        03.02.04 kanat добавил вывод КНП по квитанции
        09/03/04 kanat вместо логина печатается ФИО офицера в БКС
        07/04/04 kanat добавил информацию по получателю и отправителю в формирование чека
        25/05/04 kanat добавил проверки для г. Уральска по извещениям
        07/06/04 kanat ФИО плательщика берется из tax.chval[1], а не из БД РНН
        29/11/04 kanat Добавил условие на удаленные квитанции
        01/12/05 kanat переделал АО и ссылки на depaccnt
        09/02/05 kanat Изменил обработку резидентства - раньше не работало
        13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией
        06/04/2006 u00568 Evgeniy - закоментил печать БКС - пусть печатает из единой bks.p
                                  (по причине  ТЗ 251 от 21/02/2006 - сделать в БКС более заметной сумму комиссии банка)
                                + проставил no-undo
        26/04/2006 u00568 Evgeniy - убрал старые закомментированные куски, добавил комментарии
                                  закоментил 2 "find first" - оптимизация по читебельности и скорости
        25/08/2006 u00568 Evgeniy - печать БКС - выборка ещё и по кассиру
                                  + не печатать извещение по акту изъятия тз 345
                                  + извещение = корешок тз 346 ДРР от 24/05/2006
                                  + оптимизация
        28/08/2006 u00568 Evgeniy - fioadr1  в БКС
        08/09/2006 u00568 Evgeniy - был случай когда комиссия при печати проставилась нулевая.
        13/09/2006 u00568 Evgeniy - ФИО печатается из платежа а не из РНН, и 2 строчки для поля "дополнительно"
        09/11/2006 u00568 Evgeniy - был случай когда комиссия при печати проставилась нулевая. 2
                                  + оптимизация по читаемости кода
        10/11/2006 u00568 Evgeniy - исправил свой баг
*/

{comm-txb.i}
{global.i}
{get-dep.i}
{getfromrnn.i}

define input parameter rid as char.

define buffer bta_x for tax.
define var num as int no-undo.
define var totsum as decimal no-undo.
define var s_budget as character no-undo.
define var tl_temp as char no-undo.

define var seltxb as integer no-undo.
seltxb = comm-cod().


&scoped-define rnk bta_x.rnn_nk format 'x(12)'
&scoped-define rnn bta_x.rnn
&scoped-define tl  if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define tsum chr(27) 'x1' chr(27) 'E' totsum format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define sum chr(27) 'x1' chr(27) 'E' tax.sum format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define oldsum tax.decval[1] format '>>>>>>>>9.99'
&scoped-define cursum tax.decval[2] format '>>>>>>>>9.99'
&scoped-define fine1 tax.decval[3]  format '>>>>>>>>9.99'
&scoped-define fine2 tax.decval[4]  format '>>>>>>>>9.99'
&scoped-define d   bta_x.date format '99/99/99'
&scoped-define n   bta_x.dnum format '>>>>>9' '   '
&scoped-define k   tax.kb   format '999999'
&scoped-define vpl budcodes.name1 format 'x(20)'
&scoped-define fio fioadr1 format 'x(85)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kazna trim(bankl.name) format "x(60)"
&scoped-define iik taxnk.iik format "999999999"
&scoped-define bik taxnk.bik format "999999999"
&scoped-define kod taxnk.kod format "99"
&scoped-define kbe taxnk.kbe format "99"
&scoped-define COLORD if bta_x.colord = 1 then " " else "Платежей - " + string(bta_x.colord) format "x(43)"
&scoped-define res if bta_x.resid = true then ' X ' else '   ' format 'x(3)'
&scoped-define nres if bta_x.resid = false then ' X ' else '   ' format 'x(3)'
&scoped-define dcomsum chr(27) 'x1' chr(27) 'E'  bta_x.comsum format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define dsumall chr(27) 'x1' chr(27) 'E' (totsum + bta_x.comsum) format '>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'

define var fioadr1 as char no-undo.
define var i as int no-undo.
define var sumchar as char no-undo.
define var mark as int no-undo.
define var crlf as char no-undo.
define var s_knp as char no-undo.
define var s_payment as char no-undo.
define variable ckv as int.

crlf = chr(10).


output to taxkvit.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.


do while rid <> "":

  find first bta_x where rowid(bta_x) = to-rowid(substring(rid,1,10)) no-lock no-error.
  rid = substring(rid, 11).
  if not avail bta_x then do:
     next.
  end.

  /*был случай когда комиссия проставилась нулевая.*/
  if bta_x.comsum = 0 then do:
    release tax.
    find first tax where tax.txb = bta_x.txb
                     and tax.date = bta_x.date
                     and tax.uid = bta_x.uid
                     and tax.rnn = bta_x.rnn
                     and tax.created = bta_x.created
                     and tax.dnum = bta_x.dnum
                     and tax.deldate = ?
                     and tax.duid = ?
                     and tax.comsum <> 0
                     no-lock no-error.
    if avail tax then do:
      find first bta_x where rowid(bta_x) = rowid(tax) no-lock no-error.
      if not avail bta_x then do:
        next.
      end.
    end.
    release tax.
  end.

  /* sasco : счетчик квитанций */

  if bta_x.uid = userid ("bank") then do:
    m1:
    do transaction:
      for each tax where tax.txb = bta_x.txb
                     and tax.date = bta_x.date
                     and tax.uid = bta_x.uid
                     and tax.rnn = bta_x.rnn
                     and tax.created = bta_x.created
                     and tax.dnum = bta_x.dnum
                     and tax.deldate = ?
                     and tax.duid = ?
                   exclusive-lock ON error UNDO m1:
         ckv = ?.
         ckv = integer (tax.chval[5]) no-error.
         if ckv = ? then ckv = 0.
         ckv = ckv + 1.
         tax.chval[5] = string (ckv, "zzz9").
      end.
    end.
  end.

  fioadr1 = bta_x.chval[1].
  if fioadr1 = '' then fioadr1 = getfioadr1(bta_x.rnn).

  find first taxnk where taxnk.rnn = bta_x.rnn_nk no-lock no-error.
  if not avail taxnk then do:
    message "Нет такого налогового коммитета.~nРаспечатать невозможно." view-as alert-box title "".
    return.
  end.
  find first bankl where bankl.bank = string(taxnk.bik,"999999999") no-lock no-error.


  do i = 1 to 2:

    tl_temp = {&tl}.

    IF tl_temp = "ИЗВЕЩЕНИЕ" and INDEX(bta_x.info,'<по акту изъятия>') <> 0 and bta_x.comcode = '42' and bta_x.comsum = 0 THEN next.

    if bta_x.intval[1] <> 0 then
      s_knp = string(bta_x.intval[1]).
    else
      s_knp = string(taxnk.knp).

    if i = 1 then do:
      put unformatted "+----------------------------------------------------------------------------------------------------АО'TEXAKABANK'-+" crlf
                      "| " chr(27) 'x1' chr(27) 'E' "Бенефициар" chr(27) 'x0' chr(27) 'F' " - РНН " {&rnk}              ". ИИК:" {&iik} ". БИК:" {&bik}  ".         " chr(27) 'x1' chr(27) 'E' "Отправитель" chr(27) 'x0' chr(27) 'F' " - РНН " {&rnn}              ". Резид. РК:" bta_x.resid format "Да/Нет" "|" crlf
                      "| ФИО, Адрес: "                 {&fio}                                                            "                 |" crlf
                      "+--------------------------------------+----------------------------------------------------------------------------+" crlf
                      "| ИЗВЕЩЕНИЕ-Корешок No" {&n}  "        |КНП| КБК  | Недоимка   |плат. тек. г|    Штраф   |      Пеня  |       ИТОГО |" crlf
                      "| Дата " {&d} "                        |   |      |            |            |            |            |             |" crlf.
    end. else do:
      put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf
                      "|                 |                                                                                                 |" crlf
                      "|                 |"        trim (taxnk.name) format 'x(51)' "  РНН " {&rnk}         "                         |" crlf
                      "|    " {&tl} "    |                                                                                                 |" crlf
                      "|    No" {&n}  "  |Наименование банка: " {&kazna}                                                  "                 |" crlf
                      "|                 |                                                                                    +---+        |" crlf
                      "|                 |ИИК бенефициара               " {&iik} "              БИК " {&bik} "      Резидент РК |" {&res} "|        |" crlf
                      "|                 |                                                                                    +---+        |" crlf
                      "|                 |РНН Отправителя денег        "   {&rnn} "                             Нерезидент РК |" {&nres} "|        |" crlf
                      "| --------------- |                                                                                    +---+        |" crlf
                      "|| АО'TEXAKABANK'||ФИО,Адрес: "                 {&fio}                 " |" crlf
                      "||Приходная касса||                                                                                                 |" crlf
                      "||Кассир No      ||Вид налогового режима   -----------                         -----------                 ---------|" crlf
                      "||Дата " {&d} "  ||                Патент |           | упрощенная декларация |           | Общеуст.режим |         |" crlf
                      "| --------------- |-------------------------------------------------------------------------------------------------|" crlf
                      "|                 |                    |   |      |   Недоимка |   Платежи  |            |            |             |" crlf
                      "|                 | Наименование       |КНП| КБК  |   прошлых  |   текущего |     Штраф  |     Пеня   |     ИТОГО   |" crlf
                      "|                 | платежа            |   |      |     лет    |    года    |            |            |             |" crlf
                      "|                 |--------------------+---+------+------------+------------+------------+------------+-------------|" crlf
                      .

    end.

    totsum = 0.

    for each tax where tax.txb = bta_x.txb
                      and tax.date = bta_x.date
                      and tax.uid = bta_x.uid
                      and tax.rnn = bta_x.rnn
                      and tax.created = bta_x.created
                      and tax.dnum = bta_x.dnum
                      and tax.duid = ?
                      and tax.deldate = ?
                    no-lock.
        find first budcodes where code = tax.kb no-lock no-error.
        if tax.intval[1] <> 0 then
          s_knp = string(tax.intval[1]).
        else
          s_knp = string(taxnk.knp).

        if i = 1 then
          put unformatted "|                                      |" s_knp format "x(3)" "|" {&k} "|" {&oldsum} "|" {&cursum} "|" {&fine1} "|" {&fine2} "|"  {&sum}   " |" crlf.
        else
          put unformatted "|                 |" {&vpl}           "|" s_knp format "x(3)" "|" {&k} "|" {&oldsum} "|" {&cursum} "|" {&fine1} "|" {&fine2} "|"  {&sum}   " |" crlf.

        totsum = totsum + tax.sum.
    end.

    if i = 1 then
      put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
    else
      put unformatted "|                 |--------------------+---+------+------------+------------+------------+------------+-------------|" crlf.

    if trim(bta_x.info) <> "" then do:
      put unformatted "|                 |" trim(bta_x.info) format 'x(96)'                                                               " |" crlf.
      if length(trim(bta_x.info)) > 96 then do:
        put unformatted "|                 |"  SUBSTR(trim(bta_x.info), 97) format 'x(96)'                                                 " |" crlf.
      end.
    end.

    if bta_x.colord > 1 then
      put unformatted "|                 |"        {&COLORD}                        "                                                      |" crlf
                      "|                 |-------------------------------------------------------------------------------------------------|" crlf.

    if i = 1 then do:
      put unformatted "| "   {&tsum}  " (всего) + " {&dcomsum} " (комиссия) = " {&dsumall} " (к оплате)                                          |" crlf.
      put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
    end. else do:
      run Sm-vrd.p(totsum, output sumchar).
      sumchar = sumchar + ' тенге ' +
        string((if (totsum - integer(totsum)) < 0 then
        1 + (totsum - integer(totsum)) else
        (totsum - integer(totsum))) * 100, "99") + ' тиын'.

      if length(sumchar) > 69 then
        mark = R-INDEX(sumchar, " ", 69).
      else
        mark = length(sumchar).


      /* 13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */
      if bta_x.comsum >= 100 then
        put unformatted "|                 |                                                                           ВСЕГО |"   {&tsum}  " |" crlf
                        "|  Кассир         |Отправитель денег                                                                 ---------------|" crlf.
      else
        put unformatted "|                 |                                                                           ВСЕГО |"   {&tsum}  " |" crlf
                        "|  Кассир         |Отправитель денег                                                                 ---------------|" crlf
                        "|                 |                                                                         Комиссия|" {&dcomsum} " |" crlf
                        "|                 |                                                                         Всего   |               |" crlf
                        "|                 |                                                                         к оплате|" {&dsumall} " |" crlf
                        "|                 |                                                                                 ----------------|" crlf.
      put unformatted
                      "|                 |                                                                                                 |" crlf
                      "|                 |Сумма прописью: "                   {&sum1}                                   "            |" crlf
                      "|                 |                "                   {&sum2}                                   "            |" crlf
                      "+-------------------------------------------------------------------------------------------------------------------+" crlf.

      if is_it_jur_person_rnn(bta_x.rnn) then do:
        if i = 2 then do:
          put unformatted "| Фамилия и                                         +-----+   Фамилия и                                             |" crlf.
          put unformatted "| инициалы руководителя: ______________________     | М.П.|   инициалы главного бухгалтера: ______________________  |" crlf.
          put unformatted "| Подпись: _______________________                  +-----+   Подпись: _______________________                      |" crlf.
          put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
        end. else do:
          put unformatted "| Фамилия и                                                   Фамилия и                                             |" crlf.
          put unformatted "| инициалы руководителя: ______________________               инициалы главного бухгалтера: _______________________ |" crlf.
          put unformatted "| Подпись: _______________________                            Подпись: _______________________                      |" crlf.
          put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
        end.
      end. else do:
        put unformatted "| Подпись отправителя денег: _________________________                                                              |" crlf.
        put unformatted "+-------------------------------------------------------------------------------------------------------------------+" crlf.
      end.
    end.

    put unformatted rid crlf crlf crlf.

    IF tl_temp = "ИЗВЕЩЕНИЕ" and INDEX(bta_x.info,'<по акту изъятия>') <> 0 and bta_x.comcode = '42' and bta_x.comsum = 0 THEN
      leave.
  end.


  put unformatted crlf crlf.
end.

put unformatted chr(27) chr(64).

output close.

unix silent un-dos taxkvit.txt taxkvit.dos.
unix silent dos-un taxkvit.dos taxkvit.txt.
unix silent prit taxkvit.txt.

IF INDEX(bta_x.info,'<по акту изъятия>') <> 0 and bta_x.comcode = '42' and bta_x.comsum = 0 THEN
  return.


/* БКС ---------------------------------------------------------------------------*/
  s_payment = ''.

  for each tax where tax.txb = bta_x.txb
                 and tax.date = bta_x.date
                 and tax.uid = bta_x.uid
                 and tax.rnn = bta_x.rnn
                 and tax.created = bta_x.created
                 and tax.dnum = bta_x.dnum
                 and tax.duid = ?
                 and tax.deldate = ?
               no-lock.

    find first budcodes where budcodes.code = tax.kb no-lock no-error.
    if avail budcodes then
      s_budget = budcodes.name.
    else
      s_budget = "Другие платежи в бюджет".
    s_payment = s_payment + string(tax.dnum) + "#" + s_budget + "#" + string(tax.sum) + "#" + string(tax.comsum) + "#" + "0" + "#" + "KZT" + "|".
  end.
  if avail taxnk then
    s_budget = "NO" + "#" + bta_x.rnn_nk  + "#" + trim(taxnk.name) + "#" + {&rnn} + "#" + fioadr1.
  else
    s_budget = "NO".
  s_payment = right-trim(s_payment,"|").
  run bks(s_payment, s_budget).

/*---------------------------------------------------------------------------*/



/*
unix silent rm taxkvit.dos.
unix silent rm taxkvit.txt.
*/
