/* csavans1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        07.12.2011 Luiza
 * BASES
        BANK COMM
 * CHANGES
        09/02/2012 Luiza - изменила проставление кода кассплана
        20/06/2012 Luiza - заменила слово ТЕМПО-КАССА на МИНИКАССУ
        20/08/2012 Luiza - заменила слово темпокасса на миникассу
        04/09/2012 Luiza - кассплан при принятия наличности 300
*/

{classes.i}
{cm18_abs.i}

define input parameter new_document as logical.
define variable m_sub           as character initial "jou".
def shared var v_u as int no-undo.
def shared var v-select as integer no-undo.
def shared var v-selch as integer no-undo.

def var v-deb as char init "". /*like gl.gl no-undo.*/
def var v-cre as char init "". /*like gl.gl no-undo.*/
def var v-arp like arp.arp no-undo.
def var v-arp100200 like arp.arp no-undo.
def /*shared*/ var v-dep as char no-undo.
def /*shared*/ var v-depname as char no-undo.

def var v-nomer like cslist.nomer no-undo.
def var v-ofc as char no-undo.
def var v-tmpl as char no-undo.
def new shared var v-joudoc as char format "x(10)" no-undo.

def var rez as logi no-undo.
def var rez2 as logi no-undo.
def var rez4 as logi no-undo.

def var v-sum as deci no-undo.
def var v-sumreal as deci no-undo.

def var v-sumarp as deci no-undo.
def var v-crc like crc.crc.
def var v-crc_val as char no-undo format "xxx" init "KZT".
def var v-kod as char no-undo init "14".
def var v-kbe as char no-undo init "14".
def var v-knp as char no-undo init "890".
def var v-rem as char  no-undo .
define variable sumstr as character.
def var v-id as char no-undo.
def var v-dispensedAmt as deci no-undo.
def var v-acceptedAmt as deci no-undo.
def var v-auxOut as char no-undo.
def var v-ja as logi no-undo /*format "Да/Нет" */ init yes.

def new shared var s-jh like jh.jh.
def var v-glrem as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var v_doc as char.

def var v_trx as int no-undo.
def  var vj-label as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
define variable quest as logical format "yes/no" no-undo.
define variable v-sts like jh.sts  no-undo.
def var ans as log format "yes/no".

