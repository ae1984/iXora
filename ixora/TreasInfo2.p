/* TreasInfo2.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Доступ третьим лицам к счетам Клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.5.3
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM IB
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
{classes.i}
{comm-txb.i}

def var Usr as class ClientClass.

def var phand as handle.
def var rez as log.

def temp-table t-fils no-undo
    field fcode as char
    field fname as char
    index idx1 is primary fcode.

empty temp-table t-fils.
for each comm.txb where comm.txb.consolid no-lock:
    find first t-fils where t-fils.fcode = comm.txb.bank no-lock no-error.
    if not avail t-fils then do:
        create t-fils.
        t-fils.fcode = comm.txb.bank.
        t-fils.fname = comm.txb.info.
    end.
end.

def var CurrTXB as char.
CurrTXB = comm-txb().

function CheckAccept returns logi(input p-isgo as logi,input p-cif as char,input p-cifGO as char,input p-login as char,input p-acc as char).
    def var v-res as logi.

    v-res = false.
    if p-isgo then do:
        find first comm.treasury where comm.treasury.isgo eq false and comm.treasury.cifgo eq p-cif and comm.treasury.login eq p-login and comm.treasury.cwho ne "" and comm.treasury.cwhn ne ? no-lock no-error.
        if avail comm.treasury then do: v-res = true. leave. end.
    end.
    else do:
        find first comm.treasury where comm.treasury.isgo eq false and comm.treasury.cif eq p-cif and comm.treasury.cifgo eq p-cifGO and comm.treasury.acc eq p-acc and
        comm.treasury.login eq p-login no-lock no-error.
        if avail comm.treasury and comm.treasury.cwho ne "" and comm.treasury.cwhn ne ? then do: v-res = true. leave. end.
    end.

    return v-res.
end function.

/***********************************************************************************************************/
Usr = NEW ClientClass().

run ShowCorpGrp.
/***********************************************************************************************************/

