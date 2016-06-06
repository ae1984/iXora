/* a_ppout.p
 * MODULE
 * DESCRIPTION
        Платежное поручение – внешнее
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
         30/09/2013 Luiza  - ТЗ 2047
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
def var v-ans    as logic no-undo.

define button b1 label "СОЗДАТЬ".
define button b2 label "ПРОСМОТР".
define button b3 label "РЕДАКТ".
define button b4 label "УДАЛИТЬ".
define button b6 label "ПОРУЧЕНИЯ".
define button b5 label "ВЫХОД".


{chk12_innbin.i}

function chk-iikben returns logical (p-val1 as char, p-val2 as char).
    find first bankl where bankl.bank = p-val2 no-lock no-error.
    if available bankl and trim(bankl.mntrm) = substr(p-val1,5,3) then return true.
    else return false.
end.


define frame a2
    b1 b2 b3 b4 b5
    with side-labels row 4 column 5 no-box.


     Form
        skip(1)
        v-nom          label " Заявление               " format ">>>>>>>>9"
        v-dtnom       label " от "                         colon 43 format "99/99/9999" skip
        v-aaa         label " ИИК                     " format "x(20)" validate(can-find(first aaa where aaa.aaa = v-aaa no-lock),"Неверный счет!") skip
        v-control     label " Контроль                "
        v-contrname   label " Контролер "              colon 48 format "x(35) " skip
        v-crc         LABEL " Валюта                  " format ">9"  validate(can-find(first crc where crc.crc = v-crc and crc.sts <> 9 no-lock),"Неверный код валюты!")
                      help " Введите код клиента, F2-помощь, F4-выход"
        v-crccode     no-label                         colon 28 format "x(3)" skip
        v-lname       LABEL " Фамилия                 " format "X(20)" skip
        v-fname       LABEL " Имя                     " format "X(20)" skip
        v-mname       LABEL " Отчество                " format "X(20)" skip
        v-bin         LABEL " ИИН                     " format "x(12)" validate((chk12_innbin(v-bin)),'Неправильно введён БИН/ИИН') skip
        v-opl         LABEL " Вид оплаты              " format "x(10)" skip
        v-sum         LABEL " Сумма                   " format ">>>,>>>,>>>,>>9.99" validate(v-sum > 0,"Проверьте сумму!") skip
        v-dt          label " День формир. плат поруч " format ">9" validate(v-dt > 0 and v-dt <= 31,'Неправильно день формир-я ПП') skip
        v-dtc         label " Срок                    " format "99/99/9999" skip
        v-rem         label " Назначение              " format "X(60)" skip
        v-rem1        label "                         " format "X(60)" skip
        v-rem2        label "                         " format "X(60)" skip
        v-knp         label " КНП                     " format "X(3)"  /*validate(v-knp = "421" or v-knp = "423" or v-knp = "429","Допустимые КНП: 421, 423, 429!")*/
                     /* help  " Допустимые КНП: 421, 423, 429. F4-выход"*/ skip
        v-kbe         label " Кбе                     " format "X(2)"  validate(v-kbe = "19" or v-kbe = "29","Допустимые кбе: 19 или 29!")
                      help  " Допустимые кбе: 19 или 29. F4-выход" skip
        v-ben         label " Бенефициар              " format "X(60)" validate(v-ben <> "","Заполните наименование бенефициара!") skip
        v-binb        label " БИН / ИИН бенефициара   " format "x(12)" validate((chk12_innbin(v-binb)),'Неправильно введён БИН/ИИН') skip
        v-bic         label " БИК банка бенефициара   " format "x(8)" validate(can-find(first bankl where bankl.bank = v-bic and bankl.mntrm <> "" no-lock),"Неверный БИК!") skip
        v-bankb       label " Банк бенефициара        " format "X(60)" skip
        /*v-iikben      label " ИИК в банке бенефициара " format "X(20)" validate(length(trim(v-iikben)) = 20,"Неверное количество символов!") skip*/
        v-iikben      label " ИИК в банке бенефициара " format "X(20)" validate(chk-iikben(v-iikben, v-bic) and length(trim(v-iikben)) = 20, "Счет получателя не соответствует БИКу получателя") skip
        vj-label no-label format "x(38)" v-ja no-label
    WITH  SIDE-LABELS  ROW 6 column 3 TITLE v_title width 90 FRAME f_main.


