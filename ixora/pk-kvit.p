/* pk-kvit.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        14/01/08 marinav - переделано под расчетно-кассовый центр
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/

/* -------------------------------- */
/* Печать квитанции для проводок по */
/* потребительскому кредитованию    */
/* 09.02.2003 by Sasco              */
/* -------------------------------- */

{global.i}
{pk.i  }
{get-kod.i}
{pk-sysc.i}
{nbankBik.i}
/*
s-credtype = "6".
s-pkankln = 5.
*/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.sts < "50" then do:
  message skip " Сумма не переведена на тек.счет предприятия-партнера !~n Печать платежного поручения запрещена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


def     buffer bcif    for cif.
def        var knpcode as int format "999".
def        var knpdes  as char format "x(88)".
def        var crlf    as char.
def        var seltxb  as int.
def        var sumchar as char.
def        var mark    as int.

seltxb = comm-cod().

/*&scoped-define kod     get-kod (pkanketa.aaa, "") format "x(2)"
&scoped-define kbe     get-kod (pkanketa.partner, "") format "x(2)" */
def var vkod as char format "x(2)".
def var vkbe as char format "x(2)".
def var vsum as deci.

vsum = pkanketa.sumout.

&scoped-define name1   trim(cif.name) + ", " + trim(cif.addr[2]) format "x(58)"
&scoped-define name2   trim('ТОО "Расчетно-кассовый центр 1"') format "x(54)"
&scoped-define udl     trim(docnum) format "x(10)"
&scoped-define rnn1    cif.jss format "x(12)"
&scoped-define rnn2    '600900567221' format "x(12)"
&scoped-define bank    bankl.name format "x(56)"
&scoped-define iik1    pkanketa.aaa format "x(9)"
&scoped-define iik2    string(arp.arp) format "x(9)"
&scoped-define bic     sysc.chval format "999999999"
&scoped-define sum     vsum format "z,zzz,zzz,zz9.99"
&scoped-define sum1    SUBSTR (sumchar, 1, mark) format "x(87)"
&scoped-define sum2    SUBSTR (sumchar, mark + 1) format "x(87)"
&scoped-define npl1    SUBSTR ("Перевод собственных средств") format "x(87)"
&scoped-define npl2    SUBSTR ("") format "x(87)"
&scoped-define manager trim(ofc.name)

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

vkod = get-kodkbe (pkanketa.aaa , "").
/*vkbe = get-kodkbe (pkanketa.partner , "").*/

find first cif where cif.cif = pkanketa.cif no-lock no-error.
/*
find first aaa where aaa.aaa = pkanketa.partner no-lock no-error.
find first bcif where bcif.cif = aaa.cif no-lock no-error.
*/

vkbe = '15'.
find first arp where arp.arp = '000904512' no-lock no-error.

find rnn where rnn.trn = cif.jss no-lock no-error.
if not avail rnn then find rnnu where rnnu.trn = cif.jss no-lock no-error.

find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "knp" no-lock no-error.
     if not avail pksysc then leave.
     knpcode = pksysc.inval.
     find codfr where codfr.codfr = "spnpl" and codfr.code = string (pksysc.inval) no-lock no-error.
knpdes = trim (codfr.name[1]) + trim (codfr.name[2]) + trim (codfr.name[3]) + trim (codfr.name[4]) + trim (codfr.name[5]).

run Sm-vrd (vsum, output sumchar).
sumchar = sumchar + " тенге " + string ((
          if (vsum - integer(vsum)) < 0 then 1 + (vsum - integer(vsum))
                                        else (vsum - integer(vsum))) * 100, "99") + ' тиын'.

if length(sumchar) > 68 then mark = R-INDEX(sumchar, " ", 68).
                        else mark = length(sumchar).

find sysc where sysc.sysc = "CLECOD" no-lock no-error.
find bankl where bankl.bank = sysc.chval.

find ofc where ofc.ofc = g-ofc no-lock no-error.

crlf = chr(10).

output to pkkvit.txt.
put unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' crlf.

