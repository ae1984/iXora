/* checsar.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
       07.10.05 dpuchkov добавил серию чека
       21.10.05 dpuchkov добавил проверку на латинские буквы в серии чека
       4.8.10 marinav - комиссию можно править
       25/04/2012 dmitriy - заблокировал возможность редактирования полей "Цена" и "ПОСЛ.#"
       28/06/2012 dmitriy - добавил поле gram.bank для отличия чековых книжек "метрокомбанка" от "forte"
                          - добавил проверку по всем филиалам: зарегистрирована чековая книжка или нет
*/

/*checsar.p
18.07.95 - jaunu ўeku gr–matas iev–diЅana un frame
*/

{mainhead.i}
def var v1 as integer initial 0000025.
def var v3 as integer initial 25.
def var v2 as integer initial 0000024.
def var ccc like gram.cekcen.
def var pirmno as int.
def var otrno as int.
def var c-non like gram.nono.
def var nnn as int format "9999999".
def var lid as int format "9999999".
def var c-lid like gram.lidzno.
def var ok as int.
def var kk as int.
def var kuku as int.
def var aaa as int.
def var bbb as int.
def var v-ser as char.

def new shared temp-table wrk
field nono as int
field cif as char
field bank as char
field chk as logi.

find first tarif2 where tarif2.str5 = "151" and tarif2.stat = 'r' no-lock.
ccc = tarif2.ost.

repeat:
    nnn = 0. c-non = 0. c-lid = 0.
    update nnn label "НАЧ.#"  with 15 down frame nunu.

    /*проверка правильности введенного 1 - ого номера*/
    aaa = nnn modulo 25.
    if aaa ne 1 or nnn eq 0
    then do:
        bell.
        message "Правильно вводите номер".
        undo, retry.
    end.
    else do:
        lid = nnn + 24.
        display lid label "ПОСЛ.#" with 15 down frame nunu.
        c-lid = lid.
        /*проверка правильности введенного последнего номера*/
        bbb = lid modulo 25.
        if bbb ne 0 or lid eq 0 or lid lt nnn
            then do:
               bell.
               message "Правильно вводите номер".
               undo, retry.
            end.
        else do:
            v-ser = "".
            update v-ser label "Серия" format "x(2)"  validate(v-ser <> "","Введите номер серии") with 15 down frame nunu.
            v-ser = lower(v-ser).

            if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
                message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
            end.
            display ccc label "ЦЕНА" format "zzzz9" with 15 down frame nunu.

            c-non = nnn.
            pirmno = c-non. otrno = c-lid.
            kk = (otrno - pirmno) / v3.
            kuku = kk.
            ok = 1.
        end.
    end.

    {r-branch.i &proc= "checgram2 (nnn, v-ser)"}

    find first wrk where wrk.chk = true no-lock no-error.
    if not available wrk then do:
        do transaction:
            create gram.
            gram.nono = c-non.
            gram.lidzno = c-non + v2.
            gram.cekcen = ccc.
            gram.iendat = g-today.
            gram.ienwho = g-ofc.
            gram.ser = v-ser.
            c-non = c-non + v1.
            gram.bank = "F".
        end.
    end.
    else do:
        message "Чековая книжка с таким номером уже есть в системе. Регистрация: " wrk.bank view-as alert-box title " Внимание ".
        for each wrk no-lock: delete wrk. end.
        undo,retry.
    end.
    ok = 2.


    repeat while ok le kk:

        find first wrk where wrk.chk = true no-lock no-error.
        if not available wrk then do:
            do transaction:
                create gram.
                gram.nono = c-non.
                gram.lidzno = c-non + v2.
                gram.cekcen = ccc.
                gram.iendat = g-today.
                gram.ienwho = g-ofc.
                gram.ser = v-ser.
                ok = ok + 1.
                c-non = c-non + v1.
                gram.bank = "F".
            end.
        end.
        else do:
            bell.
            message "Чековая книжка с таким номером уже есть в системе. Регистрация: " wrk.bank view-as alert-box title " Внимание ".
            up 1 with frame nunu.
            for each wrk no-lock: delete wrk. end.
            undo,retry.
        end.
    end.

    disp kuku label "КОЛ-ВО ЧЕК.КНИЖЕК"
    g-today label "DATUMS" with 15 down frame nunu.
end.

