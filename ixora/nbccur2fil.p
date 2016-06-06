/* nbccur2fil.p
 * MODULE
        Системные параметры
 * DESCRIPTION
        Копирование курсов валют НБ и истории на филиалы при изменениях в головном
 * RUN

 * CALLER
        nbccur.p
 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-2-2
 * AUTHOR
        21.11.2002 nadejda
 * BASES
        BANK TXB COMM
 * CHANGES
   21.08.2008 id00024 - добавил g-today
   08.04.2011 damir   - убрал AST, добавил в BASES TXB.
*/

define shared var g-today as date. /* id00024 */

{curs2fil.i
&head = "ncrc"
&run = " "
}
