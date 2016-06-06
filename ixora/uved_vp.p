/* uved_vp.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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

 * BASES
        BANK COMM
 * CHANGES
            03/05/2012 Luiza.
*/

{yes-no.i}
{global.i}
def var v-ek as int.
run sel2 ("Выберите :", " 1. Список рассылки | 2. Лимиты по валютам | 3. Выход ", output v-ek).
if keyfunction (lastkey) = "end-error" then return.
if (v-ek < 1) or (v-ek > 2) then return.
if v-ek = 1 then run sr.
else run lv.

procedure sr:
    def var str_p as char.
    DEFINE QUERY q2 FOR ofcsend1 .

    define buffer buf for ofcsend1.

    def browse b2
         query q2
         displ
         ofcsend1.ofc label "  " format "x(25)"
         with 7 down title "id сотрудников для рассылки" overlay.

    define frame getlist1
    ofcsend1.ofc label "Логин офицера" help " F2 - Поиск логина"  skip
    with side-labels centered row 8.

    DEFINE BUTTON bnew LABEL "Создать".
    DEFINE BUTTON bdel LABEL "Удалить".
    DEFINE BUTTON bext LABEL "Выход".

    def frame fr2
         b2
         skip
         bnew
         bdel
         bext with centered overlay row 5 top-only.


    ON CHOOSE OF bext IN FRAME fr2
    do:
       hide frame getlist1.
       APPLY "WINDOW-CLOSE" TO BROWSE b2.
    end.

    ON CHOOSE OF bdel IN FRAME fr2
    do:
       if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
       then do:
          find buf where rowid (buf) = rowid (ofcsend1) exclusive-lock.
          delete buf.
          close query q2.
          open query q2 for each ofcsend1.
          browse b2:refresh().
       end.
    end.

       ON CHOOSE OF bnew IN FRAME fr2
    do:
       create ofcsend1.
       ofcsend1.typ = "".
       ofcsend1.who = g-ofc.
       ofcsend1.whn = g-today.
       update ofcsend1.ofc with frame getlist1.

       close query q2.
       open query q2 for each ofcsend1.
       browse b2:refresh().
    end.

    open query q2 for each ofcsend1.

    b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

    ENABLE all with frame fr2 centered overlay top-only.

    apply "value-changed" to b2 in frame fr2.

    WAIT-FOR WINDOW-CLOSE of frame fr2.

    hide frame fr2.

end procedure.

procedure lv:
    def var rid as rowid.

    for each crc where crc.crc > 0 and crc.sts <> 9 no-lock.
        find first crclim where crclim.crc = crc.crc no-lock no-error.
        if not available crclim then do:
            create crclim.
            crclim.crc = crc.crc.
            crclim.ccod = crc.code.
        end.
    end.

    DEFINE QUERY q1 FOR crclim .
    def browse b1
        query q1 no-lock
        display
            crclim.ccod label "Валюта"
            crclim.lim   label "Лимит"
            with 7 down title "Лимиты по валютам" overlay.

    def frame f1 b1  help "<Enter>-Редак-ть,  <F4> Выход" with row 5 .

    ON "return" OF b1 IN FRAME f1
        do:
            b1:set-repositioned-row(b1:focused-row, "conditional").
            rid = rowid(crclim).
            find current crclim share-lock.
                 displ /*crclim.ccod*/ crclim.lim format '->>>>>>>>>>>9.99' with no-label overlay row b1:focused-row + 8 column 49 no-box frame f2.
                 update crclim.lim  with  frame f2.
                 crclim.who = g-ofc.
                 crclim.whn = g-today.
            release crclim.
            hide frame f2.
            open query q1 for each crclim no-lock.
            reposition q1 to rowid rid.
            b1:select-row(CURRENT-RESULT-ROW("q1")).
            b1:refresh().
        end.

    open query q1 for each crclim no-lock.
    ENABLE all WITH centered FRAME f1.
    b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
    APPLY "VALUE-CHANGED" TO BROWSE b1.
    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

end procedure.