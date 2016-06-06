/* pensown.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Пенсионные платежи
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        13/01/05 kanat
 * CHANGES
   30/06/06 u00568 Evgeniy - по тз 369 пенсионные платежи отправляем в ГЦВП
*/

/*0 - платежи в ГЦВП*/
/*1 - платежи в пенсионный фонд*/
run penslist (false, 15, 0).
