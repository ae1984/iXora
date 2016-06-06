/* a_pc2.p
 * MODULE
       Клиентские операции
 * DESCRIPTION
        Переводы  со счета клиента на счет ПК (межфилиальные)
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        27.07.2012 id00810 (на основе a_kz1.p)
 * CHANGES
        23/11/2012 id00810 - добавлен поиск v-crc
        12/12/2012 id00810 - переход на ИИН/БИН (корректировка назначения платежа, реквизитов бенефициара)
        10/04/2013 Luiza ТЗ № 1515 Оповещение менеджера о клиенте
        25/06/2013 Luiza ТЗ 1855
        31/10/2013 Luiza - ТЗ 2168 Переводы с текущего счета по ПК в АВС на 286012
 */

{mainhead.i}

def input param new_document as logi.
def shared var v_u as int no-undo.

def var rcode   as int  no-undo.
def var rdes    as char no-undo.
def var v_title as char no-undo init " Переводы со счета клиента на счет по ПК (межфилиальные) ".
def var v_sum   as deci no-undo. /* сумма*/
def var v-crc   as int  no-undo. /* Валюта*/
def var v-pnp   as char no-undo format "x(20)". /* счет клиента */
def var v-chetp as char no-undo format "x(20)". /* счет клиента */
def var v-cif   as char no-undo format "x(06)". /* cif клиент */
def var v_name  as char no-undo format "x(30)". /* клиент */
def var v_namep as char no-undo format "x(30)". /* клиент */
def var v-cif1  as char no-undo format "x(06)". /* клиент */
def var v_code  as char no-undo format "x(02)". /* КОД */
def var v_kbe   as char no-undo format "x(2)".  /* КБе */
def var v_knp   as char no-undo format "x(3)".  /* КНП */
def var v-ja    as logi no-undo format "Да/Нет".
def var v_oper  as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_oper1 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper2 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_oper3 as char no-undo format "x(55)".  /* Назначение платежа*/
def var v_doc_num as char format "x(30)".
def shared var s-remtrz like remtrz.remtrz.
def var v-name as char.
def var v-templ as char.
def var v-ec as char format "x(1)" no-undo.
def var v_trx as int no-undo.
def  var vj-label as char no-undo.
define new shared variable s-jh like jh.jh.
define variable v-sts like jh.sts  no-undo.
define variable quest as logical format "да/нет" no-undo.
def var v-reg5 as char format "x(12)".
def var ourbank like bankl.bank no-undo.
def var v-gl as int.

def buffer xaaa  for aaa.
def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer d-aaa for aaa.
def buffer d-cif for cif.
def var l-ans as logical no-undo.
def new shared var s-aaa like aaa.aaa.
def new shared  var v_crc as int no-undo.
def var v-countr  as char no-undo init 'KZ'.
def var v-viddoc  as char no-undo init '01'.
def var v-ks      as char format 'x(6)'. /* v-ba */
def var v_countr1 as char no-undo.

def var  v-rnnp as char.
def var  v-lbank as char.
def var  v-nbank  as char.
def var  v-date  as date.
def var  v-pol1  as char.
def var  v-pol2  as char.
def var  v-pol3   as char.

def stream v-out.
def var v-file      as char init "Application.htm".
def var v-inputfile as char init "".
def var v-naznplat  as char.
def var v-str       as char.
def var i           as inte.
def var decAmount   as deci decimals 2.
def var strAmount   as char init "".
def var temp        as char init "".
def var str1        as char init "".
def var str2        as char init "".
def var strTemp     as char init "".
def var numpassp    as char. /*Номер Удв*/
def var whnpassp    as char. /*Когда выдан*/
def var whopassp    as char. /*Кем выдан*/
def var perpassp    as char. /*Срок действия*/

define button but label " "  NO-FOCUS.

def var v-ref    as char no-undo init "б/н".
def var v-priory as char no-undo init "o".
def var v-transp as int  no-undo init 5.

