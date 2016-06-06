/* 700n-gl2.p
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
        25/10/2012 madiyar - исключил кроме счета 1858 еще счет 1859
*/

function CRC2KZT returns decimal(sum$ as dec, crc$ as int, dt$ as date).
    find last txb.crchis where txb.crchis.crc = crc$ and txb.crchis.whn <= dt$.
    return sum$ * txb.crchis.rate[1].
end.
def shared var dt$ as date.

def var v-dam as decimal init 0.
def var v-cam as decimal init 0.

def var cur$ as char init "1,2,4,3".
def shared temp-table tgl
field tgl as int format ">>>>"
field tcrc as integer
field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
field tsum2 as dec format "->>>>>>>>>>>>>>9.99".

for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and
  substr(string(txb.gl.gl),1,1) = '1' and
  (substr(string(txb.gl.gl),1,4) <> '1801'
   and substr(string(txb.gl.gl),1,4) <> '1802'
   and substr(string(txb.gl.gl),1,4) <> '1803'
   and substr(string(txb.gl.gl),1,4) <> '1804'
   and substr(string(txb.gl.gl),1,4) <> '1805'
   and substr(string(txb.gl.gl),1,4) <> '1858'
   and substr(string(txb.gl.gl),1,4) <> '1859'
   and substr(string(txb.gl.gl),1,4) <> '1351'
   and substr(string(txb.gl.gl),1,4) <> '1352'
   and substr(string(txb.gl.gl),1,4) <> '1353')
   break by txb.gl.gl:
    def var crc$ as char.
    def var acnt$ as char.
    def var c$ as int.
    if txb.gl.gl <> 599980 then do:
    acnt$ = substr(string(txb.gl.gl), 1, 4).
    c$ = 0.
    repeat while c$ <= 3:
        c$ = c$ + 1.
        crc$ = entry(c$, cur$, ",").
        find last txb.glday where txb.glday.gdt <= dt$ and txb.glday.gl = txb.gl.gl and txb.glday.crc = int(crc$) no-error.
        if available txb.glday and txb.glday.bal <> 0 then do:
            create tgl.
            tgl.tgl = int(acnt$).
            tgl.tcrc = txb.glday.crc.
            tgl.tsum1 = txb.glday.bal.
            tgl.tsum2 = CRC2KZT(txb.glday.bal, txb.glday.crc, dt$).
        end.
    end.
    end.
end.

for each tgl break by tgl.tgl.
  for each txb.jl where txb.jl.jdt = dt$  and substr(string(txb.jl.gl),1,4) = string(tgl.tgl) and
  txb.jl.crc = tgl.tcrc  no-lock .
   v-dam = v-dam + CRC2KZT(txb.jl.dam, txb.jl.crc, dt$).
   v-cam = v-cam + CRC2KZT(txb.jl.cam, txb.jl.crc, dt$).
  end.
 tgl.tsum2 = tgl.tsum2 + v-dam - v-cam.
  v-dam = 0. v-cam = 0.
end.

