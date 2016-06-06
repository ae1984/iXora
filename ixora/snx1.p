/* snx1.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        IB COMM TXB
 * AUTHOR
        09.10.2009 id00004 Частично переделал программу старого ИБ IBHtrz_ps за основу взят ее код.
        06.10.2010 id00004 увеличил длину поля ДЕТАЛИ ПЛАТЕЖА тенговых платежей до 482 символов (согласно формата КЦМР).
        12.04.2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
        15.04.2011 id00004 добавил проверку на референс
        24.11.2011 id00004 добавил обработку БИК для RUR
        29.03.2012 id00004 изменения согласно ТЗ-1229
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        31.05.2012 evseev - навел небольшой марафет в коде
        17.07.2012 evseev - ТЗ-1349
        25.09.2012 evseev - добавил логирование
        27.09.2012 evseev - добавил логирование
        11.10.2012 Lyubov - ТЗ 1528, отвергаем зарплатный платеж в случае недостаточности денег на счете
        06.11.2012 id00810 - ТЗ 1557, добавила обработку конкр.счета KZ81470192870A023308
        02.01.2013 damir - Переход на ИИН/БИН.
        04.01.2013 damir - Перекомпиляция.
        30.03.2013 Lyubov - ТЗ №1772, при зачислении з.п. изменила сообщение в ИБ "Недостаток средств на счете"
        02.05.2013 Lyubov - ТЗ №1807, убрала проверку достаточности средств
        28.05.2013 damir - Исправлена техническая ошибка. Добавил функцию DelQues. Внедрено Т.З. № 1819.
        28.08.2013 evseev - tz-926
        08.11.2013 zhassulan - ТЗ 1417, новые поля ИНН и КПП для рубл.платежей
        14.11.2013 zhassulan - ТЗ 1313, добавлено: тип комиссии SHA, код комиссии 304

*/
/*--------------------------------------------------------------------------------------------------------
  НЕ МЕНЯТЬ ПРОГРАММЫ БЕЗ ЧЕТКОГО ПОНИМАНИЯ ПРОЦЕССА Т.К ТЕГИ XML ВЗАИМОСВЯЗАНЫ ДЛЯ РАЗНЫХ ТИПОВ ПЛАТЕЖЕЙ
  ИЗМЕНЕНИЕ ОБРАБОТКИ ДЛЯ ОДНОГО ТИПА ПЛАТЕЖА МОЖЕТ ПОВЛИЯТЬ ИЛИ ИСКАЗИТЬ РЕКВИЗИТЫ ПЛАТЕЖА ДРУГОГО ТИПА
---------------------------------------------------------------------------------------------------------*/

{srvcheck.i}
define shared var g-today  as date.
def input  parameter v-kbk        as char . /*1*/
def input  parameter v-docref       as char no-undo. /*2*/
def input  parameter v-doctype      as integer no-undo. /*3*/
def input  parameter v-docsubtype   as integer no-undo. /*4*/
def input  parameter v-docvaldate   as date. /*5*/
def input  parameter v-doccrccrc    as integer. /*6*/
def input  parameter v-docamt       as decimal. /*7*/
def input  parameter v-docordacc    as char. /*8*/
def input  parameter v-docbbname1   as char. /*9*/
def input  parameter v-docbbname2   as char. /*10*/
def input  parameter v-docbbname3   as char. /*11*/
def input  parameter v-docbbname4   as char. /*12*/
def input  parameter v-docibname2   as char. /*13*/
def input  parameter v-docbenname1 as char. /*14*/
def input  parameter v-docbenname2 as char. /*15*/
def input  parameter v-docbenname3 as char. /*16*/
def input  parameter v-docbenname4 as char. /*17*/
def input  parameter v-docbenacc   as char. /*18*/
def input  parameter v-beninfo1    as char. /*19*/
def input  parameter v-beninfo2    as char. /*20*/
def input  parameter v-beninfo3    as char. /*21*/
def input  parameter v-beninfo4    as char. /*22*/
def input  parameter v-doccharge   as char. /*23*/
def input  parameter v-docdepdate  as date. /*24*/
def input  parameter v-doccif      as char. /*25*/
def input  parameter v-docurgency  as char. /*26*/
def input  parameter v-doctax      as logical. /*27*/
def input  parameter v-docbbcode1  as char. /*28*/
def input  parameter v-docbbcode2  as char. /*29*/
def input  parameter v-docfilial   as char. /*30*/
def input  parameter v-docrnn      as char. /*31*/
def input  parameter v-doccomacc   as char. /*32*/
def input  parameter v-docregcode  as char. /*33*/
def input  parameter v-doccrccode  as char. /*34*/
def input  parameter v-doccodepar1 as char. /*35*/
def input  parameter v-doccodepar2 as char. /*36*/
def input  parameter v-docbbinfo1  as char. /*37*/
def input  parameter v-docbbinfo2  as char. /*38*/
def input  parameter v-docbbplc    as char. /*39*/
def input  parameter vg-today      as date. /*40*/
def input  parameter v-docibcode2  as char. /*41*/
def input  parameter v-docbamt     as decimal. /*42*/
def input  parameter v-state     as char. /*43*/
def input  parameter v-datedoc   as date. /*44*/
def input  parameter v-purptype  as char. /*45*/
def input  parameter v-ru_bic  as char. /*46*/
def input  parameter v-purpose  as char. /*47*/
def input  parameter v-RCPT_BANK_BIC_TYPE  as char. /*48*/
def input  parameter v-INTERMED_BANK_BIC_TYPE  as char. /*49*/
def input  parameter inn_kpp as char. /*50*/


def output parameter rdes as char no-undo.
def output parameter v-reterr as integer.
def output parameter v-ba as cha .
def output parameter v-pri as cha .
def output parameter rsts as integer no-undo.
def output parameter v-cifname as cha .

function DelQues returns char(input str as char).
    if str = ? then return "".
    else return str.
end function.

v-kbk = DelQues(v-kbk).
v-docref = DelQues(v-docref).
v-docordacc = DelQues(v-docordacc).
v-docbbname1 = DelQues(v-docbbname1).
v-docbbname2 = DelQues(v-docbbname2).
v-docbbname3 = DelQues(v-docbbname3).
v-docbbname4 = DelQues(v-docbbname4).
v-docibname2 = DelQues(v-docibname2).
v-docbenname1 = DelQues(v-docbenname1).
v-docbenname2 = DelQues(v-docbenname2).
v-docbenname3 = DelQues(v-docbenname3).
v-docbenname4 = DelQues(v-docbenname4).
v-docbenacc = DelQues(v-docbenacc).
v-beninfo1 = DelQues(v-beninfo1).
v-beninfo2 = DelQues(v-beninfo2).
v-beninfo3 = DelQues(v-beninfo3).
v-beninfo4 = DelQues(v-beninfo4).
v-doccharge = DelQues(v-doccharge).
v-doccif = DelQues(v-doccif).
v-docurgency = DelQues(v-docurgency).
v-docbbcode1 = DelQues(v-docbbcode1).
v-docbbcode2 = DelQues(v-docbbcode2).
v-docfilial = DelQues(v-docfilial).
v-docrnn = DelQues(v-docrnn).
v-doccomacc = DelQues(v-doccomacc).
v-docregcode = DelQues(v-docregcode).
v-doccrccode = DelQues(v-doccrccode).
v-doccodepar1 = DelQues(v-doccodepar1).
v-doccodepar2 = DelQues(v-doccodepar2).
v-docbbinfo1 = DelQues(v-docbbinfo1).
v-docbbinfo2 = DelQues(v-docbbinfo2).
v-docbbplc = DelQues(v-docbbplc).
v-docibcode2 = DelQues(v-docibcode2).
v-state = DelQues(v-state).
v-purptype = DelQues(v-purptype).
v-ru_bic = DelQues(v-ru_bic).
v-purpose = DelQues(v-purpose).
inn_kpp = DelQues(inn_kpp).

{nbankBik-txb.i}
run savelog("snx1", "96. Начало.....................................").
rsts = 0.
find last txb.aaa where txb.aaa.aaa = v-docordacc no-lock no-error.
if avail txb.aaa then do:
   run savelog("snx1", "100").
   v-doccrccrc = txb.aaa.crc.
end.

/****************************************************************/
def var t-beninfo as char.
def  var v-text as cha .
def  var v-bic as cha .
def  var v-bsubc as cha .
def  var v-bc as cha .
def  var v-osubc as cha .
def  var v-oc as cha .
def  var v-pk as cha .
def  var fou as log initial false .
def  var m-typ as cha .
def  var v-docbcrccode as cha .
def  var v-ret as cha .
def  var tradr as cha .
def  var exitcod as cha .
def  var v-date as date .
def  var v-bank like txb.bankl.bank .
def  var lbnstr as cha .
def  var dd as char.
def  var dep-date as date .
def  var v-cif like txb.cif.cif .
def  var rep as cha initial "0".
def  var irep as int initial 0.
def  var blok4 as log initial false .
def  var blokA as log initial false .
def  var v-ref as cha  .
def  var v-crc like txb.remtrz.fcrc .
def  var v-amt like txb.remtrz.amt.
def  var v-ord like txb.remtrz.ord.
def  var v-info as cha .
def  var v-info3 as cha .
def  var v-intmed as cha .
def  var v-intmedact as cha .
def  var v-acc like txb.remtrz.sacc.
def  var v-bb as cha .
def  var v-docsordacc as char.
def  var v-ben as cha .
def  var v-det as cha .
def  var v-chg as cha .
def  var tmp as cha .
def  var trz1 as cha .
def  var trz2 as cha .
def  buffer que1 for txb.que .
def  buffer que2 for txb.que .
def  var trzerr as log .
def  var snpgl like txb.remtrz.crgl .
def  var snpgl2 like txb.remtrz.crgl .
def  var snpacc like txb.remtrz.cracc .
def  var i as int .
def  var num as cha extent 100.
def  var v-string as cha.
def  var impok as log initial false.
def  var ok as log initial false.
def  var acode like txb.crc.code.
def  var bcode like txb.crc.code.
def  var c-acc as cha .
def  var vv-crc like txb.crc.crc .
def  var v-cashgl like txb.gl.gl.
def  var vf1-rate like txb.fexp.rate.
def  var vfb-rate like txb.fexp.rate.
def  var vt1-rate like txb.fexp.rate.
def  var vts-rate like txb.fexp.rate.
def  buffer vaaakzt for txb.aaa.
def  buffer vaaavlt for txb.aaa.
def  buffer xaaa for txb.aaa.
def  buffer fcrc for txb.crc.
def  buffer t-bankl for txb.bankl.
def  buffer tcrc for txb.crc.
def  var ourbank as cha.
def  var clecod  as cha.
def  var v-sender like txb.remtrz.sbank.
def  var t-pay like txb.remtrz.payment.
def  buffer tgl for txb.gl.
def  var b as int.
def  var s as int.
def  var sender   as cha.
def  var v-field  as cha extent 50 .
def  var receiver as cha.

