/* x-cash0.f
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        18.05.2004 nadejda - добавлено сообщение vcha16
        11.07.2005 dpuchkov- добавил формирование корешка
        14.07.2005 dpuchkov- добавил печать кассового ордера по клавише TAB
        02.08.2005 dpuchkov- добавил формирование корешка для РКО-шек
        14/09/2011 dmitriy - добавил вывод на экран проводок по филиалу (кроме ЦО) по приходу или расходу
        28/09/2011 dmitriy - добавил фрэйм ххх для отображения данных по выбранной проводке
        10/11/2011 dmitriy - изменил алгоритм поиска проводок по СП
        28/11/2011 dmitriy - прописал формат для fr1
        29/11/2011 dmitriy - width для fr1 = 100
        30/11/2011 lyubov - переход на ИИН/БИН (изменяется надпись на формах)
        09/02/2012 dmitriy - v-pass = joudoc.passp + string(joudoc.passpdt).
        11/03/2012 dmitiry - v-pass
*/

vcha1 = " Счет : ".
vcha2 = " Клиент  : ".
vcha3 = " Статус не 5 !!!! ".
vcha4 = "выплата    :".
vcha5 = "прием :".
vcha6 = " Итого ".
vcha7 = " Штамповать?" .
vcha8 = "Выплата по чеку Nr.".
vcha9 = 'Исполнить?'.
vcha10 = "Конвертировать ?".
vcha15 = "Взнос :".
vcha16 = " Проводка не кассовая!".            /*
vcha11 = "ATLIKUMS IEMAKSAI ".
vcha12 = "ATLIKUMS IZMAKSAI ". */


form  "                   ВНИМАНИЕ  " skip
      "            КАССОВАЯ ПРОВОДКА В ЖУРНАЛЕ    "
       with   row 10  centered  frame tur.

def var v-log as log init true format "Да/Нет".
def var v-yes as log initial true format "Да/Нет".

form  " Номер проводки :"
    p-pjh
    with centered no-label frame qqq.


def var v-choice as integer format '9' init 1.
def var v-pnt like point.point.
def var v-ofcdep like ofc.dpt.
def var v-ofcreg like ofc.regno.

 find ofc where ofc.ofc = g-ofc no-lock no-error.
 if avail ofc then do:
    v-ofcdep = ofc.dpt.
    v-ofcreg = ofc.regno.
 end.

/*------- dmitriy -------*/

def var v-cifname as char.
def var v-pass    as char.
def var v-rnn     as char.
def var v-prihod  as char.
def var v-rec     as logi.
def var punum like point.point.
def var v-crc like crc.code.
def var v-depart as int.

define temp-table jh-trx
    field jh like jh.jh
    field sum as deci
    field crc as char
    field cifname as char
    field jl-for as char
    field rnn as char
    field pass as char.

define frame xxx
    jh-trx.jl-for  format "x(60)" label "Назначение " skip skip
    jh-trx.cifname format "x(60)" label "Получил " skip
    jh-trx.pass    format "x(60)" label "Паспорт " skip
    jh-trx.rnn     format "x(60)" label "РНН     "
with side-labels centered row 25.

define frame xx1
    jh-trx.jl-for  format "x(60)" label "Назначение " skip skip
    jh-trx.cifname format "x(60)" label "Получил " skip
    jh-trx.pass    format "x(60)" label "Паспорт " skip
    jh-trx.rnn     format "x(60)" label "ИИН     "
with side-labels centered row 25.

define frame sp
    v-depart  format "99" label "Выберите СП "
with side-labels centered row 15.