def var v-label     as char no-undo init " ИИН клиента       :" .
def var v-labelp    as char no-undo init " ИИН получателя    :" .
def var v_rnn       as char no-undo.
def var v_rnnp      as char no-undo.
def var v-aaa       as char no-undo.
def var v-arp       as char no-undo.
def var v-arpname   as char no-undo.
def var v-chet      as char no-undo.
def var v-spcrc     as char no-undo. /* список допустимых валют */
def var v-glarp     as int  no-undo.
def var v-fil       as char no-undo.
def var v-filname   as char no-undo.
def var v-spgl      as char no-undo.
def var v-glpc      as char no-undo.
def var v-spknp     as char no-undo.
def var v-led       as char no-undo.
def var v-crcc      as char no-undo.
def var v-bb        as char no-undo.
def var s-ourbank   as char no-undo.

/*проверка банка*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!!" view-as alert-box error.
    hide message.
    return.
end.
ourbank = sysc.chval.
s-ourbank = trim(sysc.chval).

{lgps.i}
pause 0.
{chk12_innbin.i}
pause 0.
{chbin.i}
pause 0.

find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if not v-bin  then assign v-label  = " РНН клиента       :"
                          v-labelp = " РНН получателя    :"  .
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

   form
        s-remtrz label " Документ          " format "x(10)"    v_trx label   "                     ТРН " format "zzzzzzzzz"           but skip
        v-viddoc label " Вид документа     " format "x(02)" skip
        v-ref    label " Nr.плат.поруч     " format "x(03)" skip
        v-priory label " Приоритет         " format "x(01)" skip
        v-pnp    label " Счет клиента      " format "x(20)" validate(can-find(first aaa where aaa.aaa = v-pnp and lookup(string(aaa.gl),v-glpc) = 0 and can-do(v-spgl,string(aaa.gl)) and can-do(v-spcrc,string(aaa.crc)) and aaa.sta <> "C" and aaa.sta <> "E" no-lock),
                "Неверный счет клиента, воспользуйтесь помощью по F2") skip
        v_name   label " Клиент            " format "x(50)" skip
        v-label  no-label format 'x(20)' v_rnn  no-label format "x(12)" colon 20 validate((chk12_innbin(v_rnn)),'Неправильно введён БИН/ИИН') skip(1)
        v-crc    label " Валюта перевода   " format "9" validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!") skip
        v_sum    LABEL " Сумма             " validate(v_sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip(1)
        v-aaa    label " Счет по плат.карт." format 'x(20)' skip
        v_namep  label " Клиент            " format "x(50)" skip
        v-labelp no-label format 'x(20)' v_rnnp  no-label format "x(12)" colon 20 validate((chk12_innbin(v_rnnp)),'Неправильно введён БИН/ИИН') skip(1)
        v-fil    label " Филиал            " format "x(03)" v-filname no-label colon 25 format "x(30)" skip
        v-arp    label " Транзитн.счет(АРП)" format "x(20)" v-arpname no-label colon 41 format "x(30)" skip(1)

        v_code  label  " КОД               " validate(length(v_code) = 2, "Hеверное значение кода") skip
        v_kbe   label  " КБе               " validate(length(v_kbe) = 2, "Hеверное значение КБе") skip
        v_knp   label  " КНП               " validate(can-find(first codfr where codfr.codfr = "spnpl" and codfr.child = false
                    and codfr.code <> "msc" and  codfr.code = v_knp no-lock), "Нет такого кода КНП! F2-помощь") skip
        v_oper  label  " Назнач.платежа    "   format "x(55)" skip
        v_oper1 no-label colon 20 format "x(55)" skip
        v_oper2 no-label colon 20 format "x(55)" skip(1)
        vj-label no-label v-ja no-label
        WITH  SIDE-LABELS CENTERED ROW 3   TITLE v_title width 80 FRAME f_main.


DEFINE VARIABLE phand AS handle.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.

on help of v-aaa in frame f_main do:
    run h-pc PERSISTENT SET phand.
    v-aaa = frame-value.
    find first pccards where pccards.pcard = v-aaa  and pccards.sts = 'ok' no-lock no-error.
    if available pccards then v-aaa = pccards.aaa.
    else v-aaa = "".
    displ v-aaa with frame f_main.
end.

on help of s-remtrz in frame f_main do:
    run h-rmz15 PERSISTENT SET phand.
    s-remtrz = frame-value.
    displ s-remtrz with frame f_main.
end.

on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

on "END-ERROR" of v-pnp in frame f_main do:
  return.
end.

on "END-ERROR" of frame f-help do:
  hide frame f-help no-pause.
end.

/*  help for cif */
on help of v-pnp in frame f_main do:
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
            v-pnp = aaa.aaa.
            hide frame f-help.
            displ v-pnp with frame f_main.
        end.
        else do:
            v-pnp = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
            displ v-pnp with frame f_main.
            return.
        end.
    end.
    else DELETE PROCEDURE phand.
