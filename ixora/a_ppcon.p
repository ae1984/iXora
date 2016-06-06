/* a_ppcon.p
 * MODULE

 * DESCRIPTION
        Контроль длительных платежных поручений

 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        16/07/2013 Luiza ТЗ № 1738
 * CHANGES

*/


{mainhead.i}
{yes-no.i}

def var v-cif as char no-undo.
def var v_title as char no-undo. /*наименование */
v_title = "Платежное поручение – внешнее ".
def  var vj-label  as char no-undo.
def  var v-status  as char no-undo.
def  var v-aaa     as char no-undo.
def  var v-crc     as int no-undo.
def  var vopl      as int no-undo.
def  var v-name   as char no-undo.
def  var v-lname   as char no-undo.
def  var v-fname   as char no-undo.
def  var v-mname   as char no-undo.
def  var v-bin     as char no-undo.
def  var v-opl     as char no-undo.
def  var v-sum     as decim no-undo.
def  var v-dt      as int no-undo.
def  var v-dtc     as date no-undo.
def  var v-rem     as char no-undo.
def  var v-rem1     as char no-undo.
def  var v-rem2     as char no-undo.
def  var v-knp     as char no-undo.
def  var v-kbe     as char no-undo.
def  var v-ben     as char no-undo.
def  var v-binb    as char no-undo.
def  var v-bic     as char no-undo.
def  var v-bankb   as char no-undo.
def  var v-iikben  as char no-undo.
def  var v-crccode as char no-undo.
def var v-ja as logic  no-undo format "Да/Нет" init yes.
def var v-control as logic  no-undo format "Есть/Нет" init no.
def  var v-contrname as char no-undo.
def var phand    as handle no-undo.
def var v-id    as int no-undo.
def var v-nom    as int no-undo.
def var v-dtnom  as date no-undo.
def  var v-reason as char no-undo.

define button b1 label "КОНТРОЛЬ".
define button b5 label "ВЫХОД".

def temp-table tmpsts
    field reason as char.
    create tmpsts. tmpsts.reason = "Ошибка менеджера".
    create tmpsts. tmpsts.reason = "По инициативе клиента".
    create tmpsts. tmpsts.reason = "Техническая причина".

{chk12_innbin.i}

define frame a2
    b1 b5
    with side-labels row 4 column 5 no-box.


     Form
        skip(1)
        v-nom         label " Заявление  " format ">>>>>>>>9"
        v-dtnom       label " от "                         colon 43 format "99/99/9999" skip
        v-aaa         label " ИИК        " format "x(20)" skip
        v-control     label " Контроль   "
        v-contrname   label " Контролер  "              colon 35 format "x(35) " skip
        v-crc         LABEL " Валюта     " format ">9"
        v-crccode     no-label                         colon 15 format "x(3)" skip
        v-lname       LABEL " Фамилия    " format "X(20)" skip
        v-fname       LABEL " Имя        " format "X(20)" skip
        v-mname       LABEL " Отчество   " format "X(20)" skip
        v-bin         LABEL " ИИН        " format "x(12)" skip
        v-opl         LABEL " Вид оплаты " format "x(10)" skip
        v-sum         LABEL " Сумма      " format ">>>,>>>,>>>,>>9.99" skip
        v-dt          label " День формир. плат поруч " format ">9"  skip
        v-dtc         label " Срок       " format "99/99/9999" skip
        v-rem         label " Назначение " format "X(60)" skip
        v-rem1        label "            " format "X(60)" skip
        v-rem2        label "            " format "X(60)" skip
        v-knp         label " КНП        " format "X(3)"  skip (1)
        v-kbe         label " Кбе        " format "X(2)"  skip
        v-ben         label " Бенефициар " format "X(60)" skip
        v-binb        label " БИН / ИИН бенефициара   " format "x(12)" skip
        v-bic         label " БИК банка бенефициара   " format "x(8)" skip
        v-bankb       label " Банк бенефициара        " format "X(60)" skip
        v-iikben      label " ИИК в банке бенефициара " format "X(20)" skip(1)
        vj-label no-label format "x(38)" v-ja no-label
    WITH  SIDE-LABELS  ROW 6 column 3 TITLE v_title width 90 FRAME f_main.

DEFINE QUERY q-aaa FOR ppout,cif .

DEFINE BROWSE b-aaa QUERY q-aaa
       DISPLAY ppout.aaa label "ИИК                  " format "x(20)" cif.name label "ФИО " format "x(40)" ppout.stat label "Статус" format "x(6)"
       WITH  15 DOWN.
DEFINE FRAME f-aaa b-aaa  WITH overlay 1 COLUMN SIDE-LABELS row 6 COLUMN 5 width 85 NO-BOX.

DEFINE QUERY q-tmp FOR tmpsts .

DEFINE BROWSE b-tmp QUERY q-tmp
       DISPLAY tmpsts.reason label "Выберите причину    " format "x(20)"
       WITH  3 DOWN.
