/* elx_almtvin.p
 * MODULE
       Elecsnet
 * DESCRIPTION
        АлмаТВ - ввод платежа
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        elx_aall.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        22/05/2006 dpuchkov
 * CHANGES
        12.02.2007 id00004 добавил alias
*/

{get-dep.i}
{comm-txb.i}
{comm-com.i}
{rekv_pl.i}

def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

def input parameter g-today as date.
def input parameter newdoc as logical.
def input parameter rid as rowid.
def input parameter indoc as integer.
def var sm as decimal init 0.
def var cret as char init "".
def var sumt as dec.
def var sumtfk as dec.

def var v-whole-sum as decimal.
def var comchar  as char.
def var lcom as logical init false.
def var doccomsum  as decimal.
def var docallsum  as decimal.
def var doccomcode  as char.

def var v-vov-name as char init "".

def var v-tarif as decimal init 0.

find first tarif2 where tarif2.num = '5' and tarif2.kod = '83' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then do:
   v-tarif = tarif2.proc.
end.
if v-tarif = 0 then  do:
   message "Внимание: не настроены тарифы".
   return.
end.


def frame sfx
     "Номер и дата выдачи удостоверения участника ВОВ" skip
     "----------------------------------------------------"  skip
     v-vov-name  label "Участник ВОВ"  format "x(45)"
     with side-labels centered view-as dialog-box.

/*
def var course as dec.
find first crc where crc = 2 no-lock no-error.
course = rate[1].
*/

DEFINE BUTTON fnew LABEL "Ok".
DEFINE BUTTON fext LABEL "Выход".

/* dpuchkov проверка реквизитов см тз 907 */
/* убрать прошивку РНН найти РНН алматв в справочнике */
run rekvin("600900009200","","","").
if not l-ind then return.

def frame sf
    comm.almatv.ndoc label " Контракт" format ">>>>>>>9" skip
    comm.almatv.f label " Фамилия  " format "x(15)"  skip
    comm.almatv.io label " Имя отч. " format "x(15)" skip
    comm.almatv.address label " Адрес" format "x(15)" skip
    comm.almatv.house label " д. " format "x(5)"
    comm.almatv.flat label "кв." format "x(5)" skip(1)
    comm.almatv.accnt label " Счет N" format ">>>>>>>>9"
    comm.almatv.dt    label " от" skip
    comm.almatv.summ  label " Выставленная сумма тенге" format "->>>>>>>>9.99"
/*
    course label "             Курс" format "->>>>>>9.99" skip
    Sumt          label "                 в тенге" */

    skip(1)
    /*mobi-almatv.summ*/ docallsum    label " Сумма оплаты (тенге)" format "->>>>>>>>9.99" skip
    lcom        format ":/:"       label " Код комиссии "
     doccomsum        view-as text format ">>>,>>9.99"   label " Сумма комиссии"  skip
    v-whole-sum label " Сумма + комиссия (тенге)" format "->>>>>>>>9.99"

/*           sumtfk  label " Сумма фактической оплаты, в тенге" format "->>>>>>>>9.99" skip */

    "------------------------------------------------------------"
    skip
    space(20)
    fnew
    fext
    with side-labels centered view-as dialog-box.

/*  on help of lcom in frame sf do:
        run comtar("7","10,24").
        if return-value <> "" then
          doccomcode = return-value.
        if doccomcode = "24" then do:
          update
            v-vov-name
          with frame sfx.
          hide frame sfx.
          if trim(v-vov-name) = "" then do:
            message "Введите номер и дату выдачи документа" view-as alert-box title "Внимание".
            undo,retry.
          end.
        end.
        apply "value-changed" to almatv.summfk in frame sf.
    end. */


/*  on value-changed of almatv.summfk in frame sf do:
      almatv.summfk = decimal(almatv.summfk:screen-value).
      doccomsum = comm-com-1(almatv.summfk, doccomcode, "7", comchar).
      v-whole-sum = almatv.summfk + doccomsum.
      almatv.cursfk = doccomsum.
      displ
        doccomsum
        v-whole-sum
      with frame sf.
  end. */


ON CHOOSE OF fnew IN FRAME sf
    do:
       
        if newdoc then do:
           comm.almatv.dtfk = g-today.
           comm.almatv.uid = userid("bank").
           comm.almatv.cretime = time.
           comm.almatv.txb = ourcode.
           comm.almatv.deldate = ?.
           comm.almatv.deluid = ?.
           comm.almatv.deltime = ?.
           comm.almatv.delwhy = ?.
           comm.almatv.deldnum = ?.

        end.

        apply "endkey" to frame sf.
        cret = string(rowid(comm.almatv)).
    end.

ON CHOOSE OF fext IN FRAME sf
    do:
        apply "endkey" to frame sf.
    end.


/* Main Logic -----------------------------------------------------*/

    if newdoc then
    do:
        run almtvfind.
        if return-value="" then return.
        rid=to-rowid(return-value).
    end.



/*  find almatv where rowid(almatv) = rid. */
                                       
    find last mobi-almatv where rowid(mobi-almatv) = rid. no-lock no-error.
/*  find last almatv where almatv.ndoc =  indoc no-lock no-error. */
    find last comm.almatv where comm.almatv.ndoc = indoc use-index ndoc_dt_idx no-lock no-error.



/*        sumt = round(almatv.summ * course, 0). */
/*
    if newdoc then
    do:
      doccomcode = '10'.
      almatv.summfk = almatv.summ.
      doccomsum = comm-com-1(almatv.summfk, doccomcode, "7", comchar).
      almatv.cursfk = doccomsum.
    end. else do:
      doccomsum = almatv.cursfk.
    end.
*/
    docallsum =  mobi-almatv.summ - (round((mobi-almatv.summ * v-tarif / 100), 2)).
    doccomsum =  round((mobi-almatv.summ * v-tarif / 100), 2) .

    v-whole-sum = mobi-almatv.summ.  /*mobi-almatv.summ + doccomsum.*/

    display
        comm.almatv.ndoc
        comm.almatv.address
        comm.almatv.house
        comm.almatv.flat
        comm.almatv.f
        comm.almatv.io
        comm.almatv.dt
        comm.almatv.accnt
        comm.almatv.summ  
        docallsum
        doccomsum
        v-whole-sum
/*        mobi-almatv.summ */
        /* course
        sumt     */
    WITH side-labels FRAME sf.


/* if newdoc then ENABLE fnew WITH FRAME sf. */
ENABLE fnew WITH FRAME sf.
ENABLE fext WITH FRAME sf.
WAIT-FOR endkey OF frame sf.

hide frame sf.
return cret.
