/* lcadvbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advise of Amendment - BO2(акцепт)
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
        07/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        28.06.2012 Lyubov  - для EXPG проводки делаются иначе
*/
{global.i}
{chk-f.i}

def shared var s-lc       like LC.LC.
def shared var v-lcsts    as char.
def shared var v-lcerrdes as char.
def shared var s-amdsts   like lcamend.sts.
def shared var s-lcamend  like lcamend.lcamend.
def shared var s-lccor    like lcswt.lccor.
def shared var s-lcprod   as char.
def new shared var s-jh  like jh.jh.
def var v-sum      as deci no-undo.
def var v-comacc   as char no-undo.
def var v-param    as char no-undo.
def var vdel       as char no-undo initial "^".
def var rcode      as int  no-undo.
def var rdes       as char no-undo.
DEF VAR VBANK      AS CHAR no-undo.
def var v-yes      as logi no-undo.
def var v-trx      as char no-undo.
def var i          as int  no-undo.
def var k          as int  no-undo.
def var v-file     as char no-undo.
def buffer b-lcamendres for lcamendres.

pause 0.
if lookup(s-amdsts,'BO1,ERR') = 0 then do:
    message "Letter of credit's status should be BO1 or Err!" view-as alert-box.
    return.
end.

    message 'Do you want to change Credit status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.

    FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
    IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.

    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ComAcc' no-lock no-error.
    if avail lcamendh then v-comacc = lcamendh.value1.
    if v-comacc = '' then do:
        message "Field Client's Account is empty!" view-as alert-box.
        return.
    end.

    /*check balance*/
    v-sum = 0.
    for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.jh = 0 no-lock:
        v-sum = v-sum + lcamendres.amt.
    end.

    find first aaa where aaa.aaa = v-comacc no-lock no-error.
    if avail aaa then do:
        if v-sum > aaa.cbal - aaa.hbal then do:
            message "Lack of the balance Client's Account (" + aaa.aaa + ")!" view-as alert-box error.
            return.
        end.
    end.

    find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'AdvBy' no-lock no-error.
    if not avail lcamendh or lcamendh.value1 = '' then do:
        message 'The field Advise By is compulsory to complete!' view-as alert-box error.
        return.
    end.

    /*Commission postings*/
    for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.com and lcamendres.jh = 0 no-lock:
        if lcamendres.amt = 0 then next.
        find first tarif2 where tarif2.str5 = lcamendres.comcode and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then return.

        if s-lcprod = 'EXPG' then do:
            find first tarif2 where tarif2.str5 = lcamendres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign v-param = string(lcamendres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lcamendres.rem + vdel + string(lcamendres.amt) + vdel + string(tarif2.kont)
                   v-trx   = 'cif0023'.
        end.
        else assign v-param = string(lcamendres.amt) + vdel + string(lcamendres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lcamendres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                    v-trx   = 'cif0015'.

        s-jh = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message rdes.
            pause.
            message "The commission posting (" + lcamendres.comcode + ") was not done!" view-as alert-box error.
            find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
            if avail lcamendh then find current lcamendh exclusive-lock.
            if not avail lcamendh then create lcamendh.
            assign lcamendh.lc       = s-lc
                   lcamendh.lcamend    = s-lcamend
                   lcamendh.bank     = vbank
                   lcamendh.kritcode = 'ErrDes'
                   lcamendh.value1   = string(rcode) + ' ' + rdes.
            run LCsts('BO1','Err').
            return.
        end.

        if s-jh > 0 then do:
            find first b-lcamendres where rowid(b-lcamendres) = rowid(lcamendres) exclusive-lock no-error.
            if avail b-lcamendres then
            assign b-lcamendres.rwho   = g-ofc
                   b-lcamendres.rwhn   = g-today
                   b-lcamendres.jh     = s-jh
                   b-lcamendres.jdt    = g-today
                   b-lcamendres.trx    = v-trx.
            find current b-lcamendres no-lock no-error.
        end.
        message "The commission posting (" + lcamendres.comcode + ") was done!" view-as alert-box info.
    end.

   if lcamendh.value1 = '0' then do:

    if chk-f("$HOME/.ssh/id_swift") ne '0' then do:
        message "There is no file $HOME/.ssh/id_swift!" view-as alert-box error.
        find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
        if avail lcamendh then find current lcamendh exclusive-lock.
        else create lcamendh.
        assign lcamendh.value1   = "There is no file $HOME/.ssh/id_swift!"
               lcamendh.lc       = s-lc
               lcamendh.lcamend  = s-lcamend
               lcamendh.kritcode = 'ErrDes'
               lcamendh.bank     = vbank.
        run LCsts2(s-amdsts,'Err').
        v-lcerrdes = "There is no file $HOME/.ssh/id_swift!".
        return.
    end.
    run i799mt no-error.
    if error-status:error then do:
        find first lcamendh where lcamendh.bank = vbank and lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'ErrDes' no-lock no-error.
        if avail lcamendh then find current lcamendh exclusive-lock.
        else create lcamendh.
        assign lcamendh.value1   = "File wasn't copied to SWIFT Alliance!"
               lcamendh.lc       = s-lc
               lcamendh.lcamend  = s-lcamend
               lcamendh.kritcode = 'ErrDes'
               lcamendh.bank     = vbank.
        run LCsts2(s-amdsts,'Err').
        v-lcerrdes = "File wasn't copied to SWIFT Alliance!".
        return.
    end.

    find first lch where lch.lc = s-lc and  LCh.value4 = 'O799-' + string(s-lccor,'999999') and lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').

    find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I799' exclusive-lock no-error.
    assign  LCswt.fname1 = v-file
            LCswt.dt     = g-today
            LCswt.sts    = 'FIN'.
    find current LCswt no-lock no-error.
end.
run LCsts2(s-amdsts,'FIN').
