/* csavans2.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Выдача аванса кассирам РКО - подотчет
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        29/01/04 sasco
 * CHANGES
        05/02/04 sasco Добавил код валюты через &CRC
        11/03/04 sasco вынес &LABEL, &ARP_DESCR, &HTML в переменную
        28/11/05 suchkov добавил вставку даты выдачи в детали платежа
        04/05/2012 evseev - изменил путь к логотипу
*/

define variable v-label as character initial "Подотчет".
define variable v-arpdescr as character initial "подотчет для обменных операций".
define variable v-html as character initial "Для обменных операций в сберегательной кассе".

{csavans.i

 &LABEL = v-label

 &FORMAT = "z,zzz,zz9.99"

 &SYSC = "CASDP2"

 &CRC = 1

 &LOOKUP_SYSC = " if lookup (trim(string(v-dep, ""zzz9"")), sysc.chval) = 0 then next. "

 &SUB-COD = "obmen1003"

 &ARP_DESCR = v-arpdescr

 &INITSUM = 100000

 &SUM = 100000

 &ASKSUM = "yes"

 &TRANSACTION = "
      run trx (
               5,
               tmp.sum,
               1,
               '',
               tmp.arp,
               '100100',
               '',
               'Выдача подотчетной суммы для обм.операций, на ' + string(tmp.dat) + ', ' + tmp.fio,
               '14',
               '14',
               '890'
              ).
              "

 &CAS_SYMB = "560"

 &NUM_ORDERS = "3"

 &ZAYAV_HTML = v-html


}

