/* p_f_rko.p
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
        13/10/2003 kanat - Добавил вывод столбца добровольных пенсионных взносов после имени плательщика (13%)
        29/10/2003 sasco - добавил 2 разряда в номер документа
        13/11/2003 kanat - Внес измениения в формирование даных по cod = 300
        18/03/2004 kanat - Переделал break by по типам платежей (for each payment ... )
        14/02/2005 kanat - Добавил кол-во вкладчиков
        15/02/2005 kanat - Уменьшил формат вывода по просьбе юзеров
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{global.i}
{functions-def.i}
{get-dep.i}

def stream m-out.        
def var v-dat as date.
def var ssum as deci init 0.0.
def var sumcom as deci init 0.0.
def var sumr as deci init 0.0.
def var name as char format "x(30)" .

define temp-table payment like p_f_payment
   field dep like ppoint.depart.

v-dat = g-today. 
if not g-batch then do:
    update v-dat label " Укажите дату " format "99/99/9999" skip
    with side-label row 5 centered frame dataa .
    end.


find first ofc where ofc.ofc eq g-ofc.
output stream m-out to p_f_rko.img.
put stream m-out skip " "
FirstLine( 1, 1 ) format "x(79)" skip(2)
"  "
"РЕЕСТР ИЗВЕЩЕНИЙ ПО ПРИЕМУ ПЕНСИОННЫХ ПЛАТЕЖЕЙ ПО СПФ" skip " "
"                       "
" ЗА " v-dat format "99/99/9999" " г." skip(1).
put stream m-out  fill( "-", 148 ) format "x(148)" skip.
put stream m-out
" номер/док    "
"    РНН        "
"К-во "
"   Сумма    "
"    Комиссия "
"         Всего "
"   РНН П.Ф.        "
"КНП  "
"   Ф.И.О.                       " skip.
put stream m-out fill( "-", 148 ) format "x(148)" skip(1).

for each p_f_payment where txb = seltxb and date = v-dat and p_f_payment.deluid = ? and
                           (p_f_payment.cod = 100 or p_f_payment.cod = 200 or p_f_payment.cod = 300)
                           no-lock:
    create payment.
    buffer-copy p_f_payment to payment.
    payment.dep = get-dep(p_f_payment.uid, v-dat).
end.

/* разбивка payment.distr - по Пенсионным Фондам - Гульнаре это не нужно! */
for each payment no-lock break /*by payment.distr*/ by payment.dep by payment.cod:
 
  accumulate payment.amt 
    (sub-total /*by payment.distr*/ by payment.dep).

  accumulate payment.comiss 
    (sub-total /*by payment.distr*/ by payment.dep).

  accumulate payment.amt + payment.comiss 
    (sub-total /*by payment.distr*/ by payment.dep).  

  accumulate payment.qty
    (sub-total /*by payment.distr*/ by payment.dep).  

  accumulate payment.amt 
    (total count).

  accumulate payment.comiss 
    (total).

  accumulate payment.amt + payment.comiss 
    (total).  

  accumulate payment.amt 
    (sub-count /*by payment.distr*/ by payment.dep).

if first-of(payment.dep) then do:
  find first ppoint where ppoint.depart = payment.dep.
  put stream m-out unformatted " " ppoint.name skip
     fill( "-", 148 ) format "x(148)" skip.
end.

put stream m-out payment.dnum format "zzzzzzz9" "       " payment.rnn " "  

string(accum sub-total by payment.dep payment.qty) format "x(2)" " ".
 
put stream m-out "  " payment.amt format "zzzzzzz9.99" "      ".

put stream m-out payment.comiss format "zzzzzz9.99" "    ".

put stream m-out payment.amt + payment.comiss format "zzzzzzz9.99" "    ".

put stream m-out payment.distr format "x(13)" " " 
                 string(payment.cod) format "x(5)".

name = trim(payment.name).
if payment.cod = 200 then do:
  if length(name) > 26 then
    name = substr(name, 1, 26).
  name = name + " (пеня)".
end.

if payment.cod = 300 then do:
  if length(name) > 26 then
    name = substr(name, 1, 26).
  name = name + " (Д.в.(13))".
end.

put stream m-out name format "x(33)" skip.

if last-of(payment.dep) then do:
  put stream m-out fill( "-", 148 ) format "x(148)" skip
    " Итого " (accum sub-count by payment.dep payment.amt) format "zzzzzzzz9" " платежей" space(9)
    (accum sub-total by payment.dep payment.amt) format "zzzzzzz9.99" "      "
    (accum sub-total by payment.dep payment.comiss) format "zzzzzz9.99" "    "
    (accum sub-total by payment.dep payment.amt + payment.comiss) format "zzzzzzz9.99" "    " skip
    fill( "-", 148 ) format "x(148)" skip(1).
end.

/*
if last-of(payment.distr ) then do:
put stream m-out " Итого по Пенсионному Фонду" 
  (accum sub-total by payment.distr payment.amt) format "zzzzzzz9.99" "      "  
  (accum sub-total by payment.distr payment.comiss) format "zzzzzz9.99" "  " 
  (accum sub-total by payment.distr payment.amt + payment.comiss) format "zzzzzzzzz9.99" skip.
put stream m-out " " fill( "-", 148 ) format "x(148)" skip.  
end.
*/

ssum = ssum + payment.amt.
sumcom = sumcom + payment.comiss.
sumr = sumr + payment.amt + payment.comiss.  
end.
put stream m-out fill( "-", 148 ) format "x(148)" skip.
put stream m-out 
" Итого " (accum count payment.amt) format "zzzzzzzz9" " платежей" space(2)
    (accum total payment.amt) format "zzzzzzz9.99" "      "
    (accum total payment.comiss) format "zzzzzz9.99" "    "
    (accum total payment.amt + payment.comiss) format "zzzzzzz9.99" "    " skip
    fill( "-", 148 ) format "x(148)" skip(2).
put stream m-out "Менеджер операцион-" skip.
put stream m-out " ного департамента                " ofc.name format "x(30)" skip(2).
output stream m-out close.

run menu-prt("p_f_rko.img").
