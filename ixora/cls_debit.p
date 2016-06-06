/* cls_debit.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация операций по закрытию дебиторов
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
       8-12-2
 * AUTHOR
        11.01.2011 Luiza
        18.02.2011 Luiza добавила создание записи в dochhist
        22.02.2011 Изменили процедуру генерации номера документа
        26.04.11 Luiza в прцедуре create_doch : find current doch no-lock. заменила на find first doch no-lock.
        27.06.2011 Luiza запись даты today заменила на дату опер дня g-today doch.rdt = g-today
 * CHANGES

*/


{mainhead.i}

def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-param1 as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var v-select as integer no-undo.
def var v_title as char no-undo. /*наименование платежа */
def var v_sum as decimal no-undo. /* сумма расхода*/
def var v_sum971 as decimal no-undo. /* сумма 971*/
def var v_sum970 as decimal no-undo. /* сумма 970*/
def var v_ndc as decimal no-undo. /* сумма НДС*/
def var v_rem1 as char no-undo format "x(20)".
def var v_rem2 as char no-undo format "x(20)".
def var v_rem3 as char no-undo format "x(20)".
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def var v_gl as int  no-undo. /* счет г/к - расходы */
def var v_gl1 as int  no-undo. /* счет г/к */
def var v_codfr as char format "x(1)" init "2". /*код операций  табл codfr для doch.codfr */

def var v_crc as int  no-undo.  /* Валюта*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_ret as logi no-undo format "Да/Нет" init no.
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var vparr as char no-undo.
def new shared var v-docid1 as char format "x(19)" no-undo.
def new shared var v-docid as char format "x(9)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var s-acc as char no-undo.
def var v_list as char no-undo.

define temp-table arphelp like arp.
 for each arp where length(arp.arp) >= 20 no-lock.  /*and arp.crc = 1 no-lock:*/
    create arphelp.
    buffer-copy arp to arphelp.
end.

define temp-table subdel like sub-cod.
for each sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.ccode <> "msc" and
    length(sub-cod.acc) >= 20 no-lock.
    create subdel.
    buffer-copy sub-cod to subdel.
end.
for each subdel.
    s-acc = subdel.acc.
    find arphelp where arphelp.arp = s-acc no-lock no-error.
    if available arphelp then delete arphelp.
end.

define temp-table glhelp like gl.
 for each gl where gl.gl >= 560800 and gl.gl <= 592399 no-lock. /* and gl.crc = 1 no-lock:*/
    create glhelp.
    buffer-copy gl to glhelp.
end.

define button b1 label "НОВЫЙ".
define button b2 label "НА КОНТРОЛЬ".
define button b3 label "ТРАНЗАКЦИЯ".
define button b4 label "ОРДЕР".
define button b5 label "УДАЛИТЬ".
define button b6 label "ПРОСМОТР".
define button b7 label "ВЫХОД".