DEFINE FRAME f-tmp b-tmp  WITH overlay 1 COLUMN SIDE-LABELS row 15 COLUMN 35 width 30 NO-BOX.


    find first ppout where ppout.con = no or (ppout.del and ppout.delcon = no) no-lock no-error.
    if not available ppout then do:
        message "Нет поручений для контроля!" view-as alert-box.
        return.
    end.
    clear frame f_main.
    v-aaa    = "".
    vj-label = " Контролировать?........................." .
    OPEN QUERY  q-aaa FOR EACH ppout where ppout.con = no or (ppout.del and ppout.delcon = no) no-lock, each cif where cif.cif = ppout.cif no-lock.
    ENABLE ALL WITH FRAME f-aaa.
    wait-for return of frame f-aaa
    FOCUS b-aaa IN FRAME f-aaa.
    v-id      = ppout.id.
    v-aaa     = ppout.aaa.
    v-cif     = ppout.cif.
    v-control = ppout.con.
    find first ofc where ofc.ofc = ppout.conwho no-lock no-error.
    if available ofc then v-contrname = ofc.name.
    vopl     = ppout.opl.
    v-opl    = ppout.vopl.
    v-sum    = ppout.sum.
    v-dt     = ppout.dtop.
    v-dtc    = ppout.dtcl.
    v-rem    = ppout.remark[1].
    v-rem1   = ppout.remark[2].
    v-rem2   = ppout.remark[3].
    v-knp    = ppout.knp.
    v-kbe    = ppout.kbe.
    v-ben    = ppout.benname.
    v-binb   = ppout.binben.
    v-bic    = ppout.bic.
    v-bankb  = ppout.bankben.
    v-iikben = ppout.iikben.
    vopl     = ppout.opl.
    v-opl    = ppout.vopl.
    v-nom    = ppout.nom.
    v-dtnom  = ppout.dtnom.
    v-crc    = ppout.crc.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crccode  = crc.code.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crccode  = crc.code.
    find first cif where cif.cif = v-cif no-lock no-error.
    if not available cif then do:
        message "Клиент не найден!." view-as alert-box.
        undo,return.
    end.
    v-lname = entry(1,cif.name," ").
    if NUM-ENTRIES(cif.name," ") > 1 then v-fname = entry(2,cif.name," ").
    if NUM-ENTRIES(cif.name," ") > 2 then v-mname = entry(3,cif.name," ").
    v-bin = cif.bin.
    hide frame f-aaa.
    displ v-nom v-dtnom v-aaa v-control v-contrname  v-crc v-crccode v-lname v-fname v-mname v-bin v-opl v-sum v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben vj-label with frame f_main.
    pause 0.
    if vopl <> 1 then run viewgraf.
    v-ja = no.
    update v-ja  with frame f_main.
    if v-ja then do:
        v-reason = "".
        if ppout.del and ppout.delcon = no then do:
            OPEN QUERY  q-tmp FOR EACH tmpsts no-lock.
            ENABLE ALL WITH FRAME f-tmp.
            wait-for return of frame f-tmp
            FOCUS b-tmp IN FRAME f-tmp.
            v-reason = tmpsts.reason.
            hide frame f-tmp.
        end.
        if g-ofc = ppout.who then do:
            message "Нельзя контролировать свои документы!" view-as alert-box.
            undo,return.
        end.
        find first ppout where ppout.id = v-id exclusive-lock no-error.
        if not available ppout then do:
            message "Запись не найдена!" view-as alert-box.
            undo,return.
        end.
        v-control = ppout.con.
        if ppout.del and ppout.delcon = no then do:
            ppout.reason    = v-reason.
            ppout.delcon    = yes.
            ppout.delconwho = g-ofc.
            ppout.delcondt  = g-today.
        end.
        else do:
            ppout.con       = yes.
            ppout.conwho    = g-ofc.
            ppout.condt      = g-today.
        end.
        find first ofc where ofc.ofc = ppout.conwho no-lock no-error.
        if available ofc then v-contrname = ofc.name.
        displ v-control v-contrname with frame f_main.
        if ppout.del and ppout.delcon = no then message "Запись на удаление отконтролирована!" view-as alert-box.
        else message "Запись отконтролирована!" view-as alert-box.
    end.




procedure viewgraf:

    DEFINE QUERY q-graf FOR ppgraf.

    DEFINE BROWSE b-graf QUERY q-graf
           DISPLAY
           ppgraf.dat label " Дата " format "99/99/9999"
           ppgraf.sum label " Сумма " format ">>>,>>>,>>>,>>9.99"
           WITH  19 DOWN overlay no-label title " График ".
    DEFINE FRAME f-graf b-graf  WITH overlay 1 COLUMN row 7 COLUMN 65 width 40 no-box.

        OPEN QUERY  q-graf FOR EACH ppgraf where ppgraf.aaa = v-aaa and ppgraf.del = no no-lock.
        ENABLE ALL WITH FRAME f-graf.
        wait-for return of frame f-graf
        FOCUS b-graf IN FRAME f-graf.
end procedure.
