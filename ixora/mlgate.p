/* mlgate.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Настрока счетов внебаланса
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.5.14
 * BASES
        BANK COMM
 * AUTHOR
        06/08/2010 id00004
 * CHANGES
        15.08.2013 evseev - tz-1868
*/

{global.i}
def var str_p as char.

def temp-table t-ln
    field txb as char
    field name as char
index main is primary txb ASC.

  define frame fdetails
      gate.name  format "x(60)" validate(gate.name <> "", "Введите Ф.И.О пользователя") label "ФИО               " skip
      gate.email format "x(60)" validate(gate.email <> "", "Введите eMail")  label             "Email пользователя" skip
      gate.txb   format "x(5)" validate(gate.txb  = "TXB01" or gate.txb = "TXB00" or gate.txb = "TXB02" or gate.txb = "TXB03" or gate.txb = "TXB04" or gate.txb = "TXB05" or gate.txb = "TXB06" or gate.txb = "TXB07" or gate.txb = "TXB08" or gate.txb = "TXB09" or gate.txb = "TXB10" or gate.txb = "TXB11" or gate.txb = "TXB12" or gate.txb = "TXB13" or gate.txb = "TXB14" or gate.txb = "TXB15" or gate.txb = "TXB16", "Введите филиал")              label "Филиал            " help "F2-помощь"
  with side-labels centered row 5 width 90.


on help of gate.txb in frame fdetails do:
    empty temp-table t-ln.
    for each txb no-lock :
        create t-ln.
        assign t-ln.txb = txb.bank
               t-ln.name = txb.info.
    end.

    find first t-ln no-error.
    if not avail t-ln then do:
        message skip " Справочника нет !" skip(1) view-as alert-box button ok title "".
        return.
    end.
def var v-cod as char.
    {itemlist.i
        &file = "t-ln"
        &frame = "row 6 centered scroll 1 12 down overlay title 'Выберите Филиал' "
        &where = " true "
        &flddisp = " t-ln.name label 'Наименование' format 'x(12)'
                     t-ln.txb label 'Код' format 'x(50)'"
        &chkey = "txb"
        &chtype = "string"
        &index  = "main"

    }

    v-cod = frame-value.
    assign gate.txb =  v-cod.

    display  gate.txb  with frame fdetails.
end.



  DEFINE QUERY q1 FOR gate.
  define buffer buf for gate.
  def browse b1
     query q1
     displ
      gate.email  format "x(20)" label "E-mail "
      gate.name format "x(50)" label  "ФИО "
      gate.txb format "x(6)"   label " Филиал"
  with 12 down  title "Менеджеры" overlay .

  DEFINE BUTTON badd LABEL "Добавить"   .
  DEFINE BUTTON bRedakt LABEL "Изменить".
  DEFINE BUTTON brem LABEL "Удалить"    .
  DEFINE BUTTON bexit LABEL "Выход"     .

  def frame fr1 b1 skip badd bRedakt brem bexit  with centered overlay row 3 top-only  width 87.

  ON CHOOSE OF badd IN FRAME fr1
  do:
      create gate.
             update gate.name gate.email gate.txb with frame fdetails.

      hide frame fdetails.
      open query q1 for each gate no-lock break by gate.txb .
  end.

  ON CHOOSE OF bRedakt IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (gate) exclusive-lock no-error.
     if avail buf then do:
        displ  gate.email gate.name gate.txb with frame fdetails.
        update gate.email gate.name gate.txb with frame fdetails.
        hide frame fdetails.
        open query q1 for each gate no-lock break by gate.txb .
     end.

  end.



  ON CHOOSE OF brem IN FRAME fr1
  do:
     find buf where rowid (buf) = rowid (gate) exclusive-lock no-error.
     if avail buf then do:
        delete buf.
        browse b1:refresh().
     end.
  end.

  ON CHOOSE OF bexit IN FRAME fr1
  do:
     hide frame fr1.
     APPLY "WINDOW-CLOSE" TO BROWSE b1.
  end.


  open query q1 for each gate where gate.name <> "" no-lock by gate.txb .
  b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
  ENABLE all with frame fr1 centered overlay top-only.
  apply "value-changed" to b1 in frame fr1.
  WAIT-FOR WINDOW-CLOSE of frame fr1.

