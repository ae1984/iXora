/* v-crcard.f
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

/* v-crcard.f
   comes from program v-crcard.p
*/

form "      Card Number - " crcard.crcard  skip
     "   Account Number - " crcard.crdt    skip
     "           Holder - " crcard.lname crcard.mname crcard.fname skip
     "         Relation - " crcard.relation skip
     "      Expire Date - " crcard.expdt     skip
     "           Status - " vrem              skip
     with frame crcdac row 7 centered overlay top-only 1 down no-label
	  title " ACCOUNT QUERY ".
