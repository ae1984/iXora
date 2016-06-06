/* gbstars2.p
 * MODULE
        Бухгалтерия
 * DESCRIPTION
        Обнаружение звезд
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
        15/12/2010 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        25/07/2012 kapar изменил entry(1,txb.cmp.addr[1]) на entry(2,txb.cmp.addr[1])
*/

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field gl as integer
  field crc as integer
  field sub as char
  field level as integer
  field sum_gl as deci
  field sum_gl_kzt as deci
  field sum_lon as deci
  index idx is primary bank gl crc.

def input parameter dat as date no-undo.

def shared var rates as deci extent 20.

def var sublist as char no-undo.
sublist = "ARP,DFB,FUN,SCU,CIF,LON,AST,TSF,EPS".

def var i as integer no-undo.
def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

find first txb.cmp no-lock no-error.
if not avail txb.cmp then do:
   display s-ourbank + " - There is no CMP record!!".
   pause.
   return.
end.

def var v-bankn as char no-undo.
if s-ourbank = "txb00" then v-bankn = "ЦО".
else v-bankn = entry(2,txb.cmp.addr[1]).

hide message no-pause.
message v-bankn + " - G/L".

do i = 1 to num-entries(sublist):
    for each txb.gl where txb.gl.subled = entry(i,sublist) no-lock:
        for each txb.crc no-lock:
            create wrk.
            wrk.bank = s-ourbank.
            wrk.bankn = v-bankn.
            wrk.gl = txb.gl.gl.
            wrk.crc = txb.crc.crc.
            wrk.sub = txb.gl.subled.
            wrk.level = txb.gl.lev.
            find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
            if avail txb.glday then do:
                wrk.sum_gl = txb.glday.dam - txb.glday.cam.
                wrk.sum_gl_kzt = wrk.sum_gl * rates[wrk.crc].
            end.
        end.
    end.
end.

/* ARP */
hide message no-pause.
message v-bankn + " - ARP".
for each txb.arp no-lock:
    for each txb.trxbal where txb.trxbal.subled = "arp" and txb.trxbal.acc = txb.arp.arp no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'arp' and txb.histrxbal.acc = txb.arp.arp and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.arp.gl and txb.trxlevgl.subled = 'arp' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each arp */
/* DFB */
hide message no-pause.
message v-bankn + " - DFB".
for each txb.dfb no-lock:
    for each txb.trxbal where txb.trxbal.subled = "dfb" and txb.trxbal.acc = txb.dfb.dfb no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'dfb' and txb.histrxbal.acc = txb.dfb.dfb and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.dfb.gl and txb.trxlevgl.subled = 'dfb' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each dfb */
/* FUN */
hide message no-pause.
message v-bankn + " - FUN".
for each txb.fun no-lock:
    for each txb.trxbal where txb.trxbal.subled = "fun" and txb.trxbal.acc = txb.fun.fun no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'fun' and txb.histrxbal.acc = txb.fun.fun and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.fun.gl and txb.trxlevgl.subled = 'fun' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each fun */
/* SCU */
hide message no-pause.
message v-bankn + " - SCU".
for each txb.scu no-lock:
    for each txb.trxbal where txb.trxbal.subled = "scu" and txb.trxbal.acc = txb.scu.scu no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'scu' and txb.histrxbal.acc = txb.scu.scu and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.scu.gl and txb.trxlevgl.subled = 'scu' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each lon */
/* CIF */
hide message no-pause.
message v-bankn + " - CIF".
for each txb.aaa no-lock:
    for each txb.trxbal where txb.trxbal.subled = "cif" and txb.trxbal.acc = txb.aaa.aaa no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'cif' and txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled = 'cif' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each aaa */
/* LON */
hide message no-pause.
message v-bankn + " - LON".
for each txb.lon no-lock:
    for each txb.trxbal where txb.trxbal.subled = "lon" and txb.trxbal.acc = txb.lon.lon no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.lon.gl and txb.trxlevgl.subled = 'lon' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each lon */
/* AST */
hide message no-pause.
message v-bankn + " - AST".
for each txb.ast no-lock:
    for each txb.trxbal where txb.trxbal.subled = "ast" and txb.trxbal.acc = txb.ast.ast no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'ast' and txb.histrxbal.acc = txb.ast.ast and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.ast.gl and txb.trxlevgl.subled = 'ast' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each ast */
/* TSF */
hide message no-pause.
message v-bankn + " - TSF".
for each txb.tsf no-lock:
    for each txb.trxbal where txb.trxbal.subled = "tsf" and txb.trxbal.acc = txb.tsf.tsf no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'tsf' and txb.histrxbal.acc = txb.tsf.tsf and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.tsf.gl and txb.trxlevgl.subled = 'tsf' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each tsf */
/* EPS */
hide message no-pause.
message v-bankn + " - EPS".
for each txb.eps no-lock:
    for each txb.trxbal where txb.trxbal.subled = "eps" and txb.trxbal.acc = txb.eps.eps no-lock:
        find last txb.histrxbal where txb.histrxbal.subled = 'eps' and txb.histrxbal.acc = txb.eps.eps and txb.histrxbal.level = txb.trxbal.level and txb.histrxbal.crc = txb.trxbal.crc and txb.histrxbal.dt < dat no-lock no-error.
        if avail txb.histrxbal then do:
            if txb.histrxbal.dam - txb.histrxbal.cam = 0 then next.
            find first txb.trxlevgl where txb.trxlevgl.gl = txb.eps.gl and txb.trxlevgl.subled = 'eps' and txb.trxlevgl.level = txb.histrxbal.level no-lock no-error.
            find first wrk where wrk.bank = s-ourbank and wrk.gl = txb.trxlevgl.glr and wrk.crc = txb.histrxbal.crc no-error.
            wrk.sum_lon = wrk.sum_lon + txb.histrxbal.dam - txb.histrxbal.cam.
        end.
    end.
end. /* for each eps */


for each wrk:
  if wrk.sum_gl = 0 and wrk.sum_lon = 0 then delete wrk.
/*  else do:
    wrk.sum_gl = absolute(wrk.sum_gl).
    wrk.sum_lon = absolute(wrk.sum_lon).
  end.*/
end.