end.

m_pid = "P".
if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find first nmbr no-lock no-error.
    run n-remtrz.   /* получили новый номер для rmz в переменной s-remtrz */
    find first nmbr no-lock no-error.
    do transaction:
        displ s-remtrz format "x(10)" with frame f_main.
        assign v_oper  = ""
               v-ja    = yes
               v-pnp   = ""
               v_sum   = 0
               v-crc   = ?
               v_oper1 = ""
               v_oper2 = "".
        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */
else do:   /* редактирование документа   */
    s-remtrz = "".
    run view_doc ("").
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc("").
            find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
            if available remtrz then do:
               if remtrz.jh1 ne ? then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box error.
                    return.
                end.
                if remtrz.rwho ne g-ofc then do:
                    message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box error.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    displ s-remtrz v-viddoc v-ref v-priory with  frame f_main.

    update v-pnp help "Счет клиента; F2- помощь; F4-выход" with frame f_main.
    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if avail aaa then do:
        assign v-cif = aaa.cif
               v-crc = aaa.crc
               v-gl  = aaa.gl.
        find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
        if avail lgr then v-led = lgr.led.
        find first cif where cif.cif = v-cif no-lock no-error.
        if avail cif then do:
            assign v_name  = trim(trim(cif.prefix) + " " + trim(cif.name))
                   v_rnn   = if v-bin then cif.bin else cif.jss.
            find last sub-cod where sub-cod.acc = v-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
            if available sub-cod then v-ec = sub-cod.ccode.
            else do:
                message "Не заполнен сектор экономики клиента!" view-as alert-box error.
                undo, return.
            end.
            if can-do('021,022',cif.geo) then v_code = substr(cif.geo,3,1) + v-ec.
            else do:
                message "Проверьте ГЕО-код клиента!" view-as alert-box error.
                undo, return.
            end.
        end.
        find last cifsec where cifsec.cif = cif.cif no-lock no-error.
        if avail cifsec then do:
            find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
            if not avail cifsec then do:
                create ciflog.
                assign
                    ciflog.ofc     = g-ofc
                    ciflog.jdt     = today
                    ciflog.cif     = cif.cif
                    ciflog.sectime = time
                    ciflog.menu    = "Регистрация исходящих платежей".
                release ciflog.
                message "Клиент не Вашего Департамента." view-as alert-box buttons ok.
                undo,retry.
            end.
            else do:
                create ciflogu.
                assign
                    ciflogu.ofc     = g-ofc
                    ciflogu.jdt     = today
                    ciflogu.sectime = time
                    ciflogu.cif     = cif.cif
                    ciflogu.menu    = "Регистрация исходящих платежей".
                release ciflogu.
            end.
        end.
        find first crc where crc.crc = v-crc no-lock.
        v-crcc = crc.code.
    end.
    /******************************/
    /*run aaa-aas.
    find first aas where aas.aaa = v-pnp and aas.sic = 'SP' no-lock no-error.
    if available aas then do: pause. undo,retry. end.*/

    displ v_name v-label v_rnn v-crc  v_code with frame f_main.
    pause 0.
    /* ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА */
    if trim(cif.reschar[20]) <> "" or trim(cif.reschar[17]) <> "" then run a_mescif(trim(cif.cif)).

    update v_sum  with frame f_main.
    update v-aaa help "Счет клиента по ПК; F2- помощь; F4-выход" with frame f_main.
    find first pccards where pccards.aaa = v-aaa no-lock no-error.
    if avail pccards then do:
        assign v_namep = pccards.sname
               v_rnnp  = if v-bin then pccards.iin else pccards.rnn
               v-fil   = substr(pccards.aaa,19,2)
               v_kbe   = pccards.info[1] + '9'.
        find first txb where txb.bank =  'txb' + v-fil no-lock no-error.
        if avail txb then assign v-filname = txb.info
                                 v-rnnp    = if v-bin then entry(3,txb.params) else entry(1,txb.params).
    end.
    else do:
        message "Неверный счет ПК!"  view-as alert-box error.
        undo.
    end.
    if 'txb' + v-fil = s-ourbank then do:
        message "Счет по ПК принадлежит клиенту вашего филиала!~nТакие операции не предусмотрены в этом пункте меню!"  view-as alert-box error.
        undo, return.
    end.
    if can-do('CDA,TDA',v-led) and v_rnnp <> v_rnn then do:
       message "Переводные операции в пользу третьих лиц, ~nпредусмотрены только со счетов до востребования!"  view-as alert-box error.
       undo, return.
    end.

    /*v_knp = entry(lookup(string(v-gl),v-spgl),v-spknp) no-error.*/
    if v_rnnp = v_rnn then v_knp = "321".
    else v_knp = "119".
    displ v_namep v-labelp v_rnnp  v-fil v-filname v_kbe with frame f_main.
    update v_knp  with frame f_main.

    /*find first txb where txb.bank =  'txb' + v-fil no-lock no-error.
    if not avail txb then return.*/
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
    run pcfarp(v-glarp,v-crc,output v-arp,output v-arpname).
    if connected ("txb") then disconnect "txb".
    if v-arp = '' then do:
        message "Не найден счет АРП (ГК " + string(v-glarp) + ", валюта " + v-crcc + ",филиал " + v-filname + ") для пополнения ПК!"  view-as alert-box error.
        undo, return.
    end.

    displ v-arp v-arpname with frame f_main.

    if v_rnn <> v_rnnp then v_oper  = "Мат. помощь, перевод со счета клиента на счет по ПК ".
    else v_oper  = "Перевод со счета клиента на счет по ПК".
    assign  v_oper1 = v_namep + (if v-bin then " ИИН " else " РНН ") + v_rnnp + " "
            v_oper2 = v-aaa.
    displ  v_kbe v_knp v_oper v_oper1 v_oper2 vj-label with frame f_main.
    update v_oper v_oper1 v_oper2  v-ja with frame f_main.

    if new_document then do:
        create remtrz.
        remtrz.remtrz = s-remtrz.
    end.
    else find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
    assign remtrz.ptype   = "N"
           remtrz.rdt     = g-today
           remtrz.rtim    = time
           remtrz.amt     = v_sum
           remtrz.payment = v_sum
           remtrz.svca    = 0
           remtrz.svcp    = 0
           remtrz.ord     = caps(trim(v_name)) + ' /RNN/' + trim(v_rnn).

    /*if remtrz.ord = ? then do:
      run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "a_kz1.p 624", "1", "", "").
    end.*/
    assign
        remtrz.chg        = 7 /* to  outgoing process */
        remtrz.cover      = v-transp
        remtrz.ref        = v-ref
        remtrz.outcode    = 3
        remtrz.fcrc       = v-crc
        remtrz.tcrc       = v-crc
        remtrz.detpay[1]  = v_oper + v_oper1 + v_oper2
        remtrz.sbank      = ourbank
        remtrz.rbank      = 'txb' + v-fil
        remtrz.valdt1     = g-today
        remtrz.rwho       = g-ofc
        remtrz.tlx        = no
        remtrz.dracc      = v-pnp
        remtrz.drgl       = v-gl
        remtrz.sacc       = v-pnp
        remtrz.racc       = v-arp
        remtrz.sqn        = trim(ourbank) + "." + trim(s-remtrz) + ".." + if v-crc = 1 then v-ref else 'ДПС' + v-ref
        remtrz.scbank     = trim(ourbank)
        remtrz.source     = if v-crc = 1 then "P" else "RKOTXB"
        remtrz.ben[1]     = v_namep
        remtrz.ben[2]     = v-aaa
        remtrz.ben[3]     = " /RNN/" + v_rnnp
        remtrz.rcvinfo[1] = '/PC/'
        remtrz.rcvinfo[3] = s-remtrz
        remtrz.ba         = remtrz.racc
        remtrz.rsub       = 'arp'.
    find first bankt where bankt.cbank = 'txb00'
                       and bankt.racc  = "1"
                       and bankt.crc   = v-crc
                       no-lock no-error.
    if avail bankt then remtrz.cracc = bankt.acc .
    find first dfb where dfb.dfb = bankt.acc no-lock no-error.
    if avail dfb then remtrz.crgl = dfb.gl.
    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
    if avail bankl then assign remtrz.rcbank = bankl.cbank
                               remtrz.bb[1]  = bankl.name
                               remtrz.bb[2]  = bankl.addr[1]
                               remtrz.bb[3]  = bankl.addr[2] + " " + bankl.addr[3].

    assign remtrz.scbank     = remtrz.sbank
           remtrz.ordins[1]  = 'АО "ForteBank"'
           remtrz.ordins[2]  = " "
           remtrz.ordins[3]  = ""
           remtrz.ordins[4]  = ""
           remtrz.ordcst[1]  = remtrz.ord
           remtrz.bn[1]      = remtrz.bb[1]
           remtrz.bn[2]      = remtrz.bb[2]
           remtrz.bn[3]      = " /RNN/" + v-rnnp
           remtrz.rcvinfo[2] = string(g-today).
    v-bb = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]) .
    assign remtrz.actins[1] = "/" + substr(v-bb,1,34)
           remtrz.actins[2] = substr(v-bb,35,35)
           remtrz.actins[3] = substr(v-bb,70,35)
           remtrz.actins[4] = substr(v-bb,105,35)
           remtrz.actinsact = remtrz.rbank
           remtrz.valdt2    = g-today
           remtrz.ptype     = '4'.

    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub   = 'rmz'
               sub-cod.acc   = s-remtrz
               sub-cod.d-cod = 'pdoctng'
               sub-cod.ccode = v-viddoc
               sub-cod.rdt   = g-today.
    end.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" exclusive-lock no-error.
    if not available sub-cod then do:
        create sub-cod.
        assign sub-cod.sub   = "rmz"
               sub-cod.acc   = s-remtrz
               sub-cod.d-cod = "eknp"
               sub-cod.ccode = "eknp".
    end.
    assign sub-cod.rdt   = g-today
           sub-cod.rcode = v_code + "," + v_kbe + "," + v_knp.
    find current sub-cod no-lock no-error.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" exclusive-lock no-error.
    if not available sub-cod then do:
        create sub-cod.
        assign sub-cod.sub    = "rmz"
               sub-cod.acc    = s-remtrz
               sub-cod.d-cod  = "iso3166"
               sub-cod.ccode  = v-countr
               sub-cod.rdt    = g-today.
    end.
    find current sub-cod no-lock no-error.
    if v-crc > 1 then m_pid = 'O'.
    run rmzque .
    pause 0.
    release que.
    run chgsts(input "rmz", remtrz.remtrz, "4").
    find current remtrz no-lock no-error.
    displ s-remtrz with frame f_main.
    {vccheckp.i}.

    pause 0.
