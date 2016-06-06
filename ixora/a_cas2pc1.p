/* a_cas2pc1.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
       Расход.операция по ПК других банков
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-2-2
 * AUTHOR
        13/02/2013 id00800
 * CHANGES
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza -  ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        10/06/2013 Luiza - ТЗ 1727 проверка на 30 млн тенге при расходе со счета клиента наличными
        10/07/2013 Luiza -  ТЗ 1948 курс обмена валюты сохраняем в поле brate
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
        29/10/2013 Luiza - ТЗ 2161 Дополнительное поле «Основание»
 */

def input param new_document as logi.
def shared var v_u    as int no-undo.
def shared var g-ofc  as char.

def var m_sub     as char no-undo init "jou".
def var v-tmpl    as char no-undo.
def var vdel      as char no-undo init "^".
def var v-param   as char no-undo.
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
def var v_title   as char no-undo init " Расход.операция по ПК других банков ".
def var v_sum     as deci no-undo. /* сумма*/
def var v_sumtotal     as deci no-undo. /* сумма*/
def var v-crc     as int  no-undo .  /* Валюта*/
def var v-sumcom     as deci no-undo. /* сумма комиссии*/
def var v-sumcomKZT     as deci no-undo. /* сумма комиссии в тенге*/
def var v-crccom     as int  no-undo .  /* Валюта комиссии*/
def var v-arp     as char format "x(20)". /* счет arp */
def var v-arpcom     as char format "x(20)". /* счет arp комиссии */
def var v-cif     as char format "x(6)". /* cif клиент*/
def var v_lname   as char format "x(30)". /*  клиент*/
def var v-jss     as char format "x(12)". /*  рнн клиента*/
def var v_code    as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe     as char  no-undo format "x(2)".  /* КБе*/
def var v_knp     as char no-undo format "x(3)" init '321'.  /* КНП*/
def var v-ja      as logi no-undo format "Да/Нет" .
def var v_oper    as char no-undo format "x(70)".  /* Назначение платежа*/
def var v_oper1   as char no-undo format "x(85)".  /* Назначение платежа*/
def var v_oper2   as char no-undo format "x(85)".  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
def var v_docwho  as char no-undo.
def var v_docdt   as date no-undo.
def var v-rnn     as char no-undo.
def new shared var v-num     as int  no-undo.
def     shared var v-joudoc  as char no-undo format "x(10)".
def     shared var v-Get_Nal as logi.
def var v-cur as logic no-undo.

def var v_name     as char no-undo.
def var v_trx      as int  no-undo.
def var vj-label   as char no-undo.
def var v-cash     as logi no-undo.
def var v-acc      as logi no-undo.
def var v-sts      like jh.sts  no-undo.
def var quest      as logi no-undo format "да/нет".
def  var v_sum_lim as deci no-undo. /* сумма*/
def var v-arpname  as char no-undo.
def  var v-bplace  as char no-undo.
def  var v-tar     as char no-undo.
def new shared variable s-jh like jh.jh.
def new shared var v_doc as char format "x(10)" no-undo.
define new shared variable vrat  as decimal decimals 4.

/* for finmon */
def var v-monamt  as deci no-undo.
def var v-monamt2 as deci no-undo.
def var v-oper     as char no-undo.
def var v-cltype   as char no-undo.
def var v-res      as char no-undo.
def var v-res2     as char no-undo.
def var v-FIO1U    as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED     as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-clnameU  as char no-undo.
def var v-prtUD    as char no-undo.
def var v-prtUdN   as char no-undo.
def var v-prtUdIs  as char no-undo.
def var v-prtUdDt  as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-operId   as int  no-undo.
def var v-kfm      as logi no-undo.
def var v-numprt   as char no-undo.
def var v-mess     as int  no-undo.
def var v-dtbth    as date no-undo.
def var v-bdt      as char no-undo.
def var v-regdt    as date no-undo.
def var v_rnn      as char no-undo.
def var v-clname2  as char no-undo.
def var v-clfam2   as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr     as char no-undo.
def var v-country2 as char no-undo.
def var famlist    as char no-undo init "".
def var v-knpval   as char no-undo.
def var v_mname    as char no-undo.
def var v-bdt1     as date no-undo.
def var v_rez      as char no-undo.
def var v_countr   as char no-undo format "x(2)".
def var v_countr1  as char no-undo format "x(2)".
def var v_lname1   as char no-undo format "x(20)".
def var v_name1    as char no-undo format "x(20)".
def var v_mname1   as char no-undo format "x(20)".
def var v_addr     as char no-undo.
def var v_tel      as char no-undo.
def var v_public   as char no-undo.
def var v_doctype  as char no-undo.
def var v-cifmin   as char no-undo.
def var v-osnov    as char no-undo.
def var v-term     as char no-undo.
define button but label " "  NO-FOCUS.