/*обработка вызова помощи*/

/* help for aaa */
on help of v-aaa in frame f_main do:
    run a_helppc PERSISTENT SET phand.
    v-aaa = frame-value.
    displ v-aaa with frame f_main.
end.
/*---------------------------------*/

DEFINE QUERY q-bic FOR bankl.

DEFINE BROWSE b-bic QUERY q-bic
       DISPLAY bankl.bank label "Бик " format "x(8)" bankl.name label "Наименование   " format "x(40)"
       WITH  15 DOWN.
DEFINE FRAME f-bic b-bic  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 85 NO-BOX.

on help of v-bic in frame f_main do:
    OPEN QUERY  q-bic FOR EACH bankl where /*length(bankl.bank) = 8 and*/ bankl.mntrm <> "" no-lock.
    ENABLE ALL WITH FRAME f-bic.
    wait-for return of frame f-bic
    FOCUS b-bic IN FRAME f-bic.
    v-bic = bankl.bank.
    v-bankb = bankl.name.
    hide frame f-bic.
    displ v-bic v-bankb with frame f_main.
end.

DEFINE QUERY q-knp FOR codfr.

DEFINE BROWSE b-knp QUERY q-knp
       DISPLAY codfr.code label "Код  " format "x(3)" codfr.name[1] label "Наименование   " format "x(60)"
       WITH  15 DOWN.
DEFINE FRAME f-knp b-knp  WITH overlay 1 COLUMN SIDE-LABELS row 5 COLUMN 35 width 85 NO-BOX.

on help of v-knp in frame f_main do:
    OPEN QUERY  q-knp FOR EACH codfr where codfr.codfr = "spnpl" and codfr.code <> "msc" and codfr.code <> "" /*and (codfr.code = "421" or codfr.code = "423" or codfr.code = "429")*/ no-lock.
    ENABLE ALL WITH FRAME f-knp.
    wait-for return of frame f-knp
    FOCUS b-knp IN FRAME f-knp.
    v-knp = codfr.code.
    hide frame f-knp.
    displ v-knp with frame f_main.
end.
/*---------------------------------*/

DEFINE QUERY q-aaa FOR ppout.

DEFINE BROWSE b-aaa QUERY q-aaa
       DISPLAY ppout.iikben label "ИИК в банке бенефициара " format "x(20)" ppout.bankben label "Банк бенефициара " format "x(30)"
       WITH  15 DOWN.
DEFINE FRAME f-aaa b-aaa  WITH overlay 1 COLUMN SIDE-LABELS row 6 COLUMN 35 width 85 NO-BOX.

