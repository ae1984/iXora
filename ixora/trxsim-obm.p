/* trxsim-obm.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       08/04/08 marinav - crc.rate[5] -> crc.rate[3], crc.rate[4]  -> crc.rate[2]
       07/06/2011 madiyar - добавил по кассе счет 100500
       26/11/2012 Luiza  - подключила convgl.i  ТЗ 1374
       28/12/2012 madiyar - счет ГК 000001 заменяется на счет конвертации, соответствующий валюте и стороне проводки
*/

/*trxsim-obm.p
  28.11.2000 */

{global.i}
def input parameter trxcode as char.
def input parameter vdel as char.
def input parameter vparam as char.
def input parameter vnum as inte.
def output parameter rcode as inte.
def output parameter rdes as char.
def output parameter vparr as char.
def new shared var s-jh as inte.
def var i as inte.
def var k as inte.
def var vpar as char.
def var errlist as char extent 34.
def new shared temp-table tmpl like trxtmpl.
def new shared temp-table cdf like trxcdf.
def buffer btmpl for tmpl.
def var vcode as inte.
def var vdes as char.
def var vgl as inte.
def var vref as inte.
def var vsign as char.
def new shared var hsts as inte.
def new shared var hparty as char.
def new shared var hpoint as inte.
def new shared var hdepart as inte.
def new shared var hsts-f as char.
def new shared var hparty-f as char.
def new shared var hpoint-f as char.
def new shared var hdepart-f as char.
def new shared var hopt as char.
def new shared var hmult as inte.
def new shared var hopt-f as char.
def new shared var hmult-f as char.
def buffer cas for sysc.
/*def buffer buy for sysc.
def buffer sel for sysc.*/
def var N as inte.
def var crec as recid.
def var vdecpnt like crc.decpnt.
def var vrate like trxtmpl.rate.
def var vamt like trxtmpl.amt.
def var vcrc like crc.crc.
def var vmarg like trxtmpl.amt.
def var selbuy as char.
def var repl as inte.
def var nl as inte.
def var NN as inte.
def var vrem as char.
def var o as inte.
def var pcrcif as char.

def var vcrc1 as inte.
def var vcrc2 as inte.
def var cas1 as logi.
def var cas2 as logi.
def var amt1 as deci.
def var amt2 as deci.
def var vrat1 as deci decimals 10.
def var vrat2 as deci decimals 10.
def var coef1 as inte.
def var coef2 as inte.
def var marg1 as deci.
def var marg2 as deci.
def shared var vrat as deci decimals 2.
errlist[18] = "Specified TRX code doesn't exist.".
errlist[19] = "Incorrect parameter list.".
errlist[20] = "Template error.".
errlist[28] = "G/L for specified level not defined.".
errlist[29] = "Unexpected end of parameter list.".
errlist[30] = "One or more extra params in paramlist.".
errlist[33] = "Platon account for specified card and currency not defined.".
errlist[34] = "Illegal Platon account defined for specified card.".

find cas where cas.sysc = "cashgl" no-lock no-error.
/*find buy where buy.sysc = "buygl" no-lock no-error.
find sel where sel.sysc = "selgl" no-lock no-error.*/
{convgl.i "bank"}

find last trxtmpl where trxtmpl.code = trxcode no-lock no-error.
if not available trxtmpl then do:
    rcode = 18.
    rdes = errlist[18] + ": " + trxcode + ".".
    return.
end.
else nl = trxtmpl.ln.

find trxhead where trxhead.code = integer(substring(trxtmpl.code,4)) and trxhead.system = trxtmpl.system no-lock.

hopt = trxhead.opt.

/*1)Status*/
if trxhead.sts-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Status)-required.".
        return.
    end.
    hsts = integer(vpar) no-error.
    if ERROR-STATUS:error then do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Status)=" + vpar + "-integer expected.".
        hsts = 0.
        return.
    end.
    hsts-f = "d".
end.
else do:
    hsts = trxhead.sts.
    hsts-f = "d".
end.

/*2)Party*/
if trxhead.party-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Party)-required.".
        return.
    end.
    hparty = vpar.
    hparty-f = "d".
end.
else do:
    hparty = trxhead.party.
    hparty-f = "d".
end.
/*3)Point*/
if trxhead.point-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Point)-required.".
        return.
   end.
   hpoint = integer(vpar) no-error.
   if ERROR-STATUS:error then do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Point)=" + vpar + "-integer expected.".
        hpoint = 0.
        return.
    end.
    hpoint-f = "d".
end.
else do:
    hpoint = trxhead.point.
    hpoint-f = trxhead.point-f.
end.

