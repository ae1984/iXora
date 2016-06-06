/* a_pplistf.p
 * MODULE
 * DESCRIPTION
        Полный список длительных платежных поручений
 * BASES
        BANK
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
def var v-control as logic  no-undo format "Есть/Нет" init no.
def  var v-contrname as char no-undo.
def var v-id    as int no-undo.
def var v-nom    as int no-undo.
def var v-dtnom  as date no-undo.

def temp-table t-pplist no-undo
    field id      as int
    field cif     as char
    field name    as char
    field aaa     as char
    field crc     as int
    field dtop    as int
    field crccode     as char
    field sum     as decim
    field opl     as char
    field who     as char
    field nom     as int
    field dtnom   as date
    field dtcl    as date
    field con     as logic.

for each ppout where ppout.del = no no-lock.
    create t-pplist.
       t-pplist.id        = ppout.id.
       t-pplist.aaa       = ppout.aaa.
       t-pplist.crc       = ppout.crc.
       t-pplist.cif       = ppout.cif.
       find first cif where cif.cif = ppout.cif no-lock no-error.
       if available cif then t-pplist.name      = cif.sname.
       t-pplist.sum       = ppout.sum.
       find first crc where crc.crc = ppout.crc no-lock no-error.
       if available crc then t-pplist.crccode = crc.code.
       t-pplist.opl       = ppout.vopl.
       t-pplist.who       = ppout.who.
       t-pplist.con       = ppout.con.
       t-pplist.nom       = ppout.nom.
       t-pplist.dtnom     = ppout.dtnom.
       t-pplist.dtop      = ppout.dtop.
       t-pplist.dtcl      = ppout.dtcl.
end.

DEFINE QUERY q-list FOR t-pplist.

DEFINE BROWSE b-list QUERY q-list
       DISPLAY
       t-pplist.nom    label "Докум" format ">>>>9"
       t-pplist.dtnom  label "от" format "99/99/99"
       t-pplist.aaa    label " Счет " format "x(20)"
       t-pplist.crc    label "Вл" format "z9"
       t-pplist.name   label " ФИО " format "x(20)"
       t-pplist.opl    label "Опл" format "x(4)"
       t-pplist.dtop   label "Д.отп" format "z9"
       t-pplist.dtcl   label "Д.закр" format "99/99/99"
       t-pplist.sum    label "Сумма" format ">>>,>>9.99"
       t-pplist.who    label "Исполн" format "x(7)"
       t-pplist.con    label "Контр" format "Есть/Нет"
       with 29 down overlay no-label title " Полный список платежных поручений ".

define frame f-list b-list help "<Enter>-Просмотр. <F2>-Фильтр"  with width 110 row 3 overlay no-box.

     Form
        skip(1)
        v-nom         label " Заявление  " format ">>>>>>>>9"
        v-dtnom       label " от "                         colon 30 format "99/99/9999" skip
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
        v-dt          label " День формиров-я плат поруч " format ">9"  skip
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
    WITH  SIDE-LABELS  ROW 6 column 5 width 90 overlay FRAME f_main.


on "enter" of b-list in frame f-list do:
    clear frame f_main.
    v-id = t-pplist.id.
    find first ppout where ppout.id = v-id and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-nom    = ppout.nom.
    v-dtnom  = ppout.dtnom.
    v-aaa    = t-pplist.aaa.
    v-cif    = ppout.cif.
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
    v-crc    = ppout.crc.
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
    displ v-nom v-dtnom v-aaa v-control v-contrname v-sum v-crc v-crccode v-lname v-fname v-mname v-bin v-opl v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben with frame f_main.
    if vopl <> 1 then run viewgraf.
    hide frame f_main.
end.
    open query q-list FOR EACH t-pplist no-lock .
    enable all with frame f-list.

    wait-for window-close of current-window.

procedure viewgraf:

    DEFINE QUERY q-graf FOR ppgraf.

    DEFINE BROWSE b-graf QUERY q-graf
           DISPLAY
           ppgraf.dat label " Дата " format "99/99/9999"
           ppgraf.sum label " Сумма " format ">>>,>>>,>>>,>>9.99"
           WITH  20 DOWN overlay no-label title " График ".
    DEFINE FRAME f-graf b-graf  WITH overlay 3 COLUMN row 7 COLUMN 65 width 40 no-box.

        OPEN QUERY  q-graf FOR EACH ppgraf where ppgraf.id = v-id and ppgraf.del = no no-lock.
        ENABLE ALL WITH FRAME f-graf.
        wait-for return of frame f-graf
        FOCUS b-graf IN FRAME f-graf.
        hide frame f-graf.
end procedure.