/*выбор кнопки Создать*/
on choose of b1 in frame a2 do:
    clear frame f_main.
    find last ppout use-index id no-lock no-error.
    if available ppout then v-id = ppout.id + 1.
    else v-id = 1.
    v-cif    = "".
    v-nom = v-id.
    v-dtnom = today.
    v-control = no.
    v-contrname = "".
    v-aaa    = "".
    v-crc    = 0.
    v-lname  = "".
    v-fname  = "".
    v-mname  = "".
    v-bin    = "".
    v-opl    = "".
    v-sum    = 0.
    v-dt     = 0.
    v-dtc    = ?.
    v-rem    = "".
    v-rem1    = "".
    v-rem2    = "".
    v-knp    = "".
    v-kbe    = "".
    v-ben    = "".
    v-binb   = "".
    v-bic    = "".
    v-bankb  = "".
    v-iikben = "".
    v-crccode = "".
    vj-label = " Сохранить?........................." .

    display v-nom v-dtnom v-control v-contrname with frame f_main.
    update   v-aaa   with frame f_main.
    find first aaa where aaa.aaa = v-aaa no-lock no-error.
    if not available aaa then do:
        message "Счет не найден!." view-as alert-box.
        undo,return.
    end.
    v-crc = aaa.crc.
    find first crc where crc.crc = v-crc no-lock no-error.
    if available crc then v-crccode  = crc.code.
    v-cif = aaa.cif.
    find first cif where cif.cif = v-cif no-lock no-error.
    if available cif then v-name = cif.name.
    else do:
        message "Клиент не найден!." view-as alert-box.
        undo,return.
    end.
    find first pcstaff0 where pcstaff0.aaa = aaa.aaa no-lock no-error.
    /*v-lname = entry(1,cif.name," ").
    if NUM-ENTRIES(cif.name," ") > 1 then v-fname = entry(2,cif.name," ").
    if NUM-ENTRIES(cif.name," ") > 2 then v-mname = entry(3,cif.name," ").
    v-bin = cif.bin.*/
    v-bin = pcstaff0.iin.
    v-lname = trim(pcstaff0.sname).
    v-fname = trim(pcstaff0.fname).
    v-mname = trim(pcstaff0.mname).

    v-rem = "Согласно Заявлению N "  + string(v-nom) + " от " + string(v-dtnom).
    displ v-crc v-crccode v-lname v-fname v-mname v-bin v-rem with frame f_main.
    /*run sel2 ("Вид оплаты :", " 1. Постоянно | 2. График ", output vopl).
    if keyfunction (lastkey) = "end-error" then return.
    if (vopl < 1) or (vopl > 2) then return.*/
    vopl = 1.
    if vopl = 1 then do:
        v-opl  = "Постоянно".
        display v-opl vj-label with frame f_main.
        update v-sum v-dt v-dtc /*v-rem*/ v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic with frame f_main.
    end.
    else do:
        v-opl  = "График".
        run graf.
        display v-opl vj-label with frame f_main.
        update /*v-rem*/ v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic with frame f_main.
    end.
    find first bankl where bankl.bank = v-bic no-lock no-error.
    if available bankl then v-bankb = bankl.name.
    displ v-bankb with frame f_main.

    repeat:
        update v-iikben  with frame f_main.
        find first ppout where ppout.aaa = v-aaa and ppout.iikben = v-iikben and ppout.del = no no-lock no-error.
        if available ppout then message "Запись по данному счету уже есть! ~n Выберите <ПРОСМОТР> или <РЕДАКТИРОВАТЬ> " view-as alert-box.
        else leave.
    end.
    if keyfunction (lastkey) = "end-error" then undo.
    v-ja = yes.
    update v-ja  with frame f_main.
    if v-ja then do:
        create ppout.
        ppout.id        = v-id.
        ppout.cif       = v-cif.
        ppout.stat      = "".
        ppout.aaa       = v-aaa.
        ppout.crc       = v-crc.
        ppout.bin       = v-bin.
        ppout.sum       = v-sum.
        ppout.remark[1] = v-rem.
        ppout.remark[2] = v-rem1.
        ppout.remark[3] = v-rem2.
        ppout.who       = g-ofc.
        ppout.regdt     = today.
        /*ppout.upwho     =
        ppout.updt      =
        ppout.del       =
        ppout.delwho    =
        ppout.deldt     = */
        ppout.opl       = vopl.
        ppout.vopl      = v-opl.
        ppout.dtop      = v-dt.
        ppout.dtcl      = v-dtc.
        ppout.knp       = v-knp.
        ppout.kbe       = v-kbe.
        ppout.benname   = v-ben.
        ppout.binben    = v-binb.
        ppout.bic       = v-bic.
        ppout.bankben   = v-bankb.
        ppout.iikben    = v-iikben.
        ppout.con       = no.
        ppout.conwho    = "".
        ppout.stat      = "новый".
        ppout.nom       = v-nom.
        ppout.dtnom     = v-dtnom.

        MESSAGE "Необходим контроль в п.м. 15.7.3. 'Контроль платежного поручения'!"  view-as alert-box.
    end.
    else do:
        for each ppgraf where ppgraf.id = v-id exclusive-lock.
            delete ppgraf.
        end.
        hide frame f_main.
    end.
end. /*конец кнопки новый*/

