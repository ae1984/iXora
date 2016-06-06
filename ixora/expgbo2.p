/* expgBO2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Потверждение EXPG, EXLC, EXSBLC (акцепт BO2)
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
        31/01/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    21/02/2011 id00810 - вариант, что комиссий может вообще не быть или проводки по ним уже сделаны
    20/05/2011 id00810 - проверка наличия файла id_swift
    13/09/2011 id00810 - обработка ошибки копирования в SWIFT
    14/09/2011 id00810 - MT720 для EXLC
    30/01/2011 id00810 - изменение в назначении платежа для комиссий
    07/06/2012 Lyubov  - проверка отправки mt 768
    08.06.2012 Lyubov  - добавила параметры ЕКНП в транзакцию
    28.06.2012 Lyubov  - для EXPG проводки делаются иначе
*/
{global.i}

def shared var s-lc       like lc.lc.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var s-lcprod   as char.
def var v-crc    as int  no-undo.
def var v-comacc as char no-undo.
def var v-param  as char no-undo.
def var vdel     as char no-undo initial "^".
def var rcode    as int  no-undo.
def var rdes     as char no-undo.
def var v-st     as logi no-undo.
DEF VAR VBANK    AS CHAR no-undo.
def var v-gl     as char no-undo.
def var v-sum1   as deci no-undo.
def var v-yes    as logi no-undo.
def var v-rem    as char no-undo.
def var v-trx    as char no-undo.
/*def var v-lastyear as logi.*/
def var v-logsno  as char no-undo init "no,n,нет,н,1".
def new shared var s-jh like jh.jh.
def buffer b-lcres for lcres.

{chk-f.i}
pause 0.

if v-lcsts <> 'BO1' and v-lcsts <> 'Err' then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box error.
    return.
end.

message 'Do you want to change Credit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
if avail lch then v-crc = integer(lch.value1).

/*check balance*/
v-sum1 = 0.
for each lcres where lcres.lc = s-lc and lcres.com = yes and lcres.jh = 0 no-lock:
    v-sum1 = v-sum1 + lcres.amt.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
if avail lch then do:
    find first aaa where aaa.aaa = lch.value1 no-lock no-error.
    if avail aaa then do:
        if v-sum1 > aaa.cbal - aaa.hbal then do:
            message " Lack of the balance Commissions Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
            return.
        end.
        v-comacc = aaa.aaa.
    end.
end.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

/*Commission postings*/
find first lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 and lcres.jh = 0 no-lock no-error.
if not avail lcres then v-st = yes.
else do:
     for each b-lcres where b-lcres.lc = s-lc and b-lcres.com and b-lcres.amt > 0 and b-lcres.jh = 0 no-lock:
         find first lcres where recid(lcres) = recid(b-lcres) exclusive-lock no-error.
         find first tarif2 where tarif2.str5  = lcres.comcode and tarif2.stat = 'r' no-lock no-error.
         if avail tarif2 then v-gl = string(tarif2.kont).

         if s-lcprod = 'EXPG' then do:
            v-rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
            assign v-param = string(lcres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lcres.rem + vdel + string(lcres.amt) + vdel + v-gl
                   v-trx   = 'cif0023'.
         end.

         else do:
            v-rem = if num-entries(lcres.rem,';') = 2 then entry(1,lcres.rem,';') else lcres.rem.
            v-param = string(LCres.amt) + vdel + string(lcres.crc) + vdel + v-comacc + vdel + v-gl + vdel + s-lc + ' ' + v-rem + vdel + '1' + vdel + '4' + vdel + '840'.
            v-trx   = 'cif0015'.
         end.

         s-jh = 0.

         run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
         if rcode ne 0 then do:
             message rdes.
             pause.
             message "The commission posting (" + lcres.comcode + ") was not done!" view-as alert-box error.
             find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
             if avail lch then find current lch exclusive-lock.
             else create lch.
             assign lch.lc       = s-lc
                    lch.kritcode = 'ErrDes'
                    lch.value1   = string(rcode) + ' ' + rdes
                    lch.bank     = vbank.
             run LCsts('BO1','Err').
             return.
         end.
         if s-jh > 0 then do:
             assign lcres.rwho = g-ofc
                    lcres.rwhn = g-today
                    lcres.jh   = s-jh
                    lcres.jdt  = g-today
                    lcres.trx  = v-trx.
             find current lcres no-lock no-error.
             v-st = yes.
         end.
         message "The commission posting (" + lcres.comcode + ") was done!" view-as alert-box info.
     end.
end.

if v-st = yes then do:
        if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
            message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
            find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            if not avail lch then create lch.
            assign lch.lc       = s-lc
                   lch.kritcode = 'ErrDes'
                   lch.value1   = "There is no file $HOME/.ssh/id_swift!".
                   lch.bank     = vbank.
            find current lch no-lock no-error.
            run LCsts(v-lcsts,'Err').
            v-lcerrdes = "There is no file $HOME/.ssh/id_swift!".
            return.
        end.
        if s-lcprod = 'expg' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'MT768' no-lock no-error.
            if avail lch and lookup(lch.value1,v-logsno) = 0 then run expgmt no-error.
        end.
        if lookup(s-lcprod,'exlc,exsblc') > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'Advby' no-lock no-error.
            if avail lch then do:
                if lch.value1 = '720' then run lcmtlch.p ('720', yes) no-error.
                else if lch.value1 = '710' then run lcmtlch.p ('710', yes) no-error.
            end.
            find first lch where lch.lc = s-lc and lch.kritcode = 'MT730' no-lock no-error.
            if avail lch and lookup(lch.value1,v-logsno) = 0 then run expgmt no-error.
        end.
        if error-status:error then do:
            find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            if not avail lch then create lch.
            assign lch.lc       = s-lc
                   lch.kritcode = 'ErrDes'
                   lch.value1   = "File wasn't copied to SWIFT Alliance!"
                   lch.bank     = vbank.
            find current lch no-lock no-error.
            run LCsts(v-lcsts,'Err').
            v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
            return.
        end.

    run LCsts(v-lcsts,'FIN').
    if v-lcsts = 'ERR' then do:
        find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
        if avail lch then do:
            find current lch exclusive-lock.
            lch.value1 = ''.
            find current lch no-lock no-error.
        end.
    end.
end.
