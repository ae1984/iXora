/* a_cas1pc.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Взнос наличных денег по платежной карте
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-2-1
 * AUTHOR
        09.07.2012 id00810 (на основе a_cas2arp.p)
 * CHANGES
        14.08.2012 id00810 - добавления в связи с дальнейшей передачей информации по пополнению ПК в карточную систему
        10/09/2012 Luiza подключила {srvcheck.i}
        16/11/2012 добавила обработку статуса KFMONLINE
                    if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        23/11/2012 id00810 - ТЗ 1594 поиск счета ARP по sysc
        27/02/2013 Luiza - ТЗ № 1699 добавила процедуру procedure Stamp_transaction
        01.07.2013 Lyubov - ТЗ 1766, обработка доп. и бизнес-карт
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        23/07/2013 Luiza  - ТЗ 1935 если в PCPAY статус 'send' транзакцию удалять нельзя
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
*/

def input parameter new_document as logical.
def var m_sub as character init "arp" no-undo.
def shared var v_u    as int  no-undo.
def shared var g-ofc  as char.

def var v-tmpl    as char no-undo.
def var vdel      as char no-undo initial "^".
def var v-param   as char no-undo.
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
def var v_title   as char no-undo init "Взнос наличных денег по платежной карте ".
def var v_sum     as deci no-undo. /* сумма*/
def var v-crc     as int  no-undo .  /* Валюта*/
def var v-arp     as char no-undo format "x(20)". /* счет arp*/
def var v-cif     as char no-undo format "x(06)". /* cif клиент*/
def var v_lname   as char no-undo format "x(30)". /*  клиент*/
def var v_name    as char no-undo format "x(30)". /*  клиент*/
def var v-cif1    as char no-undo format "x(06)". /*  клиент*/
def var v_code    as char no-undo format "x(02)". /* КОД*/
def var v_kbe     as char no-undo format "x(02)". /* КБе*/
def var v_knp     as char no-undo format "x(03)" init '311'.  /* КНП*/
def var v-ja      as logi no-undo format "Да/Нет".
def var v_oper    as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1   as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2   as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_doc_num as char no-undo.
def var v_docwho  as char no-undo.
def var v_docdt   as date no-undo.
def var v_rnn     as char no-undo.
def var v_rnnp    as char no-undo.
def new shared var v-num     as int  no-undo.
def new shared var v_doc     as char no-undo format "x(10)".
def new shared var s-jh      like jh.jh.
def     shared var v-joudoc  as char no-undo format "x(10)".
def     shared var v-Get_Nal as logi.
def var v-ec      as char no-undo format "x(01)".
def var v_trx     as int  no-undo.
def var vj-label  as char no-undo.
def var v-sts     like jh.sts  no-undo.
def var quest     as logi no-undo format "да/нет".
def var v-bplace  as char no-undo.
def var v_sum_lim as deci no-undo. /* сумма*/
def var v-arpname as char no-undo.
def var v-plat    as char no-undo init 'u'.
def var id        as int  no-undo.
def var v-badd1   as char no-undo.
def var v-badd2   as char no-undo.
def var v-badd3   as char no-undo.
/*--------EK---------------*/
def shared var v-nomer     like cslist.nomer no-undo.
def shared var v-ek        as int  no-undo.
def        var v-crc_val   as char no-undo format "xxx".
def        var v-crc_valk  as char no-undo format "xxx".
def        var v-chEK      as char no-undo format "x(20)". /* счет ЭК*/
def        var v-chEK1     as char no-undo format "x(20)". /* счет ЭК для тенге*/
def        var v-chEKk     as char no-undo format "x(20)". /* счет ЭК для комиссии*/
/*------------------------------------*/

