/*SLORO_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Формирование платежей с ЛОРО-счетов
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
        28/10/2013 galina - ТЗ1891
 * BASES
        BANK
 * CHANGES
        29/10/2013 galina - ТЗ1891
        13/11/2013 galina - ТЗ 2195 поправила заполение многострочных полей 59,70,50,52,57,72,70,58
*/

{lgps.i "new"}
{global.i}

def var v-cur            as char.    /*валюта ISO*/
def var v-crc            as int.     /*валюта иксоры*/
def var v-sum            as decimal. /*сумма*/
def var v-acc            as char.    /*счет получателя*/
def var v-benef          as char.    /*наименование получателя*/
def var v-namesender     as char.    /*отправитель*/
def var v-details        as char.    /*назначение платежа*/
def var v-bicsender      as char.    /*бик банка отправителя*/
def var v-country        as char.    /*страна отправителя*/
def var v-kod            as char.    /*код*/
def var v-kbe            as char.    /*кбе*/
def var v-knp            as char.    /*кнп*/


def var v-57avail as logi.
def var v-71 as char.
def var v-72 as char.
def var v-countrybn as char.

def var v-lgr as char no-undo.
def var i                as int.
def var v-drgl as int.

def var v-accben as char.
def var v-rbank as char.
def var v-isfindaaa as logi.

def var v_tar as char.
def var v-cif as char.
def var v-amt as deci.
def var tproc as int.
def var pakal as char.
def var v-bicben as char.
def var v-bank as char.
def var v-sta as  char.
def var vbin as char.
def var v-cifname as char.
def buffer b-swift for swift.

def var v-rmz like remtrz.remtrz.
def buffer b-swift_det for swift_det.

