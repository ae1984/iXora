/* Mt103ToRmz.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        04.10.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
        30.11.2012 evseev
        19.12.2012 evseev
        21.12.2012 evseev
        27.12.2012 evseev
        27.03.2013 evseev tz-1633
*/

{global.i}
{lgps.i new}

def var v-cur            as char.    /*валюта ISO*/
def var v-crc            as int.     /*валюта иксоры*/
def var v-sum            as decimal. /*сумма*/
def var v-acc            as char.    /*счет получателя*/
def var v-benef          as char.    /*наименование получателя*/
def var v-namesender     as char.    /*отправитель*/
def var v-details        as char.    /*назначение платежа*/
def var v-bicsender      as char.    /*бик банка отправителя*/
def var v-country        as char.    /*страна отправителя*/
def var v-country52      as char.    /*страна отправителя*/
def var v-accsender      as char.    /*счет банка отправителя*/
def var v-rbank          as char.    /*Банк получателя */
def var v-kod            as char.    /*код*/
def var v-kbe            as char.    /*кбе*/
def var v-knp            as char.    /*кнп*/

def var v-rmz            as char.

def var v-bank           as char no-undo.
def var v-isfindaaa      as logical no-undo.
def var v-sta            as char no-undo.
def var vbin             as char no-undo.
def var v-cifname        as char no-undo.
def var v-lgr as char no-undo.
def var i                as int.

def var v-bankname as char.
def var v-bb as char.
def var vbb as char extent 3.
def var v-drgl as int.
def var v-cracc as char.
def var v-crgl as int.
def var v-transl as char.

define var v-org as char.
define var v-dest as char.
define var v-err as logical.

def buffer b-swift for swift.

def new shared var      s-remtrz like remtrz.remtrz.

