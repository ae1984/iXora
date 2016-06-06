/* pl.p
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
*/

output to "111".
define variable decSum as decimal.                      /*сумма в числовом выражении*/
define variable strSum as char format "x(100)".         /*сумма прописью*/
define variable strTiyn as char format "x(2)".          /*тиыны*/
define variable strPart1 as char.                       /*первая часть суммы прописью*/
define variable strPart2 as char.                       /*вторая часть суммы прописью*/
define variable temp as char.                           /*просто буферная переменная*/
define variable BK as char.                             /*код бюдж.класс.*/
define variable x as integer.                           /*счетчик*/
define variable num as char.                            /*номер п/п */
for each remtrz where remtrz = "RMZ264246A":
find first sub-cod where sub-cod.acc = remtrz.remtrz and d-cod = "eknp" and rcode <> "" and sub = "rmz" no-lock no-error.
find first jh where jh.jh = remtrz.jh1 no-lock no-error. /*ищем номер п/п */
temp = substring(jh.party, 14).
repeat:      /*очищаем номер п/п от мусора*/
    x = x + 1.
    if substring(temp, x, 1) <> ")" then
        num = num + substring(temp, x, 1).
    else leave.
end.
x = 0.
put fill("", 5) format "x(5)" remtrz.remtrz "/" trim(string(remtrz.jh1)) format "x(15)" skip.
put fill("", 30) format "x(30)" "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N " num format "x(15)" skip.
put fill("", 35) format "x(35)" "Дата: " remtrz.rdt skip.
put fill("", 20) format "x(20)" "----------" skip.
put fill("", 5) format "x(5)" "Плательщик:    |" trim(substring(sub-cod.rcode,1,2)) "|" skip.
put fill("", 5) format "x(5)" "-------------------------" skip.
put fill("", 5) format "x(5)" "|" trim(remtrz.ord) format "x(58)" "ДЕБЕТ          СУММА" skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
put fill("", 5) format "x(5)" "Банк плательщика:" fill("", 36) format "x(36)" "|" fill("", 11) format "x(11)" "|" fill("", 21) format "x(21)" "|" skip.
put fill("", 48) format "x(48)" "----------|           |                     |" skip.
put fill("", 5) format "x(5)" "АО TEXAKABANK г. Алматы 600900050984       |190501914| " trim(remtrz.dracc) format "x(9)" " |                     |" skip.      
put fill("", 5) format "x(5)" "-----------------------------------------------------------------|                     |" skip. 
put fill("", 5) format "x(5)" "Получатель:    |" trim(substring(sub-cod.rcode,4,2)) "|" remtrz.bn[3] format "x(40)" "|                     |" skip.
put fill("", 5) format "x(5)" "-------------------------                                        |                     |" skip.
put fill("", 5) format "x(5)" "|" trim(bn[1]) format "x(57)" "КРЕДИТ |" remtrz.amt "|" skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
put fill("", 5) format "x(5)" "Банк получателя:                                     |           |                     |" skip.
put fill("", 48) format "x(48)" "----------|           |                     |" skip.
put fill("", 5) format "x(5)" trim(bb[1]) format "x(40)" "   |" trim(rcbank) format "x(9)" "| " trim(ba) format "x(9)"  " |                     |" skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
put fill("", 5) format "x(5)" "Сумма прописью:                                                  |В.о.|                |"  skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
decSum = remtrz.amt.
temp = string(remtrz.amt).
if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    strTiyn = substring(temp, length(temp) - 1, 2) + " тиын".
    if num-entries(strTiyn,".") = 2 then
    strTiyn = substring(strTiyn,2,1) + "0 тиын".
end.
else strTiyn = "00 тиын".
run Sm-vrd.p(input decSum, output strSum). /*получаем сумму прописью*/
strSum = substring(strSum,1,length(strSum),"character").
strSum = strSum + " тенге " + strTiyn.
if length(strSum) > 85 then do:  
/*если сумма прописью слишком длинная, разбиваем ее на две части*/
    strPart1 = substring(strSum,1,85).
    strPart2 = substring(strSum,85).
    put "     " strPart1 format "x(87)" "|" skip.
    put "     " strPart2 format "x(87)" "|" skip.
end.
else put "     " strSum format "x(87)" "|" skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
put "                                                                      |Н.П.|" trim(substring(sub-cod.rcode,7,3)) "        |" skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
x = length(remtrz.ba).
if x = 16 THEN DO: /*если равно, это бюджетный платеж*/
    BK = substring(remtrz.ba, length(remtrz.ba) - 5, 6). /*ищем код БК*/
    put "     Назначение платежа:" fill(" ", 46) format "x(46)" "|Б.К.|" BK "        |"  skip.
end.
else
put fill("", 5) format "x(5)" "Назначение платежа:                                              |Б.К.|                |" skip.
put fill("", 5) format "x(5)" detpay [1] fill(" ", 30) format "x(30)" "-----------------------" skip.
put fill("", 5) format "x(5)" detpay [2] fill(" ", 30) format "x(30)" "|Д.в.|" valdt2 "        |"  skip.
put fill("", 5) format "x(5)" detpay [3] fill(" ", 30) format "x(30)" "-----------------------" skip.
put fill("", 5) format "x(5)" detpay [4] "                              |N.б.|                |"  skip.
put fill("", 5) format "x(5)" fill("-", 88) format "x(88)" skip.
put fill("", 5) format "x(5)" "М.П.                   Руководитель                        Проведено банком-получателем" skip.
put "                                                                                    " remtrz.rdt skip.
put "" skip.
put "                            Гл.бухгалтер                                       Подпись банка" skip.
put "                                                                                   ~ " remtrz.rwho skip.



end.
output close.