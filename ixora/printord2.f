/* printord2.f
 * MODULE
        Название модуля - Используется во всех модулях.
 * DESCRIPTION
        Описание - Алгоритм вывода кассовых ордеров в WORD не включая 15 модуля.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - printord2.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        16.01.2012 damir    - добавил вывод номера ЭК.
        18.01.2012 damir    - корректировка.
        20.01.2012 damir    - перекомпиляция.
        29.02.2012 damir    - внедрено Т.З. № 1281 по подписям.
        05.03.2012 damir    - в поле Получатель, Клиент отображался РНН рядом с ФИО.
        06.03.2012 damir    - перекомпиляция.
        07.03.2012 damir    - убрал shared parameter s-jh, выходила ошибка...
        11.03.2012 damir    - добавил в назначение платежа дополнительные данные, если программа запускается с п.м. 4.2.15.
        12.03.2012 damir    - вывод в расходный кассовый ордер drek [10][11][12].., в поле получатель подтянуть с п.м. 3.2.4.2 поле
                              Бенефициар.
        20.03.2012 damir    - корректировка.
        26.03.2012 damir    - отображение подписей в п.м. 2.1.3.
        28.03.2012 damir    - отменил вывод подписей только в приходном ордере.
        28.03.2012 id00810  - добавила v-bankname для печати.
        30.03.2012 damir    - внедрено Т.З. № 1330, добавлены новые форматы для п.м. 4.1.3, 15.4, 4.1.8, 4.2.15. v-ifileuregcas,
                              v-ifileuregcas1,v-ifileuregcas2,v-ifileobmenop,v-ifilevydprnal.
        10.04.2012 damir    - ID сделал с маленькой буквы.
        13.04.2012 damir    - изменил формат с "yes/no" на "да/нет".
        18.04.2012 damir    - внедрено Т.З. № 1339.
        05.05.2012 damir    - информация о филиале тянется c sysc - <fullnamerus>, убрал v-bankname и при приходе и расходе по ARP
                              подтягивать АО <ForteBank>.
        08.05.2012 damir    - добавлен шаблон inoutcashordobmen2.htm.
        10.05.2012 damir    - уменьшил размер вырезки substr назначения платежа.
        23.05.2012 damir    - вывод в назначении платежа лицевого счета при проведении коммунальных платежей.
        24.05.2012 damir    - использование COMPAYDOCClass.
        07.05.2012 damir    - вывод номера ЭК в чеке БКС.
        18.06.2012 damir    - вывод ОКПО в чеке БКС, если Дт 100500 и Кт 100100, то приходный к.ордер и номер CASH не нужен.
        21.06.2012 damir    - корректировка.
        22.06.2012 damir    - вывод v-passpnum,v-passpdt,v-passpwho.
        25.06.2012 damir    - согласно Т.З. убрал, "если Дт 100500 и Кт 100100, то приходный к.ордер и номер CASH не нужен".
        28.06.2012 damir    - перекомпиляция.
        05.07.2012 damir    - перекомпиляция.
        12.07.2012 damir    - добавил printGetEKNP-автом.формирование КОд,КБе,КНП, в v-modperoper + g-fname = A_OBMEN,убрал v-bankname.
        09.08.2012 damir    - добавил новые шаблоны v-ifilecomplat,v-ifilecomplat2, Коммунальные платежи, g-fname в v-fname,stream v-out3,v-iofileord7,
                              v-iofileord8,v-iofileord9,v-logcomusl.
        10.08.2012 damir    - корректировка, не учтено при тестировании.
        11.09.2012 damir    - Переход на ИИН/БИН. Реализовано Т.З. <Изменение цветовой гаммы в приходных/расходных ордерах>.
        13.09.2012 damir    - добавил no-lock.
        02.11.2012 damir    - Изменения, связанные с изменением шаблонов по конвертации.isConvGL.
        07.11.2012 damir    - Внедрено Т.З. № 1365,1481,1538. Добавил все типы обозначенные в iXora.
        26.12.2012 damir    - Внедрено Т.З. 1624.
        12.02.2013 damir    - Внедрено Т.З. 1676.
        26/03/2013 Luiza    - ТЗ 1714 добавила g-fname  = a_obmen2
        30.07.2013 damir - Внедрено Т.З. № 1494.
        30.09.2013 damir - Внедрено Т.З. № 1648.
*/
{comm-txb.i}