if comm-txb() <> "txb00" then do:
    on help of p-pjh in frame qqq do:
        hide frame qnum.
        message "1)Приход     2)Расход "
        update v-choice.

        if v-choice <> 1 and v-choice <> 2 then do:
            message "Значение должно быть 1 или 2".
            pause 5.
        end.

        update v-depart with frame sp.
        hide frame sp.

        find ofc where ofc.ofc = g-ofc no-lock no-error.
        if available ofc then do :
           punum =  ofc.regno / 1000 - 0.5 .
        end.

        if v-choice = 1 then do:    /*Приход*/
            v-rec = false.
            message "Ждите идет поиск транзакций".
            find sysc where sysc.sysc = "CASHGL" no-lock no-error.
            if available sysc then do:

                find first jl where jl.jdt = g-today no-lock no-error.
                if avail jl then do:
                     for each jl  where jl.jdt = g-today no-lock:
                        find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.
                        if ofchis.depart = v-depart then do:
                            if jl.gl = sysc.inval and jl.dam > 0 then do :
                                find jh where jh.jh = jl.jh no-lock no-error.
                                if available jh and jh.sts < 6 then do:
                                        v-rec = true.
                                        v-cifname = "".
                                        v-pass = "".
                                        v-rnn = "".
                                        v-crc = "".
                                            if jh.sub = 'jou' then do:
                                                find first joudoc where joudoc.docnum = jh.ref /*joudoc.jh = jh.jh*/ no-lock no-error.
                                                if avail joudoc then do:
                                                    v-cifname = joudoc.info.
                                                    if string(joudoc.passpdt) = ? then
                                                        v-pass = joudoc.passp.
                                                    else
                                                        v-pass = joudoc.passp + " " + string(joudoc.passpdt).
                                                    v-rnn = joudoc.perkod.
                                                end.
                                            end.
                                            if jh.sub = 'rmz' then do:
                                                find first remtrz  where remtrz.remtrz = jh.ref /*remtrz.jh1 = jh.jh*/ no-lock no-error.
                                                if avail remtrz then do:
                                                    v-cifname = entry(1, remtrz.ord, "/").
                                                    if length(v-cifname) > 1 then do:
                                                        v-pass = "" /*remtrz.bn[2]*/.
                                                        v-rnn = substr(remtrz.ord, length(v-cifname)).
                                                        if length(v-rnn) < 12 then v-rnn = " ".
                                                    end.
                                                    else do:
                                                        v-pass = " ".
                                                        v-rnn = " ".
                                                    end.
                                                end.
                                            end.

                                        find first crc where crc.crc = jl.crc no-lock no-error.
                                        if avail crc then v-crc = crc.code.
                                        else v-crc = ''.

                                        create jh-trx.
                                        jh-trx.jh = jh.jh.
                                        jh-trx.sum = jl.dam.
                                        jh-trx.crc = v-crc.
                                        jh-trx.cifname = v-cifname.
                                        jh-trx.jl-for = jl.rem[1] + jl.rem[2].
                                        jh-trx.rnn = v-rnn.
                                        jh-trx.pass = v-pass.
                                end. /*jh*/
                            end. /*jl.gl*/
                        end. /*ofchis*/
                     end. /*for each jl*/
                end. /*if avail jl*/
            end. /*sysc*/
        end. /* choise 1 */

        if v-choice = 2 then do:    /*Расход*/
            v-rec = false.
            message "Ждите идет поиск транзакций".
            find ofc where ofc.ofc = g-ofc no-lock no-error.
            if available ofc then do :
               punum =  ofc.regno / 1000 - 0.5 .
            end.

            find sysc where sysc.sysc = "CASHGL" no-lock no-error.
            if available sysc then do:

                find first jl where jl.jdt = g-today no-lock no-error.
                if avail jl then do:
                 for each jl  where jl.jdt = g-today no-lock:
                    find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.
                    if ofchis.depart = v-depart then do:
                        if jl.gl = sysc.inval and jl.cam > 0 then do :
                            find jh where jh.jh = jl.jh no-lock no-error.
                            if available jh and jh.sts < 6 then do:
                                    v-rec = true.
                                    v-cifname = "".
                                    v-pass = "".
                                    v-rnn = "".
                                    v-crc = "".
                                    if jh.sub = 'jou' then do:
                                        find first joudoc where joudoc.docnum = jh.ref /*joudoc.jh = jh.jh*/ no-lock no-error.
                                        if avail joudoc then do:
                                            v-cifname = joudoc.info.
                                            if string(joudoc.passpdt) = ? then
                                                v-pass = joudoc.passp.
                                            else
                                                v-pass = joudoc.passp + " " + string(joudoc.passpdt).
                                            v-rnn = joudoc.perkod.
                                        end.
                                    end.
                                    if jh.sub = 'rmz' then do:
                                        find first remtrz  where remtrz.remtrz = jh.ref /*remtrz.jh1 = jh.jh*/ no-lock no-error.
                                        if avail remtrz then do:
                                            v-cifname = entry(1, remtrz.ord, "/").
                                            if length(v-cifname) > 1 then do:
                                                v-pass = "" /*remtrz.bn[2]*/.
                                                v-rnn = substr(remtrz.ord, length(v-cifname)).
                                                if length(v-rnn) < 12 then v-rnn = " ".
                                            end.
                                            else do:
                                                v-pass = " ".
                                                v-rnn = " ".
                                            end.
                                        end.
                                    end.

                                    find first crc where crc.crc = jl.crc no-lock no-error.
                                    if avail crc then v-crc = crc.code.
                                    else v-crc = ''.

                                    create jh-trx.
                                    jh-trx.jh = jh.jh.
                                    jh-trx.sum = jl.cam.
                                    jh-trx.crc = v-crc.
                                    jh-trx.cifname = v-cifname.
                                    jh-trx.jl-for = jl.rem[1] + jl.rem[2].
                                    jh-trx.rnn = v-rnn.
                                    jh-trx.pass = v-pass.
                            end.
                        end.
                    end. /*ofchid*/
                end.
                end.
            end. /*sysc*/
        end. /* choise 2 */

        if (v-choice = 1 or v-choice = 2) and v-rec = false then do:
            pause 0.
            message 'Транзакции не найдены' .
            pause 5.
        end.

        if (v-choice = 1 or v-choice = 2) and v-rec = true then do:

            find first cmp no-lock.

            if v-choice = 1 then v-prihod = 'ПРИХОД'.
            if v-choice = 2 then v-prihod = 'РАСХОД'.

            def query q1 for jh-trx.

            def browse b1
            query q1 no-lock
            display
                jh-trx.jh         label  'Транзакция' format ">999999"
                jh-trx.sum        label  'Сумма' format ">>>,>>>,>>>,>>9.99"
                jh-trx.crc        label  'Вал.'  format "x(3)"
                jh-trx.cifname    label  'Ф.И.О. клиента' format "x(50)"
                with 5 down title "Список транзакций" .

            def frame fr1
                b1
                with no-labels centered overlay view-as dialog-box width 100.

            open query q1 for each jh-trx.
            message "". pause 0.
            b1:title = 'Список транзакций (' + v-prihod + ') - ' + cmp.name.
            b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
            ENABLE all with frame fr1 width 100.

            if v-bin = no then display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xxx.
            else display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xx1.

            apply "value-changed" to b1 in frame fr1.
            on up of b1 in frame fr1 do:
                GET PREV q1.
                if avail jh-trx then do:
                if v-bin = no then display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xxx.
                else display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xx1.
                end.

            end.
            on down of b1 in frame fr1 do:
                GET NEXT q1.
                if avail jh-trx then do:
                if v-bin = no then display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xxx.
                else display jh-trx.jl-for jh-trx.cifname jh-trx.pass jh-trx.rnn with frame xx1.
                end.

            end.

            WAIT-FOR RETURN of frame fr1.
            hide frame fr1.
            hide frame xxx.
            p-pjh = integer(string(jh-trx.jh)).
            v-pass = jh-trx.pass.
            v-rnn = jh-trx.rnn.
            v-cifname = jh-trx.cifname.
            for each jh-trx no-lock:
                delete jh-trx.
            end.
            displ p-pjh with frame qqq.
        end.
    end. /* on-help */