on choose of b2 in frame a2 do: /* кнопка просмотр*/
    clear frame f_main.
    v-aaa    = "".
    update v-aaa with frame f_main.
    find first ppout where ppout.aaa = v-aaa and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    OPEN QUERY  q-aaa FOR EACH ppout where ppout.aaa = v-aaa and ppout.del = no no-lock.
    ENABLE ALL WITH FRAME f-aaa.
    wait-for return of frame f-aaa
    FOCUS b-aaa IN FRAME f-aaa.
    v-iikben = ppout.iikben.
    v-id     = ppout.id.
    hide frame f-aaa.
    find first ppout where ppout.id = v-id and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-cif    = ppout.cif.
    /*v-status = ppout.stat.*/
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
    displ v-nom v-dtnom v-control v-contrname v-crc v-crccode v-lname v-fname v-mname v-bin v-opl v-sum v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben with frame f_main.
    if vopl <> 1 then run viewgraf.
end. /*конец кнопки .*/

on choose of b3 in frame a2 do:
    clear frame f_main.
    v-aaa    = "".
    vj-label = " Сохранить?........................." .
    update v-aaa with frame f_main.
    find first ppout where ppout.aaa = v-aaa and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    OPEN QUERY  q-aaa FOR EACH ppout where ppout.aaa = v-aaa and ppout.del = no no-lock.
    ENABLE ALL WITH FRAME f-aaa.
    wait-for return of frame f-aaa
    FOCUS b-aaa IN FRAME f-aaa.
    v-iikben = ppout.iikben.
    v-id     = ppout.id.
    hide frame f-aaa.
    find first ppout where ppout.id = v-id and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-cif    = ppout.cif.
    /*v-status = ppout.stat.*/
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
    displ v-nom v-dtnom v-control v-contrname v-crc v-crccode v-lname v-fname v-mname v-bin v-opl v-sum v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben with frame f_main.
    v-rem = "Согласно Заявлению N "  + string(v-nom) + " от " + string(v-dtnom).

    /*run sel2 ("Вид оплаты :", " 1. Постоянно | 2. График ", output vopl).
    if keyfunction (lastkey) = "end-error" then return.
    if (vopl < 1) or (vopl > 2) then return.*/
    vopl = 1.
    if vopl = 1 then do:
        v-opl  = "Постоянно".
        display v-opl vj-label with frame f_main.
        v-ans = no.
        run delgraf(output v-ans).
        if v-ans = yes then undo.
        update v-sum v-dt v-dtc /*v-rem*/ v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-iikben with frame f_main.
    end.
    else do:
        v-opl  = "График".
        run graf.
        v-sum = 0.
        v-dt = 0.
        v-dtc = ?.

        display v-opl v-sum v-dt v-dtc vj-label with frame f_main.
        update /*v-rem*/ v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-iikben with frame f_main.
    end.
    v-ja = yes.
    update v-ja  with frame f_main.
    if v-ja then do:
        find first ppout where ppout.id = v-id and ppout.del = no exclusive-lock no-error.
        if not available ppout then do:
            message "Запись не найдена!." view-as alert-box.
            undo,return.
        end.
        ppout.sum       = v-sum.
        ppout.remark[1] = v-rem.
        ppout.remark[2] = v-rem1.
        ppout.remark[3] = v-rem2.
        ppout.upwho     = g-ofc.
        ppout.updt      = today.
        ppout.opl       = vopl.
        ppout.vopl      = v-opl.
        ppout.dtop      = v-dt.
        ppout.dtcl      = v-dtc.
        ppout.knp       = v-knp.
        ppout.kbe       = v-kbe.
        ppout.benname   = v-ben.
        ppout.binben    = v-binb.
        ppout.bic       = v-bic.
        ppout.bankben   = v-bankb.
        ppout.iikben    = v-iikben.
        ppout.con       = no.
        ppout.conwho    = "".
        ppout.stat      = "редакт".
        ppout.nom       = v-nom.
        ppout.dtnom      = v-dtnom.
        MESSAGE "Необходим контроль в п.м. 15.7.3. 'Контроль платежного поручения'!"  view-as alert-box.
        v-control = no.
        v-contrname = "".
        displ v-control v-contrname with frame f_main.
        pause 0.
    end.
end.  /*конец кнопки редактирование*/