/*--------EK---------------*/
def shared var v-nomer like cslist.nomer no-undo.
def shared var v-ek    as int            no-undo.
def var v-crc_val  as char no-undo format "xxx".
def var v-crc_valk as char no-undo format "xxx".
def var v-chEK     as char format "x(20)". /* счет ЭК*/
def var v-chEK1    as char format "x(20)". /* счет ЭК для тенге*/
/*------------------------------------*/
def var v-int   as deci.
def var v-mod   as deci.
def var v-modc  as deci.
def var v-int1  as deci.
def var v-mod1  as deci.
def var v-modc1 as deci.
def var v_sum1  as deci.

def var v-fil    as char   no-undo.
def var v-spcrc  as char   no-undo. /* список допустимых валют */
def var v-glcom  as int    no-undo.
def var v-glarp  as int    no-undo.
def var v-numPC    as char   no-undo format "x(16)". /* номер ПК */
def var v-numPC1    as char   no-undo format "x(6)". /* номер ПК 1-6*/
def var v-numPC2    as char   no-undo format "x(6)". /* номер ПК 7-12*/
def var v-numPC3    as char   no-undo format "x(4)". /* номер ПК 13-16*/
def var v-dat    as char    no-undo format "99/99".  /* срок действия */
def var v_sumkzt as deci   no-undo. /* сумма в тенге */
def var v-crcc   as char   no-undo. /* буквенный код валюты */
def var v-crcccom   as char   no-undo. /* буквенный код валюты комиссии*/
def var phand    as handle no-undo.
def var v-bin    as logi   no-undo.
def var v-label  as char   no-undo init " ИИН получателя       :" .

/* для комиссии*/
def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.

/*проверка банка*/
{yes-no.i}
{findstr.i}
{kfm.i "new"}
{checkdebt.i &file = "bank"}
{keyord.i}

{srvcheck.i}

def temp-table tmprez
    field des as char.
    create tmprez. tmprez.des = "Выдача через ПОС – терминал".
    create tmprez. tmprez.des = "Заявление клиента на выдачу наличных".

DEFINE QUERY q-rez FOR tmprez.
DEFINE BROWSE b-rez QUERY q-rez
       DISPLAY tmprez.des label "Основание " format "x(47)" WITH  3 DOWN.
DEFINE FRAME f-rez b-rez  WITH overlay 1 COLUMN SIDE-LABELS row 27 COLUMN 40 width 60 NO-BOX.

function crc-conv1 returns decimal (sum as decimal, c1 as int, c2 as int).
define buffer bcrc1 for crc.
define buffer bcrc2 for crc.
if c1 <> c2 then
   do:
      find last bcrc1 where bcrc1.crc = c1 no-lock no-error.
      find last bcrc2 where bcrc2.crc = c2 no-lock no-error.
      return sum * bcrc1.rate[1] / bcrc2.rate[1].
   end.
   else return sum.
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

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "Нет параметра ourbnk sysc!"  view-as alert-box error.
    return.
end.
s-ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if not v-bin  then v-label = " РНН получателя         :".

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'crc'
                     no-lock no-error.
if avail bookcod then v-spcrc = bookcod.name.
else do:
    message "В справочнике <pc> отсутствует код <crc> для определения допустимых валют!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'limEK'
                     no-lock no-error.
if avail bookcod then v_sum_lim = deci(bookcod.name) no-error.
else do:
    message "В справочнике <pc> отсутствует код <limEK> для определения лимита суммы по ЭК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc1'
                     and bookcod.code    = 'glcom1'
                     no-lock no-error.
if avail bookcod then v-glcom = int(trim(bookcod.name)) no-error.
else do:
    message "В справочнике <pc1> отсутствует код <glcom1> для определения ГК счета комиссии по ПК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc1'
                     and bookcod.code    = 'glarp1'
                     no-lock no-error.