define frame a2
    b1 b2 b3 b4 b5 b6 b7
    with side-labels row 4 column 5 no-box.

   form
        v-docid label " Документ " format "x(9)" skip(1)
        v_ndc LABEL " Сумма НДС(в том числе)" format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму НДС; F4-выход" skip
        v_arp label " Счет-карточка ARP - кредит" format "X(20)"
            validate(can-find(first arphelp where arphelp.arp = v_arp and arphelp.crc = v_crc no-lock), "Нет такой счет - карточки ARP!") skip
        v_rem1 label " Примечание " format "X(40)" help "Введите текст примечания; F4-выход" skip(1)
        v_sum LABEL " Сумма расхода" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum > 0,"Проверьте значение суммы!") skip
        v_gl label " Счет г/к - расходы" format "zzzzzz" validate(can-find(first glhelp where glhelp.gl = v_gl and
                            lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock),"Неверный счет Г/К!")  skip
        v_rem2 label " Примечание" format "X(40)" help "Введите текст примечания; F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 60 FRAME Frame1.

    form
        v-docid label " Документ " format "x(9)" skip(1)
        v_ndc LABEL " Сумма НДС(в том числе)" format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму НДС; F4-выход" skip
        v_arp label " Счет-карточка ARP - кредит" format "X(20)"
            validate(can-find(first arphelp where arphelp.arp = v_arp and arphelp.crc = v_crc no-lock), "Нет такой счет - карточки ARP!") skip
        v_rem1 label " Примечание " format "X(40)" help "Введите текст примечания; F4-выход" skip(1)
        v_sum971 LABEL " Сумма971" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum971 > 0,"Проверьте значение суммы!") skip
        v_gl label " Счет г/к" format "zzzzzz" validate(can-find(first glhelp where glhelp.gl = v_gl and
                            lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock),"Неверный счет Г/К!")  skip
        v_rem2 label " Примечание" format "X(40)" help "Введите текст примечания; F4-выход" skip(1)
        v_sum970 LABEL " Сумма971" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum970 > 0,"Проверьте значение суммы!") skip
        v_gl1 label " Счет г/к" format "zzzzzz" validate(can-find(first glhelp where glhelp.gl = v_gl1 and
                            lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock),"Неверный счет Г/К!")  skip
        v_rem3 label " Примечание" format "X(40)" help "Введите текст примечания; F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 60 FRAME Frame2.

     Form
        v-docid label " Документ " format "x(9)" skip(1)
        v_sum LABEL " Сумма" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum > 0,"Проверьте значение суммы!") skip
        v_crc LABEL " Валюта" format "9" validate(can-find(first crc where crc.crc = v_crc no-lock),"Неверный код валюты!") skip
        v_gl label " Счет дебета г/к" format "zzzzzz"  validate(can-find(first glhelp where glhelp.gl = v_gl and
                            lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock),"Неверный счет Г/К!")  skip
        v_arp label " Счет кредита ARP " format "X(20)"
            validate(can-find(first arphelp where arphelp.arp = v_arp and arphelp.crc = v_crc no-lock), "Нет такой счет - карточки ARP для данной валюты!") skip
        v_rem1 label " Примечание " format "X(40)" help "Введите текст примечания; F4-выход" skip(1)
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 60 FRAME Frame3.

/*frame for help ARP*/
DEFINE QUERY q-help FOR arphelp.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY arphelp.arp label "Счет ARP " format "x(20)" arphelp.des label "Наименование   " format "x(29)"
       arphelp.gl label "Счет Г/К" format "999999" arphelp.crc label "Вл " format "z9"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 11 COLUMN 40 width 69 NO-BOX.

/*frame for help GL*/
DEFINE QUERY q-glhelp FOR glhelp.

DEFINE BROWSE b-glhelp QUERY q-glhelp
       DISPLAY glhelp.gl label "Счет Г/К " format "999999" glhelp.sname label "Наименование     " format "x(30)"
       glhelp.crc label "Вл." format "z9"
       WITH  15 DOWN.
DEFINE FRAME f-glhelp   b-glhelp  WITH overlay 1 COLUMN SIDE-LABELS row 11 COLUMN 40 width 69 NO-BOX.

on end-error of b-help in frame f-help do:
    hide frame f-help.
   undo, return.
end.
on end-error of b-glhelp in frame f-glhelp do:
    hide frame f-glhelp.
   undo, return.
end.

/*обработка вызова помощи*/
on help of v_arp in frame frame1 do:
    run proc_arphelp (v_crc, output v_arp).
    displ v_arp with frame frame1.
end.

on help of v_arp in frame frame2 do:
    run proc_arphelp (v_crc, output v_arp).
    displ v_arp with frame frame2.
end.

on help of v_arp in frame frame3 do:
    run proc_arphelp (v_crc, output v_arp).
    displ v_arp with frame frame3.
end.

on help of v_gl in frame frame1 do:
    run proc_glhelp (v_list, output v_gl).
    displ v_gl with frame frame1.
end.

on help of v_gl in frame frame2 do:
    run proc_glhelp (v_list, output v_gl).
    displ v_gl with frame frame2.
end.

on help of v_gl1 in frame frame2 do:
    run proc_glhelp (v_list, output v_gl1).
    displ v_gl1 with frame frame2.
end.

on help of v_gl in frame frame3 do:
    run proc_glhelp (v_list, output v_gl).
    displ v_gl with frame frame3.
end.
on help of v_crc in frame frame3 do:
    run help-crc1.
end.

