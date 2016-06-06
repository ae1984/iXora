  /* csofc.p
 * MODULE
        Электронный кассир
 * DESCRIPTION
        Привязка менеджера к ЭК
 * BASES
          BANK COMM
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
        25.02.2011 marinav
 * CHANGES
        10/02/2012  Luiza - добавила проверки на привязки к ЭК
        17.02.2012 k.gitalov изменение алгоритма
        09.11.2012 k.gitalov Перекомпиляция
*/


{global.i}

{cm18_abs.i}

def var i as int.

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var rid as rowid.
def var v-side as char.
def var v-nom as char.
def var v-men as char.
def var v-name as char.
def var v-ans as logic format "да/нет".
def var v-sel as char.



DEFINE QUERY q_cslist FOR cslist.
DEFINE BROWSE b-cslist QUERY q_cslist
       DISPLAY cslist.nomer label "ЭК " format "x(7)" cslist.des label "Описание" WITH  10 DOWN.
DEFINE FRAME f-cslist b-cslist  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 33 width 45 NO-BOX.


def buffer csofc for csofc.
DEFINE QUERY q-csofc FOR csofc , cslist.


def browse b-csofc
    query q-csofc no-lock
    display
        csofc.nomer label "ЭК" format "x(7)"
        csofc.ofc label "Менеджер"
        csofc.info[1] label "ФИО " format "x(35)"
    with  15  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .
DEFINE FRAME MainFrame b-csofc skip space(7) "<INS>-Создать,  <DEL>-Удалить,  <F4> Выход"
WITH SIDE-LABELS centered /*overlay*/ row 5 WIDTH 60 title "Список Менеджеров, работающих с Электронным кассиром".

form
    v-nom label  " ЭК         " skip
    v-men label  " Менеджер   " validate(can-find(first ofc where ofc.ofc = v-men no-lock),"Неверный логин!") help " Введите логин " skip
    v-name label " ФИО        " format "x(35)" skip
    v-ans label  " Добавить новую запись " skip
WITH  SIDE-LABELS centered  row 9 TITLE "Новая запись" width 60 FRAME f_main.



ON "insert" OF b-csofc IN FRAME MainFrame do:
    OPEN QUERY  q_cslist FOR EACH cslist where cslist.bank = s-ourbank no-lock.
    ENABLE ALL WITH FRAME f-cslist.
    wait-for return of frame f-cslist
    FOCUS b-cslist IN FRAME f-cslist.
    v-nom = cslist.nomer.
    hide frame f-cslist.

    def var i as int.
    i = 0.
    for each csofc where csofc.nomer  = v-nom no-lock.
        i = i + 1.
    end.
    if i >= 2 then do:
        message "К ЭК " v-nom " уже привязаны два менеджера!~n Вначале удалите запись! " VIEW-AS ALERT-BOX.
        return.
    end.

    displ v-nom with frame f_main.

    update v-men with frame f_main.

    find first ofc where ofc.ofc = v-men no-lock no-error.
    v-name = ofc.name.


    find first csofc where csofc.ofc = v-men /*and csofc.nomer = v-nom*/ no-lock no-error.
    if avail csofc then do:
       message "Менеджер " v-name "уже привязан к ЭК" csofc.nomer VIEW-AS ALERT-BOX.
       return.
    end.

    displ v-name with frame f_main.

    v-ans = yes.
    update v-ans with frame f_main.
    if not v-ans then return.
    hide frame f_main no-pause.
    create csofc.
    csofc.nomer = v-nom.
    csofc.ofc = v-men.
    csofc.info[1] = v-name.
    csofc.who = g-ofc.
    csofc.whn = g-today.
    rid = rowid(csofc).
    hide frame f2.
    pause 0.
    open query q-csofc for each csofc no-lock  , each cslist where cslist.bank = s-ourbank and cslist.nomer = csofc.nomer   no-lock by csofc.nomer.
    reposition q-csofc to rowid rid.
    b-csofc:select-row(CURRENT-RESULT-ROW("q-csofc")).
END.

ON "delete" OF b-csofc IN FRAME MainFrame DO:

 if GetCashOfc("KZT",csofc.ofc,g-today) > 0 or
    GetCashOfc("USD",csofc.ofc,g-today) > 0 or
    GetCashOfc("EUR",csofc.ofc,g-today) > 0 or
    GetCashOfc("RUB",csofc.ofc,g-today) > 0 then do:
        message "Темпокасса:~n"
        "KZT:" + string(GetCashOfc("KZT",csofc.ofc,g-today),">>>,>>>,>>9.99-") + "~n" +
        "USD:" + string(GetCashOfc("USD",csofc.ofc,g-today),">>>,>>>,>>9.99-") + "~n" +
        "EUR:" + string(GetCashOfc("EUR",csofc.ofc,g-today),">>>,>>>,>>9.99-") + "~n" +
        "RUB:" + string(GetCashOfc("RUB",csofc.ofc,g-today),">>>,>>>,>>9.99-") + "~n"
        view-as alert-box title "Запрет удаления!".
        return.
 end.

    MESSAGE skip "УДАЛИТЬ менеджера из списка ?" skip VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO  TITLE "Список менеджеров" UPDATE choice as logical.
        case choice:
          when true then do:
            rid = rowid(csofc).
            FIND csofc WHERE ROWID(csofc) = rid EXCLUSIVE-LOCK.
            delete csofc.
            open query q-csofc for each  csofc no-lock, each cslist where cslist.bank = s-ourbank and cslist.nomer = csofc.nomer   no-lock by csofc.nomer.
          end.
        end case.
END.

ON END-ERROR OF b-csofc in frame MainFrame
    DO:
      apply "endkey" to frame MainFrame.
      hide frame MainFrame.
END.

open query q-csofc for each csofc no-lock, each cslist where cslist.bank = s-ourbank and cslist.nomer = csofc.nomer   no-lock by csofc.nomer.
ENABLE all WITH centered FRAME MainFrame.
b-csofc:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b-csofc.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