end. /* <> txb00 */

/*-----------------------*/

if comm-txb() = "txb00" then do: /*Только Алматы ЦО*/
def var p-num as char format "x(20)".
def var str_p as char.
/*def var v-pnt like point.point.*/
def var i-ind as integer.
form  " Индивидуальный номер :" p-num validate(p-num <> "", "Введите индивидуальный номер")  with centered no-label frame qnum.
define temp-table jhmen
    field num as int
    field itm as char.


    on help of p-num in frame qnum do:
               message "Ждите идет поиск корешков".
               def query q2 for acheck.
               def browse b2
                   query q2 no-lock
                   display
                       acheck.num label ' ' format "x(40)"
                       with 5 down title "Список корешков транзакций" .
               def frame fr2
                   b2
                   with no-labels centered overlay view-as dialog-box.

        on return of b2 in frame fr2
        do:
            apply "endkey" to frame fr2.
        end.


               open query q2 for each acheck where acheck.dt = g-today .
               message "". pause 0.
               b2:title = "Cписок корешков транзакций ".
               b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
               ENABLE all with frame fr2.
               apply "value-changed" to b2 in frame fr2.
               WAIT-FOR endkey of frame fr2.
               hide frame fr2.

               p-num = acheck.num.
               displ p-num with frame qnum.
    end.




