/* trxgen0-obm.p
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
        29.07.2002 - BY SASCO - обработка параметра "b" "s"
                               курсы покупки/продажи налом
        23/12/03 sasco переделал обработку дебиторов
        07/03/2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        16/03/2004 kanat закоментировал лишний цикл для create cdf так как не работали обменные операции со льготными курсами,
                         предварительно было проведено тестирование.
        01/09/04 sasco русифицировал ошибки генератора транзакций
        24.05.2012 evseev - изменения в trx-aaafiz.i
        26/11/2012 Luiza  - подключила convgl.i  ТЗ 1374

*/

{global.i}

def input parameter trxcode as char.
def input parameter vdel as char.
def input parameter vparam as char.
def input parameter vsub as char.
def input parameter vhref as char.

def output parameter rcode as inte.
def output parameter rdes as char.
def input-output parameter vjh as inte.
def new shared var s-jh as inte.
def var i as inte.
def var k as inte.
def var vpar as char.
def var errlist as char extent 37.
def new shared temp-table tmpl like trxtmpl.
def new shared temp-table cdf like trxcdf.
def buffer btmpl for tmpl.
def var vgl as inte.
def var vref as inte.
def var vsign as char.
def new shared var jh-ref as cha .
def new shared var jh-sub as cha .
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
def var vdec as inte.
def var repl as inte.
def var nl as inte.
def var NN as inte.
def var vrem as char.
def var o as inte.

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

/*
errlist[18] = "Specified TRX code doesn't exist.".
errlist[19] = "Incorrect parameter list.".
errlist[20] = "Template error.".
errlist[28] = "G/L for specified level not defined.".
errlist[29] = "Unexpected end of parameter list.".
errlist[30] = "One or more extra params in paramlist.".
errlist[36] = "We don't buy this currency.".
errlist[37] = "We don't sell this currency.".
*/

errlist[18] = "Указанный шаблон не найден.".
errlist[19] = "Неправильный список параметров.".
errlist[20] = "Ошибка шаблона.".
errlist[28] = "Не определена Г/К для указанного уровня.".
errlist[29] = "Недостаточное количество параметров шаблона.".
errlist[30] = "Слишком много параметров для проводки.".
errlist[36] = "Банк не покупает эту валюту.".
errlist[37] = "Банк не продает эту валюту.".


find cas where cas.sysc = "cashgl" no-lock no-error.
/*find buy where buy.sysc = "buygl" no-lock no-error.
find sel where sel.sysc = "selgl" no-lock no-error.*/
{convgl.i "bank"}


jh-ref = vhref .
jh-sub = vsub .

find last trxtmpl where trxtmpl.code = trxcode no-lock no-error.
if not available trxtmpl then do:
   rcode = 18.
   rdes = errlist[18] + ": " + trxcode + ".".
   return.
end.
else nl = trxtmpl.ln.

find trxhead where trxhead.code = integer(substring(trxtmpl.code,4))
               and trxhead.system = trxtmpl.system no-lock.

     hopt = trxhead.opt.

