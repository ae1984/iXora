/* surrend1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Взнос сдачи ЭК на счет клиента
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
 * AUTHOR
        04/06/2012 Luiza
 * CHANGES
            22/08/2012 luiza добавила входящ параметр v-crc
*/


define input parameter v-jh as integer no-undo. /* Номер проводки*/
define input parameter v-summ as decimal no-undo. /*Сумма платежа*/
define input parameter v-arp as character no-undo. /*Арп счет 100500 по дебету*/
define input parameter v-crc as int no-undo. /* Валюта*/
define output parameter ss-jh as integer no-undo. /* Номер новой проводки*/
def new shared var s-jh like jh.jh.
define shared var g-ofc  as char.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-cif as char format "x(6)". /* cif клиент*/
def var v-cif1 as char format "x(6)". /* cif клиент*/
def  var v_namek as char no-undo format "x(20)".
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v-ec as char  no-undo format "x(1)".
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
define new shared variable s-aaa like aaa.aaa.
v_title = "Перевод остатков/сдачи на счет клиента".
def var v_doc as char.
def var v-info as char.
def var v-cifmin as char.
def var v-perkod as char.
/*------------------------------------*/


   form
        v-chet  label " Счет клиента            "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet and lookup(string(aaa.gl),"220520,220620,220720") > 0 and aaa.crc = v-crc no-lock),
                "Введите счет клиента открытого на сч ГК 220520,220620,220720") skip
        v_namek label " Клиент                  "  format "x(50)" skip
        v-crc   label " Валюта                  "  skip
        v-summ  LABEL " Сумма                   "  format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_code  label " КОД                     "  skip
        v_kbe   label " КБе                     "  skip
        v_knp   label " КНП                     "  format "x(3)" validate(lookup(v_knp,"311,312,314,319,421,423,424,429") > 0,
                                                  "Неверный КНП, F2 - помощь") skip
        v_oper  label " Назначение платежа      "  format "x(55)" skip
        v-ja    label " Формировать транзакцию ?"
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 85 FRAME f_main.


/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/*  help for cif */

DEFINE QUERY q-knp FOR codfr.

DEFINE BROWSE b-knp QUERY q-knp
       DISPLAY codfr.code label "Код  " format "x(3)" codfr.name[1] label "Наименование   " format "x(60)"
       WITH  15 DOWN.
DEFINE FRAME f-knp b-knp  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 35 width 85 NO-BOX.

on help of v_knp in frame f_main do:
    OPEN QUERY  q-knp FOR EACH codfr where codfr.codfr = "spnpl" and lookup(codfr.code,"311,312,314,319,421,423,424,429") > 0 no-lock.
    ENABLE ALL WITH FRAME f-knp.
    wait-for return of frame f-knp
    FOCUS b-knp IN FRAME f-knp.
    v_knp = codfr.code.
    hide frame f-knp.
    displ v_knp with frame f_main.
end.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
/*  help for cif */
on help of v-chet in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = v-crc and lookup(string(aaa.gl),"220520,220620,220720") > 0 no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" and aaa.crc = v-crc and lookup(string(aaa.gl),"220520,220620,220720") > 0 no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chet = aaa.aaa.
            hide frame f-help.
            displ v-chet with frame f_main.
        end.
        else do:
            v-chet = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-chet with frame f_main.
            return.
        end.
    end.
    else DELETE PROCEDURE phand.
end.
find first jh where jh.jh = v-jh no-lock no-error.
if avail jh then do:
    find first joudoc where joudoc.docnum  = jh.party no-lock no-error.
    v-info = joudoc.info.
    v-cifmin = joudoc.kfmcif.
    v-perkod = joudoc.perkod.
end.

    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            if cif.type = "P" then v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)).
            else v_namek = trim(trim(cif.prefix) + " " + trim(cif.name)).
            if cif.type = "P" then v-ec = "9".
            else do:
                find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                if available sub-cod then v-ec = sub-cod.ccode.
                else do:
                    message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                    undo, return.
                end.
            end.
            if cif.geo = "021" then v_kbe = "1" + v-ec.
            else do:
                if   cif.geo = "022" then v_kbe = "2" + v-ec.
                else do:
                    message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                    undo, return.
                end.
            end.
            if aaa.sta = "C" then do:
                message "Счет закрыт.".
                pause 3.
                undo, return.
            end.

            find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
            if available aas then do:
                message "ОСТАНОВКА ПЛАТЕЖЕЙ!".
                pause 3.
                undo,return.
            end.
        end.
    end.
    v_oper = "Пополнение счета/вклада (перечисление остатка/сдачи)".
    find first trxcods where trxcods.trxh = v-jh and trxcods.trxln = 1 and trxcods.codfr = "locat" no-lock no-error.
    if available trxcods then v_code = trim(trxcods.code).
    find first trxcods where trxcods.trxh = v-jh and trxcods.trxln = 1 and trxcods.codfr = "secek" no-lock no-error.
    if available trxcods then v_code = v_code + trim(trxcods.code).

    displ v_namek v-crc  v-summ v_code v_kbe  v_oper with frame f_main.

    update v_knp v-ja  with frame f_main.
    if not v-ja or keyfunction (lastkey) = "end-error" then do:
        hide frame f_main.
        undo,return.
    end.

    /*EK 100500------------------------------------------------------*/
    s-jh = 0.
   /* формир v-param для trxgen.p */
    v-param = "" + vdel + string(v-summ) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chet + vdel +
                v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_code,2,1) + vdel + v_knp + vdel + string(v-summ).
    run trxgen ("JOU0046", vdel, v-param, "arp", "", output rcode, output rdes, input-output s-jh).
    if rcode <> 0 then do:
        message rdes.
        pause.
        undo, return.
    end.

    run jou.
    v_doc = return-value.
    find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
    if available joudoc then do:
        joudoc.info  = v-info.
        joudoc.benname = v_namek.
        joudoc.kfmcif = v-cifmin.
        joudoc.perkod = v-perkod.
    end.
    find first joudoc no-lock no-error.

    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v_doc.
    jh.jh2 = v-jh.
    find first jh no-lock no-error.
    run trxsts (input s-jh, input 6, output rcode, output rdes).
    if rcode ne 0 then do:
        message rdes.
        undo, return.
    end.

    run chgsts("jou", v_doc, "rdy").

    ss-jh = s-jh.
    MESSAGE "ПРОВОДКА СФОРМИРОВАНА, НОМЕР: " + string(s-jh) view-as alert-box.
    /*if v-noord = no then run vou_bankt(1, 1, "").
    else run printord(s-jh,"").*/
    hide frame f_main.
