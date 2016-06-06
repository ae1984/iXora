/* 700h-gl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - create700h.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        03/10/2011 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
        16.01.2013 damir - Внедрено Т.З. № 1610.
*/
{conv.i}

def var s-ourbank as char no-undo.
def var v-bankn as char no-undo.
def var cur$ as char init "1,2,3,4,6,7,8,9,10,11".
def var crc$ as char.
def var acnt$ as char.
def var c$ as inte.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).

function GetFilName returns char ( input txb_val as char ):
    def var ListCod  as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
    def var ListBank as char format "x(25)" extent 17 init ["         ЦО       ","       Актобе     ","      Костанай    ","       Тараз      ",
        "      Уральск     ","     Караганда    ","   Семипалатинск  ","      Кокшетау    ",
        "       Астана     ","      Павлодар    ","   Петропавловск  ","       Атырау     ",
        "       Актау      ","     Жезказган    "," Усть-Каменогорск ","      Шымкент     ",
        "Алматинский филиал"].
    if txb_val = "" then return "".
    return  ListBank[LOOKUP(txb_val , ListCod)].
end function.

v-bankn = GetFilName(s-ourbank).
display v-bankn no-label format "x(20)"  with row 8 frame ww centered title "Обработка".

def shared var v-dt as date.

def shared temp-table tgl
    field txb as char
    field des as char
    field tgl as inte format ">>>>"
    field gl as inte
    field tcrc as inte
    field tsum1 as deci format "->>>>>>>>>>>>>>9.99"
    field tsum2 as deci format "->>>>>>>>>>>>>>9.99"
    field totlev as inte
    field totgl as inte.

for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and txb.gl.gl < 800000 no-lock break by txb.gl.gl:
    if txb.gl.gl <> 599980 then do:
        acnt$ = substr(string(txb.gl.gl),1,4).
        c$ = 0.
        repeat while c$ <= 9:
            c$ = c$ + 1.
            crc$ = entry(c$,cur$).
            find last txb.glday where txb.glday.gdt <= v-dt and txb.glday.gl = txb.gl.gl and txb.glday.crc = int(crc$) no-lock no-error.
            if avail txb.glday and txb.glday.bal <> 0 then do:
                create tgl.
                tgl.txb = s-ourbank.
                tgl.des = txb.gl.des.
                tgl.tgl = inte(acnt$).
                tgl.gl = txb.gl.gl.
                tgl.tcrc = txb.glday.crc.
                tgl.tsum1 = txb.glday.bal.
                tgl.tsum2 = CRC2KZT(txb.glday.bal,txb.glday.crc,v-dt).
                tgl.totlev = txb.gl.totlev.
                tgl.totgl = txb.gl.totgl.
            end.
        end.
    end.
end.

hide frame ww no-pause.