/*    on "TAB" of p-pjh in frame qqq do:
           def buffer bx1-jh for jh .
           find last bx1-jh where bx1-jh.jh = p-pjh no-lock no-error.
           if avail bx1-jh then do:
              s-jh = integer(p-pjh).
              run vou_bankcas(0).
           end.
           else message "Транзакция не найдена".
    end. */



    on help of p-pjh in frame qqq do:
        hide frame qnum.
        message
        "1)ВСЕ ТРАНЗАКЦИИ     2)ПОИСК ПО ИНДИВИДУАЛЬНОМУ НОМЕРУ "

        update v-choice.

        if v-choice = 1 then do:
           message "Ждите идет поиск транзакций".
           def query q1 for jhmen.
           def browse b1
               query q1 no-lock
               display
                   jhmen.itm label ' ' format "x(40)"
                   with 5 down title "Список транзакций ЦО" .
           def frame fr1
               b1
               with no-labels centered overlay view-as dialog-box.

on return of b1 in frame fr1
    do:
        apply "endkey" to frame fr1.
    end.

           find ofc where ofc.ofc = g-ofc no-lock no-error.
           if available ofc then do: v-pnt =  ofc.regno mod 1000.  end.
           find sysc where sysc.sysc = "CASHGL" no-lock.
           str_p = "".


           for each jh where jh.jdt = g-today and jh.point = v-pnt and jh.sts = 5 no-lock:
              find first jl where jl.jh = jh.jh no-lock no-error.
              if available jl then do:
                 if jl.gl = sysc.inval then do:
                                create jhmen.
                                assign jhmen.itm = string(jh.jh).
                 end.
              end.
           end.


           open query q1 for each jhmen.
           message "". pause 0.
           b1:title = "Cписок транзакций ЦО".
           b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
           ENABLE all with frame fr1.
           apply "value-changed" to b1 in frame fr1.
           WAIT-FOR endkey of frame fr1.
           hide frame fr1.

           p-pjh = integer(string(jhmen.itm)).
           displ p-pjh with frame qqq.

        end. else
        do:
           update p-num  with frame qnum.
           hide frame qnum.
           find last acheck where acheck.num = p-num and acheck.dt = g-today no-lock no-error.
           if avail acheck then do:
              p-pjh = integer(acheck.jh).
              displ p-pjh with frame qqq.
           end.
           else do:
              p-pjh = 0.
              displ p-pjh with frame qqq.
           end.
        end.
    end.
end.

