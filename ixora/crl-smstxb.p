/* crl-smstxb.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Статус SMS-информирования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16.2.2.10
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        28.05.2013 damir - Внедрено Т.З. № 1819.
*/
def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table t-wrk no-undo
    field cif as char
    field fio as char
    field iin as char
    field tell as char
    field state as char
    field pdate as date
    field ptime as inte
    field pwho as char
    field batchid as inte.

def buffer b-smspool for comm.smspool.
def buffer b-cif for txb.cif.

def var stss as char no-undo extent 4 init ['отправлено','на отправке','на отправке','ошибка отправки'].
def var v-ourbnk as char.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).
else do: message "This isn't record OURBNK in txb.sysc file !!!" view-as alert-box. return. end.

for each b-smspool where b-smspool.pdate ge v-dtb and b-smspool.pdate le v-dte and b-smspool.source = "CredLimit" no-lock:
    if b-smspool.bank ne v-ourbnk then next.
    find first b-cif where b-cif.cif = b-smspool.cif no-lock no-error.
    if not avail b-cif then next.

    create t-wrk.
    t-wrk.cif = b-smspool.cif.
    t-wrk.fio = trim(b-cif.name).
    t-wrk.iin = b-cif.bin.
    t-wrk.tell = b-smspool.tell.
    t-wrk.state = stss[b-smspool.state + 1].
    t-wrk.pdate = b-smspool.pdate.
    t-wrk.ptime = b-smspool.ptime.
    t-wrk.pwho = b-smspool.pwho.
    t-wrk.batchid = b-smspool.batchid.

    hide message no-pause.
    message "Сбор данных - " LN[i] " БАЗА № - " v-ourbnk.
    if i = 8 then i = 1.
    else i = i + 1.
end.