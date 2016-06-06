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
        09.08.06 u00124 - переделал для платежей Алматытелеком
        11.08.06 u00124 - переделал для платежей Алматытелеком по новой форме
        14.08.06 u00124 - убрал жирный шрифт.
        07.11.06 u00124 - убрал печать извещений

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
def var ckv as int no-undo.
def var v-ofcname as char no-undo.
def var s_BKS1 as char no-undo. /*u00568 */
def var s_BKS2 as char no-undo. /*u00568 */


&scoped-define rnnbn commonpl.rnnbn  format "x(12)"
&scoped-define rnn  string(commonpl.accnt) /*commonpl.rnn*/    format "x(12)"
&scoped-define tl    if i = 1 then "ИЗВЕЩЕНИЕ" else "КВИТАНЦИЯ"
&scoped-define sum /*chr(27) 'x1' chr(27) 'E'*/ commonpl.sum format '>>>>>>>>>>9.99' /*chr(27) 'x0' chr(27) 'F'*/
&scoped-define d   commonpl.date format '99/99/99'
&scoped-define n   commonpl.dnum format '>>>>>9' '   '
&scoped-define vpl1 "Услуги телефонной связи" /*trim(substring(commonls.npl,1,40))*/ format 'x(44)'
&scoped-define vpl2 /*trim(substring(commonls.npl,41,40))*/ "" format 'x(44)'
&scoped-define fio string(commonpl.counter)  format 'x(12)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(69)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(69)'
&scoped-define kod  /*commonls.kod*/ commonpl.fioadr format "x(9)"
&scoped-define kbk  string(commonpl.kb,"999999")
&scoped-define kbe  commonls.kbe format "x(2)"
&scoped-define iik  commonls.iik format "999999999"
&scoped-define bik  commonls.bik format "999999999"
&scoped-define COLORD " " /*if commonpl.z = 1 then " " else "Плательщиков - " + string(commonpl.z)*/ format "x(40)"
&scoped-define dockts commonpl.info[2] format 'x(85)'
&scoped-define dcomsum chr(27) 'x1' chr(27) 'E'  commonpl.comsum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define dsumall chr(27) 'x1' chr(27) 'E' (commonpl.sum + commonpl.comsum) format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'

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
           ckv = integer (commonpl.chval[5]) no-error.
           if ckv = ? then ckv = 0.
           ckv = ckv + 1.
           commonpl.chval[5] = string (ckv, "zzz9").
        end.
        find current commonpl no-lock no-error.
     end.


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
                            commonls.grp = commonpl.grp and commonls.visible = yes no-lock no-error.
  find first bankl where bankl.bank = string(commonls.bikbn) USE-INDEX bank no-lock no-error.

  if commonpl.arp <> "250904845" then do:   /*28/06/04*/

    do i = 2 to 2:
      put unformatted
      "---------------------------------------------------------------------------------------------------------" crlf
      "|                 |                                                              ------   --------------|" crlf
      "|                 |"       "АлматыТелеком" /*commonls.bn*/ format "x(58)"                       " KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf
      "|    " {&tl} "    |                                                              ------   --------------|" crlf
      "|    No" {&n}  "  |Наименование банка: " bankl.name format "x(50)" "               |" crlf
      "|                 |                          ------------------           -----------                   |" crlf
      "|                 |ИИК бенефициара           |  " {&iik} "     |        БИК|" {&bik} "|                   |" crlf
      "|                 |                          |----------------|     -----------------                   |" crlf
      "|                 |Номер лицевого счета      |  "   {&rnn} "  |  Номер Сч. извещения| " {&kod} " |  "

      if ltax then "       КБК: " + {&kbk} + "     |" else "     |"

      crlf
      "| --------------- |                          ------------------  --------------------------------       |" crlf
      "|| АО'TEXAKABANK'||Номер телефона            |  " {&fio}   "  |                                         |" crlf
      "||Приходная касса||-------------------------------------------------------------------------------------|" crlf
      "||Кассир No      ||                                            |        |       |        |              |" crlf
      "||Дата " {&d} "  ||        Вид платежа                         |        |       |  Дата  |    Сумма     |" crlf
      "||Сумма          ||                                            |        |       |        |              |" crlf
      "||"   {&sum}   " ||--------------------------------------------+--------+-------+--------+--------------|" crlf
      "| --------------- |"      {&vpl1}            "|        |       |" {&d} "|"   {&sum}   "|" crlf
      "|                 |--------------------------------------------+--------+-------+--------+--------------|" crlf  .
