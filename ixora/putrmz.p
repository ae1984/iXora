/* putrmz.p
 * MODULE
        Сканер штрих-кодов
 * DESCRIPTION
        Создает платеж, присваивает все поля
 * RUN
        Вызывается в цикле из scan.p при сканированиее штрих-кода
 * CALLER
        scan.p
 * SCRIPT
        
 * INHERIT
        n-remtrz - создает новый RMZ
        ispognt  - создает проводку
        putjou   - создает внутрений платеж
        Sm-vrd   - проверка суммы прописью
        comm-rnn - проверка РНН
        acc-ctr  - проверка по ключу счета получателя
 * MENU
        5.3.16
 * AUTHOR
        29.11.2004 suchkov 
 * BASES
        BANK
 * CHANGES
        18.02.2005 tsoy - добавил время платежа
        29.03.2005 suchkov - переделал проверку на повторный платеж
        11.04.2005 suchkov - перенес проставление типа платежа из rtzcon
        27.04.2005 suchkov - добавил проставление транспорта
        18.07.2005 suchkov - добавил проставление признака "pdoctng" 
        05/10/2005 rundoll - проставление транспорта для срочных платежей.
        11.08.06   Тен     - добавил проставление даты валютирования, если платеж срочный или больше равен 5000000 то транспорт 2 else 1
        02.10.06   Тен     - если не проставлена valdt2, то отрабатывает по старому
        17/04/2008 madiyar - номер платежного поручения - в t-rmz.tfld[1]
        18/04/2008 madiyar - коррсчет был прописан прямо в программе, теперь тянется из справочника банков
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
*/

{scan.i}
{global.i}
{comm-rnn.i}
{lgps.i new}

define new shared variable s-remtrz like remtrz.remtrz.
define new shared variable v-amt    as decimal .
define variable day      as integer no-undo.
define variable mon      as integer no-undo.
define variable yea      as integer no-undo.
define variable i        as integer no-undo.
define variable v-o      as logical no-undo.
define variable receiver as character no-undo.
define variable ourbank  as character no-undo.
define variable vpoint   as integer no-undo.
define variable vdep     as integer no-undo.
define variable summa    as character no-undo.
define variable ordertxt as character no-undo.
define variable et       as character initial "#" no-undo.  
define variable vbank    as character extent 4 no-undo. 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do: 
 message " There isn't record OURBNK in sysc file !! " view-as alert-box. 
 return . 
end. 
ourbank = sysc.chval. 

find first bankl where bankl.bank = ourbank no-lock no-error. 

vbank[1] = bankl.name.
/*vbank[2] = */
vbank[3] = bankl.addr[1].
/*vbank[4] = */

for each t-rmz exclusive-lock.

    v-amt = t-rmz.sum no-error .

    /* Начинаем проверки */

    /* Проверка суммы */
    if v-amt = 0 then do:
        t-rmz.terr = "Некорректная сумма!" .
        t-rmz.tpri = no.
        next.
    end.

    find bankl where bankl.bank = t-rmz.tfld[14] no-lock no-error.
    if available bankl then do: 
        receiver = "n" .
    end.
    else do:
        find bankl where bankl.crbank = t-rmz.tfld[14] no-lock no-error .
        if not available bankl then do:
            t-rmz.terr = "Не найден банк получатель в справочнике банков!" .
            t-rmz.tpri = no.
            next.
        end.
        else receiver = "u" .
    end.

    /* Проверка кода назначения платежа */
    find codfr where codfr = "spnpl" and codfr.code = t-rmz.tfld[22] no-lock no-error .
    if not available codfr then do:
        t-rmz.terr = "Ошибка в коде назначения платежа!" .
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка пенсионного платежа */
    if t-rmz.tfld[22] = "010" or t-rmz.tfld[22] = "019" or t-rmz.tfld[22] = "013" or t-rmz.tfld[22] = "020" then do:
        t-rmz.terr = "Пенсионные платежи не проводятся со сканера!" .
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка соответствия счета получателя ключу */
    run acc-ctr(input string(integer (t-rmz.tfld[12]),"999999999"),t-rmz.tfld[14],output v-o).
    if not v-o then do :
        t-rmz.terr = "Счет получателя не соответствует ключу! ". pause.
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка кода бюджетной классификации */
    if integer (t-rmz.tfld[12]) = 80900 then do:
        if t-rmz.tfld[23] = "" then do:
                t-rmz.terr = "На заполнен код бюджетной классификации!" .
                t-rmz.tpri = no.
                next.
        end.    

        find budcode where budcode.code = integer (t-rmz.tfld[23]) no-lock no-error .
            if not available codfr then do:
                t-rmz.terr = "Ошибка в коде бюджетной классификации!" .
                t-rmz.tpri = no.
                next.
            end.
    end.

    /* Проверка даты платежки */