def  var s-remtrz like txb.remtrz.remtrz.
def  var v-sal as logi init false.
def  var v-amount as deci.
def  var v-tmpstr as char.
def  var v-tmpdec as deci.
def  var v-docbbcity as char.

t-beninfo = "".

define buffer bacc for txb.aaa.

DEFINE VARIABLE ptpsession AS HANDLE.
DEFINE VARIABLE messageH AS HANDLE.

def  var v-weekbeg as int.
def  var v-weekend as int.
def  var brnch as log init no.
def  var l-chng as log.
def  var old-bank like txb.bankl.bank.


define var v-org as char.
define var v-dest as char.
define var v-err as logical.

{v-cps-get.i}

function v-eknp returns char(input v-cif as char,input v-remtrz as char,input v-rezp as char,input v-secp as char,input v-knp as int).
    run savelog("snx1", "208 v-remtrz=" + v-remtrz).
    def var l-eknp as char.
    def var v-rezo as char. /* признак резиденства для отправителя */
    def var v-seco as char. /* код сектора экономики */
    /* для получателя */
    find txb.sub-cod where txb.sub-cod.acc = v-remtrz and txb.sub-cod.sub = 'rmz' and txb.sub-cod.d-cod = 'eknp' and txb.sub-cod.ccode = 'eknp' no-error.
    if not avail txb.sub-cod then do:
        run savelog("snx1", "215").
        find txb.cif where txb.cif.cif = v-cif no-lock no-error.
        if avail txb.cif  then do:
            run savelog("snx1", "218").
            if substr(txb.cif.geo,3,1) eq '1' then v-rezo = '1'.
            else v-rezo = '2'.
        end.
        find txb.sub-cod where txb.sub-cod.acc = v-cif and txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode ne 'msc' then v-seco = txb.sub-cod.ccode.
        if v-rezo ne '' and v-seco ne '' then do:
            run savelog("snx1", "224").
            create txb.sub-cod.
            txb.sub-cod.acc   = v-remtrz.
            txb.sub-cod.sub   = 'rmz'.
            txb.sub-cod.d-cod = 'eknp'.
            txb.sub-cod.ccode = 'eknp' .
            txb.sub-cod.rcode = v-rezo + v-seco + ',' + v-rezp + v-secp + ',' + string(v-knp,"999").
            l-eknp = sub-cod.rcode.
        end.
    end.
    else do:
        run savelog("snx1", "234").
        entry(2,txb.sub-cod.rcode,',') = v-rezp + v-secp.
        entry(3,txb.sub-cod.rcode,',') = string(v-knp).
        l-eknp = txb.sub-cod.rcode.
    end.
    return l-eknp.
end function.

v-reterr = 0.

define var p_txbtime as integer no-undo.
def new shared var v-ordins as cha   init ''.
def new shared var oi-name  as cha.
def var pf_file as char init "" no-undo.
def new shared var crd_file as char init "".
def var tempstr as char init "" no-undo.
def var v-goal as char no-undo.
define buffer baaa for aaa.
def var mailaddr as character no-undo.
def var usrid  as integer init 0 no-undo.
def var usrtb  as integer init 0 no-undo.
def var usrnum as integer no-undo.
def var usrkey as char no-undo.
def var autblk as integer no-undo.
def var keynum as integer no-undo.
def var otknum as integer no-undo.
def var usrtxt as char no-undo.
def var aToken as char extent 5 no-undo.
def var usrvalue as char no-undo.
def var usrcif as char no-undo.
def var lcodekey as logical no-undo.
def buffer b-cifname for cif.
find last netbank where netbank.id = v-state  .

run savelog("snx1", "268").
find last txb.aaa where txb.aaa.aaa = v-docordacc no-lock no-error.
if avail txb.aaa then do:
    run savelog("snx1", "271").
    find last b-cifname where b-cifname.cif = txb.aaa.cif no-lock no-error.
    if avail b-cifname then do:
       run savelog("snx1", "274").
       v-cifname = b-cifname.name.
    end.

    v-doccif = txb.aaa.cif.
    find last netbank where netbank.id = v-state and (netbank.type = 1 or netbank.type = 2 or netbank.type = 4 or netbank.type = 0)  exclusive-lock no-error.
    if  avail netbank then do:
        run savelog("snx1", "281").
        netbank.cif = v-doccif.
    end.
end.
v-reterr = 0.
find txb.sysc "WKSTRT" no-lock no-error.
if available txb.sysc then v-weekbeg = txb.sysc.inval. else v-weekbeg = 2.
run savelog("snx1", "288. v-weekbeg=" + string(v-weekbeg)).
find txb.sysc "WKEND" no-lock no-error.
if available txb.sysc then v-weekend = txb.sysc.inval. else v-weekend = 6.
run savelog("snx1", "291. v-weekend" + string(v-weekend)).
find last txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
ourbank = txb.sysc.chval.
find first comm.txb where comm.txb.bank = ourbank no-lock no-error.
if comm.txb.is_branch then brnch = comm.txb.is_branch.
num[1] = trim(v-ref) .

if v-doctype = 9 then do:
        run savelog("snx1", "299").
        find last  vaaakzt where vaaakzt.aaa =  v-docordacc no-lock no-error.
        if not avail vaaakzt then do:
           run savelog("snx1", "302").
           rdes = " Счет " + v-docordacc + " не найден".
           rsts = 1.
           return.
        end.

        find last  vaaavlt where vaaavlt.aaa =  v-docbenacc no-lock no-error.
        if not avail vaaavlt then do:
           run savelog("snx1", "310").
           rdes = " Счет " + v-docbenacc + " не найден".
           rsts = 1.
           return.
        end.

        find first txb.crc where txb.crc.crc = vaaakzt.crc no-lock no-error.
        if txb.crc.crc = 1 then v-docsubtype = 1. /* Покупка */ else v-docsubtype = 2.                    /* Продажа */
        run savelog("snx1", "318. v-docsubtype=" + string(v-docsubtype)).
        v-doccrccode = txb.crc.code.
        run savelog("snx1", "320. v-doccrccode=" + string(v-doccrccode)).
        find first txb.crc where txb.crc.crc = vaaavlt.crc no-lock no-error.
        v-docbcrccode = txb.crc.code.
        run savelog("snx1", "323. v-docbcrccode=" + string(v-docbcrccode)).
        find first txb.crc where txb.crc.crc = 1 no-lock no-error.

        find first txb.aaa where txb.aaa.aaa = (if v-docsubtype <> 1 then v-docordacc else v-docbenacc) no-lock no-error.
        if not avail txb.aaa then do:
           run savelog("snx1", "328").
           rdes = " Счет не найден".
           rsts = 1.
           return.
        end.

        create txb.dealing_doc.
           txb.dealing_doc.DocNo = string(next-value(d_journal,txb),'999999').
           txb.dealing_doc.who_cr = "inbank".
           txb.dealing_doc.whn_cr = vg-today.
           txb.dealing_doc.who_mod = "inbank".
           txb.dealing_doc.whn_mod = vg-today.
           txb.dealing_doc.time_cr = time.
           txb.dealing_doc.time_mod = time.
           txb.dealing_doc.DocType =
                (if v-docsubtype = 1 and v-docurgency = "U" then 1 else
                (if v-docsubtype = 1 and v-docurgency = "N" then 2 else
                (if v-docsubtype = 2 and v-docurgency = "U" then 3 else
                (if v-docsubtype = 2 and v-docurgency = "N" then 4 else 0 )))).
           txb.dealing_doc.com_accno = v-doccomacc.
           txb.dealing_doc.tclientaccno = (if v-docsubtype = 1 then v-docordacc else v-docbenacc).
           txb.dealing_doc.vclientaccno = (if v-docsubtype = 1 then v-docbenacc else v-docordacc).
           txb.dealing_doc.tngtoval = (if v-docamt <> 0.0 then (v-doccrccode = txb.crc.code) else (v-docbcrccode = txb.crc.code)).
           txb.dealing_doc.crc = txb.aaa.crc.
           txb.dealing_doc.f_amount = (if v-docamt <> 0 then v-docamt else if v-docbamt <> 0 then v-docbamt else 0.0).
           txb.dealing_doc.sts = integer(v-docref).


           find first txb.sysc where txb.sysc.sysc = "purpose_nr"  no-lock no-error.
           if avail txb.sysc then do:
              run savelog("snx1", "360").
              do i = 1 to NUM-ENTRIES(txb.sysc.chval, "|"):
                 if ENTRY( i, txb.sysc.chval, "|" ) matches "*" + v-purpose + "*" then txb.dealing_doc.purpose = ENTRY( i, txb.sysc.chval, "|" ).
              end.
           end.
           if txb.dealing_doc.purpose = "" then do:
               run savelog("snx1", "366").
               find first txb.sysc where txb.sysc.sysc = "purpose_r"  no-lock no-error.
               if avail txb.sysc then do:
                  run savelog("snx1", "369").
                  do i = 1 to NUM-ENTRIES(txb.sysc.chval, "|"):
                     if ENTRY( i, txb.sysc.chval, "|" ) matches "*" + v-purpose + "*" then txb.dealing_doc.purpose = ENTRY( i, txb.sysc.chval, "|" ).
                  end.
               end.
           end.
           if txb.dealing_doc.purpose = "" then  txb.dealing_doc.purpose = "не найден код: " + v-purpose.



        netbank.rem[3] = string(v-docamt) + "#" + string(v-docbamt).

        if v-docamt <> 0 then do:
           run savelog("snx1", "382").
           find last bacc where bacc.aaa = v-docordacc no-lock no-error.
           if avail bacc then do:

              dealing_doc.input_crc = bacc.crc.
           end.
        end.
        if v-docbamt <> 0 then do:
           find last bacc where bacc.aaa = v-docbenacc no-lock no-error.
           if avail bacc then do:
              run savelog("snx1", "392").
              dealing_doc.input_crc = bacc.crc.
           end.
        end.

        if v-docsubtype = 1 then do:
           run savelog("snx1", "398").
           v-docsordacc = "1".
           if v-docsordacc = "1" then v-goal = "Прочее".
              else if v-docsordacc = "2" then v-goal = "Получение услуг".
              else if v-docsordacc = "3" then v-goal = "Выдача займов".
              else if v-docsordacc = "4" then v-goal = "Выполнение обязательств по займам".
              else if v-docsordacc = "5" then v-goal = "Расчеты по операциям с ЦБ".
              else if v-docsordacc = "6" then v-goal = "Выплата заработной платы".
              else if v-docsordacc = "7" then v-goal = "Выплата командировочных и представительских расходов".
              else if v-docsordacc = "8" then v-goal = "Покупка товаров и нематериальных активов".
           create txb.trgt. txb.trgt.jh = int(dealing_doc.DocNo).
           txb.trgt.rem1 = "Осуществление платежей и переводов денег, в том числе по операциям. ".
           txb.trgt.rem2 = v-purptype.
        end.
        rdes = string(dealing_doc.DocNo).
        rsts = 0.
        return.