/*1)Status*/
    if trxhead.sts-f = "r" then do:
       i = i + 1.
       vpar = entry(i,vparam,vdel) no-error.
       if ERROR-STATUS:error then do:
            rcode = 29.
            rdes = errlist[rcode] + ":Tmpl" + trxcode
                                  + ",Nr." + string(i)
                                  + "(Status)-требуется.".
            return.
       end.
       hsts = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
         rcode = 19.
         rdes = errlist[rcode] + ":Tmpl" + trxcode
                               + ",Nr." + string(i)
                               + "(Status)=" + vpar + "-нужен тип integer.".
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
            rdes = errlist[rcode] + ":Tmpl" + trxcode
                                  + ",Nr." + string(i)
                                  + "(Party)-требуется.".
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
            rdes = errlist[rcode] + ":Tmpl" + trxcode
                                  + ",Nr." + string(i)
                                  + "(Point)-требуется.".
            return.
       end.
       hpoint = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
         rcode = 19.
         rdes = errlist[rcode] + ":Tmpl" + trxcode
                               + ",Nr." + string(i)
                               + "(Point)=" + vpar + "-нужен тип integer.".
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
            rdes = errlist[rcode] + ":Tmpl" + trxcode
                                  + ",Nr." + string(i)
                                  + "(Depart)-требуется.".
            return.
       end.
       hdepart = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
         rcode = 19.
         rdes = errlist[rcode] + ":Tmpl" + trxcode
                               + ",Nr." + string(i)
                               + "(Depart)=" + vpar + "-нужен тип integer.".
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
            rdes = errlist[rcode] + ":Tmpl" + trxcode
                                  + ",Nr." + string(i)
                                  + "(Repl)-требуется.".
            return.
       end.
       hmult = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
         rcode = 19.
         rdes = errlist[rcode] + ":Tmpl" + trxcode
                               + "Nr." + string(i)
                               + "(Repl)=" + vpar + "-нужен тип integer.".
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
                                  + "(Opti)-требуется.".
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
/*Codificators temp-table records creading according to templates*/
/*
    for each trxcdf where trxcdf.trxcode = trxtmpl.code
                      and trxcdf.trxln = trxtmpl.ln no-lock:
        create cdf.
        cdf.trxcode = trxcdf.trxcode.
        cdf.trxln = tmpl.ln.
        cdf.codfr = trxcdf.codfr.
        cdf.drcod = trxcdf.drcod.
        cdf.crcod = trxcdf.crcod.
    end.
*/
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
                                  + "(Amt)-требуется.".
            return.
       end.
       tmpl.amt = decimal(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(Amt)=" + vpar + "-нужен тип decimal.".
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
                                  + "(CRC)-требуется.".
            return.
       end.
       tmpl.crc = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(CRC)=" + vpar + "-нужен тип integer.".
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
                                  + "(Rate)-требуется.".
            return.
       end.
       tmpl.rate = decimal(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(Rate)=" + vpar + "-нужен тип decimal.".
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
                                  + "(DR-GL)-требуется.".
            return.
       end.
       tmpl.drgl = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(DR-GL)=" + vpar + "-нужен тип integer.".
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
                                  + "(DR-SUB)-требуется.".
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
                                  + "(Dev)-требуется.".
            return.
       end.
       tmpl.dev = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(Dev)=" + vpar + "-нужен тип integer.".
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
                                  + "(DR-ACC)-требуется.".
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
                                  + "(CR-GL)-требуется.".
            return.
       end.
       tmpl.crgl = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(CR-GL)=" + vpar + "-нужен тип integer.".
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
                                  + "(CR-SUB)-требуется.".
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
                                  + "(Cev)-требуется.".
            return.
       end.
       tmpl.cev = integer(vpar) no-error.
       if ERROR-STATUS:error then do:
            rcode = 19.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr." + string(i)
                                  + "(Cev)=" + vpar + "-нужен тип integer.".
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
                                  + "(CR-ACC)-требуется.".
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
                                  + "(Rem[" + string(k) + "])-требуется.".
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
/*Codificators temp-table records creation according to templates*/
    for each trxcdf where trxcdf.trxcode = trxtmpl.code
                      and trxcdf.trxln = trxtmpl.ln:
        create cdf.
        cdf.trxcode = trxcdf.trxcode.
        cdf.trxln = tmpl.ln.
        cdf.codfr = trxcdf.codfr.
     if trxcdf.drcod-f = "d" or trxcdf.drcod-f = "" then do:
        cdf.drcod = trxcdf.drcod.
        cdf.drcod-f = trxcdf.drcod-f.
     end.
     else do:
      if trxcdf.drcod-f = "r" then do:
        i = i + 1.
        vpar = entry(i,vparam,vdel) no-error.
        if ERROR-STATUS:error then do:
            rcode = 29.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr=" + string(i)
                                  + "Codific." + trxcdf.codfr
                                  + "DrCode - требуется".
            return.
        end.
        cdf.drcod = vpar.
        if cdf.drcod = ? then cdf.drcod = "".
        cdf.drcod-f = "d".
      end.
      else do:
        cdf.drcod = trxcdf.drcod.
          NN = integer(substr(trxcdf.drcod-f,1,1)) no-error.
          if not ERROR-STATUS:error then do:
             NN = NN + (repl - 1) * nl.
             cdf.drcod-f = string(NN,"9999") + substring(trxcdf.drcod-f,2,1).
          end.
          else cdf.drcod-f = trxcdf.drcod-f.
      end.
     end.
     if trxcdf.crcode-f = "d" or trxcdf.crcode-f = "" then do:
        cdf.crcod = trxcdf.crcod.
        cdf.crcode-f = trxcdf.crcode-f.
     end.
     else do:
      if trxcdf.crcode-f = "r" then do:
        i = i + 1.
        vpar = entry(i,vparam,vdel) no-error.
        if ERROR-STATUS:error then do:
            rcode = 29.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Ln=" + string(tmpl.ln)
                                  + ",Re=" + string(repl)
                                  + ",Nr=" + string(i)
                                  + "Codific." + trxcdf.codfr
                                  + " CrCode - требуется".
            return.
        end.
        cdf.crcod = vpar.
        if cdf.crcod = ? then cdf.crcod = "".
        cdf.crcode-f = "d".
      end.
      else do:
        cdf.crcod = trxcdf.crcod.
          NN = integer(substr(trxcdf.crcode-f,1,1)) no-error.
          if not ERROR-STATUS:error then do:
             NN = NN + (repl - 1) * nl.
             cdf.crcode-f = string(NN,"9999") + substring(trxcdf.crcode-f,2,1).
          end.
          else cdf.crcode-f = trxcdf.crcode-f.
      end.
     end.
    end.
end. /*For each trxtmpl*/
end. /*Repeat mult*/

       i = i + 1.
       vpar = entry(i,vparam,vdel) no-error.
       if ERROR-STATUS:error = false and vpar <> "" then do:
            rcode = 30.
            rdes = errlist[rcode] + ":Tmpl=" + trxcode
                                  + ",Nr=" + string(i)
                                  + "(???)=" + vpar + "-лишнее.".
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
for each cdf where cdf.trxcode = tmpl.code
                  and cdf.trxln = tmpl.ln:
   if cdf.drcod-f <> "d" and cdf.drcod-f <> "" then do:
     run drcodeauto.
     if rcode > 0 then return.
   end.
   if cdf.crcode-f <> "d" and cdf.crcode-f <> "" then do:
     run crcodeauto.
     if rcode > 0 then return.
   end.
end.
end.

for each tmpl:
   if tmpl.amt = 0 and tmpl.amt-f = "d" then delete tmpl.
end.

/* ---------23/11/2002 nataly - проверка если счет ГК закрыт ---------     */
  find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.drgl) and d-cod  = 'clsa'  no-error.
   if available sub-cod and sub-cod.ccode = '10' then do:
     message "Транзакция невозможна!  Счет ГК " + string(tmpl.drgl) + " закрыт!"
     view-as alert-box.
     rcode = 102.
     rdes = "Счет Г/К " + string(tmpl.drgl) + " закрыт ".
     return.
    end.

  find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.crgl) and d-cod  = 'clsa'  no-error.
   if available sub-cod and sub-cod.ccode = '10' then do:
     message "Транзакция невозможна!  Счет ГК " + string(tmpl.crgl) + " закрыт!"
     view-as alert-box.
     rcode = 102.
     rdes = "Счет Г/К " + string(tmpl.crgl) + " закрыт ".
     return.
    end.

