/* almtv.p
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
        10/10/05 ten
 * CHANGES
*/

def var v-alm as char label "Введите Фамилию" format "x(12)".
def var v-alm1 as char label "Имя,Отчество" format "x(22)".
def var v-tot as char label "ФИО" format "x(10)".
def var v-acc like almatv.acc  label "Контракт" format "->>>>>>>9".
def var v-flat like almatv.flat label "Квартира" format "x(4)".
def var v-addr like almatv.address label "Адрес" format "x(10)".
def var v-house like almatv.house label "Дом" format "x(10)".


def query q1 for almatv scrolling.

def browse br1 query q1 no-lock
disp almatv.accnt label "Номер" almatv.f + " " + almatv.io label "ФИО" format "x(22)" substring(almatv.address,1,10) label "Улица" format "x(12)" substring(almatv.house,1,4) label "Дом" format "x(5)" substring(almatv.flat,1,3)  label "Квартира" format "x(4)"    with 10 down  separators  title " Просмотр абонентов Алма ТВ" .

def frame fr1
      v-addr v-house v-flat v-tot v-acc with 1 column at row 5 column 38 centered.

define frame fr2
   br1  /*help "Нажмите ""ENTER"" для просмотра контракта!" */ WITH 1 column at row 5 column 38  centered. 



update v-alm v-alm1 with frame fr centered. 

hide frame fr.
IF  v-alm1 <> "" then  do:
    if substring (v-alm1,1,1) <> "*" then 
    v-alm1 = "*" + v-alm1 + "*".
    open query q1 for each almatv where almatv.f = v-alm  and almatv.io matches v-alm1.
/*
    on  "enter" of browse br1 do:
         hide frame fr2.
         v-tot = v-alm + " " + almatv.io.
         v-acc = almatv.acc.
         v-addr = almatv.address.
         v-house = almatv.house.
         v-flat = almatv.flat.
         disp    v-addr v-house v-flat v-tot v-acc with frame fr1. pause.
         hide frame fr1.
         view frame fr2.
    end.
*/
    enable all with frame fr2.
    wait-for window-close of frame fr2 focus browse br1.

end.
else do:
     v-tot = "".
     open query q1 for each almatv where almatv.f = v-alm.
/*
     on  "enter" of browse br1 do:
         hide frame fr2.
         v-tot = v-alm + " " + almatv.io.
         v-acc = almatv.acc.
         v-addr = almatv.address.
         v-house = almatv.house.
         v-flat = almatv.flat.
         disp   v-addr v-house v-flat v-tot v-acc with frame fr1. pause.
         hide frame fr1.
         view frame fr2.
     end.
*/

     enable all with frame fr2.
     wait-for window-close of frame fr2 focus browse br1.

end.


