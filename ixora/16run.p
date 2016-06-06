/* 16run.p
 * MODULE
        Отчеты для статистики
 * DESCRIPTION
        Отчет 16ПБ - запуск на присоединенной БД "txb" - консолидация
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        16.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-2-14-9
 * AUTHOR
        11/03/04 sasco
 * BASES
        BANK COMM TXB
 * CHANGES
        08/04/04 sasco Добавил счет Г/К 1002
        16/05/08 marinav сделала консолидацию
        27.09.2011 damir - добавил валюты crc = 7,8,9 - (SEK,AUD,CHF)
        14.02.2012 aigul - исправила вывод ГК 185800
        02.11.2012 damir - Изменения, связанные с изменением шаблонов по конвертации. Добавил convgl.i,getConvGL.
*/

{16.i}
{convgl.i "txb"}

def var vcrc as int.
def var v-bank as char.

def buffer bjh  for txb.jh.
def buffer bjl  for txb.jl.


for each glacc$:   delete glacc$.  end.
for each txb.gl no-lock:
    if truncate(txb.gl.gl / 100, 0) = 1001 or
       truncate(txb.gl.gl / 100, 0) = 1002 or
       truncate(txb.gl.gl / 100, 0) = 1003 or
       truncate(txb.gl.gl / 100, 0) = 1005 then do:
          create glacc$.
          glacc$.glacc$ = txb.gl.gl.
    end.
end.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if avail txb.sysc then v-bank = sysc.chval.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * */

function GETFU returns char.
 if avail txb.cif then do:
    find txb.sub-cod where txb.sub-cod.sub = "cln" and
                       txb.sub-cod.acc = txb.cif.cif and
                       txb.sub-cod.d-cod = "clnsts"
                       no-lock no-error.
    if not avail txb.sub-cod then return "f".
    else if txb.sub-cod.ccode = "0" then return "u".
    else if txb.sub-cod.ccode = "1" then return "f".
    else return "f".
  end.
  else return "f".
end function.

/* * * * * * * * * * * * * * * * * * * * * * * * * * * */

function GEO returns char.
    if avail txb.cif then do:
       if substr(txb.cif.geo, 3, 1) = "1" then return "r".
                                      else return "n".
    end.
    else if avail txb.arp then do:
         if substr(txb.arp.geo, 3, 1) = "1" then return "r".
                                        else return "n".
    end.
    else if avail txb.remtrz then do:
                find txb.sub-cod where txb.sub-cod.sub = "rmz" and
                                   txb.sub-cod.acc = txb.remtrz.remtrz and
                                   txb.sub-cod.d-cod = "eknp" and
                                   txb.sub-cod.ccode = "eknp"
                                   no-lock no-error.
                if not avail txb.sub-cod then return "r".
                else
                if SUBSTR (ENTRY (2, txb.sub-cod.rcode, ","), 1, 1) = "1"
                          then return "r".
                          else return "n".
    end.
    else return "r".
end function.

/* * * * * * * * * * * * * * * * * * * * * * * * * * * */