define button but label " "  NO-FOCUS.
{keyord.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
s-ourbank = trim(sysc.chval).

def temp-table wrk no-undo
  field ofc as char
  field fio as char
  field nomer as char
  index idx is primary ofc.



if v-select = 1 then v-rem = "Выдача наличности в миникассу ". else v-rem = "Принятие наличности из миникассы ".
if v-select = 1 then v_title = "Выдача наличности в миникассу ". else v_title = "Принятие наличности из миникассы ".

form
    v-joudoc label " Документ        " format "x(10)"  v_trx label "  ТРН " format "zzzzzzzzz"    but  skip
    v-depname label " ЦОК             " format "x(30)"  skip
    v-nomer  label " Номер ЭК        " validate(can-find(cslist where cslist.nomer = v-nomer and cslist.bank = s-ourbank no-lock), " ЭК не вашего филиала! ") skip
    v-ofc    label " Менеджер        " validate(can-find(wrk where wrk.ofc = v-ofc no-lock), " Выберите менеджера! F2 - помощь.") skip
    v-crc    label " Валюта          " validate(v-crc <> 0, " Неверный код валюты! F2 - помощь.") help "F2 - справочник" v-crc_val no-label skip
    v-arp    label " Дебет   100500  " skip
    v-sumarp label " Текущий остаток " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-sum    label " Сумма           " /*validate(v-sum <= v-sumarp and v-select = 2, "Сумма превышает текущий остаток")*/ format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-rem    label " Примечание      " format "x(60)" skip
    v-knp    label " КНП             " format "x(3)" skip(1)
                   "           ДАННЫЕ ПРОВОДКИ  "  skip
    v-deb    label " Дебет Г/К       " format "x(35)" skip
    v-cre    label " Кредит Г/К      " format "x(35)" skip(1)
    vj-label no-label v-ja no-label
WITH  SIDE-LABELS CENTERED ROW 7 TITLE v_title width 100 FRAME f_main.

DEFINE QUERY q-sp FOR ppoint.
DEFINE BROWSE b-sp QUERY q-sp
       DISPLAY ppoint.dep label "Номер  " format "99" ppoint.name label "Наименование   " format "x(40)"
       WITH  15 DOWN.
DEFINE FRAME f-sp b-sp  WITH   column 20 row 10 TITLE "ВЫБЕРИТЕ СП" width 60 .


DEFINE QUERY q-nomer FOR cslist.

DEFINE BROWSE b-nomer QUERY q-nomer
       DISPLAY cslist.nomer label "Номер  " format "x(7)" cslist.des label "Наименование   " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-nomer b-nomer  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 60 NO-BOX.

  on help of v-nomer in frame f_main do:
        OPEN QUERY  q-nomer FOR EACH cslist where cslist.bank = s-ourbank no-lock.
        ENABLE ALL WITH FRAME f-nomer.
        wait-for return of frame f-nomer
        FOCUS b-nomer IN FRAME f-nomer.
        v-nomer = cslist.nomer.
        hide frame f-nomer.
    displ v-nomer with frame f_main.
  end.

on help of v-crc in frame f_main do:
    run help-crc1.
end.
on help of v-ofc in frame f_main do:
    find first wrk no-lock no-error.
    if not avail wrk then message skip " Нет менеджеров, привязанных к этому ЭК! " skip(1) view-as alert-box error.

    {itemlist.i
       &file = "wrk"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " wrk.ofc label 'ID' format 'x(7)'
                    wrk.fio label 'ФИО' format 'x(50)'
                  "
       &chkey = "ofc"
       &chtype = "string"
       &index  = "idx"
    }
    v-ofc = wrk.ofc.
    displ v-ofc with frame f_main.
end.

on help of v-joudoc in frame f_main do:
    if v-select = 1 then run a_help-joudoc1("VTK2"). else run a_help-joudoc1("PTK2").
    v-joudoc = frame-value.
end.
/*обработка F4*/
on choose of but in frame  f_main do:
end.
on "END-ERROR" of but in frame f_main do:
    undo, return.
end.
on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.
on "END-ERROR" of frame f-nomer do:
  hide frame f-nomer no-pause.
end.

if new_document then do:  /* создание нового документа  */
    clear frame f_main.
    vj-label  = " Сохранить новый документ?...........".
    find nmbr where nmbr.code eq "JOU" no-lock no-error.
    v-joudoc = "JOU" + string (next-value (journal), "999999") + nmbr.prefix.
    find first nmbr no-lock no-error.
    do transaction:
        displ v-joudoc format "x(10)" with frame f_main.
        v-sum = 0.
        v-ja = yes.
        v-crc = 0.


        run save_doc.
    end.  /* end transaction    */
end.  /* end new document */

else do:   /* редактирование документа   */
    run view_doc.
    if v_u = 2 then do:       /* update */
        do transaction:
            vj-label  = " Сохранить изменения документа?...........".
            run view_doc.
            find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
            if available joudoc then do:

                find joudop where joudop.docnum = v-joudoc no-lock no-error.
                if available joudop then do:
                    if v-select = 1 then do:
                        if  joudop.type <> "VTK2" then do:
                            message substitute ("Документ не относится к типу выдача наличности в миникассу(счет 100200)") view-as alert-box.
                            return.
                        end.
                    end.
                    if v-select = 2 then do:
                        if joudop.type <> "PTK2" then do:
                            message substitute ("Документ не относится к типу принятие наличности из миникассы(счет 100200)") view-as alert-box.
                            return.
                        end.
                    end.
                end.
                if joudoc.jh > 1 then do:
                    message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
                    return.
                end.
                if joudoc.who ne g-ofc then do:
                    message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
                    return.
                end.
            end.
            run save_doc.
        end.
    end.   /* end  v_u = 2 */
end.  /*else do: */

procedure save_doc:
    v-dep = "".
    v-depname = "".
    pause 0.

    if Base:dep-id = 1 then v-dep = '514'.
    else v-dep = "A" + string(Base:dep-id,'99').
    v-depname = Base:b-addr.

   /* message s-ourbank string(Base:dep-id) view-as alert-box.*/

    empty temp-table wrk.
    for each comm.cslist where comm.cslist.bank = s-ourbank and comm.cslist.info[1] = string(Base:dep-id) no-lock, each comm.csofc where comm.csofc.nomer = comm.cslist.nomer no-lock:
     create wrk.
      wrk.ofc = comm.csofc.ofc.
      wrk.nomer = comm.csofc.nomer.
      find first ofc where ofc.ofc = comm.csofc.ofc no-lock no-error.
      if avail ofc then wrk.fio = trim(ofc.name).
    end.

            displ v-nomer v-depname v-ofc v-crc v-sum v-rem v-knp vj-label with frame f_main.
            v-ofc = ''.
            update v-ofc with frame f_main.
            find first wrk where wrk.ofc = v-ofc no-lock.
            if v-select = 1 then v-rem = "Выдача наличн. в миникассу(" + wrk.fio + ")".
            else v-rem = "Принятие наличн. из миникассы(" + wrk.fio + ")".
            v-nomer = wrk.nomer.
            displ v-nomer v-rem with frame f_main.
            update v-crc with frame f_main.

            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crc_val = crc.code.
            displ v-crc_val with frame f_main.

            v-arp = ''.
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-arp = arp.arp.
                    v-sumarp = arp.dam[1] - arp.cam[1].
                end.
            end.
            if v-arp = '' then do:
                message "Не настроен счет ЭК " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                return.
            end.
            for each arp where arp.gl = 100200 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "obmen1002" no-lock no-error.
                if avail sub-cod then do:
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode = v-dep no-lock no-error.
                    if avail sub-cod then do:
                        v-arp100200 = arp.arp.
                    end.
                end.
            end.
            if v-arp100200 = "" then do:
              message "Не настроен арп счет 100200 в валюте " v-crc_val " !" view-as alert-box title " ОШИБКА ! ".
              undo.
            end.


          /*  if v-select = 2 and v-crc = 1 then run cstiyn(v-ofc).*/

            if v-select = 1 then do:
              v-deb = "100500   АРП " + v-arp.
              v-cre = "100200   АРП " + v-arp100200.
            end.
            else do:
              v-cre = "100500   АРП " + v-arp.
              v-deb = "100200   АРП " + v-arp100200.
              v-sum = 0.
              v-sumreal = GetCashOfc(v-crc_val,v-ofc,g-today).
              if (v-sumreal - integer(v-sumreal)) > 0 then v-sum = integer(v-sumreal).
              if (v-sumreal - integer(v-sumreal)) < 0 then v-sum = integer(v-sumreal) - 1.
              if (v-sumreal - integer(v-sumreal)) = 0 then v-sum =  v-sumreal.

            end.

            displ v-arp v-sumarp v-deb v-cre with frame f_main.

            update v-sum with frame f_main.



            if v-select = 2 then do:
             if  v-sum > v-sumreal then do: message "Сумма больше доступной!" view-as alert-box. undo. end.
             if (v-sum - integer(v-sum)) <> 0 then do: message "Сумма не может содержать дробное значение!" view-as alert-box. undo. end.

             if (v-sumreal - integer(v-sumreal)) > 0 then v-sumreal = integer(v-sumreal).
             if (v-sumreal - integer(v-sumreal)) < 0 then v-sumreal = integer(v-sumreal) - 1.
            /* else v-sumreal = integer(v-sumreal) - 1.*/

             if v-sum = v-sumreal then do:
               v-sumreal = GetCashOfc(v-crc_val,v-ofc,g-today).
               if (v-sumreal - integer(v-sumreal)) <> 0 then do:
                 message "Учет разницы в тиынах не сделан!" view-as alert-box.
                 undo.
               end.
             end.
            end.

            update v-rem v-ja with frame f_main.
            if keyfunction (lastkey) = "end-error" then undo.
/*
    case v-select:
        when 1 then do:
            displ v-nomer v-depname v-ofc v-crc v-sum v-rem v-knp vj-label with frame f_main.
            v-ofc = ''.
            update v-ofc with frame f_main.
            find first wrk where wrk.ofc = v-ofc no-lock.
            v-rem = "Выдача наличн. в миникассу(" + wrk.fio + ")".
            v-nomer = wrk.nomer.
            displ v-nomer v-rem with frame f_main.
            update v-crc with frame f_main.

            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crc_val = crc.code.
            displ v-crc_val v-rem with frame f_main.

            v-arp = ''.
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-arp = arp.arp.
                    v-sumarp = arp.dam[1] - arp.cam[1].
                end.
            end.
            if v-arp = '' then do:
                message "Не настроен счет ЭК " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                return.
            end.
            for each arp where arp.gl = 100200 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "obmen1002" no-lock no-error.
                if avail sub-cod then do:
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode = v-dep no-lock no-error.
                    if avail sub-cod then do:
                        v-arp100200 = arp.arp.
                    end.
                end.
            end.
            if v-arp100200 = "" then do:
              message "Не настроен арп счет 100200 в валюте " v-crc_val " !" view-as alert-box title " ОШИБКА ! ".
              undo.
            end.
            v-deb = "100500   АРП " + v-arp.
            v-cre = "100200   АРП " + v-arp100200.

            displ v-arp v-sumarp v-deb v-cre with frame f_main.
            update v-sum v-rem v-ja with frame f_main.
            if keyfunction (lastkey) = "end-error" then undo.
        end.
        when 2 then do:
            displ v-nomer v-depname v-ofc v-crc v-rem v-knp vj-label with frame f_main.
            update v-nomer with frame f_main.
            empty temp-table wrk.
            for each csofc where csofc.nomer = v-nomer no-lock:
                if csofc.ofc = g-ofc then next.
                create wrk.
                wrk.ofc = csofc.ofc.
                find first ofc where ofc.ofc = csofc.ofc no-lock no-error.
                if avail ofc then wrk.fio = trim(ofc.name).
            end.

            v-ofc = ''.
            update v-ofc v-crc with frame f_main.
            find first wrk where wrk.ofc = v-ofc no-lock.
            v-rem = "Принятие наличн. из миникассы(" + wrk.fio + ")".

            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crc_val = crc.code.
            displ v-crc_val v-rem with frame f_main.
            v-arp = ''.
            for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then do:
                    v-arp = arp.arp.
                    v-sumarp = arp.dam[1] - arp.cam[1].
                end.
            end.
            if v-arp = '' then do:
                message "Не настроен счет ЭК " + v-nomer + " в валюте " + v-crc_val + " !" view-as alert-box title " ОШИБКА ! ".
                return.
            end.

            for each arp where arp.gl = 100200 and arp.crc = v-crc no-lock.
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = "obmen1002" no-lock no-error.
                if avail sub-cod then do:
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode = v-dep no-lock no-error.
                    if avail sub-cod then v-arp100200 = arp.arp.
                end.
            end.
            if v-arp100200 = "" then do:
              message "Не настроен арп счет 100200 в валюте " v-crc_val " !" view-as alert-box title " ОШИБКА ! ".
              undo.
            end.
            v-cre = "100500   АРП " + v-arp.
            v-deb = "100200   АРП " + v-arp100200.
            displ v-arp v-sumarp v-deb v-cre with frame f_main.
            update  v-sum v-rem v-ja with frame f_main.
            if keyfunction (lastkey) = "end-error" then undo.
        end.
    end case.
*/
    if v-ja then do:
        do transaction:
            if new_document then do:
                create joudoc.
                joudoc.docnum = v-joudoc.
                create joudop.
                joudop.docnum = v-joudoc.
            end.
            else do:
                find joudoc where joudoc.docnum = v-joudoc exclusive-lock.
                find joudop where joudop.docnum = v-joudoc exclusive-lock.
            end.
            joudoc.who = g-ofc.
            joudoc.whn = g-today.
            joudoc.tim = time.
            if v-select = 1 then do:
                joudoc.dracctype = "4".
                joudoc.dracc = v-arp.
                joudoc.cracctype = "4".
                joudoc.cracc = v-arp100200.
            end.
            else do:
                joudoc.dracctype = "4".
                joudoc.dracc = v-arp100200.
                joudoc.cracctype = "4".
                joudoc.cracc = v-arp.
            end.
            joudoc.drcur = v-crc.
            joudoc.dramt = v-sum.
            joudoc.cramt = v-sum.
            joudoc.crcur = v-crc.
            joudoc.remark[1] = v-rem .
            joudoc.chk = 0.
            joudoc.bas_amt = "D".
            run chgsts("JOU", v-joudoc, "new").
            find current joudoc no-lock no-error.
            joudop.who = g-ofc.
            joudop.whn = g-today.
            joudop.tim = time.
            if v-select = 1 then joudop.type = "VTK2". else joudop.type = "PTK2".
            joudop.amt = v-sumarp.
            joudop.doc1 = v-nomer.
            joudop.lname = v-ofc.
            joudop.fname = v-dep.
            joudop.mname = v-depname.
            find current joudop no-lock no-error.
            displ v-joudoc with frame f_main.
            pause 0.
         end. /*end trans-n*/
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

    find joudoc where joudoc.docnum = v-joudoc no-lock no-error.
    if not available joudoc then do:
        message "Документ не найден." view-as alert-box.
        undo, retry.
    end.
    find joudop where joudop.docnum = v-joudoc no-lock no-error.
    if available joudop then do:
        if v-select = 1 then do:
            if  joudop.type <> "VTK2" then do:
                message substitute ("Документ не относится к типу выдача наличности в миникассу(счет 100200)") view-as alert-box.
                return.
            end.
        end.
        if v-select = 2 then do:
            if joudop.type <> "PTK2" then do:
                message substitute ("Документ не относится к типу принятие наличности из миникассы(счет 100200)") view-as alert-box.
                return.
            end.
        end.
    end.
    if joudoc.jh > 1 and v_u = 2 then do:
        message "Транзакция уже проведена. Для редактирования удалите транзакцию." view-as alert-box.
        return.
    end.
    if joudoc.who ne g-ofc and v_u = 2 then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        return.
    end.
    v-nomer = joudop.doc1.
    v-sumarp  = joudop.amt.
    v-ofc = joudop.lname.
    v-dep     = joudop.fname.
    v-depname = joudop.mname.
    v-crc = joudoc.drcur.
    if v-select = 1 then do: /* выдача */
        v-arp = joudoc.dracc.
        v-arp100200 = joudoc.cracc.
    end.
    else do: /* получение */
        v-arp = joudoc.cracc.
        v-arp100200 = joudoc.dracc.
    end.
    v-sum = joudoc.dramt.
    v-rem = joudoc.remark[1].
    v_trx = joudoc.jh.
    find first crc where crc.crc = v-crc no-lock no-error.
    if avail crc then v-crc_val = crc.code.

    if v-select = 1 then do: /*  выдача */
        v-deb = "100500   АРП " + joudoc.dracc.
        v-cre = "100200   АРП " + joudoc.cracc.
    end.
    else do:  /* принятие  */
        v-cre = "100500   АРП " + joudoc.cracc.
        v-deb = "100200   АРП " + joudoc.dracc.
    end.
    displ v_trx v-nomer v-depname v-ofc v-crc v-crc_val v-arp v-sumarp v-sum v-rem /*v-kod v-kbe*/ v-knp v-deb v-cre with frame f_main.
end procedure.


Procedure Delete_document.
    do transaction on error undo, retry:
        vj-label  = " Удалить документ?..................".
        run view_doc.
        find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
        if available joudoc then do:
            if not (joudoc.jh eq 0 or joudoc.jh eq ?) then do:
                message "Транзакция уже проведена, удаление в данном меню запрещено." view-as alert-box.
                undo, return.
            end.
            if joudoc.who ne g-ofc then do:
               message substitute (
                  "Документ принадлежит &1. Удалять нельзя.", joudoc.who) view-as alert-box.
               undo, return.
            end.
            displ vj-label no-label format "x(35)"  with frame f_main.
            pause 0.
            v-ja = no.
            update v-ja  with frame f_main.
            if v-ja then do:
                find joudoc where joudoc.docnum = v-joudoc no-error.
                if available joudoc then delete joudoc.
                find first joudoc no-lock no-error.
                for each substs where substs.sub = "jou" and  substs.acc = v-joudoc.
                    delete substs.
                end.
                find first substs no-lock no-error.
                find cursts where cursts.sub = "jou" and  cursts.acc = v-joudoc no-error.
                if available cursts then delete cursts.
                find first cursts no-lock no-error.
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
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    if joudoc.jh ne ? and joudoc.jh <> 0 then do:
        message "Транзакция уже проведена." view-as alert-box.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn) view-as alert-box.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who) view-as alert-box.
        undo, return.
    end.

    v-ja = yes.
    displ vj-label no-label format "x(35)"  with frame f_main.
    pause 0.
    update v-ja  with frame f_main.
    if not v-ja then undo, return.

    if v-select = 1 then do:
        v-tmpl = "jou0066".
        v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-arp + vdel + v-arp100200 + vdel + v-rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + v-knp.
        s-jh = 0.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc , output rcode, output rdes, input-output s-jh).
        if rcode <> 0 then do:
            message rdes.
            pause.
            undo, return.
        end.
    end.
    else do:
        v-tmpl = "jou0067".
        v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-arp100200 + vdel + v-arp + vdel + v-rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + v-knp.
        s-jh = 0.
        run trxgen (v-tmpl, vdel, v-param, "jou", v-joudoc , output rcode, output rdes, input-output s-jh).
        if rcode <> 0 then do:
            message rdes.
            pause.
            return.
        end.
    end.

    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v-joudoc.
    if jh.sts < 5 then jh.sts = 5.
    for each jl of jh:
        if jl.sts < 5 then jl.sts = 5 .
    end.
    find current jh no-lock.

    find joudoc where joudoc.docnum eq v-joudoc exclusive-lock no-error.
    joudoc.jh = s-jh.
    find current joudoc no-lock no-error.
    run chgsts(m_sub, v-joudoc, "trx").

    message "ДОКУМЕНТ ДЛЯ " v-ofc "СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(s-jh) + " ~nНеобходим акцепт документа в п.м. 4.3.6 " view-as alert-box.
    v_trx = s-jh.
    display v_trx with frame f_main.
    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
    else run printord(s-jh,"").

    find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    for each jl where jl.jh eq s-jh no-lock:
        if (jl.gl = sysc.inval or jl.gl = 100100) and jl.crc = 1 then
        do: /* проставляем код кассплана  */
            create jlsach .
            jlsach.jh = s-jh.
            if jl.dc = "D" then jlsach.amt = jl.dam . else jlsach.amt = jl.cam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            if v-select = 1 then jlsach.sim = 100 .
            else jlsach.sim = 300 .

        end.
    end.
    release jlsach.
    for each csofc where csofc.nomer = v-nomer no-lock.
        run mail   (csofc.ofc + "@metrocombank.kz",
            "METROCOMBANK <mkb@metrocombank.kz>",
            v-rem,
            "Добрый день!\n\n Необходимо отконтролировать инкассацию электронного кассира \n N: " + v-nomer +
            "\n Сумма: " + string(v-sum) + "  " + v-crc_val + "\n Проводка :" + string(s-jh) + "\n Пополнил :" + g-ofc + "\n " + string(g-today) + "  " + string(time,"HH:MM"), "1", "","" ).
    end.
    hide all.