if avail bookcod then v-glarp = int(trim(bookcod.name)) no-error.
else do:
    message "В справочнике <pc1> отсутствует код <glarp1> для определения ГК счета АРП по ПК других банков!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
{chk12_innbin.i}


    /*form v-numPC1   no-label colon 25 format 'x(6)' validate(length(trim(v-numPC1)) = 6, "Hеверное количество символов номера ПК  или должны быть цифры")
        v-numPC2   no-label colon 33  format 'x(6)' blank validate(length(trim(v-numPC2)) = 6, "Hеверное количество символов номера ПК  или должны быть цифры")
        v-numPC3   no-label colon 40  format 'x(4)' validate(length(trim(v-numPC3)) = 4, "Hеверное количество символов номера ПК  или должны быть цифры")
 WITH overlay 1 COLUMN SIDE-LABELS row 13 COLUMN 24 width 50 NO-BOX FRAME fr1.*/
        form
        v-joudoc  label " Документ               " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-crc     label " Валюта                 " format ">9" validate(can-do(v-spcrc,string(v-crc)),"Неверный код валюты! Возможны только коды: " + v-spcrc + "!")
        v-crcc    no-label  colon 28 format "x(03)" skip
        v_sum     label " Сумма к выдаче         " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip(1)
        v_sumtotal label " Сумма для ПОС          " validate(v_sumtotal > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip(1)
        /*v_tar    LABEL " Код тарифа комиссии " format "x(3)" validate(v-tar = "000","Неверный код тарифа комиссии")  help " Введите код тарифа комиссии, F2 помощь"
        v_comname  no-label colon 32 format "x(25)" skip*/
        v-sumcom  label " Сумма комиссии в валюте" validate(v-sumcom > 0, "Hеверное значение суммы комиссии") format ">>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        /*v-crccom  label " Валюта комиссии        " format ">9" validate(can-do(v-spcrc,string(v-crc)),"Неверный код валюты! Возможны только коды: " + v-spcrc + "!")
        v-crcccom no-label  colon 28 format "x(03)" skip*/
        v-sumcomKZT  label " Сумма комиссии в тенге " validate(v-sumcomKZT > 0, "Hеверное значение суммы комиссии") format ">>>,>>>,>>>,>>9.99" help " Введите сумму комиссии" skip
        v-arp     label " Счет плательщика (АРП) " format "x(20)"
        v-arpname no-label  colon 50 format "x(30)" skip
        v-numPC   label " номер ПК др банка      " format 'x(16)' validate(length(trim(v-numPC)) = 16, "Hеверное количество символов номера ПК ") skip
        v-dat     label " Срок действия карты    " validate((int(substring(v-dat,1,2)) >= month(g-today) and int(substring(v-dat,3,2)) = int(substring(string(year(g-today)),3,2)))
                                                    or (int(substring(v-dat,3,2)) > int(substring(string(year(g-today)),3,2))), "Неверный срок действия карты ") format "99/99"  help " Введите месяц и год срока действия ПК " skip
        v_lname   label " ФИО получателя         " format "x(60)" validate(trim(v_lname) <> "",'Введите ФИО получателя') skip
        v_doc_num label " № документа,удост.личн." format "x(30)" validate(trim(v_doc_num) <> "",'Введите № документа,удост.личн') skip
        v_docwho  label " Кем выдан документ     " format "x(20)" validate(trim(v_docwho) <> "",'Введите кем выдан документ ') skip
        v_docdt   label " Дата выдачи            " format "99/99/9999" validate(v_docdt <> ?,'Введите дату выдачи документа ') skip
        v_rnn     label " ИИН получателя         " format 'x(12)' validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v_code    label " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe     label " КБе                    " validate(length(v_kbe) = 2, "Hеверное значение кбе") skip
        v_knp     label " КНП                    "  skip
        v_oper    label " Назначение платежа     " skip
        v_oper1   no-label colon 5 skip
        v_oper2   no-label colon 5 skip(1)
        v-osnov   label " Основание               " format "x(47)" validate(v-osnov = "Выдача через ПОС – терминал" or  v-osnov = "Заявление клиента на выдачу наличных","")skip
        v-term    label " Код авторизации         " format "x(6)" validate(v-osnov = "Выдача через ПОС – терминал" and int(v-term) <= 999999 and length(trim(v-term)) = 6,"Неверный код авторизации") skip
        vj-label  no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 5
    TITLE v_title width 100 FRAME f_main.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS9"). else run a_help-joudoc1 ("EK9").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

on choose of but in frame  f_main do:
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find first nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    displ v-joudoc format "x(10)" with frame f_main.
    assign v-ja      = yes
           v-arp     = ""
           v-arpname = ""
           v-numPC     = ""
           v-dat     = ""
           v_sumtotal     = 0
           v-crc     = 1
           v_oper    = "Выдача наличных по ПК других банков"
           v_oper1   = ""
           v_oper2   = ""
           v_lname   = ""
           v_doc_num = ""
           v_docwho  = ""
           v_docdt   = ?
           v_rnn     = "".
    run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                 if joudop.type <> "CS9"  and joudop.type <> "EK9" then do:
                    message substitute ("Документ не относится к типу расходная операция по ПК других банков") view-as alert-box error.
                    return.
                end.
                if v-ek = 1 and joudop.type = "EK9" then do:
                    message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box error.
                    return.
                end.
                if v-ek = 2 and joudop.type = "CS9" then do:
                    message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box error.
                    return.
                end.
           end.
            if joudoc.jh ne ? then do:
                message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box error.
                return.
            end.
            if joudoc.who ne g-ofc then do:
                message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
                return.
            end.
        end.
        run save_doc.

        /* удаление записи из kfmoper  */
        find first kfmoper where kfmoper.operDoc = v-joudoc exclusive-lock no-error.
        if available kfmoper then delete kfmoper.
        find first kfmoper where kfmoper.operDoc = v-joudoc no-lock no-error.
        /*------------------------------------------------------------------------------*/
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc with frame f_main.

    update v-crc with frame f_main.
    find first crc where crc.crc = v-crc no-lock no-error.
    v-crcc = crc.code.
    displ v-crc v-crcc with frame f_main.
    if v-ek = 2 and v-crc = 3 then do:
        message "ЭК не работает с валютой " + v-crcc + "!"  view-as alert-box error.
        undo, return.
    end.

    update v_sum with frame f_main.
    v_sumkzt = if v-crc = 1 then v_sum else round(crc-conv1(v_sum, v-crc, 1),2).
    if v-ek = 2 then do:
        if v_sumkzt > v_sum_lim then do:
            message "Сумма превышает лимит = " + string(v_sum_lim) + " тенге!"  view-as alert-box error.
            undo, return.
        end.
    end.
    v-sumcom = v_sum * 0.015.
    v_sumtotal = v_sum + v-sumcom.
    v-sumcomKZT = v_sumkzt * 0.015.
    v-crccom = 1. /* пока только в KZT */
    /*find first crc where crc.crc = v-crccom no-lock no-error.
    v-crcccom = crc.code.*/
    displ /*v-crccom  v-crcccom */ v_sumtotal v-sumcom v-sumcomKZT    with frame f_main.

    /*find first sysc where sysc.sysc = 'pc1' + string(v-glarp) no-lock no-error.
    if not avail sysc then do:
        message "Нет параметра " +  'pc1' + string(v-glarp) + " sysc!"  view-as alert-box error.
        undo, return.
    end.*/
    find first arp where arp.gl = v-glarp and arp.crc = v-crc no-lock no-error.

    if avail arp then do:
        find first sub-cod where sub-cod.acc   = arp.arp
                             and sub-cod.sub   = "arp"
                             and sub-cod.d-cod = "clsa"
                             no-lock no-error.
        if avail sub-cod then if sub-cod.ccode eq "msc" then assign v-arp     = arp.arp
                                                                    v-arpname = arp.des .
   end.
   if v-arp = '' then do:
        message "Не найден счет АРП (ГК " + string(v-glarp) + ", валюта " + v-crcc + ") для выдачи наличных по ПК других банков!"  view-as alert-box error.
        undo, return.
     end.
    displ v-arp v-arpname with frame f_main.

    /*update v-numPC1  v-numPC2 v-numPC3 with frame fr1.*/
    update v-numPC with frame f_main.
    v-numPC = substring(trim(v-numPC),1,6) + "******"  +  substring(trim(v-numPC),13,4).
    displ  v-numPC with frame f_main.
    pause 0.
    update v-dat v_lname v_doc_num v_docwho v_docdt  v_rnn v_code v_kbe with frame f_main.
    displ  /*v_code v_kbe*/ v_knp vj-label with frame f_main.
    v_oper = v_oper + " № "  + v-numPC.

    v_oper1 =  " срок действия карты: " + substring(v-dat,1,2)  + "/" + substring(v-dat,3,2) + " ФИО: " + v_lname .
            v_oper2 = " докум: " + v_doc_num + " " + v_docwho + " " + string(v_docdt) + " ИИН: " + v_rnn.
    displ v_oper v_oper1 v_oper2 with frame f_main.
    pause 0.
    OPEN QUERY  q-rez FOR EACH tmprez no-lock.
    ENABLE ALL WITH FRAME f-rez.
    wait-for return of frame f-rez
    FOCUS b-rez IN FRAME f-rez.
    v-osnov = tmprez.des.
    hide frame f-rez.
    displ v-osnov with frame f_main.
    if v-osnov = "Выдача через ПОС – терминал" then update v-term with frame f_main.
    else do:
        v-term = "".
        display v-term with frame f_main.
    end.
    update v-ja with frame f_main.
     if v-ja then do:
        if v-ek = 2 then do:
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-chEK = arp.arp.
                    leave.
                end.
            end.
            if v-chEK = '' then do:
                message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crcc + " !" view-as alert-box title " ОШИБКА ! ".
                undo, return.
            end.
        end.
        find first cmp no-lock.

        if new_document then do:
            create joudoc.
            joudoc.docnum = v-joudoc.
            create joudop.
            joudop.docnum = v-joudoc.
        end.
        else do:
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if avail joudoc then find current joudoc exclusive-lock.
            find joudop where joudop.docnum = v-joudoc no-lock no-error.
            if avail joudop then find current joudop exclusive-lock.
        end.
        assign joudoc.who   = g-ofc
               joudoc.whn   = g-today
               joudoc.tim   = time
               joudoc.cramt = v_sumtotal.
        if v-ek = 2 then joudoc.cracctype = "4". else joudoc.cracctype = "1".
        if v-ek = 2 then joudoc.cracc = v-chEK. else joudoc.cracc = "".
        assign
            joudoc.crcur     = v-crc
            joudoc.dramt     = v_sumtotal
            joudoc.dracctype = "4"
            joudoc.drcur     = v-crc
            joudoc.dracc     = v-arp
            joudoc.comamt    = v-sumcomKZT
            joudoc.comcur     = v-crccom
            joudoc.info      = v_lname
            joudoc.passp     = v_doc_num + ',' + v_docwho
            joudoc.passpdt   = v_docdt
            joudoc.perkod    = v_rnn
            joudoc.remark[1] = v_oper
            joudoc.remark[2] = v_oper1
            joudoc.rescha[3] = v_oper2
            joudoc.chk       = 0
            joudoc.benname   = cmp.name.

        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
        assign joudop.who   = g-ofc
               joudop.whn   = g-today
               joudop.tim   = time
               joudop.lname = v-numPC
               joudop.mname = v-dat
               joudop.amt1  = v-sumcom
               joudop.amt2  = v_sum
               joudop.fname = v-osnov.
               joudop.rez1  = v-term.
               joudop.type   = if v-ek = 1 then "CS9" else "EK9".
        find current joudop no-lock no-error.

        find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            assign sub-cod.acc   = v-joudoc
                   sub-cod.sub   = "jou"
                   sub-cod.d-cod = "eknp"
                   sub-cod.ccode = "eknp".
        end.
        find current sub-cod exclusive-lock.
        assign sub-cod.rdt   = g-today
               sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
        find current sub-cod no-lock no-error.
        displ v-joudoc with frame f_main.
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
        message "Документ не найден." view-as alert-box error.
        undo, retry.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
         if joudop.type <> "CS9"  and joudop.type <> "EK9" then do:
            message substitute ("Документ не относится к типу расходная операция по ПК других банков") view-as alert-box error.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK9" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box error.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS9" then do:
            message substitute ("Документ создан для счета ГК 100100 ") view-as alert-box error.
            return.
        end.
    end.
    if joudoc.jh ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box error.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
        return.
    end.
    assign
    v_trx       = joudoc.jh
    v-arp       = joudoc.dracc
    v_sumtotal  = joudoc.dramt
    v-crc       = joudoc.drcur
    v-sumcomKZT = joudoc.comamt
    v-crccom    = joudoc.comcur
    v_oper      = joudoc.remark[1]
    v_oper1     = joudoc.remark[2]
    v_oper2     = joudoc.rescha[3]
    v_lname     = joudoc.info
    v_doc_num   = entry(1,joudoc.passp)
    v_docwho    = entry(2,joudoc.passp)
    v_docdt     = joudoc.passpdt
    v_rnn       = joudoc.perkod
    v-numPC     = joudop.lname
    v-dat       = trim(joudop.mname)
    v-sumcom    = joudop.amt1.
    v_sum       = joudop.amt2.
    v-osnov     = joudop.fname.
    v-term      = joudop.rez1.
    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then v-arpname = arp.des.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then assign v_code = entry(1,sub-cod.rcode,',')
                                 v_kbe  = entry(2,sub-cod.rcode,',')
                                 v_knp  = entry(3,sub-cod.rcode,',').
    v-ja = yes.
    find first crc where crc.crc = v-crc no-lock no-error.
    v-crcc = crc.code.
    /*find first crc where crc.crc = v-crccom no-lock no-error.
    v-crcccom = crc.code.*/
    displ v-joudoc v_trx v-crc v-crcc v_sum v_sumtotal v-sumcom /*v-crccom v-crcccom*/ v-sumcomKZT  v-arp v-arpname v-numPC v-dat v_lname
    v_doc_num v_docwho v_docdt  v_rnn v_code v_kbe v_knp  v_oper v_oper1 v_oper2  v-osnov v-term with  frame f_main.
end procedure.

Procedure Delete_document.
    vj-label  = " Удалить документ?..................".
    run view_doc.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if available joudoc then do:
        if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
            message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box error.
            undo, return.
        end.
        if joudoc.who ne g-ofc then do:
           message substitute (
              "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box error.
           undo, return.
        end.
        find first kfmoper where kfmoper.operDoc = joudoc.docnum and kfmoper.operType = "cs" no-lock no-error.
        if available kfmoper then do:
            message "Есть запись в службе комплаенс, удалять документ запрещено." view-as alert-box.
            undo, return.
        end.
        displ vj-label no-label format "x(35)"  with frame f_main.
        pause 0.
        update v-ja  with frame f_main.
        if v-ja then do:
            find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:
                find current joudoc exclusive-lock.
                delete joudoc.
            end.
            for each substs where substs.sub = "jou" and  substs.acc = v-joudoc.
                delete substs.
            end.
            find first cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-lock no-error.
            if available cursts then do:
                find current cursts exclusive-lock.
                delete cursts.
            end.

            find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                find current sub-cod exclusive-lock.
                delete sub-cod.
            end.
        end.
    end.
    apply "close" to this-procedure.
    delete procedure this-procedure.
    hide message.
    hide frame f_main.
end procedure.

procedure Create_transaction:
    vj-label = " Выполнить транзакцию?..................".
    run view_doc.
    if keyfunction (lastkey) = "end-error" then undo, return.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box error.
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

    /* фин мониторинг*/
    v_rez = v_code.
    v-knpval = "119".
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

    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja or keyfunction (lastkey) = "end-error" then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide frame f_main.
        return.
    end.
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

    /* поиск арп счета комиссии */
    v-arpcom = "".
    for each arp where arp.gl = v-glcom and arp.crc = 1 no-lock.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "PC1" no-lock no-error.
        if avail sub-cod then do:
            v-arpcom = arp.arp.
            leave.
        end.
    end.
    if v-arpcom = '' then do:
        message "Не найден АРП счет ГК " + string(v-glcom) + " с признаком 'PC1'!" view-as alert-box title " ОШИБКА ! ".
        undo, return.
    end.

    /*EK 100500------------------------------------------------------*/
    if v-ek = 2 then do:
        for each arp where arp.gl = 100500 and arp.crc = 1 no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK1 = arp.arp.
                leave.
            end.
        end.
        if v-chEK1 = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте KZT!" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then do:
                v-chEK = arp.arp.
                leave.
            end.
        end.
        if v-chEK = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crcc + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        s-jh = 0.
        /*---------------выделяем дробную часть  ----------------------------------------------*/
        if v-crc <> 1 then
            assign v_sum1 = deci(entry(1,string(v_sumtotal - v-sumcom),".")) / 10
                   v-mod  = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sumtotal - v-sumcom - decim(entry(1,string(v_sumtotal - v-sumcom),".")))
                   v-int  = v_sumtotal - v-sumcom - v-mod
                   v-modc = round(crc-conv(decimal(v-mod), v-crc, 1),2).
        /* проверка блокировки курса --------------------------------*/
        if v-mod <> 0 then do:
            v-cur = no.
            run a_cur(input v-crc, output v-cur).
            if v-cur then undo, return.
        end.
        /*------------------------------------------------------------------------------------------*/
        if v-crc = 1 or v-mod = 0 then do:  /* дробной части нет  */
            v-tmpl = "JOU0056".
            v-param = v-joudoc + vdel + string(v_sumtotal) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
                    + vdel + substr(v_code,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.  /*  if v-crc = 1 or v-mod = 0 then do*/
        else do:
            /* обрабатываем целую часть */
            v-tmpl = "JOU0056".
            v-param = v-joudoc + vdel + string(v_sumtotal) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
                    + vdel + substr(v_code,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            /* обрабатываем конвертируем дробную часть */
            v-tmpl = "JOU0063".
            v-param = v-joudoc + vdel + string(v-mod) + vdel + string(v-crc) + vdel + v-chEK + vdel + "обмен валюты" +
                    vdel + "1" + vdel + "1" + vdel + "9" + vdel + "9" + vdel + "213" /*+ vdel + string(v-modc)*/ + vdel +
                    "1" + vdel + v-chEK1 .
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.

        /* проводка комиссии */
        if v-crc = 1 then do:

            v-tmpl = "JOU0056". /* снятие суммы комиссии и выдача через 100500 с 186011 */
            v-param = v-joudoc + vdel + string(v-sumcom) + vdel + string(v-crc) + vdel + v-chEK + vdel + v-arpcom + vdel +
                    ("Комиссия за выдачу наличных по платежной карте других банков № " + v-numPC + " " + v_oper1 + " " + v_oper2)
                    + vdel + substr(v_kbe,1,1) + vdel + "1" + vdel + substr(v_kbe,2,1) + vdel + "4" + vdel + "840".
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.

        end.
        else do: /* если валюта операции не KZT комиссию конвертируем */

            v-tmpl = "JOU0058". /* принимаем на 100500 сумму комиссии и отправляем на 286013 с конвертацией */
            v-param = v-joudoc + vdel + string(v-sumcom) + vdel + string(v-crc) + vdel + v-chEK + vdel +
                    ("Комиссия за выдачу наличных по платежной карте других банков № " + v-numPC + " " + v_oper1 + " " + v_oper2)
                     + vdel + substr(v_kbe,1,1) + vdel + "1" + vdel + substr(v_kbe,2,1) + vdel + "4" + vdel + "840"
                     + vdel + string(v-sumcomKZT) + vdel + v-arpcom .
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        if jh.sts < 5 then jh.sts = 5.
        for each jl of jh:
            if jl.sts < 5 then jl.sts = 5.
        end.
        find current jh no-lock.

        find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        if v-crc = 1 then joudoc.brate = 1.
        else do:
            find first crc where  crc.crc = v-crc no-lock no-error.
            joudoc.brate = crc.rate[2].
            joudoc.sn = 1.
        end.
        joudoc.srate = 1.
        find current joudoc no-lock no-error.
    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        assign s-jh    = 0
               v-tmpl  = "JOU0001"
               v-param = v-joudoc + vdel + string(v_sumtotal) + vdel + string(v-crc) + vdel + v-arp + vdel +
                    (v_oper + v_oper1 + v_oper2) + vdel + substring(v_code,1,1)
                    + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1)
                    + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        /* проводка комиссии */
        if v-crc = 1 then do:

            v-tmpl = "JOU0048". /* принимаем на 100100 сумму комиссии и отправляем на 286013  */
            v-param = v-joudoc + vdel + string(v-sumcom) + vdel + string(v-crc) + vdel + v-arpcom + vdel +
                    ("Комиссия за выдачу наличных по платежной карте других банков № " + v-numPC + " " + v_oper1 + " " + v_oper2)
                        + vdel + substring(v_kbe,1,1) + vdel + "1" + vdel + substring(v_kbe,2,1) + vdel + "4" + vdel + "840".
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
        else do: /* если валюта операции не KZT комиссию конвертируем */

            v-tmpl = "JOU0059". /* принимаем на 100100 сумму комиссии и отправляем на 286013 с конвертацией */
            v-param = v-joudoc + vdel + string(v-sumcom) + vdel + string(v-crc) + vdel +
                    ("Комиссия за выдачу наличных по платежной карте других банков № " + v-numPC + " " + v_oper1 + " " + v_oper2)
                     + vdel + substr(v_kbe,1,1) + vdel + "1" + vdel + substr(v_kbe,2,1) + vdel + "4" + vdel + "840"
                     + vdel + string(v-sumcomKZT) + vdel + v-arpcom.
            run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
    end.
    if v-noord = yes then run printvouord(2).

    /*---------------------------------------------------------*/
    run chgsts(m_sub, v-joudoc, "trx").
    pause 1 no-message.
    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
    joudoc.jh = s-jh.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    run chgsts("jou", v-joudoc, "cas").

    /* копируем заполненные данные по ФМ в реальные таблицы*/
    /*if v-kfm then do:
        run kfmcopy(v-operid,v-joudoc,'fm', s-jh).
        hide all.
        view frame f_main.
    end.*/
    /**/
    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) view-as alert-box.
    if v_sumtotal >= round(crc-conv(decimal(1000), 2, v-crc),2) then  do:
        MESSAGE "Необходим контроль в п.м. 2.4.1.10! 'Контроль документов'!" view-as alert-box.
        for each sendod no-lock:
            run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
                "Добрый день!\n\n Необходимо отконтролировать расх. операцию \n со сбер/счета по суммам превышающую 1000 долл.США \n Сумма: " + string(v_sumtotal) +
                "  " + v-crc_val + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
                string(time,"HH:MM"), "1", "","" ).
        end.
        hide all.
        view frame f_main.
        pause 0.
        run chgsts(m_sub, v-joudoc, "bad").
    end.

    v_trx = s-jh.
    display v_trx with frame f_main.
    pause 0.

    if v-ek = 1 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
    end.

    if v-crc = 1 or v-mod <> 0 then do:
        find first jh where jh.jh = s-jh no-lock no-error.
        for each jl of jh use-index jhln where (jl.gl = 100100 or jl.gl = 100500) and jl.crc = 1 no-lock
        break by jl.jh by jl.crc:
            create jlsach .
            assign jlsach.jh   = jl.jh
                   jlsach.amt  = jl.dam + jl.cam
                   jlsach.ln   = jl.ln
                   jlsach.lnln = 1
                   jlsach.sim  = 220.
        end.
    end.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc  exclusive-lock no-error no-wait.
    if not avail joudoc then do:
        if locked joudoc then message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ!" view-as alert-box error.
        else message "ДОКУМЕНТА НЕТ!" view-as alert-box error.
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box error.
        pause 3.
        undo, return.
    end.
    s-jh = joudoc.jh.

    /* проверка свода кассы */
    quest = false.
    find first sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    if v-ek = 1 then find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    if v-ek = 2 then find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    find first cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find first jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя." view-as alert-box error.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box error.
            undo, return.
        end.
    end.
    /* ------------storno ?????????-----------------*/
     if jh.jdt lt g-today then do:
         message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
         if not quest then undo, return.
          /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
         for each jl where jl.jh eq joudoc.jh no-lock:
             if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
             else
             if jl.gl eq sysc.inval and jl.sts = 6 then do:
                 find first cashofc where cashofc.whn eq jl.jdt and
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

    /* удаление записи из kfmoper  */
    find first kfmoper where kfmoper.operDoc = joudoc.docnum exclusive-lock no-error.
    if available kfmoper then delete kfmoper.
    find first kfmoper where kfmoper.operDoc = joudoc.docnum no-lock no-error.
    /*------------------------------------------------------------------------------*/

     joudoc.jh   = ?.
     v_trx = ?.
     display v_trx with frame f_main.


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
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    release joudoc.
    run chgsts("JOU", v-joudoc, "new").
    message "Транзакция удалена." view-as alert-box.
