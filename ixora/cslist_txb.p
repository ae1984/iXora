  /* cslist_txb.p
 * MODULE
        Электронный кассир
 * DESCRIPTION
        Добавить ЭК в справочник для привязки к ARP Счету
 * BASES
         COMM TXB
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
        24.02.2011 marinav
 * CHANGES
*/

   def input param v-code as char.
   def input param v-name as char.

    create txb.codfr.
    assign txb.codfr.codfr = 'arptype' txb.codfr.code = v-code txb.codfr.level = 1 txb.codfr.child = no txb.codfr.name[1] = v-name .
