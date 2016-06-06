/* a_pc1.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Переводы со счета клиента на счет ПК (внутренние)
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        23.07.2012 id00810 (на основе a_cas3.p)
 * CHANGES
        16/11/2012 добавила обработку статуса KFMONLINE
                   if trim(v-errorDes) <> '' or v-operStatus = "0" or v-operStatus = "2" then return.
        23/11/2012 id00810 - ТЗ 1594 поиск счета ARP по sysc
        12/12/2012 id00810 - переход на ИИН/БИН (корректировка назначения платежа)
        15.01.2013 Lyubov - РНН поправила на ИИН
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        25/06/2013 Luiza ТЗ 1855
        18/07/2013 Luiza - ТЗ 1967 откат по F4
        23/07/2013 Luiza  - ТЗ 1935
        31/10/2013 Luiza - ТЗ 2171 Выбор основного держателя
*/

/*{mainhead.i}*/
def input param new_document as logi no-undo.
def       var   m_sub        as char no-undo init "jou".
def shared var v_u   as int no-undo.
def shared var g-ofc as char.

def var v-tmpl  as char no-undo init "JOU0028".
def var vdel    as char no-undo init "^".
def var v-param as char no-undo.
def var rcode   as int  no-undo.
def var rdes    as char no-undo.
def var v_title as char no-undo init " Переводы со счета клиента на счет по ПК (внутренние) " . /*наименование платежа */
def var v_sum   as deci no-undo. /* сумма*/
def var v-crc   as int  no-undo .  /* Валюта*/
def var v-chet  as char no-undo format "x(20)". /* счет клиента */
def var v-chetp as char no-undo format "x(20)". /* счет клиента */
def var v-cif   as char no-undo format "x(06)". /* cif клиент */
def var v-cif1  as char no-undo format "x(06)". /*  клиент */
def var v_name  as char no-undo format "x(30)". /*  клиент */
def var v-namep as char no-undo format "x(30)". /*  клиент */
def var v_code  as char no-undo format "x(02)". /* КОД */
def var v_kbe   as char no-undo format "x(02)". /* КБе */
def var v_knp   as char no-undo format "x(03)" init '119'. /* КНП */
def var v-ja    as logi no-undo format "Да/Нет".
def var v_oper  as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var ss-jh   as int  no-undo.
def var v-gl    as int  no-undo.
def var v_trx   as int  no-undo.
def var vj-label as char no-undo.
def var v-ec     as char no-undo.
def var quest    as logi no-undo format "да/нет".
def var v-sts    like jh.sts  no-undo.
def new shared var v-joudoc as char format "x(10)" no-undo.
def new shared var v_doc    as char format "x(10)" no-undo.
def new shared var s-cif    like cif.cif.
def new shared var flg1     as log.
def new shared var s-jh     like jh.jh.

/* for finmon */
def var v_doc_num as char no-undo.
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
def var v-num      as int  no-undo.
def var v-operId   as int  no-undo.
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
def var v-addr      as char no-undo.
def var v-country22 as char no-undo.
def var famlist     as char no-undo.
def var v_docwho    as char no-undo.
def var v_docdt     as date no-undo.
def var v-bdt1      as date no-undo.
def var v_rez       as char no-undo.
def var v_countr    as char no-undo.
def var v_countr1   as char no-undo.
def var v_lname1    as char no-undo format "x(20)".
def var v_name1     as char no-undo format "x(20)".
def var v_mname1    as char no-undo format "x(20)".
def var v_addr      as char no-undo.
def var v_tel       as char no-undo.
def var v_public    as char no-undo.
def var v_doctype   as char no-undo.
def var v-cifmin    as char no-undo.
def var v-bplace    as char no-undo.
def var v-knpval    as char no-undo.
def var v_lname     as char no-undo format "x(20)".
def var v_mname     as char no-undo format "x(20)".

def var v-ref       as char no-undo init 'б/н'.
def var v-viddoc    as char no-undo init '01'.
def var v-crcc      as char no-undo format "xxx".