put unformatted string (pkanketa.docdt) ", " string (time, "hh:mm:ss") " " + v-nbankru + " " crlf crlf.
put unformatted "                                    ПЛАТЕЖНОЕ ПОРУЧЕНИЕ No " pkanketa.credtype pkanketa.ln crlf.
put unformatted "                                         ДАТА " + string (pkanketa.docdt) crlf crlf.
put unformatted "-----------------------------------------------------------------------------------------------------------" crlf.
put unformatted "Плательщик:    | " vkod " | Уд.личности " {&udl} "                                                              |" crlf.
put unformatted "---------------------                                                                                     |" crlf.
put unformatted "| " {&rnn1} " | "        {&name1}                                         "  Дебет             Сумма      |" crlf.
put unformatted "-----------------------------------------------------------------------------------------------------------" crlf.
put unformatted "Банк плательщика:                                                  |                   |                  |" crlf.
put unformatted "                                                         ----------|                   |                  |" crlf.
put unformatted                            {&bank}                   " |" {&bic} "| Счет No " {&iik1} " |                  |" crlf.
put unformatted "---------------------------------------------------------------------------------------|                  |" crlf.
put unformatted "Получатель:    | " vkbe " |                                                                  |                  |" crlf.
put unformatted "---------------------                                                                  |              KZT |" crlf.
put unformatted "| "  {&rnn2} " | "        {&name2}                                    "      Кредит    | "    {&sum}    " |" crlf.
put unformatted "---------------------------------------------------------------------------------------|------------------|" crlf.
put unformatted "Банк получателя:                                                   |                   |                  |" crlf.
put unformatted "                                                         ----------|                   |                  |" crlf.
put unformatted                            {&bank}                   " |" {&bic} "| Счет No " {&iik2} " |                  |" crlf.
put unformatted "---------------------------------------------------------------------------------------|------------------|" crlf.
put unformatted "Сумма прописью:                                                                        | В.о.|            |" crlf.
put unformatted                            {&sum1}                                                     "|-----|------------|" crlf.
put unformatted                            {&sum2}                                                     "| Н.п.|            |" crlf.
put unformatted "---------------------------------------------------------------------------------------|-----|------------|" crlf.
put unformatted "Назначение платежа, наименование товара, выполненных работ, оказанных услуг:           | С.п.|            |" crlf.
put unformatted " Перевод собственных средств                                                           |-----|------------|" crlf.
put unformatted "                                                                                       | О.п.|            |" crlf.
put unformatted "Код назначения платежа:   " knpcode format "999" "                                                          |-----|------------|" crlf.
put unformatted                            knpdes format "x(87)"                                       "| N.б.|            |" crlf.
put unformatted "---------------------------------------------------------------------------------------|-----|------------|" crlf.
put unformatted "                                                                                       | Тип | нормальный |" crlf.
put unformatted "                                                                                       |-----|------------|" crlf.
put unformatted "                                                                                       | Ком.| плательщик |" crlf.
put unformatted "-----------------------------------------------------------------------------------------------------------" crlf crlf.
put unformatted "    Плательщик                                Менеджер: " {&manager} "                М.П." crlf crlf crlf crlf.

put unformatted chr(27) chr(64).
output close.

/*
unix silent un-dos pkkvit.txt pkkvit.dos.
unix silent dos-un pkkvit.dos pkkvit.txt.
*/

/*
run menu-prt ("pkkvit.txt").
*/
unix silent prit pkkvit.txt.