/*4)Depart*/
if trxhead.depart-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Depart)-required.".
        return.
    end.
    hdepart = integer(vpar) no-error.
    if ERROR-STATUS:error then do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Depart)=" + vpar + "-integer expected.".
        hdepart = 0.
        return.
    end.
    hdepart-f = "d".
end.
else do:
    hdepart = trxhead.depart.
    hdepart-f = trxhead.depart-f.
end.

/*4a)Multiplication coefficient*/
if trxhead.mult-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + ",Nr." + string(i) + "(Repl)-required.".
        return.
    end.
    hmult = integer(vpar) no-error.
    if ERROR-STATUS:error then do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode + "Nr." + string(i) + "(Repl)=" + vpar + "-integer expected.".
        hmult = 0.
        return.
    end.
    hmult-f = "d".
end.
else do:
    hmult = trxhead.mult.
    hmult-f = trxhead.mult-f.
end.

/*4b)Optimization parameter*/
if trxhead.opt-f = "r" then do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if ERROR-STATUS:error then do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
                              + ",Nr." + string(i)
                              + "(Opti)-required.".
        return.
    end.
    if vpar <> "+" or vpar <> "-" then do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl=" + trxcode
                              + ",Nr." + string(i)
                              + "(Opti)=" + vpar + "-'+' or '-' expected.".
        return.
    end.
    hopt = vpar.
    hopt-f = "d".
end.
else do:
    hopt = trxhead.opt.
    hopt-f = trxhead.opt-f.
end.