/* --------- 23/11/2002    ------------------------------------------------*/

/*
find first tmpl no-error .
if not avail tmpl then do:
          rcode = 999.
          rdes = "Error. Empty parameters ".
          return.
end.
*/

/* sasco - проверим, есть ли в проводке карточка дебитора */
/* если есть - переменные is-debitor = yes                */
/*                        is-active  = yes/no             */
/*                        re-open    = yes/no             */
/*                        deb-ost    = debls.ost          */
/*                        deb-damcam = tmpl.amt           */
/*                        v-grp      = debls.grp          */
/*                        v-ls       = debls.ls           */
if g-ofc <> "superman" and g-ofc <> "bankadm" then
do:

  /* проверка контроля физ. лиц старшим менеджером */
  {trx-aaafiz.i}

  /* обработка дебиторов */
  {trx-debhist.i "new shared"}
  {trx-debcheck.i}

end.

run trxchk1(output rcode, output rdes).
if rcode > 0 then return.
do transaction:
rcode = 0.
if trxcode ne "CIF0007" then
run trxbal(output rcode, output rdes).
if rcode > 0 then return.

s-jh = vjh.
run trxjlgen(output rcode, output rdes).
if rcode > 0 then return.
vjh = s-jh.

/* sasco - если есть карточка дебитора, */
/* то создать историю движений в debhis */
/* и изменить статус и остаток в debls  */
if g-ofc <> "superman" and g-ofc <> "bankadm" then
do:

/* {trx-debhist.i} */
  {trx-debmon.i}
  run trx-debhist.

end.

end.

/*************************************************************/
/*               Auto evaluation procedures                  */
/*************************************************************/
/*1)Status*/
PROCEDURE stsauto.
       hsts = 0.
       hsts-f = "d".
END procedure.

/*2)Party*/
PROCEDURE partyauto.
       hparty = "".
       hparty-f = "d".
END procedure.

/*3)Point*/
PROCEDURE pointauto.
       find ofc where ofc.ofc = g-ofc no-lock.
       hpoint = integer(ofc.regno) / 1000 - 0.5.
       hpoint-f = "d".
END procedure.

/*4)Depart*/
PROCEDURE departauto.
       find ofc where ofc.ofc = g-ofc no-lock.
       hdepart = integer(ofc.regno) - hpoint * 1000.
       hdepart-f = "d".
END procedure.

