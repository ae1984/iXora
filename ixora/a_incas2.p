/* a_incas2.p
 * MODULE
        Межфилиальная инкассация
 * DESCRIPTION
        Инкассация
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        17/07/2012 Luiza
 * CHANGES
        18/07/2012 Luiza - в jh.party запоминаем номер jou документа
        19/07/2012 Luiza - перекомпиляция
        23/07/2012 Luiza - изменение текста назначения платежа
        25/07/2012 Luiza  - удалила строку заполнения поля joudoc.comvo
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        04/01/2013 Luiza - в filpayment добавила заполнение полей filpayment.namefrom filpayment.rnnfrom по ТЗ
                    переход на БИН
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        06/08/2013 Luiza - ТЗ 1997 Расширение поля «Код тарифа»
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
*/


{mainhead.i}

define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def shared var v_u as int no-undo.

def var v-tmpl as char no-undo.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var v-param1 as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
def  var v_sum as decimal no-undo. /* сумма*/
def  var v_sum_lim as decimal no-undo. /* сумма*/

def  var v_sumk as decimal no-undo. /* сумма комиссии*/
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def var v_arpt as char format "x(20)" no-undo. /* тразитный счет */
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def var v_crc as int  no-undo .  /* Валюта*/
def var vv-crc as char  no-undo .  /* Валюта*/
def var v-chet-f as char format "x(20)". /* счет клиента*/
def var v-cif-f as char format "x(6)". /* cif клиент*/
def var v_name as char format "x(60)". /*  клиент*/
def var v_pakalp as char format "x(30)". /*  комиссия*/
def var v-cif1 as char format "x(6)". /*  клиент*/
def var v-jss as char format "x(12)". /*  рнн клиента*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v_tar as char no-undo format "x(5)".  /* tarif*/
def var v_tarname as char no-undo format "x(30)".  /* tarif name*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_filial as char format "x(30)".   /* название филиала*/
def var vparr as char no-undo.
def shared var v-joudoc as char no-undo format "x(10)".
def shared var v-Get_Nal as logic.

def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var v-name as char.
def var v-templ as char.
define var v_codfrn as char init " ".
def var v-ec as char format "x(1)" no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-cash   as logical no-undo.
define variable v-acc   as logical no-undo.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def var v_rnn as char.
def var v-label as char.
def var vv_arp as char.
def var v_sim as int.
def var v_des as char.
def var v-mes as char.
def var v_bank as char.
def var v-bankname as char.
def var v-bankourname as char.
def var v-st as int.  /* признак успешного поиска счета  */

/* for finmon */
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl for jl.
def buffer bb-jl for jl.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-num as inte no-undo.
def var v-operId as integer no-undo.
def var v-kfm as logi no-undo init no.
def var v-numprt as char no-undo.
def var v-mess as integer no-undo.
def var v-dtbth as date no-undo.
def var v-bdt as char no-undo.
def var v-regdt as date no-undo.
def var v-rnn as char no-undo.
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country2 as char.
def var famlist as char init "".
def var v_rnnp as char.
def var v-labelp as char format "x(22)".
def  var  v_docwho as char no-undo.
def  var v_docdt as date no-undo.
def  var v-bdt1 as date no-undo.
def var v_rez as char.
def  var v_countr as char no-undo format "x(2)".
def  var v_countr1 as char no-undo format "x(2)".
def  var v_lname1 as char no-undo format "x(20)".
def  var v_name1 as char no-undo format "x(20)".
def  var v_mname1 as char no-undo format "x(20)".
def var v_addr as char.
def var v_tel as char.
def var v_public as char.
def var v_doctype as char.
def var v-cifmin as char.
def  var v-bplace as char no-undo.
def var v-knpval as char no-undo.
def new shared var v_doc as char format "x(10)" no-undo.
def  var v_lname as char no-undo format "x(20)".
def  var v_mname as char no-undo format "x(20)".
def  var v_doc_num as char no-undo.
def  var v-mail as char.

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК for comis*/
/*------------------------------------*/