for each swift where swift.mt = "103" and swift.io = "O" and swift.dt >= today - 11 use-index idx_mt no-lock:
    find last swift_sts where swift_sts.swift_id = swift.swift_id use-index idx_swift_id no-lock no-error.
    if avail swift_sts and swift_sts.sts <> "check" then next.

    assign
      v-cur = ""           v-bicsender = ""     v-knp = ""
      v-crc = 0            v-country = ""       v-rmz = ""
      v-sum = 0            v-country52 = ""     v-bank = ""
      v-acc = ""           v-accsender = ""     v-isfindaaa = false
      v-benef = ""         v-rbank = ""         v-sta = ""
      v-namesender = ""    v-kod = ""           vbin = ""
      v-details = ""       v-kbe = ""           v-cifname  = ""
      v-transl = "".

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.val matches "*\{2:*" no-lock no-error.
    if avail swift_det then do:
       v-bicsender = substr(swift_det.val,index(swift_det.val,"\{2:") + 17,8).
       find first swibic where swibic.bic = v-bicsender + "XXX" no-lock no-error.
       if not avail swibic then run InsSwiftSts(swift.swift_id, "BIC " + v-bicsender + " не найден в справочнике swibic","warning").
       v-country = substr(swift_det.val,index(swift_det.val,"\{2:") + 21,2).
       find first code-st where code-st.code = v-country no-lock no-error.
       if avail code-st then do:
          if v-country = "KZ" then assign v-kod = "14" v-kbe = "14" v-knp = "150".
                              else assign v-kod = "24" v-kbe = "14" v-knp = "150".
       end. else run InsSwiftSts(swift.swift_id, "Страна с кодом " + v-country + " не найдена в справочнике code-st","warning").
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле \{2:","warning").

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "59" no-lock no-error.
    if avail swift_det then do:
       v-acc = trim(entry(2,swift_det.val,"/")) no-error.
       v-rbank = "TXB" + substr(v-acc,19,2).
       run findaaa(v-acc,v-rbank, output v-bank, output v-isfindaaa, output v-sta, output vbin, output v-cifname, output v-lgr).
       if v-isfindaaa = false then do:
          v-acc = "".
          v-rbank = "".
          run InsSwiftSts(swift.swift_id, "Счет получателя " + v-acc + " не найден","warning").
       end.
       if v-isfindaaa and v-sta = "C" then run InsSwiftSts(swift.swift_id, "Счет получателя " + v-acc + " закрыт","warning").
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле :59:","warning").

    v-cifname = "".
    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "59" no-lock no-error.
    if avail swift_det then do:
        /*v-namesender = entry(3,swift_det.val,":") no-error.*/
        i = 1.
        repeat:
           find next swift_det.
           if swift_det.fld <> "" or i >= 4 then leave.
           v-cifname = v-cifname + swift_det.val.
           i = i + 1.
        end.
    end. else do:
       run InsSwiftSts(swift.swift_id, "Не найдено поле :59:","warning").
    end.


    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "52" no-lock no-error.
    if avail swift_det then do:
       if swift_det.fld = "52A" then v-country52 = substr(entry(3,swift_det.val,":"),5,2) no-error.
       if swift_det.fld =  "52D" then do:
          v-country52 = substr(entry(3,swift_det.val,":"),3,2) no-error.
          find first code-st where code-st.code = v-country52 no-lock no-error.
          if not avail code-st and swift_det.val begins "52D://" then do:
             if lookup(substr(entry(3,swift_det.val,'/'),1,3),'040,041,042,043,044,045,046,047,048,049') > 0 then v-country52 = "RU".
          end.
       end.
       find first code-st where code-st.code = v-country52 no-lock no-error.
       if not avail code-st then do:
          run InsSwiftSts(swift.swift_id, "Страна с кодом " + v-country52 + " не найдена в справочнике code-st","warning").
          v-country52 = "msc".
       end.
    end. else do:
       run InsSwiftSts(swift.swift_id, "Не найдено поле :52x:","warning").
       v-country52 = "msc".
    end.

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "32A" no-lock no-error.
    if avail swift_det then do:
       v-cur = substr(entry(3,swift_det.val,":"),7,3) no-error.
       find first crc where crc.code = v-cur no-lock no-error.
       if avail crc then v-crc = crc.crc.
       else run InsSwiftSts(swift.swift_id, "Не найдена валюта " + v-cur + " в справочнике crc","warning").
       v-sum = decimal(replace(substr(entry(3,swift_det.val,":"),10,length(swift_det.val)),",",".")) no-error.
       if error-status:error then run InsSwiftSts(swift.swift_id, "Ошибка определения суммы в поле :32A:","warning").
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле :32A:","warning").

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "20" no-lock no-error.
    if avail swift_det then do:
       v-transl = substr(entry(3,swift_det.val,":"),1,1) no-error.
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле :20:","error").

    v-namesender = "".
    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld begins "50" no-lock no-error.
    if avail swift_det then do:
        /*v-namesender = entry(3,swift_det.val,":") no-error.*/
        i = 1.
        repeat:
           find next swift_det.
           if swift_det.fld <> "" or i >= 4 then leave.
           if (v-crc = 4 and i >= 2) or (v-crc <> 4 and i >= 1) then v-namesender = v-namesender + swift_det.val.
           i = i + 1.
        end.
    end. else do:
        run InsSwiftSts(swift.swift_id, "Не найдено поле :50x:","warning").
    end.

    v-details = "".
    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "70" no-lock no-error.
    if avail swift_det then do:
        v-details = entry(3,swift_det.val,":") no-error.
        i = 1.
        repeat:
           find next swift_det.
           if swift_det.fld <> "" or i >= 4 then leave.
           v-details = v-details + swift_det.val.
           i = i + 1.
        end.
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле :70:","warning").

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.val begins "/NZP/" no-lock no-error.
    if avail swift_det then do:
        v-details = v-details + entry(3,swift_det.val,"/") no-error.
        repeat:
           find next swift_det.
           if not(swift_det.val begins "//") then leave.
           v-details = v-details + entry(3,swift_det.val,"/").
        end.
    end.

    if v-transl = "+" then do:
        v-org = v-namesender.
        run lat2rur(input v-org, output v-dest, output v-err).
        v-namesender = v-dest.

        v-org = v-details.
        run lat2rur(input v-org, output v-dest, output v-err).
        v-details = v-dest.
    end.

    find first bankl where bankl.bic matches "*" + v-bicsender + "*" no-lock no-error.
    if avail bankl then do:
       find first bankt where bankt.cbank = bankl.cbank and bankt.crc = v-crc no-lock no-error.
       if avail bankt then  v-accsender = trim(bankt.acc).
       else run InsSwiftSts(swift.swift_id, "Счет для банка " + bankl.cbank + " и валюты " + string(v-crc) + " не найден в справочнике bankt","warning").
    end. else run InsSwiftSts(swift.swift_id, "BIC " + v-bicsender + " не найден в справочнике bankl","warning").

    find first sysc where sysc.sysc = "bankname" no-lock no-error.
    if avail sysc then v-bankname = sysc.chval.
    find first bankl where bankl.bank = v-rbank no-lock no-error.
    if avail bankl then do:
       v-bb = trim(bankl.name) + " " + trim(bankl.addr[1]) + " " + trim(bankl.addr[2] + " " + bankl.addr[3]).
       vbb[1] = bankl.name.
       vbb[2] = bankl.addr[1].
       vbb[3] = bankl.addr[2] + " " + bankl.addr[3].
    end. else v-bb = "".
    find first dfb where dfb.dfb = v-accsender no-lock no-error.
    if avail dfb then v-drgl = dfb.gl. else v-drgl = ?.
    find first bankt where bankt.cbank = v-rbank and bankt.crc = v-crc no-lock no-error.
    if avail bankt then v-cracc = bankt.acc. else v-cracc = "".
    find first aaa where aaa.aaa = v-cracc no-lock no-error.
    if avail aaa then v-crgl = aaa.gl. else v-crgl = ?.

    if length(v-acc) = 20 and substr(v-acc,19,2) = "00" then do:
       run savelog( "mt103tormz", "234. Первую проводку не создавать ").
       run InsSwiftSts(swift.swift_id, "Первую проводку не создавать","noCreate1trx").
    end.

    if v-bicsender = "KSNVKZKA"  then do:  /*Письмо от Милютиной во время тестирования 08.11.12*/
       run savelog( "mt103tormz", "196. От BIC " + v-bicsender + " RMZ не создавать").
       run InsSwiftSts(swift.swift_id, "От BIC " + v-bicsender + " RMZ не создавать","noRMZ").
    end. else do:
        do transaction:
            run n-remtrz.
            create remtrz.
            assign
            remtrz.remtrz      =  s-remtrz
            remtrz.ptype       =  "4"
            remtrz.rdt         =  g-today
            remtrz.amt         =  v-sum
            remtrz.payment     =  v-sum
            remtrz.svca        =  0
            remtrz.svcp        =  0
            remtrz.svcmarg     =  0
            remtrz.bb[1]       =  vbb[1]
            remtrz.bb[2]       =  vbb[2]
            remtrz.bb[3]       =  vbb[3]
            /*remtrz.bn[1]       =  v-cifname
            remtrz.bn[2]       =  " /RNN/" + vbin
            remtrz.bn[3]       =  ""*/
            remtrz.bn[1]       =  substr(v-cifname,1, 35)
            remtrz.bn[2]       =  substr(v-cifname,36, 35)
            remtrz.bn[3]       =  substr(v-cifname,71, 35)
            remtrz.ba          =  v-acc
            remtrz.ord         =  v-namesender
            remtrz.bi          =  ""
            remtrz.chg         =  7
            remtrz.cover       =  5
            remtrz.jh2         =  ?
            remtrz.jh1         =  ?
            remtrz.ref         =  string(swift.swift_id)
            remtrz.outcode     =  4
            remtrz.svcaaa      =  ""
            remtrz.svcgl       =  0
            remtrz.fcrc        =  v-crc
            remtrz.tcrc        =  v-crc
            remtrz.svcrc       =  0
            remtrz.ordcst[1]   =  substr(v-namesender,1, 35)
            remtrz.ordcst[2]   =  substr(v-namesender,36, 35)
            remtrz.ordcst[3]   =  substr(v-namesender,71, 35)
            remtrz.ordcst[4]   =  substr(v-namesender,106, 35)
            remtrz.ordins[1]   =  "АО " + v-bankname
            remtrz.ordins[2]   =  ""
            remtrz.ordins[3]   =  ""
            remtrz.ordins[4]   =  ""
            remtrz.ordinsact   =  ""
            remtrz.sndcor[1]   =  ""
            remtrz.sndcor[2]   =  ""
            remtrz.sndcor[3]   =  ""
            remtrz.sndcor[4]   =  ""
            remtrz.sndcoract   =  ""
            remtrz.rcvcor[1]   =  ""
            remtrz.rcvcor[2]   =  ""
            remtrz.rcvcor[3]   =  ""
            remtrz.rcvcor[4]   =  ""
            remtrz.rcvcoract   =  ""
            remtrz.intmed      =  ""
            remtrz.intmedact   =  ""
            remtrz.actins[1]   =  "/" + substr(v-bb,1,34)
            remtrz.actins[2]   =  substr(v-bb,35,35)
            remtrz.actins[3]   =  substr(v-bb,70,35)
            remtrz.actins[4]   =  substr(v-bb,105,35)
            remtrz.actinsact   =  v-rbank
            remtrz.ben[1]      =  remtrz.bn[1] + remtrz.bn[3]
            remtrz.ben[2]      =  ""
            remtrz.ben[3]      =  ""
            remtrz.ben[4]      =  ""
            remtrz.detpay[1]   =  substring(v-details, 1, 70)
            remtrz.detpay[2]   =  substring(v-details, 71, 70)
            remtrz.detpay[3]   =  substring(v-details, 141, 70)
            remtrz.detpay[4]   =  substring(v-details, 211, length(v-details))
            remtrz.rcvinfo[1]  =  ""
            remtrz.rcvinfo[2]  =  ""
            remtrz.rcvinfo[3]  =  ""
            remtrz.rcvinfo[4]  =  ""
            remtrz.rcvinfo[5]  =  ""
            remtrz.rcvinfo[6]  =  ""
            remtrz.sbank       =  "TXB00"
            remtrz.rbank       =  v-rbank
            remtrz.valdt1      =  g-today
            remtrz.valdt2      =  g-today
            remtrz.rwho        =  g-ofc
            remtrz.rtim        =  time
            remtrz.tlx         =  no
            remtrz.dracc       =  v-accsender
            remtrz.drgl        =  v-drgl
            remtrz.cracc       =  v-cracc
            remtrz.crgl        =  v-crgl
            remtrz.sacc        =  v-accsender
            remtrz.racc        =  v-acc
            remtrz.sqn         =  "TXB00." + trim(remtrz.remtrz) + ".." + trim(string(swift.swift_id, ">>>>>>>>9" ))
            remtrz.margb       =  0
            remtrz.margs       =  0
            remtrz.saddr       =  ""
            remtrz.raddr       =  ""
            remtrz.svccgl      =  0
            remtrz.scbank      =  "TXB00"
            remtrz.rcbank      =  v-rbank
            remtrz.rsub        =  "cif"
            remtrz.svccgr      =  302
            remtrz.t_sqn       =  s-remtrz
            remtrz.source      =  "mt103"
            remtrz.INFO[1]     =  ""
            remtrz.INFO[2]     =  ""
            remtrz.INFO[3]     =  ""
            remtrz.INFO[4]     =  ""
            remtrz.INFO[5]     =  ""
            remtrz.INFO[6]     =  ""
            remtrz.INFO[7]     =  ""
            remtrz.INFO[8]     =  ""
            remtrz.INFO[9]     =  ""
            remtrz.INFO[10]    =  ""
            remtrz.cwho        =  ""
            remtrz.own         =  no
            remtrz.bnksts      =  ""
            remtrz.vcact       =  ""
            remtrz.kfmcif      =  ""
            remtrz.package     =  ""
            remtrz.jh3         =  ?.
            if length(v-acc) = 20 and substr(v-acc,19,2) = "00" then do:
               remtrz.ptype   =  "7".
               remtrz.rsub    =  "valcon".
            end.

            run savelog( "mt103tormz", "276. RMZ " + s-remtrz).
            find first b-swift where b-swift.swift_id = swift.swift_id exclusive-lock no-error.
            if avail b-swift then b-swift.rmz = s-remtrz.
            else run savelog( "mt103tormz", "166. Swift_id не найден! " + string(swift.swift_id)).

            create sub-cod.
            assign
               sub-cod.acc = s-remtrz
               sub-cod.sub = "rmz"
               sub-cod.d-cod = "eknp"
               sub-cod.ccode = "eknp"
               sub-cod.rcode = v-kod + "," + v-kbe + "," + v-knp.
            create sub-cod.
            assign
               sub-cod.acc = s-remtrz
               sub-cod.sub = "rmz"
               sub-cod.d-cod = "iso3166"
               sub-cod.ccode = v-country52
               sub-cod.rdt = g-today
               sub-cod.rcode = "".
            run InsSwiftSts(swift.swift_id, "Создан RMZ " + s-remtrz + " к SWIFT-документу " + string(swift.swift_id) ,"ready").
        end.
        find first swift_sts where swift_sts.swift_id = swift.swift_id and swift_sts.sts = "error" no-lock no-error.
        if avail swift_sts then m_pid = "31". else  if length(v-acc) = 20 and substr(v-acc,19,2) = "00" then m_pid = "2l". else m_pid = "2T".  /* Код очереди */
        run rmzque.
    end.
end.