/*5)Amount*/
PROCEDURE amtauto.
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
         rdes = errlist[rcode] + " - amtauto (линия ссылки не найдена).".
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
      if isConvGL(tmpl.crgl) /* tmpl.crgl = buy.inval*/ then do:
         selbuy = "buy".
         vcrc1 = vcrc.
         amt1 = vamt.
         cas1 = false.
         if tmpl.drgl = cas.inval then cas1 = true.
         find tmpl where recid(tmpl) = crec.
         vcrc2 = tmpl.crc.
         cas2 = false.
         if tmpl.crgl = cas.inval then cas2 = true.
      end.
      else if isConvGL(tmpl.drgl)  /* tmpl.drgl = sel.inval*/ then do:
         selbuy = "sel".
         vcrc2 = vcrc.
         amt2 = vamt.
         cas2 = false.
         if tmpl.crgl = cas.inval then cas2 = true.
         find tmpl where recid(tmpl) = crec.
         vcrc1 = tmpl.crc.
         cas1 = false.
         if tmpl.drgl = cas.inval then cas1 = true.
      end.
      else selbuy = "".
      find tmpl where recid(tmpl) = crec.
      find crc where crc.crc = tmpl.crc no-lock.
      vdecpnt = crc.decpnt.
      find crc where crc.crc = vcrc no-lock.
    if vsign = "" and ( vcrc1 > 0 or vcrc2 > 0 ) then do:
      if amt1 = 0 then do:
        run conv(vcrc1, vcrc2, cas1, cas2,
            input-output tmpl.amt, input-output amt2,
            output vrat1, output vrat2,
            output coef1, output coef2,
            output marg1, output marg2).
        tmpl.rate = vrat1 / coef1.
        tmpl.rate-f = "d".
        find first tmpl where tmpl.ln = N no-error.
        tmpl.rate = vrat2 / coef2.
        tmpl.rate-f = "d".
        find tmpl where recid(tmpl) = crec.
      end.
      else do:
        if vrat <> 0.0 then
           run conv-obm(vcrc1, vcrc2,
               input-output amt1, input-output tmpl.amt,
               output vrat1, output vrat2,
               output coef1, output coef2,
               output marg1, output marg2).
        else
        run conv(vcrc1, vcrc2, cas1, cas2,
            input-output amt1,input-output tmpl.amt,
            output vrat1, output vrat2,
            output coef1, output coef2,
            output marg1, output marg2).
        tmpl.rate = vrat2 / coef2.
        tmpl.rate-f = "d".
        find first tmpl where tmpl.ln = N no-error.
        tmpl.rate = vrat1 / coef1.
        tmpl.rate-f = "d".
        find tmpl where recid(tmpl) = crec.
      end.
/*      tmpl.amt = round(vamt * vrate / tmpl.rate, vdecpnt).*/
      tmpl.amt-f = "d".
    end.
    else do:
     if selbuy = "buy" then do:
       vmarg =
        round(vamt * (crc.rate[1] / crc.rate[9] - vrate), vdecpnt).
     end.
     else if selbuy = "sel" then do:
       vmarg =
        round(vamt * (vrate - crc.rate[1] / crc.rate[9]), vdecpnt).
     end.
     else if vsign ne "M" and vsign ne "B" and vsign ne "S"  then do: /* sasco -> B for BEZNAL */
         rcode = 20.
         rdes = errlist[rcode] + " - amtauto (ошибка позиции).".
         return.
     end.
     if vmarg > 0 and vsign = "+" then tmpl.amt = vmarg.
     else if vmarg < 0 and vsign = "-" then tmpl.amt = - vmarg.
     tmpl.amt-f = "d".
    if vsign = "M"
      then  do:
      find crc where crc.crc = tmpl.crc no-lock.
      tmpl.amt =  round(vamt * vrate / ( crc.rate[1] / crc.rate[9] ) ,
                  crc.decpnt) .

   /*   display vrate vamt crc.rate  . pause  . */
      end.

     /* sasco */
     if vsign = "B"
      then  do:
        find crc where crc.crc = tmpl.crc no-lock.

        /* Ї®ЄЦЇЄ  ў «НБК */
        tmpl.amt =  round(vamt * vrate / ( crc.rate[2] / crc.rate[9] ), crc.decpnt) .
      end.

     if vsign = "S"
      then  do:
        find crc where crc.crc = tmpl.crc no-lock.

        /* ЇЮ®¤ ¦  ў «НБК */
/*        tmpl.amt =  round(vamt / vrate * ( crc.rate[3] / crc.rate[9] ), crc.decpnt) . */
        tmpl.amt =  round(vamt * vrate / ( crc.rate[3] / crc.rate[9] ), crc.decpnt) .
      end.

    end.