for each txb.jl where txb.jl.jdt >= v-date1 and txb.jl.jdt <= v-date2 and
(txb.jl.crc = 2 or txb.jl.crc = 4 or txb.jl.crc = 3 or txb.jl.crc = 7 or txb.jl.crc = 8 or txb.jl.crc = 9) use-index jdt:

    find txb.jh of txb.jl no-lock no-error.
    if index(txb.jh.party,"STORNED") > 0 or index(txb.jh.party,"STORNO") > 0 then next.

    find glacc$ where glacc$.glacc$ = txb.jl.gl no-error.
    if not avail glacc$ then next.

    vcrc = txb.jl.crc.

    release txb.cif.
    release txb.arp.
    release txb.lon.
    release txb.remtrz.

    /* ДЕБЕТ СЧЕТА */
    if txb.jl.dc = "D" then
    do:

        find first bjl where bjl.jh = txb.jl.jh and
                       bjl.dc  = "C" and
                       bjl.crc = txb.jl.crc and
                       bjl.cam = txb.jl.dam
                       no-lock no-error.

        if not avail bjl then
        find first bjl where bjl.jh  = txb.jl.jh and
                       bjl.dc  = "C" and
                       bjl.crc = txb.jl.crc
                       no-lock no-error.

        find txb.aaa where txb.aaa.aaa = bjl.acc no-lock no-error.
        if avail txb.aaa then find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
        else do:
                find txb.arp where txb.arp.arp = bjl.acc no-lock no-error.
                if avail txb.arp then find txb.cif where txb.cif.cif = txb.arp.cif no-lock no-error.
                else do:
                        find txb.lon where txb.lon.lon = bjl.acc no-lock no-error.
                        if avail txb.lon then find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                end.
        end.

        if SUBSTR (txb.jh.party, 1, 3) = "RMZ" then
        do:
            if SUBSTR (txb.jl.rem[1], 1, 3) = "RMZ"
               then find txb.remtrz where txb.remtrz.remtrz = SUBSTR (txb.jl.rem[1], 1, 10) no-lock no-error.
               else find txb.remtrz where txb.remtrz.remtrz = SUBSTR (txb.jh.party, 1, 10) no-lock no-error.
        end.

        run ADD-TMP ("D", bjl.cam, v-bank).
        next.

    end.
    /* КРЕДИТ СЧЕТА */
    else if txb.jl.dc = "C" then do:

        find first bjl where bjl.jh  = txb.jl.jh and
                       bjl.dc  = "D" and
                       bjl.crc = txb.jl.crc and
                       bjl.dam = txb.jl.cam
                       no-lock no-error.

        if not avail bjl then
        find first bjl where bjl.jh  = txb.jl.jh and
                       bjl.dc  = "D" and
                       bjl.crc = txb.jl.crc
                       no-lock no-error.

        find txb.aaa where txb.aaa.aaa = bjl.acc no-lock no-error.
        if avail txb.aaa then find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
        else do:
                find txb.arp where txb.arp.arp = bjl.acc no-lock no-error.
                if avail txb.arp then find txb.cif where txb.cif.cif = txb.arp.cif no-lock no-error.
                else do:
                        find txb.lon where txb.lon.lon = bjl.acc no-lock no-error.
                        if avail txb.lon then find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                end.
        end.

        if SUBSTR (txb.jh.party, 1, 3) = "RMZ" then
        do:
            if SUBSTR (txb.jl.rem[1], 1, 3) = "RMZ"
               then find txb.remtrz where txb.remtrz.remtrz = SUBSTR (txb.jl.rem[1], 1, 10) no-lock no-error.
               else find txb.remtrz where txb.remtrz.remtrz = SUBSTR (txb.jh.party, 1, 10) no-lock no-error.
        end.

        run ADD-TMP ("C", bjl.dam, v-bank).
        next.


    end.

end.

/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */

procedure ADD-TMP .

    def input parameter tdc as char.
    def input parameter tsum as decimal.
    def input parameter v-bank as char.

    def var tres as char.
    tres = GEO().

    def var vfu as char.
    vfu = GETFU().

    create wrk.
    assign wrk.crc = vcrc
           wrk.dc = tdc
           wrk.fu = vfu
           wrk.res = tres
           wrk.jh = bjl.jh
           wrk.party = txb.jh.party.

    if avail txb.cif then wrk.cif = txb.cif.cif.
                     else wrk.cif = "  -   ".

    if tdc = "D" then assign wrk.dgl = txb.jl.gl wrk.cgl = bjl.gl
                             wrk.drem[1] = txb.jl.rem[1]
                             wrk.drem[2] = txb.jl.rem[2]
                             wrk.drem[3] = txb.jl.rem[3]
                             wrk.drem[4] = txb.jl.rem[4]
                             wrk.crem[1] = bjl.rem[1]
                             wrk.crem[2] = bjl.rem[2]
                             wrk.crem[3] = bjl.rem[3]
                             wrk.crem[4] = bjl.rem[4]
                             wrk.sum = tsum
                             wrk.bank = v-bank.

    else
    if tdc = "C" then assign wrk.dgl = bjl.gl wrk.cgl = txb.jl.gl
                             wrk.crem[1] = txb.jl.rem[1]
                             wrk.crem[2] = txb.jl.rem[2]
                             wrk.crem[3] = txb.jl.rem[3]
                             wrk.crem[4] = txb.jl.rem[4]
                             wrk.drem[1] = bjl.rem[1]
                             wrk.drem[2] = bjl.rem[2]
                             wrk.drem[3] = bjl.rem[3]
                             wrk.drem[4] = bjl.rem[4]
                             wrk.sum = tsum
                             wrk.bank = v-bank.
                             if substring(txb.jl.rem[1],1,5) = "Обмен" and
                             ((txb.jl.dam <> 0 and txb.jl.ln = 1) or (txb.jl.cam <> 0 and txb.jl.ln = 4)) then
                             assign
                             wrk.dam = txb.jl.dam
                             wrk.cam = txb.jl.cam
                             wrk.ln = txb.jl.ln
                             wrk.dgl = getConvGL(vcrc,bjl.dc)
                             wrk.cgl = 100100.

end procedure.

