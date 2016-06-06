/* tr_almatv.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        03/10/2006 Evgeniy u00568
 * CHANGES
*/

TRIGGER PROCEDURE FOR Create OF almatv.

  almatv.id = next-value(seq_almatv).