for each swift where (swift.mt = "103" or swift.mt = "202") and swift.io = "O" and swift.dt >= today - 11 use-index idx_mt no-lock:
    find last swift_sts where swift_sts.swift_id = swift.swift_id use-index idx_swift_id no-lock no-error.
    if avail swift_sts and swift_sts.sts <> "new" then next.

    assign
      v-cur = ""           v-bicsender = ""     v-knp = ""
      v-crc = 0            v-country = ""       v-rmz = ""
      v-sum = 0            v-countrybn = ""
      v-acc = ""
      v-namesender = ""    v-kod = ""
      v-details = ""       v-kbe = "" v-57avail = no v-71 = "" v-72 = "".

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "53B" no-lock no-error.
    if avail swift_det then do:
       v-acc = trim(entry(2,swift_det.val,"/")) no-error.

       find first aaa where aaa.aaa = v-acc no-lock no-error.
       if avail aaa then do:
           if aaa.gl <> 201300 then next.
           if aaa.sta = 'C' then run InsSwiftSts(swift.swift_id, "Лоро-счет " + v-acc + " закрыт","warning").
           if aaa.gl = 201300 and aaa.sta <> 'C' then do:
               find first cif where cif.cif = aaa.cif no-lock no-error.
               if avail cif then do:
                   if swift.mt = '202' then v-namesender = trim(cif.prefix + ' ' + cif.name).
                   assign  v-drgl = aaa.gl v-cif = cif.cif.
               end.
               else run InsSwiftSts(swift.swift_id, "Не найден CIF для " + v-acc,"warning").

           end.
       end.
       else next. /*run InsSwiftSts(swift.swift_id, "Лоро-счет " + v-acc + " не найден","warning").*/
    end.
    else next.


    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.val matches "*\{2:*" no-lock no-error.
    if avail swift_det then do:
       v-bicsender = substr(swift_det.val,index(swift_det.val,"\{2:") + 17,8).
       if swift.mt = "103" then do:
           v-country = substr(swift_det.val,index(swift_det.val,"\{2:") + 21,2).
           find first code-st where code-st.code = v-country no-lock no-error.
           if avail code-st then do:
              if v-country = "KZ" then assign v-kod = "14" v-kbe = "27" v-knp = "710".
              else assign v-kod = "24" v-kbe = "27" v-knp = "710".
           end.
           else run InsSwiftSts(swift.swift_id, "Страна с кодом " + v-country + " не найдена в справочнике code-st","warning").
       end.
    end.
    else run InsSwiftSts(swift.swift_id, "Не найдено поле \{2:","warning").

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "32A" no-lock no-error.
    if avail swift_det then do:
       v-cur = substr(entry(3,swift_det.val,":"),7,3) no-error.
       find first crc where crc.code = v-cur no-lock no-error.
       if avail crc then v-crc = crc.crc.
       else run InsSwiftSts(swift.swift_id, "Не найдена валюта " + v-cur + " в справочнике crc","warning").
       v-sum = decimal(replace(substr(entry(3,swift_det.val,":"),10,length(swift_det.val)),",",".")) no-error.
       if error-status:error then run InsSwiftSts(swift.swift_id, "Ошибка определения суммы в поле :32A:","warning").
    end.
    else run InsSwiftSts(swift.swift_id, "Не найдено поле :32A:","warning").

    v-countrybn = ''.
    v-bicben = ''.
    if swift.mt = '103' then do:
        v-details = "".
        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "70" no-lock no-error.
        if avail swift_det then do:
            v-details = entry(3,swift_det.val,":") no-error.
            i = 1.
            repeat:
               find next swift_det.
               if swift_det.fld <> "" or i >= 4 or swift_det.val begins '-}' then leave.
               v-details = v-details + swift_det.val.
               i = i + 1.
            end.
        end.
        else run InsSwiftSts(swift.swift_id, "Не найдено поле :70:","warning").


        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "71" no-lock no-error.
        if avail swift_det then v-71 = entry(3,swift_det.val,":") no-error.
        else run InsSwiftSts(swift.swift_id, "Не найдено поле :71:","warning").

        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "72" no-lock no-error.
        if avail swift_det then do:
            if v-72 = 'RPP' then v-72 = entry(3,swift_det.val,"/").
            else v-72 = entry(2,swift_det.val,"/") no-error.
        end.

        v-namesender = ''.
        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "50" no-lock no-error.
        if avail swift_det then do:
            i = 1.
            repeat:
               find next swift_det no-lock no-error.
               if swift_det.fld <> "" or i >= 5 or swift_det.val begins '-}' then leave.
               if v-namesender <> '' then v-namesender = v-namesender + ' '.
               v-namesender = v-namesender + trim(swift_det.val).
               i = i + 1.
            end.
        end.
        else run InsSwiftSts(swift.swift_id, "Не найдено поле :50x:","warning").


        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "57" no-lock no-error.
        if avail swift_det then do:
           v-57avail = yes.
           if substr(swift_det.val,4,1) = 'A' or substr(swift_det.val,4,1) = 'B' then v-countrybn = substr(entry(3,swift_det.val,':'),5,2).
           if substr(swift_det.val,4,1) = 'C' or substr(swift_det.val,4,1) = 'D' then v-countrybn = substr(entry(3,swift_det.val,':'),3,2).
           v-bicben = entry(3,swift_det.val,':').

        end.
        else run InsSwiftSts(swift.swift_id, "Не найдено поле :57x:","warning").

        if substr(v-bicben,1,8) = 'FOBAKZKA' then do:

            find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "59" no-lock no-error.
            if avail swift_det then do:
               v-accben = trim(entry(2,swift_det.val,"/")) no-error.

               v-rbank = "TXB" + substr(v-accben,19,2).
               run findaaa(v-accben,v-rbank, output v-bank, output v-isfindaaa, output v-sta, output vbin, output v-cifname, output v-lgr).
               if v-isfindaaa = false then do:
                  run findarp(v-accben,v-rbank, output v-isfindaaa, output v-sta, output vbin, output v-cifname).
                  if v-isfindaaa = false then do:
                     assign v-accben = ""
                            v-rbank = "".
                     run InsSwiftSts(swift.swift_id, "Счет получателя " + v-accben + " не найден","warning").
                  end.
               end.
               if v-isfindaaa and v-sta = "C" then run InsSwiftSts(swift.swift_id, "Счет получателя " + v-accben + " закрыт","warning").
            end.
            else run InsSwiftSts(swift.swift_id, "Не найдено поле :59:","warning").
        end.

        if v-57avail = no then do:
            case v-crc:
                when 2 then v_tar = '288'.
                when 3 then v_tar = '289'.
                when 4 then v_tar = '312'.
                otherwise run InsSwiftSts(swift.swift_id, "Платеж в пользу клиентов АО ForteBank неверный код валюты " + string(v-crc),"warning").
            end case.
        end.
        else do:
            if v-71 = 'BEN' or v-71 = 'SHA' then do:
                case v-crc:
                    when 2 then v_tar = '291'.
                    when 3 then v_tar = '294'.
                    otherwise run InsSwiftSts(swift.swift_id, "Комиссия за счет получателя неверный код валюты " + string(v-crc),"warning").
                end case.
            end.
            if v-71 = 'OUR' then do:
                case v-crc:
                    when 2 then if v-72 = 'GOUR' then v_tar = '293'.
                    when 3 then v_tar = '295'.
                    when 4 then if v-72  matches "*.BESP*" then v_tar = '313'. else v_tar = '303'.

                    otherwise run InsSwiftSts(swift.swift_id, "Комиссия за счет получателя неверный код валюты " + string(v-crc),"warning").
                end case.
            end.
        end.
    end.
    else do:

        find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "58" no-lock no-error.
        if avail swift_det then do:
            i = 1.
            repeat:
               find next swift_det no-lock no-error.
               if swift_det.fld <> "" or i >= 2 or swift_det.val begins '-}' then leave.
               v-countrybn = trim(swift_det.val).
               v-bicben = trim(swift_det.val).
               i = i + 1.
            end.

            if v-countrybn <> '' then do:
                if v-bicsender = v-countrybn then assign v-kod = "14" v-kbe = "14" v-knp = "321".
                else assign v-kod = "14" v-kbe = "24" v-knp = "119".
                find first b-swift_det where b-swift_det.swift_id = swift.swift_id and b-swift_det.fld begins "58" no-lock no-error.

                if substr(b-swift_det.val,4,1) = 'A' or substr(swift_det.val,4,1) = 'B' then v-countrybn = substr(v-countrybn,5,2).
                if substr(b-swift_det.val,4,1) = 'C' or substr(swift_det.val,4,1) = 'D' then v-countrybn = substr(v-countrybn,3,2).

            end.
        end.
        else run InsSwiftSts(swift.swift_id, "Не найдено поле :58x:","warning").


        case v-crc:
            when 2 then v_tar = '296'.
            when 3 then v_tar = '297'.
            when 4 then v_tar = '314'.
            otherwise run InsSwiftSts(swift.swift_id, "Определение тарифа комиссии неверный код валюты " + string(v-crc),"warning").
        end case.
    end.



    if v-countrybn  = '' then do:
        run InsSwiftSts(swift.swift_id, "Не определена страна бенефициара","warning").
        v-countrybn = 'msc'.
    end.
    else do:
        find first code-st where code-st.code = v-countrybn no-lock no-error.
        if not avail code-st then do:
           run InsSwiftSts(swift.swift_id, "Страна с кодом " + v-countrybn + " не найдена в справочнике code-st","warning").
            v-countrybn = "msc".
        end.
    end.
    if v_tar = '' then run InsSwiftSts(swift.swift_id, "Не опеределен код тарифа для комиссии","warning").


    find last swift_sts where swift_sts.swift_id = swift.swift_id use-index idx_swift_id no-lock no-error.
    if avail swift_sts and swift_sts.sts <> "warning" then do:

        do transaction:
            run perev (v-acc,input v_tar, input v-sum, input v-crc, input v-crc,v-cif, output v-amt, output tproc, output pakal).
            if substr(v-bicben,1,8) <> 'FOBAKZKA' then do:

                run rmzloro (v-sum,
                         v-acc,

                         v-namesender,
                         '',
                         '',
                         '',
                         '',
                         v-knp,
                         v-kod,
                         v-kbe,
                         v-details,
                         'G',
                         4,
                         'MT' + swift.mt,
                         yes,
                         swift.swift_id,
                         v-countrybn,
                         v-amt,
                         v_tar,
                         v-acc,
                         tproc).
            end.
            else do:

                if substr(v-accben,19,2) = "00" then run rmzloro (
                                                                  v-sum,
                                                                  v-acc,
                                                                  '',
                                                                  'TXB00',
                                                                  v-accben,
                                                                  vbin,
                                                                  v-cifname,
                                                                  v-knp,
                                                                  v-kod,
                                                                  v-kbe,
                                                                  v-details,
                                                                  '2l',
                                                                  5,
                                                                  'MT' + swift.mt,
                                                                  no,
                                                                  swift.swift_id,
                                                                  v-countrybn,
                                                                  v-amt,
                                                                  v_tar,
                                                                  v-acc,
                                                                  tproc).


                else run rmzloro (v-sum,
                                  v-acc,

                                  '',
                                  'TXB' + substr(v-accben,19,2),
                                  v-accben,
                                  vbin,
                                  v-cifname,
                                  v-knp,
                                  v-kod,
                                  v-kbe,
                                  v-details,
                                  '1P',
                                   5,
                                   'MT' + swift.mt,
                                   yes,
                                   swift.swift_id,
                                   v-countrybn,
                                   v-amt,
                                   v_tar,
                                   v-acc,
                                   tproc).
            end.
            v-rmz = return-value.

            if v-rmz <> '' then do:
                if substr(v-bicben,1,8) <> 'FOBAKZKA' then do:
