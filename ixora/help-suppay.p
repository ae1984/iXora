/* help-suppay.p

 * MODULE

 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        15/04/2009 id00205
 * CHANGES
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.

*/
def input param SP as SUPPCOMClass.
def input param typ as char.

if not VALID-OBJECT(SP)  then do: message "Объект не инициализирован!" view-as alert-box. return. end.
if typ = "" then do: message "Тип не может быть пустым!" view-as alert-box. return. end.

def shared var g-lang as char.
def var v-crec as recid.
def var v-mask as char init '**'.
def var v-TypeSupp as char.

if typ = "pay" then do:
    v-TypeSupp = '2,3,5'.

    {jabro.i
        &head       = "comm.suppcom"
        &formname   = "help-suppay"
        &framename  = "F_Supp"
        &where      = "comm.suppcom.txb = SP:txb and lookup(string(comm.suppcom.type),v-TypeSupp) > 0 and comm.suppcom.name matches v-mask"
        &display    = "comm.suppcom.name comm.suppcom.knp"
        &highlight  = "comm.suppcom.name comm.suppcom.knp"
        &prechoose  = "message 'F - поиск по наименованию провайдера'."
        &postkey    = "else if keyfunction(lastkey) = 'F' or keyfunction(lastkey) = 'А' then do:
                          v-mask = ''.
                          update v-mask no-label format 'x(30)' with centered row 5 title 'Введите' frame F_mask.
                          v-mask = '*' + v-mask + '*'.
                          clin = 0. hide frame F_mask.
                          next upper.
                       end.
                       else if keyfunction(lastkey) = 'return' then do:
                          v-crec = recid(comm.suppcom).
                          hide message.
                          leave upper.
                       end."
        &index      = "nam_ind"
        &addcon     = "false"
        &deletecon  = "false"
        &end        = "hide frame F_Supp.
                       hide frame F_mask."
    }
    find first comm.suppcom where recid(comm.suppcom) = v-crec no-lock no-error.
    if avail comm.suppcom then SP:Find-First("supp_id = " + string(comm.suppcom.supp_id)).
end.
else do:
    define query q_list for comm.suppcom.
    define browse b_list query q_list no-lock
    display comm.suppcom.name label "Наименование" comm.suppcom.knp label "КНП"
    with title "Выбор поставщика услуг" 10 down centered overlay  /*NO-ASSIGN SEPARATORS*/ no-row-markers.

    define frame f1 b_list with no-labels centered overlay view-as dialog-box.

    on return of b_list in frame f1
    do:
        apply "endkey" to frame f1.
        if avail comm.suppcom then SP:Find-First("supp_id = " + string(comm.suppcom.supp_id) ).
    end.
    /******************************************************************************/
    if typ = "no_tax" then do:
    if SP:minsum > 0 then open query q_list for each comm.suppcom where comm.suppcom.txb = SP:txb and comm.suppcom.type = 4 and comm.suppcom.minsum <= SP:minsum no-lock. /* без комиссии*/
    else open query q_list for each comm.suppcom where comm.suppcom.txb = SP:txb and comm.suppcom.type = 4 no-lock. /* для comlist4*/
    end.
    if typ = "reg" then open query q_list for each comm.suppcom where comm.suppcom.txb = SP:txb and comm.suppcom.type >= 0 no-lock BY comm.suppcom.type.

    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey of frame f1.
    hide frame f1.
end.