/*Transaction template parametrisation.*/
repeat repl = 1 to hmult:
    for each trxtmpl where trxtmpl.code = trxcode no-lock:
        create tmpl.
        if repl = 1 then tmpl.ln = trxtmpl.ln.
        else tmpl.ln = trxtmpl.ln + (repl - 1) * nl.
        tmpl.code = trxtmpl.code.
        tmpl.system = trxtmpl.system.

        /*5)Amount*/
        if trxtmpl.amt-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(Amt)-required.".
                return.
            end.
            tmpl.amt = decimal(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(Amt)=" + vpar + "-decimal expected.".
                return.
            end.
            tmpl.amt-f = "d".
        end.
        else do:
            tmpl.amt = trxtmpl.amt.
            NN = integer(substr(trxtmpl.amt-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.amt-f = string(NN,"9999") + substring(trxtmpl.amt-f,2,1).
            end.
            else tmpl.amt-f = trxtmpl.amt-f.
        end.

        /*6)Currency*/
        if trxtmpl.crc-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(CRC)-required.".
                return.
            end.
            tmpl.crc = integer(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(CRC)=" + vpar + "-integer expected.".
                return.
            end.
            tmpl.crc-f = "d".
        end.
        else do:
            tmpl.crc = trxtmpl.crc.
            tmpl.crc-f = trxtmpl.crc-f.
        end.

        /*7)Rate*/
        if trxtmpl.rate-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(Rate)-required.".
                return.
            end.
            tmpl.rate = decimal(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(Rate)=" + vpar + "-decimal expected.".
                return.
            end.
            tmpl.rate-f = "d".
        end.
        else do:
            tmpl.rate = trxtmpl.rate.
            NN = integer(substr(trxtmpl.rate-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.rate-f = string(NN,"9999") + substring(trxtmpl.rate-f,2,1).
            end.
            else tmpl.rate-f = trxtmpl.rate-f.
        end.

        /*8)Debet G/L*/
        if trxtmpl.drgl-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(DR-GL)-required.".
                return.
            end.
            tmpl.drgl = integer(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(DR-GL)=" + vpar + "-integer expected.".
                return.
            end.
            tmpl.drgl-f = "d".
        end.
        else do:
            tmpl.drgl = trxtmpl.drgl.
            NN = integer(substr(trxtmpl.drgl-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.drgl-f = string(NN,"9999") + substring(trxtmpl.drgl-f,2,1).
            end.
            else tmpl.drgl-f = trxtmpl.drgl-f.
        end.

        /*9)Debet subledger type*/
        if trxtmpl.drsub-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(DR-SUB)-required.".
                return.
            end.
            tmpl.drsub = vpar.
            if tmpl.drsub = ? then tmpl.drsub = "".
            tmpl.drsub-f = "d".
        end.
        else do:
            tmpl.drsub = trxtmpl.drsub.
            NN = integer(substr(trxtmpl.drsub-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.drsub-f = string(NN,"9999") + substring(trxtmpl.drsub-f,2,1).
            end.
            else tmpl.drsub-f = trxtmpl.drsub-f.
        end.

        /*9a)Debet subledger level*/
        if trxtmpl.dev-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(Dev)-required.".
                return.
            end.
            tmpl.dev = integer(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(Dev)=" + vpar + "-integer expected.".
                return.
            end.
            tmpl.dev-f = "d".
        end.
        else do:
            tmpl.dev = trxtmpl.dev.
            NN = integer(substr(trxtmpl.dev-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.dev-f = string(NN,"9999") + substring(trxtmpl.dev-f,2,1).
            end.
            else tmpl.dev-f = trxtmpl.dev-f.
        end.

        /*10)Debet account*/
        if trxtmpl.dracc-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(DR-ACC)-required.".
                return.
            end.
            tmpl.dracc = vpar.
            if tmpl.dracc = ? then tmpl.dracc = "".
            tmpl.dracc-f = "d".
        end.
        else do:
            tmpl.dracc = trxtmpl.dracc.
            NN = integer(substr(trxtmpl.dracc-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.dracc-f = string(NN,"9999") + substring(trxtmpl.dracc-f,2,1).
            end.
            else tmpl.dracc-f = trxtmpl.dracc-f.
        end.

        /*11)Credit G/L*/
        if trxtmpl.crgl-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(CR-GL)-required.".
                return.
            end.
            tmpl.crgl = integer(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(CR-GL)=" + vpar + "-integer expected.".
                return.
            end.
            tmpl.crgl-f = "d".
        end.
        else do:
            tmpl.crgl = trxtmpl.crgl.
            NN = integer(substr(trxtmpl.crgl-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.crgl-f = string(NN,"9999") + substring(trxtmpl.crgl-f,2,1).
            end.
            else tmpl.crgl-f = trxtmpl.crgl-f.
        end.

        /*12)Credit subledger type*/
        if trxtmpl.crsub-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(CR-SUB)-required.".
                return.
            end.
            tmpl.crsub = vpar.
            if tmpl.crsub = ? then tmpl.crsub = "".
            tmpl.crsub-f = "d".
        end.
        else do:
            tmpl.crsub = trxtmpl.crsub.
            NN = integer(substr(trxtmpl.crsub-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.crsub-f = string(NN,"9999") + substring(trxtmpl.crsub-f,2,1).
            end.
            else tmpl.crsub-f = trxtmpl.crsub-f.
        end.

        /*12a)Credit subledger level*/
        if trxtmpl.cev-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(Cev)-required.".
                return.
            end.
            tmpl.cev = integer(vpar) no-error.
            if ERROR-STATUS:error then do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr." + string(i)
                                      + "(Cev)=" + vpar + "-integer expected.".
                return.
            end.
            tmpl.cev-f = "d".
        end.
        else do:
            tmpl.cev = trxtmpl.cev.
            NN = integer(substr(trxtmpl.cev-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.cev-f = string(NN,"9999") + substring(trxtmpl.cev-f,2,1).
            end.
            else tmpl.cev-f = trxtmpl.cev-f.
        end.

        /*13)Credit account*/
        if trxtmpl.cracc-f = "r" then do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if ERROR-STATUS:error then do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                      + ",Ln=" + string(tmpl.ln)
                                      + ",Re=" + string(repl)
                                      + ",Nr=" + string(i)
                                      + "(CR-ACC)-required.".
                return.
            end.
            tmpl.cracc = vpar.
            if tmpl.cracc = ? then tmpl.cracc = "".
            tmpl.cracc-f = "d".
        end.
        else do:
            tmpl.cracc = trxtmpl.cracc.
            NN = integer(substr(trxtmpl.cracc-f,1,1)) no-error.
            if not ERROR-STATUS:error then do:
                NN = NN + (repl - 1) * nl.
                tmpl.cracc-f = string(NN,"9999") + substring(trxtmpl.cracc-f,2,1).
            end.
            else tmpl.cracc-f = trxtmpl.cracc-f.
        end.

        /*14)Remarks*/
        do k = 1 to 5:
            if trxtmpl.rem-f[k] = "r" then do:
                i = i + 1.
                vpar = entry(i,vparam,vdel) no-error.
                if ERROR-STATUS:error then do:
                    rcode = 29.
                    rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                          + ",Ln=" + string(tmpl.ln)
                                          + ",Re=" + string(repl)
                                          + ",Nr=" + string(i)
                                          + "(Rem[" + string(k) + "])-required.".
                    return.
                end.
                tmpl.rem[k] = vpar.
                tmpl.rem-f[k] = "d".
            end.
            else do:
                tmpl.rem[k] = trxtmpl.rem[k].
                tmpl.rem-f[k] = trxtmpl.rem-f[k].
            end.
        end.
    end. /* for each trxtmpl */
end. /* repeat mult */

i = i + 1.
vpar = entry(i,vparam,vdel) no-error.
if ERROR-STATUS:error = false and vpar <> "" then do:
    rcode = 30.
    rdes = errlist[rcode] + ":Tmpl=" + trxcode
                          + ",Nr=" + string(i)
                          + "(???)=" + vpar + "-unexpected.".
    return.
end.

/*******************************************************/
/*Transaction template parameter's automatic evaluation*/
/*******************************************************/

if hsts-f <> "d" then do:
    run stsauto.
    if rcode > 0 then return.
end.
if hparty-f <> "d" then do:
    run partyauto.
    if rcode > 0 then return.
end.
if hpoint-f <> "d" then do:
    run pointauto.
    if rcode > 0 then return.
end.
if hdepart-f <> "d" then do:
    run departauto.
    if rcode > 0 then return.
end.

for each tmpl:
    if tmpl.amt-f <> "d" then do:
        run amtauto.
        if rcode > 0 then return.
    end.
    if tmpl.rate-f <> "d" then do:
        run rateauto.
        if rcode > 0 then return.
    end.
    if tmpl.crc-f <> "d" then do:
        run crcauto.
        if rcode > 0 then return.
    end.

    /* подстановка корректных счетов конвертации */
    if tmpl.drgl-f = "d" and tmpl.drgl = 1 then tmpl.drgl = getConvGL(tmpl.crc,"D").
    if tmpl.crgl-f = "d" and tmpl.crgl = 1 then tmpl.crgl = getConvGL(tmpl.crc,"C").
    /* подстановка корректных счетов конвертации - end */

    if tmpl.drgl-f <> "d" then do:
        run drglauto.
        if rcode > 0 then return.
    end.
    if tmpl.drsub-f <> "d" then do:
        run drsubauto.
        if rcode > 0 then return.
    end.
    if tmpl.dracc-f <> "d" then do:
        run draccauto.
        if rcode > 0 then return.
    end.
    if tmpl.crgl-f <> "d" then do:
        run crglauto.
        if rcode > 0 then return.
    end.
    if tmpl.crsub-f <> "d" then do:
        run crsubauto.
        if rcode > 0 then return.
    end.
    if tmpl.cracc-f <> "d" then do:
        run craccauto.
        if rcode > 0 then return.
    end.
    repeat o = 1 to 5:
        if tmpl.rem-f[o] <> "d" then do:
            run remauto.
            if rcode > 0 then return.
        end.
    end.
end. /* for each tmpl */


run trxchk1(output rcode, output rdes).
if rcode > 0 then return.
run auto_parami_dent(trxcode, vnum, output vparr).

/*************************************************************/
/*               Auto evaluation procedures                  */
/*************************************************************/
/*1)Status*/
procedure stsauto.
    hsts = 0.
    hsts-f = "d".
end procedure.

/*2)Party*/
procedure partyauto.
    hparty = "".
    hparty-f = "d".
end procedure.

/*3)Point*/
procedure pointauto.
    find ofc where ofc.ofc = g-ofc no-lock.
    hpoint = integer(ofc.regno) / 1000 - 0.5.
    hpoint-f = "d".
end procedure.

/*4)Depart*/
procedure departauto.
    find ofc where ofc.ofc = g-ofc no-lock.
    hdepart = integer(ofc.regno) - hpoint * 1000.
    hdepart-f = "d".
end procedure.

/*5)Amount*/
procedure amtauto.
    if tmpl.rate-f <> "d" then run rateauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.crc-f <> "d" then run crcauto.
    N = integer(substring(tmpl.amt-f,1,4)).
    vsign = substring(tmpl.amt-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then do:
        rcode = 20.
        rdes = errlist[rcode] + " - amtauto (refference line not found).".
        return.
    end.
    if tmpl.amt-f <> "d" then run amtauto.
    if tmpl.rate-f <> "d" then run rateauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.crc-f <> "d" then run crcauto.
    vrate = tmpl.rate.
    vamt = tmpl.amt.
    vcrc = tmpl.crc.
    if isConvGL(tmpl.crgl)  /* tmpl.crgl = buy.inval*/ then do:
        selbuy = "buy".
        vcrc1 = vcrc.
        amt1 = vamt.
        cas1 = false.
        if tmpl.drgl = cas.inval or tmpl.drgl = 100500 then cas1 = true.
        find tmpl where recid(tmpl) = crec.
        vcrc2 = tmpl.crc.
        cas2 = false.
        if tmpl.crgl = cas.inval or tmpl.crgl = 100500 then cas2 = true.
    end.
    else if isConvGL(tmpl.drgl)  /* tmpl.drgl = sel.inval*/ then do:
        selbuy = "sel".
        vcrc2 = vcrc.
        amt2 = vamt.
        cas2 = false.
        if tmpl.crgl = cas.inval or tmpl.crgl = 100500 then cas2 = true.
        find tmpl where recid(tmpl) = crec.
        vcrc1 = tmpl.crc.
        cas1 = false.
        if tmpl.drgl = cas.inval or tmpl.drgl = 100500 then cas1 = true.
    end.
    else selbuy = "".
    find tmpl where recid(tmpl) = crec.
    find crc where crc.crc = tmpl.crc no-lock.
    vdecpnt = crc.decpnt.
    find crc where crc.crc = vcrc no-lock.
    if vsign = "" then do:
        if amt1 = 0 then do:
            run conv(vcrc1,vcrc2,cas1,cas2,input-output tmpl.amt,input-output amt2,
                     output vrat1, output vrat2, output coef1, output coef2,
                     output marg1, output marg2).
            tmpl.rate = vrat1 / coef1.
            tmpl.rate-f = "d".
            find first tmpl where tmpl.ln = N no-error.
            tmpl.rate = vrat2 / coef2.
            tmpl.rate-f = "d".
            find tmpl where recid(tmpl) = crec.
        end.
        else do:
            run conv-obm(vcrc1,vcrc2,input-output amt1,input-output tmpl.amt,
                     output vrat1, output vrat2, output coef1, output coef2,
                     output marg1, output marg2).
            tmpl.rate = vrat2 / coef2.
            tmpl.rate-f = "d".
            find first tmpl where tmpl.ln = N no-error.
            tmpl.rate = vrat1 / coef1.
            tmpl.rate-f = "d".
            find tmpl where recid(tmpl) = crec.
        end.
        tmpl.amt-f = "d".
    end.
    else do:
        if selbuy = "buy" then vmarg = round(vamt * (crc.rate[1] / crc.rate[9] - vrate), vdecpnt).
        else
        if selbuy = "sel" then vmarg = round(vamt * (vrate - crc.rate[1] / crc.rate[9]), vdecpnt).
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " - amtauto (position error).".
            return.
        end.
        if vmarg > 0 and vsign = "+" then tmpl.amt = vmarg.
        else
        if vmarg < 0 and vsign = "-" then tmpl.amt = - vmarg.
        tmpl.amt-f = "d".
        if vsign = "M" then do:
            find crc where crc.crc = tmpl.crc no-lock.
            tmpl.amt =  round(vamt * vrate / ( crc.rate[1] / crc.rate[9] ), crc.decpnt).
        end.
    end.
end procedure.

procedure rateauto.
    if tmpl.crc-f <> "d" then run crcauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.rate-f = "M" then do:
        find crc where crc.crc = tmpl.crc no-lock.
        tmpl.rate = crc.rate[1] / crc.rate[9].
        return.
    end.
    if tmpl.rate-f = "a" then do:
        find crc where crc.crc = tmpl.crc no-lock.
        if isConvGL(tmpl.crgl)  /* tmpl.crgl = buy.inval*/ then do:
            if tmpl.drgl = cas.inval or tmpl.drgl = 100500 then do:
                tmpl.rate = crc.rate[2] / crc.rate[9].
                tmpl.rate-f = "d".
            end.
            else do:
                tmpl.rate = crc.rate[2] / crc.rate[9].
                tmpl.rate-f = "d".
            end.
        end.
        else
        if isConvGL(tmpl.drgl)  /* tmpl.drgl = sel.inval*/ then do:
            if tmpl.crgl = cas.inval or tmpl.crgl = 100500 then do:
                tmpl.rate = crc.rate[3] / crc.rate[9].
                tmpl.rate-f = "d".
            end.
            else do:
                tmpl.rate = crc.rate[3] / crc.rate[9].
                tmpl.rate-f = "d".
            end.
        end.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " - rateauto (position error).".
            return.
        end.
    end. /*tmpl.rate-f = "a"*/
    else do:
        N = integer(tmpl.rate-f).
        if tmpl.amt-f <> "d" then run amtauto.
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then do:
            rcode = 20.
            rdes = errlist[rcode] + " - rateauto (refference line not found).".
            return.
        end.
        if tmpl.amt-f <> "d" then run amtauto.
        if tmpl.rate-f <> "d" then run rateauto.
        vrate = tmpl.rate.
        vamt = tmpl.amt.
        find tmpl where recid(tmpl) = crec.
        tmpl.rate = vrate * vamt / tmpl.amt.
        tmpl.rate-f = "d".
     end.
end procedure.

/*6)Currency*/
procedure crcauto.
    if tmpl.drsub-f <> "d" then run drsubauto.
    if tmpl.dracc-f <> "d" then run draccauto.
    if tmpl.drsub <> "" then run trxcrcacc(tmpl.drsub, tmpl.dracc).
    if tmpl.crsub-f <> "d" then run crsubauto.
    if tmpl.cracc-f <> "d" then run craccauto.
    if tmpl.crsub <> "" then run trxcrcacc(tmpl.crsub, tmpl.cracc).
    if tmpl.drsub = "" and tmpl.crsub = "" then do:
        rcode = 20.
        rdes = errlist[rcode] + " crc <- acc." + "Line=" + string(tmpl.ln,"9").
        return.
    end.
end procedure.

/*8)Debet G/L*/
procedure drglauto.
    def var vsign as char.
    if tmpl.drgl-f = "a" then do:
        if tmpl.dracc-f <> "d" then run draccauto.
        if tmpl.dracc = "" then do:
            rcode = 20.
            rdes = errlist[rcode] + " drgl <- dracc.".
            return.
        end.
        else do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            if tmpl.drsub = "" then do:
                rcode = 20.
                rdes = errlist[rcode] + " drgl <- dracc.".
                return.
            end.
            else do:
                run trxglacc(tmpl.drsub, tmpl.dracc, tmpl.dev, output vgl).
                if rcode = 0 then tmpl.drgl = vgl.
            end.
        end.
    end.
    else do:
        N = integer(substring(tmpl.drgl-f,1,4)).
        vsign = substring(tmpl.drgl-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then do:
            rcode = 20.
            rdes = errlist[rcode] + " - drglauto (refference line not found).".
            return.
        end.
        if vsign = "+" then do:
            if tmpl.drgl-f <> "d" then run drglauto.
            vgl = tmpl.drgl.
        end.
        else do:
            if tmpl.crgl-f <> "d" then run crglauto.
            vgl = tmpl.crgl.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.drgl = vgl.
        tmpl.drgl-f = "d".
    end.
end procedure.

procedure drsubauto.
    def var vsub as char.
    if tmpl.drsub-f = "a" then do:
        if tmpl.drgl-f <> "d" then run drglauto.
        find gl where gl.gl = tmpl.drgl no-lock no-error.
        if available gl then do:
            tmpl.drsub = gl.subled.
            tmpl.drsub-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " drsub <- drgl.".
            return.
        end.
    end.
    else do:
        N = integer(substring(tmpl.drsub-f,1,4)).
        vsign = substring(tmpl.drsub-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then do:
            rcode = 20.
            rdes = errlist[rcode] + " - drsubauto (refference line not found).".
            return.
        end.
        if vsign = "+" then do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            vsub = tmpl.drsub.
        end.
        else do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            vsub = tmpl.crsub.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.drsub = vsub.
        tmpl.drsub-f = "d".
    end.
end procedure.

procedure draccauto.
    def var vacc as char.
    N = integer(substring(tmpl.dracc-f,1,4)).
    vsign = substring(tmpl.dracc-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then do:
        rcode = 20.
        rdes = errlist[rcode] + " - draccauto (refference line not found).".
        return.
    end.
    if vsign = "+" then do:
        if tmpl.dracc-f <> "d" then run draccauto.
        vacc = tmpl.dracc.
    end.
    else do:
        if tmpl.cracc-f <> "d" then run craccauto.
        vacc = tmpl.cracc.
    end.
    find tmpl where recid(tmpl) = crec.
    tmpl.dracc = vacc.
    tmpl.dracc-f = "d".
end procedure.

/*8)Credit G/L*/
procedure crglauto.
    if tmpl.crgl-f = "a" then do:
        if tmpl.cracc-f <> "d" then run craccauto.
        if tmpl.cracc = "" then do:
            rcode = 20.
            rdes = errlist[rcode] + " crgl <- cracc.".
            return.
        end.
        else do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            if tmpl.crsub = "" then do:
                rcode = 20.
                rdes = errlist[rcode] + " crgl <- cracc.".
                return.
            end.
            else do:
                run trxglacc(tmpl.crsub, tmpl.cracc, tmpl.cev, output vgl).
                if rcode = 0 then tmpl.crgl = vgl.
            end.
        end.
    end.
    else do:
        N = integer(substring(tmpl.crgl-f,1,4)).
        vsign = substring(tmpl.crgl-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then do:
            rcode = 20.
            rdes = errlist[rcode] + " - crglauto (refference line not found).".
            return.
        end.
        if vsign = "+" then do:
            if tmpl.crgl-f <> "d" then run crglauto.
            vgl = tmpl.crgl.
        end.
        else do:
            if tmpl.drgl-f <> "d" then run drglauto.
            vgl = tmpl.drgl.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.crgl = vgl.
        tmpl.crgl-f = "d".
    end.
end procedure.

procedure crsubauto.
    def var vsub as char.
    if tmpl.crsub-f = "a" then do:
        if tmpl.crgl-f <> "d" then run crglauto.
        find gl where gl.gl = tmpl.crgl no-lock no-error.
        if available gl then do:
            tmpl.crsub = gl.subled.
            tmpl.crsub-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " crsub <- crgl.".
            return.
        end.
    end.
    else do:
        N = integer(substring(tmpl.crsub-f,1,4)).
        vsign = substring(tmpl.crsub-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then do:
            rcode = 20.
            rdes = errlist[rcode] + " - crsubauto (refference line not found).".
            return.
        end.
        if vsign = "+" then do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            vsub = tmpl.crsub.
        end.
        else do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            vsub = tmpl.drsub.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.crsub = vsub.
        tmpl.crsub-f = "d".
    end.
end procedure.

procedure craccauto.
    def var vacc as char.
    N = integer(substring(tmpl.cracc-f,1,4)).
    vsign = substring(tmpl.cracc-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then do:
        rcode = 20.
        rdes = errlist[rcode] + " - craccauto (refference line not found).".
        return.
    end.
    if vsign = "+" then do:
        if tmpl.cracc-f <> "d" then run craccauto.
        vacc = tmpl.cracc.
    end.
    else do:
        if tmpl.dracc-f <> "d" then run draccauto.
        vacc = tmpl.dracc.
    end.
    find tmpl where recid(tmpl) = crec.
    tmpl.cracc = vacc.
    tmpl.cracc-f = "d".
end procedure.

procedure trxcrcacc.
    def input parameter vsub as char.
    def input parameter vacc as char.
    if vsub = "arp" then do:
        find arp where arp.arp = vacc no-lock no-error.
        if available arp then do:
            tmpl.crc = arp.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "ast" then do:
        find ast where ast.ast = vacc no-lock no-error.
        if available ast then do:
            tmpl.crc = ast.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "cif" then do:
        find aaa where aaa.aaa = vacc no-lock no-error.
        if available aaa then do:
            tmpl.crc = aaa.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "dfb" then do:
        find dfb where dfb.dfb = vacc no-lock no-error.
        if available dfb then do:
            tmpl.crc = dfb.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "eps" then do:
        find eps where eps.eps = vacc no-lock no-error.
        if available eps then do:
            tmpl.crc = eps.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "fun" then do:
        find fun where fun.fun = vacc no-lock no-error.
        if available fun then do:
            tmpl.crc = fun.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "lcr" then do:
        find lcr where lcr.lcr = vacc no-lock no-error.
        if available lcr then do:
            tmpl.crc = lcr.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "lon" then do:
        find lon where lon.lon = vacc no-lock no-error.
        if available lon then do:
            tmpl.crc = lon.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "ock" then do:
        find ock where ock.ock = vacc no-lock no-error.
        if available ock then do:
            tmpl.crc = ock.crc.
            tmpl.crc-f = "d".
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
end procedure.

procedure trxglacc.
    def input parameter vsub as char.
    def input parameter vacc as char.
    def input parameter vlev as inte.
    def output parameter vgl as inte.
    if vsub = "arp" then do:
        find arp where arp.arp = vacc no-lock no-error.
        if available arp then vgl = arp.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";gl <- acc.".
            return.
        end.
    end.
    else
    if vsub = "ast" then do:
        find ast where ast.ast = vacc no-lock no-error.
        if available ast then vgl = ast.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";gl <- acc.".
            return.
        end.
    end.
    else
    if vsub = "cif" then do:
        find aaa where aaa.aaa = vacc no-lock no-error.
        if available aaa then do:
            if vlev = 1 then vgl = aaa.gl.
            else do:
                find trxlevgl where trxlevgl.gl = aaa.gl and trxlevgl.level = vlev no-lock no-error.
                if available trxlevgl then vgl = trxlevgl.glr.
                else do:
                    rcode = 28.
                    rdes = errlist[rcode] + " Subledger = " + vsub + "; level = " + string(vlev,"z9") + "; G/L(1) = " + string(aaa.gl,"999999") + ".".
                    return.
                end.
            end.
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "dfb" then do:
        find dfb where dfb.dfb = vacc no-lock no-error.
        if available dfb then vgl = dfb.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "eps" then do:
        find eps where eps.eps = vacc no-lock no-error.
        if available eps then vgl = eps.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "fun" then do:
        find fun where fun.fun = vacc no-lock no-error.
        if available fun then vgl = fun.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "lcr" then do:
        find lcr where lcr.lcr = vacc no-lock no-error.
        if available lcr then vgl = lcr.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else
    if vsub = "lon" then do:
        find lon where lon.lon = vacc no-lock no-error.
        if available lon then vgl = lon.gl.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
    else if vsub = "ock" then do:
        find ock where ock.ock = vacc no-lock no-error.
        if available ock then do:
            if vlev = 1 then vgl = ock.gl.
            else do:
                find trxlevgl where trxlevgl.gl = ock.gl and trxlevgl.level = vlev no-lock no-error.
                if available trxlevgl then vgl = trxlevgl.glr.
                else do:
                    rcode = 28.
                    rdes = errlist[rcode] + " Subledger = " + vsub + "; level = " + string(vlev,"z9") + "; G/L(1) = " + string(ock.gl,"999999") + ".".      return.
                end.
            end.
        end.
        else do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":subled=" + vsub + ";acc=" + vacc + "Line=" + string(tmpl.ln,"9") + ";crc <- acc.".
            return.
        end.
    end.
end procedure.

procedure remauto.
    def var vsign as char.
    N = integer(substring(tmpl.rem-f[o],1,4)).
    vsign = substring(tmpl.rem-f[o],5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then do:
        rcode = 20.
        rdes = errlist[rcode] + " - rem (refference line not found).".
        return.
    end.
    if tmpl.rem-f[o] <> "d" then run remauto.
    vrem = tmpl.rem[o].
    find tmpl where recid(tmpl) = crec.
    tmpl.rem[o] = vrem.
    tmpl.rem-f[o] = "d".
end procedure.

procedure auto_parami_dent.
    def input parameter jcode as char.
    def input parameter jnum as inte.
    def output parameter jpar as char.
    def var i as inte format "zzzzzz9".
    def var k as inte format "zzzzzz9".
    find trxhead where trxhead.system = substring(jcode,1,3) and trxhead.code = integer(substring(jcode,4)) no-lock.
    i = 0.
    if trxhead.sts-f <> "r" and trxhead.sts-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = string(hsts).
            return.
        end.
    end.
    if trxhead.party-f <> "r" and trxhead.party-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = hparty.
            return.
        end.
    end.
    if trxhead.point-f <> "r" and trxhead.point-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = string(hpoint).
            return.
        end.
    end.
    if trxhead.depart-f <> "r" and trxhead.depart-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = string(hdepart).
            return.
        end.
    end.
    if trxhead.mult-f <> "r" and trxhead.mult-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = string(hmult).
            return.
        end.
    end.
    if trxhead.opt-f <> "r" and trxhead.opt-f <> "d" then do:
        i = i + 1.
        if jnum = i then do:
            jpar = hopt.
            return.
        end.
    end.

    for each trxtmpl where trxtmpl.code = jcode no-lock:
        if trxtmpl.amt-f <> "r" and trxtmpl.amt-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.amt).
                return.
            end.
        end.
        if trxtmpl.crc-f <> "r" and trxtmpl.crc-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.crc).
                return.
            end.
        end.
        if trxtmpl.rate-f <> "r" and trxtmpl.rate-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.rate).
                return.
            end.
        end.
        if trxtmpl.drgl-f <> "r" and trxtmpl.drgl-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.drgl).
                return.
            end.
        end.
        if trxtmpl.drsub-f <> "r" and trxtmpl.drsub-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = tmpl.drsub.
                return.
            end.
        end.
        if trxtmpl.dev-f <> "r" and trxtmpl.dev-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.dev).
                return.
            end.
        end.
        if trxtmpl.dracc-f <> "r" and trxtmpl.dracc-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = tmpl.dracc.
                return.
            end.
        end.
        if trxtmpl.crgl-f <> "r" and trxtmpl.crgl-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.crgl).
                return.
            end.
        end.
        if trxtmpl.crsub-f <> "r" and trxtmpl.crsub-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = tmpl.crsub.
                return.
            end.
        end.
        if trxtmpl.cev-f <> "r" and trxtmpl.cev-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = string(tmpl.cev).
                return.
            end.
        end.
        if trxtmpl.cracc-f <> "r" and trxtmpl.cracc-f <> "d" then do:
            i = i + 1.
            if jnum = i then do:
                find first tmpl where tmpl.ln = trxtmpl.ln.
                jpar = tmpl.cracc.
                return.
            end.
        end.
    end. /* for each trxtmpl */
end procedure.

procedure trxpcrcif.
    def input parameter vacc as char.
    def input parameter vcur as inte.
    def output parameter pcrcif as char initial ?.
    find crdcard where crdcard.crcard = vacc and crdcard.crc = vcur no-lock no-error.
    if available crdcard then pcrcif = crdcard.bacc.
end procedure.
