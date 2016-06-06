/* fil1.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация формирования внутрибанковских проводок
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
       8-9
 * AUTHOR
        01.12.2010 Luiza
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
def new shared var v_sum as decimal no-undo. /* сумма*/
def new shared var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def new shared var v_dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var v_kt as char no-undo format "x(20)". /* КТ счет карточка ARP or коррсчет*/
def var v_crc as char  no-undo format "x(1)".  /* Валюта*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(40)".  /* Назначение платежа*/
def var v_filial as char format "x(30)".   /* название филиала*/
def var v_ret as logi no-undo format "Да/Нет" init no.
def var v_pr as logi no-undo format "Да/Нет" init no.
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var vparr as char no-undo.
/*def new shared temp-table tmpl like trxtmpl.
def new shared temp-table cdf like trxcdf. */
def new shared var v-docid1 as char format "x(19)" no-undo.
def new shared var v-docid as char format "x(9)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var s-acc as char no-undo.
def var v_list as char no-undo.
def var v_codfr as char format "x(1)" init "1". /*код операций  табл codfr для doch.codfr */

/*проверка банка*/
def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).
if s-ourbank <> "TXB00" then do:
   MESSAGE " Данные операции доступны только для ЦО банка." view-as alert-box.
   hide message.
   return.
end.

define temp-table arphelp like arp.
 for each arp where length(arp.arp) >= 20 and arp.crc = 1 no-lock:
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
define button b5 label "УДАЛИТЬ".
define button b6 label "ПРОСМОТР".
define button b7 label "ВЫХОД".

define frame a2
    b1 b2 b3 b4 b5 b6 b7
    with side-labels row 4 column 5 no-box.

   form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_arp label " Дт счет-карточка ARP (с проверкой счета ГК 186010)" format "X(20)"
            validate(can-find(first arphelp where arphelp.arp = v_arp and lookup(string(arphelp.gl),v_list) > 0 no-lock),
                "Нет такой счет - карточки ARP!") skip
        v_kt label " Кт (коррсчет)" skip
        v_crc label " Валюта" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа(можно дописать наимен-е филиала); F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
        /*v_pr label "Распечатать ордер?.............."   skip*/
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME Frame1.

    form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_dt label " Дт (коррсчет)" skip
        v_arp label  " Кт счет-карточка ARP (с проверкой счета ГК 286010)" format "X(20)"  validate(can-find(first arphelp where arphelp.arp = v_arp and
                lookup(string(arphelp.gl),v_list) > 0 no-lock), "Нет такой счет - карточки ARP!") skip
        v_crc label " Валюта" skip

        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа(можно дописать наимен-е филиала); F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
    WITH SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME frame2.

     Form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_dt label " Дт (коррсчет)" skip
        v_arp label  " Кт счет-карточка ARP (с проверкой счета ГК 186710)" format "X(20)" validate(can-find(first arphelp where arphelp.arp = v_arp and
                lookup(string(arphelp.gl),v_list) > 0 no-lock), "Нет такой счет - карточки ARP!") skip
        v_crc label " Валюта" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа; F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
    WITH SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME frame3.

    form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_arp label " Дт счет-карточка ARP (с проверкой счета ГК 185410, 185420, 185440)" format "X(20)"  validate(can-find(first arphelp where arphelp.arp = v_arp and
                lookup(string(arphelp.gl),v_list) > 0 no-lock),
                "Нет такой счет - карточки ARP!") skip
        v_kt label " Кт (коррсчет)" skip
        v_crc label " Валюта" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа; F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
    WITH SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME frame4.

    Form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_dt label " Дт (коррсчет)" skip
        v_arp label  " Кт счет-карточка ARP (с проверкой счета ГК 185410, 185420, 185440)" format "X(20)" validate(can-find(first arphelp where arphelp.arp = v_arp and
                lookup(string(arphelp.gl),v_list) > 0 no-lock),
                "Нет такой счет - карточки ARP!") skip
        v_crc label " Валюта" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа; F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
    WITH SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME frame5.

    form
        v-docid label " Документ " format "x(9)" skip
        v_sum LABEL " Сумма " format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_arp label " Дт (г/к)  " format "X(6)" validate(can-find(first arphelp where arphelp.arp = v_arp and
                lookup(string(arphelp.gl),v_list) > 0 no-lock), "Нет такой счет - карточки ARP!") skip
        v_kt label " Кт (коррсчет)" skip
        v_crc label " Валюта" skip
        v_code label " КОД" skip
        v_kbe label " КБе" skip
        v_knp label " КНП" skip
        v_oper label " Назначение платежа" help "Назначение платежа(можно дописать наимен-е филиала); F4-выход" skip
        v-ja label " Отправить на контроль?..........."   skip
    WITH SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME Frame6.

