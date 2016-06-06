/* a_incas1.p
 * MODULE
        Инкассация
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
        07.12.2011 Luiza
 * CHANGES
        06/02/2012 - перекомпиляция в связи с изменениями a_finmon.i
        13/02/2012 Luiza  - добавила параметр для шаблона jou0055
        17.02.2012  Lyubov - добавила выбор символов кассплана согласно ТЗ № 1268
        07/03/2012 Luiza  - изменила передачу параметров при вызове printord
        11.03.2012 damir - добавил печать оперционного ордера, printvouord.p.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        04/05/2012 Luiza - проставление статуса 5
        07/05/2012 Luiza  - добавила процедуру defclparam
        14/05/2012 Luiza  - изменила Get_Nal и v-joudoc shared
        15/05/2012 Luiza - увеличила формат валюты до 2-х знаков
        12/06/2012 Luiza - при открытии документа отменила пересчет суммы комиссии
        18/06/2012 Luiza - расширила поле назначение платежа
        17/07/2012 Luiza - изменила шаблон, вместо jou0033 -> jou0052
        18/07/2012 Luiza - в jh.party запоминаем номер jou документа
        23/07/2012 Luiza - сохранение РНН
        25/07/2012 Luiza  - удалила строку заполнения поля joudoc.comvo
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
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
def  var v_dt as int  no-undo format "999999". /* Дт 100100*/
def  var v_kt as int no-undo format "999999". /* КТ 287051*/
def var v_crc as int  no-undo .  /* Валюта*/
def var vv-crc as char  no-undo .  /* Валюта*/
def var v-chet as char format "x(20)". /* счет клиента*/
def var v-cif as char format "x(6)". /* cif клиент*/
def var v_name as char format "x(30)". /*  клиент*/
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

/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek as integer no-undo.
def var v-crc_val as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK as char format "x(20)". /* счет ЭК*/
def var v-chEKk as char format "x(20)". /* счет ЭК for comis*/
/*------------------------------------*/

{findstr.i}
{kfm.i "new"}
{srvcheck.i}

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

{keyord.i}


    function getcrc returns char(cc as int).
        find first crc where crc.crc = cc no-lock no-error.
        if avail crc then return crc.code.
        else return "".
    end.

    function crc-conv returns decimal (sum as decimal, c1 as int, c2 as int).
    define buffer bcrc1 for crc.
    define buffer bcrc2 for crc.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
          return sum * bcrc1.rate[3] / bcrc2.rate[3].
       end.
       else return sum.
    end.

DEFINE QUERY q-tar FOR tarif2.

DEFINE BROWSE b-tar QUERY q-tar
       DISPLAY tarif2.str5 label "Код тарифа " format "x(3)" tarif2.pakalp label "Наименование   " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.

/*проверка банка*/
def buffer b-sysc for sysc.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

