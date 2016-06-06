/* currpositiontxb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        25.06.2012 damir.
        26.07.2012 damir - пробегаем по cls, добавил Getdatests.
        04.01.2012 damir - Убрал проверку по v-weekbeg,v-weekend в Getdatests.
*/

{conv.i}

def shared var v-gl1     as char init "4593,4703,4704,4705,4707,4710,4734".
def shared var v-gl2     as char init "5593,5703,5704,5705,5708,5710,5734".
def shared var v-dt      as date.
def shared var v-weekbeg as inte.
def shared var v-weekend as inte.

def shared temp-table tgl
    field bank   as char
    field gl     as inte
    field crc    as inte
    field sumval as deci
    field sumkzt as deci format "zzzzzzzzzzzzzzzzzzzzz9.99"
    field dt     as date
    index tgl-id1 is primary gl ascending
                             dt ascending.

def shared temp-table t-crc     like txb.crc.
def shared temp-table t-crchis  like txb.crchis.
def shared temp-table t-crcpro  like txb.crcpro.

def var acnt$     as char.
def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).


/**находим первый день недели***************************************************************/
find txb.sysc where txb.sysc.sysc = "WKSTRT" no-lock no-error.
if avail txb.sysc then v-weekbeg = txb.sysc.inval.
else v-weekbeg = 2.
/*******************************************************************************************/

/**находим последний день недели************************************************************/
find txb.sysc where txb.sysc.sysc = "WKEND" no-lock no-error.
if avail txb.sysc then v-weekend = txb.sysc.inval.
else v-weekend = 6.
/*******************************************************************************************/

/************************определение - рабочий день или нет ********************************/
function Getdatests returns logi(input dt as date):
    def var s-bday as logi.
    find txb.hol where txb.hol.hol = dt no-lock no-error.
    if not available txb.hol /*and weekday(dt) ge v-weekbeg and  weekday(dt) le v-weekend*/ then s-bday = yes.
    else s-bday = no.
    return s-bday.
end function.
/*******************************************************************************************/

if s-ourbank = "TXB16" then do:
    empty temp-table t-crc.
    empty temp-table t-crcpro.
    for each txb.crc no-lock:
        create t-crc.
        buffer-copy txb.crc to t-crc.
    end.
    for each txb.crcpro no-lock use-index crcdt_idx:
        create t-crcpro.
        buffer-copy txb.crcpro to t-crcpro.
    end.
end.

nxtcls:
for each txb.cls where txb.cls.whn >= date(month(v-dt),1,year(v-dt)) - 10 and txb.cls.whn <= v-dt no-lock:
    if not Getdatests(txb.cls.whn) then next nxtcls.
    for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 break by txb.gl.gl:
        if txb.gl.gl <> 599980 and (lookup(substr(string(txb.gl.gl),1,4),v-gl1) > 0 or lookup(substr(string(txb.gl.gl),1,4),v-gl2) > 0) then do:
            acnt$ = substr(string(txb.gl.gl),1,4).
            for each txb.crc no-lock break by txb.crc.crc:
                find last txb.glday where txb.glday.gdt <= txb.cls.whn and txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc no-lock no-error.
                if avail txb.glday and txb.glday.bal <> 0 then do:
                    create tgl.
                    tgl.bank   = s-ourbank.
                    tgl.gl     = inte(acnt$).
                    tgl.crc    = txb.glday.crc.
                    tgl.sumval = txb.glday.bal.
                    tgl.dt     = txb.cls.whn.
                    tgl.sumkzt = CRC2KZT(txb.glday.bal,txb.glday.crc,txb.cls.whn).
                end.
            end.
        end.
    end.
end.

