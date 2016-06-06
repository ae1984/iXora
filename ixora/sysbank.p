/* sysbank.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/* sysbank.p
*/

{mainhead.i BANK}
def new shared var v-geo like geo.geo.
{head-a.i
        &var = "def new shared var s-bank like bank.bank.
                def var vbank like bank.bank.
                def buffer b-bank for bank."
        &file = "bank"
        &line = " "
        &form = "
                 bank.bank colon 17
                 bank.name colon 17
                 bank.addr colon 17
                 bank.attn colon 17
                 bank.tel  colon 17 bank.fax colon 50
                 bank.tlx  colon 17
                 bank.bic colon 17 format ""x(14)""
                 bank.chipno colon 17  bank.cgr colon 50 label ""CGR""
                 bank.frbno colon 17   v-geo format ""x(3)"" colon 50
                 bank.lne     colon 17 format ""x(35)"" label ""DOC. NAME""
                 bank.gl      colon 17
                 bank.acc     colon 50
                 bank.crbank  colon 17
                 bank.acct    colon 17
                 bank.ibf     colon 17
                 bank.inter   colon 50
                 bank.intrate colon 17
                 bank.rim     colon 50
                 "
        &frame = "row 3 side-label"
        &predisp = " v-geo = string(bank.stn,'999')."
        &fldupdt = "
                 bank.bank bank.name bank.addr
                 bank.attn bank.tel bank.fax bank.tlx bank.bic
                 bank.chipno bank.cgr bank.frbno v-geo bank.lne
                 bank.gl bank.acc "
        &posupdt = "find geo where geo.geo = v-geo no-lock no-error.
                    if not available geo then undo,retry.
                    find cgr where bank.bank.cgr eq cgr.cgr no-lock no-error.
                    if not available cgr then undo,retry.
                    bank.stn = integer(v-geo).
                    do on error undo,retry:
                    find dfb where dfb.dfb eq bank.acc no-error.
                    if available dfb and dfb.gl = bank.gl then
                    bank.crbank = dfb.name.
                    update bank.crbank bank.acct
                    bank.ibf bank.inter bank.intrate bank.rim
                    with frame bank. end."
        &vseleform = "1 col row 2 col 67 no-label overlay"
        &flddisp = "
                 bank.bank bank.name bank.addr
                 bank.attn bank.tel bank.tlx bank.fax  bank.bic
                 format ""x(14)""
                 bank.chipno bank.cgr bank.frbno v-geo
                 bank.intrate bank.lne bank.gl bank.acc
                 bank.rim bank.crbank bank.acct
                 bank.ibf bank.inter "
        &other1  = " "
        &other2  = " "
        &other3  = " "
        &other4  = " "
        &other5  = " "
        &other6  = " "
        &other7  = " "
        &other8  = " "
        &other9  = " "
        &other10 = " "
        &prg1 = "other"
        &prg2 = "other"
        &prg3 = "other"
        &prg4 = "other"
        &prg5 = "other"
        &prg6 = "other"
        &prg7 = "other"
        &prg8 = "other"
        &prg9 = "other"
        &prg10 = "other"
        }
