/* corbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION

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
        22.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        30.11.2012 Lyubov - ТЗ 1374 от 23/05/2012 «Изменение счета ГК 1858».

*/

/*{global.i}*/
{mainhead.i}
{convgl.i "bank"}

def shared var s-lc     like LC.LC.
def shared var s-corsts as char.
def shared var v-lcsts  as char.
def shared var s-lccor  like lcswt.lccor.
def shared var s-mt     as inte.
def shared var s-lctype as char.

def var v-zag  as char.
def var v-yes  as logi init yes.
def var v-str  as char.
def var v-sp   as char.
def var v-file as char.
def var n      as inte.
def var m      as inte.

def var v-param       as char no-undo.
def var vdel          as char no-undo initial "^".
def var rcode         as int  no-undo.
def var rdes          as char no-undo.
def new shared var s-jh like jh.jh.
def var v-st          as logi no-undo.
DEF VAR VBANK         AS CHAR no-undo.
def var v-trx         as char no-undo.

pause 0.
if v-lcsts <> 'BO1' and v-lcsts <> 'Err' then do:
    message " Status should be BO1 or Err!" view-as alert-box error.
    return.
end.
else do:
    message 'Do you want to change status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
    if not v-yes then return.
    else do:
        for each lcres where lcres.lc = s-lc and lcres.com and lcres.amt > 0 exclusive-lock:
            if lcres.jh <> 0 then message 'The commission posting ' + lcres.comcod + ' was done earlier' view-as alert-box.
            else do:
                find first tarif2 where tarif2.str5 = lcres.comcode and tarif2.stat = 'r' no-lock no-error.
                if s-lctype = 'I' then
                    assign v-param = string(lcres.amt) + vdel + string(lcres.crc) + vdel + '186082' + vdel + tarif2.pakal + s-lc + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + '840' + vdel + '1' + vdel + '461211'
                           v-trx   = 'uni0022'.

                else
                    assign v-param = string(lcres.amt) + vdel + string(lcres.crc) + vdel + 'Комиссионные доходы ' + s-lc + vdel + string(lcres.amt) + vdel + string(lcres.crc) + vdel + string(getConvGL(lcres.crc,"C")) + vdel + string(tarif2.kont)
                           v-trx   = 'cif0024'.
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                message rcode rdes view-as alert-box.
                    find first lch where lch.lc = s-lc and kritcode = 'ErrDes' no-lock no-error.
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
                    assign lcres.rwho = g-ofc
                           lcres.rwhn = g-today
                           lcres.jh   = s-jh
                           lcres.jdt  = g-today
                           lcres.trx  = v-trx.
                    v-st = yes.
                    message "The commission posting (" + lcres.comcode + ") was done! " s-jh view-as alert-box info.
                end.
            end.
        end.

        if s-lctype = 'E' then do:
            find first lch where lch.kritcode = 'MT799' no-lock no-error.
            if avail lch and lch.value1 = 'YES' then do:
                run expgmt no-error.
                run i799mt no-error.
            end.
        end.

        if s-lctype = 'I' then run i799mt no-error.

        if error-status:error then do:
            find first lch where lch.bank = vbank and lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then find current lch exclusive-lock.
            else create lch.
            assign lch.value1   = "File wasn't copied to SWIFT Alliance!"
                   lch.lc       = s-lc
                   lch.kritcode = 'ErrDes'
                   lch.bank     = vbank.
            run LCsts(v-lcsts,'Err').
            return.
        end.

        run LCsts(v-lcsts,'FIN').

        if v-lcsts = 'ERR' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'ErrDes' no-lock no-error.
            if avail lch then do:
                find current lch exclusive-lock.
                lch.value1 = ''.
                find current lch no-lock no-error.
            end.
        end.

        else do:
            find first lch where lch.lc = s-lc and /* LCh.value4 = 'O799-' + string(s-lccor,'999999') and*/ lch.kritcode = "TRNum" and lch.value1 <> '' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then v-file = replace(lch.value1,"/", "_") + "_" + string(s-lccor,'999999').
            find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I768' exclusive-lock no-error.
            if avail LCswt then
            assign LCswt.fname1 = v-file
                   LCswt.dt     = g-today
                   LCswt.sts    = "FIN".
            find current LCswt no-lock no-error.

            find first LCswt where LCswt.LC = s-lc and LCswt.LCcor = s-lccor and LCswt.mt = 'I799' exclusive-lock no-error.
            if avail LCswt then
            assign LCswt.fname1 = v-file
                   LCswt.dt     = g-today
                   LCswt.sts    = "FIN".
            find current LCswt no-lock no-error.
        end.
    end.
end.