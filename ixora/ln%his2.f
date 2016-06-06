/* ln%his2.f
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
        03/08/2004 tsoy   - добавил в сохранение истории новые параметры ( Коммисисия за кред.линию, Пролонгация 1, 
                                                                           Пролонгация 2, Валюта индексации, Курс договора)
*/

def var nul as char format "x(1)".
form ln%his.f0      label "Нм"
     nul            label "<"
     ln%his.long2   label "Пролонг2" format "99/99/99"
     ln%his.lcnt    label "Договор"
     ln%his.gua     label "Вид"
     ln%his.grp     label "Грп"      format "z9"
     ln%his.pnlt1   label "Штр%(в)"  format "z9.99"
     ln%his.pnlt2   label "Штр%(о)"  format "z9.99"
     ln%his.comln   label "Комм"     format "z9.99"
     ln%his.drate   column-label "Курс"      
     ln%his.kcrc    label "Вал"      format "z9"
   with centered overlay no-hide row 10 7 down
   title "История изменения параметров кредита"
   frame ln%his2.

form "Исполнитель: " ln%his.who "  Дата изменения : " ln%his.whn    
   with overlay no-label no-box color messages column 3 row 21 frame ln%hism.
