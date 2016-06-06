/*dcbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC - проводки, акцепт 2-го менеджера бэк-офиса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-1 опция BO2
 * AUTHOR
        29/12/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        13/02/2012 id00810 - для ODC
        06.03.2012 Lyubov  - "dc" изменила на "idc"
        08.06.2012 Lyubov  - добавила параметры ЕКНП в транзакцию
*/
{global.i}
{chk-f.i}

def shared var s-lc       like lc.lc.
def shared var v-lcerrdes as char.
def shared var v-lcsts    as char.
def shared var s-lcprod   as char.

def var v-sum     as deci no-undo.
def var v-crc     as int  no-undo.
def var v-param   as char no-undo.
def var v-rem     as char no-undo.
def var vdel      as char no-undo initial "^".
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
DEF VAR VBANK     AS CHAR no-undo.
def var v-yes     as logi no-undo.
def var v-arp     as char.
def var i         as int.
def var k         as int.
def var v-crcc    as char.
def var v-logsno  as char init "no,n,нет,н,1".
def var v-nazn    as char.
def var v-date    as char.
def var v-dacc    as char.
def var v-cacc    as char.
def var v-levD    as int.
def var v-levC    as int.
def var v-trx     as char.
def new shared var s-jh like jh.jh.
def buffer  b-lcres for lcres.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
    message 'Нет параметра OURBNK в sysc!' view-as alert-box.
    return.
end.

pause 0.
if v-lcsts <> 'BO1' and v-lcsts <> 'Err' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box.
    return.
end.

message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

v-crc = 1.
find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crcc = crc.code.

if s-lcprod = 'idc' then do:
    find first pksysc where pksysc.sysc = s-lcprod + 'arp' no-lock no-error.
    if avail pksysc then do:
        if num-entries(pksysc.chval) >= v-crc then v-arp = entry(v-crc,pksysc.chval).
        else do:
            message "The value " + s-lcprod  + "ARP in pksysc is empty!" view-as alert-box error.
            return.
        end.
    end.
    if v-arp = '' then do:
        message "The value " + s-lcprod  + "ARP in pksysc is empty!" view-as alert-box error.
        return.
    end.
end.
find first lch where lch.lc = s-lc and lch.kritcode = 'Number' no-lock no-error.
if not avail lch or lch.value1 = '' then do:
    message "Field Number is empty!" view-as alert-box error.
    return.
end.
v-sum = deci(lch.value1).

/*********POSTINGS**********/
/* number of documents*/
if s-lcprod = 'idc' then assign v-dacc = v-arp
                               v-cacc = '824000'
                               v-nazn  = 'Поступление документов на инкассо, ' + s-lc.
else assign v-dacc = '715030'
            v-cacc = '815000'
            v-nazn  = 'Отправка документов на инкассо, ' + s-lc.
find first lcres where lcres.lc = s-lc and lcres.dacc = v-dacc and lcres.cacc = v-cacc no-lock no-error.

if not avail lcres then do:
    create lcres.
    assign lcres.lc      = s-lc
           lcres.levD    = 1
           lcres.dacc    = v-dacc
           lcres.levC    = 1
           lcres.cacc    = v-cacc
           lcres.rem     = v-nazn
           lcres.amt     = v-sum
           lcres.crc     = v-crc
           lcres.com     = no
           lcres.comcode = ''
           lcres.rwho    = g-ofc
           lcres.rwhn    = g-today
           lcres.bank    = 'TXB00'.
    find current lcres no-lock.
    if s-lcprod = 'idc' then v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Поступление документов на инкассо, ' + vdel + s-lc.
    else v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn.
    find first clsdp where clsdp.aaa = v-dacc and clsdp.txb = 'TXB00' and clsdp.sts = '17' and clsdp.rem = s-lc no-lock no-error.
    if not avail clsdp then do:
        create clsdp.
        assign clsdp.aaa = v-dacc
               clsdp.txb = 'TXB00'
               clsdp.sts = '17'
               clsdp.rem = s-lc
               clsdp.prm = v-param.
    end.
end.
/* commissions */
find first lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 and lcres.jh = 0 no-lock no-error.
if avail lcres then do:
    for each lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 and lcres.jh = 0 no-lock:
        v-rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
        v-param = string(LCres.amt) + vdel + string(lcres.crc) + vdel + lcres.dacc + vdel + lcres.cacc + vdel + s-lc + ' ' + v-rem + vdel + '1' + vdel + '4' + vdel + '840'.

        s-jh = 0.
        run trxgen ("cif0015", vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                   message rdes.
                   pause.
                   message "The commission posting (" + lcres.comcode + ") was not done!" view-as alert-box error.
                   find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
                   if avail lch then find current lch exclusive-lock.
                   if not avail lch then create lch.
                   assign lch.lc       = s-lc
                          lch.kritcode = 'ErrDes'
                          lch.value1   = string(rcode) + ' ' + rdes
                          lch.bank     = vbank.
                   run LCsts('BO1','Err').
                   return.
                end.
        if s-jh > 0 then do:
            find first b-lcres where rowid(b-lcres) = rowid(lcres) exclusive-lock no-error.
            if avail b-lcres then
            assign b-lcres.rwho = g-ofc
                   b-lcres.rwhn = g-today
                   b-lcres.jh   = s-jh
                   b-lcres.jdt  = g-today
                   b-lcres.trx  = 'cif0015'.
            find current b-lcres no-lock no-error.
        end.
        message "The commission posting (" + lcres.comcode + ") was done!" view-as alert-box info.
    end.
end.

if s-lcprod = 'idc' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'MT410' no-lock no-error.
    if avail lch and lookup(lch.value1,v-logsno) = 0 then do:
        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            else create lch.
            assign lch.lc       = s-lc
                   lch.bank     = vbank
                   lch.kritcode = 'ErrDes'
                   lch.value1   = "There is no file $HOME/.ssh/id_swift!".
            run LCsts(v-lcsts,'Err').
        end.
        run lcmtlch('410',yes) no-error.
        if error-status:error then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            else create lch.
            assign lch.lc       = s-lc
                   lch.bank     = vbank
                   lch.kritcode = 'ErrDes'
                   lch.value1   = "File wasn't copied to SWIFT Alliance!".
            find current lch no-lock no-error.
            run LCsts(v-lcsts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.
    end.
end.
run LCsts(v-lcsts,'BO2').
if v-lcsts = 'ERR' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
    if avail lch then do:
        find current lch exclusive-lock.
        lch.value1 = ''.
        find current lch no-lock no-error.
    end.
end.
