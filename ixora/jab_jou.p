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
        02/08/2004 recompile
        21.04.10 marinav - добавилось третье поле примечания
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        08.06.2011 aigul - исправила вывод курса (после запятой выводить 4 цифры)
        25.04.2012 aigul - сделала строгий выбор суммы для льготных курсов
        27.04.2012 aigul - Добавила bases
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
def var v-sumlg as deci.
def var v-typ as char.
def var v-crc as int.

define shared variable vrat  as decimal decimals 4.
def var otv as log init 'false'.

         /*----timur 11.03.03--------------------*/

procedure control_sum_passp:
/* если сумма больше или равна 10000USD проверять паспорт и фамилию */

define variable mcrc like crc.crc.
define variable mamt like joudoc.dramt.
define variable zcrc like crc.crc.
define variable zamt like joudoc.dramt.

define frame f_cus
       "ФИО:     " joudoc.info no-label skip
       "Паспорт: " joudoc.passp no-label
       "Дата выдачи паспорта: " joudoc.passpdt no-label
       with centered row 7 title "Введите данные".

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
            message "не определена переменная sysc obmcon" skip "берутся значения по умолчанию 10000USD" view-as alert-box.
            zcrc = 2.
            zamt = 10000.
         end.

     if mcrc <> zcrc
        then
          do:
             find crc where crc.crc = zcrc no-lock.
             zcrc = 1.
             zamt = zamt * crc.rate[1].

             find crc where crc.crc = mcrc no-lock.
             mcrc = 1.
             mamt = mamt * crc.rate[1].
          end.

     if mamt >= zamt then
        do:
           repeat on error undo, retry:
             if (trim(joudoc.info) eq '') or (trim(joudoc.passp) eq '')  or joudoc.passpdt = ?
                then update joudoc.info joudoc.passp with frame f_cus.
             if (trim(joudoc.info) eq '') or (trim(joudoc.passp) eq '')  or joudoc.passpdt = ?
                then retry.
                else leave.
           end.
        end.

end procedure.

         /*----timur 11.03.03--------------------*/
{mframe.i "shared"}


DO transaction:

find joudoc where joudoc.docnum eq v_doc exclusive-lock.
joudoc.dracc = "".
joudoc.cracc = "".
joudoc.chk   = 0.
d_cif = "". c_cif = "".
dname_1 = "". dname_2 = "". dname_3 = "".
cname_1 = "". cname_2 = "". cname_3 = "".
d_avail = "". c_avail = "".
d_atl = "".  c_atl = "". d_izm = "".  d_lab = "".
joudoc.info = "". joudoc.passp = "".  joudoc.perkod = "".
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

if comm-cod() = 0 then  do:
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
end.
else
  update vrat label ' Введите льготный курс' format '999.99' skip with side-label row 5 centered frame dat.





               run conv-obm(input joudoc.drcur, input joudoc.crcur,
                     input-output d_amt, input-output c_amt,
                     output joudoc.brate, output joudoc.srate,
                     output joudoc.bn,output joudoc.sn,
                     output m_buy, output m_sell).

            display joudoc.brate joudoc.srate joudoc.bn joudoc.sn
                    with frame f_main.

               run jab_tmpl(input joudoc.bas_amt,
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

              run jab_tmpl
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
        end.

        leave.
    end.

    leave.
end.

run jou_com.
if keyfunction (lastkey) eq "end-error" then undo, return.

leave.
END.
