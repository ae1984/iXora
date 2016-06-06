/*  kzn_st1.p
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
        22/07/04 dpuchkov
 * CHANGES
        03/08/04 dpuchkov - убрал округление курсов при отображении
*/
def var str_p as char.
define frame getlist1
   crclg.crcpok label "Курс покупки" skip
   crclg.crcprod label "Курс продажи" skip

   crclg.name label "Клиент" skip
   crclg.sum label "Сумма." skip
   crclg.dateb label "Дата действия"  skip
   crclg.lock label "Блокировать" skip
   crclg.dep  label "СПФ" skip
   crclg.whn label "Дата"   skip
   crclg.crcpr label "Валюта" format '99' skip
with side-labels centered row 8.

on help of crclg.dep in frame getlist1 do:
  str_p = "".
  for each ppoint no-lock by ppoint.depart:
    str_p = str_p + string (ppoint.depart) + ". " + ppoint.name + "|".
  end.
  str_p = SUBSTR (str_p, 1, LENGTH(str_p) - 1).
  run sel ("Выберите департамент", str_p).
  crclg.dep = int(return-value).
  display crclg.dep with frame getlist1.
end.

on help of crclg.crcpr in frame getlist1 do:
/*  run help-crc1.
    crclg.crcpr = int(frame-value). 
    display crclg.crcpr with frame getlist1. */
end.

{yes-no.i}
{global.i}

def shared var v-crclgt as decimal.

DEFINE QUERY q1 FOR crclg.

define buffer buf for crclg.

def browse b1
     query q1 
     displ 
     crclg.crcpok label "Курс пок."    

     crclg.crcprod label "Курс прод." 
     crclg.name label "Клиент" format 'x(12)'
     crclg.sum label "Сумма." 
/*   crclg.dateb label "Срок дейст."  */
     crclg.lock label "Блокир." 
     crclg.dep  label "СПФ:" format '99'  
     crclg.crctxt label "Валюта" 
 
     with 7 down title "Льготные курсы обмена." overlay.


DEFINE BUTTON bedt LABEL "Свойства".         
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 
     skip
     bedt
     bext with centered overlay row 5 top-only.  


ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.


ON CHOOSE OF bedt IN FRAME fr1
do:
   find buf where rowid (crclg) = rowid (buf) exclusive-lock.
   displ crclg.crcpok crclg.crcprod crclg.name crclg.sum crclg.dateb crclg.lock crclg.dep crclg.whn crclg.crcpr with frame getlist1.
   if crclg.crcpr = 1 then crclg.crctxt = "KZT". else
   if crclg.crcpr = 2 then crclg.crctxt = "USD". else
   if crclg.crcpr = 4 then crclg.crctxt = "RUR". else
   if crclg.crcpr = 11 then crclg.crctxt = "EUR". else
      crclg.crctxt = "".

   close query q1.
   open query q1 for each crclg.
   browse b1:refresh().
end.

open query q1 for each crclg . 


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

