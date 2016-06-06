/* 700n-v.p
 * MODULE
        Балансовый отчет 700-Н
 * DESCRIPTION
        Баланс за дату с разбивкой по валютам - формирование временной таблицы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        700n-val
 * SCRIPT
        
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-12-2-3 
 * AUTHOR
        23.03.2005  marinav 
 * CHANGES
*/

def shared var dt$ as date.
def var cur$ as char init "1,2,4,3".
def shared temp-table tgl
field tgl as int format ">>>>"
field tcrc as integer
field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
field tsum2 as dec format "->>>>>>>>>>>>>>9.99".

for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl < 300000 break by txb.gl.gl:
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
            find last txb.crchis where txb.crchis.crc = int(crc$) and txb.crchis.whn <= dt$.
            create tgl.
            tgl.tgl = int(acnt$).
            tgl.tcrc = txb.glday.crc.
            tgl.tsum1 = txb.glday.bal.
            tgl.tsum2 = txb.glday.bal * txb.crchis.rate[1].
        end.
    end.
    end.
end.
        