end.
run savelog("snx1", "111").
v-pri     = 'n'.
v-chg     = 'BEN'.
run savelog("snx1", "v-doctype=" + string(v-doctype)).
if v-doctype ge 1 and v-doctype le 5 then m-typ = entry(v-doctype,'10B,10E,,10B,10B').
run savelog("snx1", "222=" + m-typ).
v-info3   = m-typ + '^' .
v-ref     = v-docref .
v-date    = v-docvaldate .
v-crc     = v-doccrccrc .
v-amt     = v-docamt .
v-acc     = v-docordacc .
v-intmed  = v-docibname2 /*+ ' ' + ib.doc.ibinfo[1] + ib.doc.ibinfo[2] + ib.doc.ibinfo[3] + ib.doc.ibinfo[4]*/ .
run savelog("snx1", "333").
run savelog("snx1", "v-docbenname1=" + v-docbenname1 + "v-docbenname2=" + v-docbenname2 + "v-docbenname3=" + v-docbenname3 +
"v-docbenname4=" + v-docbenname4).
v-bb = v-docbbname1 + ' ' + v-docbbname2 + ' ' + v-docbbname3 + ' ' + v-docbbname4 .
v-ben = v-docbenname2 + ' ' + v-docbenname3 + ' ' + v-docbenname4.
run savelog("snx1", "444").
if m-typ = '10B' and trim(v-docbenname1) <> '' then v-ben = v-ben + ' /RNN/' + v-docbenname1 .
run savelog("snx1", "430 v-ben=" + v-ben ).
v-ba = v-docbenacc .
v-det = v-beninfo1 + '' + v-beninfo2 + '' + v-beninfo3 + '' + v-beninfo4 .
v-chg = v-doccharge.
dep-date = v-docdepdate.
v-cif = v-doccif .
v-pri = v-docurgency .
IF (v-doctype = 4) OR (v-doctype = 5) OR (v-doctype = 1 and v-docsubtype = 4) THEN v-bank = ourbank . ELSE v-bank = v-docbbplc .
run savelog("snx1", "438 v-bank=" + v-bank ).
if not v-bank begins "TXB" then do:
   run savelog("snx1", "440").
   find first txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
   if avail txb.bankl then do:
      run savelog("snx1", "443").
      old-bank = txb.bankl.acct.
      if old-bank <> "" then do:
         find first txb.bankl where txb.bankl.bank = old-bank no-lock no-error.
         if avail txb.bankl then do:
            run savelog("snx1", "448").
            old-bank = v-bank.
            v-bank = txb.bankl.bank.
            l-chng = true.
         end.
      end.
   end.
end.

if can-do('KZ41470142860A037116,KZ05470142860A020401,KZ77470142860A019202,KZ80470142860A020603,KZ41470142860A018104,KZ56470142860A022005,KZ80470142860A020506,KZ82470142860A022507,KZ88470142860A022108,KZ95470142860A021109,KZ68470142860A021110,KZ58470142860A020611,KZ44470142860A022512,KZ53470142860A020313,KZ85470142860A023714,KZ10470142860A023415',v-ba) then v-sal = true.

/* 22.07.04 tsoy Если платеж на филиал то заменить БИК на TXBxx  */
if v-bank = v-clecod then do:
   find first txb where txb.consolid = true and txb.bank = "TXB" + substr(v-docbenacc,19,2) no-lock no-error.
   if avail txb then v-bank = txb.bank.
end. else do:
   find first txb where txb.consolid = true and txb.mfo = v-bank no-lock no-error.
   if avail txb then v-bank = txb.bank.
end.
run savelog("snx1", "464 v-bank=" + v-bank ).
if m-typ = '10B' then v-info = (if v-doctax then '/TAX/' else '') + v-info + ''.
if m-typ = '10B' then do:
   run savelog("snx1", "467").
   if v-bb = '' then do:
      run savelog("snx1", "469").
      find bankl where bankl.bank = v-bank no-lock no-error .
      if avail bankl then v-bb = trim(bankl.name) + ' ' + trim(bankl.addr[1]) + ' ' + trim(bankl.addr[2]) + ' ' + trim (bankl.addr[3]) .
   end .
end. else do :
   run savelog("snx1", "474").
   if v-bank = '' then do :
      run savelog("snx1", "476").
      if v-docbbcode1 = 'SWIFT' then do :
         run savelog("snx1", "478").
         v-ordins = v-docbbcode2 .
         if oi-name <> '' then v-bb = oi-name .
      end.
   end.
   run savelog("snx1", "483 v-bb=" + v-bb).
   if v-bank = '' then do:
      if v-crc = 4 then do:
         v-bb = '/RU' + ' ' + v-docbbcode2 + ' ' + v-ru_bic + ' ' + v-bb .
      end. else do:
            v-bb = v-docbbcode1 + ' ' + v-docbbcode2 + ' ' + v-bb .
      end.
   end. else if v-bb = '' then do :
      find bankl where bankl.bank = v-bank no-lock no-error .
      if avail bankl then do :
         v-bb = trim(bankl.name) + ' ' + trim(bankl.addr[1]) + ' ' + trim(bankl.addr[2]) + ' ' + trim (bankl.addr[3]) .
      end .
   end .
end .
run savelog("snx1", "497 v-bb=" + v-bb).
/* проверка на повторный документ за дату валютирования */
find txb.remtrz where txb.remtrz.sbank = ourbank and txb.remtrz.sqn = v-cif + '.' + string(v-docvaldate,'99/99/9999') + '.' + trim(v-ref) no-lock no-error .
if avail txb.remtrz then do:
   run savelog("snx1", "501").
   v-reterr = 1 .
   rdes = "Ошибка: Платеж с данным номером уже существует".
   rsts = 1.
   return.
end.

if v-reterr eq 0 then do:
   run savelog("snx1", "509").
   find first txb.aaa where txb.aaa.aaa = v-acc no-lock no-error .
   if avail txb.aaa then find txb.cif of txb.aaa no-lock no-error .

   if not avail txb.cif or not avail txb.aaa or ( v-cif ne txb.cif.cif ) then do:
      run savelog("snx1", "514").
      v-reterr = 2.
   end. else do :
      run savelog("snx1", "517").
      /* Ten обработка doc.filial doc.rnn */
      run savelog("snx1", "v-docfilial=" + v-docfilial + "aaa=" + v-acc).
      if v-docfilial <> "" then
         v-ord =  trim(v-docfilial) + '/RNN/'.
      else do:
         v-ord = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)) + '/RNN/'.
      end.
      run savelog("snx1", "444.v-ord=" + v-ord + "v-docrnn=" + v-docrnn).
      if v-docrnn <> "" then do:
         v-ord = v-ord + trim(v-docrnn).
         run savelog("snx1", "555.v-ord=" + v-ord).
      end.
      else do:
        if trim(v-docregcode) = '' then v-ord = v-ord + trim(txb.cif.jss).
        else v-ord = v-ord + trim(v-docregcode).
        run savelog("snx1", "666.v-ord=" + v-ord).
      end.
   end .
end .

find txb.sysc where txb.sysc.sysc = 'othbnk' no-lock no-error .
if avail txb.sysc and txb.sysc.chval ne '' and v-bank ne '' then do:
   run savelog("snx1", "537").
   if lookup(trim(v-bank),txb.sysc.chval,',') ne 0 then do:
      run savelog("snx1", "539").
      old-bank = v-bank .
      l-chng = true .
      v-bank = ourbank.
   end. else l-chng = false  .
end.

if v-reterr eq 0 and v-bank = ourbank then do:
   run savelog("snx1", "547").
   find first txb.aaa where txb.aaa.aaa = v-ba no-lock no-error .
   find first txb.arp where txb.arp.arp = v-ba no-lock no-error .
   if not avail txb.aaa and not avail txb.arp then
      v-reterr = 3 .
   else do:
      if avail txb.aaa then if txb.aaa.crc ne v-crc  then v-reterr = 4.
      if avail txb.arp then if txb.arp.crc ne v-crc  then v-reterr = 4.
   end.
   run savelog("snx1", "556 v-reterr=" + string(v-reterr)).
end.

if v-reterr eq 0 and m-typ = '10b' then do:
   run savelog("snx1", "560").
   if v-bank eq '' then  v-reterr = 5. else do:
      /*known RECEIVER  */
      find first txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
      if not avail txb.bankl then v-reterr = 6 .
   end .
   run savelog("snx1", "566 v-reterr=" + string(v-reterr)).