on choose of b4 in frame a2 do: /* кнопка удалить*/
    clear frame f_main.
    v-aaa    = "".
    vj-label = " Удалить?........................." .
    update v-aaa with frame f_main.
    find first ppout where ppout.aaa = v-aaa and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    OPEN QUERY  q-aaa FOR EACH ppout where ppout.aaa = v-aaa and ppout.del = no no-lock.
    ENABLE ALL WITH FRAME f-aaa.
    wait-for return of frame f-aaa
    FOCUS b-aaa IN FRAME f-aaa.
    v-iikben = ppout.iikben.
    v-id     = ppout.id.
    hide frame f-aaa.
    find first ppout where ppout.id = v-id and ppout.del = no no-lock no-error.
    if not available ppout then do:
        message "Запись не найдена!" view-as alert-box.
        undo,return.
    end.
    v-cif    = ppout.cif.
    /*v-status = ppout.stat.*/
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
    displ v-nom v-dtnom v-control v-contrname v-crc v-crccode v-lname v-fname v-mname v-bin v-opl v-sum v-dt v-dtc v-rem v-rem1 v-rem2 v-knp v-kbe v-ben v-binb v-bic v-bankb v-iikben vj-label with frame f_main.
    pause 0.
    v-ja = no.
    update v-ja  with frame f_main.
    if v-ja then do:
        run delgraf(output v-ans).
        if v-ans = yes then undo.
        find first ppout where ppout.id = v-id exclusive-lock no-error.
        if not available ppout then do:
            message "Запись не найдена!." view-as alert-box.
            undo,return.
        end.
        if ppout.con then do: /* если контроль документа есть, отправляем на контроль удаления */
            ppout.del       = yes.
            ppout.delwho    = g-ofc.
            ppout.deldt     = today.
            ppout.stat      = "удален".
            hide frame f_main.
            MESSAGE "Необходим контроль удаления в п.м. 15.7.3. 'Контроль платежного поручения'!"  view-as alert-box.
        end.
        else do:  /* если контроля документа не было, удаляем запись */
            delete ppout.
            hide frame f_main.
            MESSAGE "Запись удалена!"  view-as alert-box.
        end.
    end.

end.  /*конец кнопки удаление*/

on choose of b5 in frame a2 do:
    hide frame a2.
    return.
end. /*конец кнопки выход*/

    enable all with frame a2.
    wait-for window-close of frame a2 or choose of b5 in frame a2.


