/* jaa_jou.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
* BASES
        BANK COMM
 * CHANGES
        23/07/2004 dpuchkov добавил проверку на действие льготного курса.
        02/08/2004 recompile
        13.10.2005 dpuchkov добавил дату выдачи паспорта.
        08/04/08 marinav - спрашивать фио при льготном курсе
        03.09.09 marinav - льготный курс берется из таблички льготных курсов
        21.04.10 marinav - добавилось третье поле примечания
        16.06.10 marinav - эквивалент 10000 долл по курсу нац банка
        02/07/2010 galina - структурировала заполнение паспортных данных
        04/08/2010 galina - добавила side-label f_cur
        12/08/2010 galina - поправила фрейм f_cur
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        19.04.2011 aigul - проверка курсов с опорниками
        22.04.2011 aigul - recompile
        08.06.2011 aigul - исправила вывод курса (после запятой выводить 4 цифры)
        08.08.2011 aigul - добавила проверку на сущ рапоряжения
        09.08.2011 aigul - recompile
        18.08.2011 aigul - recompile
        16.01.2012 aigul - recompile
        25.04.2012 aigul - сделала строгий выбор суммы для льготных курсов
        26.04.2012 aigul - recompile
        04.10.2012 id01143(sayat) - добавил поле "Вид документа" в форме f_cus (ТЗ 1527)
        14/05/2013 Luiza -  ТЗ № 1838 заполнение миникарточки при обмене наличности >= 1000$
        19/06/2013 Luiza -  ТЗ 1887 добавление ИИН в миникарточку при обмене наличности >= 1000$
*/

/** jaa_jou.p
    (D) KASE -- (K) KASE **/


{mainhead.i}
{comm-txb.i}
def new shared var v-crclgt as decimal.
def new shared var v-dateb as date.

define shared buffer bcrc for crc.
define shared buffer ccrc for crc.

define shared variable v_doc like joudoc.docnum.
define shared variable loccrc1 as character format "x(3)".
define shared variable loccrc2 as character format "x(3)".
define shared variable f-code  like crc.code.
define shared variable t-code  like crc.code.

define variable amt_debit  as logical.
define variable amt_credit as logical.

define variable rcode   as integer.
define variable rdes    as character.
define variable vdel    as character initial "^".
define variable vparam  as character.
define variable templ   as character.
define variable jparr   as character format "x(20)".

define variable d_amt   like joudoc.dramt.
define variable c_amt   like joudoc.cramt.
define variable com_amt like joudoc.comamt.
define variable m_buy   as decimal.
define variable m_sell  as decimal.

define shared variable vrat  as decimal decimals 4.
def var otv as log init 'false'.
def var v-sumlg as deci.
def var v-typ as char.
def var v-crc as int.

{chk12_innbin.i}

         /*----timur 11.03.03--------------------*/

procedure control_sum_passp:
/* если сумма больше или равна 10000USD проверять паспорт и фамилию */

