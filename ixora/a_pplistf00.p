/* a_pplistf00.p
 * MODULE
 * DESCRIPTION
        Список длительных платежных поручений для ЦО
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

def var v-fil as char no-undo.
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

def new shared temp-table t-pplist no-undo
    field id      as int
    field txb     as char
    field fil     as char
    field cif     as char
    field name    as char
    field bin     as char
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

def new shared temp-table t-ppout no-undo
    field  id     as int
    field  txb    as char
    field  fil    as char
    field  nom    as int
    field  dtnom  as date
    field  aaa    as char
    field  cif    as char
    field  conwho as char
    field  vopl   as int
    field  opl    as char
    field  sum    as decim
    field  dt     as int
    field  dtc    as date
    field  rem    as char extent 3
    field  knp    as char
    field  kbe    as char
    field  ben    as char
    field  binb   as char
    field  bic    as char
    field  bankb  as char
    field  iikben as char
    field  crc    as int
    field  lname as char
    field  bin   as char
    field  con   as logic
    field  del   as logic.

display '   Ждите идет сбор данных ' with row 8 frame ww centered.
{r-branch.i &proc = "a_pplistf_txb"}

pause 0.
DEFINE QUERY q-list FOR t-pplist.

DEFINE BROWSE b-list QUERY q-list
       DISPLAY
       /*t-pplist.nom    label "Документ" format ">>>>>>>>9"
       t-pplist.dtnom  label "от" format "99/99/99"*/
       t-pplist.fil    label "Филиал" format "x(10)"
       t-pplist.aaa    label " Счет " format "x(20)"
       t-pplist.crc    label "Вл" format "z9"
       t-pplist.name   label " ФИО " format "x(20)"
       t-pplist.opl    label "Опл" format "x(4)"
       t-pplist.dtop   label "Д.опл" format "z9"
       t-pplist.dtcl   label "Дата закр." format "99/99/99"
       t-pplist.sum    label "Сумма" format ">,>>>,>>9.99"
       t-pplist.who    label "Исполн" format "x(7)"
       t-pplist.con    label "Контр" format "Есть/Нет"
       with 29 down overlay no-label title " Полный список платежных поручений ".

define frame f-list b-list help "<Enter>-Просмотр. <F2>-Фильтр"  with width 110 row 3 overlay no-box.

     Form
        skip(1)
        v-fil         label " Филиал     " format "x(20)" skip
        v-nom         label " Заявление  " format ">>>>>>>>9"
        v-dtnom       label " от "                         colon 30 format "99/99/9999" skip
        v-aaa         label " ИИК        " format "x(20)" skip
        v-control     label " Контроль   "
        v-contrname   label " Контролер  "              colon 35 format "x(35) " skip
        v-crc         LABEL " Валюта     " format ">9"
        v-crccode     no-label                         colon 15 format "x(3)" skip
        v-lname       LABEL " ФИО        " format "X(30)" skip
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
    find first t-ppout where t-ppout.txb = t-pplist.txb and t-ppout.id = t-pplist.id and t-ppout.del = no no-lock no-error.
    if not available t-ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-fil    = t-ppout.fil.
    v-nom    = t-ppout.nom.
    v-dtnom  = t-ppout.dtnom.
    v-aaa    = t-pplist.aaa.
    v-cif    = t-ppout.cif.
    v-control = t-ppout.con.
    v-contrname = t-ppout.conwho.
    v-opl    = t-ppout.opl.
    v-sum    = t-ppout.sum.
    v-dt     = t-ppout.dt.
    v-dtc    = t-ppout.dtc.
    v-rem    = t-ppout.rem[1].
    v-rem1    = t-ppout.rem[2].
    v-rem2    = t-ppout.rem[3].
    v-knp    = t-ppout.knp.
    v-kbe    = t-ppout.kbe.
    v-ben    = t-ppout.ben.
    v-binb   = t-ppout.binb.
    v-bic    = t-ppout.bic.
    v-bankb  = t-ppout.bankb.
    v-iikben = t-ppout.iikben.
    v-crc    = t-ppout.crc.
    vopl     = t-ppout.vopl.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crccode  = crc.code.
    v-lname = t-pplist.name.
    v-bin   = t-ppout.bin.
    displ v-fil v-nom v-dtnom v-aaa v-control v-contrname v-sum v-crc v-crccode v-lname v-bin v-opl v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben with frame f_main.
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