/*    assign
    day = integer (substring (t-rmz.tfld[2],7,2))
    mon = integer (substring (t-rmz.tfld[2],5,2))
    yea = integer (substring (t-rmz.tfld[2],1,4)).
    if date(mon,day,yea) < today - 10 then do:
                t-rmz.terr = "Срок документа больше 10 дней!" .
                next.
    end. */

    /* Проверка счета отправителя */
    find aaa where aaa.aaa = string(integer (t-rmz.tfld[6]),"999999999")  no-lock no-error .
    if not available aaa then do:
        t-rmz.terr = "Не найден счет отправителя!" .
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка клиента */
    find cif where cif.cif = aaa.cif no-lock no-error .
    if not available cif then do:
        t-rmz.terr = "Не найден клиент - владелец счета отправителя!" .
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка РНН отправителя */
    if cif.jss <> t-rmz.tfld[4] then do:
        t-rmz.terr = "Несоответствие РРН отправителя!" .
        t-rmz.tpri = no.
        next.
    end.

    /* Проверка РНН получателя */
    if comm-rnn (t-rmz.tfld[10]) then do:
        t-rmz.terr = "Не верный контрольный ключ РНН!".
        t-rmz.tpri = no.
        next.
    end. 


    /* Проверка на повторный ввод */
/*    find first remtrz where remtrz.rdt   = today 
                        and remtrz.ba    = string(integer (t-rmz.tfld[12]),"999999999")  
                        and remtrz.dracc = string(integer (t-rmz.tfld[6]),"999999999") 
                        and substr(remtrz.sqn, 19, length(remtrz.sqn) - 18) = t-rmz.tfld[16]
                        and remtrz.amt   = v-amt          no-lock no-error .
    if available remtrz then do:
        t-rmz.terr = "Повторный ввод! Первичный платеж - " + remtrz.remtrz .
        t-rmz.tpri = no.
        next.
    end.*/

    /* Все проверки пройдены. Теперь разные предупреждения. */

    /* Проверка суммы: числом/прописью */
    run Sm-vrd (input v-amt, output summa).
    if replace(summa," ","") <> replace(substring(t-rmz.tfld[20],1,index(t-rmz.tfld[20], "тенге") - 1)," ","")
                                then message "Сумма цифрами не совпадает с суммой прописью!!!" view-as alert-box.

    /* Проверка банка посредника */
    if t-rmz.tfld[17] begins "19" and bankl.bank <> t-rmz.tfld[17] and bankl.crbank <> t-rmz.tfld[17] then message "Неверный банк посредник!" view-as alert-box.

    /* Проверка длины назначения платежа */
    if length(t-rmz.tfld[25]) > 60 then message "Длина назначения платежа больше 60 символов!!!" view-as alert-box.

    /* Проверка спецсимволов в назначения платежа */
    do i = 1 to length (et):
        if t-rmz.tfld[25] matches "*" + substring(et,i,1) + "*" then message "В назначении платежа встречен символ " substring(et,i,1) view-as alert-box.
    end.
    if lookup(t-rmz.tfld[25],"*") > 0 then message "В назначении платежа встречен символ *" view-as alert-box.

    /* Проверка КБК */
    if t-rmz.tfld[23] <> "" and integer (t-rmz.tfld[12]) <> 80900 then message "Заполнен КБК но платеж не бюджетный!" view-as alert-box.


    /* Все проверки прошли успешно! Проверим не внутренний ли это платеж? */

    if t-rmz.tfld[8] = t-rmz.tfld[14] then next .

    /* Все проверки прошли успешно! Создаем RMZ */

