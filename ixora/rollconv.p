/* rollconv.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        IB COMM TXB
 * AUTHOR
        09/10/09 id00004
*/

def input  parameter v-rmz        as char .
def output parameter v-payval as char no-undo.




 find last txb.dealing_doc where txb.dealing_doc.DocNo = v-rmz exclusive-lock no-error.
 if avail txb.dealing_doc and txb.dealing_doc.jh = ? then do:
    delete  txb.dealing_doc.
    release txb.dealing_doc.
    v-payval = "ok" .
 end.