end.

if v-docbbplc = '' and v-docbbcode2 = '' and v-bb = '' then v-reterr = 7 .
if v-docamt <= 0 then v-reterr = 8 .

create txb.remtrz.
    txb.remtrz.rtim = time.
    find txb.nmbr where txb.nmbr.code eq "REMTRZ" exclusive-lock no-error.
    if not available txb.nmbr then do:
        undo,retry.
    end.
    s-remtrz = txb.nmbr.prefix + string(txb.nmbr.nmbr,txb.nmbr.fmt) + txb.nmbr.sufix.
    run savelog("snx1", "580 s-remtrz=" + s-remtrz).
    txb.nmbr.nmbr = txb.nmbr.nmbr + 1.
    release txb.nmbr.
    txb.remtrz.t_sqn = trim(v-ref) .
    txb.remtrz.rdt = today .
    txb.remtrz.remtrz = s-remtrz.
    if v-crc = 1 then do:
       txb.remtrz.valdt1 = today.
       txb.remtrz.valdt2 = v-date.
    end. else txb.remtrz.valdt1 = v-date.
    txb.remtrz.saddr = tradr .
    txb.remtrz.sacc = v-acc .
    txb.remtrz.tcrc = v-crc .
    txb.remtrz.payment = v-amt .
    txb.remtrz.dracc = v-acc  .
    find first txb.aaa where txb.aaa.aaa = v-acc no-lock no-error .
    txb.remtrz.drgl = txb.aaa.gl .
    txb.remtrz.fcrc = v-crc .
    txb.remtrz.amt = v-amt .
    txb.remtrz.jh1   = ?  .
    txb.remtrz.jh2 = ? .
    run savelog("snx1", "777 v-ord=" + v-ord).
    txb.remtrz.ord = v-ord .
    if txb.remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "snx1.p 533", "1", "", "").
    end.
    run savelog("snx1", "603 v-bb=" + v-bb).
    txb.remtrz.bb[1]  = '/' + substr(v-bb,1,35) .
    txb.remtrz.bb[2]  = substr(v-bb,36,35) .
    txb.remtrz.bb[3]  = substr(v-bb,71,70) .
    txb.remtrz.intmed = v-intmed  .
    txb.remtrz.intmedact  = v-intmed  .
    txb.remtrz.actins[1]  = '/' + substr(v-bb,1,35) .
    txb.remtrz.actins[2]  = substr(v-bb,36,35) .
    txb.remtrz.actins[3]  = substr(v-bb,71,35) .
    txb.remtrz.actins[4]  = substr(v-bb,106,35) .
    txb.remtrz.bn[1] = substr(v-ben,1,60) .
    txb.remtrz.bn[2] = substr(v-ben,61,60) .
    txb.remtrz.bn[3] = substr(v-ben,121,60) .
    txb.remtrz.rcvinfo[1] = substr(v-info,1,35) .
    txb.remtrz.rcvinfo[2] = substr(v-info,36,35) .
    txb.remtrz.rcvinfo[3] = substr(v-info,71,35) .
    txb.remtrz.rcvinfo[4] = substr(v-info,106,35) .
    txb.remtrz.rcvinfo[5] = substr(v-info,141,35) .
    txb.remtrz.rcvinfo[6] = substr(v-info,176,35) .
    if m-typ = '10B' and v-kbk <> '' then txb.remtrz.ba = v-ba + '/' + v-kbk . else txb.remtrz.ba = v-ba .
    txb.remtrz.bi = v-chg .
    txb.remtrz.margb = 0.
    txb.remtrz.margs = 0.
    txb.remtrz.svccgr   = 0.
    txb.remtrz.svca   = 0.
    txb.remtrz.svcaaa = ''.
    txb.remtrz.svcmarg = 0.
    txb.remtrz.svcp = 0.
    txb.remtrz.svcrc = 0.
    txb.remtrz.svccgl = 0.
    txb.remtrz.svcgl = 0.

create txb.sub-cod.
    txb.sub-cod.acc = txb.remtrz.remtrz.
    txb.sub-cod.sub    = 'rmz'.
    txb.sub-cod.d-cod  = 'pdoctng'.
    txb.sub-cod.ccode  =  '01'.

rdes = remtrz.remtrz.

/*tsoy 07.07.2004 Если срочный то провести по ГРОССУ независимо от времени */
if v-docurgency = "U" then do:
   run savelog("snx1", "645").
   txb.remtrz.cover = 2.
   create txb.sub-cod.
      txb.sub-cod.acc = txb.remtrz.remtrz.
      txb.sub-cod.sub = 'rmz'.
      txb.sub-cod.d-cod = "urgency".
      txb.sub-cod.ccode = 's'.
end.

find first txb.crchs where txb.crchs.crc = txb.remtrz.fcrc no-lock no-error.
if m-typ = '10B' and v-crc = 1 then do:
   run savelog("snx1", "656").
   txb.remtrz.svcrc = txb.remtrz.fcrc.
   txb.remtrz.svcaaa = if v-doccomacc <> '' then v-doccomacc else txb.remtrz.dracc.
   find baaa where baaa.aaa = remtrz.svcaaa no-lock no-error.
   if available baaa then remtrz.svcrc = baaa.crc.
   txb.remtrz.svcgl = txb.remtrz.drgl.
   find txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
   if avail txb.bankl and txb.bankl.nu = 'u' then txb.remtrz.svccgr = if v-sal then 0 else 571 .
end. else if ( m-typ eq '10E' and v-crc = 1 ) or crchs.hs = 'h' then do:
   run savelog("snx1", "665").
   txb.remtrz.svcrc = txb.remtrz.fcrc.
   txb.remtrz.svcaaa = if v-doccomacc <> '' then v-doccomacc else txb.remtrz.dracc.
   find baaa where baaa.aaa = remtrz.svcaaa no-lock no-error.
   if available baaa then txb.remtrz.svcrc = baaa.crc.
   txb.remtrz.svcgl = txb.remtrz.drgl.
   find txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
   if avail txb.bankl then if txb.bankl.nu = 'u' then txb.remtrz.svccgr = if v-sal then 0 else 571 .
end. else if m-typ ne '10B' and  crchs.hs = 's' then do:
   run savelog("snx1", "674").
   txb.remtrz.svcrc = txb.remtrz.fcrc.
   txb.remtrz.svcaaa = if v-doccomacc <> '' then v-doccomacc else txb.remtrz.dracc.
   txb.remtrz.svcgl = txb.remtrz.drgl.
   find baaa where baaa.aaa = txb.remtrz.svcaaa no-lock no-error.
   if available baaa then txb.remtrz.svcrc = baaa.crc.
end.

find first txb.aaa where txb.aaa.aaa = txb.remtrz.dracc no-lock no-error .
txb.remtrz.sqn = v-cif + '.' + string(v-docvaldate,'99/99/9999') + '.' +  trim(v-ref).
txb.remtrz.cracc = ''.
txb.remtrz.crgl = 0.
txb.remtrz.sbank = ourbank.
txb.remtrz.scbank = ourbank.
find bankl where bankl.bank = remtrz.sbank no-lock no-error.
if available bankl then txb.remtrz.ordins[1] = v-nbankru .
txb.remtrz.rcbank = ''.
txb.remtrz.rbank = v-bank.

acode = ''.
txb.remtrz.racc = v-ba .
txb.remtrz.outcode = 3 .

if v-bank eq '' and not brnch then  do:
   run savelog("snx1", "698").