/*выбор кнопки новый*/
on choose of b1 in frame a2 do:
 v-select = 0.
 hide frame frame1.
 hide frame frame2.
 hide frame frame3.
  run sel2 (" ВИДЫ  ОПЕРАЦИЙ ", " 1. ЗАКРЫТИЕ ДЕБИТОРОВ | 2. ЗАКРЫТИЕ ДЕБИТОРОВ НА СЧ. 970, 971 | 3. Г/К - ARP (без ЕКНП) | 4. ВЫХОД ", output v-select).
        if v-select = 0 then return.
        v-docid = "".
        run dochgen (output v-docid).
         if v-docid = "" then do:
            message "Ошибка генерации номера документа. Обратитесь к администратору.".
            pause.
            hide message.
            return.
        end.
        case v-select:

        when 1 then do:
            v_list = "5608,5741,5742,574,5744,5745,5746,5748,5749,5750,5752,5753,5921,5922,5923".
            v_ndc = 0.
            v_crc = 1.
            v_arp = "".
            v_rem1 = "".
            v_sum = 0.
            v_gl = 0.
            v_rem2 = "".
            v_title = " ЗАКРЫТИЕ ДЕБИТОРОВ ".
            v-tmpl = "vnb0009".
            v_ret = yes.
            v-ja = no.
            displ v-docid  v-ja with  frame frame1.
            do while v_ret:
                v_ret = no.
                update  v_ndc v_arp  help "Счет -карточка ARP; F2-помощь; F4-выход" v_rem1 v_sum  help " Введите сумму; F4-выход"
                v_gl help "Введите счет г/к - расходы; F2-помощь; F4-выход" v_rem2 with frame frame1.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame1.
                update v-ja  with frame frame1.
                 /* формир v-param для trxgen.p */
                v-param = string(v_ndc) + vdel + v_arp + vdel + v_rem1 + vdel +
                string(v_sum) + vdel + string(v_gl) + vdel + v_rem2 + vdel.

                /* формир v-param1 для trxsim.p */
                v-param1 = string(v_ndc) + vdel + v_arp + vdel + v_rem1 + vdel +
                string(v_sum) + vdel + string(v_gl) + vdel + v_rem2 + vdel.
                run create_doch.
                if rcode <> 0 then v_ret = yes.
            end. /* end do while v_ret*/
        end. /* end when 1  */
/*---------------*/
        when 2 then do:
            v_list = "5608,5741,5742,574,5744,5745,5746,5748,5749,5750,5752,5753,5921,5922,5923".
            v_ndc = 0.
            v_crc = 1.
            v_arp = "".
            v_rem1 = "".
            v_sum971 = 0.
            v_gl = 0.
            v_rem2 = "".
            v_sum970 = 0.
            v_gl1 = 0.
            v_rem3 = "".
            v_title = " ЗАКРЫТИЕ ДЕБИТОРОВ НА СЧ. 970, 971".
            v-tmpl = "vnb0011".
            v_ret = yes.
            v-ja = no.
            displ v-docid  v-ja with  frame frame2.
            do while v_ret:
                v_ret = no.
                update  v_ndc v_arp  help "Счет -карточка ARP; F2-помощь; F4-выход" v_rem1
                v_sum971  help " Введите сумму; F4-выход" v_gl help "Введите счет г/к; F2-помощь; F4-выход" v_rem2
                v_sum970  help " Введите сумму; F4-выход" v_gl1 help "Введите счет г/к; F2-помощь; F4-выход" v_rem3 with frame frame2.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame2.
                update v-ja  with frame frame2.
                 /* формир v-param для trxgen.p */
                v-param = string(v_ndc) + vdel + v_arp + vdel + v_rem1 + vdel +
                string(v_sum971) + vdel + string(v_gl) + vdel + v_rem2 + vdel +
                string(v_sum970) + vdel + string(v_gl1) + vdel + v_rem3 + vdel.

                /* формир v-param1 для trxsim.p */
                v-param1 = string(v_ndc) + vdel + v_arp + vdel + v_rem1 + vdel +
                string(v_sum971) + vdel + string(v_gl) + vdel + v_rem2 + vdel +
                string(v_sum970) + vdel + string(v_gl1) + vdel + v_rem3 + vdel.
                run create_doch.
                if rcode <> 0 then v_ret = yes.
            end. /* end do while v_ret*/
        end. /* end when 2  */