/*    "|                 |"        {&vpl2}                           "|        |       |        |              |" crlf
      "|                 |----------------------------------------------------------------------+--------------|" crlf 
      "|                 |"        {&COLORD}                         "                        Пеня  |              |" crlf
      "|                 |                                                                      |--------------|" crlf
      "|                 |                                                                Всего |"   {&sum}   "|" crlf
      "| Кассир          |                                                                      ---------------|" crlf.*/




        put unformatted
/*      "|                 |                                                             Комиссия |" {&dcomsum} "|" crlf
        "|                 |                                                             Всего    |              |" crlf
        "|                 |                                                             к оплате |" {&dsumall} "|" crlf
        "|                 |                                                                      ---------------|" crlf  */ 

        "|                 |                                                                                     |" crlf   
        "| Кассир          |Сумма прописью: "                   {&sum1}                                         "|" crlf
        "|                 |                "                   {&sum2}                                         "|" crlf.
      /* 13/05/05 kanat - Добавил условие, если комиссия <= 100, то тогда добавляется в конец подсчет обшей суммы с комиссией */


      put unformatted
      "|                 |"{&dockts}                                                                          "|" crlf
      "---------------------------------------------------------------------------------------------------------" crlf
      rid crlf crlf crlf.
    end. /* for */

  end. /* if commonpl.arp <> "250904845" then do: ... */

  /* -------------------------------------------------------------------------------------------------------------------------------- */
/*  find sysc where sysc.sysc = "BKEXCL" no-lock no-error.
  if available sysc and lookup (g-ofc, sysc.chval) > 0 then
    s_print = "NO".
  else do:

    i_temp_dep = int(get-dep (g-ofc, g-today)).

    find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
    if avail depaccnt and depaccnt.rem <> '' then do:

      find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
      if avail ppoint then
        s_depname = ppoint.name.
      else
        s_depname = '***'.

      s_nknmb = entry(1,depaccnt.rem,'$').
      s_stadr = entry(2,depaccnt.rem,'$') + ' ' + entry(3,depaccnt.rem,'$').

      if entry(4,depaccnt.rem,'$') = "" then do:
        find first cmp no-lock no-error.
         s_rnn = cmp.addr[2].
      end.
      else
        s_rnn = entry(4,depaccnt.rem,'$').
    end.
    else do:
      s_nknmb = '***'.
      s_stadr = '***'.
    end.

    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then
      v-ofcname = ofc.name.
    else
      v-ofcname = "manager".

    put unformatted  "                 КОНТРОЛЬНЫЙ ЧЕК БКС N " string(time) skip.
    put unformatted  "Наименование банка (структурного подразделения): " skip.
    put unformatted  "АО TEXAKABANK " s_depname skip.
    put unformatted  s_stadr format 'x(100)' skip.
    put unformatted  "РНН: " s_rnn skip.
    put unformatted  "Рег. номер БКС в НК: " s_nknmb  skip.
    put unformatted  "Кассир: " v-ofcname skip.
    put unformatted  string(commonpl.date) " " string(time,"HH:MM:SS") skip.

    put unformatted "Получатель: " {&rnnbn} " " commonls.bn format "x(58)" skip.
    put unformatted "Отправитель: " {&rnn} " " {&fio} skip.

    put fill("=",78) format "x(78)" skip.

    put  string(commonpl.dnum) format "x(10)" " | " substr(commonls.npl,1,40) format "x(40)" " | " commonpl.sum format ">>>>>>>>9.99" " | KZT" skip.

    put fill("=",78) format "x(78)" skip.
    put "Комиссия банка: " commonpl.comsum format ">>>>>>>>9.99" " KZT" skip.
    put "ИТОГО: " commonpl.sum + commonpl.comsum format ">>>>>>>>9.99" " KZT" skip(2).

  end. */
  /* -------------------------------------------------------------------------------------------------------------------------------- */
  put unformatted crlf crlf.
end.

put unformatted chr(27) chr(64).
output close.

unix silent un-dos cmplkvit.txt cmplkvit.dos.
unix silent dos-un cmplkvit.dos cmplkvit.txt.

unix silent prit cmplkvit.txt.
/* run menu-prt ("cmplkvit.txt"). */

    /*БКС u00568 Evgeniy--------------------------------------------------------------*/
    find first commonls where commonls.rnnbn = commonpl.rnnbn no-lock no-error. do:
      if avail commonls then
        s_BKS2 = commonls.bn.
      else
        s_BKS2 = "".
    end.
    s_BKS1 = string(commonpl.dnum) + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT" .
    s_BKS2 = "NO" + "#" + commonpl.rnnbn + "#" + s_BKS2 + "#" + commonpl.rnn + "#" + commonpl.fioadr .
/*    run bks(s_BKS1, s_BKS2).*/
    /*БКС u00568 Evgeniy--------------------------------------------------------------*/