END procedure.

PROCEDURE rateauto.
/*     if tmpl.system <> "FEX" then do:
       rcode = 20.
       rdes = errlist[rcode] + " - rateauto (system not FEX).".
       return.
     end.
*/
       if tmpl.crc-f <> "d" then run crcauto.
       if tmpl.drgl-f <> "d" then run drglauto.
       if tmpl.crgl-f <> "d" then run crglauto.
     if tmpl.rate-f = "M" then do:
       find crc where crc.crc = tmpl.crc no-lock.
       tmpl.rate = crc.rate[1] / crc.rate[9].
       return .
     end.

     /* 24.07.2002, sasco - ­ «. ЄЦЮА */
     if tmpl.rate-f = "b" then do:
       find crc where crc.crc = tmpl.crc no-lock.
       tmpl.rate = crc.rate[2] / crc.rate[9].
       return.
     end.

     if tmpl.rate-f = "s" then do:
       find crc where crc.crc = tmpl.crc no-lock.
/*       tmpl.rate = crc.rate[3] / crc.rate[9]. */
       tmpl.rate = crc.rate[3] / crc.rate[9].
       return.
     end.



     if tmpl.rate-f = "a" then do:
        find crc where crc.crc = tmpl.crc no-lock.
         if isConvGL(tmpl.crgl)  /* tmpl.crgl = buy.inval*/ then do:
            if tmpl.drgl = cas.inval then do:
               tmpl.rate = crc.rate[2] / crc.rate[9].
               tmpl.rate-f = "d".
               if tmpl.rate = 0 then do:
                  rcode = 36.
                  rdes = errlist[rcode] + ":" + crc.code + "(касса).".
                  return.
               end.
            end.
            else do:
               tmpl.rate = crc.rate[4] / crc.rate[9].
               tmpl.rate-f = "d".
               if tmpl.rate = 0 then do:
                  rcode = 36.
                  rdes = errlist[rcode] + ":" + crc.code + ".".
                  return.
               end.
            end.
         end.
         else if isConvGL(tmpl.drgl)  /* tmpl.drgl = sel.inval*/ then do:
            if tmpl.crgl = cas.inval then do:
               tmpl.rate = crc.rate[3] / crc.rate[9].
               tmpl.rate-f = "d".
               if tmpl.rate = 0 then do:
                  rcode = 37.
                  rdes = errlist[rcode] + ":" + crc.code + "(касса).".
                  return.
               end.
            end.
            else do:
               tmpl.rate = crc.rate[5] / crc.rate[9].
               tmpl.rate-f = "d".
               if tmpl.rate = 0 then do:
                  rcode = 37.
                  rdes = errlist[rcode] + ":" + crc.code + ".".
                  return.
               end.
            end.
         end.
         else do:
            rcode = 20.
            rdes = errlist[rcode] + " - rateauto (ошибка позиции).".
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
            rdes = errlist[rcode] + " - rateauto (линия ссылки не найдена).".
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
END procedure.

/*6)Currency*/
PROCEDURE crcauto.
       if tmpl.drsub-f <> "d" then run drsubauto.
       if tmpl.dracc-f <> "d" then run draccauto.
       if tmpl.drsub <> "" then run trxcrcacc(tmpl.drsub, tmpl.dracc).
       if tmpl.crsub-f <> "d" then run crsubauto.
       if tmpl.cracc-f <> "d" then run craccauto.
       if tmpl.crsub <> "" then run trxcrcacc(tmpl.crsub, tmpl.cracc).
       if tmpl.drsub = "" and tmpl.crsub = "" then do:
          rcode = 20.
          rdes = errlist[rcode] + " валюта <- счет."
               + "Линия=" + string(tmpl.ln,"99").
          return.
       end.
END procedure.

/*8)Debet G/L*/
PROCEDURE drglauto.
def var vsign as char.
  if tmpl.drgl-f = "a" then do:
    if tmpl.dracc-f <> "d" then run draccauto.
    if tmpl.dracc = "" then do:
       rcode = 20.
       rdes = errlist[rcode] + " Г/К(Дб) <-счет(Дб).".
       return.
    end.
    else do:
     if tmpl.drsub-f <> "d" then run drsubauto.
     if tmpl.drsub = "" then do:
       rcode = 20.
       rdes = errlist[rcode] + " Г/К(Дб) <-счет(Дб).".
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
         rdes = errlist[rcode] + " - drglauto (линия ссылки не найдена).".
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
END procedure.

PROCEDURE drsubauto.
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
    rdes = errlist[rcode] + " субсчет <- Г/К(Дб).".
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
         rdes = errlist[rcode] + " - drsubauto (линия ссылки не найдена).".
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
END procedure.