end. else do:
   run savelog("snx1", "700").
   if brnch and v-bank = '' then  v-bank = clecod.
   /*  known RECEIVER  */
   find first txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
   if not avail txb.bankl then  v-reterr = v-reterr + 9.
   else if txb.bankl.bank ne ourbank  then do:
       run savelog("snx1", "706").
       find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.  bcode = txb.crc.code .
       find first txb.bankt where txb.bankt.cbank = txb.bankl.cbank and txb.bankt.crc = txb.remtrz.tcrc and txb.bankt.racc = '1' no-lock no-error .
       if not avail txb.bankt then do:
          run savelog("snx1", "710").
       end. else do :
          run savelog("snx1", "712").
          if v-crc <> 1 then do:
             if txb.remtrz.valdt1 >= vg-today then txb.remtrz.valdt2 = txb.remtrz.valdt1 + txb.bankt.vdate .
             else txb.remtrz.valdt2 = vg-today + txb.bankt.vdate .
          end.
          if txb.remtrz.valdt2 = vg-today and txb.bankt.vtime < time  then txb.remtrz.cover = 2.
          if v-crc = 1 then do:
             if txb.remtrz.rtim >= 53100 then txb.remtrz.cover = 2.
          end.
          /*------ Для филиалов - проставление CLEAR или GROSS kanat --------*/
          if brnch then do:
             find first txb.sysc where txb.sysc.sysc = "PSJTIM" no-lock no-error.
             if avail txb.sysc then do:
                if txb.remtrz.rtim >= 53100 then txb.remtrz.cover = 2.
             end.
          end.
          /*----------------------------------------------------------------*/
          repeat:
               find txb.hol where txb.hol.hol eq txb.remtrz.valdt2 no-lock  no-error.
               if not available txb.hol and weekday(txb.remtrz.valdt2) ge v-weekbeg and weekday(txb.remtrz.valdt2) le v-weekend then do:
                  leave.
               end. else txb.remtrz.valdt2  = txb.remtrz.valdt2 + 1.
          end.
          find first t-bankl where t-bankl.bank = txb.bankt.cbank no-lock .
          txb.remtrz.rcbank = t-bankl.bank .
          find first txb.sysc where txb.sysc.sysc = "netgro" no-lock.
          if (not brnch and txb.bankl.nu = "u") or (brnch and txb.remtrz.rbank = clecod) then
             txb.remtrz.cover = 5.
          else do:
             if txb.remtrz.tcrc = 1 and (t-bankl.crbank ne "clear" or txb.remtrz.payment >= txb.sysc.deval) then txb.remtrz.cover = 2.
          end.
          /*Добавил согласно ТЗ 1229*/
          if v-crc = 1 then do:
             if txb.remtrz.ptype <> "M"  then do:
                if txb.remtrz.valdt2 <> vg-today and txb.remtrz.payment < txb.sysc.deval and v-docurgency <> "U" then txb.remtrz.cover = 1.
             end.
          end.
          /*Добавил согласно ТЗ 1229*/
          if t-bankl.nu = 'u' then do:
             receiver = 'u'.
             txb.remtrz.rsub = 'cif'.
          end. else do:
             receiver = 'n' .
             if txb.remtrz.ba = '' then txb.remtrz.ba = '/' +  v-ba .
          end .
          txb.remtrz.rcbank = t-bankl.bank .
          txb.remtrz.raddr = t-bankl.crbank.
          txb.remtrz.cracc = txb.bankt.acc.
          if txb.bankt.subl = 'dfb' then do:
             run savelog("snx1", "761").
             find first txb.dfb where txb.dfb.dfb = txb.bankt.acc no-lock no-error .
             if not avail txb.dfb  then do:
                v-reterr = v-reterr + 125.
             end. else do:
                txb.remtrz.crgl = txb.dfb.gl.
                find tgl where tgl.gl = txb.remtrz.crgl no-lock.
             end.
          end.
          if txb.bankt.subl = 'cif' then do:
             run savelog("snx1", "771").
             find first txb.aaa where txb.aaa.aaa = txb.bankt.acc no-lock no-error .
             if not avail txb.aaa  then do:
                v-reterr = v-reterr + 126.  /*  */  .
             end. else do:
                txb.remtrz.crgl = aaa.gl.
                find tgl where tgl.gl = remtrz.crgl no-lock.
             end.
          end.
       end .  /* not error */
       find first txb.bankl where txb.bankl.bank = v-bank no-lock no-error.
   end. else do :
       run savelog("snx1", "783").
       txb.remtrz.rsub = 'cif'.
       txb.remtrz.raddr = ''.
       if txb.remtrz.rsub ne '' then do:
          run savelog("snx1", "787").
          c-acc = txb.remtrz.racc .
          if rsub = 'cif' then do:
             find first txb.aaa where txb.aaa.aaa = c-acc and txb.aaa.crc eq txb.remtrz.tcrc no-lock no-error .
             if avail aaa then do:
                if txb.aaa.sta eq 'C' then do:
                   v-reterr = v-reterr + 8.
                end. else do :
                   find tgl where tgl.gl = txb.aaa.gl no-lock.
                   txb.remtrz.cracc = txb.remtrz.racc .
                   txb.remtrz.crgl = tgl.gl.
                end .
             end. else do:
                v-reterr = v-reterr + 32.
             end.
          end. else do:
             v-reterr = v-reterr + 64 .  /* */ .
          end.
       end. else do:
          v-reterr = v-reterr + 128 .  /* */ .
       end.
   end.
end.
find first txb.aaa where txb.aaa.aaa = txb.remtrz.dracc no-lock no-error .
find first xaaa where xaaa.aaa = txb.remtrz.cracc no-lock no-error .
if avail aaa and avail xaaa then do:
   run savelog("snx1", "813").
   if xaaa.cif = txb.aaa.cif and txb.aaa.cif ne '' then do:
      txb.remtrz.svcrc = 0.
      txb.remtrz.svcaaa = ''.
      txb.remtrz.svcgl = 0.
      txb.remtrz.svccgr = 0 .
      txb.remtrz.svca = 0 .
      txb.remtrz.svccgl = 0 .
   end.
end.
txb.remtrz.ref = (substr(trim(v-cif),1,6) + fill(' ' , 6 - length(substr(trim(v-cif),1,6)))) + 'IBNK' + (substr(trim(v-ref),1,12) +
    fill(' ' , 12 - length(substr(trim(v-ref),1,12)))) + (substr(trim(ourbank),1,12) + fill(' ' , 12 - length(substr(trim(ourbank),1,12)))) +
    (substr(trim(v-acc),1,10) + fill(' ' , 10 - length(substr(trim(v-acc),1,10)))) + string(day(dep-date),'99') + string(month(dep-date),'99') +
    substr(string(year(dep-date),'9999'),3,2) .
if m-typ = '10B' and txb.remtrz.fcrc = 1 and txb.remtrz.crgl ne 0 and txb.remtrz.cracc ne '0' then
   txb.remtrz.chg = 0.
else
   txb.remtrz.chg = 7 .
if txb.remtrz.rbank = ourbank then txb.remtrz.rcbank = ourbank.
if txb.remtrz.rcbank = '' then txb.remtrz.rcbank = txb.remtrz.rbank .
if txb.remtrz.scbank = '' then txb.remtrz.scbank = txb.remtrz.sbank .
find first txb.bankl where txb.bankl.bank = txb.remtrz.scbank  no-lock no-error .
if avail txb.bankl then
   if txb.bankl.nu = 'u' then sender = 'u'. else sender = 'n' .
else
   sender = '' .
find first txb.bankl where txb.bankl.bank = txb.remtrz.rcbank no-lock no-error .
if avail txb.bankl then
   if txb.bankl.nu = 'u' then receiver  = 'u'. else receiver  = 'n' .
else
   receiver = '' .
if txb.remtrz.scbank = ourbank then sender = 'o' .
if txb.remtrz.rcbank = ourbank then receiver  = 'o' .
find first txb.ptyp where txb.ptyp.sender = sender and txb.ptyp.receiver = receiver no-lock no-error .
if avail txb.ptyp then
   txb.remtrz.ptype = txb.ptyp.ptype.
else
   txb.remtrz.ptype = 'N'.
if  txb.remtrz.ptype = "M"  then txb.remtrz.bi = "OUR" .

if txb.remtrz.tcrc = 1 then do:
   if length(v-det) <= 140  then do:
      txb.remtrz.det[1] = substr(v-det,1,35) .
      txb.remtrz.det[2] = substr(v-det,36,35) .
      txb.remtrz.det[3] = substr(v-det,71,35) .
      txb.remtrz.det[4] = substr(v-det,106,35) .
   end. else do:
      txb.remtrz.det[1] = substr(v-det,1,120) .
      txb.remtrz.det[2] = substr(v-det,121,120) .
      txb.remtrz.det[3] = substr(v-det,241,120) .
      txb.remtrz.det[4] = substr(v-det,361,122) .
   end.
end. else do:
   txb.remtrz.det[1] = substr(v-det,1,35) .
   txb.remtrz.det[2] = substr(v-det,36,35) .
   txb.remtrz.det[3] = substr(v-det,71,35) .
   txb.remtrz.det[4] = substr(v-det,106,35) .
end.

txb.remtrz.rwho   = "superman" .
txb.remtrz.source = "IBH" .
txb.remtrz.rtim   = time.

v-text = v-cps-get( v-doccodepar2, 'BENRES', 1, 'R' ).
v-text = if v-text = 'R' then '1' else '2'.

v-text = v-eknp(v-doccif, txb.remtrz.remtrz, v-text, substr(v-docbbinfo1, 1, 1), int( substr( v-docbbinfo2,  1, 3 ))).

if receiver ne 'o' and v-bank ne '' then do:
   run savelog("snx1", "882").
   find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
   if avail txb.sysc and  txb.sysc.chval ne  "" then do:
      if txb.remtrz.sbank ne txb.sysc.chval  and  txb.remtrz.jh1 eq ? and txb.remtrz.dracc ne "" then do:
          find first txb.nbal where txb.nbal.dfb = txb.remtrz.dracc and txb.nbal.plus = txb.remtrz.valdt1 - vg-today exclusive-lock no-error .
          if not avail txb.nbal then do:
             create txb.nbal .
                 txb.nbal.dfb = txb.remtrz.dracc .
                 txb.nbal.plus = txb.remtrz.valdt1 - vg-today .
                 txb.nbal.inwbal = 0 .
                 txb.nbal.outbal = 0 .
          end .
          txb.nbal.inwbal = txb.nbal.inwbal + txb.remtrz.amt .
      end.
      if txb.remtrz.rbank ne txb.sysc.chval  and txb.remtrz.jh2 eq ? and txb.remtrz.cracc ne "" then do:
         find first txb.nbal where txb.nbal.dfb = txb.remtrz.cracc and txb.nbal.plus = txb.remtrz.valdt2 - vg-today exclusive-lock no-error .
         if not avail txb.nbal then do:
            create txb.nbal.
               txb.nbal.dfb = txb.remtrz.cracc .
               txb.nbal.plus = txb.remtrz.valdt2 - vg-today .
               txb.nbal.inwbal = 0 .
               txb.nbal.outbal = 0 .
         end .
         txb.nbal.outbal = txb.nbal.outbal + txb.remtrz.payment.
      end.
   end.
end.

