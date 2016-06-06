/* dcls2.p
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

 /* odaint.p
    Sushinin V.L.           26.05.94
*/
{global.i}

/*
{proghead.i "ODA INTEREST CALCULATION"}
*/
def  shared var s-intday as int.
def var s-int like jl.dam.
def var vday as int.
def var vmtdacc like aaa.mtdacc.
def var vrate like aaa.rate.
def new shared var srem as char format "x(50)" extent 2.
def var s-oldcrl like aaa.opnamt.
def buffer b-aaa for aaa.

def stream stream-err .
output stream stream-err to odaint.err.
def stream stream-out .
output stream stream-out to odaint.out.
def var v-err as log.
def var v-rate like pri.rate.
def var v-lstmavg like aaa.lstmavg.
def var s-amt like jl.dam.
def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
def var v-param as char.
def var vdel as char initial "^".
def var v-templ as char.
def var rcode as int.
def var rdes as char.
def var s-jh like jh.jh.

if month(g-today) <> 12 then
vday = date(month(g-today) + 1,1,year(g-today)) -
date(month(g-today),1,year(g-today)) .
else
vday = date(1,1,year(g-today) + 1) -
date(12,1,year(g-today)) .
for each lgr where lgr.led = "ODA" no-lock break by lgr:
    v-err = no.
    vrate = 0.
    if lgr.complex = no then do:
    if lgr.lookaaa eq true then do:
        if lgr.pri ne "F" then do:
            find pri where pri.pri eq lgr.pri no-lock no-error.
            if available pri then do:
                if pri.itype eq 1 then v-rate = pri.rate .
                else do:
                    put stream stream-err "Error interest rate for " lgr.lgr "."
                    skip.
                    v-err = yes.
                end.
            end.
            else do:
                put stream stream-err "Error interest type for " lgr.lgr "."
                skip.
                v-err = yes.
            end.
        end.
        else v-rate = 0.
    end.
    else do:
        if lgr.pri ne "F" then do:
            find pri where pri.pri eq lgr.pri.
            if available pri then do:
                if pri.itype eq 1 then v-rate = pri.rate + lgr.rate.
                else do:
                    put stream stream-err "Error interest rate for " lgr.lgr "."
                    skip.
                    v-err = yes.
                end.
            end.
            else do:
                put stream stream-err "Error interest type for " lgr.lgr "."
                skip.
                v-err = yes.
            end.
        end.
        else v-rate = lgr.rate.
    end.
    end.
    else do:
        put stream stream-err "Error interest type (C/S) for " lgr.lgr "."
        skip.
        v-err = yes.
    end.
    vrate = v-rate.







for each aaa where aaa.lgr = lgr.lgr  :

    find crc of aaa.
    vmtdacc = aaa.mtdacc + (aaa.cr[1] - aaa.dr[1]) * s-intday.

    if month(aaa.regdt) = month(g-today) and
    year(aaa.regdt) = year(g-today) then
    v-lstmavg = - vmtdacc  / (vday - day(aaa.regdt) + 1).
    else
    v-lstmavg = - vmtdacc  / vday.



    if not v-err then do:
        if lgr.lookaaa then vrate = v-rate + aaa.rate.
        s-int = round((( - vmtdacc ) * vrate / aaa.base / 100.0 ) , crc.decpnt).
        s-amt = 0.
        find b-aaa where b-aaa.aaa = aaa.craccnt no-lock no-error.
        if available b-aaa then do:
            run aaa-bal777(input b-aaa.aaa, output vbal,output vavl, 
            output vhbal, output vfbal, output vcrline, output vcrlused, 
            output vooo).
        
            if vavl ge s-int then s-amt = s-int. else s-amt = vavl.
            if s-amt lt 0 then s-amt = 0.
            if s-amt gt 0 then do:
                v-templ = "CIF0005".
                v-param = string(s-amt) + vdel + b-aaa.aaa.
                run trxgen (v-templ, vdel, v-param, "CIF" , b-aaa.aaa ,
                output rcode, output rdes, input-output s-jh).
        
                if rcode ne 0 then s-amt = 0.
            end.
            if s-amt ne s-int then
                put stream stream-err "Non sufficient fund for account "
                    b-aaa.aaa ", ODA ACCOUNT " aaa.aaa ", MTDACC = "
                    vmtdacc ", INTEREST = " s-amt skip.
            else do:
                    {odaint.f}
                    display stream stream-out aaa.aaa b-aaa.aaa vmtdacc
                    vrate s-amt s-jh.
            end.

            v-err = no.
        end.
        else put stream stream-err "Not found DDA for ODA " aaa.aaa
        ", MTDACC = " vmtdacc ", INTEREST = " s-amt skip.
    end.  /* not v-err */
    else put stream stream-err "Error for ODA ACCOUNT "
    aaa.aaa ", MTDACC = " vmtdacc skip.
    
    do transaction :
        find b-aaa where aaa.aaa = b-aaa.aaa exclusive-lock.
        b-aaa.lstmavg = v-lstmavg.
    end.
end.

end.