procedure ShowCorpGrp:
    define button bt-add label "Добавить".
    define button bt-del label "Удалить".
    define button bt-close label "Выход".

    def buffer b-treasury for comm.treasury.
    def buffer b-webra for comm.webra.

    define query q_list for b-treasury,b-webra.
    define browse b_list query q_list no-lock
    display
        b-treasury.cif column-label "CIF-код" format "x(8)"
        b-treasury.name column-label "Наименование клиента" format "x(42)"
        b-treasury.login column-label "Логин ИБ" format "x(10)"
        b-webra.info[3] + " " + b-webra.info[4] + " " + b-webra.info[5] column-label "Наименование логина" format "x(35)"
    with title "Головная организация" 10 down centered width 102 overlay no-row-markers.

    define frame f1
        b_list skip space(33)
        bt-add
        bt-del
        bt-close
    with no-labels row 1 column 1 width 104 overlay.

    /******************************************************************************/
    on choose of bt-add in frame f1
    do:
        define frame f2
            iCif as char format "x(8)" label "              Код клиента" validate(iCif ne "","Введите CIF-код клиента!") skip
            nameGo as char format "x(25)" label "     Наименование клиента" skip
            login as char format "x(20)" label "       Логин пользователя" validate(can-find(first b-webra where b-webra.login = trim(login) no-lock),"Логин не найден! Повторите ввод!") skip
            loginname as char format "x(30)" label "Наименование пользователя" skip
        WITH SIDE-LABELS row 5 column 2 width 102 overlay title "Введите данные ГО".

        on "end-error" of frame f2 do:
            hide frame f2 no-pause.
        end.

        on help of iCif in frame f2 do:
            run h-cif persistent set phand.
            iCif = trim(frame-value).
            displ iCif with frame f2.
        end.

        do transaction:
            set iCif with frame f2.
            if iCif entered then
            do:
                iCif = trim(iCif).
                def var GoCif as char init "".
                if not Usr:FindClientNo(iCif) then undo.
                nameGo = Usr:clientname.
                displ nameGo with frame f2.
            end.
            else undo.

            set login with frame f2.
            if login entered then
            do:
                find last b-webra where b-webra.login = trim(login) no-lock no-error.
                if avail b-webra then loginname = trim(b-webra.info[3]) + " " + trim(b-webra.info[4]) + " " + trim(b-webra.info[5]).
                displ loginname with frame f2.
                pause 3.
            end.
            else undo.

            find first b-treasury where b-treasury.isgo = true and b-treasury.cif = iCif and b-treasury.login = login no-lock no-error.
            if not avail b-treasury then do:
                create b-treasury.
                b-treasury.isgo = true.
                b-treasury.txb = CurrTXB.
                b-treasury.cif = iCif.
                b-treasury.name = Usr:clientname.
                b-treasury.login = login.
                b-treasury.who = g-ofc.
                b-treasury.whn = g-today.
            end.
            else do:
                message "Данные уже были добавлены!Попробуйте еще раз!" view-as alert-box buttons ok.
                undo.
            end.
        end.
        OPEN QUERY q_list for each b-treasury where b-treasury.txb = CurrTXB and b-treasury.isgo = true no-lock,
        each b-webra where b-webra.login = b-treasury.login no-lock.
    end.

    /******************************************************************************/
    on choose of bt-del in frame f1
    do:
        GET CURRENT q_list no-lock.
        if avail b-treasury then
        do:
            def var v-Pos as inte.
            v-Pos = CURRENT-RESULT-ROW("q_list").
            if not CheckAccept(b-treasury.isgo,b-treasury.cif,b-treasury.cifgo,b-treasury.login,b-treasury.acc) then do:
                run yn("","Удалить выделенную запись ?","","", output rez).
                if rez then
                do:
                    def var tCif as char.
                    REPOSITION q_list to ROW v-Pos.
                    GET CURRENT q_list exclusive-lock.
                    tCif = b-treasury.cif.
                    login = b-treasury.login.
                    delete b-treasury.
                    for each b-treasury where b-treasury.isgo = false and b-treasury.cifgo = tCif and b-treasury.login = login exclusive-lock:
                        delete b-treasury.
                    end.
                    OPEN QUERY q_list for each b-treasury where b-treasury.txb = CurrTXB and b-treasury.isgo = true no-lock,
                    each b-webra where b-webra.login = b-treasury.login no-lock.
                end.
            end.
            else message "Удаление невозможно, необходимо снять акцепт в п.м. 1.5.5 !" view-as alert-box buttons ok.
        end.
        else release b-treasury.
    end.
    /******************************************************************************/
    on choose of bt-close in frame f1
    do:
        hide all no-pause.
        apply "endkey" to frame f1.
    end.
    /******************************************************************************/
    on return of b_list in frame f1
    do:
        if avail b-treasury then
        do:
            run ShowFillGrp(b-treasury.txb,b-treasury.cif,b-treasury.name,b-treasury.acc,b-treasury.login).
        end.
    end.
    /******************************************************************************/
    OPEN QUERY q_list for each b-treasury where b-treasury.txb = CurrTXB and b-treasury.isgo = true no-lock,each b-webra where b-webra.login = b-treasury.login no-lock.
    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR "endkey" of frame f1 focus browse b_list.
end procedure.

