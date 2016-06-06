/* pkbad.p
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
        18.10.2004 tsoy добавил кнопки отчет и фильтр
        01/06/2006 madiyar редактировать/удалять данные может только пользователь с правами директора/ст.менеджера ДПК (пакет p00027)
        02/06/2006 madiyar редактировать/удалять данные может только пользователь с выданными правами
                           права выдавать может только пользователь с пакетом p00027 (директор/ст.менеджер ДПК), кнопка bacc
*/

/* pkbad.p Потребкредиты
   Черный список - просмотр, загрузка, удаление

   09.04.2003 nadejda
*/

{mainhead.i}
{pk.i new}

def var v-pperm_main as char init "p00027". /* юзер/пакет ЦО, имеющий право давать доступы другим юзерам/пакетам */

def var v-rid as rowid.
def var i as integer.
def var v-ans as logical.
def stream r-lst.

def var v-fio as char.
def var v-rnn as char.
def var v-permed as char.

def frame f-param
    v-fio label " ФИО " format "x(25)"  skip
    v-rnn label " РНН " format "x(12)" 
  with centered overlay row 7 side-labels title " ПАРАМЕТРЫ ОТБОРА СПИСКА ДОЛЖНИКОВ ".

def temp-table t-badlst like pkbadlst
  field n as integer format ">>>9"
  field sort as char 
  field name as char format "x(50)"
  field strdt as char format "x(10)"
  field rid as char format "x(20)"
  index main sort.

/* функция проверки на наличие прав на редактирование/удаление */
function chkperm returns logical (usr as char, pperm as char).
    def var v-res as logical init no.
    def var j as integer.
    if pperm = '' then do:
      find first pksysc where pksysc.credtype = '6' and pksysc.sysc = 'badprm' no-lock no-error.
      if avail pksysc then pperm = pksysc.chval.
    end.
    find first ofc where ofc.ofc = usr no-lock no-error.
    if avail ofc then do:
      if lookup(usr,pperm) > 0 then v-res = yes.
      else do:
        do j = 1 to num-entries(ofc.expr[1]):
          if lookup(entry(j,ofc.expr[1]),pperm) > 0 then do: v-res = yes. leave. end.
        end. /* do j = 1 */
      end.
    end.
    return v-res.
end.


run dolst.

DEFINE QUERY q1 FOR t-badlst.

def browse b1 
    query q1 no-lock 
    display 
        t-badlst.n      label " N "
        t-badlst.rnn    label "РНН" format "x(12)" 
        t-badlst.name   label "ФИО" format "x(32)"
        t-badlst.strdt  label "ДАТА РОЖД"
        t-badlst.docnum label "УДОСТ"
        with 12 down title "" no-labels. 

DEFINE BUTTON bedt  LABEL "Просм/Измен".
DEFINE BUTTON bnew  LABEL "Новый".
DEFINE BUTTON bimp  LABEL "Импорт".
DEFINE BUTTON bdel  LABEL "Удалить".
DEFINE BUTTON bprt  LABEL "Печать".
DEFINE BUTTON brpo  LABEL "Отчет".
DEFINE BUTTON bflt  LABEL "Фильтр".
DEFINE BUTTON bacc  LABEL "Доступ".

def frame f1 
    b1 
    skip
    space
    bedt 
    bnew
    bimp
    bdel
    bprt
    brpo
    bflt
    bacc
  with centered row 3 title "ЧЕРНЫЙ СПИСОК кредитования физических лиц".

on choose of bacc in frame f1 do:
  if not chkperm(g-ofc,v-pperm_main) then do:
    message " Нет прав выдачу доступов! Обратитесь к директору / ст.менеджеру ДПК" view-as alert-box error.
    leave.
  end.
  v-permed = ''.
  find first pksysc where pksysc.credtype = '6' and pksysc.sysc = 'badprm' no-lock no-error.
  if avail pksysc then v-permed = pksysc.chval.
  update v-permed no-label format "x(2000)" view-as fill-in size 60 by 1 help "Введите логины пользователей или пакеты через запятую"
     with centered row 10 overlay title " Доступ " frame pfr.
  if not avail pksysc then do:
    create pksysc.
    assign pksysc.credtype = '6'
           pksysc.sysc = 'badprm'.
  end.
  find current pksysc exclusive-lock.
  pksysc.chval = v-permed.
  find current pksysc no-lock.
end.

ON CHOOSE OF bflt IN FRAME f1 do:
    update   v-fio v-rnn with frame f-param.
    v-fio = trim(v-fio).
    run dolst.
  open query q1 for each t-badlst no-lock use-index main.
  b1:refresh().

END.

