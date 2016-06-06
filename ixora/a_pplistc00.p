/* a_pplistc00.p
 * MODULE
        Список длительных платежных поручений
 * DESCRIPTION

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
def  var v-control as logic  no-undo format "Есть/Нет" init no.
def  var v-contrname as char no-undo.
def var v-id     as int no-undo.
def var v-nom    as int no-undo.
def var v-dtnom  as date no-undo.
def var v-bank   as char no-undo.
def var v-rmz    as char no-undo.
def var v-jh     as int no-undo.

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


find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Нет параметра ourbnk sysc!" view-as alert-box.
    return.
end.
v-bank = sysc.chval.

display '   Ждите идет сбор данных ' with row 8 frame ww centered.
{r-branch.i &proc = "a_pplistf_txb"}
pause 0.

DEFINE QUERY q-list FOR pplist,t-ppout.

DEFINE BROWSE b-list QUERY q-list
       DISPLAY
       /*pplist.nom    label "Документ" format ">>>>>>9"
       pplist.dtnom  label "от" format "99/99/99"*/
       t-ppout.fil    label "Филиал" format "x(10)"
       pplist.aaa    label " Счет " format "x(20)"
       pplist.crc    label "Вл" format "z9"
       t-ppout.lname label " ФИО " format "x(15)"
       t-ppout.opl   label " Опл" format "x(4)"
       t-ppout.dt    label "опл" format "z9"
       pplist.sum    label "Сумма" format ">>>,>>9.99"
       pplist.dtout  label "Дата отпр" format "99/99/99"
       pplist.stat   label "СТАТУС" format "x(7)"
       pplist.delwho label " удал" format "x(7)"
      pplist.remtrz  label "RMZ" format "x(10)"

       with 29 down overlay width 110 no-label /*title " список платежных поручений "*/ no-box.

define frame f-list b-list help "<Enter>-Просмотр деталей" /*, <DEL>-удаление" */ with width 110 row 3 overlay no-box.

     Form
        skip(1)
        v-nom         label " Заявление   " format ">>>>>>>>9"
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
        v-kbe         label " Кбе        " format "X(3)"  skip
        v-ben         label " Бенефициар " format "X(60)" skip
        v-binb        label " БИН / ИИН бенефициара   " format "x(12)" skip
        v-bic         label " БИК банка бенефициара   " format "x(8)" skip
        v-bankb       label " Банк бенефициара        " format "X(60)" skip
        v-iikben      label " ИИК в банке бенефициара " format "X(20)" skip(1)
        v-rmz         label " RMZ документ            " format "X(10)" skip
        v-jh          label " Номер ранзакции         " format "zzzz99999" skip
    WITH  SIDE-LABELS  ROW 6 column 5 width 90 overlay FRAME f_main.


on "enter" of b-list in frame f-list do:
    clear frame f_main.
    v-id = pplist.id.
    find first t-ppout where t-ppout.txb = pplist.txb and t-ppout.id = v-id and t-ppout.del = no no-lock no-error.
    if not available t-ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-nom    = t-ppout.nom.
    v-dtnom  = t-ppout.dtnom.
    v-aaa    = pplist.aaa.
    v-crc    = pplist.crc.
    v-cif    = t-ppout.cif.
    /*v-status = t-ppout.stat.*/
    v-control = t-ppout.con.
    v-contrname = t-ppout.conwho.
    vopl     = t-ppout.vopl.
    v-opl    = t-ppout.opl.
    v-sum    = t-ppout.sum.
    v-dt     = t-ppout.dt.
    v-dtc    = t-ppout.dtc.
    v-rem    = t-ppout.rem[1].
    v-rem1   = t-ppout.rem[2].
    v-rem2   = t-ppout.rem[3].
    v-knp    = t-ppout.knp.
    v-kbe    = t-ppout.kbe.
    v-ben    = t-ppout.ben.
    v-binb   = t-ppout.binb.
    v-bic    = t-ppout.bic.
    v-bankb  = t-ppout.bankb.
    v-iikben = t-ppout.iikben.
    v-rmz    = pplist.remtrz.
    v-jh     = pplist.jh.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crccode  = crc.code.
    v-lname = t-ppout.lname.
    v-bin   = t-ppout.bin.
    displ v-nom v-dtnom v-aaa v-control v-contrname v-sum v-crc v-crccode v-lname
          v-bin v-opl v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben v-rmz v-jh with frame f_main.
    if vopl <> 1 then run viewgraf.
    hide frame f_main.
end.

/*on "DELETE-CHARACTER" of b-list in frame f-list do:
    if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
    then do:
        if pplist.stat = "Новый" then do:
            v-id  = pplist.id.
            v-aaa = pplist.aaa.
            find first pplist where pplist.txb = v-bank and pplist.id = v-id and pplist.aaa = v-aaa exclusive-lock no-error.
            pplist.del    = yes.
            pplist.delwho = g-ofc.
            pplist.deldt  = g-today.
            pplist.stat   = "Удален".
            browse b-list:refresh().
        end.
        else message "Удалять нельзя файл уже сформирован!" view-as alert-box.
    end.
end.*/

    open query q-list FOR EACH pplist no-lock, each t-ppout where t-ppout.txb = pplist.txb and t-ppout.id = pplist.id no-lock.
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
