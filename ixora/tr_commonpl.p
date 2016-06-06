/* tr_commonpl.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        24/08/2006 Evgeniy u00568
 * CHANGES
*/

TRIGGER PROCEDURE FOR Create OF commonpl.

  commonpl.id = next-value(seq_commonpl).