/*frame for help */
DEFINE QUERY q-help FOR arphelp.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY arphelp.arp label "Счет ARP " format "x(20)" arphelp.des label "Наименование   " format "x(29)"
       arphelp.gl label "Счет Г/К" format "999999" arphelp.crc label "Вл " format "z9"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 11 COLUMN 40 width 69 NO-BOX.


/*ON VALUE-CHANGED OF b-help DO:
    v_arp = arphelp.arp.
END.*/
/*----------*/


/*обработка вызова помощи*/
on end-error of b-help in frame f-help do:
    hide frame f-help.
   undo, return.
end.

on help of v_arp in frame frame1 do:
    run d_arphelp (v_list,output v_arp).
    displ v_arp with frame frame1.
end.


on help of v_arp in frame frame2 do:
    run k_arphelp (v_list,output v_arp).
    displ v_arp with frame frame2.
end.
on help of v_arp in frame frame3 do:
    run k_arphelp (v_list,output v_arp).
    displ v_arp with frame frame3.
end.
on help of v_arp in frame frame4 do:
    run d_arphelp (v_list,output v_arp).
    displ v_arp with frame frame4.
end.
on help of v_arp in frame frame5 do:
    run k_arphelp (v_list,output v_arp).
    displ v_arp with frame frame5.
end.
on help of v_arp in frame frame6 do:
    run d_arphelp (v_list,output v_arp).
    displ v_arp with frame frame6.
end.