end procedure.


procedure view_doc:
    define input parameter s as char.
    if s = "" then update s-remtrz help "Введите номер документа, F2-помощь" with frame f_main.
    else s-remtrz = s.
    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.
    if trim(s-remtrz) = "" then undo, return.
    displ s-remtrz with frame f_main.
    pause 0.
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if not available remtrz then do:
        message "Документ не найден." view-as alert-box error.
        undo, return.
    end.
    if remtrz.jh1 ne ? and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box error.
        return.
    end.
    if remtrz.rwho ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box error.
        return.
    end.
    assign
        v_trx    = remtrz.jh1
        v_sum    = remtrz.amt
        v_name   = remtrz.ord
        v-ref    = remtrz.ref
        v-transp = remtrz.cover
        v-crc    = remtrz.fcrc
        v_oper   = substr(remtrz.detpay[1],1,55)
        v_oper1  = substr(remtrz.detpay[1],56,55)
        v_oper2  = substr(remtrz.detpay[1],111,55)
        v-pnp    = remtrz.dracc
        v-rnnp   = if index(remtrz.bn[3], "/RNN/") <= 0 then substr(remtrz.bn[3],1,12)
                                                        else substr(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12)
        v-arp    = remtrz.racc
        v-lbank  = remtrz.rbank
        v-nbank  = remtrz.bb[1]
        v-date   = remtrz.valdt2
        v-transp = remtrz.cover
        v_namep  = remtrz.ben[1]
        v-aaa    = remtrz.ben[2]
        v_rnnp   = if index(remtrz.ben[3], "/RNN/") <= 0 then substr(remtrz.ben[3],1,12)
                                                        else substr(remtrz.ben[3],index(remtrz.ben[3], "/RNN/") + 5,12)
        v-fil    = substr(remtrz.rbank,4,2)
        v-filname = remtrz.bn[1] + ' ' + remtrz.bn[2]
        v-pol1    = remtrz.bn[1] + ' ' + remtrz.bn[2].

    find first aaa where aaa.aaa = v-pnp no-lock no-error.
    if avail aaa then assign v-cif = aaa.cif
                             v-crc = aaa.crc.
    find first cif where cif.cif = v-cif no-lock no-error.
    if avail cif then assign v_name  = trim(trim(cif.prefix) + " " + trim(cif.name))
                             v_rnn   = if v-bin then cif.bin else cif.jss
                             v-reg5  = v_rnn.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "pdoctng" no-lock no-error.
    if avail sub-cod then v-viddoc = sub-cod.ccode.

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then assign v_code = entry(1,sub-cod.rcode,',')
                                 v_kbe = entry(2,sub-cod.rcode,',')
                                 v_knp = entry(3,sub-cod.rcode,',').
    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
    v-priory = if avail sub-cod then sub-cod.ccode else 'o'.
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "iso3166" no-lock no-error.
    if avail sub-cod then v-countr = sub-cod.ccode.
    v-ja = yes.
    displ s-remtrz v_trx  v-viddoc v-ref v-priory v-pnp v_name v-label v_rnn v-crc v_sum v-aaa v_namep v-labelp v_rnnp v-fil v-filname
          v-arp v-arpname v_code v_kbe v_knp  v_oper v_oper1 v_oper2 with  frame f_main.
