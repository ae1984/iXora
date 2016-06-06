/* ciflist_def.p
 * MODULE
        Список клиентов
 * DESCRIPTION
        Список клиентов с их контактами (Физ./ юр. лиц)
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
        30/06/2010 Aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        24/06/2011 dmitriy - добавил столбцы ФИО Дир., ФИО Бух., в столбце Наименование компании - сокращенную форму собственности
        15/03/2012 id00810 - закомментировала VBANK = ''  в цикле по cif (ошибка)
*/


def input parameter d1 as date no-undo.
DEF VAR VBANK AS CHAR.
def shared temp-table wrk1 no-undo
     FIELD BANK AS CHAR
     FIELD w-cif as char
     FIELD w-name as char
     FIELD w-tel as char
     FIELD w-t1 as char
     FIELD w-t2 as char
     FIELD w-addr1 as char
     FIELD w-addr2 as char
     FIELD w-c as char
     FIELD w-mail as char
     FIELD dir as char
     FIELD buh as char.

def var v-dir as char.
def var v-buh as char.

/*VBANK = ''.
v-dir = ''.
v-buh = ''.*/

FIND FIRST TXB.SYSC WHERE TXB.SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
    IF AVAIL TXB.SYSC AND TXB.SYSC.CHVAL <> '' THEN VBANK =  TXB.SYSC.CHVAL.
FOR EACH txb.cif no-lock:

if trim(txb.cif.name) <> ' ' then do:
        CREATE wrk1.
        wrk1.w-cif = txb.cif.cif.

    find first txb.cif-mail where txb.cif-mail.cif = txb.cif.cif no-lock no-error.
        If avail txb.cif-mail then wrk1.w-mail = txb.cif-mail.mail.

    find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and
                             txb.sub-cod.sub = 'cln' and
                             txb.sub-cod.d-cod = 'clnbk' and
                             txb.sub-cod.ccod = 'mainbk' no-lock no-error.
    if avail txb.sub-cod then v-buh = txb.sub-cod.rcode.

    find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and
                             txb.sub-cod.sub = 'cln' and
                             txb.sub-cod.d-cod = 'clnchf' and
                             txb.sub-cod.ccod = 'chief' no-lock no-error.
    if avail txb.sub-cod then v-dir = txb.sub-cod.rcode.

            wrk1.w-name = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).
            wrk1.w-tel = txb.cif.tel.
            wrk1.w-t1 = txb.cif.fax.
            wrk1.w-t2 = txb.cif.tlx.
            wrk1.w-addr1 = txb.cif.addr[1].
            wrk1.w-addr2 = txb.cif.addr[2].
            wrk1.BANK = VBANK.
            wrk1.dir = v-dir.
            wrk1.buh = v-buh.

        /*    VBANK = ''.*/
            v-dir = ''.
            v-buh = ''.
    end.
end.

output close.

