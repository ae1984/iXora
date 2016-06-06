/* rep_vp1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по валютной позиции
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
 * BASES
	BANK COMM TXB
 * AUTHOR

 * CHANGES
            03/05/2012 Luiza
            04/05/2012 Luiza - уменьшила формат вывода сообщения
            29/11/2012 Luiza TZ № 1570 счета 285800 285900 185900
*/


def shared var fdt as date.
def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.
def shared var g-ofc as char.

def shared var g-today as date.

def shared var d-rates as deci no-undo extent 20.
def shared var c-rates as deci no-undo extent 20.

def  var v185800 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var v-vt as decimal format 'zzz,zzz,zzz,zz9.99-'. /* Внебалансовые требования */
def  var v-vo as decimal format 'zzz,zzz,zzz,zz9.99-'. /* Внебалансовые  обязательства */
def  var v-pr as decimal format 'zzz,zzz,zzz,zz9.99-'. /* разница по прозивиям */

def  var v1858001 as decimal format 'zzz,zzz,zzz,zz9.99-'.
def  var v-vt1 as decimal format 'zzz,zzz,zzz,zz9.99-'. /* Внебалансовые требования */
def  var v-vo1 as decimal format 'zzz,zzz,zzz,zz9.99-'. /* Внебалансовые  обязательства */
def  var v-pr1 as decimal format 'zzz,zzz,zzz,zz9.99-'. /* разница по прозивиям */

def var v-sum as decim no-undo.
def var v-sumtotD as decim no-undo.
def var v-sumtotC as decim no-undo.

def new shared var sum1 as decimal.
def new shared var sum2 as decimal.
def new shared var sum3 as decimal.
def new shared var sum4 as decimal.
def new shared var sum5 as decimal.
def new shared var sum6 as decimal.
/*def new shared var sum7 as decimal.
def new shared var sum8 as decimal.*/
def new shared var v-crc as integer.

def var prov_od as deci no-undo.
def var prov_prc as deci no-undo.
def var prov_pen as deci no-undo.
def var prov_afn as deci no-undo.

define shared temp-table wrk1 no-undo
    field lev as int
    field fil as char
    field poz1 as decim
    field prov as decim
    field bay as decim
    field rate as decim
    field sel as decim
    field poz2 as decim
    field vo as decim
    field vt as decim
    field vou as decim /* внебал обязат на утро */
    field vtu as decim /* внебал треб на утро */
    field vd as decim
    field vc as decim
    field gl as int
    field rem as char
    field fio as char
    field corrgl as int
    field corrglname as char
    field doc as char
    field jh as int
    field id as char
    field tt as int
    field crc as int
    field crccode as char
    field sort1 as int
    field d as date
    index ind1 is primary  sort1 fil lev jh.


def buffer bjl for txb.jl.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
displ  ("Идет расчет по вал позиции " + v-fil-cnt) format "x(70)".
pause 0.
v-fil-int = v-fil-int + 1.


