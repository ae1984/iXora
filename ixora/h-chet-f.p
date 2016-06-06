/* h-chet-f.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Поиск клиента на другом филиале
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
        17/07/2012 Luiza
 * CHANGES

        12/10/2012 Luiza - вызов run perev поменяла на run perev_txb по СЗ от ОД
*/


define input parameter vcif as char.
define input parameter vtar as char.
define input parameter vsum as char.
define output parameter vf as char.
define output parameter vc as int.
define output parameter vname as char.
define output parameter vcode as char.
define output parameter vrnn as char.
define output parameter vtarname as char.
define output parameter vsumk as decim.
define output parameter vkt as int.
define output parameter vst as int.
define output parameter vmail as char.
vf = "".
vc = 0.
vname = "".
vcode = "".
vrnn = "".
vtarname = "".
vsumk = 0.
vkt = 0.
vmail = "".
vst = 0.

def var vec as char.
def var vbin as logi init no.
/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
if avail txb.sysc then vmail = trim(entry(5, txb.sysc.chval, "|")) no-error.

find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then vbin = txb.sysc.loval.

DEFINE QUERY q-help FOR txb.aaa, txb.lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY txb.aaa.aaa label "Счет клиента " format "x(20)" txb.aaa.cr[1] - txb.aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       txb.aaa.sta label "Статус" format "x(1)" txb.aaa.crc label "Вл " format "z9" txb.lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.

find first txb.aaa where txb.aaa.cif = vcif and txb.aaa.crc = 1 and length(txb.aaa.aaa) >= 20 and txb.aaa.sta <> "C" and txb.aaa.sta <> "E" no-lock no-error.
if available txb.aaa then do:
    OPEN QUERY  q-help FOR EACH txb.aaa where  txb.aaa.cif = vcif and length(txb.aaa.aaa) >= 20 and txb.aaa.sta <> "C" and txb.aaa.sta <> "E" no-lock,
                each txb.lgr where txb.aaa.lgr = txb.lgr.lgr and txb.lgr.led <> "ODA" no-lock.
    ENABLE ALL WITH FRAME f-help.
    wait-for return of frame f-help
    FOCUS b-help IN FRAME f-help.
    vf = txb.aaa.aaa.
    vc = txb.aaa.crc.
    hide frame f-help.
    find first txb.cif where txb.cif.cif = vcif no-lock no-error.
    if avail txb.cif then do:
        vname  = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
        if vbin then vrnn = txb.cif.bin. else vrnn = txb.cif.jss.

        if txb.cif.type = "P" then vec = "9".
        else do:
            find last txb.sub-cod where txb.sub-cod.acc = vcif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" no-lock no-error.
            if available txb.sub-cod then vec = txb.sub-cod.ccode.
            else do:
                message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                return.
            end.
        end.
        if txb.cif.geo = "021" then vcode = "1" + vec.
        else do:
            if   txb.cif.geo = "022" then vcode = "2" + vec.
            else do:
                message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                return.
            end.
        end.
    end.
    find first txb.tarif2 where txb.tarif2.str5 = vtar  and txb.tarif2.stat  = "r" no-lock no-error.
    if avail txb.tarif2 then do:
        vtarname = txb.tarif2.pakalp.
        vkt = txb.tarif2.kont.
    end.
     /* вычисление суммы комиссии-----------------------------------*/
    v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev_txb (vf,input vtar, input vsum, input vc, input vc, vcif, output v-amt, output tproc, output pakal).
    vsumk = v-amt.
    /*------------------------------------------------------------*/
    vst = 1.

end.
else do:
    MESSAGE "СЧЕТ КЛИЕНТА В ТЕНГЕ НЕ НАЙДЕН." view-as alert-box.
    vst = 0.
    return.
end.

