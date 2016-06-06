/* point.f
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
        07/11/07 marinav - добавила поле termlist где пишется обслуживающий банк для договора Микрокредита
*/

point.point label 'ПУНКТ' skip
point.name label 'НАЗВАНИЕ' skip 
point.regno label 'РЕГИСТР.Nr' skip 
point.licno label 'ЛИЦЕНЗИЯ Nr' skip
point.nalno label 'НАЛОГОВ. Nr' skip
point.addr[1] label 'АДРЕС' skip 
point.addr[2] label 'АДРЕС' skip 
point.addr[3] label 'АДРЕС' skip 
point.contact label 'РУКОВОДИТЕЛЬ' skip 
point.tel label 'ТЕЛЕФОН' 