def var v-oplcom1 as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v-oplcom as char. /*  вид оплаты комиссии 1 - с кассы 2 - со счета)*/
def var v-chetk as char.
def var v_trxcom as int.

{findstr.i}
{kfm.i "new"}
{srvcheck.i}
{keyord.i}

    function getcrc returns char(cc as int).
        find first crc where crc.crc = cc no-lock no-error.
        if avail crc then return crc.code.
        else return "".
    end.

    function crc-conv returns decimal (sum as decimal, c1 as int, c2 as int).
        define buffer bcrc1 for crc.
        define buffer bcrc2 for crc.
        if c1 <> c2 then do:
          find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[3] / bcrc2.rate[3].
       end.
       else return sum.
    end.

/*проверка банка*/
def buffer b-sysc for sysc.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).
find first txb where txb.bank = s-ourbank no-lock no-error.
v-bankourname = txb.info.

define button but label " "  NO-FOCUS.
s-ourbank = trim(sysc.chval).
def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label = " ИИН           :". else v-label = " РНН           :".


   form
        v-joudoc label " Документ       " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz" but skip
        v_bank   label " ФИЛИАЛ         "  format "x(6)" validate(can-find(first txb where txb.bank = v_bank no-lock),"Неверный код банк!") help " Введите код банка (F2 - поиск)"
        v-bankname no-label             colon 30  format "x(45)"  skip
        v_sum    LABEL " Сумма          " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v-cif-f  label " КЛИЕНТ         " format "x(6)" help " Введите код клиента (F2 - поиск)"   validate (v-cif-f ne "", " Введите код клиента ! ")
        v_name  no-label                colon 30 format "x(60)" skip
        v-label no-label v_rnn  no-label format "x(12)" colon 17 skip
        v-chet-f  label " Счет клиента   "  format "x(20)" /*validate(can-find(first aaa where aaa.aaa = v-chet-f no-lock),"Неверный счет клиента")*/ skip
        v_crc   label " Валюта         " format ">9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_tar   LABEL " Код тарифа     " format "x(5)"
        v_tarname no-label             colon 30  format "x(45)" skip
        v_sumk  label " Сумма комиссии " format ">>>,>>>,>>>,>>9.99" validate(v_sumk > 0, "Hеверное значение суммы")  help " Введите сумму комиссии" skip
        v-oplcom1 label " Оплата комиссии" format "x(15)" skip
        v-chetk   label " Счет комиссии  " format "x(20)"   v_trxcom label "    Транз комиссии " format "zzzzzzzzz" skip(1)
        v_code  label " КОД            " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label " КБе            "  skip
        v_knp   label " КНП            "  skip
        v_oper  label " Назначение платежа"  skip
        v_oper1  no-label  colon 20 skip
        v_oper2  no-label  colon 20 skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS column 2 ROW 7 TITLE v_title width 95 FRAME f_main.