define button but label " "  NO-FOCUS.
s-ourbank = trim(sysc.chval).
def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label = " ИИН           :". else v-label = " РНН           :".


   form
        v-joudoc label " Документ       " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz" but skip
         v-chet  label " Счет клиента   "  format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet no-lock),"Неверный счет клиента") skip
       /* v-cif   label " Код клиента    "   format "x(6)" skip*/
        v_name  label " Клиент         "   format "x(60)" skip
        v-label no-label v_rnn  no-label format "x(12)" colon 17 skip
        v_crc   label " Валюта         " format ">9" validate(can-find(first crc where crc.crc = v_crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum   LABEL " Сумма          " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_tar   LABEL " Код тарифа     " format "x(5)" validate(((v_tar = "450" or v_tar = "431") and cif.type = "P" and v_crc = 1)
                                                   or ((v_tar = "459" or v_tar = "125" or v_tar = "431") and cif.type = "P" and v_crc <> 1)
                                                   or ((v_tar = "403" or v_tar = "436" or v_tar = "401" or v_tar = "302") and cif.type = "B" and v_crc = 1)
                                                   or (v_tar = "456" and cif.type = "B" and v_crc <> 1)
                                                   ,"Неверный код тарифа комиссии")  help " Введите код тарифа комиссии, F2 помощь"
        v_tarname no-label /*"ГК комиссии " */ colon 35  format "x(30)" skip
        v_sumk  LABEL " Сумма комиссии " validate((v_sumk > 0 and can-find(first tarif2 where tarif2.str5 = v_tar  and not (tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0) no-lock))
                                                    or (v_sumk = 0 and can-find(first tarif2 where tarif2.str5 = v_tar   and tarif2.proc = 0 and tarif2.min = 0 and tarif2.max = 0 no-lock))
                                                    or v_sumk = v-amt or (v_sumk = 0 and v_tar = "302"), "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v_code  label " КОД            " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label " КБе            "  skip
        v_knp   label " КНП            "  skip
        v_oper  label " Назначение платежа"  skip
        v_oper1  no-label  colon 20 skip
        v_oper2  no-label  colon 20 skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS column 1 ROW 7 TITLE v_title width 80 FRAME f_main.


/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/*  help for cif */


/*обработка F4*/
on choose of but in frame  f_main do:
end.

on help of v_crc in frame f_main do:
    run help-crc1.
end.
on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("INC"). else run a_help-joudoc1 ("NIC").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
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

on "END-ERROR" of frame f-tar do:
  hide frame f-tar no-pause.
end.

/*  help for cif */
on help of v-chet in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chet = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            v-chet = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-chet with frame f_main.
            return.
        end.
        displ  v-chet with frame f_main.
    end.
    else DELETE PROCEDURE phand.
end.
/*  help for cif */
/*on help of v-cif in frame f_main do:
    hide frame f-help.
    v-cif = "".
    run h-cif PERSISTENT SET phand.
    v-cif = frame-value.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        v_name  = cif.name.
        displ v-cif v_name with frame f_main.
    end.
    DELETE PROCEDURE phand.
end.*/

  on help of v_tar in frame f_main do:
  /* 450, 459, 125, 420, 431, 403, 436, 401, 456 */
        if cif.type = "P" and v_crc = 1 then  OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "450" or tarif2.str5 = "431") and tarif2.stat  = "r" no-lock.
        if cif.type = "P" and v_crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "459" or tarif2.str5 = "125" or tarif2.str5 = "431") and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v_crc = 1 then OPEN QUERY  q-tar FOR EACH tarif2 where (tarif2.str5 = "403" or tarif2.str5 = "436" or tarif2.str5 = "401") and tarif2.stat  = "r" no-lock.
        if cif.type = "B" and v_crc <> 1 then OPEN QUERY  q-tar FOR EACH tarif2 where tarif2.str5 = "456" and tarif2.stat  = "r" no-lock.
        ENABLE ALL WITH FRAME f-tar.
        wait-for return of frame f-tar
        FOCUS b-tar IN FRAME f-tar.
        v_tar = tarif2.str5.
        hide frame f-tar.
    displ v_tar with frame f_main.
  end.



if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    v_title = " ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        v_oper = "Зачисление инкассированной выручки ".
        v_oper1 = "".
        v_oper2 = "".
        displ v-joudoc format "x(10)" with frame f_main.
        v_kbe = "".
        v_knp = "311".
        v_sum = 0.
        v_sumk = 0.
        v-ja = yes.
        v-chet = "".
        v-cif = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    v_title = " ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if joudop.type <> "INC" and joudop.type <> "NIC" then do:
                        message substitute ("Документ не относится к типу зачисление инкассированной выручки ") view-as alert-box.
                        return.
                    end.
                    if v-ek = 1 and joudop.type = "NIC" then do:
                        message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
                        return.
                    end.
                    if v-ek = 2 and joudop.type = "INC" then do:
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
    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        if cif.bin = '' then do:
            if g-today < 01/01/13 then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
            else do:
                message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
                return.
            end.
        end.
        v_name  = trim(trim(cif.prefix) + " " + trim(cif.name)).
        if v-bin then v_rnn = cif.bin. else v_rnn = cif.jss.

        if cif.type = "P" then v-ec = "9".
        else do:
            find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
            if available sub-cod then v-ec = sub-cod.ccode.
            else do:
                message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
        if cif.geo = "021" then v_code = "1" + v-ec.
        else do:
            if   cif.geo = "022" then v_code = "2" + v-ec.
            else do:
                message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
    end.
    v_kbe = v_code.
    displ v_name v-label v_rnn  v_code v_kbe v_crc with frame f_main.
    pause 0.
    update v_sum  with frame f_main.
    update v_tar with frame f_main.

    find first tarif2 where tarif2.str5 = trim(v_tar)  and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        v_tarname = tarif2.pakalp.
        v_kt = tarif2.kont.
     /* вычисление суммы комиссии-----------------------------------*/
    /*v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev ("",input v_tar, input v_sum, input v_crc, input v_crc,"", output v-amt, output tproc, output pakal).*/
    v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
    run perev (v-chet,input v_tar, input v_sum, input v_crc, input v_crc,v-cif, output v-amt, output tproc, output pakal).
    v_sumk = v-amt.
    /*------------------------------------------------------------*/
        displ  v_tarname no-label vj-label format "x(35)" with frame f_main.
        repeat:
            update v_sumk  with frame f_main.
            if v-amt <> 0 and v_sumk = 0 then undo.
            leave.
        end.
        if keyfunction (lastkey) = "end-error" then undo.
    end.
    update  v_oper  v_oper1 v_oper2  v-ja with frame f_main.
    if v-ja then do:
        do transaction:
            if v-ek = 2 then do:
                find first crc where crc.crc = v_crc no-lock.
                v-crc_val = crc.code.
                for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                    if avail sub-cod then do:
                        v-chEK = arp.arp.
                    end.
                end.
                if v-chEK = '' then do:
                    message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                    undo, return.
                end.
                find first arp no-lock no-error.
             end.

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
            if v-ek = 2 then joudoc.dracctype = "4". else joudoc.dracctype = "1".
            if v-ek = 2 then joudoc.dracc = v-chEK. else joudoc.dracc = "".
            joudoc.drcur = v_crc.
            joudoc.cramt = v_sum.
            joudoc.cracctype = "2".
            joudoc.crcur = v_crc.
            joudoc.cracc = v-chet.
            joudoc.comcode = v_tar.
            joudoc.comamt = v_sumk.
            if v-ek = 2 then joudoc.comacctype = "4". else joudoc.comacctype = "1".
            if v-ek = 2 then joudoc.comacc = v-chEK. else joudoc.comacc = "".
            joudoc.comcur = v_crc.
            joudoc.info = v_name.
            joudoc.benname = v_name.
            joudoc.remark[1] = v_oper.
            joudoc.remark[2] = trim(v_oper1) +  " " + trim(v_oper2).
            joudoc.chk = 0.
            joudoc.perkod = v_rnn.
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-ek = 1 then joudop.type = "INC". else joudop.type = "NIC".
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
         end. /*end trans-n*/
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
        if joudop.type <> "INC" and joudop.type <> "NIC" then do:
            message substitute ("Документ не относится к типу зачисление инкассированной выручки ") view-as alert-box.
            return.
        end.
        if v-ek = 1 and joudop.type = "NIC" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box.
            return.
        end.
        if v-ek = 2 and joudop.type = "INC" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box.
            return.
        end.
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
    v-chet = joudoc.cracc.
    v_sum = joudoc.dramt.
    v_crc = joudoc.drcur.
    v_oper = joudoc.remark[1].
    v_oper1 = substring(joudoc.remark[2],1,55).
    v_oper2 = substring(joudoc.remark[2],56,55).
    v_tar = joudoc.comcode.
    v_sumk = joudoc.comamt.

    find first tarif2 where tarif2.str5 = trim(v_tar) and tarif2.stat  = "r" no-lock no-error.
    if avail tarif2 then do:
        v_tarname = tarif2.pakalp.
        v_kt = tarif2.kont.
    end.

    v_knp = "311".
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        v-cif = aaa.cif.
        v_crc = aaa.crc.
    end.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        v_name  = cif.name.
        if v-bin then v_rnn = cif.bin. else v_rnn = cif.jss.
        if cif.type = "P" then v-ec = "9".
        else do:
            find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
            if available sub-cod then v-ec = sub-cod.ccode.
            else do:
                message "В справочнике неверно заполнен сектор экономики клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
        if cif.geo = "021" then v_code = "1" + v-ec.
        else do:
            if   cif.geo = "022" then v_code = "2" + v-ec.
            else do:
                message "В справочнике неверно заполнен ГЕО-КОД клиента. Обратитесь к администратору" view-as alert-box.
                undo, return.
            end.
        end.
    end.
    v_kbe = v_code.
    v-ja = yes.
    v_title = " ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
    displ v-joudoc v_trx v-chet v_name v-label v_rnn v_crc v_kbe v_knp v_crc v_sum v_tar v_sumk v_tarname v_code v_kbe v_knp  v_oper v_oper1 v_oper2  with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        v_title = "  ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
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
    v_title = "  ЗАЧИСЛЕНИЕ ИНКАССИРОВАННОЙ ВЫРУЧКИ ".
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

    v_rez = v_code.
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

    /*EK 100500------------------------------------------------------*/
    if v-ek = 2 then do:
        find first crc where crc.crc = v_crc no-lock.
        v-crc_val = crc.code.
        for each arp where arp.gl = 100500 and arp.crc = v_crc no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK = arp.arp.
                /*v-sumarp = arp.dam[1] - arp.cam[1].*/
            end.
        end.
        if v-chEK = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.
        find first arp no-lock no-error.
        s-jh = 0.
        v-tmpl = "JOU0055".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + v-chEK + vdel + vv_arp + vdel + v_oper + " " + v_oper1 + " " + v_oper2 + vdel +
                    substring(v_code,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        v-tmpl = "jou0033".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + vv_arp + vdel + v-chet + vdel + v_oper + " " + v_oper1 + " " + v_oper2 +
                    vdel + substring(v_code,1,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        v-tmpl = "jou0026".
        v_oper = "Комиссия за: " + v_tarname.
     /* формир v-param для trxgen.p */
        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chet + vdel + string(v_kt) + vdel + v_oper.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        find first arp no-lock no-error.

        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        if jh.sts < 5 then jh.sts = 5.
        for each jl of jh:
            if jl.sts < 5 then jl.sts = 5.
        end.
        find current jh no-lock.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        find current joudoc no-lock no-error.
        run chgsts(m_sub, v-joudoc, "trx").

    end.
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
        v-tmpl = "jou0052".
        v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v_crc) + vdel + vv_arp + vdel + v-chet + vdel + v_oper + " " + v_oper1 + " " + v_oper2 +
                    vdel + substring(v_code,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1) + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        v-tmpl = "jou0026".
        v_oper = "Комиссия за: " + v_tarname.
     /* формир v-param для trxgen.p */
        v-param = v-joudoc + vdel + string(v_sumk) + vdel + string(v_crc) + vdel + v-chet + vdel + string(v_kt) + vdel + v_oper.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
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

    /*x0-cont1*/
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
        update v_sim with frame frm123.
        display '<Enter> - изменить,<F9> - добавить,<F10> - удалить,<F2>-помощь,<F4>-выход ' with row 22 centered no-box.
        jlsach.sim = v_sim.
        hide all no-pause.
        release jlsach.
    end.

    view frame f_main.

    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    find b-sysc where b-sysc.sysc eq "CASHGL500" no-lock no-error.
    v-cash = false. v-acc = false.
    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval then v-cash = true.
        /*if (jl.gl eq sysc.inval or jl.gl = b-sysc.inval) and jl.crc = 1 then do:*/ /* проставляем код кассплана  */
            /*create jlsach .
            jlsach.jh = s-jh.
            jlsach.amt = jl.dam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            jlsach.sim = 200 .
        end.*/
    end.
    /* копируем заполненные данные по ФМ в реальные таблицы*/
    if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.
    /**/
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.

    if avail joudoc then do:
        /*run vou_bankt(1, 1, joudoc.info).*/
        if v-noord = no then run vou_bankt(1, 1, joudoc.info).
        else run printord(s-jh,"").
    end.

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc.
    if locked joudoc then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = joudoc.jh.

    /* проверка свода кассы */
    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    if v-ek = 1 then find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    if v-ek = 2 then find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
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

