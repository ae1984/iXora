/* st-poz.i
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
 * BASES
        BANK 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       14.04.2006 nataly перевела на базу BANK
*/


def {1} shared temp-table st-poz 
        field  crc      as inte format ">9"   column-label "Валюта"
        field  crccode  as char format "x(3)" column-label "Вал.наим"
        field  arppras  as deci format "zzz,zzz,zzz,zz9.99-" 
               column-label "Требован"
        field  arpsaist as deci format "zzz,zzz,zzz,zz9.99-"
               column-label "Обязател."
        field  arpus  as deci format "zzz,zzz,zzz,zz9.99-" 
               column-label "Требован"
        field  arpeu  as deci format "zzz,zzz,zzz,zz9.99-" 
               column-label "Требован"
        field  arpru  as deci format "zzz,zzz,zzz,zz9.99-" 
               column-label "Требован"
        field  crcrate  as deci format "zzz,zzz.9999" 
        column-label "Вал.курс " extent 0
        field  crcnom   as deci format "zzz,zzz.9999" 
        column-label "Вал.номин"  extent 0
               .

def {1} shared variable v-kap as deci format "z,zzz,zzz,zzz,zz9.99-"
        label "Капитал ".
def {1} shared variable v-iest as char  label "Учережд"  format "x(80)".
def {1} shared variable v-adr  as char  label "Адрес "   format "x(80)".
/*15.11.99 buru*/
def {1} shared variable v-add as deci .

        
        
        