end procedure.

Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc ("").
        find remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
        if available remtrz then do:
            if not (remtrz.jh1 eq 0 or remtrz.jh1 eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if remtrz.rwho ne g-ofc then do:
               message substitute ("Документ принадлежит &1. Удалять нельзя.", remtrz.rwho) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            update v-ja  with frame f_main.
            if v-ja then do:
                find remtrz where remtrz.remtrz = s-remtrz no-error.
                if available remtrz then delete remtrz.
                find first remtrz no-lock no-error.
                for each substs where substs.sub = "rmz" and  substs.acc = s-remtrz exclusive-lock.
                    delete substs.
                end.
                find first substs  no-error.

                find cursts where cursts.sub = "rmz" and  cursts.acc = s-remtrz  exclusive-lock no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.

                for each sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz exclusive-lock.
                    delete sub-cod.
                end.
                for each que where que.remtrz = s-remtrz exclusive-lock.
                    delete que.
                end.
            end.
        end.
        apply "close" to this-procedure.
        delete procedure this-procedure.
        hide message.
        hide frame f_main.
    end. /* end transaction */
    return.
end procedure.

procedure Create_transaction:
    vj-label = " Выполнить транзакцию?..................".
    run view_doc (s-remtrz).
    find first remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
    if remtrz.jh1 ne ? and remtrz.jh1 <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box error.
        undo, return.
    end.
    if remtrz.rdt ne g-today then do:
        message substitute ("Документ создан &1 .", remtrz.rdt) view-as alert-box error.
        undo, return.
    end.
    if remtrz.rwho ne g-ofc then do:
        message substitute ("Документ создан &1 .", remtrz.rwho) view-as alert-box error.
        undo, return.
    end.
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
    enable but with frame f_main.
    pause 0.
    run ispognt.
    disable but with frame f_main.
    if remtrz.jh1 > 0 then do:
        v_trx = remtrz.jh1.
        run trxsts (input v_trx, input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
            undo, return .
        end.
        MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(v_trx) view-as alert-box.
        run chgsts(input "rmz", remtrz.remtrz, "rdy").
        if v-crc <> 1 then do:
            find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error.
            if avail que then que.pid = 'G'.
            find current que no-lock no-error.
        end.
        view frame f_main.
        displ v_trx with frame f_main.
    end.
end procedure.

procedure Delete_transaction:
    if s-remtrz eq "" then undo, retry.
    find first remtrz where remtrz.remtrz eq s-remtrz.
    if locked remtrz then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box error.
        pause 3.
        undo, return.
    end.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        pause 3.
        undo, return.
    end.

    if remtrz.rwho ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box error.
        pause 3.
        undo, return.
    end.
    s-jh = remtrz.jh1.
    run rmzcano.
    hide all no-pause.
    view frame f_main.
    pause 0.
end procedure.

procedure Screen_transaction:
    if s-remtrz eq "" then undo, retry.
    find first remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.

    do transaction:
        s-jh = remtrz.jh1.
        run vou_word (2, 1, "").
    end. /* transaction */
end procedure.

procedure print_transaction:
    if s-remtrz eq "" then undo, retry.
    find first remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.

    if remtrz.jh1 eq ? then do:
        message "Транзакция не существует." view-as alert-box error.
        undo, return.
    end.

    do transaction:
        s-jh = remtrz.jh1.
        run printord(s-jh,"").
    end. /* transaction */
end procedure.

procedure print_statement:
find first remtrz where remtrz.remtrz eq s-remtrz no-lock no-error.
if avail remtrz then do:
    find aaa where aaa.aaa eq v-pnp no-lock no-error.
    if avail aaa then do:
        assign v-chet  = v-pnp
               v-chetp = v-arp
               v_namep = v-filname
               v_rnnp  = v-rnnp.
        if v-crc = 1 then do:
            {a_cas3printapp.i}
        end.
        else do:
         {a_cas3printapp2.i}
        end.
    end.
end.

end procedure.

procedure prtppp1:
    run connib.
    run prtppp.
    if connected ('ib') then disconnect 'ib'.
end procedure.

