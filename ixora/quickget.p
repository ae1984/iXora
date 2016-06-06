/* quickget.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация взаимозачетов по быстрым переводам
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        15.02.2011 Luiza
        22.02.2011 Изменили процедуру генерации номера документа
        31.03.2011 Luiza в прцедуре create_doch : find current doch no-lock. заменила на find first doch no-lock.
        14.04.2011 Luiza Изменила код кнп с 119 на 840.
        27.06.2011 Luiza запись даты today заменила на дату опер дня g-today doch.rdt = g-today
        06/04/2012 Luiza добавила команду удаление транзакции
 * CHANGES

*/


{mainhead.i}

def var v-tmpl as char no-undo.
def var v-tmpl1 as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-param1 as char no-undo.
def var v-paramk as char no-undo.
def var v-param1k as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var v-select1 as integer no-undo.
def var v_title as char no-undo. /*наименование платежа */
def var v_sum as decimal no-undo. /* сумма перевода*/
def var v_sumk as decimal no-undo. /* сумма комиссии*/
def var v_rem1 as char no-undo format "x(20)".
def var v_rem2 as char no-undo format "x(20)".
def var v_dt as int no-undo. /* debet*/
def var v_dt1 as int no-undo. /* debet*/
def var v_ct as int  no-undo. /* credit */
def var v_ct1 as int  no-undo. /* комиссия */
def var v_arp as char format "x(20)" no-undo. /* счет ARP debet */
def var v_arp2 as char format "x(20)" no-undo. /* счет ARP debet */
def var v_arp1 as char format "x(20)" no-undo. /* счет ARP credit */
def var v_codfr as char format "x(1)" init "4". /*код операций  табл codfr для doch.codfr */

def var v_crc as int  no-undo.  /* Валюта*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_ret as logi no-undo format "Да/Нет" init no.
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var vparr as char no-undo.
def new shared var v-docid2 as char format "x(19)" no-undo.
def new shared var v-docid1 as char format "x(19)" no-undo.
def var v-docid as char format "x(9)" no-undo.
def new shared var v-docidk as char format "x(9)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var s-acc as char no-undo.
def var v_list as char no-undo.
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/

define temp-table arphelp like arp.
 for each arp where length(arp.arp) >= 20 and arp.crc <> 1 no-lock:
    create arphelp.
    buffer-copy arp to arphelp.
end.

define temp-table subdel like sub-cod.
for each sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.ccode <> "msc" and
    length(sub-cod.acc) >= 20 no-lock.
    create subdel.
    buffer-copy sub-cod to subdel.
end.
for each subdel no-lock.
    s-acc = subdel.acc.
    find arphelp where arphelp.arp = s-acc no-lock no-error.
    if available arphelp then delete arphelp.
end.

define button b1 label "НОВЫЙ".
define button b2 label "НА КОНТРОЛЬ".
define button b3 label "ТРАНЗАКЦИЯ".
define button b4 label "ОРДЕР".
define button b5 label "УДАЛИТЬ ДОК".
define button b8 label "УДАЛИТЬ ТРАНЗ".
define button b6 label "ПРОСМОТР".
define button b7 label "ВЫХОД".

define frame a2
    b1 b2 b3 b4 b5 b6 b8 b7
    with side-labels row 4 column 5 no-box.

     Form
        v-docid2 label " Документ " format "x(9)" skip(1)
        v_crc LABEL " Валюта                  " format "9" validate(can-find(first crc where crc.crc <> 1 and crc.sts <> 9 and crc.crc = v_crc no-lock),"Неверный код валюты!") skip
        v_sum LABEL " Сумма выданных переводов" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum >= 0,"Проверьте значение суммы!") skip
        v_dt LABEL " Дебет Г/К               " format "999999"  v_arp label "        АРП (Дт)" format "X(20)" skip
        v_ct LABEL " Кредит Г/К              " format "999999" v_arp1 label "        АРП (Кт)" format "X(20)" skip
        v_rem1 label " Примечание" format "X(50)" skip
        "___________________________________________________________________________" skip(1)
        v-docidk label " Документ " format "x(9)" skip(1)
        v_sumk LABEL " Сумма комиссии          " format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sumk >= 0,"Проверьте значение суммы!") skip
        v_dt1 LABEL " Дебет Г/К               " format "999999" v_arp2 label "        АРП (Дт)" format "X(20)" skip
        v_ct1 LABEL " Кредит Г/К              " format "999999"  skip
        v_rem2 label " Примечание" format "X(50)" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip(1)
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 80 FRAME Frame1.

/*обработка вызова помощи*/
on help of v_crc in frame frame1 do:
    run help-crc1.