for each txb.crc no-lock where txb.crc.crc > 0 and txb.crc.sts ne 9 and txb.crc.crc <> 5
     break by txb.crc.crc:

     sum1 = 0.
     sum2 = 0.
     sum3 = 0.
     sum4 = 0.
     sum5 = 0.
     sum6 = 0.
     /*sum7 = 0.
     sum8 = 0.*/

    v-crc = txb.crc.crc.
    run rep_vp2.

    /* sum1 format 'zzz,zzz,zzz,zz9.99-' at 9 знак меняем на противоположный*/
    /* sum2 format 'zz,zzz,zzz,zz9.99-' at 29  дебет*/
    /* sum3 format 'z,zzz,zzz,zz9.99-' at 47   кредит */
    /* sum4 format 'zzz,zzz,zzz,zz9.99-' at 67   знак меняем на противоположный*/
    /* sum6 format 'zzz,zzz,zzz,zz9.99-' at 87       требования*/
    /* sum5 format 'zzz,zzz,zzz,zz9.99-' at 107       обяз-ва*/

    find first wrk1 where wrk1.crc = txb.crc.crc no-error.
    if not available wrk1 then do:
        create wrk1.
        wrk1.lev = 1.
        wrk1.crc = txb.crc.crc.
        if txb.crc.crc = 1 then wrk1.sort1 = txb.crc.crc + 100. else wrk1.sort1 = txb.crc.crc.
        wrk1.crccode  = txb.crc.code.
        wrk1.fil  = v-fil-cnt.
    end.
    find first wrk1  where wrk1.crc = txb.crc.crc and wrk1.lev = 1 no-error.
    wrk1.poz1 = wrk1.poz1 + sum1 /*+ sum5 - sum6 */.
    wrk1.prov = wrk1.prov +  sum1. /* вх ост по 185800*/
    wrk1.bay = wrk1.bay + sum2.
    wrk1.rate = wrk1.rate + sum3.
    wrk1.sel = wrk1.sel + sum4.
    wrk1.vo = wrk1.vo + sum6. /* обязат внебал */
    wrk1.vt = wrk1.vt + sum5. /* треб внеб*/
    /*wrk1.vd = wrk1.vd + sum7.*/ /* обороты внебал дебет */
    /*wrk1.vc = wrk1.vc + sum8.*/ /* обороты внебал кредит */
    wrk1.poz2 = wrk1.poz2 + sum4 + sum5 - sum6.
    /* поиск внебаланс требов и обязат на утро --------------------------------*/
     fdt = fdt - 1.
     sum1 = 0.
     sum2 = 0.
     sum3 = 0.
     sum4 = 0.
     sum5 = 0.
     sum6 = 0.
     /*sum7 = 0.
     sum8 = 0.*/
     run rep_vp2.
     find first wrk1  where wrk1.crc = txb.crc.crc and wrk1.lev = 1 no-error.
     wrk1.poz1 = wrk1.poz1 + (sum5 - sum6).
     wrk1.vou = wrk1.vou + sum6. /* обязат внебал */
     wrk1.vtu = wrk1.vtu + sum5. /* треб внеб*/
     fdt = fdt + 1.
     /*------------------------------------------------------------------------------*/

    /* сбор покупки  */
    v-sum = 0.
    v-sumtotD = 0.
    v-sumtotC = 0.
    for each txb.jl where txb.jl.jdt = fdt and ((txb.jl.gl = 185800 or txb.jl.gl = 285800 or txb.jl.gl = 185900 or txb.jl.gl = 285900) or (txb.jl.gl >= 600000 and txb.jl.gl <= 641500 and txb.jl.gl <> 603600 ) or
                        (txb.jl.gl >= 650000 and txb.jl.gl <= 691500 and txb.jl.gl <> 653600)) and txb.jl.crc = txb.crc.crc no-lock.
        create wrk1.
        wrk1.lev = 4.
        wrk1.fil = v-fil-cnt.
        wrk1.crc = txb.crc.crc.
        if txb.crc.crc = 1 then wrk1.sort1 = txb.crc.crc + 100. else wrk1.sort1 = txb.crc.crc.
        wrk1.crccode  = txb.crc.code.
        wrk1.rate = 0.
        wrk1.gl = txb.jl.gl.
        if txb.jl.dc = "C" then do: /* покупка */
           if txb.crc.crc = 1 then do:
               if txb.jl.gl = 185900 or txb.jl.gl = 285900 then do:
                    wrk1.bay = txb.jl.cam.
                    v-sumtotC = v-sumtotC + txb.jl.cam.
                end.
                else do:
                    wrk1.sel = txb.jl.cam.
                    v-sumtotD = v-sumtotD + txb.jl.cam.
                end.
           end.
           else do: /* не тенге  */
               if txb.jl.gl = 185800 or txb.jl.gl = 285800 then do:
                    wrk1.bay = txb.jl.cam.
                    v-sumtotC = v-sumtotC + txb.jl.cam.
                end.
                else do:
                    wrk1.sel = txb.jl.cam.
                    v-sumtotD = v-sumtotD + txb.jl.cam.
                end.
           end.
           find first bjl where bjl.jh = txb.jl.jh and bjl.dc = "D" and bjl.crc = txb.jl.crc and bjl.ln = txb.jl.ln - 1 no-lock no-error.
        end.
        if txb.jl.dc = "D" then do:  /*продажа */
           if txb.crc.crc = 1 then do:
                if txb.jl.gl = 185900  or txb.jl.gl = 285900  then do:
                    wrk1.sel = txb.jl.dam.
                    v-sumtotD = v-sumtotD + txb.jl.dam.
                end.
                else do:
                    wrk1.bay = txb.jl.dam.
                    v-sumtotC = v-sumtotC + txb.jl.dam.
                end.
            end.
            else do: /*  не тенге  */
                if txb.jl.gl = 185800  or txb.jl.gl = 285800  then do:
                    wrk1.sel = txb.jl.dam.
                    v-sumtotD = v-sumtotD + txb.jl.dam.
                end.
                else do:
                    wrk1.bay = txb.jl.dam.
                    v-sumtotC = v-sumtotC + txb.jl.dam.
                end.
            end.
            find first bjl where bjl.jh = txb.jl.jh and bjl.dc = "C" and bjl.crc = txb.jl.crc and  bjl.ln = txb.jl.ln + 1 no-lock no-error.
        end.

        if available bjl then do:
            wrk1.corrgl = bjl.gl.
            find first txb.gl where txb.gl.gl = bjl.gl no-lock no-error.
            if avail txb.gl then wrk1.corrglname = txb.gl.des.
        end.
        wrk1.rem = txb.jl.rem[1].
        wrk1.id = txb.jl.who.
        wrk1.jh = txb.jl.jh.
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if available txb.jh then do:
           wrk1.tt = txb.jh.tim.
           wrk1.doc = txb.jh.party.
            find first txb.joudoc where txb.joudoc.docnum = txb.jh.party no-lock no-error.
            if available txb.joudoc then do:
                if txb.joudoc.info <> "" then wrk1.fio = txb.joudoc.info.
                else if txb.jl.rem[1] begins "Обмен валюты" then wrk1.fio = "Обменный пункт".
                if txb.joudoc.srate > 1 then wrk1.rate = txb.joudoc.srate.
                else  wrk1.rate = txb.joudoc.brate.
                if txb.jl.rem[1] = "" then wrk1.rem = txb.joudoc.remark[1].
            end.
            else do:
                find first txb.dealing_doc where txb.dealing_doc.jh = txb.jl.jh no-lock no-error.
                if available txb.dealing_doc then wrk1.rate = txb.dealing_doc.rate.
                if txb.jl.rem[1] = "" then do:
                    find first bjl where bjl.jh = txb.jl.jh and  bjl.ln = 1 no-lock no-error.
                    wrk1.rem = bjl.rem[1].
                    find first txb.aaa where txb.aaa.aaa = bjl.acc no-lock no-error.
                    if available txb.aaa then do:
                        find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                        if available txb.cif then wrk1.fio = txb.cif.name.
                    end.
                end.
            end.
        end.
    end.
    create wrk1.
    wrk1.lev = 3.
    wrk1.fil = v-fil-cnt.
    wrk1.crc = txb.crc.crc.
    if txb.crc.crc = 1 then wrk1.sort1 = txb.crc.crc + 100. else wrk1.sort1 = txb.crc.crc.
    wrk1.crccode  = txb.crc.code.
    wrk1.bay = v-sumtotC.
    wrk1.sel = v-sumtotD.
end.

