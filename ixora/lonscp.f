/* lonscp.f
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
        04/05/06 marinav Увеличить размерность поля суммы
*/

/* lonscp.f
   30-08-94
*/
form lnsch.schn format "x(9)" label "Nr"
     lnsch.stdat label "Дата"
     lnsch.stval format ">,>>>,>>>,>>9.99" label "Сумма"
     lnsch.comment label "Примечание"
   with overlay no-hide column 5 row 8 7 down
   title "Календарь возврата кредита | Всего: " + trim(svopnamt) 
   frame lonscp.
form "1)Клнд.выплаты проц. 2) Клнд.выдачи. 3) Изм.суммы.  4) Ежемес.погашение" 
   with overlay column 6 row 19 no-box color messages frame msgh.