/* for finmon */
def var v-monamt  as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl  for jl.
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
def var v-operId   as inte no-undo.
def var v-kfm      as logi no-undo.
def var v-numprt   as char no-undo.
def var v-mess     as int  no-undo.
def var v-dtbth    as date no-undo.
def var v-bdt      as char no-undo.
def var v-regdt    as date no-undo.
def var v-rnn      as char no-undo.
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
define button but label " "  NO-FOCUS.
/* */
def var v-fil      as char   no-undo.
def var v-bankname as char   no-undo.
def var v-spcrc    as char   no-undo. /* список допустимых валют */
def var v-glaaa    as int    no-undo.
def var v-glarp    as int    no-undo.
def var v-aaa      as char   no-undo format "x(20)". /* счет ПК */
def var v-card     as char   no-undo format "x(16)". /*номер ПК*/
def var v_sumkzt   as deci   no-undo. /* сумма в тенге */
def var v-crcc     as char   no-undo. /* буквенный код валюты */
def var phand      as handle no-undo.
def var v_namek    as char   no-undo. /*  клиент*/
def var v-bin      as logi   no-undo.
def var v-label    as char   no-undo init " ИИН клиента            :" .
def var v-labelp   as char   no-undo init " ИИН плательщика        :" .
def var v-id       as int    no-undo.
def var v-arpp     as char   no-undo.
def var v-arppname as char   no-undo.
def var v-mfil     as logi   no-undo.
def var v-filname  as char   no-undo.

def buffer b-pccards for pccards.

{yes-no.i}
{findstr.i}
{kfm.i "new"}
{checkdebt.i &file = "bank"}
{keyord.i}
{srvcheck.i}

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
    message "Нет параметра ourbnk sysc!" view-as alert-box error.
    return.
end.
s-ourbank = trim(sysc.chval).

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if not v-bin  then assign v-label  = " РНН клиента            :"
                          v-labelp = " РНН плательщика        :".

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
                     and bookcod.code    = 'glarpp'
                     no-lock no-error.
if avail bookcod then v-glarp = int(trim(bookcod.name)) no-error.
else do:
    message "В справочнике <pc> отсутствует код <glarpp> для определения ГК счета АРП по ПК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
{chk12_innbin.i}
   form
        v-joudoc  label " Документ               " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"          but skip
        v-crc     label " Валюта                 " format ">9" validate(can-do(v-spcrc,string(v-crc)),"Неверный код валюты! Возможны только коды: " + v-spcrc + "!")
        v-crcc    no-label  colon 28 format "x(03)" skip
        v_sum     label " Сумма                  " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v-arp     label " Транзитный счет (АРП)  " format "x(20)"
        v-arpname no-label  colon 50 format "x(30)" skip(1)
        v-card    label " Номер плат.карточки    " format 'x(16)' skip
        v-aaa     label " Счет по плат.карточке  " format 'x(20)' skip
        v_namek   label " Клиент                 " format "x(40)" skip
        v-label   no-label format 'x(25)' v_rnn  colon 25 no-label format "x(12)" validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip(1)
        v_lname   label " ФИО плательщика        " validate(trim(v_lname) <> "", "Введите ФИО плательщика ") format "x(60)" skip
        v_doc_num label " № докум. и дата выдачи " help "Введите номер докумета удостов. личность и дату выдачи документа" format "x(50)" validate(trim(v_doc_num) <> "", "Заполните номер документа") skip
        v-labelp  no-label format 'x(25)' v_rnnp  colon 25 no-label format "x(12)" help "Введите значение (12 цифр) или '-'"  validate((chk12_innbin(v_rnnp)),'Неправильно введён БИН/ИИН') skip
        v_code    label " КОД                    " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe     label " КБе                    " skip
        v_knp     label " КНП                    " skip
        v_oper    label " Назначение платежа     " skip
        v_oper1   no-label colon 25 skip
        v_oper2   no-label colon 25 skip(1)
        vj-label  no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.

on help of v-card in frame f_main do:
    run h-pc PERSISTENT SET phand.
    v-card = frame-value.
    displ v-card with frame f_main.
end.

on help of v-joudoc in frame f_main do:
    if v-ek = 1 then run a_help-joudoc1 ("CS7"). else run a_help-joudoc1 ("EK7").
    v-joudoc = frame-value.