end procedure.

procedure Delete_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc.
    if locked joudoc then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш." view-as alert-box.
        pause 3.
        undo, return.
    end.
    s-jh = joudoc.jh.

    /* проверка свода кассы */
    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.
    find sysc where sysc.sysc eq "CASHGL500" no-lock no-error.
    find cursts where cursts.sub eq "jou" and cursts.acc eq v-joudoc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя.".
            pause 3.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
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
                    find cashofc where cashofc.whn eq jl.jdt and
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
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        cashofc.whn = jl.jdt.
                        cashofc.ofc = jl.teller.
                        cashofc.crc = jl.crc.
                        cashofc.sts = 2.
                        cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.

        end.

        joudoc.jh   = ?.
        v_trx = ?.
        display v_trx with frame f_main.

    end. /* transaction */

    do transaction:
        run comm-dj(joudoc.docnum).

        /* sasco - удалить записи о контроле для arpcon */
        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        /* найдем arpcon со счетом по дебету */
        find arpcon where arpcon.arp = joudoc.dracc and
                          arpcon.sub = 'jou' and
                          arpcon.txb = sysc.chval
                          no-lock no-error.
        if avail arpcon then do:
            /* удалим статус контроля из истории платежа */
            for each substs where substs.sub = 'jou' and
                                  substs.acc = joudoc.docnum and
                                  substs.sts = arpcon.new-sts:
                delete substs.
            end.

            find cursts where cursts.sub = 'jou' and cursts.acc = joudoc.docnum no-error.

            if avail cursts then do:
               find last substs where substs.sub = 'jou' and substs.acc = joudoc.docnum no-lock no-error.
               assign cursts.sts = substs.sts.
            end.
        end.
    end. /* transaction */
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.
    release joudoc.
    run chgsts("JOU", v-joudoc, "new").
    message "Транзакция удалена." view-as alert-box.
end procedure.

procedure Screen_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        run vou_word (2, 1, joudoc.info).
    end. /* transaction */
end procedure.

procedure print_transaction:
    if v-joudoc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v-joudoc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует." view-as alert-box.
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
                if v-noord = no then run vou_bankt(2, 1, joudoc.info).
                else do:
                    ans = yes.
                    Message "Печать операционного ордера ? " update ans.
                    if ans then run vou_word(2, 1, joudoc.info).
                    run printord(s-jh,"").
                end.
    end. /* transaction */
end procedure.


