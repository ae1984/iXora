/* a_cas2pc.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        расходная операция по платежной карте
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-2-2
 * AUTHOR
        22.06.2012 id00810 (на основе a_cas2arp.p)
 * CHANGES
        16/07/2012 id00810 - переход на использование таблицы pccards
        25/07/2012 id00810 - исправлена ошибка передачи параметров в процедуру pcfdoc
        24/08/2012 id00810 - в назначении платежа учтен переход на ИИН, переход на использование параметра sysc для определения счета АРП
        10/09/2012 Luiza подключила {srvcheck.i}
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        21/12/2012 id00810 - контроль документа нужен только для сумм больше 1000$
        24/12/2012 id00810 - если не нужен контроль, то документу сразу присваивается статус cas
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        05/04/2013 Luiza - ТЗ № 1764 проверка признака блокирования валют при обменных операциях
        10/06/2013 Luiza - ТЗ 1727 проверка на 30 млн тенге при расходе со счета клиента наличными
        01.07.2013 Lyubov - ТЗ 1766, обработка доп. и бизнес-карт
        10/07/2013 Luiza -  ТЗ 1948 курс обмена валюты сохраняем в поле brate
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
        29/10/2013 Luiza - ТЗ 2161 Дополнительное поле «Основание»
        12/11/2013 Luiza - ТЗ 2116 редактирование полей
        12/11/2013 Luiza - ТЗ 2191 поля для расход ордера
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
def var v_title   as char no-undo init " Расходная операция по платежной карте ".
def var v_sum     as deci no-undo. /* сумма*/
def var v-crc     as int  no-undo .  /* Валюта*/
def var v-arp     as char format "x(20)". /* счет arp */
def var v-cif     as char format "x(6)". /* cif клиент*/
def var v_lname   as char format "x(30)". /*  клиент*/
def var v-jss     as char format "x(12)". /*  рнн клиента*/
def var v_code    as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe     as char  no-undo format "x(2)".  /* КБе*/
def var v_knp     as char no-undo format "x(3)" init '321'.  /* КНП*/
def var v-ja      as logi no-undo format "Да/Нет" .
def var v_oper    as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1   as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2   as char no-undo format "x(55)".  /* Назначение платежа*/
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
def new shared variable s-jh like jh.jh.
def new shared var v_doc as char format "x(10)" no-undo.
define new shared variable vrat  as decimal decimals 4.

/* for finmon */
def var v-monamt  as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl for jl.
def buffer bb-jl for jl.
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
/*def var v-num as inte no-undo.*/
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
def var v-glaaa  as int    no-undo.
def var v-glarp  as int    no-undo.
def var v-aaa    as char   no-undo format "x(20)". /* счет ПК */
def var v-card   as char   no-undo format "x(16)".
def var v_sumkzt as deci   no-undo. /* сумма в тенге */
def var v-crcc   as char   no-undo. /* буквенный код валюты */
def var phand    as handle no-undo.
def var v-bin    as logi   no-undo.
def var v-label  as char   no-undo init " ИИН получателя       :" .

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
DEFINE FRAME f-rez b-rez  WITH overlay 1 COLUMN SIDE-LABELS row 22 COLUMN 40 width 60 NO-BOX.


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

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'glaaa'
                     no-lock no-error.
if avail bookcod then v-glaaa = int(trim(bookcod.name)) no-error.
else do:
    message "В справочнике <pc> отсутствует код <glaaa> для определения ГК счета клиента по ПК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'glarp'
                     no-lock no-error.
if avail bookcod then v-glarp = int(trim(bookcod.name)) no-error.
else do:
    message "В справочнике <pc> отсутствует код <glarp> для определения ГК счета АРП по ПК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
{chk12_innbin.i}
   form
        v-joudoc  label " Документ               " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-crc     label " Валюта                 " format ">9" validate(can-do(v-spcrc,string(v-crc)),"Неверный код валюты! Возможны только коды: " + v-spcrc + "!")
        v-crcc    no-label  colon 28 format "x(03)" skip
        v_sum     label " Сумма                  " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v-arp     label " Счет плательщика (АРП) " format "x(20)"
        v-arpname no-label  colon 50 format "x(30)" skip
        v-card    label " Номер плат.карточки    " format 'x(16)' skip
        v-aaa     label " Счет по плат.карточке  " format 'x(20)' /*validate(can-find(first aaa where aaa.aaa = v-aaa and aaa.gl = 220430 no-lock),"Неверный счет ПК!")*/ skip
        v_lname   label " ФИО получателя         " format "x(60)" skip
        v_doc_num label " № документа,удост.личн." format "x(30)" skip
        v_docwho  label " Выдан                  " format "x(20)" skip
        v_docdt   label " Дата выдачи            " format "99/99/9999" skip
        v-label   no-label format 'x(26)' v_rnn  format 'x(12)' colon 25 no-label validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip
        v_code    label " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe     label " КБе                    " skip
        v_knp     label " КНП                    " skip
        v_oper    label " Назначение платежа     " skip
        v_oper1   no-label colon 25 skip
        v_oper2   no-label colon 25 skip(1)
        v-osnov   label " Основание               " format "x(47)" validate(v-osnov = "Выдача через ПОС – терминал" or  v-osnov = "Заявление клиента на выдачу наличных","")skip
        v-term    label " Код авторизации         " format "x(6)" validate(v-osnov = "Выдача через ПОС – терминал" and int(v-term) <= 999999 and length(trim(v-term)) = 6,"Неверный код авторизации") skip

        vj-label  no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.

