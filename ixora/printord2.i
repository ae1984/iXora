/* printord2.i
 * MODULE
        Название модуля - Используется во всех модулях.
 * DESCRIPTION
        Описание - Алгоритм вывода кассовых ордеров в WORD для 15 модуля, исключая обменные операции.
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
        18.01.2012 damir    - корректировка.
        29.02.2012 damir    - внедрено Т.З. № 1281 по подписям...
        05.03.2012 damir    - в поле Получатель, Клиент отображался РНН рядом с ФИО.
        07.03.2012 damir    - убрал shared parameter s-jh, выходила ошибка...
        28.03.2012 damir    - отменил вывод подписей только в приходном ордере.
        28.03.2012 id00810  - добавила v-bankname для печати.
        30.03.2012 damir    - уменьшил высоту факсимиле.
        10.04.2012 damir    - ID сделал с маленькой буквы.
        18.04.2012 damir    - внедрено Т.З. № 1339.
        25.04.2012 damir    - не подтягивалось поле клиент.
        05.05.2012 damir    - информация о филиале тянется c sysc - <fullnamerus>, убрал v-bankname.
        10.05.2012 damir    - уменьшил размер вырезки substr назначения платежа.
        07.05.2012 damir    - вывод номера ЭК в чеке БКС.
        18.06.2012 damir    - вывод ОКПО в чеке БКС.
        22.06.2012 damir    - вывод v-passpnum,v-passpdt,v-passpwho.
        28.06.2012 damir    - перекомпиляция.
        05.07.2012 damir    - отображение номера при пополнении баланса в примечании на сумму сдачи.
        12.07.2012 damir    - добавил ClassPAR,убрал v-bankname.
        18.07.2012 damir    - мелкие корректировки.
        24.07.2012 id00810  - A_1CAS, приходник, поле Получатель (whorecei2) - данные из joudoc.benname
        11.09.2012 damir    - Переход на ИИН/БИН. Реализовано Т.З. <Изменение цветовой гаммы в приходных/расходных ордерах>.
        13.09.2012 damir    - добавил no-lock.
        02.11.2012 damir    - Изменения, связанные с изменением шаблонов по конвертации.isConvGL,v-convGL.
        07.11.2012 damir    - Внедрено Т.З. № 1365,1481,1538. Добавил все типы обозначенные в iXora.
        26.12.2012 damir    - Внедрено Т.З. 1624.
        12.02.2013 damir    - Внедрено Т.З. 1676.
        30.07.2013 damir - Внедрено Т.З. № 1494.
        30.09.2013 damir - Внедрено Т.З. № 1648.
*/
def var v-sum1 as deci.
def var v-KOd1 as char.
def var v-KBe1 as char.
def var v-KNP1 as char.
def var v-naznpl1 as char.
def var accon1 as char.
def var whorecei1 as char.
def var v-acccash1 as char.
def var v-flag1 as char.
def var v-ln1 as inte.
def var v-sum2 as deci.
def var v-KOd2 as char.
def var v-KBe2 as char.
def var v-KNP2 as char.
def var v-naznpl2 as char.
def var accon2 as char.
def var whorecei2 as char.
def var v-acccash2 as char.
def var v-flag2 as char.
def var v-ln2 as inte.
def var v-sum3 as deci.
def var v-KOd3 as char.
def var v-KBe3 as char.
def var v-KNP3 as char.
def var v-naznpl3 as char.
def var accon3 as char.
def var whorecei3 as char.
def var v-acccash3 as char.
def var v-flag3 as char.
def var v-ln3 as inte.
def var clien as char.
def var v-accon as char.
def var v-payacc as char.
def var acc as char.
def var v-suppname as char.
def var v-s as deci.
def var v-s1 as deci.
def var v-s2 as deci.
def var v-n1 as char.
def var v-n2 as char.
def var v-l1 as logi.
def var v-k1 as char.
def var v-k2 as char.
def var v-incashord3 as char.
def var v-incashord4 as char.
def var v-strA1 as char.
def var v-strAkzt1 as char.
def var v-strA2 as char.
def var v-strAkzt2 as char.
def var v-strA3 as char.
def var v-strAkzt3 as char.
def var v-incas1 as char.
def var v-incas2 as char.
def var v-incas3 as char.
def var v-outcas2 as char.
def var v-passpnum3 as char.
def var v-passpwho3 as char.
def var v-passpdt3 as date.
def var v-iinbin3 as char.
def var v-passpnum2 as char.
def var v-passpwho2 as char.
def var v-passpdt2 as date.
def var v-iinbin2 as char.
def var v-passpnum1 as char.
def var v-passpwho1 as char.
def var v-passpdt1 as date.
def var v-iinbin1 as char.

def temp-table t-jl
    field jh as inte
    field gl as inte
    field crc as inte
    field dc as char
    field dam as deci
    field cam as deci
    field kods as char
    field rem as char
    field accon as char
    field whorecei as char
    field clien as char
    field cashnumacc as char
    field flag as char
    field ln as inte
    field jdt as date
    field incas as char
    field outcas as char
    field passpnum as char
    field passpwho as char
    field passpdt as date
    field iinbin as char
    field teller as char
index idx1 is primary dc descending
                      crc ascending
index idx2 jh ascending
           gl ascending
index idx3 jh ascending
           dc ascending
           flag ascending
           crc ascending
           gl ascending.

def buffer b-t-jl for t-jl.

def temp-table t-obm no-undo
    field jh as inte
    field gl as inte
    field rem1 as char
    field rem2 as char
    field rem3 as char
    field rem4 as char
    field rem5 as char
    field crc as inte
    field dc as char
    field dam as deci
    field cam as deci
    field acc as char
    field ln as inte
    field sts as inte
    field jdt as date
    field teller as char
index idx1 rem1 ascending
           jh ascending
index idx2 rem1 ascending
           crc ascending
           jh ascending
index idx3 rem1 ascending
           crc ascending
           gl ascending
           jh ascending.

def temp-table wjl like jl.

find joudoc where joudoc.docnum eq jh.ref no-lock no-error.
if avail joudoc then find joudop where joudop.docnum = joudoc.docnum no-lock no-error.

empty temp-table t-jl.