def var v-datastr as char format "x(20)".
def var v-datastrkz as char format "x(20)".
def var v-databks as char format "x(20)".
def var v-databkskz as char format "x(20)".
def var xin as deci decimals 2 format "-z,zzz,zzz,zzz,zz9.99". /*Дебет*/
def var xout as deci decimals 2 format "-z,zzz,zzz,zzz,zz9.99". /*Кредит*/
def var decAmount like xin.
def var decAmount2 like xin.
def var strAmount as char format "x(80)".
def var strAmount2 as char format "x(80)".
def var strAmountkzt as char format "x(80)".
def var strAmountkzt2 as char format "x(80)".
def var strTemp as char.
def var str1 as char format "x(80)".
def var str2 as char format "x(80)".
def var decAmountT like xin.
def var decAmountT2 like xin.
def var v-iscash as logi.
def var i as inte init 0.
def var j as inte init 0.
def var k as inte init 0.
def var q as inte init 0.
def var v-sub as logi init no.
def var v-com as char.
def var v-kods as char.
def var v-remtrz as char.
def var v-sumobm as deci decimals 2.
def var v-ofileinput as char init "".
def var v-ifileinput as char init "".
def var v-ofileoutput as char init "".
def var v-ifileoutput as char init "".
def var v-ofileinput2 as char init "".
def var v-ifileinput2 as char init "".
def var v-ofileoutput2 as char init "".
def var v-ifileoutput2 as char init "".
def var v-iofileord as char init "ord1.htm".
def var v-iofileord2 as char init "ord2.htm".
def var v-obmenoper as logi format "да/нет".
def var ln1 as inte.
def var ln2 as inte.
def var v-lnstr as char.
def var v-dcstr as char.
def var v-gl1 as inte.
def var v-gl2 as inte.
def var v-sumobmenoper as deci.
def var v-strtmp as char.
def var v-matchestmp as char.
def var v-ifileuregcas as char. /*Шаблон п.м. 4.1.8*/
def var v-ifileuregcas1 as char. /*Шаблон п.м. 4.1.8*/
def var v-ifileuregcas2 as char. /*Шаблон п.м. 4.1.8*/
def var v-ifileobmenop as char. /*Шаблон п.м. 4.1.3 и п.м. 15.4*/ /*С контрольным чеком БКС*/
def var v-ifileobmenop2 as char. /*Шаблон п.м. 4.1.3 и п.м. 15.4*/ /*Без контрольного чека БКС*/
def var v-ifilevydprnal as char. /*Шаблон п.м. 4.2.15*/
def var v-ifilecomplat as char. /*Шаблон п.м. 4.1.2.1,4.1.2.3*/
def var v-ifilecomplat2 as char. /*Шаблон п.м. 4.1.2.1,4.1.2.3*/
def var v-iofileord3 as char init "ord3.htm".
def var v-iofileord4 as char init "ord4.htm".
def var v-iofileord5 as char init "ord5.htm".
def var v-iofileord6 as char init "ord6.htm".
def var v-iofileord7 as char init "ord7.htm".
def var v-iofileord8 as char init "ord8.htm".
def var v-iofileord9 as char init "ord9.htm".
def var v-filemain as char init "Mainord.htm".
def var v-filemain2 as char init "Mainord2.htm".
def var v-tmplogi as logi init no.
def var v-outprefix as char init "".
def var v-consumd as deci.
def var v-consumc as deci.
def var v-funlog as logi init no.
def var v-glcash as logi init no.
def var v-nazncomusl as char.
def var v-sumcomusl as deci.
def var v-ourbnk as char.
def var v-tm as char.
def var temp as char.

/*def var v-modperoper as char init "A_KZ,A_DOCH,A_JOU,A_1CAS,A_2CAS,A_INCAS,ACOM,A_UNI,OBMEN,A_OBMEN,A_OBMEN2,COMPAY,COMLIST,TLCA0,GJTE0".
def var v-fname as char init "TIYN,,,cas110,,,".*/

def var v-modperoper as char init "TIYN,cas110".
def var v-fname as char init "TIYN,,,cas110,,,".

def buffer drate for crc.

def buffer b-ljl  for ljl.
def buffer b2-ljl for ljl.

def var v-str   as char.
def stream v-out.
def stream v-out2.
def stream v-out3.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-ourbnk = comm-txb().

if v-doccontrol = yes then do:
    if v-idconfname <> "" then do:
        find last ordsignat where ordsignat.ofc = v-idconfname no-lock no-error.
        if avail ordsignat and ordsignat.sign = yes then do:
            /*Директория подписей контроллеров*/
            def var v-dcpath as char.
            find first pksysc where pksysc.credtype = "6" and pksysc.sysc = "dcpath" no-lock no-error.
            if avail pksysc then v-dcpath = trim(pksysc.chval).
            v-dir = v-idconfname + "order.jpg".
            v-pathdir = g-dbdir + v-dcpath.
            v-dir = replace(v-dir,"ID","id").
            v-idconfname = replace(v-idconfname,"ID","id").
            hide message. pause 0.
            input through value("ssh Administrator@`askhost` dir /B c:\\\\tmp\\\\" + v-dir).
            import unformatted v-res.
            input close.
            if v-res matches "*" + v-dir +  "*" then do:
            end.
            else do:
                unix silent value("scp " + v-pathdir + v-dir + " Administrator@`askhost`:C:\\\\tmp\\\\").
            end.
            hide message. pause 0.
        end.
    end.
end.

