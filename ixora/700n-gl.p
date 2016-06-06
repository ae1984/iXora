/* 700n-gl.p
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
 * BASES
        BANK COMM TXB
 * CHANGES
        02.07.2012 damir - добавил ZAR.
        04.07.2012 damir - добавил CAD.
        04.02.2013 damir - Конвертация в тенге производилась с помощью conv.i. Убрал conv.i, сделал как в Конс.балансе в тенге.
*/
def shared var dt$ as date.

def shared temp-table tgl
    field tgl as inte format ">>>>"
    field tcrc as inte
    field tsum1 as deci format "->>>>>>>>>>>>>>9.99"
    field tsum2 as deci format "->>>>>>>>>>>>>>9.99".

def var cur$ as char init "1,2,3,4,6,7,8,9,10,11".
def var crc$ as char.
def var acnt$ as char.
def var c$ as inte.

def buffer p-crchis for txb.crchis.

for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 no-lock break by txb.gl.gl:
    if txb.gl.gl <> 599980 then do:
        acnt$ = substr(string(txb.gl.gl),1,4).
        c$ = 0.
        repeat while c$ <= 9:
            c$ = c$ + 1.
            crc$ = entry(c$,cur$).
            find last txb.glday where txb.glday.gdt <= dt$ and txb.glday.gl = txb.gl.gl and txb.glday.crc = int(crc$) no-lock no-error.
            if avail txb.glday and txb.glday.bal <> 0 then do:
                find last p-crchis where p-crchis.crc = txb.glday.crc and p-crchis.rdt <= dt$ no-lock no-error.
                create tgl.
                tgl.tgl   = int(acnt$).
                tgl.tcrc  = txb.glday.crc.
                tgl.tsum1 = txb.glday.bal.
                if avail p-crchis then tgl.tsum2 = txb.glday.bal * p-crchis.rate[1] / p-crchis.rate[9].
            end.
        end.
    end.
end.
