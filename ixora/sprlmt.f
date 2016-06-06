/* sprlmt.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Настройки кредитного модуля
        Форма редактирования справочника кредитных лимитов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12-1-2-9-4 
 * AUTHOR
        27.12.2005 Natalya D.
 * CHANGES
   
*/


form
     lonlimit.id format ">>9" label "ID"
     lonlimit.longrp format ">>9" label "КОД"
       help " Код группы"
     lonlimit.lnsegm  label "ПРИЗНАК"
       help " Код признака кредита"    
     lonlimit.lonsec label "КОД " 
       help " Код залога " 
     lonlimit.des format "x(40)" label "ВИД КРЕДИТА"
       help " Название !"
     lonlimit.amt_usd  label "СУММА"
     with row 5 centered scroll 1 12 down frame f-ed .
