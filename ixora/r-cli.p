/* r-cli.p
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
        18.02.2004 nadejda - группировка клиентов по РКО
*/

/*Программа по формированию отчета по остаткам клиента ГО на конец месяца за 
период с 01.01.01 по тек дату.
Заметим, что аналогичная программа на базе Астаны отлична от этой (r-cli2.p), 
тк там база начала функциионировать с августа
copyright 12/09/01 Popova Natalya

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

{global.i}

def stream nur. 
def var lastday$ as date.
def var v-dtb as date.
def var i as int init 1.
def var g as int. 
def var ff as date extent 14 .
def var bal as decimal extent 14. 
def var flg as logical init false.
def var flg2 as log init false.
 
def var chief as char.
def var sek-ek as char.
def var tel as char.
def var v-dep as integer.


find last cls no-lock.
lastday$ = cls.whn.
g = month(lastday$).


find ofc where ofc.ofc = g-ofc no-lock no-error.
v-dep = ofc.regno mod 1000.

find first cmp no-lock no-error.

display "   Ждите...   "  with row 5 frame ww centered .


do i = g to 12:
  ff[i - g + 1] = date (i, 1, year(lastday$) - 1).
end.
ff[12 - g + 2] = date (12, 31, year(lastday$) - 1).
do i = 2 to g:
  ff[12 - g + 1 + i] = date (i, 1, year(lastday$)).
end.

/*-----------------*/

v-dtb = date(g, 1, year(lastday$) - 1).

output stream nur to rpt.img.
put stream nur skip
string( today, "99/99/9999" ) + ", " +
string( time, "HH:MM:SS" ) + ", " +
trim( cmp.name )                               format "x(79)" at 02 skip(1).

put stream nur skip 
" ОТЧЕТ ПО ОСТАТКАМ КЛИЕНТОВ НА НАЧАЛО МЕСЯЦЕВ " format "x(50)" at 22 skip
"ЗА ПЕРИОД С " v-dtb format "99/99/9999" "  ПО " format "x(30)" at 30 
space(2) lastday$ format "99/99/9999".
put stream nur skip(2) "Счет" format "x(7)" space(4) 
                      "Валюта" format "x(9)" space(6).

do i = 1 to 13:
  put stream nur  "На " ff[i] format "99/99/99" space(7). 
end.

put stream nur skip fill( "-", 807 ) format "x(77)" skip(1).

for each cif where cif.type = "b" no-lock break by cif.jame: 
   if cif.jame = "" then next.

   if v-dep <> 1 and integer(cif.jame) mod 1000 <> v-dep then next.

   if first-of(cif.jame) then do:
      put stream nur unformatted skip(1) "Департамент : ". 
      find ppoint where ppoint.depart = integer(cif.jame) mod 1000 no-lock no-error.
      if avail ppoint then 
        put stream nur unformatted ppoint.name.
      else 
        put stream nur unformatted "неизвестен".
      put stream nur unformatted skip fill("-", 40) format "x(40)" skip.
   end.
   
   find sub-cod where  sub-cod.sub = "cln" and sub-cod.acc = cif.cif and
        sub-cod.d-cod = "clnsts" /*выбираем только юр лица */
         no-lock no-error.
   if available sub-cod and sub-cod.ccode = "0" then do:
     find sub-cod where  sub-cod.sub = "cln" and sub-cod.acc = cif.cif and
        sub-cod.d-cod = "clnchf" no-lock no-error.
     if avail sub-cod then chief = sub-cod.rcode. 
                      else chief = "".
     find  sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and
       sub-cod.d-cod = "ecdivis" no-lock no-error.
     if avail sub-cod then sek-ek = sub-cod.ccode. 
                      else sek-ek = "".
   end. /*if available*/ 
   else next. 

 
   for each aaa no-lock where aaa.cif = cif.cif and  aaa.sta <> "C" break by aaa.crc: 
     if aaa.sta = "C" or substr(aaa.aaa, 4, 3) = "140" then next.

     flg = false.
     find crc where crc.crc = aaa.crc no-lock.

     do i = 1 to 13 :
       find last aab where aab.aaa = aaa.aaa and aab.fdt < ff[i] no-lock no-error. 
       if available aab then do:
         bal[i] = aab.bal.
         if bal[i] > 0 then flg = true.
       end.  
     end. /*do*/

     if  flg2 = false and flg = true then do:
         find codfr where codfr.codfr = "ecdivis" and codfr.code = sek-ek no-lock no-error.
         put stream nur skip(2)  
           trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(60)" space(2) 
           cif.addr[1] format "x(30)" space(3) 
           "Тел." space(2) cif.tel  format "x(20)" skip 
         chief format "x(60)" space(2) "Деят-ть компании:" space(1) if avail codfr then codfr.name[1] else "" format "x(40)" skip. 
         flg2 = true.
     end.


     if flg then  
       put stream nur space(3) 
          aaa.aaa format "x(9)"space(2) crc.code format "999"
          space (2) 
          bal[1] format "-zz,zzz,zzz,zz9.99" 
          bal[2] format "-zz,zzz,zzz,zz9.99" 
          bal[3] format "-zz,zzz,zzz,zz9.99" 
          bal[4] format "-zz,zzz,zzz,zz9.99"
          bal[5] format "-zz,zzz,zzz,zz9.99"  
          bal[6] format "-zz,zzz,zzz,zz9.99"
          bal[7] format "-zz,zzz,zzz,zz9.99"  
          bal[8] format "-zz,zzz,zzz,zz9.99"
          bal[9] format "-zz,zzz,zzz,zz9.99"  
          bal[10] format "-zz,zzz,zzz,zz9.99"
          bal[11] format "-zz,zzz,zzz,zz9.99"
          bal[12] format "-zz,zzz,zzz,zz9.99"
          bal[13] format "-zz,zzz,zzz,zz9.99"
          skip.
     do i = 1 to 14: 
         bal[i] = 0. 
     end.
   end. /*break by aaa*/                                                          
   flg2 = false. 
end. /*break by cif*/                                                           


output stream  nur close.

if not g-batch then do:
    pause 0 before-hide.                  
    run menu-prt( "rpt.img" ).
    pause 0 no-message.
    pause before-hide.
end.
                                                                           
