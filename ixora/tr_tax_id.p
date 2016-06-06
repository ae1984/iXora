/* tr_tax_id.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19/09/2006 Evgeniy u00568
 * CHANGES
*/

TRIGGER PROCEDURE FOR Create OF tax.

  tax.id = next-value(seq_tax_id).