/*ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР*/ /*СБОР ДАННЫХ*/
for each ljl where ljl.jh = jh.jh and ljl.dc = "D" and (ljl.gl = 100100 or ljl.gl = 100500 or ljl.gl = 100110) and ljl.crc <> 0 no-lock break by ljl.crc:
    if first-of(ljl.crc) then do:
        v-sum1 = 0. v-acccash1 = "". v-KOd1 = "". v-KBe1 = "". v-KNP1 = "". v-flag1 = "". v-ln1 = 0. v-incas1 = "". v-passpnum1 = "". v-passpwho1 = "". v-passpdt1 = ?. v-iinbin1 = "".
        v-sum2 = 0. v-acccash2 = "". v-KOd2 = "". v-KBe2 = "". v-KNP2 = "". v-flag2 = "". v-ln2 = 0. v-incas2 = "". v-passpnum2 = "". v-passpwho2 = "". v-passpdt2 = ?. v-iinbin2 = "".
        v-sum3 = 0. v-acccash3 = "". v-KOd3 = "". v-KBe3 = "". v-KNP3 = "". v-flag3 = "". v-ln3 = 0. v-incas3 = "". v-passpnum3 = "". v-passpwho3 = "". v-passpdt3 = ?. v-iinbin3 = "".
        for each bb-ljl where bb-ljl.jh = ljl.jh and bb-ljl.dc = "D" and (bb-ljl.gl = 100100 or bb-ljl.gl = 100500 or bb-ljl.gl = 100110) and bb-ljl.crc = ljl.crc no-lock break by bb-ljl.ln:
            v-payacc = "". acc = "". v-suppname = "". v-KOd = "". v-KBe = "". v-KNP = "". v-storn = false.
            v-storn = bb-ljl.rem[1] matches "*storn*" or bb-ljl.rem[2] matches "*storn*" or bb-ljl.rem[3] matches "*storn*" or bb-ljl.rem[4] matches "*storn*" or bb-ljl.rem[5] matches "*storn*".

            if bb-ljl.rem[1] matches "*комиссия*" then do:
                find first bb2-ljl where bb2-ljl.jh = bb-ljl.jh and if v-storn then bb2-ljl.ln = bb-ljl.ln - 1 else bb2-ljl.ln = bb-ljl.ln + 1 no-lock no-error.
                if avail bb2-ljl and bb2-ljl.dc = "C" then do:
                    if trim(string(bb2-ljl.gl)) begins "4" then do:
                        accon1 = string(bb2-ljl.gl).
                        whorecei1 = "АО «ForteBank»".
                        if avail joudoc then v-incas1 = trim(joudoc.info).
                        v-sum1 = v-sum1 + bb-ljl.dam.
                        v-naznpl1 = bb-ljl.rem[1].

                        run printGetEKNP(v-storn,bb-ljl.jh,bb-ljl.dc,bb-ljl.ln,trim(bb-ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).
                        if v-KOd + v-KBe + v-KNP <> "" then do:
                            v-KOd1 = v-KOd. v-KBe1 = v-KBe. v-KNP1 = v-KNP.
                        end.

                        run ClassPAR(ljl.jh,input-output accon1,input-output whorecei1,input-output v-naznpl1,input-output v-passpnum1,input-output v-passpwho1,input-output v-iinbin1).
                        run RecDt(input-output whorecei1,input-output v-incas1,input-output accon1,input-output v-passpnum1,input-output v-passpwho1,input-output v-passpdt1,
                        input-output v-iinbin1,input-output v-KOd,input-output v-KBe,input-output v-KNP).

                        run RecCom(input-output v-KOd1,input-output v-KBe1,input-output v-KNP1).

                        if bb-ljl.gl = 100500 then v-acccash1 = bb-ljl.acc.
                        v-flag1 = "com".
                        v-ln1 = bb-ljl.ln.
                    end.
                    else do:
                        if not bb2-ljl.rem[1] matches "*обмен валюты*" then do:
                            accon2 = bb2-ljl.acc.
                            if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS1,EK1,CS4,EK4,CS7,EK7") > 0 then do: /*g-fname = "A_1CAS"*/
                                find first aaa where aaa.aaa = bb2-ljl.acc no-lock no-error.
                                if avail aaa then do:
                                    find first cif where cif.cif = aaa.cif no-lock no-error.
                                    if avail cif then whorecei2 = trim(cif.prefix) + " " + trim(cif.name) + ", " + cif.bin.
                                end.
                                else whorecei2 = "АО «ForteBank»".
                            end.
                            else if avail joudop and (lookup(substr(trim(joudop.type),1,3),"TR1,RT1,TR2,RT2,TR3,RT3,TR4,RT4") > 0 or
                                                      lookup(substr(trim(joudop.type),1,3),"FR1,RF1,FR2,RF2,FR3,RF3,TN3,NT3,TN4,NT4,TN5,NT5,TN6,NT6") > 0) then do: /*lookup(g-fname,"A_JOU,A_DOCH") = 0*/
                                if avail joudoc then whorecei2 = trim(joudoc.benname).
                            end.
                            else if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS2,EK2,CS5,EK5,CS6,EK6,CS9,EK9") > 0 then do: /*lookup(g-fname,"A_2CAS") > 0*/
                                find first arp where arp.arp = bb2-ljl.acc no-lock no-error.
                                if avail arp then whorecei2 = "АО «ForteBank»".
                                else if avail joudoc then whorecei2 = trim(joudoc.benname).
                            end.
                            if avail joudoc then v-incas2 = trim(joudoc.info).
                            v-sum2 = v-sum2 + bb-ljl.dam.
                            v-naznpl2 = bb-ljl.rem[1].

                            run printGetEKNP(v-storn,bb-ljl.jh,bb-ljl.dc,bb-ljl.ln,trim(bb-ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).
                            if v-KOd + v-KBe + v-KNP <> "" then do:
                                v-KOd2 = v-KOd. v-KBe2 = v-KBe. v-KNP2 = v-KNP.
                            end.

                            run ClassPAR(ljl.jh,input-output accon2,input-output whorecei2,input-output v-naznpl2,input-output v-passpnum2,input-output v-passpwho2,input-output v-iinbin2).
                            run RecDt(input-output whorecei2,input-output v-incas2,input-output accon2,input-output v-passpnum2,input-output v-passpwho2,input-output v-passpdt2,
                            input-output v-iinbin2,input-output v-KOd,input-output v-KBe,input-output v-KNP).

                            if bb-ljl.gl = 100500 then v-acccash2 = bb-ljl.acc.
                            v-flag2 = "com".
                            v-ln2 = bb-ljl.ln.
                        end.
                    end.
                end.
            end.
            else do:
                find first bb2-ljl where bb2-ljl.jh = bb-ljl.jh and if v-storn then bb2-ljl.ln = bb-ljl.ln - 1 else bb2-ljl.ln = bb-ljl.ln + 1 no-lock no-error.
                if avail bb2-ljl and bb2-ljl.dc = "C" then do:
                    if trim(string(bb2-ljl.gl)) begins "4" then do:
                        accon1 = string(bb2-ljl.gl).
                        whorecei1 = "АО «ForteBank»".
                        if avail joudoc then v-incas1 = trim(joudoc.info).
                        v-sum1 = v-sum1 + bb-ljl.dam.
                        v-naznpl1 = bb-ljl.rem[1].

                        run printGetEKNP(v-storn,bb-ljl.jh,bb-ljl.dc,bb-ljl.ln,trim(bb-ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).
                        if v-KOd + v-KBe + v-KNP <> "" then do:
                            v-KOd1 = v-KOd. v-KBe1 = v-KBe. v-KNP1 = v-KNP.
                        end.

                        run ClassPAR(ljl.jh,input-output accon1,input-output whorecei1,input-output v-naznpl1,input-output v-passpnum1,input-output v-passpwho1,input-output v-iinbin1).
                        run RecDt(input-output whorecei1,input-output v-incas1,input-output accon1,input-output v-passpnum1,input-output v-passpwho1,input-output v-passpdt1,
                        input-output v-iinbin1,input-output v-KOd,input-output v-KBe,input-output v-KNP).

                        run RecCom(input-output v-KOd1,input-output v-KBe1,input-output v-KNP1).

                        if bb-ljl.gl = 100500 then v-acccash1 = bb-ljl.acc.
                        v-flag1 = "com".
                        v-ln1 = bb-ljl.ln.
                    end.
                    else do:
                        if not bb2-ljl.rem[1] matches "*обмен валюты*" then do:
                            accon3 = bb2-ljl.acc.
                            if bb-ljl.gl = 100500 and bb2-ljl.gl = 100100 then accon3 = bb-ljl.acc.
                            if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS1,EK1,CS4,EK4,CS7,EK7") > 0 then do: /*g-fname = "A_1CAS"*/
                                find first aaa where aaa.aaa = bb2-ljl.acc no-lock no-error.
                                if avail aaa then do:
                                    find first cif where cif.cif = aaa.cif no-lock no-error.
                                    if avail cif then whorecei3 = trim(cif.prefix) + " " + trim(cif.name) + ", " + cif.bin.
                                end.
                                else whorecei3 = if joudoc.benname ne "" then trim(joudoc.benname) else "АО «ForteBank»".
                            end.
                            else if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS2,EK2,CS5,EK5,CS6,EK6,CS9,EK9") > 0 then do: /*lookup(g-fname,"A_2CAS") > 0*/
                                find first arp where arp.arp = bb2-ljl.acc no-lock no-error.
                                if avail arp then whorecei3 = "АО «ForteBank»".
                                else if avail joudoc then whorecei3 = trim(joudoc.benname).
                            end.
                            else if avail joudoc then whorecei3 = trim(joudoc.benname).
                            if avail joudoc then v-incas3 = trim(joudoc.info).
                            v-sum3 = v-sum3 + bb-ljl.dam.
                            v-naznpl3 = bb-ljl.rem[1].

                            run printGetEKNP(v-storn,bb-ljl.jh,bb-ljl.dc,bb-ljl.ln,trim(bb-ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).
                            if v-KOd + v-KBe + v-KNP <> "" then do:
                                v-KOd3 = v-KOd. v-KBe3 = v-KBe. v-KNP3 = v-KNP.
                            end.

                            run ClassPAR(ljl.jh,input-output accon3,input-output whorecei3,input-output v-naznpl3,input-output v-passpnum3,input-output v-passpwho3,input-output v-iinbin3).

                            run RecDt(input-output whorecei3,input-output v-incas3,input-output accon3,input-output v-passpnum3,input-output v-passpwho3,input-output v-passpdt3,
                            input-output v-iinbin3,input-output v-KOd,input-output v-KBe,input-output v-KNP).
                            if v-KOd + v-KBe + v-KNP <> "" then do:
                                v-KOd3 = v-KOd. v-KBe3 = v-KBe. v-KNP3 = v-KNP.
                            end.

                            if bb-ljl.gl = 100500 then v-acccash3 = bb-ljl.acc.
                            v-flag3 = "base".
                            v-ln3 = bb-ljl.ln.
                        end.

                    end.
                end.

            end.
        end.
        find ofc where ofc.ofc = ljl.teller no-lock no-error.
        if v-sum1 <> 0 then do:
            create t-jl.
            t-jl.jh = ljl.jh.
            t-jl.gl = ljl.gl.
            t-jl.crc = ljl.crc.
            t-jl.dc = ljl.dc.
            t-jl.dam = v-sum1.
            t-jl.kods = v-KOd1 + "," + v-KBe1 + "," + v-KNP1.
            t-jl.rem = v-naznpl1.
            t-jl.accon = accon1.
            t-jl.whorecei = whorecei1.
            t-jl.cashnumacc = v-acccash1.
            t-jl.flag = v-flag1.
            t-jl.ln = v-ln1.
            t-jl.jdt = ljl.jdt.
            t-jl.incas = v-incas1.
            t-jl.passpnum = v-passpnum1.
            t-jl.passpwho = v-passpwho1.
            t-jl.passpdt = v-passpdt1.
            t-jl.iinbin = v-iinbin1.
            t-jl.teller = if avail ofc then ofc.name else "".
        end.
        if v-sum2 <> 0 then do:
            create t-jl.
            t-jl.jh = ljl.jh.
            t-jl.gl = ljl.gl.
            t-jl.crc = ljl.crc.
            t-jl.dc = ljl.dc.
            t-jl.dam = v-sum2.
            t-jl.kods = v-KOd2 + "," + v-KBe2 + "," + v-KNP2.
            t-jl.rem = v-naznpl2.
            t-jl.accon = accon2.
            t-jl.whorecei = whorecei2.
            t-jl.cashnumacc = v-acccash2.
            t-jl.flag = v-flag2.
            t-jl.ln = v-ln2.
            t-jl.jdt = ljl.jdt.
            t-jl.incas = v-incas2.
            t-jl.passpnum = v-passpnum2.
            t-jl.passpwho = v-passpwho2.
            t-jl.passpdt = v-passpdt2.
            t-jl.iinbin = v-iinbin2.
            t-jl.teller = if avail ofc then ofc.name else "".
        end.
        if v-sum3 <> 0 then do:
            create t-jl.
            t-jl.jh = ljl.jh.
            t-jl.gl = ljl.gl.
            t-jl.crc = ljl.crc.
            t-jl.dc = ljl.dc.
            t-jl.dam = v-sum3.
            t-jl.kods = v-KOd3 + "," + v-KBe3 + "," + v-KNP3.
            t-jl.rem = v-naznpl3.
            t-jl.accon = accon3.
            t-jl.whorecei = whorecei3.
            t-jl.cashnumacc = v-acccash3.
            t-jl.flag = v-flag3.
            t-jl.ln = v-ln3.
            t-jl.jdt = ljl.jdt.
            t-jl.incas = v-incas3.
            t-jl.passpnum = v-passpnum3.
            t-jl.passpwho = v-passpwho3.
            t-jl.passpdt = v-passpdt3.
            t-jl.iinbin = v-iinbin3.
            t-jl.teller = if avail ofc then ofc.name else "".
        end.
    end.
end.

/*РАСХОДНЫЙ КАССОВЫЙ ОРДЕР*/ /*СБОР ДАННЫХ*/
for each ljl where ljl.jh = jh.jh and ljl.dc = "C" and (ljl.gl = 100100 or ljl.gl = 100500 or ljl.gl = 100110) and ljl.crc <> 0 no-lock break by ljl.crc:
    if first-of(ljl.crc) then do:
        v-sum2 = 0. v-KOd2 = "". v-KBe2 = "". v-KNP2 = "". accon2 = "". v-outcas2 = "". v-passpnum2 = "". v-passpwho2 = "". v-passpdt2 = ?. v-iinbin2 = "".
        for each bb-ljl where bb-ljl.jh = ljl.jh and bb-ljl.dc = "C" and (bb-ljl.gl = 100100 or bb-ljl.gl = 100500 or bb-ljl.gl = 100110) and bb-ljl.crc = ljl.crc no-lock break by bb-ljl.ln:
            v-storn = false.
            v-storn = bb-ljl.rem[1] matches "*storn*" or bb-ljl.rem[2] matches "*storn*" or bb-ljl.rem[3] matches "*storn*" or bb-ljl.rem[4] matches "*storn*" or bb-ljl.rem[5] matches "*storn*".
            find first bb2-ljl where bb2-ljl.jh = bb-ljl.jh and if v-storn then bb2-ljl.ln = bb-ljl.ln + 1 else bb2-ljl.ln = bb-ljl.ln - 1 no-lock no-error.
            if avail bb2-ljl and bb2-ljl.dc = "D" then do:
                if not bb2-ljl.rem[1] matches "*обмен валюты*" then do:
                    accon2 = bb2-ljl.acc.
                    if avail joudop and (lookup(substr(trim(joudop.type),1,3),"TR1,RT1,TR2,RT2,TR3,RT3,TR4,RT4") > 0 or
                                         lookup(substr(trim(joudop.type),1,3),"FR1,RF1,FR2,RF2,FR3,RF3,TN3,NT3,TN4,NT4,TN5,NT5,TN6,NT6") > 0) then do: /*lookup(g-fname,"A_DOCH,A_JOU") > 0*/
                        if avail joudoc then clien = trim(joudoc.info).
                    end.
                    else if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS2,EK2,CS5,EK5,CS6,EK6,CS9,EK9") > 0 then do: /*lookup(g-fname,"A_2CAS") > 0*/
                        find first arp where arp.arp = bb2-ljl.acc no-lock no-error.
                        if avail arp then clien = "АО «ForteBank»".
                        else if avail joudoc then clien = trim(joudoc.benname).
                    end.
                    else do:
                        find joudop where joudop.docnum eq joudoc.docnum no-lock no-error.
                        if avail joudop and lookup(substr(trim(joudop.type),1,3),"CS9,EK9") gt 0 then clien = "".
                        else if avail joudoc then clien = trim(joudoc.benname).
                    end.
                    if avail joudoc then v-outcas2 = trim(joudoc.info).
                    v-sum2 = v-sum2 + bb-ljl.cam.
                    v-naznpl2 = bb-ljl.rem[1].

                    run printGetEKNP(v-storn,bb-ljl.jh,bb-ljl.dc,bb-ljl.ln,trim(bb-ljl.rem[1]),output v-KOd,output v-KBe,output v-KNP).
                    if v-KOd + v-KBe + v-KNP <> "" then do:
                        v-KOd2 = v-KOd. v-KBe2 = v-KBe. v-KNP2 = v-KNP.
                    end.

                    run RecCt(input-output clien,input-output v-outcas2,input-output accon2,input-output v-passpnum2,input-output v-passpwho2,input-output v-passpdt2,input-output v-iinbin2,
                    input-output v-KOd,input-output v-KBe,input-output v-KNP).
                    if v-KOd + v-KBe + v-KNP <> "" then do:
                        v-KOd2 = v-KOd. v-KBe2 = v-KBe. v-KNP2 = v-KNP.
                    end.

                    if bb-ljl.gl = 100500 then v-acccash2 = bb-ljl.acc.
                end.
            end.
        end.
        if v-sum2 <> 0 then do:
            create t-jl.
            t-jl.jh = ljl.jh.
            t-jl.gl = ljl.gl.
            t-jl.crc = ljl.crc.
            t-jl.dc = ljl.dc.
            t-jl.cam = v-sum2.
            t-jl.kods = v-KOd2 + "," + v-KBe2 + "," + v-KNP2.
            t-jl.rem = v-naznpl2.
            t-jl.accon = accon2.
            t-jl.clien = clien.
            t-jl.cashnumacc = v-acccash2.
            t-jl.jdt = ljl.jdt.
            t-jl.outcas = v-outcas2.
            t-jl.passpnum = v-passpnum2.
            t-jl.passpwho = v-passpwho2.
            t-jl.passpdt = v-passpdt2.
            t-jl.iinbin = v-iinbin2.
        end.
    end.
end.

v-ifileinput = "/data/export/incashord.htm". /*Шаблон приходных кассовых ордеров*/
v-ifileinput2 = "/data/export/incashord2.htm". /*Шаблон приходных кассовых ордеров(без контрольного чека БКС)*/
v-incashord3 = "/data/export/incashord3.htm". /*Шаблон приходных кассовых ордеров - Сумма операции + Сумма комиссии*/
v-incashord4 = "/data/export/incashord4.htm". /*Шаблон приходных кассовых ордеров - Сумма операции + Сумма комиссии (без контрольного чека БКС)*/
v-ifileoutput = "/data/export/outcashord.htm". /*Шаблон расходных кассовых ордеров*/
v-ifileoutput2 = "/data/export/outcashord2.htm". /*Шаблон расходных кассовых ордеров(без контрольного чека БКС)*/


for each t-jl where t-jl.jh = jh.jh and (t-jl.gl = 100100 or t-jl.gl = 100500 or t-jl.gl = 100110) no-lock break by t-jl.ln:
    v-KOd = "". v-KBe = "". v-KNP = "". v-accon = "". v-elcash = "". v-glcash = no. decAmount = 0. strAmount = "". strAmountkzt = "".
    v-l1 = false. v-s = 0. v-s1 = 0. v-s2 = 0. v-n1 = "". v-n2 = "". v-k1 = "". v-k2 = "". v-strA1 = "". v-strAkzt1 = "". v-strA2 = "". v-strAkzt2 = "". v-strA3 = "". v-strAkzt3 = "".

    if t-jl.dc eq "D" then do:
        if t-jl.flag = "base" then do:
            v-s = t-jl.dam.
            v-n1 = t-jl.rem.
            v-s1 = t-jl.dam.
            v-k1 = t-jl.kods.
            find first b-t-jl where b-t-jl.jh = t-jl.jh and b-t-jl.dc = "D" and b-t-jl.flag = "com" and b-t-jl.crc = t-jl.crc and (b-t-jl.gl = 100100 or b-t-jl.gl = 100500) exclusive-lock no-error.
            if avail b-t-jl then do:
                v-l1 = true.
                v-s = v-s + b-t-jl.dam.
                v-n2 = b-t-jl.rem.
                v-s2 = b-t-jl.dam.
                v-k2 = b-t-jl.kods.
                delete b-t-jl.
            end.
        end.
    end.
    if v-l1 then do:
        decAmount = v-s.
        run SWords(decAmount,t-jl.crc,t-jl.jdt,input-output v-strA1,input-output v-strAkzt1).
        decAmount = v-s1.
        run SWords(decAmount,t-jl.crc,t-jl.jdt,input-output v-strA2,input-output v-strAkzt2).
        decAmount = v-s2.
        run SWords(decAmount,t-jl.crc,t-jl.jdt,input-output v-strA3,input-output v-strAkzt3).
    end.

    run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz). /* День месяц(прописью) год */
    run pkdefdtstr(string(dtreg,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */
    if num-entries(t-jl.kods) = 3 then do:
        v-KOd = entry(1,t-jl.kods).
        v-KBe = entry(2,t-jl.kods).
        v-KNP = entry(3,t-jl.kods).
    end.
    if t-jl.gl = 100500 and t-jl.cashnumacc <> "" then do:
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.acc = t-jl.cashnumacc and sub-cod.d-cod = "arptype" and sub-cod.ccode <> "msc" no-lock no-error.
        if avail sub-cod then v-elcash = sub-cod.ccode.
        v-glcash = yes.
    end.
    find first crc where crc.crc = t-jl.crc no-lock no-error.

    /*-------------------------------Вывод суммы прописью---------------------------------------*/
    if t-jl.dc eq "D" then decAmount = t-jl.dam.
    if t-jl.dc eq "C" then decAmount = t-jl.cam.

    run SWords(decAmount,t-jl.crc,t-jl.jdt,input-output strAmount,input-output strAmountkzt).

    /*-----------------------------------------------------------------------------------------------*/
    if jh.sts = 6 then do:
        if t-jl.dc eq "D" then do:
            if not v-l1 then input from value(v-ifileinput).
            else do: input from value(v-incashord3). end.
        end.
        if t-jl.dc eq "C" then input from value(v-ifileoutput).
    end.
    else do:
        if t-jl.dc eq "D" then do:
            if not v-l1 then input from value(v-ifileinput2).
            else do: input from value(v-incashord4). end.
        end.
        if t-jl.dc eq "C" then input from value(v-ifileoutput2).
    end.

    output stream v-out to value(v-filemain).
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
            if v-str matches "*jheader*" then do:
                v-str = replace (v-str,"jheader",string(jh.jh)).
                next.
            end.
            if v-str matches "*joudocnum*" then do:
                if jh.ref <> "" then v-str = replace (v-str,"joudocnum",if avail joudoc then jh.ref else "").
                else v-str = replace (v-str,"joudocnum","").
                next.
            end.
            if v-str matches "*udostoverenie*" then do:
                if t-jl.passpnum <> "" then v-str = replace (v-str,"udostoverenie",t-jl.passpnum).
                else v-str = replace (v-str,"udostoverenie","").
                next.
            end.
            if v-str matches "*udovwhnvydan*" then do:
                if t-jl.passpdt <> ? then v-str = replace (v-str,"udovwhnvydan",string(t-jl.passpdt,"99/99/9999")).
                else v-str = replace (v-str,"udovwhnvydan","").
                next.
            end.
            if v-str matches "*udovkemvydan*" then do:
                if t-jl.passpwho <> "" then v-str = replace (v-str,"udovkemvydan",t-jl.passpwho).
                else v-str = replace (v-str,"udovkemvydan","").
                next.
            end.
            if v-str matches "*iin*" then do:
                if t-jl.iinbin <> "" then v-str = replace (v-str,"iin",t-jl.iinbin).
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
            if length(trim(t-jl.rem)) < 90 then do:
                if v-str matches "*naznplat*" then do:
                    if t-jl.rem <> "" then v-str = replace (v-str,"naznplat",trim(t-jl.rem)).
                    else v-str = replace (v-str,"naznplat","").
                    next.
                end.
                if v-str matches "*extension*" then do:
                    if t-jl.rem <> "" then v-str = replace (v-str,"extension","").
                    else v-str = replace (v-str,"extension","").
                    next.
                end.
            end.
            else do:
                if v-str matches "*naznplat*" then do:
                    if t-jl.rem <> "" then v-str = replace (v-str,"naznplat",substr(trim(t-jl.rem),1,90)).
                    else v-str = replace (v-str,"naznplat","").
                    next.
                end.
                if v-str matches "*extension*" then do:
                    if t-jl.rem <> "" then v-str = replace (v-str,"extension",trim(substr(trim(t-jl.rem),91,length(trim(t-jl.rem))))).
                    else v-str = replace (v-str,"extension","").
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
            if v-str matches "*elcash*" then do:
                if v-elcash <> "" then v-str = replace (v-str,"elcash",v-elcash).
                else v-str = replace (v-str,"elcash","").
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
            if v-str matches "*kassirfioname*" then do:
                if t-jl.teller <> "" then v-str = replace (v-str,"kassirfioname",t-jl.teller).
                else v-str = replace (v-str,"kassirfioname","").
                next.
            end.
            if v-str matches "*КУРС*" then do:
                v-str = replace (v-str,"КУРС","").
            end.
            if v-str matches "*kursbks*" then do:
                v-str = replace (v-str,"kursbks","").
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
            if t-jl.dc eq "D" then do:
                if v-str matches "*account*" then do:
                    if t-jl.accon <> "" then v-str = replace (v-str,"account",t-jl.accon).
                    else v-str = replace (v-str,"account","").
                    next.
                end.
                if v-str matches "*whoreceive*" then do:
                    if t-jl.whorecei <> "" then v-str = replace (v-str,"whoreceive",trim(t-jl.whorecei)).
                    else v-str = replace (v-str,"whoreceive","").
                    next.
                end.
                if v-str matches "*receivefrom*" then do:
                    if t-jl.incas <> "" then v-str = replace (v-str,"receivefrom",t-jl.incas).
                    else v-str = replace (v-str,"receivefrom","").
                    next.
                end.
                if v-str matches "*sumoperation*" then do:
                    if t-jl.dam <> 0 then v-str = replace (v-str,"sumoperation",string(t-jl.dam,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sumoperation","").
                    next.
                end.
                if v-str matches "*prihod*" then do:
                    if t-jl.dam <> 0 then v-str = replace (v-str,"prihod",string(t-jl.dam, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + crc.code).
                    else v-str = replace (v-str,"prihod","").
                    next.
                end.
                if v-str matches "*rashod*" then do:
                    v-str = replace (v-str,"rashod","").
                    next.
                end.
                if v-str matches "*lksjdgoiuerhg*" then do:
                    if v-s <> 0 then v-str = replace (v-str,"lksjdgoiuerhg",string(v-s,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"lksjdgoiuerhg","").
                    next.
                end.
                if v-str matches "*lksjdfoiwgbosidg*" then do:
                    if v-strAkzt1 <> "" then v-str = replace (v-str,"lksjdfoiwgbosidg",v-strAkzt1).
                    else v-str = replace (v-str,"lksjdfoiwgbosidg","").
                    next.
                end.
                if v-str matches "*klasjfowiuehfosidjghjh*" then do:
                    if v-n1 <> "" then v-str = replace (v-str,"klasjfowiuehfosidjghjh",v-n1).
                    else v-str = replace (v-str,"klasjfowiuehfosidjghjh","").
                    next.
                end.
                if v-str matches "*oiquwpoihakjsfkhgvbhbeisdh*" then do:
                    if v-n2 <> "" then v-str = replace (v-str,"oiquwpoihakjsfkhgvbhbeisdh",v-n2).
                    else v-str = replace (v-str,"oiquwpoihakjsfkhgvbhbeisdh","").
                    next.
                end.
                if v-str matches "*qwgr*" then do:
                    v-str = replace (v-str,"qwgr",crc.code).
                    next.
                end.
                if v-str matches "*mkvrfiuhrtgb*" then do:
                    if v-s1 <> 0 then v-str = replace (v-str,"mkvrfiuhrtgb",string(v-s1,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"mkvrfiuhrtgb","").
                    next.
                end.
                if v-str matches "*wtyedcvdg*" then do:
                    if v-s2 <> 0 then v-str = replace (v-str,"wtyedcvdg",string(v-s2,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"wtyedcvdg","").
                    next.
                end.
                if v-str matches "*zcafsgwteu*" then do:
                    if v-strA2 <> "" then v-str = replace (v-str,"zcafsgwteu",v-strA2).
                    else v-str = replace (v-str,"zcafsgwteu","").
                    next.
                end.
                if v-str matches "*lgprkgjyhtow*" then do:
                    if v-strA3 <> "" then v-str = replace (v-str,"lgprkgjyhtow",v-strA3).
                    else v-str = replace (v-str,"lgprkgjyhtow","").
                    next.
                end.
                if v-str matches "*+P*" then do:
                    if v-k1 <> "" then v-str = replace (v-str,"+P",entry(1,v-k1)).
                    else v-str = replace (v-str,"+P","").
                    next.
                end.
                if v-str matches "*+O*" then do:
                    if v-k1 <> "" then v-str = replace (v-str,"+O",entry(2,v-k1)).
                    else v-str = replace (v-str,"+O","").
                    next.
                end.
                if v-str matches "*+U*" then do:
                    if v-k1 <> "" then v-str = replace (v-str,"+U",entry(3,v-k1)).
                    else v-str = replace (v-str,"+U","").
                    next.
                end.
                if v-str matches "*+Y*" then do:
                    if v-k2 <> "" then v-str = replace (v-str,"+Y",entry(1,v-k2)).
                    else v-str = replace (v-str,"+Y","").
                    next.
                end.
                if v-str matches "*+T*" then do:
                    if v-k2 <> "" then v-str = replace (v-str,"+T",entry(2,v-k2)).
                    else v-str = replace (v-str,"+T","").
                    next.
                end.
                if v-str matches "*+R*" then do:
                    if v-k2 <> "" then v-str = replace (v-str,"+R",entry(3,v-k2)).
                    else v-str = replace (v-str,"+R","").
                    next.
                end.
                if v-str matches "*hdfuhsbudvgukjh*" then do:
                    if v-s <> 0 then v-str = replace (v-str,"hdfuhsbudvgukjh",string(v-s,">>>,>>>,>>>,>>>,>>>,>>9.99") + "&nbsp;&nbsp;" + crc.code).
                    else v-str = replace (v-str,"hdfuhsbudvgukjh","").
                    next.
                end.
            end.
            else do:
                if v-str matches "*accountfrom*" then do:
                    if t-jl.accon <> "" then v-str = replace (v-str,"accountfrom",t-jl.accon).
                    else v-str = replace (v-str,"accountfrom","").
                    next.
                end.
                if v-str matches "*nmclpoiuwyet*" then do:
                    if t-jl.clien <> "" then v-str = replace (v-str,"nmclpoiuwyet",trim(t-jl.clien)).
                    else v-str = replace (v-str,"nmclpoiuwyet","").
                    next.
                end.
                if v-str matches "*receivewho*" then do:
                    if t-jl.outcas <> "" then v-str = replace (v-str,"receivewho",t-jl.outcas).
                    else v-str = replace (v-str,"receivewho","").
                    next.
                end.
                if v-str matches "*sumoperation*" then do:
                    if t-jl.cam <> 0 then v-str = replace (v-str,"sumoperation",string(t-jl.cam,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sumoperation","").
                    next.
                end.
                if v-str matches "*prihod*" then do:
                    v-str = replace (v-str,"prihod","").
                    next.
                end.
                if v-str matches "*rashod*" then do:
                    if t-jl.cam <> 0 then v-str = replace (v-str,"rashod",string(t-jl.cam, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + crc.code).
                    else v-str = replace (v-str,"rashod","").
                    next.
                end.
            end.

            if v-doccontrol then do:
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
            leave.
        end.
        put stream v-out unformatted v-str skip.
    end.
    input close.
    output stream v-out close.

    if jh.sts = 6 then do:
        if t-jl.dc eq "D" then unix silent cptwin value(v-filemain) winword.
        if t-jl.dc eq "C" then unix silent cptwin value(v-filemain) winword.
    end.
    else do:
        if t-jl.dc eq "D" then unix silent cptwin value(v-filemain) winword.
        if t-jl.dc eq "C" then unix silent cptwin value(v-filemain) winword.
    end.
end.

/***************************************************************ОБМЕННЫЕ ОПЕРАЦИИ**************************************************************************/
run ExcOper.

PROCEDURE ExcOper:

    def buffer b-t-obm for t-obm.
    def buffer b2-t-obm for t-obm.
    def buffer b-wjl for wjl.
    def buffer b2-wjl for wjl.

    empty temp-table t-obm.
    for each ljl no-lock:
        create t-obm.
        BUFFER-COPY ljl TO t-obm NO-ERROR.
        t-obm.rem1 = ljl.rem[1].
        t-obm.rem2 = ljl.rem[2].
        t-obm.rem3 = ljl.rem[3].
        t-obm.rem4 = ljl.rem[4].
        t-obm.rem5 = ljl.rem[5].
    end.

    empty temp-table wjl.
    for each t-obm where t-obm.jh = jh.jh and t-obm.rem1 matches "*обмен валюты*" no-lock break by t-obm.crc:
        if first-of(t-obm.crc) then do:
            for each b-t-obm where b-t-obm.jh = t-obm.jh and b-t-obm.crc = t-obm.crc and b-t-obm.rem1 matches "*обмен валюты*" break by b-t-obm.gl:
                if first-of(b-t-obm.gl) then do:
                    v-consumd = 0. v-consumc = 0.
                    for each b2-t-obm where b2-t-obm.jh = b-t-obm.jh and b2-t-obm.gl = b-t-obm.gl and b2-t-obm.crc = t-obm.crc and b2-t-obm.rem1 matches "*обмен валюты*" no-lock
                    break by b2-t-obm.ln:
                        if b2-t-obm.dc = "D" then v-consumd = v-consumd + b2-t-obm.dam.
                        else v-consumc = v-consumc + b2-t-obm.cam.
                    end.
                    find ofc where ofc.ofc = b-t-obm.teller no-lock no-error.
                    create wjl.
                    wjl.jh = t-obm.jh.
                    wjl.gl = b-t-obm.gl.
                    wjl.rem[1] = b-t-obm.rem1.
                    wjl.rem[2] = b-t-obm.rem2.
                    wjl.rem[3] = b-t-obm.rem3.
                    wjl.rem[4] = b-t-obm.rem4.
                    wjl.rem[5] = b-t-obm.rem5.
                    wjl.dc = b-t-obm.dc.
                    wjl.dam = v-consumd.
                    wjl.cam = v-consumc.
                    wjl.acc = b-t-obm.acc.
                    wjl.crc = b-t-obm.crc.
                    wjl.ln = b-t-obm.ln.
                    wjl.sts = b-t-obm.sts.
                    wjl.jdt = b-t-obm.jdt.
                    wjl.teller = if avail ofc then ofc.name else "".
                end.
            end.
        end.
    end.

    for each wjl where wjl.jh = jh.jh and wjl.dc = "D" and (wjl.gl = 100100 or wjl.gl = 100500) and wjl.crc <> 0 no-lock break by wjl.ln:

        v-ifileobmenop  = "/data/export/inoutcashordobmen.htm".  /*Шаблон - обменные операции*/ /*С БКС*/
        v-ifileobmenop2 = "/data/export/inoutcashordobmen2.htm". /*Шаблон - обменные операции*/ /*БЕЗ БКС*/

        xin = 0. xout = 0. v-KOd = "". v-KBe = "". v-KNP = "". v-crc = "". v-crc2 = "". v-obmenoper = no. v-onacc = "". v-accfrom = "".
        v-crcobmen = "". v-crccod = 0. v-crccod2 = 0. decAmountT = 0. decAmountT2 = 0. strAmountkzt = "". strAmountkzt2 = "". decAmount = 0.
        decAmount2 = 0. v-glcash = no. v-elcash = "".

        xin = wjl.dam.
        v-onacc = string(wjl.gl).
        find first crc where crc.crc = wjl.crc no-lock no-error.
        if avail crc then do:
            v-crc = crc.code.
            v-crccod = crc.crc.
        end.
        find first b-wjl where b-wjl.jh = wjl.jh and b-wjl.ln = wjl.ln + 1 no-lock no-error.
        if avail b-wjl and b-wjl.dc = "C" then do:
            if isConvGL(b-wjl.gl) then do:
                v-obmenoper = yes.
                if b-wjl.crc = 1 then v-strtmp = "ПРОДАЖИ".
                else v-strtmp = "ПОКУПКИ".
                find first b2-wjl where b2-wjl.jh = wjl.jh and b2-wjl.ln = wjl.ln + 3 no-lock no-error.
                if avail b2-wjl and b2-wjl.dc = "C" then do:
                    xout = b2-wjl.cam.
                    v-accfrom = string(b2-wjl.gl).
                    v-sumobmenoper = b2-wjl.cam.
                    find first crc where crc.crc = b2-wjl.crc no-lock no-error.
                    if avail crc then do:
                        v-crc2 = crc.code.
                        v-crccod2 = crc.crc.
                    end.
                end.
            end.
        end.
        if wjl.crc <> 1 then v-crcobmen = "KZT".
        else v-crcobmen = v-crcobm.

        if wjl.gl = 100500 and wjl.acc <> "" then do:
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.acc = wjl.acc and sub-cod.d-cod = "arptype" and sub-cod.ccode <> "msc" no-lock no-error.
            if avail sub-cod then v-elcash = sub-cod.ccode.

            v-glcash = yes.
        end.

        run CODSOBM(wjl.dc,wjl.ln).

        run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz). /* День месяц(прописью) год */
        run pkdefdtstr(string(dtreg,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */

        /*-------------------------------Вывод суммы прописью---------------------------------------*/
        decAmount = xin.
        run SWords(decAmount,v-crccod,wjl.jdt,input-output strAmount,input-output strAmountkzt).

        decAmount = xout.
        run SWords(decAmount,v-crccod2,wjl.jdt,input-output strAmount2,input-output strAmountkzt2).
        /*-----------------------------------------------------------------------------------------------*/
        v-whorecei  = "-".
        v-incas     = "-".
        v-clien     = "-".
        v-outcas    = "-".
        v-passpnum  = "-".
        v-passpdt   = ?.
        v-passpwho  = "-".
        v-iinbin    = "-".

        if wjl.rem[1] <> "" then v-naznplat = wjl.rem[1].
        else if wjl.rem[2] <> "" then v-naznplat = wjl.rem[2].
        else if wjl.rem[3] <> "" then v-naznplat = wjl.rem[3].
        else if wjl.rem[4] <> "" then v-naznplat = wjl.rem[4].
        else if wjl.rem[5] <> "" then v-naznplat = wjl.rem[5].

        if jh.sts = 6 then do:
            output stream v-out to value(v-iofileord3).
            input from value(v-ifileobmenop).
        end.
        else do:
            output stream v-out to value(v-iofileord3).
            input from value(v-ifileobmenop2).
        end.
        output stream v-out2 to value(v-iofileord4).
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
                    if jh.ref <> "" then v-str = replace (v-str,"joudocnum",if avail joudoc then jh.ref else "").
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
                if v-str matches "*oiwjhrgonlkjdfg*" then do:
                    if v-accfrom <> "" then v-str = replace (v-str,"oiwjhrgonlkjdfg",v-accfrom).
                    else v-str = replace (v-str,"oiwjhrgonlkjdfg","").
                    next.
                end.
                if v-str matches "*crccode*" then do:
                    if v-crc <> "" then v-str = replace (v-str,"crccode",trim(v-crc)).
                    else v-str = replace (v-str,"crccode","").
                    next.
                end.
                if v-str matches "*ksjdhksdg*" then do:
                    if v-crc2 <> "" then v-str = replace (v-str,"ksjdhksdg",trim(v-crc2)).
                    else v-str = replace (v-str,"ksjdhksdg","").
                    next.
                end.
                if v-str matches "*sjldhgslkghlkj*" then do:
                    if xout <> 0 then v-str = replace (v-str,"sjldhgslkghlkj",string(xout,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sjldhgslkghlkj","").
                    next.
                end.
                if v-str matches "*sadjksdghgksdjf*" then do:
                    if strAmount2 <> "" then v-str = replace (v-str,"sadjksdghgksdjf",strAmount2).
                    else v-str = replace (v-str,"sadjksdghgksdjf","").
                    next.
                end.
                if v-str matches "*wseilryowieuhojks*" then do:
                    if strAmountkzt2 <> "" then v-str = replace (v-str,"wseilryowieuhojks",strAmountkzt2).
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
                    if wjl.teller <> "" then v-str = replace (v-str,"kassirfioname",wjl.teller).
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

        input from value(v-iofileord3).

        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-doccontrol = yes then do:
                    find first ordsignat where ordsignat.ofc = v-idconfname no-lock no-error.
                    if avail ordsignat and ordsignat.sign = yes then do:
                        if v-str matches "*signcon*" then do:
                            v-str = replace (v-str,"signcon","<img src='c:\\\\tmp\\\\" + v-idconfname + "order.jpg' width = '85'
                            height = '30'").
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
                leave.
            end.
            put stream v-out2 unformatted v-str skip.
        end.
        input close.
        output stream v-out2 close.

        unix silent cptwin value(v-iofileord4) winword.

    end.
    /***************************************************************ОБМЕННЫЕ ОПЕРАЦИИ**************************************************************************/

end PROCEDURE.

PROCEDURE CODSOBM:
    def input parameter dc as char.
    def input parameter ln as inte.

    ln1 = 0. ln2 = 0. v-gl1 = 0. v-gl2 = 0. v-KOd = "". v-KBe = "". v-KNP = "".
    if dc = "D" then do:
        ln1 = ln.
        ln2 = ln + 1.
    end.
    if ln1 <> 0 and ln2 <> 0 then do:
        v-lnstr = string(ln1) + "," + string(ln2).
        v-dcstr = "D,C".
        do j = 1 to 2:
            KOd = "". KBe = "". KNP = "".
            run GetEKNP(jh.jh,inte(entry(j,v-lnstr)),entry(j,v-dcstr),input-output KOd,input-output KBe,input-output KNP).
            if KOd <> "" then v-KOd = KOd.
            if KBe <> "" then v-KBe = KBe.
            if KNP <> "" then v-KNP = KNP.
        end.
    end.
end PROCEDURE.

PROCEDURE SWords:
    def input parameter decAmount as deci.
    def input parameter crc as inte.
    def input parameter dt as date.
    def input-output parameter strAmount as char.
    def input-output parameter strAmountkzt as char.

    def buffer b-crcpro for crcpro.

    def var temp as char.
    def var decAmountT as deci.

    temp = string(decAmount).
    if num-entries(temp,".") = 2 then do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
    end.
    else temp = "00".
    strTemp = string(truncate(decAmount,0)).
    run Sm-vrd(input decAmount, output strAmount).
    run sm-wrdcrc(input strTemp,input temp,input crc,output str1,output str2).
    strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

    strAmountkzt = "".
    if crc <> 1 then do:
        find last b-crcpro where b-crcpro.crc = crc and b-crcpro.regdt <= dt no-lock no-error.
        if avail b-crcpro then decAmountT = decAmount * b-crcpro.rate[1].
        temp = string (round(decAmountT,2)).
        if num-entries(temp,".") = 2 then do:
            temp = substring(temp, length(temp) - 1, 2).
            if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".
        strTemp = string(truncate(decAmountT,0)).
        run Sm-vrd(input decAmountT, output strAmountkzt).
        run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
        strAmountkzt = "(" + strAmountkzt + " " + str1 + " " + temp + " " + str2 + ")".
    end.
    else strAmountkzt = "-".
end PROCEDURE.

PROCEDURE ClassPAR:
    def input  parameter jh as inte.
    def input-output parameter onacc as char.
    def input-output parameter whorecei as char.
    def input-output parameter nazp as char.
    def input-output parameter passpnum as char.
    def input-output parameter passpwho as char.
    def input-output parameter iinbin as char.

    if Doc:FindDocJH(string(jh)) then do:
        onacc = Doc:arp.
        whorecei = Doc:suppname.
        nazp = nazp + " ( " + Doc:payacc + " ) ".
        passpnum = "-".
        passpwho = "-".
        iinbin = "-".
    end.
end PROCEDURE.

procedure RecCom:
    def input-output parameter KOd as char.
    def input-output parameter KBe as char.
    def input-output parameter KNP as char.

    if jh.ref begins "MXP" then do:
        find first translat where translat.jh = jh.jh no-lock no-error.
        if avail translat then do:
            find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                KOd = substr(sub-cod.rcode,1,2).
                KBe = "14".
                KNP = "840".
            end.
        end.
        else do:
            find first r-translat where r-translat.jh = jh.jh no-lock no-error.
            if avail r-translat then do:
                find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = r-translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    KOd = substr(sub-cod.rcode,1,2).
                    KBe = "14".
                    KNP = "840".
                end.
            end.
        end.
    end.
end procedure.

PROCEDURE RecDt:
    def input-output parameter whorecei as char.
    def input-output parameter incas as char.
    def input-output parameter accon as char.

    def input-output parameter v-passpnum as char.
    def input-output parameter v-passpwho as char.
    def input-output parameter v-passpdt as date.
    def input-output parameter v-iinbin as char.

    def input-output parameter KOd as char.
    def input-output parameter KBe as char.
    def input-output parameter KNP as char.

    def var v-rnnbin as char.
    find first aaa where aaa.aaa = bb2-ljl.acc no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            if v-bin then do:
                if dtreg >= v-bin_rnn_dt then v-rnnbin = trim(cif.bin).
                else v-rnnbin = trim(cif.jss).
            end.
            else v-rnnbin = trim(cif.jss).
            whorecei = trim(cif.prefix) + " " + trim(cif.name) + ", " + trim(v-rnnbin).
        end.
    end.
    if jh.ref begins "JOU" then do:
        find joudoc where joudoc.docnum = jh.ref no-lock no-error.
        if avail joudoc then do:
            if joudoc.passp ne "" then do:
                if index(trim(joudoc.passp),",") > 0 then do:
                    v-passpnum = trim(substr(trim(joudoc.passp),1,index(trim(joudoc.passp),",") - 1)).
                    v-passpwho = trim(substr(trim(joudoc.passp),index(trim(joudoc.passp),",") + 1,length(trim(joudoc.passp)))).
                end.
                if joudoc.passpdt ne ? then v-passpdt = joudoc.passpdt.
            end.
            if joudoc.kfmcif ne "" then do:
                find first comm.cifmin where comm.cifmin.cifmin = joudoc.kfmcif no-lock no-error.
                if avail comm.cifmin then do:
                    v-passpnum = trim(comm.cifmin.docnum).
                    v-passpdt = comm.cifmin.docdt.
                    v-passpwho = trim(comm.cifmin.docwho).
                end.

                find filpayment where filpayment.jh = joudoc.jh and filpayment.jou = joudoc.docnum and filpayment.cif = joudoc.kfmcif no-lock no-error.
                if avail filpayment then do:
                    accon = filpayment.iik.
                    whorecei = filpayment.name.
                    find comm.txb where comm.txb.bank = filpayment.bankto no-lock no-error.
                    if avail comm.txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                        run printtxb(filpayment.cif,output v-outprefix).
                        if connected ("txb") then disconnect "txb".
                    end.
                    whorecei = v-outprefix + " " + whorecei + ", " + filpayment.rnnto.
                end.
            end.
            if joudoc.perkod <> "000000000000" and joudoc.perkod <> "" then v-iinbin = joudoc.perkod.
        end.
    end.
    if jh.ref begins "MXP" then do:
        find first translat where translat.jh = jh.jh no-lock no-error.
        if avail translat then do:
            incas = translat.fam + " " + translat.name + " " + translat.otch.
            whorecei = translat.rec-name + " " + translat.rec-fam + " " + translat.rec-otch.

            v-iinbin = translat.rnn.
            v-passpnum = trim(translat.nom-doc).
            v-passpdt = translat.dt-doc.
            v-passpwho = substr(trim(translat.vid-doc),1,37).

            find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                KOd = substr(sub-cod.rcode,1,2).
                KBe = substr(sub-cod.rcode,4,2).
                KNP = substr(sub-cod.rcode,7,3).
            end.
        end.
        else do:
            find first r-translat where r-translat.jh = jh.jh no-lock no-error.
            if avail r-translat then do:
                incas = r-translat.fam + " " + r-translat.name + " " + r-translat.otch.
                whorecei = r-translat.rec-name + " " + r-translat.rec-fam + " " + r-translat.rec-otch.

                v-iinbin = r-translat.acc.
                v-passpnum = trim(r-translat.nom-doc).
                v-passpdt = r-translat.dt-doc.
                v-passpwho = substr(trim(r-translat.vid-doc),1,37).

                find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = r-translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    KOd = substr(sub-cod.rcode,1,2).
                    KBe = substr(sub-cod.rcode,4,2).
                    KNP = substr(sub-cod.rcode,7,3).
                end.
            end.
        end.
    end.
end PROCEDURE.

PROCEDURE RecCt:
    def input-output parameter clien as char.
    def input-output parameter outcas as char.
    def input-output parameter accon as char.

    def input-output parameter v-passpnum as char.
    def input-output parameter v-passpwho as char.
    def input-output parameter v-passpdt as date.
    def input-output parameter v-iinbin as char.

    def input-output parameter KOd as char.
    def input-output parameter KBe as char.
    def input-output parameter KNP as char.

    def var v-rnnbin as char.
    find first aaa where aaa.aaa = bb2-ljl.acc no-lock no-error.
    if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            if v-bin then do:
                if dtreg >= v-bin_rnn_dt then v-rnnbin = trim(cif.bin).
                else v-rnnbin = trim(cif.jss).
            end.
            else v-rnnbin = trim(cif.jss).
            clien = trim(cif.prefix) + " " + trim(cif.name) + ", " + trim(v-rnnbin).
        end.
    end.
    if jh.ref begins "JOU" then do:
        find joudoc where joudoc.docnum = jh.ref no-lock no-error.
        if avail joudoc then do:
            if joudoc.passp <> "" then do:
                if index(trim(joudoc.passp),",") > 0 then do:
                    v-passpnum = trim(substr(trim(joudoc.passp),1,index(trim(joudoc.passp),",") - 1)).
                    v-passpwho = trim(substr(trim(joudoc.passp),index(trim(joudoc.passp),",") + 1,length(trim(joudoc.passp)))).
                end.
                if joudoc.passpdt ne ? then v-passpdt = joudoc.passpdt.
            end.
            if joudoc.kfmcif ne "" then do:
                find first comm.cifmin where comm.cifmin.cifmin = joudoc.kfmcif no-lock no-error.
                if avail comm.cifmin then do:
                    v-passpnum = trim(comm.cifmin.docnum).
                    v-passpdt = comm.cifmin.docdt.
                    v-passpwho = trim(comm.cifmin.docwho).
                end.
                find filpayment where filpayment.jh = joudoc.jh and filpayment.jou = joudoc.docnum and filpayment.cif = joudoc.kfmcif no-lock no-error.
                if avail filpayment then do:
                    accon = filpayment.iik.
                    clien = filpayment.name.
                    find comm.txb where comm.txb.bank = filpayment.bankto no-lock no-error.
                    if avail comm.txb then do:
                        if connected ("txb") then disconnect "txb".
                        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                        run printtxb(filpayment.cif,output v-outprefix).
                        if connected ("txb") then disconnect "txb".
                    end.
                    clien = v-outprefix + " " + clien + ", " + filpayment.rnnto.
                end.
            end.
            if joudoc.perkod <> "000000000000" and joudoc.perkod <> "" then v-iinbin = joudoc.perkod.
        end.
    end.
    if jh.ref begins "MXP" then do:
        find first translat where translat.jh = jh.jh no-lock no-error.
        if avail translat then do:
            clien = translat.rec-fam + " " + translat.rec-name + " " + translat.rec-otch.
            outcas = translat.rec-fam + " " + translat.rec-name + " " + translat.rec-otch.

            v-iinbin = translat.rnn.
            v-passpnum = trim(translat.nom-doc).
            v-passpdt = translat.dt-doc.
            v-passpwho = substr(trim(translat.vid-doc),1,37).

            find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                KOd = substr(sub-cod.rcode,1,2).
                KBe = substr(sub-cod.rcode,4,2).
                KNP = substr(sub-cod.rcode,7,3).
            end.
        end.
        else do:
            find first r-translat where r-translat.jh = jh.jh no-lock no-error.
            if avail r-translat then do:
                clien = r-translat.rec-fam + " " + r-translat.rec-name + " " + r-translat.rec-otch.
                outcas = r-translat.rec-fam + " " + r-translat.rec-name + " " + r-translat.rec-otch.

                v-iinbin = r-translat.acc.
                v-passpnum = trim(r-translat.rec-nom-doc).
                v-passpdt = r-translat.rec-dt-doc.
                v-passpwho = substr(trim(r-translat.rec-vid-doc),1,37).

                find first sub-cod where sub-cod.sub = "trl" and sub-cod.acc = r-translat.nomer and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    KOd = substr(sub-cod.rcode,1,2).
                    KBe = substr(sub-cod.rcode,4,2).
                    KNP = substr(sub-cod.rcode,7,3).
                end.
            end.
        end.
    end.
end PROCEDURE.

PROCEDURE printGetEKNP:
    def input parameter storn as logi.
    def input parameter jh as inte.
    def input parameter dc as char.
    def input parameter ln as inte.
    def input parameter rem as char.
    def output parameter KOd as char.
    def output parameter KBe as char.
    def output parameter KNP as char.

    def var ln1 as inte.
    def var ln2 as inte.

    ln1 = 0. ln2 = 0.
    if dc = "D" then do:
        if not storn then do: ln1 = ln. ln2 = ln + 1. end.
        else do: ln1 = ln. ln2 = ln - 1. end.
    end.
    else do:
        if not storn then do:
            if rem matches "*обмен валюты*" then do: ln1 = ln - 3. ln2 = ln - 2. end.
            else do: ln1 = ln - 1. ln2 = ln. end.
        end.
        else do: ln1 = ln. ln2 = ln + 1. end.
    end.
    KOd = "". KBe = "". KNP = "".
    run GetEKNPCASH(storn,jh,ln1,ln2,input-output KOd,input-output KBe,input-output KNP).
end PROCEDURE.

PROCEDURE GetEKNPCASH:
    def input parameter storn as logi.
    def input parameter jh as inte.
    def input parameter ln1 as inte.
    def input parameter ln2 as inte.
    def input-output parameter p-KOd as char.
    def input-output parameter p-KBe as char.
    def input-output parameter p-KNP as char.

    def buffer b-jl for jl.

    def var KOd as char.
    def var KBe as char.
    def var KNP as char.

    KOd = "". KBe = "". KNP = "".
    for each b-jl where b-jl.jh = jh and (b-jl.ln = ln1 or b-jl.ln = ln2) no-lock:
        if not storn then run GetEKNP(b-jl.jh, b-jl.ln, b-jl.dc, input-output KOd, input-output KBe, input-output KNP).
        else run GetEKNP_Storn(b-jl.jh, b-jl.ln, b-jl.dc, input-output KOd, input-output KBe, input-output KNP).

        if KOd + KBe + KNP <> "" then do:
            p-KOd = KOd. p-KBe = KBe. p-KNP = KNP.
        end.
        if p-KBe = "" then p-KBe = KBe.
    end.
end PROCEDURE.