/* для комиссии*/
/*def var v-crctrf as int.
def var tmin1 as decim.
def var tmax1 as decim.
def var v-amt as decim.
def var tproc as decim.
def var v-err as log .
def var pakal as char.
def var v_comname as char.*/

def stream v-out.
def var v-file      as char no-undo init "Application3.htm".
def var v-inputfile as char no-undo.
def var v-naznplat  as char no-undo.
def var v-str       as char no-undo.
def var i           as inte no-undo.
def var decAmount   as deci no-undo decimals 2.
def var strAmount   as char no-undo.
def var temp        as char no-undo.
def var str1        as char no-undo.
def var str2        as char no-undo.
def var strTemp     as char no-undo.
def var numpassp    as char no-undo. /*Номер Удв*/
def var whnpassp    as char no-undo. /*Когда выдан*/
def var whopassp    as char no-undo. /*Кем выдан*/
def var perpassp    as char no-undo. /*Срок действия*/
def var v-bin       as logi no-undo.
/* */
def var v-aaa       as char no-undo.
def var v-arp       as char no-undo.
def var v-arpname   as char no-undo.
def var v-spcrc     as char no-undo. /* список допустимых валют */
def var v-glarp     as int  no-undo.
def var v-fil       as char no-undo.
def var v-spgl      as char no-undo.
def var v-glpc      as char no-undo.
def var v-spknp     as char no-undo.
def var v_namep     as char no-undo.
def var v_rnnp      as char no-undo.
def var v_rnn       as char no-undo.
def var v-rnnp      as char no-undo.
def var v-led       as char no-undo.
def var v-label     as char no-undo init " ИИН клиента           :" .
def var v-labelp    as char no-undo init " ИИН получателя        :" .
define button but label " ".

{findstr.i}
{kfm.i "new"}
{checkdebt.i &file = "bank"}
{keyord.i}
{srvcheck.i}

/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "There is no record OURBNK in bank.sysc file!!!" view-as alert-box error.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

find first cmp no-lock no-error.
if avail cmp then assign v_namep = cmp.name
                         v_rnnp  = cmp.addr[3].

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if not v-bin  then assign v-label  = " РНН клиента           :"
                          v-labelp = " РНН получателя        :"  .

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'crc'
                     no-lock no-error.
if avail bookcod then v-spcrc = bookcod.name.
else do:
    message "В справочнике <pc> отсутствует код <crc> для определения допустимых валют!~nОбратитесь к администратору АБС!" view-as alert-box error.
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

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'glaaap'
                     no-lock no-error.
if avail bookcod then v-spgl = bookcod.name.
else do:
    message "В справочнике <pc> отсутствует код <glaaap> для определения допустимых для перевода счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'glpc'
                     no-lock no-error.
if avail bookcod then v-glpc = bookcod.name.
else do:
    message "В справочнике <pc> отсутствует код <glpc> для определения допустимых карточных счетов ГК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'knpp'
                     no-lock no-error.
if avail bookcod then v-spknp = bookcod.name.
else do:
    message "В справочнике <pc> отсутствует код <knpp> для определения допустимых КНП перевода на счетов ПК!~nОбратитесь к администратору АБС!" view-as alert-box error.
    return.
