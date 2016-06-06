/* s-secamt.p
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
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        07.10.2005 marinav изменена форма
        01/03/2011 madiyar - изменена форма
        18/07/2011 kapar - ТЗ 948
        18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониториг залогов - переоценка" отключен функционал по мониторингу
*/

define shared variable s-lon    as character.
define shared variable g-today  as date.
define shared variable m-ln as integer .

define frame colla skip(1)
    lonsec1.prm           label "Обеспечение" VIEW-AS EDITOR SIZE 83 by 10
                          help "Наименование; F1,F4-далее" skip(1)
    lonsec1.vieta         label "Адрес      " VIEW-AS EDITOR SIZE 83 by 3
                             help "Место нахождения; F1,F4-далее" skip(1)
    lonsec1.pielikums[3]  label "Оценка     " VIEW-AS EDITOR SIZE 83 by 3 skip(2)
    with overlay width 100 side-labels column 2 row 2 title
         "Ввод описания обеспечения" .
/*message 'F1 - Сохранить, F4 - Выход, F5 - Мониторинг, F6 - История '.*/
message 'F1 - Сохранить, F4 - Выход '.

find first lonsec1 where lonsec1.lon = s-lon and lonsec1.ln = m-ln exclusive-lock.

   display lonsec1.prm
           lonsec1.vieta
           lonsec1.pielikums[3]
           with frame colla.
   update  lonsec1.prm
           lonsec1.vieta
           lonsec1.pielikums[3]
           /*go-on("PF4","F5","F6")*/
           go-on("PF4")
           with frame colla.

     lonsec1.who = userid("bank").
     lonsec1.whn = g-today.

/*Мониторинг*/
/*
if lastkey = keycode("F5") then do:
  run chk-clnd.
  run s-secamt.
end.
*/
/*История стоимость в результате переоценки*/
/*
if lastkey = keycode("F6") then do:
  define frame stvp skip(1)
    lnmonsrp.pdt      label "График"
    lnmonsrp.zname     label "Обеспечение"
    lnmonsrp.crc       label "Валюта"
    lnmonsrp.nsum      label "Сумма"
    with row 2 overlay title "Стоимость в результате переоценки" .
  for each lnmonsrp where lnmonsrp.lon = s-lon and lnmonsrp.num = m-ln  no-lock:
    display
      lnmonsrp.pdt
      lnmonsrp.zname
      lnmonsrp.crc
      lnmonsrp.nsum
      with frame stvp.
  end.
  pause.
  run s-secamt.
end.
*/
hide frame colla.
readkey pause 0.
/*-----------------------------------------------------------------------------
  #3.
     1.izmai‡a - forma papildin–ta ar klienta re¦istr–cijas apliecЁbas numuru"
       un datumu
-----------------------------------------------------------------------------*/
