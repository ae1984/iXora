/* rep_conbl1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Консолидированный баланс в тенге
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - rep_conbl.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/09/2011 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
        02.11.2012 damir - Изменения, связанные с изменением шаблонов по конвертации. Добавил convgl.i,isConvGL,v-convGL.
        16.01.2013 damir - Внедрено Т.З. № 1610.
*/

{convgl.i "txb"}
{rep_conbl_shared.i}

def var s-ourbank as char no-undo.
def var v-bankn as char no-undo.
def var v-convGL as logi.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).

function GetFilName returns char ( input txb_val as char ):
    def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
    def var ListBank as char format "x(25)" extent 17 init  ["ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
    "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].
    if txb_val = "" then return "".
    return  ListBank[LOOKUP(txb_val , ListCod)].
end function.

v-bankn = GetFilName(s-ourbank).
display v-bankn no-label format "x(20)"  with row 8 frame ww centered title "Обработка".

run GetBalDate( dt1 ).
run GetBalDate( dt2 ).

hide frame ww no-pause.

procedure GetBalDate:
    def input parameter dat_rep as date.

    def var vbal as decimal extent 10.
    def var vbaltot as decimal.
    def var rate1 as decimal.
    def var rate9 as decimal.

    def buffer p-crchis for txb.crchis.
    def buffer basecrc for bank.crchis.
    def buffer b2-temp for temp.

    find last basecrc where basecrc.crc = 1 and basecrc.rdt <= dat_rep no-lock no-error.
    if avail basecrc then do:
       rate9 = basecrc.rate[9].
       rate1 = basecrc.rate[1].
    end.
    else do: message "нет записи в bank.crchis" view-as alert-box. end.

    for each bank.gl where bank.gl.ibfact = false no-lock break by bank.gl.type by bank.gl.gl   :
        vbal[1] = 0.  vbal[2] = 0. vbal[3] = 0. vbal[4] = 0. vbal[5] = 0. vbal[6] = 0. vbal[7] = 0. vbal[8] = 0. vbal[9] = 0. vbal[10] = 0.

        if lookup(bank.gl.type,"A,L,O,R,E") = 0 then next.

        find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.crc = 1 and txb.glday.gdt <= dat_rep no-lock no-error.
        if available txb.glday then vbal[1] = vbal[1] + txb.glday.bal * rate9 / rate1.

        /* other currencies */
        for each bank.crc where bank.crc.crc > 1 and bank.crc.sts <> 9 no-lock:
            find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.crc = bank.crc.crc and txb.glday.gdt <= dat_rep no-lock no-error.
            if avail txb.glday then do:
                find last p-crchis where p-crchis.crc = txb.glday.crc and p-crchis.rdt <= dat_rep no-lock no-error.
                if avail p-crchis then do:
                    if      txb.glday.crc = 2 then  vbal[2] = vbal[2] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 4 then  vbal[3] = vbal[3] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 3 then  vbal[4] = vbal[4] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 6 then  vbal[5] = vbal[5] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 7 then  vbal[6] = vbal[6] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 8 then  vbal[7] = vbal[7] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 9 then  vbal[8] = vbal[8] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 10 then  vbal[9] = vbal[9] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                    else if txb.glday.crc = 11 then  vbal[10] = vbal[10] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
                end.
                else do: message "Нет данных истории валюты " string(txb.glday.crc) " в филиале " v-bankn. pause 1. end.
            end.
        end.
        vbaltot = vbal[1]  + vbal[2] + vbal[3] + vbal[4] + vbal[5] + vbal[6] + vbal[7] + vbal[8] + vbal[9] + vbal[10].
        v-convGL = false.
        v-convGL = isConvGL(bank.gl.gl).
        if bank.gl.vadisp  and (vbaltot <> 0 or v-convGL) then  do:
            find b2-temp where b2-temp.gl = bank.gl.gl and b2-temp.dt = dat_rep and b2-temp.txb = s-ourbank no-lock no-error.
            if not available b2-temp then do:
                create temp.
                temp.txb = s-ourbank.
                temp.dt = dat_rep.
                temp.gl = bank.gl.gl.
                temp.des = bank.gl.des.
                temp.totlev = bank.gl.totlev.
                temp.bal1 = vbal[1].
                temp.bal2 = vbal[2].
                temp.bal3 = vbal[3].
                temp.bal4 = vbal[4].
                temp.bal5 = vbal[5].
                temp.bal6 = vbal[6].
                temp.bal7 = vbal[7].
                temp.bal8 = vbal[8].
                temp.bal9 = vbal[9].
                temp.bal10 = vbal[10].
                temp.baltot = vbaltot.
            end.
            else do:
                b2-temp.bal1 = b2-temp.bal1 + vbal[1].
                b2-temp.bal2 = b2-temp.bal2 + vbal[2].
                b2-temp.bal3 = b2-temp.bal3 + vbal[3].
                b2-temp.bal4 = b2-temp.bal4 + vbal[4].
                b2-temp.bal5 = b2-temp.bal5 + vbal[5].
                b2-temp.bal6 = b2-temp.bal6 + vbal[6].
                b2-temp.bal7 = b2-temp.bal7 + vbal[7].
                b2-temp.bal8 = b2-temp.bal8 + vbal[8].
                b2-temp.bal9 = b2-temp.bal9 + vbal[9].
                b2-temp.bal10 = b2-temp.bal10 + vbal[10].
                b2-temp.baltot = b2-temp.baltot + vbaltot.
            end.
        end.
        /*сравнение лоро-ностро счетов*/
        /*
        if bank.gl.gl = 135100 then vsver[1] = vsver[1] + vbaltot .
        if bank.gl.gl = 215200 then vsver[2] = vsver[2] + vbaltot .
        if bank.gl.gl = 135200 then vsver[3] = vsver[3] + vbaltot .
        if bank.gl.gl = 215100 then vsver[4] = vsver[4] + vbaltot .
        */
    end. /*for each bank.gl.*/
end procedure.