/*****************/
                if swift.mt = '103' then do:
                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "23B" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "23"
                               swbody.type = "B"
                               swbody.content[1] = entry(3,swift_det.val,':').
                    end.

                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "50" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "50"
                               swbody.type = substr(entry(2,swift_det.val,':'),3,1)
                               swbody.content[1] = entry(3,swift_det.val,':').
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> "" or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.
                    end.

                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "59" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "59"
                               swbody.content[1] = entry(3,swift_det.val,':').
                               if length(entry(2,swift_det.val,':')) > 2 then swbody.type = substr(entry(2,swift_det.val,':'),3,1).
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.
                    end.

                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "70" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "70"
                               swbody.content[1] = entry(3,swift_det.val,':').

                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.
                    end.


                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "71" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "71"
                               swbody.type = substr(entry(2,swift_det.val,':'),3,1)
                               swbody.content[1] = entry(3,swift_det.val,':').
                    end.

                end.
                else do:
                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "20" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "21"
                               swbody.content[1] = entry(3,swift_det.val,':').
                    end.

                    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "58" no-lock no-error.
                    if avail swift_det then do:
                        create swbody.
                        assign swbody.rmz = v-rmz
                               swbody.swfield = "58"
                               swbody.content[1] = entry(3,swift_det.val,':')
                               swbody.type = substr(entry(2,swift_det.val,':'),3,1).
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.
                    end.


                end.
                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "32A" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "32"
                           swbody.type = "A"
                           swbody.content[1] = entry(3,swift_det.val,':').
                end.

                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "33" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "33"
                           swbody.type = substr(entry(2,swift_det.val,':'),3,1)
                           swbody.content[1] = entry(3,swift_det.val,':').
                end.


                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "53" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "52"
                           swbody.type = 'A'
                           swbody.content[1] = entry(3,swift_det.val,':').
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.
                        if swbody.content[2] = '' then swbody.content[2] = v-bicsender.
                end.

                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "56" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "56"
                           swbody.type = substr(entry(2,swift_det.val,':'),3,1)
                           swbody.content[1] = entry(3,swift_det.val,':').
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.

                end.
                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "57" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "57"
                           swbody.type = substr(entry(2,swift_det.val,':'),3,1)
                           swbody.content[1] = entry(3,swift_det.val,':').
                        i = 1.
                        repeat:
                           find next swift_det no-lock no-error.
                           if swift_det.fld <> '' or i >= 5 or swift_det.val begins '-}' then leave.
                           swbody.content[i + 1] = trim(swift_det.val).
                           i = i + 1.
                        end.

                end.
                find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "72" no-lock no-error.
                if avail swift_det then do:
                    create swbody.
                    assign swbody.rmz = v-rmz
                           swbody.swfield = "72"
                           swbody.content[1] = entry(3,swift_det.val,':').
                    i = 1.
                    repeat:
                       find next swift_det no-lock no-error.
                       if swift_det.fld <> '' or i >= 6 or swift_det.val begins '-}' then leave.
                       swbody.content[i + 1] = trim(swift_det.val).
                       i = i + 1.
                    end.

                end.
                end.

/***************/


                run savelog( "mt103loro", "1. RMZ " + v-rmz).
                find first b-swift where b-swift.swift_id = swift.swift_id exclusive-lock no-error.
                if avail b-swift then b-swift.rmz = v-rmz.
                else run savelog( "mt103loro", "1. Swift_id не найден! " + string(swift.swift_id)).

                run InsSwiftSts(swift.swift_id, "Создан RMZ " + v-rmz + " к SWIFT-документу " + string(swift.swift_id) ,"ready").
                v-text = "Создан RMZ " + v-rmz + " к SWIFT-документу " + string(swift.swift_id).
                run lgps.

            end.
        end.
    end.
end.