PROCEDURE draccauto.
def var vacc as char.
    N = integer(substring(tmpl.dracc-f,1,4)).
    vsign = substring(tmpl.dracc-f,5,1).
      crec = recid(tmpl).
      find first tmpl where tmpl.ln = N no-error.
      if not available tmpl then do:
         rcode = 20.
         rdes = errlist[rcode] + " - draccauto (линия ссылки не найдена).".
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
END procedure.

/*8)Credit G/L*/
PROCEDURE crglauto.
  if tmpl.crgl-f = "a" then do:
    if tmpl.cracc-f <> "d" then run craccauto.
    if tmpl.cracc = "" then do:
       rcode = 20.
       rdes = errlist[rcode] + " Г/К(Кр) <-счет(Кр).".
       return.
    end.
    else do:
     if tmpl.crsub-f <> "d" then run crsubauto.
     if tmpl.crsub = "" then do:
       rcode = 20.
       rdes = errlist[rcode] + " Г/К(Кр) <-счет(Кр).".
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
         rdes = errlist[rcode] + " - crglauto (линия ссылки не найдена).".
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
END procedure.

PROCEDURE crsubauto.
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
    rdes = errlist[rcode] + " субсчет <- Г/К(Кр).".
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
         rdes = errlist[rcode] + " - crsubauto (линия ссылки не найдена).".
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
END procedure.

PROCEDURE craccauto.
def var vacc as char.
    N = integer(substring(tmpl.cracc-f,1,4)).
    vsign = substring(tmpl.cracc-f,5,1).
      crec = recid(tmpl).
      find first tmpl where tmpl.ln = N no-error.
      if not available tmpl then do:
         rcode = 20.
         rdes = errlist[rcode] + " - craccauto (линия ссылки не найдена).".
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
END procedure.

PROCEDURE trxcrcacc.
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
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "ast" then do:
    find ast where ast.ast = vacc no-lock no-error.
    if available ast then do:
      tmpl.crc = ast.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "cif" then do:
    find aaa where aaa.aaa = vacc no-lock no-error.
    if available aaa then do:
      tmpl.crc = aaa.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "dfb" then do:
    find dfb where dfb.dfb = vacc no-lock no-error.
    if available dfb then do:
      tmpl.crc = dfb.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "eps" then do:
    find eps where eps.eps = vacc no-lock no-error.
    if available eps then do:
      tmpl.crc = eps.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "fun" then do:
    find fun where fun.fun = vacc no-lock no-error.
    if available fun then do:
      tmpl.crc = fun.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "lcr" then do:
    find lcr where lcr.lcr = vacc no-lock no-error.
    if available lcr then do:
      tmpl.crc = lcr.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "lon" then do:
    find lon where lon.lon = vacc no-lock no-error.
    if available lon then do:
      tmpl.crc = lon.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
  else if vsub = "ock" then do:
    find ock where ock.ock = vacc no-lock no-error.
    if available ock then do:
      tmpl.crc = ock.crc.
      tmpl.crc-f = "d".
    end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";валюта <- счет.".
      return.
    end.
  end.
END procedure.

