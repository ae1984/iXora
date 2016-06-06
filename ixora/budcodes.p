/* budcodes.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * BASES
          BANK COMM TXB
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
        09/04/04 recompile only
        13/07/05 kanat - добавил имена таблиц при выводе ее полей в displ
	    04/06/09 id00363 - добавил синхронизацию с филиалами
        23.07.2010 marina - увеличено поле наименование
        26/05/2011 dmitriy - добавил вывод в Word и Excel
                           - запретил редактирование всем, кроем ЦО

*/



def var s-ourbank as char no-undo.
find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.

s-ourbank = trim(bank.sysc.chval).

def var rid as rowid.
def var v-all     as log.
def var v-ofc as char no-undo.
def var str-ul as char.

DEFINE QUERY q1 FOR bank.budcodes.




def browse b1
    query q1 no-lock
    display
        budcodes.code  label "Код БК"
        budcodes.name  format "x(50)" label "Наименование"
        budcodes.hand  label "РР"
        budcodes.ul    no-label
        with 14 down title "Коды БК".

DEFINE BUTTON bedt LABEL "Просмотр".
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bext LABEL "Выход".
DEFINE BUTTON bword LABEL "Word".
DEFINE BUTTON bexcel LABEL "Excel".

def frame f1
    b1
    skip
    space(10)
    bedt
    bnew
    bdel
    bword
    bexcel.


ON CHOOSE OF bedt IN FRAME f1
    do:
        if s-ourbank <> "txb00" then leave.
        else do:

            rid = rowid(bank.budcodes).
            find current bank.budcodes share-lock.
            update
                budcodes.code  label "Код БК"
                budcodes.name  format "x(80)" label "Наименование"
                budcodes.name1 format "x(80)" label "Наименование"
                budcodes.hand  label "Ручное рапред."
                budcodes.ul    label "Физ/Юр лицаOS"
                s-perc label "% Респ. бюджет"
                p-perc label "% Местн. бюджет"
            with centered 1 column side-labels width 100 frame edit-frame.
            release budcodes.
            open query q1 for each budcodes no-lock.
            reposition q1 to rowid rid.
            b1:select-row(CURRENT-RESULT-ROW("q1")).
            b1:refresh().
        end.
    end.
ON CHOOSE OF bnew IN FRAME f1
    do:
        if s-ourbank <> "txb00" then leave.
        else do:
            create bank.budcodes.
            rid = rowid(bank.budcodes).
            update
                budcodes.code  label "Код БК"
                budcodes.name  format "x(80)" label "Наименование"
                budcodes.name1 format "x(80)" label "Наименование"
                budcodes.hand  label "Ручное рапред."
                s-perc label "% Респ. бюджет"
                p-perc label "% Местн. бюджет"
            with 1 column side-labels width 100 frame edit-frame.
            open query q1 for each budcodes no-lock.
            reposition q1 to rowid rid.
            b1:select-row(CURRENT-RESULT-ROW("q1")).
        end.
    end.
ON CHOOSE OF bdel IN FRAME f1
    do:
       if s-ourbank <> "txb00" then leave.
       else do:
           MESSAGE "Удалить?"
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
           TITLE "Код БК" UPDATE choice as logical.
           case choice:
              when true then do:
                rid = rowid(bank.budcodes).
                FIND bank.budcodes WHERE ROWID(bank.budcodes) = rid EXCLUSIVE-LOCK.
                delete budcodes.
                open query q1 for each budcodes no-lock.
              end.
           end case.
       end.
    end.

on END-ERROR of frame f1
do:
	if s-ourbank = "txb00" then do:
           v-all = no.
           message "Производить изменения в Справочнике кодов бюджета по всем филиалам?" view-as alert-box question buttons yes-no title "" update v-all.
           if v-all then do:
              displ " Синхронизация Справочника кодов бюджета с филиалами... " with no-label row 7 centered frame vmess.
	          /*run pack_sync(v-ofc).*/
	          {r-branch.i &proc = "budcodes-txb"}
	          hide frame vmess.
           end.
	end.
end.


{yes-no.i}
ON CHOOSE OF bword IN FRAME f1
    do:
               if yes-no ('', 'Вы действительно хотите вывести данные в Word ?') then do:
                     output to vcdata.img .
                     displ space(35) 'КОДЫ БК' skip(1).
                     displ 'КОД БК' ' '
                           'НАИМЕНОВАНИЕ' space(41).

                     put fill('=',73) format 'x(73)' skip.
                     for each bank.budcodes no-lock:
                          if length(bank.budcodes.name) <= 63 then
                             put unformatted
                             string(bank.budcodes.code) format "x(6)" '   '
                             bank.budcodes.name format "x(63)"
                             skip.
                          else
                             put unformatted
                             bank.budcodes.code '   '
                             substr(bank.budcodes.name,1,63) '-' skip
                             space(9) trim(substr(bank.budcodes.name,64,16)) format "x(63)"
                             skip.
                      end.
                     output close.
                     unix silent cptwin vcdata.img winword.
               end.
    end.

ON CHOOSE OF bexcel IN FRAME f1
    do:
               if yes-no ('', 'Вы действительно хотите вывести данные в Excel ?') then do:
                     output to vcdata.csv.
                     displ 'КОДЫ БК' skip(1).
                     displ 'КОД БК' ';'
                           'НАИМЕНОВАНИЕ'.
                     put fill('=',75) format 'x(75)' skip.
                     for each bank.budcodes no-lock:
                          if bank.budcodes.ul = yes then str-ul = 'ю.л.'.
                          else str-ul = 'ф.л.'.
                          put unformatted '''' + string(bank.budcodes.code) ';' bank.budcodes.name skip.
                      end.
                     output close.
                     unix silent cptwin vcdata.csv excel.
               end.

    end.

open query q1 for each budcodes no-lock.
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.