/***********************************************************************************************************/
procedure ShowFillGrp:
    def input param GoTXB as char.
    def input param GoCif as char.
    def input param GoName as char format "x(45)".
    def input param GoAcc as char format "x(21)".
    def input param GoLogin as char.

    def buffer b2-treasury for comm.treasury.
    def buffer b2-txb for comm.txb.

    define button bt-add label "Добавить".
    define button bt-del label "Удалить".
    define button bt-close label "Закрыть".

    define query q2_list for b2-treasury,b2-txb.
    define browse b2_list query q2_list no-lock
    display
        b2-txb.info column-label "Филиал" format "x(25)"
        b2-treasury.cif column-label "CIF-код" format "x(8)"
        b2-treasury.name column-label "Наименование клиента" format "x(42)"
        b2-treasury.acc column-label "Счет" format "x(20)"
    with 10 down centered overlay width 102 SEPARATORS no-row-markers.

    define frame f3
        b2_list skip  space(33)
        bt-add
        bt-del
        bt-close
    with no-labels row 18 column 1 overlay width 104 title "Состав группы Головной Организации".

    /******************************************************************************/
    on "end-error" of frame f3 do:
        hide frame f3 no-pause.
        apply "endkey" to frame f3.
    end.
    /******************************************************************************/
    on choose of bt-add in frame f3
    do:
        define frame f4
            TXB as char format "x(5)" label "              Филиал" validate(can-find(first t-fils where t-fils.fcode eq TXB no-lock),"Некорректный код филиала банка!") help "Выбор через клавишу < F2 >" skip
            iCif as char format "x(8)" label  "         Код клиента" skip
            v-nameFil as char format "x(25)" label "Наименование клиента" skip
        WITH SIDE-LABELS row 23 column 2 overlay width 102 title "Введите данные филиала".

        on "end-error" of frame f4 do:
            hide frame f4 no-pause.
        end.
        on help of TXB in frame f4 do:
            {itemlist.i
                &file       = "t-fils"
                &frame      = "row 6 centered scroll 1 20 down overlay "
                &where      = " true "
                &flddisp    = " t-fils.fcode label 'Код' format 'x(5)'
                                t-fils.fname label 'Филиал' format 'x(50)'
                              "
                &chkey      = "fcode"
                &chtype     = "string"
                &index      = "idx1"
            }
            TXB = trim(t-fils.fcode).
            displ TXB with frame f4.
            find first b2-txb where b2-txb.consolid = true and b2-txb.bank = TXB no-lock no-error.
        end.

        on help of iCif in frame f4 do:
            if avail b2-txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(b2-txb.path,'/data/','/data/b') + " -ld txb -U " + b2-txb.login + " -P " + b2-txb.password).
                run h-ciftxb(output iCif).
                displ iCif with frame f4.
            end.
            if connected ("txb") then disconnect "txb".
        end.

        hide frame f4 no-pause.
        set TXB with frame f4.
        set iCif with frame f4.
        if iCif entered then
        do:
            def var v-err as char.
            iCif = trim(iCif).
            if avail b2-txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(b2-txb.path,'/data/','/data/b') + " -ld txb -U " + b2-txb.login + " -P " + b2-txb.password).
                run goadd_txb(TXB,iCif,GoCif,g-ofc,g-today,GoLogin,output v-nameFil,output v-err).
                if v-err <> "" then undo.
                displ v-nameFil with frame f4.
                pause 3.
            end.
            if connected ("txb") then disconnect "txb".
            hide frame f4 no-pause.
        end.

        OPEN QUERY q2_list for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock,
        each b2-txb where b2-txb.bank = b2-treasury.txb no-lock By b2-treasury.txb.
    end.
    /******************************************************************************/
    on choose of bt-del in frame f3
    do:
        GET CURRENT q2_list no-lock.
        if avail b2-treasury then
        do:
            def var v-Pos as inte.
            v-Pos = CURRENT-RESULT-ROW("q2_list").
            if not CheckAccept(b2-treasury.isgo,b2-treasury.cif,b2-treasury.cifgo,b2-treasury.login,b2-treasury.acc) then do:
                run yn("","Удалить выделенную запись ?","","", output rez).
                if rez then
                do:
                    REPOSITION q2_list to ROW v-Pos.
                    GET CURRENT q2_list exclusive-lock.
                    if b2-treasury.isgo = false and b2-treasury.cifgo = GoCif then delete b2-treasury.
                    OPEN QUERY q2_list for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock,
                    each b2-txb where b2-txb.bank = b2-treasury.txb no-lock By b2-treasury.txb.
                end.
            end.
            else message "Удаление невозможно, необходимо снять акцепт в п.м. 1.5.5 !" view-as alert-box buttons ok.
        end.
        else release b2-treasury.
    end.

    /******************************************************************************/
    on choose of bt-close in frame f3
    do:
        hide frame f3 no-pause.
        apply "endkey" to frame f3.
    end.
    /******************************************************************************/
    OPEN QUERY q2_list for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock,
    each b2-txb where b2-txb.bank = b2-treasury.txb no-lock By b2-treasury.txb.
    enable all with frame f3.
    apply "value-changed" to b2_list in frame f3.
    WAIT-FOR "endkey" of frame f3 focus browse b2_list.
end procedure.
/***********************************************************************************************************/

if VALID-OBJECT(Usr) then DELETE OBJECT Usr NO-ERROR.






