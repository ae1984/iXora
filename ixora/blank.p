/* blank.p
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


def temp-table test
         field nu    as character
         field name  as character
         field s-dat as character
         field acc   as character
         field crc   as character
         field r-dat as character
         field e-dat as character
         field ostat as character
         field sum   as character
/*         field type  as character*/
         field adres as character
         field phone as character.

define temp-table t-t like test. 
define temp-table n-n 
         field sum as integer 
         field lim as integer . 

def var fiel as character .
def var t as int.
define variable summ  as integer .
define variable limit as integer .
define variable num as character .
define variable fam as character .
define variable nam as character .
define variable ot  as character .
define variable tip as character .

def var v-dbpath as char.
find sysc where sysc.sysc = "rkbdir" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

input from value(v-dbpath + "import/ll.d").

repeat:
   create test.
   import test.
end.

input close.

input from value(v-dbpath + "import/ll-1.csv").
repeat:
   create n-n.
   import n-n.
end.
input close.

/* обработка */


   find first test.
   fiel = test.name .
   create t-t.
   buffer-copy test to t-t .

repeat .
   find next test where test.name <> fiel .
   fiel = test.name .
   create t-t.
   buffer-copy test to t-t .
end.
   
/*for each t-t . display t-t. end .*/

update fiel format "x(21)" label "Введите номер клиента:".

find t-t where t-t.nu = fiel no-lock .
display t-t.name format "x(30)" label "Имя".

fiel = t-t.acc .
if length (fiel) = 8 then fiel = "0" + fiel .
find aaa where aaa.aaa = fiel no-lock .
find cif where cif.cif = aaa.cif no-lock .

summ = integer (t-t.sum) .
find first n-n where n-n.sum >= summ no-error.
if not available n-n then limit = 750000 . else limit = n-n.lim .

run Sm-vrd (decimal(limit), output fiel).

tip = "0".

for each test where test.name = t-t.name .
   if integer(test.ostat) > integer(tip) then do:
                                            tip = test.ostat .
                                            num = test.nu .
                                         end.
end.
 
fam = caps (entry (1,t-t.name," ")).
fam = CAPS(SUBSTRING(fam, 1, 1)) + LC(SUBSTRING(fam, 2)).
nam = caps (entry (2,t-t.name," ")).
nam = CAPS(SUBSTRING(nam, 1, 1)) + LC(SUBSTRING(nam, 2)).
ot = caps (entry (3,t-t.name," ")).
ot = CAPS(SUBSTRING(ot, 1, 1)) + LC(SUBSTRING(ot, 2)).

/* Формирование первого листа */
unix silent rm -f value("blank.img").  
output to blank.img .

put
skip(3)
space(197)
" "                
skip(5)
space(159)
"И. О. Первого Заместителя Председателя Правления"
skip
space(159)
"Степановой Ирины Константиновны"
skip(1)
space(159)
"Устава"
skip
space(174)
fam format "x(15)"    
skip (1)
space(174) 
nam format "x(15)"
skip (1)
space(174) 
ot  format "x(15)".

output close.
unix silent cptwo "blank.img" .
 
find test where test.nu = num .

/* Формирование второго листа */
unix silent rm -f value("blank.img").  
output to blank.img .

put
skip(5)
space(10)
test.acc
space(18)
test.r-dat
skip
space(20)
test.r-dat
skip(5)
space(107)
"KZT"
skip(29)
space(107)
"KZT"
skip(3)
space(85)
limit
space(13)
fiel format "x(50)"	
skip(1)
space(150)
"KZT"
skip(8)
space(87)
"34,8   тридцать четыре целых восемь десятых"
skip(7)
space(84)
"45           сорок пять"		
skip(4)
space(84)
"45           сорок пять"		
skip(5)
space(173)
test.adres format "x(45)"
skip(1)
space(168)
cif.jss
space(24)
cif.pss
skip(3)
space(164)
fam format "x(15)"
" " 
nam format "x(15)"
" " 
ot  format "x(15)"
skip(1)
space(194)
"Степанова И. К."
skip(1)
space(160)
"03    июля 2003 г.".


output close.
unix silent cptwo "blank.img" .


