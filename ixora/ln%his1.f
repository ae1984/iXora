/* ln%his1.f
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
form ln%his.f0      label "Нм."
     ln%his.stdat   label "Дата"        format "99/99/99"
     ln%his.rdt     label "Дата нач"    format "99/99/99"
     ln%his.duedt   label "Дата оконч." format "99/99/99"
     ln%his.opnamt  label "Сумма кредита" format "z,zzz,zzz,zz9.99"  
     ln%his.intrate label "%Ставка"     format "zz9.99"
     ln%his.long1   label "%Пролонг1"   format "99/99/99"
     nul label ">"
   with centered overlay no-hide row 10 7 down
   title "История изменения параметров кредита"
   frame ln%his1.
form "Исполнитель: " ln%his.who "  Дата изменения : " ln%his.whn    
   with overlay no-label no-box color messages column 3 row 21 frame ln%hism.
