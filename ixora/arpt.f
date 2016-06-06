/* arpt.f
 * MODULE
        Настройка ARP  и тарифов
 * DESCRIPTION
        Настройка ARP  и тарифов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2-7-6
 * AUTHOR
        19/09/05 nataly
 * CHANGES
        20/09/2013 Luiza    - ТЗ 1916 изменение поиска записи в таблице tarif2
*/

form arptarif.arp validate(can-find( arp no-lock where arp.arp = arptarif.arp  ), 'Счет ARP не найден !') column-label "ARP"
     arptarif.kod validate (can-find( tarif2 no-lock where  tarif2.str5  = trim(arptarif.kod) /*tarif2.num = substr(arptarif.kod,1,1) and tarif2.kod = substr(arptarif.kod,2,2)*/  ) , 'Тариф не найден! ')
    format "x(3)" column-label "Код"
        with  /*COLUMN 1*/ row 6  down centered frame cods.