end.

on choose of b8 in frame a2 do: /* кнопка контроль*/
run doch_trxdel (v_codfr).
end. /*конец кнопки контроль*/


/*выбор кнопки новый*/
on choose of b1 in frame a2 do:
 v-select1 = 0.
 hide frame frame1.
 hide frame frame2.
 hide frame frame3.
  run sel2 (" ВИДЫ  ПЕРЕВОДОВ ", " 1. Система 'ЮНИСТРИМ'  | 2. Система 'ЗОЛОТАЯ КОРОНА' | 3. Система 'БЫСТРАЯ ПОЧТА'
                           | 4. Система 'ВЕСТЕРН ЮНИОН' | 5. ВЫХОД ", output v-select1).
        if v-select1 = 0 then return.
        v-docid2 = "".
        run dochgen (output v-docid2).
         if v-docid2 = "" then do:
            message "Ошибка генерации номера документа. Обратитесь к администратору.".
            pause.
            hide message.
            return.
        end.
        v-docidk = "".
        run dochgen (output v-docidk).
         if v-docidk = "" then do:
            message "Ошибка генерации номера документа. Обратитесь к администратору.".
            pause.
            hide message.
            return.
        end.
            clear frame frame1.
            v_code = "14".
            v_kbe = "14".
            v_knp = "840".   /*"119".  */
            v_arp = "".
            v_arp1 = "".
            v_sum = 0.
            v_crc = 0.
            v_arp2 = "".
            v_sumk = 0.
            v_ret = yes.
            v-ja = no.

        case v-select1:
        when 1 then do:
            v_dt = 287036.
            v_dt1 = 287036.
            v_ct = 187036.
            v_ct1 = 460126.
            v_rem1 = "Взаиморасчет по переводам 'ЮНИСТРИМ' ".
            v_rem2 = "Комиссия за выданные переводы 'ЮНИСТРИМ'".
            v_title = " Система 'ЮНИСТРИМ' ".
        end. /* end when 1  */
        when 2 then do:
            v_dt = 287037.
            v_dt1 = 287037.
            v_ct = 187037.
            v_ct1 = 460127.
            v_rem1 = "Взаиморасчет по переводам 'ЗОЛОТАЯ КОРОНА'".
            v_rem2 = "Комиссия за выданные переводы 'ЗОЛОТАЯ КОРОНА'".
            v_title = " Система 'ЗОЛОТАЯ КОРОНА' ".
        end. /* end when 1  */
        when 3 then do:
            v_dt = 287034.
            v_dt1 = 287034.
            v_ct = 187034.
            v_ct1 = 460123.
            v_rem1 = "Взаиморасчет по переводам 'БЫСТРАЯ ПОЧТА'".
            v_rem2 = "Комиссия за выданные переводы 'БЫСТРАЯ ПОЧТА'".
            v_title = " Система 'БЫСТРАЯ ПОЧТА' ".
        end. /* end when 1  */
        when 4 then do:
            v_dt = 287035.
            v_dt1 = 287035.
            v_ct = 187035.
            v_ct1 = 460124.
            v_rem1 = "Взаиморасчет по переводам 'ВЕСТЕРН ЮНИОН'".
            v_rem2 = "Комиссия за выданные переводы 'ВЕСТЕРН ЮНИОН'".
            v_title = " Система 'ВЕСТЕРН ЮНИОН' ".
        end. /* end when 1  */
     when 5 then return.
   end case.
            displ v-docid2  v-docidk v-ja with  frame frame1.
            do while v_ret:
                v_ret = no.
                update  v_crc help " Введите код валюты, F2-помощь, F4-выход" v_sum help " Введите сумму перевода; F4-выход"
                v_sumk   help " Введите сумму комиссии; F4-выход" with frame frame1.
                if v_sum = 0 then message " Сумма перевода равна нулю, проводка по переводу не сформируется! ".
                if v_sumk = 0 then message " Сумма комиссии равна нулю, проводка по комиссии не сформируется! ".
                find first arphelp where arphelp.gl = v_dt and arphelp.crc = v_crc no-lock no-error.
                if available arphelp then v_arp = arphelp.arp.
                else do:
                    message "Не найден АРП счет по дебету. Обратитесь к администратору.".
                    pause.
                    hide message.
                    hide frame frame1.
                    return.
                end.
                find first arphelp where arphelp.gl = v_ct and arphelp.crc = v_crc no-lock no-error.
                if available arphelp then v_arp1 = arphelp.arp.
                else do:
                    message "Не найден АРП счет по кредиту. Обратитесь к администратору.".
                    pause.
                    hide message.
                    hide frame frame1.
                    return.
                end.
                v_arp2 = v_arp.
                displ v_dt v_arp v_ct  v_arp1 v_rem1 v_dt1 v_arp2 v_ct1 v_rem2 v_code v_kbe v_knp with frame frame1.
                if v_sum = 0 and v_sumk = 0 then do : hide  frame frame1. return. end.
                update v-ja  with frame frame1.
                if v_sum <> 0 then do:
                     /* формир v-param для trxgen.p */
                   v-param = string(v_sum) + vdel + v_arp + vdel + v_arp1 + vdel +
                    v_rem1 + vdel + " " + vdel.

                    /* формир v-param1 для trxsim.p */
                    v-param1 = string(v_sum) + vdel + v_arp + vdel + v_arp1 + vdel +
                    v_rem1 + vdel + " " + vdel.
                    v-tmpl = "vnb0010".
                    run create_doch (v-docid2, v_arp).
                    if rcode <> 0 then v_ret = yes.
                end.
                if v_sumk <> 0 then do:
                     /* формир v-param для trxgen.p */
                   v-param = string(v_sumk) + vdel + string(v_crc) + vdel + v_arp2 + vdel + v_rem2 + vdel +
                    "1" + vdel + string(v_ct1) + vdel.
                    /* формир v-param1 для trxsim.p */
                    v-param1 = string(v_sumk) + vdel + string(v_crc) + vdel + v_arp2 + vdel + v_rem2 + vdel +
                    "1" + vdel + string(v_ct1) + vdel.
                    v-tmpl = "vnb0060".
                    run create_doch (v-docidk, v_arp2).
                    if rcode <> 0 then v_ret = yes.
                end.
            end. /* end do while v_ret*/
/*---------------*/
 hide frame frame1.
end. /*конец кнопки новый*/

on choose of b2 in frame a2 do: /* кнопка контроль*/
run doch_control (v_codfr).
end. /*конец кнопки контроль*/

on choose of b3 in frame a2 do:
run doch_trx (v_codfr).
end.  /*конец кнопки транзакция*/

on choose of b4 in frame a2 do: /* кнопка ордер(к)*/
run doch_order (v_codfr).
end. /*конец кнопки ордер(к)*/

on choose of b5 in frame a2 do: /* кнопка del*/
run doch_del (v_codfr).
end. /*конец кнопки del*/

on choose of b6 in frame a2 do: /* кнопка просмотр*/
run doch_view (v_codfr).
end. /*конец кнопки просмотр**/

on choose of b7 in frame a2 do:
    hide frame a2.
    return.
end. /*конец кнопки выход*/

    enable all with frame a2.
    wait-for window-close of frame a2 or choose of b7 in frame a2.



procedure dochgen. /*генерация номера след документа */
    def output parameter v-docid as char format "x(9)".
    def var num1 as int.
    find first nmbr where nmbr.code = "JOU" no-lock no-error.
    do transaction:
        num1 = NEXT-VALUE(dochnum).
        v-docid = "D" + string(num1, "9999999") + caps(nmbr.prefix).
    end.
end procedure.

procedure create_doch:
    def input parameter v-docid1 as char format "x(19)" no-undo.
    def input parameter v_ar as char format "x(20)" no-undo.
    do transaction:
        create doch.
        doch.docid = v-docid1.
        doch.rdt = g-today.
        doch.rtim = TIME.
        doch.rwho = g-ofc.
        if v-ja then  doch.sts = "sen".
        else doch.sts = "new".
        doch.templ = v-tmpl.
        doch.delim = vdel.
        doch.param1 = v-param.
        doch.sub = "arp".
        doch.acc = v_ar.
        doch.codfr =  v_codfr.
        v-rdt =  doch.rdt.
        v-rtim = doch.rtim.
        find first doch no-lock.
        run doch_hist (v-docid1).
        run trxsim (v-docid1, v-tmpl, vdel, v-param1, 1, output rcode, output rdes, output vparr).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            undo.
            next.
        end.
        if v-ja then run pr_doch_order(v-docid1, v-rdt, v-rtim, g-ofc).
     /* оконч формир проводки в doch и docl */
     end. /*end trans-n*/
end procedure.