procedure graf:
    def var rid as rowid.
    define buffer buf for ppgraf.

    DEFINE QUERY q-graf FOR ppgraf.

    DEFINE BROWSE b-graf QUERY q-graf
           DISPLAY
           ppgraf.dat label " Дата " format "99/99/9999"
           ppgraf.sum label " Сумма " format ">>>,>>>,>>>,>>9.99"
           WITH  10 DOWN.
    DEFINE FRAME f-graf b-graf  WITH overlay 1 COLUMN title "INS-добавить ENTER-редакт DEL-удалить" SIDE-LABELS row 12 COLUMN 43 width 40.

    define frame getlist1
         ppgraf.dat no-label format "99/99/9999"
         ppgraf.sum no-label format ">>>,>>>,>>>,>>9.99"
    with side-labels row 8.


    repeat:
        OPEN QUERY  q-graf FOR EACH ppgraf where ppgraf.id = v-id /*ppgraf.aaa = v-aaa*/  no-lock.
        ENABLE ALL WITH FRAME f-graf.
        wait-for return of frame f-graf or INSERT-MODE of frame f-graf or DELETE-CHARACTER of frame f-graf
        FOCUS b-graf IN FRAME f-graf.

        if keyfunction (lastkey) = "end-error" then leave.

        if keyfunction (lastkey) = "RETURN" then do:
            b-graf:set-repositioned-row(b-graf:focused-row, "conditional").
            rid = rowid(ppgraf).
            find current ppgraf share-lock.
            displ ppgraf.dat ppgraf.sum with no-label overlay row b-graf:focused-row + 15 column 47 no-box frame getlist1.
            update ppgraf.dat ppgraf.sum with overlay row b-graf:focused-row + 15 column 47 no-box frame getlist1.
            ppgraf.uptim = time.
            ppgraf.upwho = g-ofc.
            ppgraf.updt = today.
            release ppgraf.
        end.
        if keyfunction (lastkey) = "DELETE-CHARACTER" then do:
            if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
            then do:
                find buf where rowid (buf) = rowid (ppgraf) exclusive-lock.
                create ppgrafhis.
                ppgrafhis.id        = buf.id.
                ppgrafhis.cif       = buf.cif.
                ppgrafhis.aaa       = buf.aaa.
                ppgrafhis.bin       = buf.bin.
                ppgrafhis.sum       = buf.sum.
                ppgrafhis.dat       = buf.dat.
                ppgrafhis.who       = buf.who.
                ppgrafhis.uptim     = buf.uptim.
                ppgrafhis.regdt     = buf.regdt.
                ppgrafhis.upwho     = buf.upwho.
                ppgrafhis.updt      = buf.updt.
                ppgrafhis.del       = yes.
                ppgrafhis.delwho    = g-ofc.
                ppgrafhis.deldt     = today.
                delete buf.

                close query q-graf.
                open query q-graf for each ppgraf where ppgraf.aaa = v-aaa no-lock.
                ENABLE ALL WITH FRAME f-graf.
            end.
        end.
        if keyfunction (lastkey) = "INSERT-MODE" then do:
            create ppgraf.
            ppgraf.id = v-id.
            ppgraf.cif = v-cif.
            ppgraf.aaa = v-aaa.
            ppgraf.bin = v-bin.
            ppgraf.sum = 0.
            ppgraf.dat = ?.
            ppgraf.who = g-ofc.
            ppgraf.regdt = today.
            ppgraf.uptim = time.
            ppgraf.upwho = "".
            ppgraf.updt = ?.
            ppgraf.del = no.
            ppgraf.delwho = "".
            ppgraf.deldt = ?.
            update ppgraf.dat ppgraf.sum with overlay row b-graf:focused-row + 15 column 47 no-box frame getlist1.
        end.
    end.

end procedure.

procedure delgraf:
    define output parameter result  as logic.
    result = no.
    def var quest as logic format "Да/Нет" init no.
    find first ppgraf where ppgraf.id = v-id  no-lock no-error.
    if available ppgraf then do:
        message substitute ("Есть данные по графику, удалить?") update quest.
        if quest then do:
            for each  ppgraf where ppgraf.id = v-id exclusive-lock.
                create ppgrafhis.
                ppgrafhis.id        = ppgraf.id.
                ppgrafhis.cif       = ppgraf.cif.
                ppgrafhis.aaa       = ppgraf.aaa.
                ppgrafhis.bin       = ppgraf.bin.
                ppgrafhis.sum       = ppgraf.sum.
                ppgrafhis.dat       = ppgraf.dat.
                ppgrafhis.who       = ppgraf.who.
                ppgrafhis.uptim     = ppgraf.uptim.
                ppgrafhis.regdt     = ppgraf.regdt.
                ppgrafhis.upwho     = ppgraf.upwho.
                ppgrafhis.updt      = ppgraf.updt.
                ppgrafhis.del       = yes.
                ppgrafhis.delwho    = g-ofc.
                ppgrafhis.deldt     = today.
                delete ppgraf.
            end.
        end.
        else result = yes.
    end.

end procedure.

procedure viewgraf:

    DEFINE QUERY q-graf FOR ppgraf.

    DEFINE BROWSE b-graf QUERY q-graf
           DISPLAY
           ppgraf.dat label " Дата " format "99/99/9999"
           ppgraf.sum label " Сумма " format ">>>,>>>,>>>,>>9.99"
           WITH  20 DOWN overlay no-label title " График ".
    DEFINE FRAME f-graf b-graf  WITH overlay 1 COLUMN row 7 COLUMN 65 width 40 no-box.

        OPEN QUERY  q-graf FOR EACH ppgraf where ppgraf.id = v-id  no-lock.
        ENABLE ALL WITH FRAME f-graf.
        wait-for return of frame f-graf
        FOCUS b-graf IN FRAME f-graf.
        hide frame f-graf.
end procedure.
