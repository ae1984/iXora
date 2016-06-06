/* h-dolgs.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма к списку документов должников
 * RUN
        15.1. меню - Долги
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24/06/04 saltanat
 * CHANGES
        27.12.2010 aigul -  изменила вывод дат
*/

form
   /*vcdolgs.dnvn format "99/99/99" LABEL "ДАТА ВНЕС."
   vcdolgs.pdt format "99/99/99" LABEL "ДАТА ПОГАШ.ДОЛГА"*/
   vcdolgs.dndate format "99/99/99" LABEL "ДАТА"
   vcdolgs.pdt format "99/99/99" LABEL "ДАТА ВОЗВРАТА"
   codfr.name[2] format "x(6)" LABEL "ТИП"
   vcdolgs.dnnum format "x(25)" LABEL "ДОК. НОМЕР"
   vcdolgs.sum format ">>>,>>>,>>>,>>9.99" LABEL "Сумма"
   with width 80 row 4 centered scroll 1 12 down overlay frame h-dolgs.
