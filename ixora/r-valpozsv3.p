/* r-valpozsv3.p
 * MODULE

 * DESCRIPTION
        Валютная позиция (Сводная)
        Расчет по одной валюте для одного филиала
 * RUN

 * CALLER
        valpozsv3.p
 * SCRIPT

 * INHERIT

 * MENU
        7.4.3.5
 * BASES
        BANK COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27/11/2002 nataly   - были доработаны остатки по внебалансам по принципу
                              все счета 6 класса  где totgl <> 0 and totlev = 1 + остатки по ARP
                              счетам 640510/640520 для активов или 690510/690520 для пассивов,
                              где проставлен признак arpcrc в соответсвующей валюте
                              Если признак arpcrc не проставлен или задан как msc расчет ВП прерывается!
        11.02.2004 nadejda  - свела вместе r-valpozsv2.p и r-valpozsv3.p сюда
        11/02/2005 nataly   - добавила txb.gl.type eq "o" для sysc.sysc = "vadip5"
        24.07.09 marinav    - не учитывать счет 699920
        18.01.2012 damir    - не учитывать счета ГК начинающиеся на 699.
        19.06.2012 damir    - добавил расчет v-sum1,v-sum2.
        23.10.2012 damir    - Внедрено Т.З. № 1491.Выявлена ошибка,устранено.
 */

def shared var vcrc     as inte format ">9".
def shared var tt1      as char extent 13.
def shared var vbal     as deci format "z,zzz,zzz,zz9.99" .
def shared var vbeur    as deci format "z,zzz,zzz,zz9.99" .
def shared var vrate    as deci.
def shared var dat1     as date format "99/99/9999".
def shared var i        as inte.
def shared var g-today  as date.
def shared var v-stop   as logi init false.
def shared var v-ast    as logi init true.
def shared var v-sum1   as deci.
def shared var v-sum2   as deci.

def buffer b-gl      for txb.gl.
def buffer t-sub-cod for txb.sub-cod.

def var vbal1   as deci.
def var dt      as deci.
def var ct      as deci.

v-ast = true.
find first txb.glbal where txb.glbal.crc eq vcrc and txb.glbal.bal ne 0 no-lock no-error.
if not available txb.glbal then  v-ast = false.

case i :
when 12 then do:

    for each txb.gl no-lock where txb.gl.totgl <> 0 and txb.gl.totlev = 1 and string(txb.gl.gl) begins "6" and txb.gl.gl < 650000
    break by txb.gl.type by txb.gl.gl:
        find last txb.glday where txb.glday.gl eq txb.gl.gl and txb.glday.crc eq vcrc and txb.glday.gdt <= dat1 no-lock no-error.
        if available txb.glday then   vbal = vbal + txb.glday.bal * vrate.
    end.    /* for each txb.gl */

    for each txb.arp where txb.arp.gl = 640510 or txb.arp.gl = 640520 no-lock.
        find  txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc =  txb.arp.arp and txb.sub-cod.d-cod = "clsa"  no-lock.
        if txb.sub-cod.ccode <> "msc" then next.
        else find  t-sub-cod where t-sub-cod.sub = "arp" and t-sub-cod.acc =  txb.arp.arp and t-sub-cod.d-cod = "arpcrc"  no-lock no-error.
        if not available t-sub-cod or t-sub-cod.ccode = "msc" then do:
            message "По счету ARP " txb.arp.arp " не задан признак arpcrc" skip "  или задан как msc!"  view-as alert-box.
            message "Дальнейший расчет ВП невозможен!!! "  view-as alert-box.
            v-stop = true.
            return.
        end.

        if available t-sub-cod and t-sub-cod.ccode = string(vcrc) then do:
            /* остаток на счету на текущий момент */
            if dat1 = g-today  then vbal = vbal + (txb.arp.dam[1] - txb.arp.cam[1]).
            else do:
                /* остаток на счету на дату запроса */
                ct = 0 . dt = 0.
                for each txb.jl no-lock where txb.jl.acc eq txb.arp.arp and txb.jl.jdt gt dat1 by txb.jl.jdt:
                    dt =  dt + jl.dam.
                    ct  = ct + jl.cam.
                end.

            end. /* else */
            vbal = vbal + (txb.arp.dam[1] - txb.arp.cam[1]) - (dt - ct).
        end. /*t-sub-cod.ccode = string(vcrc) */
    end.   /* for each txb.arp */