if v-ba = 'KZ81470192870A023308' then assign txb.remtrz.rsub = 'arp' txb.remtrz.rcvinfo[3] = txb.remtrz.remtrz.
if v-doctype = 1 and v-docsubtype = 3 then do:
   txb.remtrz.rcvinfo[1] = "/PSJ/".
   find first txb.sysc where txb.sysc.sysc = "PSJIN" no-lock.
   if avail txb.sysc then
      pf_file = trim(txb.sysc.chval) + trim(txb.remtrz.remtrz).
   else do:
      run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
      if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
      else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").
      run setUser in ptpsession ("SonicClient").
      run setPassword in ptpsession ("SonicClient").
      RUN beginSession IN ptpsession.
      run createXMLMessage in ptpsession (output messageH).
      run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
      run appendText in messageH ("<DOC>").
      if remtrz.fcrc = 1 then
         run appendText in messageH ("<PAYMENT>").
      else
         run appendText in messageH ("<CURRENCY_PAYMENT>").
      run appendText in messageH ("<ID>" + netbank.id + "</ID>").
      run appendText in messageH ("<STATUS>6</STATUS>").
      run appendText in messageH ("<DESCRIPTION>Отвергнут</DESCRIPTION>").
      run appendText in messageH ("<TIMESTAMP>" + string(vg-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
      if remtrz.fcrc = 1 then
         run appendText in messageH ("</PAYMENT>").
      else
         run appendText in messageH ("</CURRENCY_PAYMENT>").
      run appendText in messageH ("</DOC>").
      RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
      RUN deleteMessage IN messageH.
      netbank.sts = "6".
      netbank.rem[1] = "Отвергнут" .
      find first txb.que where txb.que.remtrz=txb.remtrz.remtrz exclusive-lock no-error.
      if avail txb.que then delete txb.que.
      delete txb.remtrz.
      rdes = "Ошибка: транспортировки".
      rsts = 1.
      return.
   end.
   unix silent value ( ' cp ' + v-docordacc + '_' + v-docref + '.txt ' +  pf_file).
   pause 3 no-message.
   /*Ошибка транспортировки пенсионного файла добавить отвержение*/
   if SEARCH(pf_file) = ? then do:
       run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
       if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
       else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").
       run setUser in ptpsession ("SonicClient").
       run setPassword in ptpsession ("SonicClient").
       RUN beginSession IN ptpsession.
       run createXMLMessage in ptpsession (output messageH).
       run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in messageH ("<DOC>").
       if remtrz.fcrc = 1 then
          run appendText in messageH ("<PAYMENT>").
       else
          run appendText in messageH ("<CURRENCY_PAYMENT>").
       run appendText in messageH ("<ID>" + netbank.id + "</ID>").
       run appendText in messageH ("<STATUS>6</STATUS>").
       run appendText in messageH ("<DESCRIPTION>Отвергнут</DESCRIPTION>").
       run appendText in messageH ("<TIMESTAMP>" + string(vg-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
       if remtrz.fcrc = 1 then
          run appendText in messageH ("</PAYMENT>").
       else
          run appendText in messageH ("</CURRENCY_PAYMENT>").
       run appendText in messageH ("</DOC>").
       RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
       RUN deleteMessage IN messageH.
       netbank.sts = "6".
       netbank.rem[1] = "Отвергнут" .
       find first txb.que where txb.que.remtrz = txb.remtrz.remtrz exclusive-lock no-error.
       if avail txb.que then delete txb.que.
       delete txb.remtrz.
       rdes = "Ошибка транспортировки".
       rsts = 1.
       return.
   end.
end.
/* KOVAL Новый ввод swift  */
if v-doctype = 2 then do:
   run savelog("snx1", "991").
   find first comm.swout where comm.swout.rmz=s-remtrz no-lock no-error.
   if avail comm.swout then do:
      for each comm.swbody where comm.swbody.rmz = s-remtrz.
          delete comm.swbody.
      end.
      release comm.swbody.
   end. else do:
      create comm.swout.
   end.
   assign comm.swout.rmz = s-remtrz
       comm.swout.cif = v-doccif
       comm.swout.mt  = '103'
       comm.swout.credate = today
       comm.swout.cretime = time
       comm.swout.creuid = userid("bank")
       comm.swout.branch = ourbank.

   /*Evseev TZ-926***********************************************************/
   create comm.swbody.
   assign
       comm.swbody.rmz     = s-remtrz
       comm.swbody.type    = ""
       comm.swbody.swfield = "20"
       comm.swbody.content[1] = s-remtrz + "-S".
   run toLogSWBody.

   create comm.swbody.
   assign
       comm.swbody.rmz     = s-remtrz
       comm.swbody.type    = "B"
       comm.swbody.swfield = "23"
       comm.swbody.content[1] = "CRED".
   run toLogSWBody.


   create comm.swbody.
   assign
       comm.swbody.rmz     = s-remtrz
       comm.swbody.type    = "A"
       comm.swbody.swfield = "32".
       find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
       v-tmpstr = trim(string(txb.remtrz.payment,">>>>>>>>>>>>>>>9.99")).
       v-tmpstr = replace(v-tmpstr, ".", ",").
       comm.swbody.content[1] = substr(string(year(g-today)), 3, 2)  + "" + string(month(g-today),"99") + "" +
            string(day(g-today), "99")  + "" + txb.crc.code + "" + v-tmpstr.
   run toLogSWBody.

   v-tmpstr = if lookup(txb.remtrz.bi,"BEN,OUR,SHA") > 0 then txb.remtrz.bi else "OUR".
   if v-tmpstr <> "OUR" then do:
       create comm.swbody.
       assign
           comm.swbody.rmz     = s-remtrz
           comm.swbody.type    = "B"
           comm.swbody.swfield = "33".
       run toLogSWBody.
   end.

   if txb.remtrz.tcrc  <> 4 then do:
       v-tmpstr = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).
       run rus2lat(input v-tmpstr, output v-dest, output v-err).
       v-tmpstr = v-dest.
       create comm.swbody.
       assign
           comm.swbody.rmz     = s-remtrz
           comm.swbody.type    = "K"
           comm.swbody.swfield = "50"
           comm.swbody.content[1] = "/" + txb.remtrz.sacc
           comm.swbody.content[2] = "1/BIN" + trim(txb.cif.bin)
           comm.swbody.content[3] = "1/" + substr(v-tmpstr,  1,33).
           if trim(substr(v-tmpstr,  34,33)) <> "" then comm.swbody.content[4] = "1/" + substr(v-tmpstr,  34,33).

           v-tmpstr = trim(entry(4,txb.cif.addr[1]) + " " + entry(5,txb.cif.addr[1]) + " " + entry(6,txb.cif.addr[1])).
           run rus2lat(input v-tmpstr, output v-dest, output v-err).
           v-tmpstr = v-dest.
           if comm.swbody.content[4] = "" then comm.swbody.content[4] =  substr("2/" + v-tmpstr ,1,33).  /*адрес*/
           else comm.swbody.content[5] =  substr("2/" + v-tmpstr,1,33).  /*адрес*/

           v-tmpstr = trim(entry(3,txb.cif.addr[1])).
           run rus2lat(input v-tmpstr, output v-dest, output v-err).
           v-tmpstr = v-dest.
           if comm.swbody.content[5] = "" then comm.swbody.content[5] = "3/" + substr(entry(2,entry(1,txb.cif.addr[1]),'('),1,2) + "/" + v-tmpstr. /*код страны город*/
           else comm.swbody.content[6] = "3/" + substr(entry(2,entry(1,txb.cif.addr[1]),'('),1,2) + "/" + v-tmpstr. /*код страны город*/
   end. else do:
       v-tmpstr = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).
       run rur2lat(input v-tmpstr, output v-dest, output v-err).
       v-tmpstr = v-dest.
       create comm.swbody.
       assign
           comm.swbody.rmz     = s-remtrz
           comm.swbody.type    = "K"
           comm.swbody.swfield = "50"
           comm.swbody.content[1] = "/" + txb.remtrz.sacc
           comm.swbody.content[2] = "1/BIN" + trim(txb.cif.bin)
           comm.swbody.content[3] = "1/" + substr(v-tmpstr,  1,33).
           if trim(substr(v-tmpstr,  34,33)) <> "" then comm.swbody.content[4] = "1/" + substr(v-tmpstr,  34,33).

           v-tmpstr = trim(entry(4,txb.cif.addr[1]) + " " + entry(5,txb.cif.addr[1]) + " " + entry(6,txb.cif.addr[1])).
           run rur2lat(input v-tmpstr, output v-dest, output v-err).
           v-tmpstr = v-dest.
           if comm.swbody.content[4] = "" then comm.swbody.content[4] =  substr("2/" + v-tmpstr ,1,33).  /*адрес*/
           else comm.swbody.content[5] =  substr("2/" + v-tmpstr,1,33).  /*адрес*/

           v-tmpstr = trim(entry(3,txb.cif.addr[1])).
           run rur2lat(input v-tmpstr, output v-dest, output v-err).
           v-tmpstr = v-dest.
           if comm.swbody.content[5] = "" then comm.swbody.content[5] = "3/" + substr(entry(2,entry(1,txb.cif.addr[1]),'('),1,2) + "/" + v-tmpstr. /*код страны город*/
           else comm.swbody.content[6] = "3/" + substr(entry(2,entry(1,txb.cif.addr[1]),'('),1,2) + "/" + v-tmpstr. /*код страны город*/
   end.
   run toLogSWBody.
   txb.remtrz.ord = trim(comm.swbody.content[1] + " " + comm.swbody.content[2]  + " " + comm.swbody.content[3]  + " " + comm.swbody.content[4]  + " " + comm.swbody.content[5]  + " " + comm.swbody.content[6] ).
   if txb.remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "snx1.p 1159", "1", "", "").
   end.

   create comm.swbody.
   assign
       comm.swbody.rmz     = s-remtrz
       comm.swbody.type    = "N"
       comm.swbody.swfield = "53".
   run toLogSWBody.

   if txb.remtrz.tcrc  <> 4 then do:
        if trim(v-INTERMED_BANK_BIC_TYPE) = "SWIFT" then do:
            if v-docibcode2 <> "" then do:
                v-tmpstr = v-docibname2.
                run rus2lat(input v-tmpstr, output v-dest, output v-err).
                v-tmpstr = v-dest.
                create comm.swbody.
                assign
                    comm.swbody.rmz     = s-remtrz
                    comm.swbody.type    = "A"
                    comm.swbody.swfield = "56".
                    if length(trim(v-docibcode2)) = 8 then comm.swbody.content[1] = trim(v-docibcode2) + "XXX".
                    else comm.swbody.content[1] = trim(v-docibcode2).
                txb.remtrz.intmed = comm.swbody.content[1] + " " + trim(v-tmpstr).
            end.
        end. else do:
            v-tmpstr = v-docibname2.
            run rus2lat(input v-tmpstr, output v-dest, output v-err).
            v-tmpstr = v-dest.
            create comm.swbody.
            assign
                comm.swbody.rmz     = s-remtrz
                comm.swbody.type    = "D"
                comm.swbody.swfield = "56"
                comm.swbody.content[2] = substr(trim(v-tmpstr),  1,35)
                comm.swbody.content[3] = substr(trim(v-tmpstr),  36,35)
                comm.swbody.content[4] = substr(trim(v-tmpstr),  71,35).
           v-tmpstr = trim(v-INTERMED_BANK_BIC_TYPE).
           if v-tmpstr = "SORTING CODE"  then v-tmpstr = "//SC".
           if v-tmpstr = "ABA ROUTING"  then v-tmpstr = "//FW".
           if v-tmpstr = "BLZ"  then v-tmpstr = "//BL".
           if v-tmpstr = "CHIPS"  then v-tmpstr = "//FW".
           comm.swbody.content[1] = v-tmpstr + v-docibcode2.

           txb.remtrz.intmed = trim(comm.swbody.content[1]) + " " + comm.swbody.content[2] + comm.swbody.content[3] + comm.swbody.content[4].
        end.
        run toLogSWBody.

        if trim(v-RCPT_BANK_BIC_TYPE) = "SWIFT" then do:
            create comm.swbody.
            assign
                comm.swbody.rmz     = s-remtrz
                comm.swbody.type    = "A"
                comm.swbody.swfield = "57".
                if length(trim(v-docbbcode2)) = 8 then comm.swbody.content[1] = trim(v-docbbcode2) + "XXX".
                else comm.swbody.content[1] = trim(v-docbbcode2).
            txb.remtrz.bb[1]  = comm.swbody.content[1] .
            txb.remtrz.bb[2]  = v-docbbname1.
        end. else do:
            v-tmpstr = v-docbbname1.
            run rus2lat(input v-tmpstr, output v-dest, output v-err).
            v-tmpstr = v-dest.
            create comm.swbody.
            assign
                comm.swbody.rmz     = s-remtrz
                comm.swbody.type    = "D"
                comm.swbody.swfield = "57"
                comm.swbody.content[2] = substr(trim(v-tmpstr),  1,35)
                comm.swbody.content[3] = substr(trim(v-tmpstr),  36,35)
                comm.swbody.content[4] = substr(trim(v-tmpstr),  71,35).

            v-tmpstr = trim(v-RCPT_BANK_BIC_TYPE).
            if v-tmpstr = "SORTING CODE"  then v-tmpstr = "//SC".
            if v-tmpstr = "ABA ROUTING"  then v-tmpstr = "//FW".
            if v-tmpstr = "BLZ"  then v-tmpstr = "//BL".
            if v-tmpstr = "CHIPS"  then v-tmpstr = "//FW".
            comm.swbody.content[1] = v-tmpstr + v-docbbcode2.

            txb.remtrz.bb[1]  = comm.swbody.content[1] .
            txb.remtrz.bb[2]  = comm.swbody.content[2] .
            txb.remtrz.bb[3]  = comm.swbody.content[3] + comm.swbody.content[4].
        end.
        run toLogSWBody.

        v-tmpstr = v-docbenname2.
        run rus2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = ""
            comm.swbody.swfield = "59"
            comm.swbody.content[1] = "/" + trim(v-docbenacc)
            comm.swbody.content[2] = substr(v-tmpstr,  1,35)
            comm.swbody.content[3] = substr(v-tmpstr, 36,35)
            comm.swbody.content[4] = substr(v-tmpstr, 71,35)
            comm.swbody.content[5] = substr(v-tmpstr,106,35).
        run toLogSWBody.
        txb.remtrz.ba  = trim(v-docbenacc) .
        txb.remtrz.bn[1]  = comm.swbody.content[2] .
        txb.remtrz.bn[2]  = comm.swbody.content[3] .
        txb.remtrz.bn[3]  = comm.swbody.content[4] +  comm.swbody.content[5].


        v-tmpstr = v-beninfo1.
        run rus2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = ""
            comm.swbody.swfield = "70"
            comm.swbody.content[1] = substr(v-tmpstr,  1,35)
            comm.swbody.content[2] = substr(v-tmpstr, 36,35)
            comm.swbody.content[3] = substr(v-tmpstr, 71,35)
            comm.swbody.content[4] = substr(v-tmpstr,106,35).
        run toLogSWBody.
        txb.remtrz.det[1] = comm.swbody.content[1] .
        txb.remtrz.det[2] = comm.swbody.content[2] .
        txb.remtrz.det[3] = comm.swbody.content[3] .
        txb.remtrz.det[4] = comm.swbody.content[4] .

        v-tmpstr = if lookup(txb.remtrz.bi,"BEN,OUR,SHA") > 0 then txb.remtrz.bi else "OUR".
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = "A"
            comm.swbody.swfield = "71"
            comm.swbody.content[1] = v-tmpstr.
        run toLogSWBody.
        txb.remtrz.bi = comm.swbody.content[1].

        if v-tmpstr <> "OUR" then do:
            /*find first txb.tarif2 where txb.tarif2.num + txb.tarif2.kod = string(txb.remtrz.svccgr) no-lock no-error.
            v-tmpdec = 0.
            if avail txb.tarif2 and txb.tarif2.proc > 0 then do:
                v-tmpdec = txb.remtrz.payment / 100 * txb.tarif2.proc.
                find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
                v-tmpdec = v-tmpdec * txb.crc.rate[1].
                if txb.tarif2.max1 > 0 and txb.tarif2.max1 < v-tmpdec then v-tmpdec = txb.tarif2.max1.
                if txb.tarif2.min1 > 0 and txb.tarif2.min1 > v-tmpdec then v-tmpdec = txb.tarif2.min1.
                v-tmpdec = v-tmpdec / txb.crc.rate[1].
                v-tmpdec = round(v-tmpdec,2).
            end.*/
            run savelog("snx1",  "1316. " + string(txb.remtrz.svccgr) + " | " + string(txb.remtrz.svca) ).
            if txb.remtrz.svcrc = 1 then do:
                find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
                v-tmpdec = txb.remtrz.svca.
                v-tmpdec = v-tmpdec / txb.crc.rate[1].
                v-tmpdec = round(v-tmpdec,2).
            end. else if txb.remtrz.svcrc <> txb.remtrz.tcrc then do:
                v-tmpdec = txb.remtrz.svca.
                find first txb.crc where txb.crc.crc = txb.remtrz.svcrc no-lock no-error.
                v-tmpdec = v-tmpdec * txb.crc.rate[1].
                find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
                v-tmpdec = v-tmpdec / txb.crc.rate[1].
                v-tmpdec = round(v-tmpdec,2).
            end. else do:
                find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
                v-tmpdec = txb.remtrz.svca.
            end.

            create comm.swbody.
            assign
                comm.swbody.rmz     = s-remtrz
                comm.swbody.type    = "F"
                comm.swbody.swfield = "71"
                comm.swbody.content[1] = txb.crc.code + replace(string(v-tmpdec),".",",").  /*3!a15d (Currency)(Amount)*/
            run toLogSWBody.
        end.
   end. else do:
        /*v-tmpstr = v-docbbname1.
        run rur2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.*/
        /*57D://RU044525502. 30101810000000000502
            RCPT_BANK_BIC =  049706752
            RUBIC_ACCOUNT =  30101810600000000752
        */
        v-tmpstr = "//RU" + trim(v-docbbcode2) + "." + trim(v-ru_bic).
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = "D"
            comm.swbody.swfield = "57"
            comm.swbody.content[1] = substr(trim(v-tmpstr),  1,35).

        v-tmpstr = v-docbbname1.
        /*отделяем город от названия банка*/
        if index(v-tmpstr,chr(10)) > 0 then do:
            v-tmpstr = substring(v-tmpstr,1,index(v-tmpstr,chr(10)) - 1).
            v-docbbcity = substring(v-docbbname1,index(v-docbbname1,chr(10)) + 1,length(v-docbbname1)).
        end.
        /*отделяем город от названия банка*/
        run rur2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.
        if trim(v-docbbcity) <> '' then do:
            run rur2lat(input v-docbbcity, output v-dest, output v-err).
            v-docbbcity = v-dest.
            comm.swbody.content[2] = substr(trim(v-tmpstr),  1,35).
            comm.swbody.content[3] = substr(trim(v-tmpstr),  36,35).
            comm.swbody.content[4] = substr(trim(v-tmpstr),  71,35).

            if comm.swbody.content[3] = '' then do:
                comm.swbody.content[3] = substr(trim(v-docbbcity), 1,35).
                comm.swbody.content[4] = ''.
            end. else do:
                if comm.swbody.content[4] = '' then
                    comm.swbody.content[4] = substr(trim(v-docbbcity), 1,35).
                else comm.swbody.content[5] = substr(trim(v-docbbcity), 1,35).
            end.

        end. else do:
            comm.swbody.content[2] = substr(trim(v-tmpstr),  1,35).
            comm.swbody.content[3] = substr(trim(v-tmpstr),  36,35).
            comm.swbody.content[4] = substr(trim(v-tmpstr),  71,35).
        end.
        run toLogSWBody.
        txb.remtrz.bb[1]  = comm.swbody.content[1] .
        txb.remtrz.bb[2]  = comm.swbody.content[2] .
        txb.remtrz.bb[3]  = comm.swbody.content[3] + comm.swbody.content[4].
        if comm.swbody.content[5] <> '' and comm.swbody.content[5] <> ? then do:
            if txb.remtrz.bb[3] <> '' then
                txb.remtrz.bb[3] = txb.remtrz.bb[3] + " " + comm.swbody.content[5].
            else txb.remtrz.bb[3] = comm.swbody.content[5].
        end.

        v-tmpstr = v-docbenname2.
        run rur2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = ""
            comm.swbody.swfield = "59"
            comm.swbody.content[1] = "/" + trim(v-docbenacc).
            if trim(inn_kpp) <> '' then do:
                comm.swbody.content[2] = trim(inn_kpp).
                comm.swbody.content[3] = substr(v-tmpstr,  1,35).
                comm.swbody.content[4] = substr(v-tmpstr, 36,35).
                comm.swbody.content[5] = substr(v-tmpstr, 71,35).
                comm.swbody.content[6] = substr(v-tmpstr,106,35).
            end. else do:
                comm.swbody.content[2] = substr(v-tmpstr,  1,35).
                comm.swbody.content[3] = substr(v-tmpstr, 36,35).
                comm.swbody.content[4] = substr(v-tmpstr, 71,35).
                comm.swbody.content[5] = substr(v-tmpstr,106,35).
            end.
        run toLogSWBody.
        txb.remtrz.ba  = trim(v-docbenacc) .
        txb.remtrz.bn[1]  = comm.swbody.content[2] .
        txb.remtrz.bn[2]  = comm.swbody.content[3] .
        txb.remtrz.bn[3]  = comm.swbody.content[4] + comm.swbody.content[5].
        if comm.swbody.content[6] <> '' and comm.swbody.content[6] <> ? then
            txb.remtrz.bn[3] = txb.remtrz.bn[3] + comm.swbody.content[6].

        v-tmpstr = v-beninfo1.
        run rur2lat(input v-tmpstr, output v-dest, output v-err).
        v-tmpstr = v-dest.
        /*корректировка после транслитирования*/
        if index(v-tmpstr,"VO") > 0 then do:
            v-tmpstr = replace(v-tmpstr,"'","").
            if substr(v-tmpstr,1,1) = "j" then v-tmpstr = substr(v-tmpstr,2).
            if substr(v-tmpstr,1,3) = "(VO" and substr(v-tmpstr,9,1) = ")" then do:
                v-tmpstr = "'" + substr(v-tmpstr,1,9) + "'" + substr(v-tmpstr,10).
            end.
        end.
        /*корректировка после транслитирования*/
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = ""
            comm.swbody.swfield = "70"
            comm.swbody.content[1] = substr(v-tmpstr,  1,35)
            comm.swbody.content[2] = substr(v-tmpstr, 36,35)
            comm.swbody.content[3] = substr(v-tmpstr, 71,35)
            comm.swbody.content[4] = substr(v-tmpstr,106,35).
        run toLogSWBody.
        txb.remtrz.det[1] = comm.swbody.content[1] .
        txb.remtrz.det[2] = comm.swbody.content[2] .
        txb.remtrz.det[3] = comm.swbody.content[3] .
        txb.remtrz.det[4] = comm.swbody.content[4] .


        v-tmpstr = if lookup(txb.remtrz.bi,"BEN,OUR") > 0 then txb.remtrz.bi else "OUR".
        create comm.swbody.
        assign
            comm.swbody.rmz     = s-remtrz
            comm.swbody.type    = "A"
            comm.swbody.swfield = "71"
            comm.swbody.content[1] = v-tmpstr.
        run toLogSWBody.
        txb.remtrz.bi = comm.swbody.content[1].
   end.
   create comm.swbody.
   assign
       comm.swbody.rmz     = s-remtrz
       comm.swbody.type    = ""
       comm.swbody.swfield = "DS".
   run toLogSWBody.
   /*************************************************************************/

   /*
       def var tmpRNN as char.
       def var tmpstr as char.
       def var tmpstr3 as char.
       def var tmpi as integer.
       def buffer tmpswb for comm.swbody.
       def var v-engcity as char.

       find first comm.swlist where comm.swlist.mt = '103' no-lock no-error.
       repeat i=1 to NUM-ENTRIES(comm.swlist.flist):

           find first comm.swfield where comm.swfield.swfld = ENTRY (i,comm.swlist.flist) no-lock.
           create comm.swbody.
              assign
                  comm.swbody.rmz     = s-remtrz
                  comm.swbody.type    = if lookup('N',comm.swfield.feature)>0 then "N" else ENTRY (1, comm.swfield.feature)
                  comm.swbody.swfield = ENTRY (i, comm.swlist.flist)
                  comm.swbody.content = ''.
           CASE ENTRY (i, swlist.flist):
               when '20' then assign comm.swbody.content[1] = s-remtrz + "-S" comm.swbody.type=''.
               when '32' then do:
                   find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
                   tmpstr = string(txb.remtrz.payment, ">>>>>>>>>>>>9.99").
                   tmpstr = replace(tmpstr, ".", ",").
                   comm.swbody.content[1] = substr(string(year(txb.remtrz.valdt2)), 3, 2)  + "/" + string(month(txb.remtrz.valdt2),"99") + "/" +
                        string(day(txb.remtrz.valdt2), "99")  + " " + txb.crc.code + " " + tmpstr.
               end.
               when '50' then do:
                   run rus2eng(INPUT-OUTPUT txb.remtrz.ord).
                   tmpi = index(txb.remtrz.ord,"/RNN/").
                   if tmpi > 0 then
                      tmpRNN = substr(txb.remtrz.ord, tmpi , 17).
                   else
                      assign tmpRNN = "/RNN/".
                   tmpstr = replace(trim(txb.remtrz.ord),tmpRNN,"").
                   v-engcity = ''.
                   find first txb.cmp no-lock no-error.
                   if avail txb.cmp then do:
                      find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
                      if avail txb.sysc and num-entries(txb.sysc.chval,'|') > 7 then v-engcity = entry(8, txb.sysc.chval, "|").
                   end.
                   if trim(v-engcity) <> '' then
                      tmpstr3 = caps(v-engcity) + ' KAZAKHSTAN'.
                   else
                      tmpstr3 = "KAZAKHSTAN".
                   comm.swbody.content[1] = substr(tmpstr,  1,35).
                   comm.swbody.content[2] = substr(tmpstr, 36,35).
                   comm.swbody.content[3] = substr(tmpstr, 71,35).
                   comm.swbody.content[4] = substr(tmpstr,106,35).
                   if comm.swbody.content[2] = "" then do:
                      comm.swbody.content[2] = tmpRNN.
                      comm.swbody.content[3] = tmpstr3.
                   end. else do:
                      comm.swbody.content[3] = tmpRNN.
                      comm.swbody.content[4] = tmpstr3.
                   end.
                   comm.swbody.type=''.
               end.
               when '56' then if trim(v-docibcode2 + v-docibname2)  <> "" then
                         assign comm.swbody.type='D'
                                comm.swbody.content[1] = replace(v-docbbcode1 + v-docibcode2,"SWIFT","")
                                comm.swbody.content[2] = v-docibname2
                                comm.swbody.content[3] = ""
                                comm.swbody.content[4] = "".
               when '57' then if trim(v-docbbcode2 + v-docbbname2 + v-docbbname3 + v-docbbname4) <> "" then
                         assign comm.swbody.type='D'
                                comm.swbody.content[1] = replace(v-docbbcode1 + v-docbbcode2,"SWIFT","")
                                comm.swbody.content[2] = v-docbbname2
                                comm.swbody.content[3] = v-docbbname3
                                comm.swbody.content[4] = v-docbbname4.
               when '59' then if trim(v-docbenacc + v-docbenname2 + v-docbenname3 + v-docbenname4) <> "" then
                         assign comm.swbody.type=''
                                comm.swbody.content[1] = "/" + v-docbenacc
                                comm.swbody.content[2] = v-docbenname2
                                comm.swbody.content[3] = v-docbenname3
                                comm.swbody.content[4] = v-docbenname4.
                         else comm.swbody.type=''.
               when '70' then do:
                      t-beninfo = v-beninfo1.
                      v-beninfo1 = substr(t-beninfo,1,35) .
                      v-beninfo2 = substr(t-beninfo,36,35) .
                      v-beninfo3 = substr(t-beninfo,71,35) .
                      v-beninfo4 = substr(t-beninfo,106,35) .
                      assign
                         comm.swbody.type=''
                         comm.swbody.content[1] = v-beninfo1
                         comm.swbody.content[2] = v-beninfo2
                         comm.swbody.content[3] = v-beninfo3
                         comm.swbody.content[4] = v-beninfo4.
               end.
               when '71' then assign comm.swbody.type='A'
                                     comm.swbody.content[1] = if lookup(txb.remtrz.bi,"BEN,OUR") > 0 then txb.remtrz.bi else "OUR".
               when '72' then comm.swbody.type=''.
               when '23' then assign comm.swbody.type='B'
                                    comm.swbody.content[1] = "CRED".
           end case.
           if comm.swbody.type="N" then comm.swbody.content[1] = "NONE".

            run savelog("swiftmaket",  "snx1.p  1107 swbody.rmz         " + comm.swbody.rmz) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.swfield     " + comm.swbody.swfield) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.type        " + comm.swbody.type) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[1]  " + comm.swbody.content[1]) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[2]  " + comm.swbody.content[2]) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[3]  " + comm.swbody.content[3]) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[4]  " + comm.swbody.content[4]) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[5]  " + comm.swbody.content[5]) no-error.
            run savelog("swiftmaket",  "snx1.p       swbody.content[6]  " + comm.swbody.content[6]) no-error.

       end.
   */

   txb.remtrz.cover = 4.
end.

def var FnameError as char. /*Для вывода предупреждающего сообщения*/
FnameError = "". /*обнуляем предупреждающее сообщение*/
find last txb.cif where txb.cif.cif = v-doccif no-lock no-error. /*находим карточку клиента*/
if avail txb.cif then do: /*если карточка найдена*/
   if trim(txb.cif.fname) <> "" then /*прикреплен ли клиент к менеджеру*/
      FnameError = "ВНИМАНИЕ! Обслуживающий офицер не определен!".
   else
      FnameError = cif.fname.
   /* u00121 01.06.2005 найдем РКО в котором обслуживается клиент и определим общий адресс електронной почты РКО*/
   find last txb.ppoint where txb.ppoint.point = 1 and txb.ppoint.dep = (integer(txb.cif.jame) - 1000) no-lock no-error.
   if avail txb.ppoint then do:
      if txb.ppoint.mail <> "" then do:
         mailaddr  = txb.ppoint.mail.
      end.
   end.
end.




procedure toLogSWBody:
   run savelog("swiftmaket",  "snx1.p  swbody.rmz         " + comm.swbody.rmz) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.swfield     " + comm.swbody.swfield) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.type        " + comm.swbody.type) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[1]  " + comm.swbody.content[1]) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[2]  " + comm.swbody.content[2]) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[3]  " + comm.swbody.content[3]) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[4]  " + comm.swbody.content[4]) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[5]  " + comm.swbody.content[5]) no-error.
   run savelog("swiftmaket",  "snx1.p  swbody.content[6]  " + comm.swbody.content[6]) no-error.
end procedure.