/*
&scoped-define rnnbn bcif.jss format "x(12)"
&scoped-define rnn   cif.jss format "9999999"
&scoped-define tl1   "ПЛАТЕЖНОЕ"
&scoped-define tl2   "ПОРУЧЕНИЕ"
&scoped-define sum   chr(27) 'x1' chr(27) 'E' vsum format '>>>>>>>>>>9.99' chr(27) 'x0' chr(27) 'F'
&scoped-define d     g-today format '99/99/99'
&scoped-define n     pkanketa.ln format '>>>>>>9' '  '
&scoped-define vpl1  trim(substring("Приобретение бытовой техники: " + pkanketa.goal,1,57)) format 'x(60)'
&scoped-define vpl2  trim(substring("Приобретение бытовой техники: " + pkanketa.goal,58,58)) format 'x(60)'

&scoped-define fio  if avail rnn then trim( rnn.lname ) + " " + trim( rnn.fname ) + " " + trim( rnn.mname ) + ", " + rnn.street1 + ", " + rnn.housen1 + "/" + rnn.apartn1 else if avail rnnu then trim( rnnu.busname ) + ", " + rnnu.street1 + ", " + rnnu.housen1 + "/" + rnnu.apartn1 else cif.name format 'x(73)'
&scoped-define sum1 SUBSTR(sumchar, 1, mark) format 'x(68)'
&scoped-define sum2 SUBSTR(sumchar, mark + 1) format 'x(68)'

&scoped-define kod  get-kod (pkanketa.aaa, "") format "x(2)"
&scoped-define kbe  get-kod (pkanketa.partner, "") format "x(2)"
&scoped-define iik  pkanketa.partner format "999999999"
&scoped-define bik  sysc.chval format "999999999"
&scoped-define udl  trim(pkanketa.rescha[1]) format "x(70)"

put unformatted "--------------------------------------------------------------------------------------------------------" crlf.
put unformatted "|                 |                                                             ------   --------------|" crlf.
put unformatted "|    " {&tl1} "    |"        bcif.name format "x(58)"                       "KБе| " {&kbe} " |РНН|"  {&rnnbn}  "||" crlf.
put unformatted "|    " {&tl2} "    |                                                             ------   --------------|" crlf.
put unformatted "|    No" {&n}  "  |Наименование банка: " bankl.name format "x(50)" "              |" crlf.
put unformatted "|                 |                          ------------------          -----------                   |" crlf.
put unformatted "|                 |ИИК бенефициара           |  " {&iik} "     |       БИК|" {&bik} "|                   |" crlf.
put unformatted "|                 |                          |----------------|    -----------------                   |" crlf.
put unformatted "|                 |Лицевой счет плательщика  |  " {&rnn} "      |  KОд| " {&kod} " |                              |" crlf.
put unformatted "|                 |                          ------------------    ------                              |" crlf.
put unformatted "| --------------- |ФИО,Адрес: "                 {&fio}                                                 "|" crlf.
put unformatted "||АО 'TEXAKABANK'||Удостоверение личности номер " {&udl}                                                             "              |" crlf.
put unformatted "||Приходная касса||------------------------------------------------------------------------------------|" crlf.
put unformatted "||Кассир No      ||                                                            |        |              |" crlf.
put unformatted "||Дата " {&d} "  ||        Вид платежа                                         |  Дата  |    Сумма     |" crlf.
put unformatted "||Сумма          ||                                                            |        |              |" crlf.
put unformatted "||"   {&sum}   " ||------------------------------------------------------------+--------+--------------|" crlf.
put unformatted "| --------------- |"        {&vpl1}                                           "|" {&d} "|"   {&sum}   "|" crlf.
put unformatted "|                 |------------------------------------------------------------+--------+--------------|" crlf.
put unformatted "|                 |"        {&vpl2}                                           "|        |              |" crlf.
put unformatted "|                 |---------------------------------------------------------------------+--------------|" crlf.
put unformatted "|                 |                                                               Пеня  |              |" crlf.
put unformatted "|                 |Отправитель денег                                                    |--------------|" crlf.
put unformatted "|                 |                                                               Всего |"   {&sum}   "|" crlf.
put unformatted "| Кассир          |                                                                     ---------------|" crlf.
put unformatted "|                 |Сумма прописью: "                   {&sum1}                                         "|" crlf.
put unformatted "|                 |                "                   {&sum2}                                         "|" crlf.
put unformatted "--------------------------------------------------------------------------------------------------------" crlf.
put unformatted crlf crlf.

put unformatted crlf crlf crlf crlf crlf crlf.
*/




