/* almtvin.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
        АлмаТВ - ввод платежа
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12/04/04 kanat - добавил вывод установленных комиссий
        16/04/04 kanat - добавил выбор комиссии при приеме платежей
        23/04/04 kanat - поменял summfk на cursfk при проверке на ввод суммы комиссии.
        25/04/04 dpuchkov - добавил возможность контроля платежей от юр лиц в пользуюр лиц.
        07/06/04 kanat - добавил вывод обшей суммы с комиссией при вводе и просмотре платежа.
        23/06/04 kanat - сумма комиссии должна быть равна 0 - так как по договору с клиентов их не берем
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        09/02/2005 kanat - добавил выбор комисиий и убрал ручной ввод комиссий
        02/12/2005 marinav - выбор  только двух комиссий
        17/02/2006 u00568 Evgeniy - после исправления {comm-com.i} понадобилась переделка, чтобы правельно комиссию считала
         6/03/2006 Evgeniy (u00568) - сохраняет номер удостоверения участника ВОВ в almatv.chval[4]
         9/03/2006 Evgeniy (u00568) - сохраняет код комиссии almatv.chval[2]
        15/06/2006 Evgeniy (u00568) - запрет на отрицательные суммы
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
def var sm as decimal init 0.
def var cret as char init "".
def var sumt as dec.
def var sumtfk as dec.

def var v-whole-sum as decimal.
def var comchar  as char.
def var lcom as logical init false.
def var doccomsum  as decimal.
def var doccomcode  as char.

def var v-vov-name as char init "".

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
    almatv.ndoc label " Контракт" format ">>>>>>>9" skip
    almatv.f label " Фамилия  " format "x(15)"  skip
    almatv.io label " Имя отч. " format "x(15)" skip
    almatv.address label " Адрес" format "x(15)" skip
    almatv.house label " д. " format "x(5)"
    almatv.flat label "кв." format "x(5)" skip(1)
    almatv.accnt label " Счет N" format ">>>>>>>>9"
    almatv.dt    label " от" skip
    almatv.summ  label " Выставленная сумма тенге" format "->>>>>>>>9.99"
/*
    course label "             Курс" format "->>>>>>9.99" skip
    Sumt          label "                 в тенге" */

    skip(1)
    almatv.summfk  label " Сумма оплаты (тенге)" format "->>>>>>>>9.99" validate (almatv.summfk > 0 , 'Не принимаем отрицательные суммы платежей.') skip
    lcom        format ":/:"       label " Код комиссии "
    doccomsum       view-as text format ">>>,>>9.99"   label " Сумма комиссии"  skip
    v-whole-sum label " Сумма + комиссия (тенге)" format "->>>>>>>>9.99"

/*           sumtfk  label " Сумма фактической оплаты, в тенге" format "->>>>>>>>9.99" skip*/

    "------------------------------------------------------------"
    skip
    space(20)
    fnew
    fext
    with side-labels centered view-as dialog-box.

    on help of lcom in frame sf do:
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
    end.


  on value-changed of almatv.summfk in frame sf do:
      almatv.summfk = decimal(almatv.summfk:screen-value).
      if almatv.summfk < 0 then almatv.summfk = - almatv.summfk.
      doccomsum = comm-com-1(almatv.summfk, doccomcode, "7", comchar).
      v-whole-sum = almatv.summfk + doccomsum.
      almatv.cursfk = doccomsum.
      displ
        almatv.summfk
        doccomsum
        v-whole-sum
      with frame sf.
  end.


ON CHOOSE OF fnew IN FRAME sf
    do:
       
        if newdoc then do:
           almatv.dtfk = g-today.
           almatv.uid = userid("bank").
           almatv.cretime = time.
           almatv.txb = ourcode.
           almatv.deldate = ?.
           almatv.deluid = ?.
           almatv.deltime = ?.
           almatv.delwhy = ?.
           almatv.deldnum = ?.

        end.

        apply "endkey" to frame sf.
        cret = string(rowid(almatv)).
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



    find almatv where rowid(almatv) = rid.

/*        sumt = round(almatv.summ * course, 0).*/

    if newdoc then
    do:
      doccomcode = '10'.
      almatv.summfk = almatv.summ.
      doccomsum = comm-com-1(almatv.summfk, doccomcode, "7", comchar).
      almatv.cursfk = doccomsum.
    end. else do:
      doccomsum = almatv.cursfk.
    end.
    v-whole-sum = almatv.summfk + doccomsum.

    display
        almatv.ndoc
        almatv.address
        almatv.house
        almatv.flat
        almatv.f
        almatv.io
        almatv.dt
        almatv.accnt
        almatv.summ
        doccomsum
        v-whole-sum
        almatv.summfk
        /* course
        sumt     */
    WITH side-labels FRAME sf.

    if newdoc then do:
       /* kanat - теперь в cursfk пишется комиссия */
       /* almatv.cursfk = 1. */
       /* sumtfk = round(almatv.summfk * course, 0).*/
       update
         almatv.summfk   validate( almatv.summfk > 0, " Сумма должна быть больше нуля !")
         lcom
         /*sumtfk          */
       WITH side-labels FRAME sf.
       v-whole-sum = almatv.summfk + doccomsum.
       displ
         doccomsum
         v-whole-sum
       with frame sf.
       almatv.chval[2] = doccomcode.
       if doccomcode = '24' then
         almatv.chval[4] = v-vov-name.
            /* editing:
                READKEY.
                APPLY LASTKEY.
                IF FRAME-FIELD = "Summfk" THEN do:
                    sumtfk = round(deci(almatv.summfk:screen-value) * course, 0).
                    display sumtfk with frame sf.
                end.
                else IF FRAME-FIELD = "sumtfk" THEN do:
                    almatv.summfk = round(deci(sumtfk:screen-value) / course, 2).
                    display almatv.summfk with frame sf.
                end.
            end.*/
    end. else do:
             /*
             if almatv.state = 0 then do:
                update almatv.summfk validate( almatv.summfk > 0, " Сумма должна быть больше нуля !")
                       WITH side-labels FRAME sf.
                almatv.euid = userid ("bank").
                almatv.edate = today.
                almatv.etim = time.
             end.
             else */
    end.

/* if newdoc then ENABLE fnew WITH FRAME sf. */
ENABLE fnew WITH FRAME sf.
ENABLE fext WITH FRAME sf.
WAIT-FOR endkey OF frame sf.

hide frame sf.
return cret.