on help of v-card in frame f_main do:
    run h-pc PERSISTENT SET phand.
    v-card = frame-value.
    displ v-card with frame f_main.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS6"). else run a_help-joudoc1 ("EK6").
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
           v-aaa     = ""
           v_sum     = 0
           v-crc     = 1
           v_oper    = "Выдача наличных по платежной карте "
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
                 if joudop.type <> "CS6"  and joudop.type <> "EK6" then do:
                    message substitute ("Документ не относится к типу расходная операция по платежной карте") view-as alert-box error.
                    return.
                end.
                if v-ek = 1 and joudop.type = "EK6" then do:
                    message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box error.
                    return.
                end.
                if v-ek = 2 and joudop.type = "CS6" then do:
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
    if v-ek = 2 then do:
        v_sumkzt = if v-crc = 1 then v_sum else round(crc-conv(v_sum, v-crc, 1),2).
        if v_sumkzt > v_sum_lim then do:
            message "Сумма превышает лимит = " + string(v_sum_lim) + " тенге!"  view-as alert-box error.
            undo, return.
        end.
    end.

    find first sysc where sysc.sysc = 'pc' + string(v-glarp) no-lock no-error.
    if not avail sysc then do:
        message "Нет параметра " +  "pc" + string(v-glarp) + " sysc!"  view-as alert-box error.
        undo, return.
    end.
    v-arp = sysc.chval.
    if num-entries(v-arp) >= v-crc then v-arp = entry(v-crc,v-arp).
    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then do:
        find first sub-cod where sub-cod.acc   = arp.arp
                             and sub-cod.sub   = "arp"
                             and sub-cod.d-cod = "clsa"
                             no-lock no-error.
        if avail sub-cod then if sub-cod.ccode eq "msc" then assign v-arp     = arp.arp
                                                                    v-arpname = arp.des .
   end.
   if v-arp = '' then do:
        message "Не найден счет АРП (ГК " + string(v-glarp) + ", валюта " + v-crcc + ") для выдачи наличных по ПК!"  view-as alert-box error.
        undo, return.
     end.
    displ v-arp v-arpname with frame f_main.

    update v-card help "Счет клиента по ПК; F2- помощь; F4-выход" with frame f_main.
    find first pccards where pccards.pcard = v-card and pccards.sts = 'OK' no-lock no-error.
    if avail pccards then do:
        v-card = substr(v-card,1,6) + '******' + substr(v-card,13).
        displ v-card with frame f_main.
           assign v_lname = pccards.sname
               v-aaa   = pccards.aaa
               v_rnn   = if v-bin then pccards.iin else pccards.rnn
               v-fil   = 'txb' + substr(pccards.aaa,19,2)
               v-cif   = pccards.cif.
               if pccards.pctype <> 'B' then v_code  = pccards.info[1] + '9'.
               else v_code = '14'.
               v_kbe   = v_code.
        /*if v-fil = s-ourbank then do:
            find first cif where cif.cif = v-cif no-lock no-error.
            if avail cif then assign v_doc_num = entry(1,cif.pss,' ')
                                     v_docdt   = date(entry(2,cif.pss,' '))
                                     v_docwho  = substr(cif.pss,length(entry(1,cif.pss,' ') + entry(2,cif.pss,' ')) + 2)
                                     no-error.
        end.
        else do:
            find first txb where txb.bank = v-fil no-lock no-error.
            if not avail txb then return.
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            run pcfdoc(v-cif,output v_doc_num,output v_code).
            if connected ("txb") then disconnect "txb".
            if v_doc_num = '' or v_code = '' then return.
            assign v_docdt   = date(entry(2,v_doc_num,' '))
                   v_docwho  = substr(v_doc_num,length(entry(1,v_doc_num,' ') + entry(2,v_doc_num,' ')) + 2)
                   v_doc_num = entry(1,v_doc_num,' ')
                   no-error.
        end.*/
        find first pcstaff0 where pcstaff0.iin = v_rnn  no-lock no-error.
        if available pcstaff0 then assign v_doc_num = pcstaff0.nomdoc
                                     v_docdt   = pcstaff0.issdt
                                     v_docwho  = pcstaff0.issdoc
                                     no-error.
    end.
    else do:
        message "Неверный счет ПК!"  view-as alert-box error.
        undo.
    end.

    displ v-aaa  v_lname v_doc_num v_docwho v_docdt v-label v_rnn v_code v_kbe v_knp vj-label with frame f_main.
    assign v_oper1 = v_lname + (if v-bin then " ИИН " else " РНН ") + v_rnn + " "
            v_oper2 = v-aaa.
    update v_doc_num  v_docwho v_docdt v_oper v_oper1 v_oper2 with frame f_main.
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
               joudoc.cramt = v_sum.
        if v-ek = 2 then joudoc.cracctype = "4". else joudoc.cracctype = "1".
        if v-ek = 2 then joudoc.cracc = v-chEK. else joudoc.cracc = "".
        assign
            joudoc.crcur     = v-crc
            joudoc.dramt     = v_sum
            joudoc.dracctype = "4"
            joudoc.drcur     = v-crc
            joudoc.dracc     = v-arp
            joudoc.info      = v_lname
            joudoc.passp     = v_doc_num + ',' + v_docwho
            joudoc.passpdt   = v_docdt
            joudoc.perkod    = v_rnn
            joudoc.remark[1] = v_oper
            joudoc.remark[2] = v_oper1
            joudoc.rescha[3] = v_oper2
            joudoc.chk       = 0.
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.
        assign joudop.who   = g-ofc
               joudop.whn   = g-today
               joudop.tim   = time
               joudop.lname = v-aaa
               joudop.type   = if v-ek = 1 then "CS6" else "EK6".
               joudop.fname = v-osnov.
               joudop.rez1  = v-term.
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
         if joudop.type <> "CS6"  and joudop.type <> "EK6" then do:
            message substitute ("Документ не относится к типу расходная операция по платежной карте") view-as alert-box error.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK6" then do:
            message substitute ("Документ создан для ЭК ГК 100500") view-as alert-box error.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS6" then do:
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
    v_trx     = joudoc.jh
    v-arp     = joudoc.dracc
    v_sum     = joudoc.dramt
    v-crc     = joudoc.drcur
    v_oper    = joudoc.remark[1]
    v_oper1   = joudoc.remark[2]
    v_oper2   = joudoc.rescha[3]
    v_lname   = joudoc.info
    v_doc_num = entry(1,joudoc.passp)
    v_docwho  = entry(2,joudoc.passp)
    v_docdt   = joudoc.passpdt
    v_rnn     = joudoc.perkod
    v-aaa     = joudop.lname.
    v-osnov     = joudop.fname.
    v-term      = joudop.rez1.
    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then v-arpname = arp.des.
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then assign v_code = entry(1,sub-cod.rcode,',')
                                 v_kbe  = entry(2,sub-cod.rcode,',')
                                 v_knp  = entry(3,sub-cod.rcode,',').
    v-ja = yes.
    displ v-joudoc v_trx v-crc v_sum v-arp v-arpname v-aaa v_lname v_doc_num v_docwho v_docdt v-label v_rnn v_code v_kbe v_knp
    v_oper v_oper1 v_oper2 v-osnov v-term with  frame f_main.
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
            assign v_sum1 = deci(entry(1,string(v_sum),".")) / 10
                   v-mod  = ((v_sum1 - decim(entry(1,string(v_sum1),"."))) * 10) + (v_sum - decim(entry(1,string(v_sum),".")))
                   v-int  = v_sum - v-mod
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
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
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
            v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-chEK + vdel + (v_oper + v_oper1 + v_oper2)
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
        if v-noord = yes then run printvouord(2).
    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        assign s-jh    = 0
               v-tmpl  = "JOU0001"
               v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel +
                    (v_oper + v_oper1 + v_oper2) + vdel + substring(v_code,1,1)
                    + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1)
                    + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
        if v-noord = yes then run printvouord(2).
    end.

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
    if v_sum >= round(crc-conv(decimal(1000), 2, v-crc),2) then  do:
        MESSAGE "Необходим контроль в п.м. 2.4.1.10! 'Контроль документов'!" view-as alert-box.
        for each sendod no-lock:
            run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
                "Добрый день!\n\n Необходимо отконтролировать расх. операцию \n со сбер/счета по суммам превышающую 1000 долл.США \n Сумма: " + string(v_sum) +
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
            pause 3.
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