/*выбор кнопки новый*/
on choose of b1 in frame a2 do:
 v-select = 0.
 hide frame frame1.
 hide frame frame2.
 hide frame frame3.
 hide frame frame4.
 hide frame frame5.
 hide frame frame6.
  run sel2 (" ВИДЫ  ОПЕРАЦИЙ ", " 1. Подкрепление филиалов | 2. Сдача наличных денег филиалами | 3. Пополнение счета в БЦК |
 4. Зачисление на картсчета в БЦК | 5. Возврат сумм не зачисл на к/сч в БЦК | 6. Комиссия БЦК | 7. ВЫХОД ", output v-select).
 assign v_crc = "1" v_code = "14" v_kbe = "14"   v_sum = 0 v_arp = "" v-ja = no.
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
            v_oper ="Подкрепление филиала ".
            v_list = "186010".
            v_kt = "KZ39470141051A002000".
            v_knp = "150".
            v_title = " ПОДКРЕПЛЕНИЕ ФИЛИАЛОВ ".
            v-tmpl = "uni0014".
            displ v-docid v_kt  v_crc  v_code  v_kbe v_knp v_oper v-ja with  frame frame1.
            v_ret = yes.
            do while v_ret:
                v_ret = no.
                update  v_sum v_arp  help "Счет -карточка ARP; F2- помощь; F4-выход" v_oper with frame frame1.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame1.
                update v-ja  with frame frame1.
                if  v_sum <= 0 then do:
                    message "Проверьте значение суммы!".
                    v_ret = yes.
                    v-ja = no.
                    hide message.
                end.
            end.
             /* формир v-param для trxgen.p */
            v-param = string(v_sum) + vdel + v_arp + vdel + v_kt + vdel +
            v_oper + vdel + vdel + vdel + vdel + "1" + vdel + "1" + vdel + "4" + vdel + "4" + vdel + v_knp.

            /* формир v-param1 для trxsim.p */
            v-param1 = string(v_sum) + vdel + v_arp + vdel + v_kt + vdel + v_oper + vdel + vdel + vdel + vdel.
        end.
        when 2 then do:
            v_oper ="Сдача наличных филиала ".
            v_dt = "KZ39470141051A002000".
            v_list = "286010".
            v_knp = "311".
            v_title = " СДАЧА НАЛИЧНЫХ ДЕНЕГ ФИЛИАЛАМИ ".
            v-tmpl = "uni0017".
            displ v-docid v_dt  v_crc v_code v_kbe v_knp v_oper v-ja with  frame frame2.
            v_ret = yes.
            do while v_ret:
                v_ret = no.
                update  v_sum v_arp help "Счет -карточка ARP; F2- помощь; F4-выход" v_oper  with frame frame2.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame2.
                update v-ja  with frame frame2.
                if v_sum <= 0 then do:
                    message "Проверьте значение суммы!".
                    v_ret = yes.
                    v-ja = no.
                    hide message.
                end.
            end.
            /* формир v-param для trxgen.p */
            v-param = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel + v_oper + vdel + "1" + vdel + "4" + vdel + v_knp.

            /* формир v-param1 для trxsim.p */
            v-param1 = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel + v_oper.
        end.
        when 3 then do:
            v_oper ="Пополнение счета ".
            v_dt = "KZ05470141052A000300".
            v_list = "186710".
            v_knp = "321".
            v_title = " ПОПОЛНЕНИЕ СЧЕТА В БЦК ".
            v-tmpl = "uni0017".
            displ v-docid v_dt v_crc v_code v_kbe v_knp v_oper v-ja with  frame frame3.
            v_ret = yes.
            do while v_ret:
                v_ret = no.
                update  v_sum v_arp help "Счет -карточка ARP; F2- помощь; F4-выход" v_oper with frame frame3.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame3.
                update v-ja  with frame frame3.
                if v_sum <= 0 then do:
                    message "Проверьте значение суммы!".
                    v_ret = yes.
                    v-ja = no.
                    hide message.
                end.
            end.
            /* формир v-param для trxgen.p */
            v-param = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel + v_oper + vdel + "1" + vdel + "4" + vdel + v_knp.
            /* формир v-param1 для trxsim.p */
            v-param1 = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel + v_oper.
        end.
        when 4 then do:
            v_oper ="".
            v_list = "185410,185420,185440".
            v_kt = "KZ05470141052A000300".
            v_knp = "311".
            v_title = " ЗАЧИСЛЕНИЕ НА КАРТСЧЕТА В БЦК ".
            v-tmpl = "uni0014".
            displ v-docid v_kt v_crc v_code v_kbe v_knp v_oper v-ja with  frame frame4.
            v_ret = yes.
            do while v_ret:
                v_ret = no.
                update  v_sum v_arp help "Счет -карточка ARP; F2- помощь; F4-выход" v_oper with frame frame4.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame4.
                update v-ja  with frame frame4.
                if  v_sum <= 0 then do:
                    message "Проверьте значение суммы!".
                    v_ret = yes.
                    v-ja = no.
                    hide message.
                end.
            end.
             /* формир v-param для trxgen.p */
            v-param = string(v_sum) + vdel + v_arp + vdel + v_kt + vdel +
            v_oper + vdel + vdel + vdel + vdel + "1" + vdel + "1" + vdel + "4" + vdel + "4" + vdel + v_knp.
            /* формир v-param1 для trxsim.p */
            v-param1 =string(v_sum) + vdel + v_arp + vdel + v_kt + vdel + v_oper + vdel + vdel + vdel + vdel.
        end.
       when 5 then do:
            v_oper = "".
            v_dt = "KZ05470141052A000300".
            v_list = "185410,185420,185440".
            v_knp = "150".
            v_title = " ВОЗВРАТ СУММ НЕ ЗАЧИСЛ НА К/СЧЕТА В БЦК ".
            v-tmpl = "uni0017".

            displ v-docid v_dt v_crc v_code v_kbe v_knp v_oper v-ja with  frame frame5.
            v_ret = yes.
            do while v_ret:
                v_ret = no.
                update  v_sum v_arp  help "Счет -карточка ARP; F2- помощь; F4-выход" v_oper with frame frame5.
                v_arp=caps(v_arp).
                displ v_arp with  frame frame5.
                update v-ja  with frame frame5.
                if  v_sum <= 0 then do:
                    message "Проверьте значение суммы!".
                    v_ret = yes.
                    v-ja = no.
                    hide message.
                end.
            end.
            /* формир v-param для trxgen.p */
            v-param = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel +
            v_oper + vdel + "1" + vdel + "4" + vdel + v_knp.
            /* формир v-param1 для trxsim.p */
            v-param1 = string(v_sum) + vdel + v_dt + vdel + v_arp + vdel + v_oper.
        end.
      when 6 then do:
        v_oper ="Комиссия банка за ".
        v_list = "560800".
        v_kt = "KZ05470141052A000300".
        v_knp = "840".
        v_title = " КОМИССИЯ БЦК ".
        v-tmpl = "uni0012".
        v_arp = "560800".
        displ v-docid v_arp v_kt v_crc v_code v_kbe v_knp v_oper v-ja with  frame frame6.
        v_ret = yes.
        do while v_ret:
            v_ret = no.
            update  v_sum v_oper with frame frame6.
            update v-ja  with frame frame6.

            if  v_sum <= 0 then do:
                message "Проверьте значение суммы!".
                v_ret = yes.
                v-ja = no.
                hide message.
            end.
        end.
            /* формир v-param для trxgen.p */
        v-param = string(v_sum) + vdel + v_crc + vdel + v_arp + vdel + v_kt + vdel +
        v_oper + vdel + "1" + vdel + "1" + vdel + v_knp.
        /* формир v-param1 для trxsim.p */
        v-param1 =string(v_sum) + vdel + v_crc + vdel + v_arp + vdel + v_kt + vdel + v_oper.
     end.
     when 7 then return.
   end case.
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
    v-docid1 = v-docid + "," + v_code + "," + v_kbe + "," + v_knp.
    v-rdt =  doch.rdt.
    v-rtim = doch.rtim.
    find first doch no-lock .
    run trxsim (v-docid1, v-tmpl, vdel, v-param1, 1, output rcode, output rdes, output vparr).
    /*run trxgen (v-tmpl, vdel, v-param, "ARP", v_dt, output rcode, output rdes, input-output s-jh).*/
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
  /*  hide frame &v-fr.*/
 hide frame frame1.
 hide frame frame2.
 hide frame frame3.
 hide frame frame4.
 hide frame frame5.
 hide frame frame6.
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

for each cmp no-lock:
   v_filial = cmp.name.
end.


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


procedure d_arphelp. /*справка по счетам arp для v_dt */
    def input parameter v_list as char.
    def output parameter v_arp as char.
    find first arphelp where lookup(string(arphelp.gl),v_list) > 0 no-lock no-error.
    if available arphelp then do:
        OPEN QUERY  q-help FOR EACH arphelp where  lookup(string(arphelp.gl),v_list) > 0 no-lock.
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

procedure k_arphelp. /*справка по счетам arp для v_kt */
    def input parameter v_list as char.
    def output parameter v_arp as char.
    find first arphelp where  lookup(string(arphelp.gl),v_list) > 0 no-lock no-error.
    if available arphelp then do:
        OPEN QUERY  q-help FOR EACH arphelp where lookup(string(arphelp.gl),v_list) > 0 no-lock.
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