end.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    release nmbr.
    displ v-joudoc format "x(10)" with frame f_main.
    assign v-ja      = yes
           v-aaa     = ""
           v_namek   = ""
           v_rnn     = ""
           v-arp     = ""
           v-arpname = ""
           v_sum     = 0
           v-crc     = 1
           v-crcc    = ""
           v_lname   = ""
           v_doc_num = ""
           v_rnnp    = ""
           v_oper    = "Пополнение счета по платежной карте "
           v_oper1   = ""
           v_oper2   = ""
           v-arpp    = "".
    run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if avail joudoc then do:
            find first joudop where joudop.docnum = v-joudoc no-lock no-error.
            if avail joudop then do:
                if joudop.type <> "CS7"  and joudop.type <> "EK7" then do:
                    message "Документ не относится к типу взнос наличных денег по плвтежной карте!" view-as alert-box error.
                    return.
                end.
                if v-ek = 1 and joudop.type = "EK7" then do:
                    message "Документ создан для ЭК ГК 100500!" view-as alert-box error.
                    return.
                end.
                if v-ek = 2 and joudop.type = "CS7" then do:
                    message "Документ создан для счета ГК 100100!" view-as alert-box error.
                    return.
                end.
           end.
           if joudoc.jh ne ? then do:
                message "Транзакция уже проведена. Для редактирования удалите транзакцию!" view-as alert-box error.
                return.
            end.
            if joudoc.who ne g-ofc then do:
                message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
                return.
            end.
        end.
        run save_doc.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc with  frame f_main.

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
        message "Не найден счет АРП (ГК " + string(v-glarp) + ", валюта " + v-crcc + ") для пополнения ПК!"  view-as alert-box error.
        undo, return.
     end.
    displ v-arp v-arpname with frame f_main.

    update v-card help "Счет клиента по ПК; F2- помощь; F4-выход" with frame f_main.
    find first pccards where pccards.pcard = v-card and pccards.sts = 'ok' no-lock no-error.
    if avail pccards then do:
    v-card = substr(v-card,1,6) + '******' + substr(v-card,13).
    displ v-card with frame f_main.
        assign /*v_namek = pccards.sname*/
               v-aaa   = pccards.aaa
               /*v_rnn   = if v-bin then pccards.iin else pccards.rnn*/
               v-fil   = 'txb' + substr(pccards.aaa,19,2)
               v-cif   = pccards.cif.
               if pccards.pctype <> "B" then v_kbe = pccards.info[1] + '9'.
               if pccards.sup then do:
                   find first b-pccards where b-pccards.aaa = pccards.aaa and b-pccards.sup = no no-lock no-error.
                   v_namek = b-pccards.sname .
                   v_rnn = b-pccards.iin.
                   v_knp = '119'.
               end.
               else assign v_namek = pccards.sname
                           v_rnn   = pccards.iin.
    end.
    else do:
        message "Неверный счет ПК!"  view-as alert-box error.
        undo.
    end.
    displ v-aaa v_namek v-label v_rnn with frame f_main.
    if v-fil = s-ourbank then v-arpp = v-arp.
    else do:
        v-mfil = yes.
        find first txb where txb.bank =  v-fil no-lock no-error.
        if not avail txb then return.
        v-filname = txb.info.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
        run pcfarp(v-glarp,v-crc,output v-arpp  ,output v-arppname).
        if connected ("txb") then disconnect "txb".
        if v-arpp = '' then do:
            message "Не найден счет АРП (ГК " + string(v-glarp) + ", валюта " + v-crcc + ",филиал " + v-filname + ") для пополнения ПК!"  view-as alert-box error.
            undo, return.
        end.
    end.
    if pccards.pctype <> 'B' then do:
        if yes-no ('', 'Плательщиком является держатель платежной карты?') then do:
            /*assign v_lname   = v_namek
                   v_rnnp    = v_rnn.*/
            assign v_lname   = pccards.sname
                   v_rnnp    = pccards.iin.
            if v-mfil then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
                run pcfdoc(v-cif,output v_doc_num,output v_code).
                if connected ("txb") then disconnect "txb".
                if v_doc_num = '' or v_code = '' then return.
            end.
            else do:
                find first cif where cif.cif = v-cif no-lock no-error.
                if avail cif then do:
                    v_doc_num = cif.pss.
                    find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                    if avail sub-cod then v-ec = sub-cod.ccode.
                    if v-ec = '' or v-ec = 'msc' then do:
                        message "Не заполнен сектор экономики клиента!" view-as alert-box error.
                        undo, return.
                    end.
                    if can-do('021,022',cif.geo) then v_code = substr(cif.geo,3,1) + v-ec.
                    else do:
                        message "Проверьте ГЕО-код клиента!" view-as alert-box error.
                        undo, return.
                    end.
                end.
            end.
            display v_lname v_doc_num v-labelp v_rnnp with frame f_main.
            pause 0.
         end.
         else do:
            repeat:
                message 'u - Уполномоченное лицо, t - Третье лицо'.
                update v-plat no-label skip
                with frame fplat centered row 5 title ' Задайте параметр '.
                hide frame fplat.
                if v-plat ne 'u' and v-plat ne 't' then message 'Выберите U или T !' view-as alert-box error title ' Внимание! '.
                else leave.
            end.
            if keyfunction (lastkey) = "end-error" then undo.
            if v-plat eq 'u' then do:
                if v-mfil then do:
                    if connected ("txb") then disconnect "txb".
                    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
                    run pcfupl(v-cif,v-aaa,output v_lname,output v_doc_num,output v_rnnp).
                    if connected ("txb") then disconnect "txb".
                    if v_lname = '' then do:
                        message "У клиента нет уполномоченных лиц или истек срок доверенности!" view-as alert-box error.
                        undo, retry.
                    end.
                end.
                else do:
                    find first cif where cif.cif = v-cif no-lock no-error.
                    if avail cif then do:
                        find first uplcif where uplcif.cif = cif.cif and uplcif.dop = v-aaa no-error.
                        if avail uplcif then do:
                            {itemlist.i
                            &file    = "uplcif"
                            &frame   = "row 6 centered scroll 1 12 down width 90 overlay "
                            &where   = " uplcif.cif = cif.cif and uplcif.dop = v-aaa and uplcif.finday > today "
                            &findadd = "v-id = v-id + 1."
                            &flddisp = " v-id           label 'N'               format 'zz9'
                                         uplcif.badd[1] label 'Ф.И.О.'          format 'x(20)'
                                         uplcif.rnn     label 'РНН'             format 'x(12)'
                                         uplcif.badd[2] label 'Паспорт.данные'  format 'x(20)'
                                         uplcif.badd[3] label 'Кем/Когда выдан' format 'x(20)'
                                         uplcif.finday  label 'Дата окон.дов.'
                                       "
                            &chkey = "badd[1]"
                            &chtype = "string"
                            &index  = "uplcif"
                            &end = "if keyfunction(lastkey) eq 'end-error' then return."
                           }
                           assign v_lname   = uplcif.badd[1]
                                  v_doc_num = uplcif.badd[2] + " " + uplcif.badd[3]
                                  v_rnnp    = uplcif.rnn.
                        end.
                        else do:
                            message "У клиента нет уполномоченных лиц!" view-as alert-box error.
                            undo, retry.
                        end.
                    end.
                end.
                v_code = '19'.
            end.
            else do:
                assign v_lname    = ''
                       v_doc_num  = ''
                       v_rnnp     = ''
                       v_code     = ''.
                displ v-labelp with frame f_main.
                update v_lname v_doc_num v_rnnp v_code  with frame f_main.
            end.
         end.
     end.
     else update v_lname v_doc_num v_rnnp v_code with frame f_main.
     displ  v_lname v_doc_num v-labelp v_rnnp v_code v_kbe v_knp vj-label with frame f_main.
     if pccards.pctype = 'B' then do:
        find first pcstaff0 where pcstaff0.aaa = pccards.aaa and pcstaff0.iin = pccards.iin no-lock no-error.
        if avail pcstaff0 and pcstaff0.pcprod <> 'STAFCORP' then do:
            find first aaa where aaa.aaa = v-aaa no-lock no-error.
            if avail aaa then find first cif where cif.cif = aaa.cif no-lock no-error.
            v_oper1 = cif.prefix + ' ' + cif.name + ' ' + aaa.aaa.
            v_kbe = ''.
        end.
        else do:
            v_oper1 = 'АО ForteBank ' + v-aaa.
            v_kbe = '14'.
        end.
        v-oper = 'Пополнение счета по платежной карте'.
     end.
     else
     assign v_oper1 = v_namek + (if v-bin then " ИИН " else " РНН ") + v_rnn + " "
            v_oper2 = v-aaa.
     update v_kbe v_oper v_oper1 v_oper2 v-ja with frame f_main.

     if v-ja then do:

        if v-ek = 2 then do:
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then v-chEK = arp.arp.
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
            find first joudoc where joudoc.docnum = v-joudoc exclusive-lock.
            find first joudop where joudop.docnum = v-joudoc exclusive-lock.
        end.
        assign joudoc.who       = g-ofc
               joudoc.whn       = g-today
               joudoc.tim       = time
               joudoc.dramt     = v_sum
               joudoc.dracctype = if v-ek = 2 then "4"    else "1"
               joudoc.dracc     = if v-ek = 2 then v-chEK else ""
               joudoc.drcur     = v-crc
               joudoc.cramt     = v_sum
               joudoc.cracctype = "4"
               joudoc.crcur     = v-crc
               joudoc.cracc     = v-arp
               joudoc.info      = v_lname
               joudoc.perkod    = v_rnnp
               joudoc.remark[1] = v_oper
               joudoc.remark[2] = v_oper1
               joudoc.rescha[3] = v_oper2
               joudoc.chk       = 0
               joudoc.benname   = v_namek
               joudoc.rescha[4] = v-fil + vdel + v-aaa + vdel + v-arpp.

        if num-entries(trim(v_doc_num),",") > 1 or num-entries(trim(v_doc_num)," ") <= 1 then joudoc.passp = trim(v_doc_num).
        else joudoc.passp = entry(1,trim(v_doc_num)," ") + "," + substring(trim(v_doc_num),index(trim(v_doc_num)," "), length(v_doc_num)).
        run chgsts("JOU", v-joudoc, "new").
        find current joudoc no-lock no-error.

        assign joudop.who   = g-ofc
               joudop.whn   = g-today
               joudop.tim   = time
               joudop.lname = v-aaa
               joudop.type  = if v-ek = 1 then "CS7" else "EK7".
        find current joudop no-lock no-error.

        find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
        if not available sub-cod then do:
            create sub-cod.
            assign sub-cod.acc    = v-joudoc
                   sub-cod.sub    = "jou"
                   sub-cod.d-cod  = "eknp"
                   sub-cod.ccode  = "eknp".
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
    if trim(v-joudoc) = "" then return.
    displ v-joudoc with frame f_main.

    find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box error.
        return.
    end.
    find first joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "CS7"  and joudop.type <> "EK7" then do:
            message "Документ не относится к типу взнос наличных денег по платежной карте!" view-as alert-box error.
            return.
        end.
        if v-ek = 1 and joudop.type = "EK7" then do:
            message "Документ создан для ЭК ГК 100500!" view-as alert-box error.
            return.
        end.
        if v-ek = 2 and joudop.type = "CS7" then do:
            message "Документ создан для счета ГК 100100!" view-as alert-box error.
            return.
        end.
    end.
    if joudoc.jh > 1 and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box error.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
        return.
    end.
    assign v_trx     = joudoc.jh
           v-arp     = joudoc.cracc
           v_sum     = joudoc.dramt
           v-crc     = joudoc.drcur
           v_oper    = joudoc.remark[1]
           v_oper1   = joudoc.remark[2]
           v_oper2   = joudoc.rescha[3]
           v_lname   = joudoc.info
           v_doc_num = joudoc.passp
           v_rnn     = joudoc.perkod
           v_rnnp    = joudoc.perkod
           v_namek   = joudoc.benname
           v-aaa     = joudop.lname.
    find first crc where crc.crc = v-crc no-lock no-error.
    if avail crc then v-crcc = crc.code.

    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then v-arpname = arp.des.


    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then assign v_code = entry(1,sub-cod.rcode,',')
                                 v_kbe  = entry(2,sub-cod.rcode,',')
                                 v_knp  = entry(3,sub-cod.rcode,',').
    v-ja = yes.
    displ v-joudoc v_trx v-crc v-crcc v_sum v-arp v-arpname v-aaa v_namek v-label v_rnn v_lname v_doc_num v-labelp v_rnnp  v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc.
        find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено!" view-as alert-box error.
                undo, return.
            end.
            if joudoc.who ne g-ofc then do:
               message substitute (
                  "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box error.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                find first joudoc where joudoc.docnum = v-joudoc no-error.
                if available joudoc then delete joudoc.
                find first joudoc no-lock no-error.
                for each substs where substs.sub = "jou" and  substs.acc = v-joudoc.
                    delete substs.
                end.
                find first cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-error.
                if available cursts then delete cursts.

                find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp"  no-error.
                if avail sub-cod then delete sub-cod.
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
    run view_doc.
    if keyfunction (lastkey) = "end-error" then undo, return.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box error.
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
            if avail sub-cod then v-chEK1 = arp.arp.
        end.
        if v-chEK1 = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте KZT!" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
            if avail sub-cod then v-chEK = arp.arp.
        end.
        if v-chEK = '' then do:
            message "Не настроен АРП счет ЭК ГК 100500 " + v-nomer + " в валюте " + v-crcc + " !" view-as alert-box title " ОШИБКА ! ".
            undo, return.
        end.

        assign s-jh    = 0
               v-tmpl  = "JOU0055"
               v-param = v-joudoc + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chEK + vdel + v-arp + vdel + (v_oper + v_oper1 + v_oper2)
                + vdel + substr(v_code,1,1) + vdel + substr(v_kbe,1,1) + vdel + substr(v_code,2,1) + vdel + substr(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.

        find first jh where jh.jh = s-jh exclusive-lock.
        jh.party = v-joudoc.
        if jh.sts < 5 then jh.sts = 5.
        for each jl of jh:
            if jl.sts < 5 then jl.sts = 5.
        end.
        find current jh no-lock.

        find first joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        if v-crc = 1 then joudoc.srate = 1.
        else do:
            find first crc where  crc.crc = v-crc no-lock no-error.
            joudoc.srate = crc.rate[3].
            joudoc.sn = 1.
        end.
        joudoc.brate = 1.
        find current joudoc no-lock no-error.

    end. /* end v-ek = 2  */

    /* CASH 100100-------------------------------------------------*/
    if v-ek = 1 then do:
        /* для суммы пополнения        */
        assign v-tmpl  = "JOU0027"
               v-param = /*v-joudoc + vdel + */ string(v_sum) + vdel + string(v-crc) + vdel + v-arp + vdel + (v_oper + v_oper1 + v_oper2)
                    + vdel + substring(v_code,1,1) + vdel + substring(v_kbe,1,1) + vdel + substring(v_code,2,1) + vdel + substring(v_kbe,2,1) + vdel + v_knp.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
    end.
        /*---------------------------------------------------------*/
    run chgsts(m_sub, v-joudoc, "trx").
    pause 1 no-message.
    find first joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
    joudoc.jh = s-jh.
    find current joudoc no-lock no-error.

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

    if v-ek = 1 then do:
        run trxsts (input s-jh, input 5, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return.
        end.
        run chgsts("jou", v-joudoc, "cas").
    end.
    if v-crc = 1 then do:
        find first jh where jh.jh = s-jh no-lock no-error.
        for each jl of jh use-index jhln where (jl.gl = 100100 or jl.gl = 100500) and jl.crc = 1 no-lock
        break by jl.jh by jl.crc:
            create jlsach .
            assign jlsach.jh   = jl.jh
                   jlsach.amt  = jl.dam + jl.cam
                   jlsach.ln   = jl.ln
                   jlsach.lnln = 1
                   jlsach.sim  = 20.
        end.
    end.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc no-error no-wait.
    if not avail joudoc then do:
        if locked joudoc then message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ!" view-as alert-box error.
        else message "ДОКУМЕНТА НЕТ!" view-as alert-box error.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box error.
        undo, return.
    end.
    find first pcpay where pcpay.jou  = v-joudoc no-lock no-error.
    if available pcpay and pcpay.sts = "send" then do:
        message "Транзакция не может быть удалена. Файл OW сформирован. Обратитесь в Департамент платежных карточек!" view-as alert-box error.
        undo, return.
    end.
    if available pcpay and pcpay.sts <> "send" then do:
        find first remtrz where remtrz.remtrz = pcpay.ref no-lock no-error.
        if available remtrz then do:
            message "Был создан RMZ документ. Необходимо удалить " + pcpay.ref + " документ!" view-as alert-box error.
            undo, return.
        end.
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
            message "Транзакция акцептована кассиром. Удалять нельзя." view-as alert-box error.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалять нельзя" view-as alert-box error.
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
                               cashofc.sts = 2
                               cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.
        end.
        /* удаляем запись в pcpay */
        find first pcpay where pcpay.jou  = v-joudoc and trim(pcpay.jou) <> "" exclusive-lock no-error.
        if available pcpay and trim(pcpay.jou) <> "" then delete pcpay.
        find first pcpay no-lock no-error.

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.

    end. /* transaction */

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

    do transaction:
        s-jh = joudoc.jh.
        run vou_word (2, 1, joudoc.info).
    end. /* transaction */
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
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
    run a_stamp(joudoc.jh).
    pause 0.
    hide all.
    view frame f_main.
end.
