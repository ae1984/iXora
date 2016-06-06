/* lonavn-p2.f
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

/* lonavn-p2.f
   28-11-94
*/
form lonlizjl.jh  label  'TRX'
     lonlizjl.gl  label  'G.G.konts'
     lonlizjl.jdt label  'Datums'
     lonlizjl.crc label  'Val­ta'
     lonlizjl.acc label  'Konts'
     lonlizjl.amt format '>>>,>>>,>>9.99' label 'Summa'
     lonlizjl.dc  format 'xxx' label 'D/K'
     lonlizjl.who label  'Darb.'
with centered overlay no-hide row 7 10 down
frame lonavn-p2.