/*------------------*/
        when 3 then do:
            v_list = "5608,5721,5722,5729,5741,5742,574,5744,5745,5746,5748,5749,5750,5752,5753,5761,5763,5764,5765,5766,5768,5921,5922,5923".
            v_sum = 0.
            v_crc = 0.
            v_arp = "".
            v_rem1 = "".
            v_gl = 0.
            v_title = " Г/К - ARP(без ЕКНП)".
            v-tmpl = "vnb0002".
            v_ret = yes.
            v-ja = no.
            displ v-docid  v-ja with  frame frame3.
            do while v_ret:
                v_ret = no.
                update  v_sum  help " Введите сумму; F4-выход" v_crc help " Введите код валюты; F2-помощь; F4-выход"  v_gl  help "Введите счет дебета г/к; F2-помощь; F4-выход"
                with frame frame3.
                update v_arp help "Введите счет кредита ARP; F2-помощь; F4-выход" v_rem1 with frame frame3.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame3.
                update v-ja  with frame frame3.
                 /* формир v-param для trxgen.p */
                v-param = string(v_sum) + vdel + string(v_crc) + vdel +
                string(v_gl) + vdel + v_arp + vdel + v_rem1 + vdel.

                /* формир v-param1 для trxsim.p */
                v-param1 = string(v_sum) + vdel + string(v_crc) + vdel +
                string(v_gl) + vdel + v_arp + vdel + v_rem1 + vdel.
                run create_doch.
                if rcode <> 0 then v_ret = yes.
            end. /*end do while v_ret:*/
        end.
     when 7 then return.
   end case.

 hide frame frame1.
 hide frame frame2.
 hide frame frame3.
end. /*конец кнопки новый*/

on choose of b2 in frame a2 do: /* кнопка контроль*/
run doch_control (v_codfr).
end. /*конец кнопки контроль*/

on choose of b3 in frame a2 do: /* кнопка транзакция*/
run doch_trx (v_codfr).
end. /*конец кнопки транзакция*/

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

procedure proc_glhelp.
def input parameter v_list as char.
def output parameter v_gl1 as int.
find first glhelp where lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock no-error.
    if available glhelp then do:
        OPEN QUERY  q-glhelp FOR EACH glhelp where lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock.
        ENABLE ALL WITH FRAME f-glhelp.
        wait-for return of frame f-glhelp
        FOCUS b-glhelp IN FRAME f-glhelp.
        v_gl1 = glhelp.gl.
        hide frame f-glhelp.
   end.
    else do:
        MESSAGE "СЧЕТ Г/Л РАСХОДЫ НЕ НАЙДЕН.".
        v_gl1 = 0.
    end.
end procedure.

procedure proc_arphelp.
    def input parameter v_crc as int.
    def output parameter v_arp as char.
    find first arphelp no-lock no-error.
    if available arphelp then do:
        OPEN QUERY  q-help FOR EACH arphelp where arphelp.crc = v_crc no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        v_arp = arphelp.arp.
        hide frame f-help.
    end.
    else do:
        MESSAGE "СЧЕТ АRP НЕ НАЙДЕН.".
        v_arp = "".
    end.
end procedure.

procedure create_doch:
    do transaction:
        create doch.
        doch.docid = v-docid.
        doch.rdt = g-today.
        doch.rtim = TIME.
        doch.rwho = g-ofc.
        if v-ja then  doch.sts = "sen".
        else doch.sts = "new".
        doch.templ = v-tmpl.
        doch.delim = vdel.
        doch.param1 = v-param.
        doch.sub = "arp".
        doch.acc = v_arp.
        doch.codfr =  v_codfr.
        v-docid1 = v-docid.
        v-rdt =  doch.rdt.
        v-rtim = doch.rtim.
        find first doch no-lock.
        run trxsim (v-docid1, v-tmpl, vdel, v-param1, 1, output rcode, output rdes, output vparr).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            undo.
            next.
        end.
        run doch_hist (v-docid).
      if v-ja then run pr_doch_order(v-docid, v-rdt, v-rtim, g-ofc).
     /* оконч формир проводки в doch и docl */
     end. /*end trans-n*/
end procedure.



