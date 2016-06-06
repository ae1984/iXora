/* r-cli2.p
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

/*Программа по формированию отчета по остаткам клиента филиала на конец 
месяца за  начала функционирования базы (авг 2001) по тек дату.
Заметим, что аналогичная программа на базе Алматы отлична от этой (r-cli.p), 

copyright 12/09/01 Popova Natalya

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/


def stream nur. def var lastday$ as date.
def var i as int init 1.
def var g as int. 
def var ff as date extent 14 .
def var bal as decimal extent 14. 
def var flg as logical init false.
def var flg2 as log init false.
 
def var chief as char.
def var sek-ek as char.
def var tel as char.

output stream nur to rpt.img.
find last cls.
lastday$ = cls.whn.
g = month(lastday$).

{global.i new}

find last  cls no-lock no-error.
find first cmp no-lock no-error.
/*g-today = if available cls then cls.cls + 1 else today.
 */
display '   Ждите...   '  with row 5 frame ww centered .
put stream nur skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name )                               format 'x(79)' at 02 skip(1).
/* 'Исполнитель: ' + trim( ofc.name )             format 'x(79)' at 02 skip(2).
 */

put stream nur skip 
" ОТЧЕТ ПО ОСТАТКАМ КЛИЕНТОВ НА НАЧАЛО МЕСЯЦЕВ " format 'x(50)' at 22 skip
'ЗА ПЕРИОД С 01/09/01  ПО ' format 'x(30)' at 30 
space(2) lastday$.
put stream nur skip(2) "Счет" format 'x(7)' space(4) 
                      "Валюта" format 'x(9)' space(5) 
                      /*"На 01.01.00" space(2) */
                      "На 01.09.01 " "На" space(1) lastday$ skip . 

put stream nur ' ' fill( '-', 807 ) format 'x(77)' skip(1).



do i = 1 to g - 7:
find last cls where month(cls.whn) = i + 7 and year(cls.whn) = 2001 
     no-lock no-error.
 ff[i] = cls.whn.
end.
/*-----------------*/


for each cif where cif.type = 'b'/* break by cif.cif*/: 
 for each aaa  where aaa.cif = cif.cif and  aaa.sta <> 'C' break by aaa.crc: 
  flg = false.

 find sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
      sub-cod.ccode matches '*0*' and sub-cod.d-cod matches '*clns*' /*выбираем только юр лица */
       no-lock no-error.
  
 if available sub-cod then do:
    hide message no-pause.
    find sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
       sub-cod.d-cod matches '*clnc*' no-lock no-error.
       chief = sub-cod.rcode. 
    find  sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
      sub-cod.d-cod matches '*ecdi*' no-lock no-error.
      sek-ek = sub-cod.ccode. 
  end. /*if available*/ 
  else do:
   next. end.
 hide message no-pause.
find crc where crc.crc = aaa.crc.
find codf where codf.codfr = 'ecdivis' and codf.code = sek-ek.  
      /*-------------*/

   If aaa.sta <> 'C' and substr(aaa.aaa,4,3) <> '140' then do:
   do i= 1 to g - 7 :
    find aab where aab.aaa = aaa.aaa and aab.fdt = ff[i] no-lock no-error. 
        if available aab then do:
         bal[i] = aab.bal.
          if bal[i] > 0 then flg = true.
        end.  
     if not available aab  then  do:
       find last aab where aab.aaa = aaa.aaa and aab.fdt <= ff[i] and             month(aab.fdt) = i no-lock no-error.  
       if available aab then bal[i] = aab.bal.
       if bal[i] > 0 then flg = true.
      end.
    end. /*do*/

  if  flg2 = false and flg = true then do:
      put stream nur skip(2)  trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(30)' space(2) cif.addr[1] 
        format 'x(30)'space(3) 'Тел.' space(2) cif.tel  format 'x(20)' skip 
         chief format 'x(30)' space(2) 'Деят-ть компании:' space(1) codf.name[1] format 'x(40)' skip. 
      flg2 = true.
  end. /*if firt-of*/


    if flg = true  then  put stream nur space(3) /*aaa.cif format 'x(7)'*/ 
         aaa.aaa format 'x(9)'space(2) crc.code format '999'
  space (2) bal[1] format "->>,>>>,>>9.99" 
            bal[2] format "->>,>>>,>>9.99" 
            /*bal[3] format "->>,>>>,>>9.99"
            bal[5] format "->>,>>>,>>9.99"  bal[6] format "->>,>>>,>>9.99"
       */
       skip.
     do i= 1 to 5: 
        bal[i] = 0. 
     end.
    end. /* <> '140'*/
  
  end. /*break by aaa*/                                                          flg2 = false. 
 end. /*break by cif*/                                                           


 output stream  nur close.

if not g-batch then do:
    pause 0 before-hide.                  
    run menu-prt( 'rpt.img' ).
    pause 0 no-message.
    pause before-hide.
     end.
                