define variable mcrc like crc.crc.
define variable mamt like joudoc.dramt.
define variable zcrc like crc.crc.
define variable zamt like joudoc.dramt.
def var p-doctyp as char no-undo. /* вид документа удостоверяющего личность */
def var v-passp as char.
def var v-passpwho as char.
define frame f_cus
       joudoc.info colon 14 label "ФИО, Инициалы" format "x(60)"  skip
       joudoc.perkod colon 14 label "ИИН" format "x(12)" validate((chk12_innbin(joudoc.perkod)),'Неправильно введён ИИН') skip
       p-doctyp colon 14 label 'Вид документа' format "99"  help 'F2 - справочник' validate(can-find (codfr where codfr.codfr = 'kfmFUd' and codfr.code = p-doctyp and (codfr.code = "01" or codfr.code = "02" or codfr.code = "11" or codfr.code = "12" or codfr.code = "13")  no-lock),'Нет такого вида документа!') skip
       /*"------------------Документ удостоверяющий личность------------------" at 2 skip*/
       v-passp colon 14 label "Номер"  format "x(40)" skip
       joudoc.passpdt colon 14 label "Дата выдачи" format "99/99/9999" skip
       v-passpwho  colon 14 label "Кем выдан" format "x(40)"
       with centered row 7 side-label title "ВВЕДИТЕ ДАННЫЕ" width 78.

    on help of p-doctyp in frame f_cus do:
        {itemlist.i
            &file = " codfr "
            &frame = "row 6 width 110 centered 28 down overlay "
            &where = " codfr.codfr = 'kfmFUd' and (codfr.code = '01' or codfr.code = '02' or codfr.code = '11' or codfr.code ='12' or codfr.code ='13') "
            &flddisp = " codfr.code label 'КОД' format 'x(10)' codfr.name[1] label 'Вид документа удостоверяющего личность' format 'x(40)'"
            &chkey = "code"
            &chtype = "string"
            &index  = "cdco_idx"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        p-doctyp = codfr.code.
        displ p-doctyp with frame f_cus.
    end.

    if joudoc.bas_amt eq "D" then do:
        mamt = joudoc.dramt.
        mcrc = joudoc.drcur.
    end.
    else if joudoc.bas_amt eq "C" then do:
        mamt = joudoc.cramt.
        mcrc = joudoc.crcur.
    end.

    find sysc where sysc.sysc = "obmcon" no-lock no-error.
    if avail sysc
       then
         do:
            zcrc = sysc.inval.
            zamt = sysc.deval.
         end.
       else
         do:
            message "не определена переменная sysc obmcon" skip "берутся значения по умолчанию 1000 USD" view-as alert-box.
            zcrc = 2.
            zamt = 1000.
         end.

    /* if mcrc <> zcrc  then do:*/
             find crc where crc.crc = zcrc no-lock no-error.
             zcrc = 1.
             zamt = zamt * crc.rate[1].
     /*message zamt crc.rate[1] view-as alert-box.*/

             find crc where crc.crc = mcrc no-lock no-error.
             mcrc = 1.
             if joudoc.bas_amt eq "D" then mamt = mamt * crc.rate[2].
                                      else mamt = mamt * crc.rate[3].
    /*  if joudoc.bas_amt eq "D" then  message mamt crc.rate[2] view-as alert-box.
                               else  message mamt crc.rate[3] view-as alert-box.*/
      /*    end.*/

     if mamt > zamt then
        do:
           repeat on error undo, retry:
             if (trim(joudoc.info) eq '') or (trim(v-passp) eq '') or (trim(v-passpwho) eq '') or joudoc.passpdt = ? then do:
                  update joudoc.info joudoc.perkod p-doctyp v-passp joudoc.passpdt v-passpwho with frame f_cus.
                  joudoc.passp = trim(v-passp) + ',' + replace(trim(v-passpwho),',',' ').
                  joudoc.vidpassp = p-doctyp.
             end.
             if (trim(joudoc.info) eq '') or (trim(joudoc.perkod) eq '') or (trim(v-passp) eq '') or (trim(v-passpwho) eq '') or joudoc.passpdt = ?
                then retry.
                else leave.
           end.
        end.

end procedure.

         /*----timur 11.03.03--------------------*/
{mframe.i "shared"}


DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
joudoc.dracc = "".
joudoc.cracc = "".
joudoc.chk   = 0.
d_cif = "". c_cif = "".
dname_1 = "". dname_2 = "". dname_3 = "".
cname_1 = "". cname_2 = "". cname_3 = "".
d_avail = "". c_avail = "".
d_atl = "".  c_atl = "". d_izm = "".  d_lab = "".
joudoc.info = "". joudoc.passp = "".  joudoc.perkod = "". joudoc.passpdt = ?.
display db_com joudoc.dracc joudoc.cracc joudoc.chk c_cif d_cif d_atl
    dname_1 dname_2 dname_3 d_avail cname_1 cname_2 cname_3 c_avail c_atl
    d_izm d_lab with frame f_main.

L_1:
repeat on endkey undo, return:
    message "  F2 - ПОМОЩЬ  ".
    update joudoc.drcur with frame f_main.
    find crc where crc.crc eq joudoc.drcur no-lock no-error.
    /*joudoc.brate = crc.rate[2].*/
    f-code = crc.code.
    display crc.des with frame f_main.
    hide message.

    repeat on endkey undo, next L_1:
        message "  F2 - ПОМОЩЬ  ".
        update joudoc.crcur with frame f_main.
            if joudoc.crcur eq joudoc.drcur then do:
                message "ОДИНАКОВЫЕ КОДЫ ВАЛЮТ.".
                pause 3.
                undo, retry.
            end.
            else leave.
    end.
    def var b as char.
    def var c as char.
    def var d as char.
    for each sysc where sysc.sysc = "scrc" no-lock:
        c = sysc.chval.
        if (index(c,string(joudoc.crcur)) > 0) or (index(c,string(joudoc.drcur)) > 0) then do:
            d = substr(c,index(c,string(joudoc.crcur)),3).
            if substr(d,3,1) = "1" then do:
                message "Курс валюты не соответствует опорному курсу! Операция не возможна!" view-as alert-box.
                return.
            end.
            b = substr(c,index(c,string(joudoc.drcur)),3).
            if substr(b,3,1) = "1" then do:
                message "Курс валюты не соответствует опорному курсу! Операция не возможна!" view-as alert-box.
                return.
            end.
        end.
    end.

    find first sysc where sysc.sysc = "scrc-order" no-lock no-error.
    if avail sysc and sysc.loval = yes then do:
        message "Курс валюты не соответствует опорному курсу! Операция не возможна!!" view-as alert-box.
        return.
    end.
    /*
    for each sysc where sysc.sysc = "scrc-order" no-lock:
        c = sysc.chval.
        if (index(c,string(joudoc.crcur)) > 0) or (index(c,string(joudoc.drcur)) > 0) then do:
            d = substr(c,index(c,string(joudoc.crcur)),3).
            if substr(d,3,1) = "1" then do:
                message "Курс валюты не соответствует опорному курсу! Операция не возможна!!" view-as alert-box.
                return.
            end.
            b = substr(c,index(c,string(joudoc.drcur)),3).
            if substr(b,3,1) = "1" then do:
                message "Курс валюты не соответствует опорному курсу! Операция не возможна!!" view-as alert-box.
                return.
            end.
        end.
    end.
    */
    find bcrc where bcrc.crc eq joudoc.crcur no-lock no-error.
    /*joudoc.srate = bcrc.rate[3].*/
    t-code = bcrc.code.
    display loccrc1 loccrc2 /*crc.rate[9] bcrc.rate[9]*/ f-code t-code
        /*joudoc.brate joudoc.srate*/ bcrc.des with frame f_main.
    hide message.

    /*
    joudoc.sn = crc.rate[9].
    joudoc.bn = bcrc.rate[9].*/

    /** MAKS…JUMA SUMMA **/
    repeat on endkey undo, next L_1:
        update joudoc.dramt with frame f_main.
        if joudoc.dramt eq 0 then update joudoc.cramt with frame f_main.
        if joudoc.dramt eq 0 and joudoc.cramt eq 0 then undo, retry.
        else do:
            if joudoc.dramt ne 0 then joudoc.bas_amt = "D".
            else if joudoc.cramt ne 0 then joudoc.bas_amt = "C".

            if joudoc.bas_amt eq "D" then do:
                d_amt = joudoc.dramt.
                c_amt = 0.
                v-sumlg = d_amt.
                v-typ = "D".
                v-crc = joudoc.drcur.
            end.
            else if joudoc.bas_amt eq "C" then do:
                d_amt = 0.
                c_amt = joudoc.cramt.
                v-sumlg = c_amt.
                v-typ = "C".
                v-crc = joudoc.crcur.
            end.
            run yn('Внимание!','','Курс обмена льготный?','',output otv).
            if otv = true then do.

                        /*          update vrat label ' Введите льготный курс' format '999.99' skip with side-label row 5 centered frame dat.
                        */
                      /*
                        if comm-cod() = 0 then  do:
                      */
                             if joudoc.drcur = 1 then
                               run kzn_lg(True, True, v-sumlg, v-typ, v-crc).
                             else
                               run kzn_lg(True, False, v-sumlg, v-typ, v-crc).

                               if v-crclgt = 0 then return.
                               if g-today > v-dateb then do:
                                  MESSAGE "Внимание: срок действия данного курса истек. " VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "".
                                  return.
                               end.
                               vrat = v-crclgt.
                               if vrat = 0 then return.
                       /*
                        end.
                        else
                         update vrat label ' Введите льготный курс' format '999.99' skip with side-label row 5 centered frame dat.
                       */

                        run conv-obm(input joudoc.drcur, input joudoc.crcur,
                              input-output d_amt, input-output c_amt,
                              output joudoc.brate, output joudoc.srate,
                              output joudoc.bn,output joudoc.sn,
                              output m_buy, output m_sell).

                        display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                             with frame f_main.

                        run control_sum_passp.

                        run jaa_tmpl(input joudoc.bas_amt,
                                   output vparam, output templ).
            end.

            else do.
                       run conv (input joudoc.drcur, input joudoc.crcur, input true,
                         input true, input-output d_amt, input-output c_amt,
                         output joudoc.brate, output joudoc.srate, output joudoc.bn,
                         output joudoc.sn, output m_buy, output m_sell).


                       display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                         with frame f_main.

                       /*----timur 11.03.03--------------------*/
                         run control_sum_passp.
                       /*----timur 11.03.03--------------------*/
                       run jaa_tmpl
                         (input joudoc.bas_amt, output vparam, output templ).

            end.
            if joudoc.bas_amt eq "D" then do:
                if otv =true then
                run trxsim-obm (templ, vdel, vparam, 4, output rcode,
                    output rdes, output jparr).
                else run trxsim ("", templ, vdel, vparam, 4, output rcode,
                                    output rdes, output jparr).

                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.
                joudoc.cramt = decimal (jparr).
                display joudoc.cramt with frame f_main.
            end.
            if joudoc.bas_amt eq "C" then do:
               if otv =true then
               run trxsim-obm (templ, vdel, vparam, 3, output rcode,
                    output rdes, output jparr).
               else
                run trxsim ("", templ, vdel, vparam, 3, output rcode,
                    output rdes, output jparr).

                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.

                joudoc.dramt = decimal (jparr).
                display joudoc.dramt with frame f_main.
            end.

            display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                with frame f_main.

            joudoc.remark[1] = "Обмен валюты.".
            display joudoc.remark with frame f_main.
            display joudoc.rescha[3] with frame f_main.
/*          update joudoc.remark with frame f_main. */

        end.

        leave.
    end.

    leave.
end.

run jou_com.
if keyfunction (lastkey) eq "end-error" then undo, return.

leave.
END.
