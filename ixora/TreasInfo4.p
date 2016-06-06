/* TreasInfo4.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Контроль доступа третьим лицам к счетам Клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.5.5
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM IB
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
{classes.i}
{comm-txb.i}

def var phand as handle.
def var rez as log.

def var CurrTXB as char.
CurrTXB = comm-txb().

/***********************************************************************************************************/
run connib.

run ShowCorpGrp.
/***********************************************************************************************************/

procedure ShowCorpGrp:
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
    with no-labels row 1 column 1 width 104 overlay.

    on "end-error" of frame f1
    do:
        hide all no-pause.
        apply "endkey" to frame f1.
    end.
   /******************************************************************************/
    on "return" of b_list in frame f1
    do:
        if avail b-treasury then
        do:
            run ShowFillGrp(b-treasury.txb,b-treasury.cif,b-treasury.name,b-treasury.acc,b-treasury.login).
        end.
    end.
   /******************************************************************************/
    OPEN QUERY q_list for each b-treasury where b-treasury.txb = CurrTXB and b-treasury.isgo = true no-lock,each b-webra where b-webra.login = b-treasury.login no-lock by b-treasury.txb.
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

    def buffer b-treasury for comm.treasury.
    def buffer b2-treasury for comm.treasury.
    def buffer b2-txb for comm.txb.

    define query q2_list for b2-treasury,b2-txb.
    define browse b2_list query q2_list no-lock
    display
        b2-txb.info column-label "Филиал" format "x(25)"
        b2-treasury.cif column-label "CIF-код" format "x(8)"
        b2-treasury.name column-label "Наименование клиента" format "x(42)"
        b2-treasury.acc column-label "Счет" format "x(20)"
    with 10 down centered overlay width 102 SEPARATORS no-row-markers.

    define frame f3
        b2_list skip  space(28)
        "F1 - Акцепт, F8 - Снять акцепт, F4 - Выход"
    with no-labels row 18 column 1 overlay width 104 title "Состав группы Головной Организации".

    /******************************************************************************/
    on "go" of frame f3 do:
        def var v-GoName as char.
        def var v-FilName as char.
        find first b-treasury where b-treasury.isgo = true and b-treasury.cif = GoCif and b-treasury.login = GoLogin no-lock no-error.
        if avail b-treasury then v-GoName = b-treasury.name.
        for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock:
            if v-FilName <> "" then v-FilName = v-FilName + "~n" + b2-treasury.name.
            else v-FilName = b2-treasury.name.
        end.
        message "Информация об остатках на счетах~n" v-FilName "~nбудет доступна сотруднику~n" v-GoName ".~nПродолжить?" view-as alert-box buttons yes-no title "ВНИМАНИЕ" update rez.
        if rez then
        do:
            find first b-treasury where b-treasury.isgo = true and b-treasury.cif = GoCif and b-treasury.login = GoLogin exclusive-lock no-error.
            if avail b-treasury then do: b-treasury.cwho = g-ofc. b-treasury.cwhn = g-today. end.
            find first b-treasury where b-treasury.isgo = true and b-treasury.cif = GoCif and b-treasury.login = GoLogin no-lock no-error.
            for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin exclusive-lock:
                b2-treasury.cwho = g-ofc. b2-treasury.cwhn = g-today.
            end.
            for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock:
            end.
        end.
    end.
    on "clear" of b2_list in frame f3 do:
        run yn("","Снять акцепт ?","","", output rez).
        if rez then
        do:
            find first b-treasury where b-treasury.isgo = true and b-treasury.cif = GoCif and b-treasury.login = GoLogin exclusive-lock no-error.
            if avail b-treasury then do: b-treasury.cwho = "". b-treasury.cwhn = ?. end.
            find first b-treasury where b-treasury.isgo = true and b-treasury.cif = GoCif and b-treasury.login = GoLogin no-lock no-error.
            for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin exclusive-lock:
                b2-treasury.cwho = "". b2-treasury.cwhn = ?.
            end.
            for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock:
            end.
        end.
    end.
    /******************************************************************************/
    on "end-error" of frame f3 do:
        run yn("","Выйти ?","","", output rez).
        if rez then
        do:
            hide frame f3 no-pause.
            apply "endkey" to frame f3.
        end.
    end.
    /******************************************************************************/
    OPEN QUERY q2_list for each b2-treasury where b2-treasury.isgo = false and b2-treasury.cifgo = GoCif and b2-treasury.login = GoLogin no-lock,
    each b2-txb where b2-txb.bank = b2-treasury.txb no-lock By b2-treasury.txb.
    enable all with frame f3.
    apply "value-changed" to b2_list in frame f3.
    WAIT-FOR "endkey" of frame f3 focus browse b2_list.
end procedure.
/***********************************************************************************************************/

if connected("ib") then disconnect "ib".