/*  message "Все проверки завершены успешно!" . pause 10. */

    ordertxt = t-rmz.tfld[3] + "/RNN/" + t-rmz.tfld[4] + "/CHIEF/" + t-rmz.tfld[26] + "/MAINBK/" + t-rmz.tfld[27].

    find ofc where ofc.ofc = g-ofc no-lock.
    assign vpoint = ofc.regno / 1000 - 0.5 
           vdep   = ofc.regno - vpoint * 1000.
    find point where point.point = vpoint no-lock .
    find ppoint where  ppoint.depart = vdep and ppoint.point = vpoint no-lock .
    find sysc where sysc.sysc = "swadd4" no-lock.
    
    run n-remtrz. 
    create remtrz .
    assign remtrz.source     = "SCN"
           remtrz.rtim       = time
           remtrz.t_sqn      = ""
           remtrz.rdt        = today
           remtrz.remtrz     = s-remtrz 
           remtrz.scbank     = t-rmz.tfld[8]
           remtrz.rwho       = g-ofc
/*           day               = integer (substring (t-rmz.tfld[24],7,2))
           mon               = integer (substring (t-rmz.tfld[24],5,2))
           yea               = integer (substring (t-rmz.tfld[24],1,4))
           remtrz.valdt1     = date(mon,day,yea)*/
           remtrz.valdt1     = g-today
           remtrz.sacc       = aaa.aaa
           remtrz.tcrc       = 1
           remtrz.payment    = v-amt
           remtrz.fcrc       = 1
           remtrz.amt        = v-amt
           remtrz.jh1        = ?  
           remtrz.jh2        = ? 
           remtrz.ord        = t-rmz.tfld[3] + "/RNN/" + t-rmz.tfld[4]
                             
           remtrz.bb[1]      = substr(t-rmz.tfld[11],1,35) 
           remtrz.bb[2]      = substr(t-rmz.tfld[11],36,35) 
           remtrz.bb[3]      = substr(t-rmz.tfld[11],71,70)

           remtrz.actins[1]  = "/" + substr(t-rmz.tfld[11],1,35) 
           remtrz.actins[2]  = substr(t-rmz.tfld[11],36,35)
           remtrz.actins[3]  = substr(t-rmz.tfld[11],71,70)

           remtrz.bn[1]      = substr(t-rmz.tfld[9],1,60) 
           remtrz.bn[2]      = substr(t-rmz.tfld[9],61,60) 
           remtrz.bn[3]      = " /RNN/" + t-rmz.tfld[10] 

           remtrz.ben[1]     = trim(remtrz.bn[1]) + " " + trim(remtrz.bn[2]) + " " + trim(remtrz.bn[3])
           remtrz.ordcst[1]  = remtrz.ord

                             
           remtrz.detpay[1]  = substr(t-rmz.tfld[25],1,35) 
           remtrz.detpay[2]  = substr(t-rmz.tfld[25],36,35) 
           remtrz.detpay[3]  = substr(t-rmz.tfld[25],71,35) 
           remtrz.detpay[4]  = substr(t-rmz.tfld[25],106) 

/*           remtrz.rcvinfo[1] = substr(v-info,1,35)     проставить */
/*           remtrz.rcvinfo[2] = substr(v-info,36,35)    проставить */
/*           remtrz.rcvinfo[3] = substr(v-info,71,35)    проставить */
/*           remtrz.rcvinfo[4] = substr(v-info,106,35)   проставить */
/*           remtrz.rcvinfo[5] = substr(v-info,141,35)   проставить */
/*           remtrz.rcvinfo[6] = substr(v-info,176,35)   проставить */

           remtrz.ba         = string(integer (t-rmz.tfld[12]),"999999999") 
           remtrz.bi         = "BEN"
           remtrz.margb      = 0
           remtrz.margs      = 0
           remtrz.svca       = 0
           remtrz.svcaaa     = aaa.aaa
           remtrz.svcmarg    = 0
           remtrz.svcp       = 0
           remtrz.svcrc      = 1
           remtrz.svccgl     = 0
           remtrz.svcgl      = 0
           remtrz.dracc      = aaa.aaa
           remtrz.drgl       = aaa.gl

           remtrz.ordcst[1]  = substr(ordertxt,1,35)    
           remtrz.ordcst[2]  = substr(ordertxt,36,35)   
           remtrz.ordcst[3]  = substr(ordertxt,71,35)   
           remtrz.ordcst[4]  = substr(ordertxt,106,35)
           remtrz.ordins[1]  = point.name
           remtrz.ordins[2]  = ppoint.name
           remtrz.ordins[3]  = point.addr[1]
           remtrz.ordins[4]  = sysc.chval

           remtrz.sqn        = "TXB00." + s-remtrz  + ".." + t-rmz.tfld[1]
           remtrz.rcbank     = bankl.cbank
           remtrz.rbank      = bankl.bank
           remtrz.racc       = string(integer (t-rmz.tfld[12]),"999999999")
           remtrz.outcode    = 3
           remtrz.scbank     = ourbank
           remtrz.sbank      = ourbank
           remtrz.actinsact  = remtrz.rbank

           remtrz.rsub       = ""
           remtrz.raddr      = ""
           remtrz.crgl       = 105100
           remtrz.rsub       = "cif"
           remtrz.ptype      = "6"

           remtrz.svccgr     = 0
           remtrz.svcrc      = 1
           remtrz.ref        = "".

    find bankt where bankt.cbank = remtrz.rbank and bankt.crc = 1 no-lock no-error.
    if avail bankt then remtrz.cracc = bankt.acc. else remtrz.cracc = "400161670".
    
    if t-rmz.tfld[24] <> "" then remtrz.valdt2 = date(t-rmz.tfld[24]).
    else 
    if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1.
                                else remtrz.valdt2 = g-today .