IF LOOKUP(trim(g-fname),trim(v-modperoper)) > 0 THEN DO:
    i = 0. v-nazncomusl = "". v-sumcomusl = 0.

    /*ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР*/
    incash:
    for each ljl where ljl.jh = jh.jh and ljl.dc = "D" and (ljl.gl = 100100 or ljl.gl = 100500 or ljl.gl = 100110) and ljl.crc <> 0 no-lock by ljl.ln:
        v-ifileuregcas  = "/data/export/inoutcashord.htm". /*Шаблон для п.м. 4.1.8 - урегулирование кассы*/
        v-ifileuregcas1 = "/data/export/inoutcashord1-1.htm". /*Шаблон для п.м. 4.1.8 - урегулирование кассы - Приходный*/
        v-ifilevydprnal = "/data/export/inoutcashord2.htm". /*Шаблон для п.м. 4.2.15 - выдача/прием денежной наличности по счету ГК 100110*/

        xin = 0. v-KOd = "". v-KBe = "". v-KNP = "". v-crc = "". v-obmenoper = no. v-onacc = "". v-crcobmen = "". v-glcash = no.
        decAmount = 0. decAmountT = 0. strAmountkzt = "".

        v-storn = ljl.rem[1] matches "*storn*" or ljl.rem[2] matches "*storn*" or ljl.rem[3] matches "*storn*" or ljl.rem[4] matches "*storn*" or ljl.rem[5] matches "*storn*".
        run printGetEKNP(v-storn,ljl.jh,ljl.dc,ljl.ln,trim(ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).

        run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz). /* День месяц(прописью) год */
        run pkdefdtstr(string(dtreg,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */

        xin = ljl.dam.
        find first crc where crc.crc = ljl.crc no-lock no-error.
        if avail crc then v-crc = crc.code.

        decAmount = xin.
        run SWords(decAmount,ljl.crc,ljl.jdt,input-output strAmount,input-output strAmountkzt).

        if ljl.rem[1] <> "" then v-naznplat = ljl.rem[1].
        else if ljl.rem[2] <> "" then v-naznplat = ljl.rem[2].
        else if ljl.rem[3] <> "" then v-naznplat = ljl.rem[3].
        else if ljl.rem[4] <> "" then v-naznplat = ljl.rem[4].
        else if ljl.rem[5] <> "" then v-naznplat = ljl.rem[5].

        if g-fname = trim(entry(1,v-fname)) then do:
            output stream v-out to value(v-iofileord3).
            find first b-ljl where b-ljl.jh = ljl.jh and b-ljl.cam = ljl.dam and b-ljl.dc = "C" and b-ljl.crc <> 0 and b-ljl.ln <> 0 no-lock no-error.
            if avail b-ljl then do:
                if b-ljl.gl = 100100 or b-ljl.gl = 100200 or b-ljl.gl = 100110 or b-ljl.gl = 100500 then do:
                    input from value(v-ifileuregcas).
                end.
                else do:
                    input from value(v-ifileuregcas1).
                    v-tmplogi = yes.
                end.
            end.
        end.
        if g-fname = trim(entry(4,v-fname)) then do:
            if v-info <> "" then do:
                if trim(v-info) = "1" then v-naznplat = v-naznplat + " (Дебет 100100 Кредит 100110) " + ljl.rem[4].
                if trim(v-info) = "2" then v-naznplat = v-naznplat + " (Дебет 100110 Кредит 100100) " + ljl.rem[4].
            end.

            output stream v-out to value(v-iofileord3).
            input from value(v-ifilevydprnal).
            v-onacc = string(ljl.gl).
        end.
        if lookup(g-fname,v-fname) > 0 then output stream v-out2 to value(v-iofileord4).

        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*day*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"day",entry(1,v-datastr," ")).
                    else v-str = replace (v-str,"day","").
                    next.
                end.
                if v-str matches "*month*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"month",entry(2,v-datastr," ")).
                    else v-str = replace (v-str,"month","").
                    next.
                end.
                if v-str matches "*year*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"year",entry(3,v-datastr," ")).
                    else v-str = replace (v-str,"year","").
                    next.
                end.
                if v-str matches "*ofcname*" then do:
                    v-str = replace (v-str,"ofcname",v-ofcnam).
                    next.
                end.
                if v-str matches "*fullnmbnkobl*" then do:
                    if v-city <> "" then v-str = replace (v-str,"fullnmbnkobl",v-city).
                    else v-str = replace (v-str,"fullnmbnkobl","").
                    next.
                end.
                if v-str matches "*cok*" then do:
                    if v-cokname <> "" then v-str = replace (v-str,"cok",trim(v-cokname)).
                    else v-str = replace (v-str,"cok","").
                    next.
                end.
                if v-str matches "*account*" then do:
                    if v-onacc <> "" then v-str = replace (v-str,"account",v-onacc).
                    else v-str = replace (v-str,"account","").
                    next.
                end.
                if v-str matches "*jheader*" then do:
                    v-str = replace (v-str,"jheader",string(jh.jh)).
                    next.
                end.
                if v-str matches "*joudocnum*" then do:
                    if jh.ref <> "" then v-str = replace (v-str,"joudocnum",jh.ref).
                    else v-str = replace (v-str,"joudocnum","").
                    next.
                end.
                if v-str matches "*whoreceive*" then do:
                    if v-whorecei <> "" then v-str = replace (v-str,"whoreceive",trim(v-whorecei)).
                    else v-str = replace (v-str,"whoreceive","").
                    next.
                end.
                if v-str matches "*receivefrom*" then do:
                    if v-incas <> "" then v-str = replace (v-str,"receivefrom",v-incas).
                    else v-str = replace (v-str,"receivefrom","").
                    next.
                end.
                if v-str matches "*udostoverenie*" then do:
                    if v-passpnum <> "" then v-str = replace (v-str,"udostoverenie",v-passpnum).
                    else v-str = replace (v-str,"udostoverenie","").
                    next.
                end.
                if v-str matches "*udovwhnvydan*" then do:
                    if v-passpdt <> ? then v-str = replace (v-str,"udovwhnvydan",string(v-passpdt,"99/99/9999")).
                    else v-str = replace (v-str,"udovwhnvydan","").
                    next.
                end.
                if v-str matches "*udovkemvydan*" then do:
                    if v-passpwho <> "" then v-str = replace (v-str,"udovkemvydan",v-passpwho).
                    else v-str = replace (v-str,"udovkemvydan","").
                    next.
                end.
                if v-str matches "*iin*" then do:
                    if v-iinbin <> "" then v-str = replace (v-str,"iin",v-iinbin).
                    else v-str = replace (v-str,"iin", "").
                    next.
                end.
                if v-str matches "*+A*" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+A",substr(trim(v-KOd),1,1)).
                    else v-str = replace (v-str,"+A", "").
                    next.
                end.
                if v-str matches "*+B**" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+B",substr(trim(v-KOd),2,1)).
                    else v-str = replace (v-str,"+B","").
                    next.
                end.
                if v-str matches "*+C*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+C",substr(trim(v-KBe),1,1)).
                    else v-str = replace (v-str,"+C","").
                    next.
                end.
                if v-str matches "*+D*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+D",substr(trim(v-KBe),2,1)).
                    else v-str = replace (v-str,"+D","").
                    next.
                end.
                if v-str matches "*+KNP*" then do:
                    if v-KNP <> "" then v-str = replace (v-str,"+KNP",trim(v-KNP)).
                    else v-str = replace (v-str,"+KNP","").
                    next.
                end.
                if v-str matches "*crccode*" then do:
                    v-str = replace (v-str,"crccode",CAPS(crc.code)).
                    next.
                end.
                if v-str matches "*sumoperation*" then do:
                    if xin <> 0 then v-str = replace (v-str,"sumoperation",string(xin,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sumoperation","").
                    next.
                end.
                if v-str matches "*sumoperpropis*" then do:
                    if strAmount <> "" then v-str = replace (v-str,"sumoperpropis",strAmount).
                    else v-str = replace (v-str,"sumoperpropis","").
                    next.
                end.
                if v-str matches "*ekvivalten*" then do:
                    if strAmountkzt <> "" then v-str = replace (v-str,"ekvivalten",strAmountkzt).
                    else v-str = replace (v-str,"ekvivalten","-").
                    next.
                end.
                if length(trim(v-naznplat)) < 90 then do:
                    if v-str matches "*naznplat*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"naznplat",trim(v-naznplat)).
                        else v-str = replace (v-str,"naznplat","").
                        next.
                    end.
                    if v-str matches "*extension*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"extension"," ").
                        else v-str = replace (v-str,"extension"," ").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*naznplat*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"naznplat",substr(trim(v-naznplat),1,90)).
                        else v-str = replace (v-str,"naznplat","").
                        next.
                    end.
                    if v-str matches "*extension*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"extension",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                        else v-str = replace (v-str,"extension"," ").
                        next.
                    end.
                end.
                if v-str matches "*bksnumber*" then do:
                    v-str = replace (v-str,"bksnumber",string(jh.jh)).
                    next.
                end.
                if v-str matches "*dtbks*" then do:
                    v-str = replace (v-str,"dtbks",entry(1,v-databks," ")).
                    next.
                end.
                if v-str matches "*mhbks*" then do:
                    v-str = replace (v-str,"mhbks",entry(2,v-databks," ")).
                    next.
                end.
                if v-str matches "*yrbks*" then do:
                    v-str = replace (v-str,"yrbks",entry(3,v-databks," ")).
                    next.
                end.
                if v-str matches "*timebks*" then do:
                    v-str = replace (v-str,"timebks",string(time,"HH:MM:SS")).
                    next.
                end.
                if v-glcash = yes then do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" and v-elcash <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> Рег.№ ЭК </B> &nbsp;" + v-elcash + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> ОКПО </B> &nbsp;" + v-okpo).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb)).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                if v-str matches "*binbnk*" then do:
                    if v-bnkbin <> "" then v-str = replace (v-str,"binbnk",trim(v-bnkbin)).
                    else v-str = replace (v-str,"binbnk","").
                    next.
                end.
                if v-str matches "*elcash*" then do:
                    if v-elcash <> "" then v-str = replace (v-str,"elcash",v-elcash).
                    else v-str = replace (v-str,"elcash","").
                    next.
                end.
                if v-str matches "*kassirfioname*" then do:
                    find ofc where ofc.ofc = ljl.teller no-lock no-error.
                    if ljl.teller <> "" then v-str = replace (v-str,"kassirfioname",if avail ofc then ofc.name else "").
                    else v-str = replace (v-str,"kassirfioname","").
                    next.
                end.
                if v-str matches "*prihod*" then do:
                    if xin <> 0 then v-str = replace (v-str,"prihod",string(xin, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crc).
                    else v-str = replace (v-str,"prihod","").
                    next.
                end.
                if v-obmenoper = yes then do:
                    if v-str matches "*rashod*" then do:
                        v-str = replace (v-str,"rashod",string(v-sumobmenoper, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crcobmen).
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*rashod*" then do:
                        v-str = replace (v-str,"rashod","").
                        next.
                    end.
                    if v-str matches "*КУРС*" then v-str = replace (v-str,"КУРС","").
                end.
                if v-str matches "*kursbks*" then do:
                    if v-obmenoper = yes then do:
                        if v-curs <> 0 then v-str = replace (v-str,"kursbks",v-strtmp + " " + string(v-curs, ">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"kursbks","").
                    end.
                    else do:
                        v-str = replace (v-str,"kursbks","").
                    end.
                    next.
                end.

                if i > 1 then do:
                    if v-str matches "*mkoijkkhji*" then do:
                        if v-onacc <> "" then v-str = replace (v-str,"mkoijkkhji",v-onacc).
                        else v-str = replace (v-str,"mkoijkkhji","").
                        next.
                    end.
                    if v-str matches "*asgdftwehsjd*" then do:
                        if v-whorecei <> "" then v-str = replace (v-str,"asgdftwehsjd",trim(v-whorecei)).
                        else v-str = replace (v-str,"asgdftwehsjd","").
                        next.
                    end.
                    if v-str matches "*oeorjq*" then do:
                        v-str = replace (v-str,"oeorjq",CAPS(crc.code)).
                        next.
                    end.
                    if v-str matches "*jkiygretgudfu*" then do:
                        if xin <> 0 then v-str = replace (v-str,"jkiygretgudfu",string(xin,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"jkiygretgudfu","").
                        next.
                    end.
                    if v-str matches "*kdjfgnhwkdkd*" then do:
                        if strAmount <> "" then v-str = replace (v-str,"kdjfgnhwkdkd",strAmount).
                        else v-str = replace (v-str,"kdjfgnhwkdkd","").
                        next.
                    end.
                    if v-str matches "*jkwiefnnjdkfhd*" then do:
                        if strAmountkzt <> "" then v-str = replace (v-str,"jkwiefnnjdkfhd",strAmountkzt).
                        else v-str = replace (v-str,"jkwiefnnjdkfhd","-").
                        next.
                    end.
                    if length(trim(v-naznplat)) < 90 then do:
                        if v-str matches "*aslkdnfbhf*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"aslkdnfbhf",trim(v-naznplat)).
                            else v-str = replace (v-str,"aslkdnfbhf","").
                            next.
                        end.
                        if v-str matches "*sjkdhdkakkl*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"sjkdhdkakkl"," ").
                            else v-str = replace (v-str,"sjkdhdkakkl"," ").
                            next.
                        end.
                    end.
                    else do:
                        if v-str matches "*aslkdnfbhf*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"aslkdnfbhf",substr(trim(v-naznplat),1,90)).
                            else v-str = replace (v-str,"aslkdnfbhf","").
                            next.
                        end.
                        if v-str matches "*sjkdhdkakkl*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"sjkdhdkakkl",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                            else v-str = replace (v-str,"sjkdhdkakkl"," ").
                            next.
                        end.
                    end.
                    if v-str matches "*kjdutngjkdk*" then do:
                        if v-nazncomusl <> "" then v-str = replace (v-str,"kjdutngjkdk",substr(trim(v-nazncomusl),1,140)).
                        else v-str = replace (v-str,"kjdutngjkdk","").
                        next.
                    end.
                    if v-str matches "*iuwebsjwi*" then do:
                        if v-sumcomusl <> 0 then v-str = replace (v-str,"iuwebsjwi",string(v-sumcomusl, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crc).
                        else v-str = replace (v-str,"iuwebsjwi","").
                        next.
                    end.
                    if v-str matches "*+E*" then do:
                        if v-KOd <> "" then v-str = replace (v-str,"+E",substr(trim(v-KOd),1,1)).
                        else v-str = replace (v-str,"+E", "").
                        next.
                    end.
                    if v-str matches "*+F**" then do:
                        if v-KOd <> "" then v-str = replace (v-str,"+F",substr(trim(v-KOd),2,1)).
                        else v-str = replace (v-str,"+F","").
                        next.
                    end.
                    if v-str matches "*+J*" then do:
                        if v-KBe <> "" then v-str = replace (v-str,"+J",substr(trim(v-KBe),1,1)).
                        else v-str = replace (v-str,"+J","").
                        next.
                    end.
                    if v-str matches "*+K*" then do:
                        if v-KBe <> "" then v-str = replace (v-str,"+K",substr(trim(v-KBe),2,1)).
                        else v-str = replace (v-str,"+K","").
                        next.
                    end.
                    if v-str matches "*+PNK*" then do:
                        if v-KNP <> "" then v-str = replace (v-str,"+PNK",trim(v-KNP)).
                        else v-str = replace (v-str,"+PNK","").
                        next.
                    end.
                end.
                if v-str matches "*RNBNIN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"RNBNIN","ИИН/БИН").
                        else v-str = replace (v-str,"RNBNIN","РНН").
                    end.
                    else v-str = replace (v-str,"RNBNIN","РНН").
                    next.
                end.
                if v-str matches "*BNNRNN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"BNNRNN","БИН").
                        else v-str = replace (v-str,"BNNRNN","РНН").
                    end.
                    else v-str = replace (v-str,"BNNRNN","РНН").
                    next.
                end.
                leave.
            end.
            put stream v-out unformatted v-str skip.
        end.
        input close.
        output stream v-out close.

        if lookup(g-fname,v-fname) > 0 then input from value(v-iofileord3).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*signcon*" then do:
                    v-str = replace (v-str,"signcon","").
                    next.
                end.
                leave.
            end.
            put stream v-out2 unformatted v-str skip.
        end.
        input close.
        output stream v-out2 close.
    end.

    if g-fname = trim(entry(1,v-fname)) and v-tmplogi = yes then unix silent cptwin value(v-iofileord4) winword.

    /*РАСХОДНЫЙ КАССОВЫЙ ОРДЕР*/
    outcash:
    for each ljl where ljl.jh = jh.jh and ljl.dc = "C" and (ljl.gl = 100100 or ljl.gl = 100500 or ljl.gl = 100110) and ljl.crc <> 0 no-lock by ljl.ln:
        v-ifileuregcas2 = "/data/export/inoutcashord1-2.htm". /*Шаблон для п.м. 4.1.8 - урегулирование кассы - Расходный*/

        xout = 0. v-KOd = "". v-KBe = "". v-KNP = "". v-crc = "". v-accfrom = "". v-obmenoper = no. v-crcobmen = "". v-funlog = no.
        v-glcash = no. decAmount = 0. decAmountT = 0. strAmountkzt = "".

        v-storn = ljl.rem[1] matches "*storn*" or ljl.rem[2] matches "*storn*" or ljl.rem[3] matches "*storn*" or ljl.rem[4] matches "*storn*" or ljl.rem[5] matches "*storn*".
        run printGetEKNP(v-storn,ljl.jh,ljl.dc,ljl.ln,trim(ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).

        run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz). /* День месяц(прописью) год */
        run pkdefdtstr(string(dtreg,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */

        xout = ljl.cam.
        find first crc where crc.crc = ljl.crc no-lock no-error.
        if avail crc then v-crc = crc.code.

        /*-------------------------------Вывод суммы прописью---------------------------------------*/
        decAmount = xout.
        run SWords(decAmount,ljl.crc,ljl.jdt,input-output strAmount,input-output strAmountkzt).

        if ljl.rem[1] <> "" then v-naznplat = ljl.rem[1].
        else if ljl.rem[2] <> "" then v-naznplat = ljl.rem[2].
        else if ljl.rem[3] <> "" then v-naznplat = ljl.rem[3].
        else if ljl.rem[4] <> "" then v-naznplat = ljl.rem[4].
        else if ljl.rem[5] <> "" then v-naznplat = ljl.rem[5].

        if g-fname = trim(entry(4,v-fname)) then do:
            if v-info <> "" then do:
                if trim(v-info) = "1" then v-naznplat = v-naznplat + " (Дебет 100100 Кредит 100110) " + ljl.rem[4].
                if trim(v-info) = "2" then v-naznplat = v-naznplat + " (Дебет 100110 Кредит 100100) " + ljl.rem[4].
            end.
            v-accfrom = string(ljl.gl).
        end.

        if g-fname = trim(entry(1,v-fname)) then do:
            output stream v-out to value(v-iofileord4).
            find first b-ljl where b-ljl.jh = ljl.jh and b-ljl.dam = ljl.cam and b-ljl.dc = "D" no-lock no-error.
            if avail b-ljl and b-ljl.gl <> 100100 and b-ljl.gl <> 100200 or b-ljl.gl <> 100110 or b-ljl.gl <> 100500 and b-ljl.crc <> 0 and b-ljl.ln <> 0 then
            input from value(v-ifileuregcas2).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                put stream v-out unformatted v-str skip.
            end.
            input close.
            output stream v-out close.
        end.

        if lookup(g-fname,v-fname) > 0 then do:
            output stream v-out to value(v-iofileord5).
            input from value(v-iofileord4).
        end.

        if lookup(g-fname,v-fname) > 0 then output stream v-out2 to value(v-iofileord6).

        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*day*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"day",entry(1,v-datastr," ")).
                    else v-str = replace (v-str,"day","").
                    next.
                end.
                if v-str matches "*month*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"month",entry(2,v-datastr," ")).
                    else v-str = replace (v-str,"month","").
                    next.
                end.
                if v-str matches "*year*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"year",entry(3,v-datastr," ")).
                    else v-str = replace (v-str,"year","").
                    next.
                end.
                if v-str matches "*ofcname*" then do:
                    v-str = replace (v-str,"ofcname",v-ofcnam).
                    next.
                end.
                if v-str matches "*fullnmbnkobl*" then do:
                    if v-city <> "" then v-str = replace (v-str,"fullnmbnkobl",v-city).
                    else v-str = replace (v-str,"fullnmbnkobl"," ").
                    next.
                end.
                if v-str matches "*cok*" then do:
                    if v-cokname <> "" then v-str = replace (v-str,"cok",trim(v-cokname)).
                    else v-str = replace (v-str,"cok","").
                    next.
                end.
                if v-str matches "*jheader*" then do:
                    v-str = replace (v-str,"jheader",string(jh.jh)).
                    next.
                end.
                if v-str matches "*joudocnum*" then do:
                    if jh.ref <> "" then v-str = replace (v-str,"joudocnum",jh.ref).
                    else v-str = replace (v-str,"joudocnum","").
                    next.
                end.
                if v-str matches "*nmclpoiuwyet*" then do:
                    if v-clien <> "" then v-str = replace (v-str,"nmclpoiuwyet",trim(v-clien)).
                    else v-str = replace (v-str,"nmclpoiuwyet","").
                    next.
                end.
                if v-str matches "*receivewho*" then do:
                    if v-outcas <> "" then v-str = replace (v-str,"receivewho",v-outcas).
                    else v-str = replace (v-str,"receivewho","").
                    next.
                end.
                if v-str matches "*udostoverenie*" then do:
                    if v-passpnum <> "" then v-str = replace (v-str,"udostoverenie",v-passpnum).
                    else v-str = replace (v-str,"udostoverenie","").
                    next.
                end.
                if v-str matches "*udovwhnvydan*" then do:
                    if v-passpdt <> ? then v-str = replace (v-str,"udovwhnvydan",string(v-passpdt,"99/99/9999")).
                    else v-str = replace (v-str,"udovwhnvydan","").
                    next.
                end.
                if v-str matches "*udovkemvydan*" then do:
                    if v-passpwho <> "" then v-str = replace (v-str,"udovkemvydan",v-passpwho).
                    else v-str = replace (v-str,"udovkemvydan","").
                    next.
                end.
                if v-str matches "*iin*" then do:
                    if v-iinbin <> "" then v-str = replace (v-str,"iin",v-iinbin).
                    else v-str = replace (v-str,"iin", "").
                    next.
                end.

                if v-str matches "*+A*" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+A",substr(trim(v-KOd),1,1)).
                    else v-str = replace (v-str,"+A", "").
                    next.
                end.
                if v-str matches "*+B**" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+B",substr(trim(v-KOd),2,1)).
                    else v-str = replace (v-str,"+B","").
                    next.
                end.
                if v-str matches "*+C*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+C",substr(trim(v-KBe),1,1)).
                    else v-str = replace (v-str,"+C","").
                    next.
                end.
                if v-str matches "*+D*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+D",substr(trim(v-KBe),2,1)).
                    else v-str = replace (v-str,"+D","").
                    next.
                end.
                if v-str matches "*+KNP*" then do:
                    if v-KNP <> "" then v-str = replace (v-str,"+KNP",trim(v-KNP)).
                    else v-str = replace (v-str,"+KNP","").
                    next.
                end.
                if lookup(g-fname,v-fname) <= 0 or v-funlog = yes then do:
                    if v-str matches "*accountfrom*" then do:
                        if v-accfrom <> "" then v-str = replace (v-str,"accountfrom",v-accfrom).
                        else v-str = replace (v-str,"accountfrom","").
                        next.
                    end.
                    if v-str matches "*crccode*" then do:
                        v-str = replace (v-str,"crccode",CAPS(crc.code)).
                        next.
                    end.
                    if v-str matches "*sumoperation*" then do:
                        if xout <> 0 then v-str = replace (v-str,"sumoperation",string(xout,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"sumoperation","").
                        next.
                    end.
                    if v-str matches "*sumoperpropis*" then do:
                        if strAmount <> "" then v-str = replace (v-str,"sumoperpropis",strAmount).
                        else v-str = replace (v-str,"sumoperpropis","").
                        next.
                    end.
                    if v-str matches "*ekvivalten*" then do:
                        if strAmountkzt <> "" then v-str = replace (v-str,"ekvivalten",strAmountkzt).
                        else v-str = replace (v-str,"ekvivalten","-").
                        next.
                    end.
                    if length(trim(v-naznplat)) < 90 then do:
                        if v-str matches "*naznplat*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"naznplat",trim(v-naznplat)).
                            else v-str = replace (v-str,"naznplat","").
                            next.
                        end.
                        if v-str matches "*extension*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"extension","").
                            else v-str = replace (v-str,"extension","").
                            next.
                        end.
                    end.
                    else do:
                        if v-str matches "*naznplat*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"naznplat",substr(trim(v-naznplat),1,90)).
                            else v-str = replace (v-str,"naznplat","").
                            next.
                        end.
                        if v-str matches "*extension*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"extension",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                            else v-str = replace (v-str,"extension","").
                            next.
                        end.
                    end.
                end.
                else do:
                    if v-str matches "*oiwjhrgonlkjdfg*" then do:
                        if v-accfrom <> "" then v-str = replace (v-str,"oiwjhrgonlkjdfg",v-accfrom).
                        else v-str = replace (v-str,"oiwjhrgonlkjdfg","").
                        next.
                    end.
                    if v-str matches "*ksjdhksdg*" then do:
                        v-str = replace (v-str,"ksjdhksdg",CAPS(crc.code)).
                        next.
                    end.
                    if v-str matches "*sjldhgslkghlkj*" then do:
                        if xout <> 0 then v-str = replace (v-str,"sjldhgslkghlkj",string(xout,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"sjldhgslkghlkj","").
                        next.
                    end.
                    if v-str matches "*sadjksdghgksdjf*" then do:
                        if strAmount <> "" then v-str = replace (v-str,"sadjksdghgksdjf",strAmount).
                        else v-str = replace (v-str,"sadjksdghgksdjf","").
                        next.
                    end.
                    if v-str matches "*wseilryowieuhojks*" then do:
                        if strAmountkzt <> "" then v-str = replace (v-str,"wseilryowieuhojks",strAmountkzt).
                        else v-str = replace (v-str,"wseilryowieuhojks","-").
                        next.
                    end.
                    if length(trim(v-naznplat)) < 90 then do:
                        if v-str matches "*akuwrouhbdlfhnl*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"akuwrouhbdlfhnl",trim(v-naznplat)).
                            else v-str = replace (v-str,"akuwrouhbdlfhnl","").
                            next.
                        end.
                        if v-str matches "*luiyehofbnskldg*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"luiyehofbnskldg"," ").
                            else v-str = replace (v-str,"luiyehofbnskldg"," ").
                            next.
                        end.
                    end.
                    else do:
                        if v-str matches "*akuwrouhbdlfhnl*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"akuwrouhbdlfhnl",substr(trim(v-naznplat),1,90)).
                            else v-str = replace (v-str,"akuwrouhbdlfhnl","").
                            next.
                        end.
                        if v-str matches "*luiyehofbnskldg*" then do:
                            if v-naznplat <> "" then v-str = replace (v-str,"luiyehofbnskldg",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                            else v-str = replace (v-str,"luiyehofbnskldg"," ").
                            next.
                        end.
                    end.
                end.
                if v-str matches "*bksnumber*" then do:
                    v-str = replace (v-str,"bksnumber",string(jh.jh)).
                    next.
                end.
                if v-str matches "*dtbks*" then do:
                    v-str = replace (v-str,"dtbks",entry(1,v-databks," ")).
                    next.
                end.
                if v-str matches "*mhbks*" then do:
                    v-str = replace (v-str,"mhbks",entry(2,v-databks," ")).
                    next.
                end.
                if v-str matches "*yrbks*" then do:
                    v-str = replace (v-str,"yrbks",entry(3,v-databks," ")).
                    next.
                end.
                if v-str matches "*timebks*" then do:
                    v-str = replace (v-str,"timebks",string(time,"HH:MM:SS")).
                    next.
                end.
                if v-glcash = yes then do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" and v-elcash <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> Рег.№ ЭК </B> &nbsp;" + v-elcash + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> ОКПО </B> &nbsp;" + v-okpo).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb)).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                if v-str matches "*binbnk*" then do:
                    if v-bnkbin <> "" then v-str = replace (v-str,"binbnk",trim(v-bnkbin)).
                    else v-str = replace (v-str,"binbnk","").
                    next.
                end.
                if v-str matches "*elcash*" then do:
                    if v-elcash <> "" and v-funlog = no then v-str = replace (v-str,"elcash",v-elcash).
                    else v-str = replace (v-str,"elcash","").
                    next.
                end.
                if v-str matches "*kassirfioname*" then do:
                    find ofc where ofc.ofc = ljl.teller no-lock no-error.
                    if ljl.teller <> "" then v-str = replace (v-str,"kassirfioname",if avail ofc then ofc.name else "").
                    else v-str = replace (v-str,"kassirfioname","").
                    next.
                end.
                if v-str matches "*rashod*" then do:
                    if xout <> 0 then v-str = replace (v-str,"rashod",string(xout, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crc).
                    else v-str = replace (v-str,"rashod","").
                    next.
                end.
                if v-obmenoper = yes then do:
                    if v-str matches "*prihod*" then do:
                        v-str = replace (v-str,"prihod",string(v-sumobmenoper, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crcobmen).
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*КУРС*" then v-str = replace (v-str,"КУРС","").
                    if v-str matches "*prihod*" then do:
                        v-str = replace (v-str,"prihod","").
                        next.
                    end.
                end.
                if v-str matches "*kursbks*" then do:
                    if v-obmenoper = yes then do:
                        if v-curs <> 0 then v-str = replace (v-str,"kursbks",v-strtmp + " " + string(v-curs, ">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"kursbks","").
                    end.
                    else do:
                        v-str = replace (v-str,"kursbks","").
                    end.
                    next.
                end.
                if v-str matches "*RNBNIN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"RNBNIN","ИИН/БИН").
                        else v-str = replace (v-str,"RNBNIN","РНН").
                    end.
                    else v-str = replace (v-str,"RNBNIN","РНН").
                    next.
                end.
                if v-str matches "*BNNRNN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"BNNRNN","БИН").
                        else v-str = replace (v-str,"BNNRNN","РНН").
                    end.
                    else v-str = replace (v-str,"BNNRNN","РНН").
                    next.
                end.
                leave.
            end.
            put stream v-out unformatted v-str skip.
        end.
        input close.
        output stream v-out close.

        if lookup(g-fname,v-fname) <= 0 or v-funlog = yes then input from value(v-iofileord2).
        else input from value(v-iofileord5).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if (g-fname = "TLCA0" or g-fname = "GJTE0" or g-fname = "FOFC") then do:
                    if v-doccontrol = yes then do:
                        find first ordsignat where ordsignat.ofc = v-idconfname no-lock no-error.
                        if avail ordsignat and ordsignat.sign = yes then do:
                            if v-str matches "*signcon*" then do:
                                v-str = replace (v-str,"signcon","<img src='c:\\\\tmp\\\\" + v-idconfname + "order.jpg' width = '85' height = '30'").
                                next.
                            end.
                        end.
                        else do:
                            if v-str matches "*signcon*" then do:
                                v-str = replace (v-str,"signcon","").
                                next.
                            end.
                        end.
                    end.
                    else do:
                        if v-str matches "*signcon*" then do:
                            v-str = replace (v-str,"signcon","").
                            next.
                        end.
                    end.
                end.
                else do:
                    if v-str matches "*signcon*" then do:
                        v-str = replace (v-str,"signcon","").
                        next.
                    end.
                end.
                leave.
            end.
            put stream v-out2 unformatted v-str skip.
        end.
        input close.
        output stream v-out2 close.

        if lookup(g-fname,v-fname) <= 0 or v-funlog = yes then do:
            if jh.sts = 6 then unix silent cptwin value(v-filemain) winword.
            else unix silent cptwin value(v-filemain) winword.
        end.

    end.

    if g-fname = trim(entry(4,v-fname)) then unix silent cptwin value(v-iofileord6) winword.

    if g-fname = trim(entry(1,v-fname)) then if v-tmplogi = no then unix silent cptwin value(v-iofileord6) winword.

end.
else do:
    {printord2.i}
end.