on help of v_bank in frame f_main do:
{itemlist.i
       &file = "txb"
       &where = "txb.bank begins 'txb'"
       &form = "txb.bank txb.info form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "txb.bank txb.info"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
  v_bank = frame-value.
  displ v_bank with frame f_main.
end.


/*обработка F4*/
on choose of but in frame  f_main do:
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("INC2"). else run a_help-joudoc1 ("NIC2").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  return.
end.

/*lyubov*/
    form
      jl.ln label '#' format 'zzz'
      vv-crc label 'Валюта'
      jlsach.amt label ' Сумма '
      v_sim label 'Код' format '999' validate((v_sim = 010 or v_sim = 070 or v_sim = 100), "Неверный символ кассплана")
      v_des label ' Описание        ' format 'x(38)'
      with centered 10 down frame frm123.

DEFINE QUERY q-sc FOR cashpl.

DEFINE BROWSE b-sim QUERY q-sc
       DISPLAY cashpl.sim label "Символ " format "999" cashpl.des label "Описание" format "x(45)"
       WITH  15 DOWN.
DEFINE FRAME f-sim b-sim  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

on help of v_sim in frame frm123 do:
/* 010, 070, 090, 100 */
    OPEN QUERY  q-sc FOR EACH cashpl where (lookup(string(cashpl.sim), "10,70,100") > 0) and cashpl.act no-lock.
    ENABLE ALL WITH FRAME f-sim.
    wait-for return of frame f-sim
    FOCUS b-sim IN FRAME f-sim.
    v_sim = cashpl.sim.
    v_des = cashpl.des.
    hide frame f-sim.
    displ v_sim v_des with frame frm123.
end.
/*lyubov*/


if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " ЗАЧИСЛЕНИЕ МЕЖФИЛИАЛЬНОЙ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "".
        v_oper1 = "".
        v_oper2 = "".
        displ v-joudoc format "x(10)" with frame f_main.
        v_kbe = "".
        v_knp = "311".
        v_sum = 0.
        v_sumk = 0.
        v-ja = yes.
        v-chet-f = "".
        v-cif-f = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = " ЗАЧИСЛЕНИЕ МЕЖФИЛИАЛЬНОЙ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "INC2" and joudop.type <> "NIC2" then do:
                        message substitute ("Документ не относится к типу зачисление инкассированной выручки в другой филиал") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "NIC2" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "INC2" then do:
                        message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
                        return.
                    end.
                end.
                if joudoc.jh > 1 then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if joudoc.who ne g-ofc then do:
                    message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc   v_knp v_oper v_oper1 v_oper2  with  frame f_main.
    update v_bank with frame f_main.
    if v_bank = s-ourbank then do:
        message "Клиент вашего филиала! " view-as alert-box.
        return.
    end.

    find first txb where txb.bank = v_bank no-lock no-error.
    if not avail txb then return.
    v-bankname = txb.info.
    displ v-bankname with frame f_main.
    update v_sum  with frame f_main.
    v_code = "14".
    v_knp = "311".
    v_tar = "403".
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
    update v-cif-f  with frame f_main.
    run check_ul_txb(v-cif-f).
    /*if connected ("txb") then disconnect "txb".*/

    run h-chet-f(v-cif-f, v_tar,v_sum, output v-chet-f, output v_crc, output v_name, output v_kbe, output v_rnn, output v_tarname,
        output v_sumk, output v_kt, output v-st, output v-mail).
    if connected ("txb") then disconnect "txb".
    if v-st = 0 then return.
    displ v-chet-f v_name v_crc v-label v_rnn  v_code v_kbe v_knp v_tar v_tarname v_sumk vj-label no-label format "x(35)" with frame f_main.
    update v_tar with frame f_main.

    repeat:
        update v_sumk  with frame f_main.
        if v_sumk = 0 and v_tar <> "302" then return.
        leave.
    end.
    if keyfunction (lastkey) = "end-error" then return.

    run chk-com-f("com",v-cif-f,v-chet-f,v_sum,v_sumk,output v-st,output v-chetk,output v-oplcom).
    if v-st = 0 then return.
    if v-oplcom = "1" then v-oplcom1 = "с кассы".
    if v-oplcom = "2" then v-oplcom1 = "со счета".
    displ v-oplcom1 v-chetk with frame f_main.
    v_oper = "Инкассированная наличность("  + v-bankourname + ")".
    update  v_oper  v_oper1 v_oper2  v-ja with frame f_main.
    if v-ja then do:

        if new_document then do:
            create joudoc.
            joudoc.docnum = v-joudoc.
            create joudop.
            joudop.docnum = v-joudoc.
        end.
        else do:
            find joudoc where joudoc.docnum = v-joudoc exclusive-lock.
            find joudop where joudop.docnum = v-joudoc exclusive-lock.
        end.
        joudoc.who = g-ofc.
        joudoc.whn = g-today.
        joudoc.tim = time.
        joudoc.dramt = v_sum.
        joudoc.dracctype = "1".
        joudoc.dracc = "".
        joudoc.drcur = v_crc.
        joudoc.cramt = v_sum.
        joudoc.cracctype = "2".
        joudoc.crcur = v_crc.
        joudoc.cracc = v-chet-f.
        joudoc.comcode = v_tar.
        joudoc.comamt = v_sumk.
        joudoc.comacctype = v-oplcom.
        joudoc.comacc = v-chetk.
        joudoc.comcur = v_crc.
        joudoc.benname = v_name .
        joudoc.remark[1] = v_oper.
        joudoc.remark[2] = trim(v_oper1) +  " " + trim(v_oper2).
        joudoc.chk = 0.
        joudoc.perkod = v_rnn.
        find current joudoc no-lock no-error.
        joudop.who = g-ofc.
        joudop.whn = g-today.
        joudop.tim = time.
        joudop.lname = v_bank + "," + v-bankname + "," + v_rnn + "," + v-cif-f.
        joudop.mname = v_tarname.
        joudop.fname = string(v_kt).
        joudop.rez1 = v_code + "," + v_kbe + "," + v_knp.
        joudop.doc1 = v-mail.

        if v-ek = 1 then joudop.type = "INC2". else joudop.type = "NIC2".
        find current joudop no-lock no-error.
        displ v-joudoc with frame f_main.
        run chgsts("JOU", v-joudoc, "new").
        run chgsts("JOU", v-joudoc, "bap").
        MESSAGE "Необходим контроль в п.м. 2.4.1.1! 'Контроль документов'!"  view-as alert-box.
        find first crc where crc.crc = v_crc no-lock.
        v-crc_val = crc.code.
        for each sendod no-lock.
            run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
            "Добрый день!\n\n Необходимо отконтролировать зачисление инкассированной выручки в другой филиал \n Сумма: " + string(v_sum) +
            "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
            string(time,"HH:MM"), "1", "","" ).
        end.
        hide all.
        view frame f_main.
    end.
