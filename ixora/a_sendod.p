/* a_sendod.p
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
            05/04/2012 Luiza.
            19/04/2012 Luiza - отменила тип new
*/

{yes-no.i}
{global.i}
    def var str_p as char.
    DEFINE QUERY q2 FOR sendod .

    define buffer buf for sendod.

    def browse b2
         query q2
         displ
         sendod.ofc label "  " format "x(25)"
         with 7 down width 50 title "id сотруд ОД для рассылки сообщений о контроле докум" overlay.

    define frame getlist1
    sendod.ofc label "Логин офицера" help " F2 - Поиск логина"  skip
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
          find buf where rowid (buf) = rowid (sendod) exclusive-lock.
          delete buf.
          close query q2.
          open query q2 for each sendod where sendod.typ = "".
          browse b2:refresh().
       end.
    end.

       ON CHOOSE OF bnew IN FRAME fr2
    do:
       create sendod.
       sendod.typ = "".
       sendod.who = g-ofc.
       sendod.whn = g-today.
       update sendod.ofc with frame getlist1.

       close query q2.
       open query q2 for each sendod where sendod.typ = "".
       browse b2:refresh().
    end.

    open query q2 for each sendod where sendod.typ = "".

    b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

    ENABLE all with frame fr2 centered overlay top-only.

    apply "value-changed" to b2 in frame fr2.

    WAIT-FOR WINDOW-CLOSE of frame fr2.

    hide frame fr2.