PROCEDURE trxglacc.
def input parameter vsub as char.
def input parameter vacc as char.
def input parameter vlev as inte.
def output parameter vgl as inte.
  if vsub = "arp" then do:
    find arp where arp.arp = vacc no-lock no-error.
   if available arp then do:
    if vlev = 1 then vgl = arp.gl.
    else do:
     find trxlevgl where trxlevgl.gl = arp.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(arp.gl,"999999") + ".".      return.
     end.
    end.
   end.
   else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
   end.
  end.
  else if vsub = "ast" then do:
   find ast where ast.ast = vacc no-lock no-error.
   if available ast then do:
    if vlev = 1 then vgl = ast.gl.
    else do:
     find trxlevgl where trxlevgl.gl = ast.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
        + string(vlev,"z9") + "; Г/К(1) = " + string(ast.gl,"999999") + ".".          return.
     end.
    end.
   end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
    end.
  end.
  else if vsub = "cif" then do:
   find aaa where aaa.aaa = vacc no-lock no-error.
   if available aaa then do:
    if vlev = 1 then vgl = aaa.gl.
    else do:
     find trxlevgl where trxlevgl.gl = aaa.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(aaa.gl,"999999") + ".".
      return.
     end.
    end.
   end.
   else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
   end.
  end.
   else if vsub = "dfb" then do:
   find dfb where dfb.dfb = vacc no-lock no-error.
   if available dfb then do:
    if vlev = 1 then vgl = dfb.gl.
    else do:
     find trxlevgl where trxlevgl.gl = ast.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
        + string(vlev,"z9") + "; Г/К(1) = " + string(dfb.gl,"999999") + ".".
      return.
     end.
    end.
   end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
    end.
  end.
  else if vsub = "eps" then do:
   find eps where eps.eps = vacc no-lock no-error.
   if available eps then do:
    if vlev = 1 then vgl = eps.gl.
    else do:
     find trxlevgl where trxlevgl.gl = eps.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
        + string(vlev,"z9") + "; Г/К(1) = " + string(eps.gl,"999999") + ".".         return.
     end.
    end.
   end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
    end.
  end.

  else if vsub = "fun" then do:
    find fun where fun.fun = vacc no-lock no-error.
   if available fun then do:
    if vlev = 1 then vgl = fun.gl.
    else do:
     find trxlevgl where trxlevgl.gl = fun.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(fun.gl,"999999") + ".".      return.
     end.
    end.
   end.
   else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
   end.
  end.
   else if vsub = "lcr" then do:
   find lcr where lcr.lcr = vacc no-lock no-error.
   if available lcr then do:
    if vlev = 1 then vgl = lcr.gl.
    else do:
     find trxlevgl where trxlevgl.gl = lcr.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
        + string(vlev,"z9") + "; Г/К(1) = " + string(lcr.gl,"999999") + ".".         return.
     end.
    end.
   end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
    end.
  end.
 else if vsub = "lon" then do:
   find lon where lon.lon = vacc no-lock no-error.
   if available lon then do:
    if vlev = 1 then vgl = lon.gl.
    else do:
     find trxlevgl where trxlevgl.gl = lon.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
       + string(vlev,"z9") + "; Г/К(1) = " + string(lon.gl,"999999") + ".".            return.
     end.
    end.
   end.
    else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
    end.
  end.

 else if vsub = "ock" then do:
    find ock where ock.ock = vacc no-lock no-error.
   if available ock then do:
    if vlev = 1 then vgl = ock.gl.
    else do:
     find trxlevgl where trxlevgl.gl = ock.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(ock.gl,"999999") + ".".      return.
     end.
    end.
   end.
   else do:
      rcode = 20.
      rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
           + ";счет=" + vacc + "Линия="
           + string(tmpl.ln,"99") + ";Г/К <- счет.".
      return.
   end.
  end.
END procedure.

PROCEDURE remauto.
def var vsign as char.
    N = integer(substring(tmpl.rem-f[o],1,4)).
    vsign = substring(tmpl.rem-f[o],5,1).
      crec = recid(tmpl).
      find first tmpl where tmpl.ln = N no-error.
      if not available tmpl then do:
         rcode = 20.
         rdes = errlist[rcode] + " - rem (линия ссылки не найдена).".
         return.
      end.
       if tmpl.rem-f[o] <> "d" then run remauto.
       vrem = tmpl.rem[o].
      find tmpl where recid(tmpl) = crec.
      tmpl.rem[o] = vrem.
      tmpl.rem-f[o] = "d".
END procedure.