end procedure.


procedure view_doc:
    update v-joudoc help "Введите номер документа, F2-помощь" with frame f_main.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(v-joudoc) = "" then undo, return.
    displ v-joudoc with frame f_main.

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, return.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "INC2" and joudop.type <> "NIC2" then do:
            message substitute ("Документ не относится к типу зачисление инкассированной выручки в другой филиал") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "NIC2" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "INC2" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            return.
        end.
    end.
    else do:
        message substitute ("Документ создан в другм пункте меню ") view-as alert-box.
        return.
    end.
    if joudoc.jh > 1 and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v_trx = joudoc.jh.
    v-chet-f = joudoc.cracc.
    v_sum = joudoc.dramt.
    v_crc = joudoc.drcur.
    v_oper = joudoc.remark[1].
    v_oper1 = substring(joudoc.remark[2],1,55).
    v_oper2 = substring(joudoc.remark[2],56,55).
    v_tar = joudoc.comcode.
    v_sumk = joudoc.comamt.
    v-chetk = joudoc.comacc.
    v_name = joudoc.benname.
    v_rnn = joudoc.perkod.
    v_bank = entry(1,joudop.lname).
    v-bankname = entry(2,joudop.lname).
    v-cif-f = entry(4,joudop.lname).
    v_tarname = joudop.mname.
    v_kt = int(joudop.fname).
    v_code = entry(1,joudop.rez1).
    v_kbe = entry(2,joudop.rez1).
    v_knp = entry(3,joudop.rez1).
    v-mail = joudop.doc1.
    v-oplcom = joudoc.comacctype.
    if v-oplcom = "1" then v-oplcom1 = "с кассы".
    if v-oplcom = "2" then v-oplcom1 = "со счета".
    /* ищем транзакцию комиссии */
    if v_trx > 1 and v-oplcom = "2" then do:
        find first filpayment where filpayment.jh = v_trx no-lock no-error.
        if available filpayment and filpayment.jhcom > 1 then do:
            v_trxcom = filpayment.jhcom.
            displ v_trxcom with frame f_main.
        end.
    end.

    v-ja = yes.
    v_title = " ЗАЧИСЛЕНИЕ МЕЖФИЛИАЛЬНОЙ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    displ v-joudoc v_trx v_bank v-bankname v-cif-f v-chet-f v_name v-label v_rnn v_crc v_kbe v_knp v_crc v_sum v_tar v_sumk v_tarname v-oplcom1 v-chetk v_code v_kbe v_knp  v_oper v_oper1 v_oper2  with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = "  ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ В ДРУГОЙ ФИЛИАЛ ".
        run view_doc.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if joudoc.who ne g-ofc then do:
               message substitute (
                  "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                find joudoc where joudoc.docnum = v-joudoc no-error.
                if available joudoc then delete joudoc.
                find first joudoc no-lock no-error.
                for each substs where substs.sub = "jou" and  substs.acc = v-joudoc.
                    delete substs.
                end.
                find first substs no-lock no-error.
                find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.
                v-joudoc = "".
            end.
        end.
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide message.
        hide frame f_main.
    end.
    return.
end procedure.

procedure Create_transaction:
    vj-label = " Выполнить транзакцию?..................".
    v_title = "  ЗАЧИСЛЕНИЕ МЕЖФИЛИАЛЬНОЙ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    run view_doc.
    if keyfunction (lastkey) = "end-error" then undo, return.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.

    find first cursts no-lock no-error.
    release cursts.
    find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-lock no-error.
    if available cursts then do:
        if cursts.sts <> "con" then do:
            message "Документ должен пройти контроль в п.м. 2.4.1.1! 'Контроль документов'!" view-as alert-box.
            undo, return.
        end.
    end.
    else do:
        message "Не найден статус документа, обратитесь к разработчику!" view-as alert-box.
        undo, return.
    end.

    v_rez = v_kbe.
    v-knpval = v_knp.
    v_doc = v-joudoc.
    enable but with frame f_main.
    pause 0.
    {a_finmon.i}
    disable but with frame f_main.
    if keyfunction (lastkey) = "end-error" then do:
        message "Транзакция прервана!" view-as alert-box.
        return.
    end.
    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.

    find last arp where arp.gl = 287051 and arp.crc = v_crc and length(arp.arp) >= 20 no-lock no-error.
    if not available arp then do:
        message "Не найден АРП счет для инкассированной выручки!" view-as alert-box.
        return.
    end.
    vv_arp = arp.arp.
    /* транзитный арп счет для соответствующей валюты */
    if substring(v_kbe,2,1) = '9' then  do:
        find sysc where sysc.sysc = "transf" no-lock no-error.
        if not avail sysc or sysc.chval = "" then do:
           display " В настройках нет записи transf  !!".   pause.   return.
        end.
    end.
    else  do:
        find sysc where sysc.sysc = "transu" no-lock no-error.
        if not avail sysc or sysc.chval = "" then do:
           display " В настройках нет записи transu  !!".   pause.   return.
        end.
    end.
    v_arpt = trim(entry(v_crc,trim(sysc.chval))).  /* транзитный арп счет для соответствующей валюты  */
    find first arp no-lock no-error.
    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja then undo, return.
    /* проставление вида документа */
    find first sub-cod where sub-cod.sub = 'jou' and sub-cod.acc = v-joudoc and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.sub = 'jou'.
        sub-cod.acc = v-joudoc.
        sub-cod.d-cod = 'pdoctng'.
        sub-cod.ccode = "12" /* Платежный ордер */.
        sub-cod.rdt = g-today.
    end.

        s-jh = 0.

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        v-tmpl = "jou0027".
     /* формир v-param для trxgen.p */
        v-param = /*v-joudoc + vdel + */ string(v_sum) + vdel + string(v_crc) + vdel + vv_arp + vdel + v_oper + " " + v_oper1 + " " + v_oper2 + vdel +
                    substring(v_code,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1) + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        v-tmpl = "jou0040".
        v-param = string(v_sum) + vdel + string(v_crc) + vdel + vv_arp + vdel + v_arpt + vdel + v_oper + " " + v_oper1 + " " + v_oper2 +
                    vdel + substring(v_code,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        if v-oplcom = "1" and v_sumk <> 0 then  do: /* комиссия с кассы */
            v-tmpl = "jou0025".
            v-param = v-joudoc + vdel + string(v_sumk) + vdel + "1" + vdel + string(v_kt) + vdel + "Комиссия " + v_tarname + vdel +
                                 substr(v_kbe,1,1) + vdel + substring(v_kbe,2,1).
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        run chgsts(m_sub, v-joudoc, "trx").
        pause 1 no-message.
        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        find current jh no-lock.

        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.

        run chgsts("jou", v-joudoc, "cas").

        if v-noord = yes then run printvouord(2).
    end.


    view frame f_main.
    create filpayment.
    filpayment.id = 'fil' + string(next-value(filp)).
    filpayment.type = 'add'.
    filpayment.bankfrom = s-ourbank.
    filpayment.bankto = v_bank.
    filpayment.iik = v-chet-f.
    filpayment.cif = v-cif-f.
    filpayment.sts = 'A'.
    filpayment.name = v_name.
    filpayment.rnnto = v_rnn.
    filpayment.crc = v_crc.
    filpayment.amount = v_sum.
    filpayment.arp = trim(entry(v_crc,trim(sysc.chval))). /* транзитный арп счет для соответствующей валюты  */
    filpayment.info[10] = trim(entry(1,trim(sysc.chval))). /* транзитный арп счет для тенге */
    if substring(v_kbe,2,1) = "9" then filpayment.info[9] = "P". /* тип клиента, если 'B' юр. лицо, иначе физ лицо */
    else filpayment.info[9] = "B".
    filpayment.kod = v_code.
    filpayment.kbe = v_kbe.
    filpayment.knp = v_knp.
    filpayment.info[1] = v_oper + " " + v_oper1 + " " + v_oper2.
    filpayment.info[2] = v_tar.
    filpayment.info[3] = v-mail.
    filpayment.info[4] = "".
    filpayment.rdt = today.
    filpayment.whn = g-today.
    filpayment.who = g-ofc.
    filpayment.tim = time.
    filpayment.rem[2] = v-oplcom . /* сохраняем признак оплаты 1- c кассы , 2 - со счета  */
    filpayment.jou = v-joudoc.
    filpayment.jh = s-jh.
    filpayment.amountcom = v_sumk.
    filpayment.info[8] = v-chetk + "," + string(v_crc). /* запоминаем счет с которого снять комиссию и код валюты */
    filpayment.info[7] = v_tarname. /* запоминаем описание тарифа */
    find first cmp no-lock no-error.
    if available cmp then filpayment.namefrom = cmp.name.
    find sysc where sysc.sysc = 'bnkbin' no-lock no-error.
    if available sysc then filpayment.rnnfrom = trim(sysc.chval).
    if v-oplcom = "2" then filpayment.stscom = "new1". /* внеш платеж для комиссии сформир-тся в x1-cash.p  */
    find first filpayment no-lock no-error.


    for each jl where jl.jh = s-jh and jl.crc = 1 and (jl.gl = 100100 or jl.gl = 100500) no-lock:
        create jlsach .
        jlsach.jh = s-jh.
        if jl.dc = "c" then jlsach.amt = jl.cam .
                       else jlsach.amt = jl.dam .
        jlsach.ln = jl.ln .
        jlsach.lnln = 1.
        vv-crc = getcrc(jl.crc).
        hide all no-pause.
        displ jl.ln vv-crc jlsach.amt with frame frm123.
        update v_sim with  frame frm123.
        display '<Enter> - изменить,<F9> - добавить,<F10> - удалить,<F2>-помощь,<F4>-выход ' with row 22 centered no-box.
        jlsach.sim = v_sim.
        hide all no-pause.
        release jlsach.
    end.

    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
    end.
    /**/
    view frame f_main.
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.

    if avail joudoc then do:
        if v-noord = no then run vou_bankt(1, 1, joudoc.info).
        else run printord(s-jh,"").
    end.

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc.
    if locked joudoc then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        undo, return.
    end.
    s-jh = joudoc.jh.

    find first substs where substs.sub = "jou" and substs.acc = v-joudoc and substs.sts  = "rdy" no-lock no-error.
    /*find first jh where jh.jh eq joudoc.jh no-lock no-error.*/

    if available substs /*and available jh and (jh.sts = 6 or cursts.sts = "rdy")*/ then do:
        /*message "Внешние платежи уже сформированы, ~nудаление транзакции выполните в п.м 2.6.8" view-as alert-box.*/
        message "Внешние платежи уже сформированы, ~nудаление транзакции в п.м запрещено" view-as alert-box.
        return.
    end.


    /*find first txb where txb.bank = v_bank no-lock no-error.
    if not avail txb then return.
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
    run chk-com-f("sum",v-cif-f,v-chet-f,v_sum,v_sumk,output v-st,output v-chetk,output v-oplcom).
    if v-st = 0 then do:
        if connected ("txb") then disconnect "txb".
        return.
    end.
    if connected ("txb") then disconnect "txb".*/

    /* проверка свода кассы */
    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    find cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя.".
            pause 3.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            undo, return.
        end.
    end.
    /* ------------storno ?????????-----------------*/
    do transaction on error undo, return:
        quest = false.
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then undo, return.
             /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        assign cashofc.whn = jl.jdt
                               cashofc.ofc = jl.teller
                               cashofc.crc = jl.crc
                               cashofc.who = g-ofc
                               cashofc.sts = 2
                               cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.
            /* ------------------------------------------------------------------*/
            /* sasco - снятие блокировки с суммы */
            /* (которая для контроля старшим менеджером в 2.13) */
            run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).

            /* 13.10.2003 nadejda - поискать эту транзакцию в списке блокированных сумм валютного контроля и убрать пометку о зачислении суммы на счет клиента */
            run jou42-blkdel (joudoc.jh).

            run trxstor(input joudoc.jh, input 6, output s-jh, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            run x-jlvo.
        end.
        /* ------------storno ?????????-----------------*/
        else do:
            message "Вы уверены ?" update quest.
            if not quest then undo, return.

            v-sts = jh.sts.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                 if rcode = 50 then do:
                    hide all.
                    view frame f_main.
                end.
                message rdes.
                if rcode = 50 then do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    return.
                end.
                else undo, return.
            end.

           /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        cashofc.whn = jl.jdt.
                        cashofc.ofc = jl.teller.
                        cashofc.crc = jl.crc.
                        cashofc.sts = 2.
                        cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.

        end.

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.

    end. /* transaction */

    do transaction:
        run comm-dj(joudoc.docnum).

        /* sasco - удалить записи о контроле для arpcon */
        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        /* найдем arpcon со счетом по дебету */
        find arpcon where arpcon.arp = joudoc.dracc and
                          arpcon.sub = 'jou' and
                          arpcon.txb = sysc.chval
                          no-lock no-error.
        if avail arpcon then do:
            /* удалим статус контроля из истории платежа */
            for each substs where substs.sub = 'jou' and
                                  substs.acc = joudoc.docnum and
                                  substs.sts = arpcon.new-sts:
                delete substs.
            end.

            find cursts where cursts.sub = 'jou' and cursts.acc = joudoc.docnum no-error.

            if avail cursts then do:
               find last substs where substs.sub = 'jou' and substs.acc = joudoc.docnum no-lock no-error.
               assign cursts.sts = substs.sts.
            end.
        end.
    end. /* transaction */
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    release joudoc.
    run chgsts("JOU", v-joudoc, "new").
    message "Транзакция удалена." view-as alert-box.
end procedure.

procedure Screen_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        run vou_word (2, 1, joudoc.info).
    end. /* transaction */
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        if v-noord = no then run vou_bankt(2, 1, joudoc.info).
        else run printord(s-jh,"").
    end. /* transaction */
end procedure.

procedure Get_Nal:
    run view_doc.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh < 1 or joudoc.jh = ? then do:
        message "Транзакция не проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.
    find cursts where cursts.acc = v-joudoc and cursts.sub = "jou" no-lock no-error.
    if avail cursts and cursts.sts = "rdy" then do :
      message "Проводка уже отштампована " view-as alert-box.
      undo, return.
    end.
    v-Get_Nal = yes.

    /*vj-label  = " Выполнить прием наличных?..................".
    s-jh = joudoc.jh.
    enable but with frame f_main.
    pause 0.
    def var v-errmsg as char init "".
    def var v-rez as logic init false.
    run csstampf(s-jh, v-nomer, output v-errmsg, output v-rez ).
    view frame f_main.
    disable but with frame f_main.
    if  v-errmsg <> "" or not v-rez then do:
        message  v-errmsg view-as alert-box error.
        undo, return.
    end.
    run chgsts(m_sub, v-joudoc, "rdy").
    message "Проводка отштампована " view-as alert-box.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").*/
end procedure.

procedure create_100100:
    run a_create100100(v-joudoc).
end.

procedure defclparam.

    v-cltype = ''.
    v-res = ''.
    v-res2 = ''.
    v-publicf = ''.
    v-FIO1U = ''.
    v-OKED = ''.
    v-prtOKPO = ''.
    v-prtEmail = ''.
    v-prtPhone = ''.
    v-prtFLNam = ''.
    v-prtFFNam = ''.
    v-prtFMNam = ''.
    v-clnameU = ''.
    v-prtUD = ''.
    v-prtUdN = ''.
    v-prtUdIs = ''.
    v-prtUdDt = ''.
    v-bdt = ''.
    v-bplace = ''.

    if cif.type = 'B' then do:
        if cif.cgr <> 403 then v-cltype = '01'.
        if cif.cgr = 403 then v-cltype = '03'.
    end.
    else v-cltype = '02'.

    if cif.geo = '021' then do:
        v-res = 'KZ'.
        v-res2 = '1'.
    end.
    else do:
        v-res2 = '0'.
        if num-entries(cif.addr[1]) = 7 then do:
            v-country2 = entry(1,cif.addr[1]).
            if num-entries(v-country2,'(') = 2 then v-res = substr(entry(2,v-country2,'('),1,2).
        end.
    end.
    find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
    if avail cif-mail then v-prtEmail = cif-mail.mail.
    v-prtPhone = cif.tel.

    if v-cltype = '01' then do:
        v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name).
        v-prtOKPO = cif.ssn.
    end.
    else v-clnameU = ''.

    if v-cltype = '02' or v-cltype = '03'then do:
        if v-cltype = '02' then do:
            if num-entries(trim(cif.name),' ') > 0 then v-prtFLNam = entry(1,trim(cif.name),' ').
            if num-entries(trim(cif.name),' ') >= 2 then v-prtFFNam = entry(2,trim(cif.name),' ').

            if num-entries(trim(cif.name),' ') >= 3 then v-prtFMNam = entry(3,trim(cif.name),' ').
        end.
        else do:
            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                if num-entries(trim(sub-cod.rcode),' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
            end.
        end.

        if cif.geo = '021' then v-prtUD = '01'.
        else v-prtUD = '11'.

        if num-entries(cif.pss,' ') > 1 then v-prtUdN = entry(1,cif.pss,' ').
        else v-prtUdN = cif.pss.

        if num-entries(cif.pss,' ') >= 2 then v-prtUdDt = entry(2,cif.pss,' ').
        if num-entries(cif.pss,' ') >= 3 then v-prtUdIs = entry(3,cif.pss,' ').
        if num-entries(cif.pss,' ') > 3 then v-prtUdIs = entry(3,cif.pss,' ') + ' ' + entry(4,cif.pss,' ').

        find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.

        v-bdt = string(cif.expdt,'99/99/9999').
        v-bplace = cif.bplace.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.

    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

