/* csavans3.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Выдача аванса кассирам крупных РКО - обменник по 100200, все валюты
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        05/02/04 sasco
 * CHANGES
        11/03/04 sasco назначение платежа разделено на аванс касс. операций и
                       подотчет для обм. операций
        26/03/04 sasco печатается только один экземпляр расходного ордера
        28/11/05 suchkov добавил вставку даты выдачи в детали платежа
        04/05/2012 evseev - изменил путь к логотипу
*/



define variable v-crc as integer initial 1.
define variable choice as integer. /* аванс = 1 или подотчет  = 2 */

define variable v-arpdescr as character.
define variable v-trx as character.
define variable v-html as character.

update v-crc format "z9" label "Введите код валюты"
       with row 2 centered overlay side-labels frame getcrc.
hide frame v-crc.

choice = 0.
run sel2 ("", "Аванс для кассовых операций|Подотчет для обменных операций", output choice).
if choice = 0 or choice = ? then do:
   message "Ошибка выбора!" view-as alert-box title "".
   return.
end.

if choice = 1 then assign v-arpdescr = "аванс для кассовых операций"
                          v-trx = "Выдача авансовой суммы для касс. операций, "
                          v-html = "Для кассовых операций "
                          .
              else assign v-arpdescr = "подотчет для обменных операций"
                          v-trx = "Выдача подотчетной суммы для обм.операций, "
                          v-html = "Для обменных операций "
                          .

{csavans.i

 &LABEL = "Сумма"

 &FORMAT = "zzz,zzz,zz9.99"

 &SYSC = "CASDP3"

 &CRC = v-crc

 &LOOKUP_SYSC = " if lookup (trim(string(v-dep, ""zzz9"")), sysc.chval) = 0 then next. "

 &SUB-COD = "obmen1002"

 &ARP_DESCR = v-arpdescr

 &INITSUM = 0

 &SUM = 0

 &ASKSUM = "no"

 &TRANSACTION = "
      run trx (
               5,
               tmp.sum,
               v-crc,
               '',
               tmp.arp,
               '100100',
               '',
               v-trx + 'на ' + string(tmp.dat) + ', ' + tmp.fio,
               '14',
               '14',
               '890'
              ).
              "

 &CAS_SYMB = "560"

 &NUM_ORDERS = "1"

 &ZAYAV_HTML = v-html

}