end.
  {chk12_innbin.i}
   form
        v-joudoc label " Документ              " format "x(10)"   v_trx label "           ТРН " format "zzzzzzzzz"           but skip
        v-viddoc label " Вид документа         " format "x(02)"   v-ref label "         Nr.плат.поруч " format "x(03)" skip(1)
        v-chet   label " Счет клиента(плательщ)" format "x(20)" validate(can-find(first aaa where aaa.aaa = v-chet and can-do(v-spgl,string(aaa.gl)) and can-do(v-spcrc,string(aaa.crc)) and aaa.sta <> "C" and aaa.sta <> "E" no-lock),
                "Неверный счет клиента, воспользуйтесь помощью по F2") skip
        v_name   label " Клиент                "  format "x(60)" skip
        v-label  no-label format 'x(25)' v_rnn  no-label format "x(12)" colon 24 validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip(1)
        v-crc    label " Валюта                " format "9"       v-crcc no-label  colon 28 format "x(03)" skip
        v_sum    label " Сумма                 " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip(1)
        v-aaa    label " Счет по плат.карточке " format 'x(20)' skip
        v-namep  label " Клиент                " format "x(60)" skip
        v-labelp no-label format 'x(25)' v-rnnp  no-label format "x(12)" colon 24 validate((chk12_innbin(v-rnnp)),'Неправильно введён БИН/ИИН') skip(1)
        v-arp    label " Транзитный счет (АРП) " format "x(20)"   v-arpname no-label  colon 50 format "x(30)" skip(1)
        v_code  label  " КОД                   " skip
        v_kbe   label  " КБе                   " skip
        v_knp   label  " КНП                   " validate(can-find(first codfr where codfr.codfr = "spnpl" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_knp no-lock), "Нет такого кода КНП! F2-помощь") skip
        v_oper  label  " Назначение платежа    " format "x(50)" skip
        v_oper1 no-label  colon 25 format "x(50)" skip
        v_oper2 no-label  colon 25 format "x(50)" skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 100 FRAME f_main.

DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.

on help of v-joudoc in frame f_main do:
    run a_help-joudoc1 ("CS8").
    v-joudoc = frame-value.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

on help of v-aaa in frame f_main do:
    run h-pc PERSISTENT SET phand.
    v-aaa = frame-value.
    find first pccards where pccards.pcard = v-aaa  and pccards.sts = 'ok' no-lock no-error.
    if available pccards then v-aaa = pccards.aaa.
    else v-aaa = "".
    displ v-aaa with frame f_main.
end.

on choose of but in frame  f_main do:
    hide all.
    if this-procedure:persistent then delete procedure this-procedure.
    return.
end.
on "END-ERROR" of v-chet in frame f_main do:
  return.
end.

on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
end.

on help of v-chet in frame f_main do:
    on "END-ERROR" of frame f-help do:
    end.
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" and can-do(v-spgl,string(aaa.gl)) and can-do(v-spcrc,string(aaa.crc)) no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" and can-do(v-spgl,string(aaa.gl)) and can-do(v-spcrc,string(aaa.crc)) no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-chet = aaa.aaa.
            hide frame f-help.
            displ v-chet with frame f_main.
        end.
        else do:
            v-chet = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-chet with frame f_main.
            return.
        end.
    end.
    DELETE PROCEDURE phand.
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find first nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    displ v-joudoc format "x(10)" with frame f_main.
    assign v-ja    = yes
           v-aaa   = ""
           v-chet  = ""
           v-arp   = ""
           v-arpname = ""
           v_sum   = 0
           v-crc   = ?
           v-crcc  = ""
           v_code  = ""
           v_knp   = ""
           v_oper  = ""
           v_oper1 = ""
           v_oper2 = "".
    run save_doc.