end procedure.

procedure Screen_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.

    s-jh = joudoc.jh.
    run vou_word (2, 1, joudoc.info).
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.

    s-jh = joudoc.jh.
    if v-noord = no then run vou_bankt(2, 1, joudoc.info).
    else do:
        run printvouord(2).
        run printord(s-jh,"").
    end.

end procedure.

procedure Get_Nal:
    run view_doc.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh < 1 or joudoc.jh = ? then do:
        message "Транзакция не проведена." view-as alert-box error.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box error.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
        undo, return.
    end.
    find first cursts where cursts.acc = v-joudoc and cursts.sub = "jou" no-lock no-error.
    if avail cursts and cursts.sts = "rdy" then do :
      message "Проводка уже отштампована " view-as alert-box error.
      undo, return.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do:
        message "Документ не отконтролирован " view-as alert-box error.
      undo, return.
    end.
    v-Get_Nal = yes.
end procedure.

procedure create_100100:
    run a_create100100(v-joudoc).
end.

procedure Stamp_transaction:
    find first optitsec where optitsec.proc = "a_stamp" and lookup(g-ofc,optitsec.ofcs) > 0 no-lock no-error.
    if not avail optitsec then do :
      message "Нет доступа к меню 'Штамп'! " view-as alert-box.
      undo, return.
    end.
    if joudoc.jh < 1 or joudoc.jh = ? then do:
        message "Транзакция не проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    /*if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.*/
    find cursts where cursts.acc = v-joudoc and cursts.sub = "jou" no-lock no-error.
    if avail cursts and cursts.sts = "rdy" then do :
      message "Проводка уже отштампована " view-as alert-box.
      undo, return.
    end.
    if not avail cursts or (avail cursts and cursts.sts <> "cas") then do:
        message "Документ не отконтролирован " view-as alert-box error.
      undo, return.
    end.

    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.