ON CHOOSE OF bedt IN FRAME f1 do:
  
  if not chkperm(g-ofc,'') then do:
    message " Нет прав! Обратитесь к директору / ст.менеджеру ДПК" view-as alert-box error.
    leave.
  end.
  
  run pkbadmemb (t-badlst.rid, false).
  v-rid = to-rowid(return-value).

  if return-value <> "" then do:
    run dolst.
    find t-badlst where to-rowid(t-badlst.rid) = v-rid no-lock no-error.
    v-rid = rowid(t-badlst).
    open query q1 for each t-badlst no-lock use-index main.
    get last q1.
    reposition q1 to rowid v-rid no-error.
    b1:refresh().
  end.
end.

ON CHOOSE OF bnew IN FRAME f1 do:
  
  if not chkperm(g-ofc,'') then do:
    message " Нет прав! Обратитесь к директору / ст.менеджеру ДПК" view-as alert-box error.
    leave.
  end.
  
  run pkbadmemb (t-badlst.rid, true).
  v-rid = to-rowid(return-value).

  if return-value <> "" then do:
    run dolst.
    find t-badlst where to-rowid(t-badlst.rid) = v-rid no-lock no-error.
    v-rid = rowid(t-badlst).
    open query q1 for each t-badlst no-lock use-index main.
    get last q1.
    reposition q1 to rowid v-rid no-error.
    b1:refresh().
  end.
end.

ON CHOOSE OF bimp IN FRAME f1 do: 
  run pkbadimp.

  run dolst.
  open query q1 for each t-badlst no-lock use-index main.
  b1:refresh().
end.

ON CHOOSE OF bdel IN FRAME f1 do:
    
    if not chkperm(g-ofc,'') then do:
      message " Нет прав! Обратитесь к директору / ст.менеджеру ДПК" view-as alert-box error.
      leave.
    end.
    
    MESSAGE skip 
            " " t-badlst.name skip
            " Дата рождения : " t-badlst.strdt skip
            "   РНН : " t-badlst.rnn + fill(" ", 12 - length(t-badlst.rnn)) skip
            " Удост : " t-badlst.docnum  + fill(" ", 12 - length(t-badlst.docnum)) skip(1)
            " Удалить из ЧЕРНОГО СПИСКА ?" skip(1)
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE " ВНИМАНИЕ ! " UPDATE v-ans.

  if v-ans then do transaction on error undo, leave:
    find pkbadlst where rowid(pkbadlst) = to-rowid(t-badlst.rid) exclusive-lock no-error.
    if avail pkbadlst then
      assign pkbadlst.sts = "D"
             pkbadlst.udt = today
             pkbadlst.uwho = g-ofc.
    release pkbadlst.
    run dolst.
    open query q1 for each t-badlst no-lock use-index main.
    b1:refresh(). 
  end.
end.

   
ON CHOOSE OF bprt IN FRAME f1 do:
  output stream r-lst to rpt.img.
  put stream r-lst 
    "ЧЕРНЫЙ СПИСОК кредитования физлиц" skip
    "на " g-today skip(1)
    "   N  РНН          ФИО                                                Дата рожд" skip
    fill("-", 100) format "x(100)" skip.

  for each t-badlst :
    put stream r-lst t-badlst.n " " t-badlst.rnn " " t-badlst.name " " t-badlst.strdt skip.
  end.
  output stream r-lst close.
  run menu-prt ("rpt.img").
  b1:refresh().
end.

ON CHOOSE OF brpo IN FRAME f1 do:
  run pkbadmrpo (t-badlst.rid).
end.


open query q1 for each t-badlst no-lock use-index main.

ENABLE all WITH FRAME f1.

b1:SET-REPOSITIONED-ROW(12, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

close query q1.
hide all no-pause.

procedure dolst.
  for each t-badlst. delete t-badlst. end.

  for each pkbadlst where pkbadlst.sts = "A" no-lock.

        if v-rnn <> "" and pkbadlst.rnn  <> v-rnn then next.
        if v-fio <> "" then do:
        
        if not (pkbadlst.lname matches ("*" + v-fio + "*")) and 
           not (pkbadlst.fname matches ("*" + v-fio + "*")) and 
           not (pkbadlst.mname matches ("*" + v-fio + "*")) then next.
        end.

        create t-badlst.
        buffer-copy pkbadlst to t-badlst.

        assign t-badlst.name = trim(caps(pkbadlst.lname)) + " " + trim(caps(pkbadlst.fname)) + " " + trim(caps(pkbadlst.mname))
               t-badlst.rid = string(rowid(pkbadlst)).
        if pkbadlst.bdt = ? then t-badlst.strdt = string(pkbadlst.ybdt, "9999").
                            else t-badlst.strdt = string(pkbadlst.bdt, "99/99/9999").
        t-badlst.sort = t-badlst.name.
  end.

  i = 0.
  for each t-badlst no-lock use-index main:
    i = i + 1.
    t-badlst.n = i.
  end.
end procedure.

