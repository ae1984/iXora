/* kd.i
 * MODULE
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
     Обязательна для всех программ кредитного досье      
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
        01.03.2005 marinav
 * CHANGES

    20.05.03 кредитное досье

    05.01.2004
    13.01.2004
    16.01.2004
    24.03.2005 добавлен номер мониторинга
    19/09/2005
    30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов
*/

/* номер текущего клиента и досье */
define {1} shared var s-kdcif like kdcif.kdcif. 
define {1} shared var s-kdlon like kdlon.kdlon. 
define {1} shared var s-nom like kdcifhis.nom.

/* для pksysc */
define {1} shared var s-credtype as char.
s-credtype = '0'.

/* каталог временных файлов на локальной машине юзера */
define {1} shared var s-tempfolder as char.

/* текущий банк */
{comm-txb.i}
define {1} shared var s-ourbank as char.
s-ourbank = comm-txb().