/*10)Debit code auto*/
PROCEDURE drcodeauto.
def var vsign as char.
def var vcodfr as char.
def var vcod as char.
def var vN0 as inte.
def var vcif like cif.cif.
  if cdf.drcod-f = "a" then do:
     if cdf.codfr <> "secek" and cdf.codfr <> "locat" then do:
        rcode = 20.
        rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб).".
        return.
     end.
     if tmpl.drsub-f <> "d" then run drsubauto.
     if tmpl.drsub <> "cif" and tmpl.drsub <> "lon" then do:
        rcode = 20.
        rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                              + tmpl.drsub + ").".
        return.
     end.
     if tmpl.dracc-f <> "d" then run draccauto.
     if tmpl.drsub = "cif" then do:
        find aaa where aaa.aaa = tmpl.dracc no-lock no-error.
        if available aaa then find cif where cif.cif = aaa.cif no-lock no-error.
        if available cif then vcif = cif.cif.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                                  + tmpl.dracc + ").".
            return.
        end.
     end.
     else do:
        find lon where lon.lon = tmpl.dracc no-lock no-error.
        if available lon then find cif where cif.cif = lon.cif no-lock no-error.
        if available cif then vcif = cif.cif.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                                  + tmpl.dracc + ").".
            return.
        end.
     end.
     if cdf.codfr = "secek" then do:
       find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek"
                      and sub-cod.acc = vcif no-lock no-error.
       if available sub-cod and sub-cod.ccode <> "msc" then do:
          cdf.drcod = sub-cod.ccode.
       end.
       else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(secek) <- счет(Дб)("
                                  + vcif + ")- secek не опред.".
            return.
       end.
     end.
     if cdf.codfr = "locat" then do:
        if cif.geo <> "" and cif.geo <> ? then do:
          if substring(cif.geo,3,1) = "1" then cdf.drcod = "1".
          else cdf.drcod = "2".
        end.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(locat) <- счет(Дб)("
                                  + vcif + ") - GEO не опред.".
            return.
        end.
     end.
  cdf.drcod-f = "d".
  end. /*cdf.drcod-f = "a"*/
  else do:
    vN0 = cdf.trxln.
    N = integer(substring(cdf.drcod-f,1,4)).
    vsign = substring(cdf.drcod-f,5,1).
    vcodfr = cdf.codfr.
      crec = recid(cdf).
      find first cdf where cdf.trxln = N and cdf.codfr = vcodfr no-error.
      if not available cdf then do:
         rcode = 20.
         rdes = errlist[rcode] + " - drcodeauto (линия ссылки не найдена).".
         return.
      end.
    if vsign = "-" then do:
       if cdf.crcode-f <> "d" then run crcodeauto.
       vcod = cdf.crcod.
    end.
    else do:
      if cdf.trxln = vN0 then do:
       rcode = 20.
       rdes = errlist[rcode] + " - drcodeauto (Ссылки на себя запрещены).".
       return.
      end.
       if cdf.drcod-f <> "d" then run drcodeauto.
       vcod = cdf.drcod.
    end.
      find cdf where recid(cdf) = crec.
      cdf.drcod = vcod.
      cdf.drcod-f = "d".
  end.
END procedure.

/*11)Credit code auto*/
PROCEDURE crcodeauto.
def var vsign as char.
def var vcodfr as char.
def var vcod as char.
def var vN0 as inte.
def var vcif like cif.cif.
  if cdf.crcode-f = "a" then do:
     if cdf.codfr <> "secek" and cdf.codfr <> "locat" then do:
        rcode = 20.
        rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр).".
        return.
     end.
     if tmpl.crsub-f <> "d" then run crsubauto.
     if tmpl.crsub <> "cif" and tmpl.crsub <> "lon" then do:
        rcode = 20.
        rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                              + tmpl.crsub + ").".
        return.
     end.
     if tmpl.cracc-f <> "d" then run craccauto.
     if tmpl.crsub = "cif" then do:
        find aaa where aaa.aaa = tmpl.cracc no-lock no-error.
        if available aaa then find cif where cif.cif = aaa.cif no-lock no-error.
        if available cif then vcif = cif.cif.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                                  + tmpl.cracc + ").".
            return.
        end.
     end.
     else do:
        find lon where lon.lon = tmpl.cracc no-lock no-error.
        if available lon then find cif where cif.cif = lon.cif no-lock no-error.
        if available cif then vcif = cif.cif.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                                  + tmpl.cracc + ").".
            return.
        end.
     end.
     if cdf.codfr = "secek" then do:
       find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek"
                      and sub-cod.acc = vcif no-lock no-error.
       if available sub-cod and sub-cod.ccode <> "msc" then do:
          cdf.crcod = sub-cod.ccode.
       end.
       else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(secek) <- счет(Кр)("
                                  + vcif + ")- secek не опред.".
            return.
       end.
     end.
     if cdf.codfr = "locat" then do:
        if cif.geo <> "" and cif.geo <> ? then do:
          if substring(cif.geo,3,1) = "1" then cdf.crcod = "1".
          else cdf.crcod = "2".
        end.
        else do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(locat) <- счет(Кр)("
                                  + vcif + ") - GEO не опред.".
            return.
        end.
     end.
  cdf.crcode-f = "d".
  end. /*cdf.crcode-f = "a"*/
  else do:
    vN0 = cdf.trxln.
    N = integer(substring(cdf.crcode-f,1,4)).
    vsign = substring(cdf.crcode-f,5,1).
    vcodfr = cdf.codfr.
    crec = recid(cdf).
      find first cdf where cdf.trxln = N and cdf.codfr = vcodfr no-error.
      if not available cdf then do:
         rcode = 20.
         rdes = errlist[rcode] + " - crcodeauto (линия ссылки не найдена).".
         return.
      end.
    if vsign = "-" then do:
       if cdf.drcod-f <> "d" then run drcodeauto.
       vcod = cdf.drcod.
    end.
    else do:
      if cdf.trxln = vN0 then do:
       rcode = 20.
       rdes = errlist[rcode] + " - drcodeauto (Ссылки на себя запрещены).".
       return.
      end.
       if cdf.crcode-f <> "d" then run crcodeauto.
       vcod = cdf.crcod.
    end.
      find cdf where recid(cdf) = crec.
      cdf.crcod = vcod.
      cdf.crcode-f = "d".
  end.
END procedure.
