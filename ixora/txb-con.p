/* txb-con.p
 * MODULE
        connect to txb
 * DESCRIPTION
        Список контрактов клиента
 * RUN

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24/11/2010 aigul
 * BASES
        BANK COMM

 * CHANGES
        18/11/2010 aigul - сделала отчет консолидированным и добавила выбор всех типов контракта
*/
find first comm.txb where comm.txb.consolid = true and comm.txb.bank = 'txb00' no-lock no-error.
 connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).