end.  /* end new document */
else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        vj-label  = " Сохранить изменения документа?...........".
        run view_doc.
        find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if available joudoc then do:
            find first joudop where joudop.docnum = v-joudoc no-lock no-error.
            if available joudop then do:
                if joudop.type <> "CS8" then do:
                    message "Документ не относится к типу переводы со счета клиента на счет по ПК." view-as alert-box error.
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
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ v-joudoc v-viddoc v-ref with  frame f_main.

    update  v-chet help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then do:
        assign v-cif = aaa.cif
               v-crc = aaa.crc
               v-gl  = aaa.gl.
        find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr then v-led = lgr.led.
    end.

    find first crc where crc.crc = v-crc no-lock.
    v-crcc = crc.code.

    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        assign v_name  = trim(trim(cif.prefix) + " " + trim(cif.name))
               v_rnn   = if v-bin then cif.bin else cif.jss.

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

    displ v_name v-label v_rnn no-label v-crc v-crcc v_code v_oper vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    update v_sum  with frame f_main.
    if lookup(string(aaa.gl),v-glpc) > 0 then do:
        v-aaa = v-chet.
        displ v-aaa with frame f_main.
        find first pcstaff0 where pcstaff0.aaa = v-aaa no-lock no-error.
        if avail pcstaff0 then do:
            assign v-namep = trim(pcstaff0.sname)  + " " + trim(pcstaff0.fname)  + " " + trim(pcstaff0.mname)
                                     v-rnnp  = pcstaff0.iin
                                     v-fil   = 'txb' + substr(pcstaff0.aaa,19,2).
            if pcstaff0.country = "KAZ" then v_kbe   = '19'. else v_kbe   = '29'.
        end.
        else do:
            message "Неверный счет ПК"  view-as alert-box error.
            undo.
        end.
    end.
    else do:
        update v-aaa help "Счет клиента по ПК; F2- помощь; F4-выход" with frame f_main.
        find first aaa where aaa.aaa = v-aaa no-lock no-error.
        if not available aaa then do:
            message "Не найден счет клиента!"  view-as alert-box error.
            undo.
        end.
        find first pccards where pccards.aaa = v-aaa no-lock no-error.
        if avail pccards then assign v-namep = pccards.sname
                                     v-rnnp  = if v-bin then pccards.iin else pccards.rnn
                                     v-fil   = 'txb' + substr(pccards.aaa,19,2)
                                     v_kbe   = pccards.info[1] + '9'.
        else do:
            message "Неверный счет ПК!"  view-as alert-box error.
            undo.
        end.
    end.
    if v-fil <> s-ourbank then do:
        message "Счет по ПК принадлежит клиенту другого филиала!~nТакие операции не предусмотрены в этом пункте меню!"  view-as alert-box error.
        undo, return.
    end.
    if can-do('CDA,TDA',v-led) and v-rnnp <> v_rnn then do:
       message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только со счетов до востребования!"  view-as alert-box error.
       undo, return.
    end.

    /*v_knp = entry(lookup(string(v-gl),v-spgl),v-spknp) no-error.*/
    if v-rnnp = v_rnn then v_knp = "321".
    else v_knp = "119".
    displ v-namep v-labelp v-rnnp /*no-label*/ /*v-crcp*/  v_kbe  with frame f_main.
    update v_knp  with frame f_main.

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
    if v_rnn <> v-rnnp then v_oper  = "Мат. помощь, перевод со счета клиента на счет по ПК ".
    else v_oper  = "Перевод со счета клиента на счет по ПК".
    assign v_oper1 = v-namep + (if v-bin then " ИИН " else " РНН ") + v-rnnp + " "
            v_oper2 = v-aaa.
    displ  v_kbe v_knp v_oper v_oper1 v_oper2 with frame f_main.
    update v_oper v_oper1 v_oper2 v-ja with frame f_main.

  if v-ja then do:
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
    assign  joudoc.who       = g-ofc
            joudoc.whn       = g-today
            joudoc.tim       = time
            joudoc.dramt     = v_sum
            joudoc.dracctype = "2"
            joudoc.dracc     = v-chet
            joudoc.drcur     = v-crc
            joudoc.cramt     = v_sum
            joudoc.cracctype = "4"
            joudoc.crcur     = v-crc
            joudoc.cracc     = v-arp
            joudoc.remark[1] = v_oper
            joudoc.remark[2] = v_oper1
            joudoc.rescha[3] = v_oper2
            joudoc.chk       = 0
            joudoc.num       = v-ref
            joudoc.info      = v_name
            joudoc.benname   = v-namep
            joudoc.perkod    = v-rnnp
            joudoc.rescha[4] = v-fil + vdel + v-aaa + vdel + v-arp.
            run chgsts("JOU", v-joudoc, "new").
    find current joudoc no-lock no-error.
    assign joudop.who   = g-ofc
           joudop.whn   = g-today
           joudop.tim   = time
           joudop.lname = v-aaa
           joudop.type  = "CS8".
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

    find first sub-cod where sub-cod.sub = 'jou' and sub-cod.acc = v-joudoc and sub-cod.d-cod = 'pdoctng' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub   = 'jou'
               sub-cod.acc   = v-joudoc
               sub-cod.d-cod = 'pdoctng'.
    end.
    find current sub-cod exclusive-lock.
    assign sub-cod.ccode = v-viddoc
           sub-cod.rdt   = g-today.
    find current sub-cod no-lock no-error.
    displ v-joudoc with frame f_main.

   /* if v-crc <> 1 or substring(v_code,1,1) = "2" or substring(v_kbe,1,1) = "2" then do:
        message "Платеж должен пройти контроль Департаментом Валютного контроля 9.11 !"  view-as alert-box.
        run mail ("DVKG@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
            "Добрый день!\n\n Необходимо отконтролировать внутренний перевод со счета клиента \n Сумма: " + string(v_sum) +
            "  " + v-crcc + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
            string(time,"HH:MM"), "1", "","" ).
            hide all.
            view frame f_main.
    end.*/
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

    find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box error.
        undo, return.
    end.
    find first joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if joudop.type <> "CS8" then do:
            message "Документ не относится переводам со счета клиента на счет по ПК!" view-as alert-box error.
            return.
        end.
    end.
    if joudoc.jh ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию!" view-as alert-box error.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box error.
        return.
    end.
    assign v_trx   = joudoc.jh
           v-chet  = joudoc.dracc
           v-arp   = joudoc.cracc
           v_sum   = joudoc.dramt
           v-crc   = joudoc.drcur
           v_oper  = joudoc.remark[1]
           v_oper1 = joudoc.remark[2]
           v_oper2 = joudoc.rescha[3]
           v-ref   = joudoc.num
           v-aaa   = joudop.lname
           v-rnnp  = joudoc.perkod
           v-namep = joudoc.benname.
    find first crc where crc.crc = v-crc no-lock.
    v-crcc = crc.code.

    find first arp where arp.arp = v-arp no-lock no-error.
    if avail arp then v-arpname = arp.des.

    find first aaa where aaa.aaa = v-chet no-lock no-error.
    if avail aaa then
    assign v-cif = aaa.cif
           v-gl  = aaa.gl.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then
    assign v_name  = trim(trim(cif.prefix) + " " + trim(cif.name))
           v_rnn   = if v-bin then cif.bin else cif.jss.

    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then
    assign v_code = entry(1,sub-cod.rcode,',')
           v_kbe  = entry(2,sub-cod.rcode,',')
           v_knp  = entry(3,sub-cod.rcode,',').
    find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = v-joudoc and sub-cod.d-cod = "pdoctng" no-lock no-error.
    if avail sub-cod then v-viddoc = entry(1,sub-cod.ccode,',').
    v-ja = yes.
    displ v-joudoc v-viddoc v-ref v_trx v-chet v_name v-label v_rnn v-arp v-arpname v-crc v_sum v-aaa v-namep v-labelp v-rnnp /*no-label*/ v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc.

        find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box error.
                undo, return.
            end.
            if joudoc.who ne g-ofc then do:
               message substitute ("Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box error.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                find first joudoc where joudoc.docnum = v-joudoc no-error.
                if available joudoc then delete joudoc.
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
  /*  if joudoc.rescha[2] = "" and (v-crc <> 1  or substring(v_code,1,1) = "2" or substring(v_kbe,1,1) = "2") then do:
        message "Документ подлежит валютному контролю в п.м. 9.11 " view-as alert-box error.
        undo, return.
    end.*/

    /*комплаенс*/
    assign v_rez    = v_code
           v-knpval = v_knp
           v_doc    = v-joudoc.
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
    displ vj-label format "x(35)" no-label with frame f_main.
    pause 0.
    update v-ja no-label with frame f_main.
    if not v-ja  then do:
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide frame f_main.
        return.
    end.

    /* транзакция */
    assign s-jh = 0
           v-param = v-tmpl + vdel + string(v_sum) + vdel + string(v-crc) + vdel + v-chet + vdel + v-arp + vdel
                + (v_oper + v_oper1 + v_oper2) + vdel + v_knp.
    run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.
        pause.
        undo, return.
    end.
    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v-joudoc.
    find current jh no-lock no-error.

    run trxsts (input s-jh, input 5, output rcode, output rdes).
    if rcode ne 0 then do:
        message rdes.
        return.
    end.
    run chgsts(m_sub, v-joudoc, "trx").
    pause 1 no-message.
    find first joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error no-wait.
    joudoc.jh = s-jh.
    find current joudoc no-lock no-error.

    if v-noord = yes then run printvouord(2).

    v_trx = s-jh.
    display v_trx with frame f_main.
    pause 0.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + "~nДанный документ подлежит контролю в п.м. 2.4.1.3" view-as alert-box.
    for each sendod no-lock.
        run mail(sendod.ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Контроль документа",
        "Добрый день!\n\n Необходимо отконтролировать платеж со счета клиента на счет по ПК \n Сумма: " + string(v_sum) +
        "  " + v-crcc + "\n документ :" + v-joudoc + "\n создал :" + g-ofc + "\n " + string(g-today) + "  " +
        string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.
    view frame f_main.
    pause 0.
    run chgsts("jou", v-joudoc, "bac").
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find first joudoc where joudoc.docnum eq v-joudoc no-error no-wait.
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
    ss-jh = joudoc.jh.
    find first jh where jh.jh eq joudoc.jh no-lock no-error.
    /* ------------storno ?????????-----------------*/
    do transaction on error undo, return:
        quest = false.
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then undo, return.
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
    end.

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.

    end. /* transaction */
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
    /*run vou_bankt(2, 1, joudoc.info).*/
    if v-noord = no then run vou_bankt(2, 1, joudoc.info).
    else do:
        run printord(s-jh,"").
    end.
end procedure.

procedure print_statement:
    v-chetp = v-arp.
    find first joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if avail joudoc then do:
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if v-crc = 1 then do:
            {a_cas3printapp.i}
        end.
        else do:
            {a_cas3printapp2.i}
        end.
    end.
end procedure.

procedure prtppp1:
    define var o_err  as log init false. /* Customer's Account  */

    def var in_cif like cif.cif                   no-undo.
    def var in_acc like aaa.aaa                   no-undo.
    def var in_jh   as char init ""               no-undo.
    def var in_ln   as char init ""               no-undo.
    def var crccode like crc.code                 no-undo.
    def var p_mem   as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
    def var p_memf  as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
    def var p_pld   as char init "" format "x"    no-undo.  /*   Дебетовое платежное поручениеPut plat.por. deb. */
    def var p_uvd   as char init "" format "x"    no-undo.  /*   Кредитовое уведомление Put plat.por. deb.       */
    def var v-ok    as log                        no-undo.
    def var in_command as char init "prit"        no-undo.
    def var in_destination as char init "dok.img" no-undo.
    def var partkom as char                       no-undo.
    def var vans    as log init true              no-undo.
    def var m-rtn   as log                        no-undo.
    def var s-rem   as char                       no-undo.
    def var v-cifname as char format "x(40)"      no-undo.

    find first jl where jl.acc = joudoc.cracc and jl.jh = joudoc.jh no-lock no-error.
    if not avail jl then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.
    in_acc = jl.acc.
    in_jh  = string(jl.jh).
    in_ln =  string(jl.ln).
    p_mem="".
    p_memf="".
    p_pld="1".


    unix silent rm -f value("dok.img").

    display " Ждите, производится формирование документа по операции " in_jh with frame c3 no-label . pause 0.
    run vipdokln(in_jh,in_ln,in_acc,p_mem,p_memf,p_pld,p_uvd,output o_err).
    if opsys <> "UNIX" then return "0".
    if in_command <> ? then do:
        partkom = in_command + " " + in_destination.
    end.
    else do:
        find first ofc where ofc.ofc = userid("bank") no-lock no-error.
        if available ofc and ofc.expr[3] <> ""
        then do:
             partkom = ofc.expr[3] + " " + in_destination.
        end.
        else return "0".
    end.
    unix silent cptwin value("dok.img") winword.
    pause 0.
    hide frame c3.
    /*view frame f_main.*/
end procedure.