end.  /* j = 12 */

when 13 then do : /* j = 13 */
    for each txb.gl no-lock where txb.gl.totgl <> 0 and txb.gl.totlev = 1 and string(txb.gl.gl) begins "6" and txb.gl.gl >= 650000
    and txb.gl.gl < 699920 break by txb.gl.gl:
        if string(txb.gl.gl) begins "699" then next.
        find last txb.glday where txb.glday.gl eq txb.gl.gl and txb.glday.crc eq vcrc and txb.glday.gdt <= dat1 no-lock no-error.
        if available txb.glday then vbal = vbal + txb.glday.bal * vrate.
    end.   /* for each txb.gl */

    for each txb.arp where txb.arp.gl = 690510 or txb.arp.gl = 690520 no-lock.
        find  txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc =  txb.arp.arp and txb.sub-cod.d-cod = "clsa"  no-lock no-error.
        if txb.sub-cod.ccode <> "msc" then next.
        else find  t-sub-cod where t-sub-cod.sub = "arp" and t-sub-cod.acc =  txb.arp.arp and t-sub-cod.d-cod = "arpcrc"  no-lock no-error.
        if not available t-sub-cod or t-sub-cod.ccode = "msc" then do:
            message "По счету ARP " txb.arp.arp " не задан признак arpcrc" skip
            "  или задан как msc!"  view-as alert-box.
            message "Дальнейший расчет ВП невозможен!!! " view-as alert-box.
            v-stop = true.
            return.
        end.
        if t-sub-cod.ccode = string(vcrc) then do:
            /* остаток на счету на текущий момент */
            if dat1 = g-today then vbal = vbal + (txb.arp.cam[1] - txb.arp.dam[1]).
            else do:
                /* остаток на счету на дату запроса */
                ct = 0 . dt = 0.
                for each txb.jl no-lock where txb.jl.acc eq txb.arp.arp and txb.jl.jdt gt dat1 by txb.jl.jdt:
                    dt =  dt + jl.dam.
                    ct  = ct + jl.cam.
                end.
            end. /* else */
            vbal = vbal + (txb.arp.cam[1] - txb.arp.dam[1]) - ( ct - dt).
        end. /*t-sub-cod.ccode = string(vcrc) */
    end.   /* for each txb.arp */
end.  /* j =13 */
otherwise do: /* i = 1 to 11  */
    for each txb.gl no-lock where (txb.gl.type eq "A" or txb.gl.type eq "L" or txb.gl.type eq "o") and  txb.gl.ibfact eq false and
    can-do(tt1[i],string(txb.gl.gl)) break by txb.gl.type by txb.gl.gl:
        find last txb.glday where txb.glday.gl eq txb.gl.gl and txb.glday.crc eq vcrc and txb.glday.gdt <= dat1 no-lock no-error.
        if available txb.glday then vbal = vbal + txb.glday.bal * vrate.
        if txb.gl.ibfgl <> 0 then do:
            find b-gl where b-gl.gl eq txb.gl.ibfgl no-lock no-error.
            if v-ast then do:
                find txb.glbal where txb.glbal.gl eq b-gl.gl and  txb.glbal.crc eq vcrc no-lock  no-error.
                vbal = vbal + txb.glbal.bal * vrate.
            end. /*v-ast*/
        end.
        /*if txb.gl.vadisp then do :
            if v-ast and txb.glbal.crc = 3 then vbeur = vbal.
            else do :
                if v-ast and txb.glbal.crc = 11 then do :
                    vbal = vbal + vbeur.
                    vbeur = 0.
                end.
            end.
        end.*/
    end. /*txb. gl */
    if i = 3 then do:
        find last txb.glday where txb.glday.gl eq 142800 and txb.glday.crc eq vcrc and txb.glday.gdt <= dat1 no-lock no-error.
        if available txb.glday then v-sum1 = v-sum1 + txb.glday.bal * vrate.

        find last txb.glday where txb.glday.gl eq 910010 and txb.glday.crc eq vcrc and txb.glday.gdt <= dat1 no-lock no-error.
        if available txb.glday then v-sum2 = v-sum2 + txb.glday.bal * vrate.
    end.
end.
end case.



