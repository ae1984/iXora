/* putjou.p
 * MODULE
        Сканер штрих-кодов
 * DESCRIPTION
        Эта прога делает внутренние платежи со сканера
 * RUN
        К моменту вызова в поле t-rmz.tpri стоит true только для внутренних платежей.
 * CALLER
        putrmz
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.3.16
 * AUTHOR
        suchkov
 * BASES
        BANK
 * CHANGES
        15/05/2008 madiyar - автоматически статус 6 если не кассовая операция
*/

{scan.i}
{global.i}
/*
define new shared buffer   bcrc     for crc.
define new shared buffer   ccrc     for crc.

define new shared variable loccrc1  as character format "x(3)".
define new shared variable loccrc2  as character format "x(3)".
define new shared variable f-code   like crc.code.
define new shared variable t-code   like crc.code. */

define     shared variable v-amt    as decimal.
define            variable v_doc    like joudoc.docnum.
define            variable day      as integer.
define            variable mon      as integer.
define            variable yea      as integer.
define            variable vdel     as character.
define            variable vparam   as character.
define            variable receiver as character.
define            variable ourbank  as character.
define            variable jou_prog as character.
define new shared variable s-jh     as integer.
define            variable rcode    as integer.
define            variable rdes     as character.
define            variable v-cash   as logical.



/* {mframe.i "new shared"} */

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message " There isn't record OURBNK in sysc file !! " view-as alert-box.
 return .
end.
ourbank = sysc.chval.

find first bankl where bankl.bank = ourbank no-lock no-error.

for each t-rmz where t-rmz.tpri no-lock .

    /* Главная проверка - документ надо делать в 2.1 ? */

    if t-rmz.tfld[8] = t-rmz.tfld[14] and t-rmz.terr = "" then do:

    
    
        /* Начинаем проверки */
        /*   Вообще-то все проверки пройдены в вызывающей процедуре
        find bankl where bankl.bank = t-rmz.tfld[14] no-lock no-error.
        if not available bankl then receiver = "n" .
        else do:
            find bankl where bankl.crbank = t-rmz.tfld[14] no-lock no-error .
            t-rmz.terr = "Не найден банк получатель в справочнике банков!" .
            next.
            receiver = "u" .
        end.

        find first ptyp where ptyp.sender = "o" and ptyp.receiver = receiver no-lock no-error .
       if not available ptyp then do:
            t-rmz.terr = "Не найден тип платежа в справочнике типов!" .
            next.
        end.

        find bankl where bankl.bank = t-rmz.tfld[18] no-lock no-error.
        if not available bankl then do:
            t-rmz.terr = "Не найден банк корреспондент в справочнике банков!" .
            next.
        end.

        find aaa where aaa.aaa = t-rmz.tfld[6] no-lock no-error .
        if not available aaa then do:
            t-rmz.terr = "Не найден счет отправителя!" .
            next.
        end.

        find cif where cif.cif = aaa.cif no-lock no-error .
        if not available cif then do:
            t-rmz.terr = "Не найден клиент - владелец счета отправителя!" .
            next.
        end.

        if cif.jss <> t-rmz.tfld[8] then do:
            t-rmz.terr = "Несоответствие РРН отправителя!" .
            next.
        end.  */
        
        /* Одна единственная проверка на повторный ввод */
        find first joudoc where joudoc.whn   = g-today 
                            and joudoc.dracc = string(integer (t-rmz.tfld[6]),"999999999")  
                            and joudoc.cracc = string(integer (t-rmz.tfld[12]),"999999999") 
                            and joudoc.dramt = v-amt          no-lock no-error .
        if available joudoc then do:
            t-rmz.terr = "Повторный ввод! Первичный платеж - " + joudoc.docnum .
            t-rmz.tpri = no.
            next.
        end.



        
        /* Все проверки прошли успешно! Создаем Jou Document */

        v-amt = decimal (replace(t-rmz.tfld[19],"-",".")) no-error .

        find nmbr where nmbr.code eq "JOU" no-lock .
        v_doc = "jou" + string (next-value (journal), "999999") + nmbr.prefix.

        create joudoc.
        assign joudoc.docnum = v_doc
               joudoc.whn    = g-today
               joudoc.who    = g-ofc
               joudoc.tim    = time
               joudoc.num    = ""
               joudoc.rem[1] = t-rmz.tfld[25]
               joudoc.dracc  = string(integer (t-rmz.tfld[6]),"999999999") 
               joudoc.dramt  = v-amt  
               joudoc.cramt  = v-amt
               joudoc.drcur  = 1
               joudoc.crcur  = 1
               joudoc.cracctype = '2'
               joudoc.dracctype = '2'
               /*joudoc.crc    = 1*/
               joudoc.cracc  = string(integer (t-rmz.tfld[12]),"999999999") .


        find first jouset where jouset.drtype eq "Счет" and jouset.crtype eq "Счет" no-lock no-error.
        if not available jouset or jouset.proc eq "" then do:
             message "РЕЖИМ НЕ РАБОТАЕТ." view-as alert-box.
             return.
        end.
        
        /*
        assign
        jou_prog = jouset.proc */
        t-rmz.tpri = no.

        /* run value (jou_prog). */

        vparam = joudoc.docnum + "^" + string(v-amt) + "^" + "1" + "^" + joudoc.dracc + "^" + joudoc.cracc + "^" + joudoc.remark[1] + "^" + t-rmz.tfld[22] .
        run trxgen("JOU0022", "^", vparam, "jou", joudoc.docnum , output rcode, output rdes, input-output s-jh).

        if rcode <> 0 then t-rmz.terr = rdes .
                      else do: 
                                /*
                                find jh where jh.jh = s-jh exclusive-lock .
                                jh.ref = joudoc.docnum .
                                release jh. */
                                t-rmz.rmz  = string(s-jh) .
                                joudoc.jh = s-jh.
                                
                                v-cash = false.
                                for each jl where jl.jh = s-jh no-lock:
                                    if jl.gl = 100100 or jl.gl = 100200 then do: v-cash = true. leave. end.
                                end.
                                if not v-cash then run trxsts (input s-jh, input 6, output rcode, output rdes).
                                if rcode <> 0 then do: message rdes. pause. end.
                                
                                run chgsts('jou', joudoc.docnum, 'rdy').

                                run vou_bank(2). /* Печатаем ордер */
                      end.

/*        display rcode rdes s-jh .
        pause .
  */


        s-jh = ?.
        v_doc = "".

    end.
end.

