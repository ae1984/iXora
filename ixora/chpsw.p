/* chpsw.p
 * MODULE
        Администрирование ПРАГМЫ
 * DESCRIPTION
        Смена пользователем своего пароля
 * RUN
        
 * CALLER
        главное меню
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-8
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        05.11.2003 nadejda  - validate на значение пароля, запрос на подтверждение
        11.11.2003 nadejda  - собственно смена пароля вынесена в chpsw0.p, чтобы можно было вызвать ее из nmenu.p
*/

/* Changing password prosedure*/

{mainhead.i}

def var v-newpswd as logical.

run chpsw0 (yes, output v-newpswd).  /* вызов с параметром "запрашивать подтверждение на изменение" */