/* Проставление транспорта */
    find sysc where sysc.sysc = "lbtime" no-lock no-error .
    if not available sysc then do:
           message "Не найдена настройка времени клиринга. Платеж будет отправлен по гроссу!" view-as alert-box. 
           remtrz.cover = 2 .
    end.
    else do:
           if integer (sysc.chval) > time then remtrz.cover = 1 .
                                          else remtrz.cover = 2 .
    end.
 /* rundoll - для срочных платежей и платежей с суммой >= 5000000 транспорт 2. */
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "urgency"  no-lock no-error.
    if avail sub-cod then sub-cod.ccode = t-rmz.tfld[28].
    else do:
       create sub-cod.
              sub-cod.sub = "rmz".
              sub-cod.acc = remtrz.remtrz.
              sub-cod.d-cod = "urgency".
              sub-cod.ccode = t-rmz.tfld[28].
    end.
    if sub-cod.ccode = "s" then remtrz.cover = 2.

    if remtrz.amt >= 5000000 then remtrz.cover = 2.


/*
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
    if avail sub-cod then remtrz.cover = 2.
*/

/* Проставление типа платежа (перенесено из rtzcon)*/
    if remtrz.rbank begins "TXB" then do:
           find bankt where bankt.cbank = remtrz.rbank and bankt.crc = 1 no-lock .
           assign
           remtrz.cracc = bankt.acc 
           remtrz.ptype = "4"
           remtrz.cover = 5 .
    end.
                
    create sub-cod.
    create que.
    assign sub-cod.acc   = remtrz.remtrz
           sub-cod.sub   = "rmz"
           sub-cod.d-cod = "eknp" 
           sub-cod.ccode = "eknp" 
           sub-cod.rcod  = t-rmz.tfld[7] + "," + t-rmz.tfld[13] + "," + t-rmz.tfld[22]
           que.remtrz   = remtrz.remtrz
           que.pid      = "SS"
           que.rcid     = recid(remtrz) 
           que.ptype    = remtrz.ptype
           que.rcod     = "1"
           que.con      = "W"
           que.dp       = today
           que.tp       = time
           que.pri      = 29999 
           t-rmz.rmz    = remtrz.remtrz.
    create sub-cod.
    assign sub-cod.acc   = remtrz.remtrz
           sub-cod.sub   = "rmz"
           sub-cod.d-cod = "pdoctng" 
           sub-cod.ccode = "01" .

    
    if integer (t-rmz.tfld[12]) = 80900 and t-rmz.tfld[23] <> "" then do:
           assign
           remtrz.rcvinfo[1] = "/TAX/" 
           remtrz.ba         = remtrz.ba + "/" + t-rmz.tfld[23].
    end.

    /* Теперь проставим признак, что платеж уже сделан. */
    t-rmz.tpri = no .

    /* А теперь замутим транзакцию */
    run ispognt.

end.

/* А теперь надо сделать все внутренние платежи */
run putjou. 
